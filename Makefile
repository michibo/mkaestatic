
.SUFFIXES:
.SUFFIXES:	.md .html .d

MD              :=          python aestatics.py
DEP             :=          python aestatics.py -d

%.html  :   %.md
	$(MD)  --config "$(CF_TGT)" $@ $<

%.d     :   %.md
	$(DEP) --config "$(CF_TGT)" $@ $<

all:		targets

dir := .
include $(dir)/Rules.mk


.PHONY:		targets
targets:	$(TGT_BIN) $(TGT_SBIN) $(TGT_ETC) $(TGT_LIB)

.PHONY:		clean
clean:
	rm -f $(CLEAN)

.SECONDARY:	$(CLEAN)
