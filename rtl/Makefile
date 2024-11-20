MODULES = cpu_test.sv alu.sv top.sv core.sv decoder.sv dmemory.sv imemory.sv regfile.sv hazard.sv uart.sv sram.sv

ROOT_DIR := $(realpath ../)

VERILATOR_FLAGS=-Wno-TIMESCALEMOD -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --threads `nproc` --trace

all: cpu

cpu: $(MODULES)
	verilator $(VERILATOR_FLAGS) --binary $(MODULES)

lint:
	verilator --lint-only -Wall --timing $(MODULES)

clean:
	rm -rf ./obj_dir

.PHONY: all cpu lint clean

