hsi::open_hw_design C:/Users/TimothyDuke/workspace/ArtyFreeTest/Debug/_sds/p0/vpl/system.hdf
set hw_design [hsi::current_hw_design]
# optionally set repo path here
hsi::generate_bsp -dir C:/Users/TimothyDuke/workspace/ArtyFreeTest/Debug/_sds/swstubs/standalone_bsp/scratch -hw ${hw_design} -os freertos10_xilinx -proc ps7_cortexa9_0
quit