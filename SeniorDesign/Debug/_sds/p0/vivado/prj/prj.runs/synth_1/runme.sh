#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/Vivado/2018.2/bin
else
  PATH=/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/SDK/2018.2/bin:/home/timothyduke/Documents/Vivado/2018.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/timothyduke/workspace/SeniorDesign/Debug/_sds/p0/vivado/prj/prj.runs/synth_1'
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

EAStep vivado -log Arty_Z7_20_wrapper.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source Arty_Z7_20_wrapper.tcl