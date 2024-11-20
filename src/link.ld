OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  imem (rx) : ORIGIN = 0x80000000, LENGTH = 0x800 /* SRAM 512B * 4 = 2KB */
  dmem (rw) : ORIGIN = 0x90000000, LENGTH = 0x800 /* SRAM 512B * 4 = 2KB */
}
SECTIONS
{
  . = 0x80000000;
  .text.init : { *(.text.init) } > imem
  .text : { *(.text) } > imem
  .tohost : { *(.tohost) } > dmem
  .data : { *(.data) } > dmem
  .bss : { *(.bss) } > dmem
  _end = .;
}
