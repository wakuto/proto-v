MODULES = cpu.sv alu.sv top.sv core.sv decoder.sv dmemory.sv imemory.sv regfile.sv hazard.sv uart.sv sram.sv gpio.sv

ROOT_DIR := $(realpath ../)

VERILATOR_FLAGS=-Wno-TIMESCALEMOD -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --threads `nproc` --trace -j `nproc`

TESTS = riscv_test

all: $(TESTS:%=obj_dir/V%)

obj_dir/V%: %.sv $(MODULES)
	verilator $(VERILATOR_FLAGS) --binary $< $(MODULES)

clean:
	rm -rf ./obj_dir

.PHONY: all cpu lint clean

