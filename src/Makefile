ROOT_DIR=../
PREFIX=riscv32-unknown-elf-
BANK_DIV_TOOL = $(ROOT_DIR)/test/tool/bank_division.py
DUMP_DIR = dump

# 入力ファイル
OBJS = $(wildcard *.S)

# 中間生成ファイル
ELF_FILES = $(OBJS:%.S=$(DUMP_DIR)/%.elf)
INST_FILES = $(ELF_FILES:%.elf=%.inst.bin)
DATA_FILES = $(ELF_FILES:%.elf=%.data.bin)

# 出力ファイル
INST_BANK_HEX = $(INST_FILES:.inst.bin=.inst.bank0.hex) \
                $(INST_FILES:.inst.bin=.inst.bank1.hex) \
                $(INST_FILES:.inst.bin=.inst.bank2.hex) \
                $(INST_FILES:.inst.bin=.inst.bank3.hex)
DATA_BANK_HEX = $(DATA_FILES:.data.bin=.data.bank0.hex) \
                $(DATA_FILES:.data.bin=.data.bank1.hex) \
                $(DATA_FILES:.data.bin=.data.bank2.hex) \
                $(DATA_FILES:.data.bin=.data.bank3.hex)

DUMP_FILES = $(ELF_FILES:.elf=.dump)
HEX_FILES = $(INST_FILES:.bin=.hex) $(DATA_FILES:.bin=.hex)

all: $(DUMP_FILES) $(HEX_FILES) $(INST_BANK_HEX) $(DATA_BANK_HEX)

$(DUMP_DIR)/%.o: %.S
	@if [ ! -d $(DUMP_DIR) ]; then \
		echo "mkdir $(DUMP_DIR)"; mkdir $(DUMP_DIR); \
	fi
	$(PREFIX)as $< -c -o $@

$(DUMP_DIR)/%.elf: $(DUMP_DIR)/%.o link.ld
	$(PREFIX)ld $< -Tlink.ld -o $@
  
%.inst.bin: %.elf
	$(PREFIX)objcopy -R .tohost -R .data -R .bss -O binary $< $@

%.data.bin: %.elf
	$(PREFIX)objcopy -R .text -R .text.init -O binary $< $@

$(DUMP_DIR)/%.hex: $(DUMP_DIR)/%.bin
	od -t x1 -A n -w1 -v $< > $@

%.bank0.hex %.bank1.hex %.bank2.hex %.bank3.hex: %.bin
	python $(BANK_DIV_TOOL) $<

$(DUMP_DIR)/%.dump: $(DUMP_DIR)/%.elf
	$(PREFIX)objdump -M numeric -M no-aliases -d $< > $@

clean:
	rm -rf $(DUMP_DIR)

.PHONY: all clean
