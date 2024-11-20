ROOT_DIR := $(realpath ../../)
BANK_DIV_TOOL = $(ROOT_DIR)/test/tool/bank_division.py
include $(ROOT_DIR)/common.mk

# 入力ファイル
OBJS = $(shell find . -not -name "*.hex" -not -name "*.bin" -not -name "." -not -name "Makefile" -exec echo {} \;)

# 中間生成ファイル
INST_FILES = $(OBJS:%=%.inst.bin)
DATA_FILES = $(OBJS:%=%.data.bin)

# 出力ファイル
INST_HEX = $(INST_FILES:.inst.bin=.inst.bank0.hex) \
           $(INST_FILES:.inst.bin=.inst.bank1.hex) \
           $(INST_FILES:.inst.bin=.inst.bank2.hex) \
           $(INST_FILES:.inst.bin=.inst.bank3.hex)

DATA_HEX = $(DATA_FILES:.data.bin=.data.bank0.hex) \
           $(DATA_FILES:.data.bin=.data.bank1.hex) \
           $(DATA_FILES:.data.bin=.data.bank2.hex) \
           $(DATA_FILES:.data.bin=.data.bank3.hex)


all: $(INST_FILES:.bin=.hex) $(DATA_FILES:.bin=.hex) $(INST_HEX) $(DATA_HEX)

%.inst.bin: %
	$(PREFIX)objcopy -R .tohost -R .data -R .bss -O binary $< $@

%.data.bin: %
	$(PREFIX)objcopy -R .text -R .text.init -O binary $< $@

%.hex: %.bin
	od -t x1 -A n -w1 -v $< > $@

%.bank0.hex %.bank1.hex %.bank2.hex %.bank3.hex: %.bin
	python $(BANK_DIV_TOOL) $<

clean:
	rm -rf *.hex *.bin

.PHONY: all
