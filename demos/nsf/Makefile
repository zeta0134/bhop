.PHONY: all clean dir run

SOURCEDIR := prg
ARTDIR := ../../art
TOOLSDIR := ../../tools/vendor
BUILDDIR := build
ROM_NAME := $(notdir $(CURDIR)).nsf
DBG_NAME := $(notdir $(CURDIR)).dbg
PY:=python3

# Assembler files, for building out the banks
PRG_ASM_FILES := $(wildcard $(SOURCEDIR)/*.s) 
O_FILES := \
  $(patsubst $(SOURCEDIR)/%.s,$(BUILDDIR)/%.o,$(PRG_ASM_FILES))

rebuild: clean all

all: dir $(ROM_NAME)

dir:
	@mkdir -p build

clean:
	-@rm -rf build
	-@rm -f $(ROM_NAME)
	-@rm -f $(BUILDDIR)/$(basename $(notdir $(ROM_NAME)))
	-@rm -f $(BUILDDIR)/$(basename $(notdir $(ROM_NAME)))_header
	-@rm -f $(DBG_NAME)

run: dir $(ROM_NAME)
	rustico-sdl $(ROM_NAME)

beta: dir $(ROM_NAME)
	/home/zeta0134/Downloads/MesenBeta/Mesen $(ROM_NAME)

$(ROM_NAME): $(BUILDDIR)/$(basename $(notdir $(ROM_NAME)))
	cat $^_header $^ > $@

$(BUILDDIR)/$(basename $(notdir $(ROM_NAME))): $(BUILDDIR)/auto_nsf.cfg $(O_FILES)
	ld65 -m $(BUILDDIR)/map.txt --dbgfile $(DBG_NAME) -o $@ -C $^

$(BUILDDIR)/auto_nsf.cfg: $(SOURCEDIR)/nsf.cfg $(O_FILES)
	$(PY) $(TOOLSDIR)/doctor_fill.py nsf $@ $^

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.s
	ca65 -g -o $@ $< -l $(BUILDDIR)/$(basename $(notdir $<)).lst

