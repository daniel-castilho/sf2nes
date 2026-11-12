# Street Fighter II NE (DEMO by Parisoft) — disassembly remontavel
#
#   make          monta build/sf2ne.nes e confere que e' IDENTICO ao ROM original (byte a byte)
#   make gen      regenera src/ a partir de rom/ + trace/ + annotations/sf2ne.ann  (fase de anotacao)
#   make fixed    monta build/sf2ne_fixed.nes com as correcoes opcionais ligadas (blocos `alt` das anotacoes)
#   make prontos  monta as variantes jogaveis em prontos/ (reset corrigido, versus, golpe forte unico, golpe na borda)
#   make assets   exporta os graficos (PNG) e as vozes (WAV) para extracted/
#   make clean
#
# Requisitos: cc65 (ca65/ld65) e python3.   Debian/Ubuntu: sudo apt install cc65

ROM      := rom/sf2ne_demo.nes
SHA1     := 0bf9dc578de5a10bb9f429845c26fd2f958a9aed
BUILD    := build
SRCS     := $(sort $(wildcard src/*.s))
OBJS     := $(patsubst src/%.s,$(BUILD)/%.o,$(SRCS))
INCS     := $(wildcard src/*.inc)
CA65FLAGS := -I src --bin-include-dir .

.PHONY: all gen verify fixed prontos assets clean
all: $(BUILD)/sf2ne.nes

$(BUILD)/%.o: src/%.s $(INCS)
	@mkdir -p $(BUILD)
	ca65 $(CA65FLAGS) $(DEFS) $< -o $@

$(BUILD)/sf2ne.nes: $(OBJS) sf2ne.cfg
	ld65 -C sf2ne.cfg $(OBJS) -o $@ -m $(BUILD)/sf2ne.map -Ln $(BUILD)/sf2ne.labels

verify: $(BUILD)/sf2ne.nes
	@if cmp -s $(BUILD)/sf2ne.nes $(ROM); then 	    echo "OK: build/sf2ne.nes e' identico ao ROM original (sha1 $(SHA1))"; 	else 	    echo "ATENCAO: build/sf2ne.nes diverge do ROM original (sha1 $(SHA1))"; 	fi

gen:
	python3 tools/disasm.py

# ---- versao com correcoes (nao e' identica ao original, de proposito)
# correcoes ligadas no `make fixed`. Para experimentar outras:  make fixed FIXDEFS="-D FIX_SOFT_RESET -D FIX_HEAVY_ONCE"
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

# ROMs prontos para jogar (copias em prontos/, que e' versionado; build/ nao e')
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
