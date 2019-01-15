#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
# 

echo "This script was generated under a different operating system."
echo "Please update the PATH and LD_LIBRARY_PATH variables below, before executing this script"
exit

if [ -z "$PATH" ]; then
  PATH=E:/SDSoC/SDK/2018.2/bin;E:/SDSoC/SDK/2018.2/bin;E:/SDSoC/SDK/2018.2/bin;E:/SDSoC/SDK/2018.2/bin:E:/SDSoC/Vivado/2018.2/bin
else
  PATH=E:/SDSoC/SDK/2018.2/bin;E:/SDSoC/SDK/2018.2/bin;E:/SDSoC/SDK/2018.2/bin;E:/SDSoC/SDK/2018.2/bin:E:/SDSoC/Vivado/2018.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='C:/Users/TimothyDuke/workspace/ArtyFreeTest/Debug/_sds/p0/vivado/prj/prj.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log Arty_Z7_20_wrapper.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source Arty_Z7_20_wrapper.tcl -notrace

