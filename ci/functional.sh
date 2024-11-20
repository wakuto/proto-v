#!/bin/bash

set -e

echo "proto-v Functional Test"

functional() {
  make -C src
  make -C rtl

  mkdir -p ./log/vcd
  hex_file=$(find src/dump/ -type f -name "*.inst.hex" | sort -n )
  hex_file="${hexfile%.inst.hex}"
  log_file=./log/result-$(date "+%Y-%m-%d-%H-%M-%S").log

	for name in ${hex_file}; do\
	  ./rtl/obj_dir/Vcpu_test +inst=$name.inst.hex +data=$name.data.hex +log=$log_file +vcd=./log/vcd/$(basename $name).vcd;
	done

  echo ""
  echo "Please implement functional tests!"
  # echo ""
  # error=$(cat $log_file | grep "FAILED")
  # if [ "$error" = "" ]; then
  #   echo "ALL TEST PASSED!"
  # else
  #   echo "$error"
  #   echo "logfile: $log_file"
  # fi
}

functional
