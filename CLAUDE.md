# CLAUDE.md

**mkaestatic** is Michael Borinsky's minimalist static website generator
(github.com/michibo/mkaestatic, MIT, 2016–2024). It glues together **GNU make**, **Python 3**,
**Mistune v3** (Markdown), **Jinja2** (templates) and **PyYAML** (configs). The whole generator is
`mkaestatic.py` (~330 lines) plus two make files.

`readme.md` is the user manual. It is also the content of the demo site in this repo, so it gets
rendered to `readme.html` (and mirrored to `index.html`). Keep it accurate when the behaviour changes.

## Repository layout

| Path | Role |
|---|---|
| `mkaestatic.py` | The generator: front-matter extraction, rendering, URL rewriting, `.d` dependency files |
| `Makefile` | Top-level make driver: suffix rules, user config block, deploy targets |
| `Pages.mk` | Per-directory page list (non-recursive make). Must exist in every included directory |
| `Site.yml` | Global site config (`name`, `tagline`, default `template`) → `site.*` in templates |
| `_templates/default.html` | Demo Jinja template: auto menu from `root`, optional blog menu |
| `static/` | Demo static files (`style.css`, `Harrison_H4_clock_design.jpg`) |
| `readme.md`, `index.md`, `example.md`, `contact.md` | Demo pages. `index.md` has `mirror: readme.html` and `nomenu: true` |
| `blog/`, `blog/archive/` | Subdirectory demo with their own `Pages.mk`. **Not built by default**: the include block in the root `Pages.mk` is commented out |
| `*.html` | Generated, but **committed** so the repo works as a GitHub Pages demo |
| `*.yml` (except Site.yml), `*.d` | Generated, gitignored |
| `LICENSE` | MIT |

## Build pipeline in detail

Each page `X.md` goes through two invocations of `mkaestatic.py`, both driven by make:

1. **Config pass**: `python3 mkaestatic.py X.md --parse_yml` (make rule `%.yml : %.md`).
   `mdsplit()` splits off the Jekyll-style front matter: an optional leading `---`, YAML, then a
   `---` line. The YAML is normalised with `yaml.dump` and written to `X.yml` **only if it
   changed**. That way, editing page *content* doesn't touch the `.yml`, and other pages don't
   need rebuilding. A file without any `---` line gets the config `{}`.
2. **Render pass**: `python3 mkaestatic.py X.md --configs "<all .yml>" --site_config Site.yml`
   (rules `%.html : %.md` and `%.d : %.md`).
   - `load_configs()` reads **every** page's `.yml` into a `dirlisttree`. It adds `url`
     (`/path/X.html`), `name` (basename) and the default `title` (= name), and picks out the
     current page's config. If the current page's `.yml` isn't in the list, it raises
     "referenced but not included in the make": the page's directory has no `Pages.mk` wired in.
   - If the page has `mirror: other.html`, that file is copied verbatim and becomes a hard dependency.
   - Otherwise the template is the page's `template:` key, falling back to `Site.yml`'s
     `template:`. If neither is set, it raises `ValueError`.
   - `render()` runs Mistune with a custom renderer whose `link`/`image` pass URLs through
     `url_transform`. Jinja gets a custom loader that records every loaded template (including
     `{% extends %}`/`{% include %}`) as a hard dependency, plus a `localurl` filter (the same
     `url_transform`).
   - `write_dep_file()` writes `X.d`:
     ```make
     X.html X.d : <hard deps: templates / mirror source>
     REQUISITES+=<soft deps: every local file referenced>
     ```

### Template variables
- `content`: rendered page HTML
- `site`: `Site.yml`
- `page`: current page config (front matter + `url`, `name`, `title`)
- `root`: `dirlisttree` of all pages. Iterating it yields the page configs of the top directory.
  Subdirectories are accessed by attribute or key (`root.blog`, `'blog' in root`). `root["a/b"]`
  splits the path.
- `home`: relative path from the current page back to the top directory

### URL rewriting (`get_url_transform`)
This is the core idea. Everything is **relative**, so a site works when copied into any
subdirectory (`~user/`) and over `file://`.
- Leaves URLs with a netloc (`//host/..`, `https://..`), any scheme (`mailto:`), or only a
  `#fragment` unchanged.
- `/path/file`: rewritten to `relpath(path/file, page_dir)` and added as a soft dependency.
  The `?query#fragment` suffix is kept (since Nov 2026; before that it was silently dropped,
  e.g. font `?#iefix`).
- `/` alone: becomes the relative path to the site root plus `/`.
- A relative `file` (no leading slash) is kept as written. `page_dir/file` is added as a soft dependency.

## Make machinery

- `Makefile` includes the root `Pages.mk`. Each `Pages.mk` uses the van Bergen non-recursive
  scheme: a directory stack in `sp`/`dirstack_*`, with `$(d)` = the current directory prefix.
- A `Pages.mk` sets `PAGES_SRC_$(d)` (default: all `$(d)*.md`; the root one filters out
  `CLAUDE.md`). Subdirectories are added explicitly:
  ```make
  dir := $(d)blog/
  include $(dir)Pages.mk
  MKCONFIGS+=$(dir)Pages.mk
  ```
  It then appends to the global `PAGES`, `TGTS` (.html), `CONFIGS` (.yml), `DEPS` (.d) and
  `CLEAN`, and runs `-include`s the `.d` files.
- Every `.html`/`.d` depends on **all** `.yml` configs, all `Pages.mk` files and `Site.yml`.
  So a front-matter change (e.g. a title, which could appear in menus) rebuilds every page.
  Content-only edits rebuild just that page.
- `FILES = sort(TGTS + REQUISITES)` is the full deploy set. A referenced local file that doesn't
  exist and has no rule makes `make` fail ("No rule to make target"). That is the broken-link check.
- `.SECONDARY: $(CLEAN)` keeps intermediates around.

### Targets
`make` / `make all` (build), `make serve` (build + `python3 -m http.server 8000`), `make build`
(copy `FILES` into `built/`), `make tar` (`built.tar.gz`), `make upload` (tar over ssh to
`SSH_SERVER:SSH_FOLDER` and chmod 755), `make git-add-requisites` (`git add $(FILES)`),
`make clean`.

**Caution:** `make clean` also deletes the committed demo `.html` files. Run `make` afterwards
before committing.

## Working on this repo

- Requirements: `pip install mistune jinja2 pyyaml`. Only Mistune ≥ 3 works (renderer API
  changed in v2 and again in v3; see commits from 2022-01-01 and 2024-03-04).
- There is no test suite. To verify a change: `make clean && make`, then `git diff *.html`.
  Only intended changes should show up. Also try the `blog/` subdirectory demo by uncommenting
  its block in `Pages.mk`, but don't commit that.
- Keep the code style: plain functions, docstrings, `( spaces )` inside some calls, no extra
  dependencies. Keep it small. The "only ~350 lines" claim is a feature listed in the readme.
- Update `readme.md` (and regenerate `readme.html`/`index.html`) whenever behaviour or
  requirements change.
- The header comments in the files say "Copyright 2016-2022".

## Known quirks / possible improvements
- A front matter that is present but empty (`---` followed directly by `---`) gives `None`
  from YAML, which crashes `load_configs` (`cfg['url'] = ...`).
- The default renderer escapes raw HTML in Markdown (Mistune default). Sites that need raw
  HTML have to change `MyRenderer` (e.g. `HTMLRenderer(escape=False)`).
- `make upload` chmods only `.` and the files, not intermediate directories.
