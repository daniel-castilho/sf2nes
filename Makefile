# Street Fighter II NE (DEMO by Parisoft) — remontable disassembly
#
#   make          builds build/sf2ne.nes (canonical build: modified ROM, with Ken playable)
#   make verify   optional HISTORICAL check: compares the build with rom/sf2ne_demo.nes
#   make gen      regenerates src/ from rom/ + trace/ + annotations/sf2ne.ann
#   make fixed    builds build/sf2ne_fixed.nes with optional fixes linked (annotation `alt` blocks)
#   make prontos  builds playable variants in prontos/ (reset fix, versus, strong attack once, edge attack)
#   make assets   exports graphics (PNG) and voices (WAV) to extracted/
#   make clean
#
# Requirements: cc65 (ca65/ld65) and python3.   Debian/Ubuntu: sudo apt install cc65

ROM      := rom/sf2ne_demo.nes
SHA1     := 0bf9dc578de5a10bb9f429845c26fd2f958a9aed
BUILD    := build
SRCS     := $(sort $(wildcard src/*.s))
OBJS     := $(patsubst src/%.s,$(BUILD)/%.o,$(SRCS))
INCS     := $(wildcard src/*.inc)
CA65FLAGS := -I src --bin-include-dir .

# Canonical build definitions (make). The original demo does not have Ken nor the destination country flag of
# destination visible on selection; `make fixed`/`make prontos` build the historical variants, without these
# definicoes.
DEFS     := -D DEST_FLAG_BLINK

.PHONY: all gen verify fixed prontos assets clean
all: $(BUILD)/sf2ne.nes

$(BUILD)/%.o: src/%.s $(INCS)
	@mkdir -p $(BUILD)
	ca65 $(CA65FLAGS) $(DEFS) $< -o $@

$(BUILD)/sf2ne.nes: $(OBJS) sf2ne.cfg
	ld65 -C sf2ne.cfg $(OBJS) -o $@ -m $(BUILD)/sf2ne.map -Ln $(BUILD)/sf2ne.labels

# HISTORICAL check, optional: the canonical build includes Ken and does not need to be equal to the demo.
verify: $(BUILD)/sf2ne.nes
	@if cmp -s $(BUILD)/sf2ne.nes $(ROM); then 	    echo "OK: build/sf2ne.nes is identical to original ROM (sha1 $(SHA1))"; 	else 	    echo "WARNING: build/sf2ne.nes diverges from original ROM (sha1 $(SHA1)); expected in Ken build"; 	fi

gen:
	python3 tools/disasm.py

# Conversao de estados/quadros do formato declarativo (TOML) para assembly.
# Separate non-destructive target: does not modify the existing make gen.
# The generated .s files are placed in src/ and can be included in the build
# via annotations/sf2ne.ann (keepbank) or sf2ne.cfg.
STATE_TOML_DIR := data/estados
STATE_GEN_DIR  := src
STATE_GEN_TOOL := tools/state_data_gen.py

gen-states:
	@mkdir -p $(STATE_GEN_DIR)
	@for f in $(STATE_TOML_DIR)/*.toml; do \
		base=$$(basename "$$f" .toml); \
		echo "Convertendo $$f -> $(STATE_GEN_DIR)/$$base.s"; \
		python3 $(STATE_GEN_TOOL) "$$f" "$(STATE_GEN_DIR)/$$base.s"; \
	done

# ---- version with fixes (not identical to original, on purpose)
# fixes linked in `make fixed`. To experiment with others:  make fixed FIXDEFS="-D FIX_SOFT_RESET -D FIX_HEAVY_ONCE"
FIXDEFS  ?= -D FIX_SOFT_RESET
FIXOBJS  := $(patsubst src/%.s,$(BUILD)/fixed/%.o,$(SRCS))

$(BUILD)/fixed/%.o: src/%.s $(INCS)
	@mkdir -p $(BUILD)/fixed
	ca65 $(CA65FLAGS) $(FIXDEFS) $< -o $@

$(BUILD)/sf2ne_fixed.nes: $(FIXOBJS) sf2ne.cfg
	ld65 -C sf2ne.cfg $(FIXOBJS) -o $@ -m $(BUILD)/sf2ne_fixed.map -Ln $(BUILD)/sf2ne_fixed.labels

fixed:
	@rm -rf $(BUILD)/fixed $(BUILD)/sf2ne_fixed.nes      # as opcoes mudam entre chamadas: remonta sempre
	@$(MAKE) --no-print-directory $(BUILD)/sf2ne_fixed.nes FIXDEFS="$(FIXDEFS)" > /dev/null
	@echo "build/sf2ne_fixed.nes: $$(cmp -l $(BUILD)/sf2ne_fixed.nes $(ROM) | wc -l) bytes diferentes do original ($(FIXDEFS))"

# ROMs ready to play (copies in prontos/, which is versioned; build/ is not)
prontos:
	@mkdir -p prontos
	@$(MAKE) --no-print-directory fixed && cp $(BUILD)/sf2ne_fixed.nes prontos/sf2ne_reset_corrigido.nes
	@$(MAKE) --no-print-directory fixed FIXDEFS="-D FIX_SOFT_RESET -D MODE_VERSUS" && cp $(BUILD)/sf2ne_fixed.nes prontos/sf2ne_versus.nes
	@$(MAKE) --no-print-directory fixed FIXDEFS="-D FIX_SOFT_RESET -D FIX_HEAVY_ONCE" && cp $(BUILD)/sf2ne_fixed.nes prontos/sf2ne_golpe_forte_unico.nes
	@$(MAKE) --no-print-directory fixed FIXDEFS="-D FIX_SOFT_RESET -D FIX_EDGE_ATTACK" && cp $(BUILD)/sf2ne_fixed.nes prontos/sf2ne_golpe_na_borda.nes
	@$(MAKE) --no-print-directory fixed > /dev/null
	@ls -l prontos/*.nes

assets:
	python3 tools/extract_chr.py
	python3 tools/extract_dpcm.py

clean:
	rm -rf $(BUILD)
