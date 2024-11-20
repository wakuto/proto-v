ROOT_DIR := $(realpath ../)
CUR_DIR := $(realpath ./)

RISCV_TESTS = $(ROOT_DIR)/riscv-tests

TEST_TARGET = "rv32ui-p-*"
RISCV_TESTS_OBJS = $(shell find $(ISA_DIR) -not -name "*.hex")
HEX_FILES = $(shell find $(ISA_DIR) -name "*.hex" -name $(TEST_TARGET))

all: isa

riscv-tests:
	# rv*-p- のビルド時に自前のリンカスクリプトを使用する（ただし、今回使用するのはrv32ui-p-のみ）。
	# リンカスクリプトを置換する方法だと、rv*-v- のリンカスクリプトも変更されてしまうため、Makefileを変更している。
	# rv*-v- はコードサイズが大きくSRAM容量を超えるため、自前のリンカスクリプトを使用した場合にエラーとなる。
	# 正しいリンカスクリプトを使用しているのはrv*-p-のみなので、それ以外のバイナリは正常に実行できない。
	sed -i 's#-T$$(src_dir)/../env/p/link.ld#-T$(ROOT_DIR)/src/link.ld#' $(RISCV_TESTS)/isa/Makefile
	cd $(RISCV_TESTS) && autoupdate && autoconf && ./configure --with-xlen=32 && make -j -C $(RISCV_TESTS)/isa/ rv32ui
	find $(RISCV_TESTS)/isa/ -maxdepth 1 -type f -name $(TEST_TARGET) -not -name "*.dump" -exec mv {} isa/ \;

isa: riscv-tests
	make -C isa

clean:
	make -C $(RISCV_TESTS) clean
	make -C isa clean

.PHONY: riscv-tests isa


  
