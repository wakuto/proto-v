#!/bin/bash

set -e

echo "proto-v Regression Test"

isa() {
  make -C test
  make -C rtl

  mkdir -p ./log/vcd
  hex_file=$(find test/isa/ -type f -name "rv32ui-p-*" -not -name "*.hex" -not -name "*.bin" | sort -n )
  log_file=./log/result-$(date "+%Y-%m-%d-%H-%M-%S").log

	for name in ${hex_file}; do\
	  ./rtl/obj_dir/Vcpu_test +inst=$name.inst.hex +data=$name.data.hex +log=$log_file +vcd=./log/vcd/$(basename $name).vcd;
	done

  echo ""
  error=$(cat $log_file | grep "FAILED")
  if [ "$error" = "" ]; then
    echo "ALL TEST PASSED!"
  else
    echo "$error"
    echo "logfile: $log_file"
  fi
}

isa
