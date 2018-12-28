package require math::bignum

namespace eval ocl_util {
  namespace export lock_crit_cells write_cookie_file_impl report_utilization_impl \
                   report_timing_and_scale_freq  get_achievable_kernel_freq write_new_clk_freq \
                   write_user_impl_clock_constraint

  proc get_script_dir {} [list return [file dirname [info script]]]

  proc dict_get_default {adict key default} {
    if { [dict exists $adict $key] } {
      return [dict get $adict $key]
    }
    return $default
  }

  proc error2file {dir msg {catch_res ""}} {
    global vivado_error_file
    if { $catch_res ne "" } {
      puts "ERROR: caught error: $catch_res"
    }
    regsub -nocase {^\s*ERROR\s*:*\s*} $msg {} msg
    set fname [file join $dir $vivado_error_file]
    # puts "--- DEBUG: Writing to file $fname: $msg"
    set fh [open $fname w]
    puts $fh $msg
    close $fh
    uplevel 1 error [list $msg]
    #error $msg
  }

  proc warning2file {dir msg } {
    global vivado_warn_file
    puts "$msg"
    regsub -nocase {^\s*(CRITICAL)?\s*WARNING\s*:\s*} $msg {} msg
    set fname [file join $dir $vivado_warn_file]
    # puts "--- DEBUG: Writing warnings to file $fname: $msg"
    # this file may have multiple warning messages, we should use "append" mode
    set fh [open $fname a+]
    puts $fh $msg
    close $fh
  }

  set System "system"
  set Kernel "kernel"

  # Initialize rule-checker functionality if the environment has been configured for it.
  set drcv_connected false
  if {[info exists ::env(XILINX_RS_PORT)]} {
    if { [catch {
      # Load library (shared/common/services/rulecheck/client/tcl)
      set result [load librdi_drcvtcl[info sharedlibextension]]
      # Connect
      if {$result eq "true"} {
        set result [::drcv::connect]
      }
      # Load rules
      if {$result eq "true"} {
        set platformSeparator ":"
        if {[info exist tcl_platform(platform)] && ($tcl_platform(platform) == "windows")} {
          set platformSeparator ";"
        }
        set rule_part [file join scripts ocl ocl_rules.cfg]
        foreach rdiRoot [split "$::env(RDI_APPROOT)" $platformSeparator] {
          set path_test [file join $rdiRoot $rule_part]
          if {[file exists $path_test]} {
            set rule_path $path_test
            break
          }
        }
        if {$rule_path ne ""} {
          set result [::drcv::load_rule_data_file $rule_path]
          set drcv_connected $result    
        }
      }
    } catch_res] } {
      #TODO: This doesn't appear to work so early in the flow because
      # can't read "vivado_warn_file": no such variable
      #warning2file [pwd] "failed to connect to rulecheck server: $catch_res"
      puts "WARNING: failed to connect to rulecheck server - $catch_res"
    }
  }
  proc is_drcv {} {
    if { $ocl_util::drcv_connected } { return true }
    return false
  }

  # Dummy proc "OPTRACE".  Needs to be created in case the real OPTRACE proc
  # isn't inserted
  if { [expr {[llength [info procs ::OPTRACE]] == 0}] } {
    proc ::OPTRACE {{arg1 \"\" } {arg2 \"\"} {arg3 \"\" } {arg4 \"\"} {arg5 \"\" } {arg6 \"\"}} {
        # Do nothing
    }
  }

  proc create_ocl_region_bd {dsa_name dsa_ports {kernels {}} {ocl_ip_dict {}} {kernel_resources_dict {}} {debug_settings {}} {generate_bd true}} {
    set startdir [pwd]

    #set start_time [clock seconds]
    # Update input data to conform to expectations
    if { [catch {update_kernel_info kernels} catch_res] } {
      error2file $startdir "invalid kernel information" $catch_res
    }
    
    if { [catch {update_ocl_ip_info $ocl_ip_dict $dsa_ports} catch_res] } {
      error2file $startdir "invalid dynamic region information" $catch_res
    } else {
      set ocl_ip_config $catch_res
    }
    dict set ocl_ip_dict CONFIG $ocl_ip_config


    set kernel_debug [dict_get_default $debug_settings KERNEL_DEBUG false]
    set enable_protocol_checker [dict_get_default $debug_settings PROTOCOL_CHECKER false]

    # Source IP TCL script
    set ocl_ip_vlnv [dict get $ocl_ip_dict VLNV] 
    set ip_ns_prefix [source_ocl_ip_tcl_file $ocl_ip_vlnv]

    # Run IP TCL to re-create BD content
    puts "Creating BD external ports..."
    if { [catch {${ip_ns_prefix}create_boundary $ocl_ip_config created_ports_dict} catch_res] } {
      error2file $startdir "problem with dynamic region boundary" $catch_res
    }

    puts "Creating BD contents..."
    if { [catch {${ip_ns_prefix}create_contents $ocl_ip_config $kernels $kernel_resources_dict} catch_res] } {
      error2file $startdir "problem with dynamic region: $catch_res"
    } else {
      set ocl_content_dict $catch_res
    }
   
    puts "Updating BD port configurations..."
    if { [catch {update_port_config $dsa_ports $created_ports_dict} catch_res] } {
      error2file $startdir "problem with dynamic region ports" $catch_res
    }

    puts "Updating kernel resources..."
    if { [catch {update_kernel_resources $kernel_resources_dict $ocl_content_dict $ip_ns_prefix $ocl_ip_config} catch_res] } {
      error2file $startdir "problem with dynamic region kernel resources" $catch_res
    }
    
    # Add profiling
    if { [is_profiling_enabled $kernels] } {
      puts "Updating profiling resources..."
      save_bd_design
      set profiling [dict_get_default $kernel_resources_dict PROFILING {}]
      if { [catch {update_profiling_resources $ocl_content_dict $kernels $profiling} catch_res] } {
        error2file $startdir "problem with dynamic region profiling" $catch_res
      }
    }
    
    # Add kernel debugging (HW emulation only)
    if { [is_debug_enabled $debug_settings] } {
      puts "Updating kernel debug resources..."
      save_bd_design
      if { [catch {update_debug_resources $ocl_content_dict $kernels} catch_res] } {
        error2file $startdir "problem with kernel debugging" $catch_res
      }
    }

    # Add protocol checker (HW emulation only)
    if { [is_protocol_checker_enabled $debug_settings] } {
      puts "Adding protocol checker..."
      save_bd_design
      if { [catch {enable_protocol_checker $ocl_content_dict $kernels} catch_res] } {
        error2file $startdir "problem with adding protocol checker" $catch_res
      }
    }
    
    puts "Updating addressing..."
    if { [catch {update_addressing $ip_ns_prefix $dsa_ports $ocl_content_dict} catch_res] } {
      error2file $startdir "problem with dynamic region addressing" $catch_res
    }

    
    ### Following are manual work-arounds
    #if { [string match -nocase "vc690-admpcie7v3-1ddr-gen2" $dsa_name] } {
    #  assign_bd_address
    #  set addr_seg [get_bd_addr_segs {kernel_0/Data/SEG_M_AXI_Reg}]
    #  puts "old_offset=[get_property offset $addr_seg] old_range=[get_property range $addr_seg]"
    #  set_property offset 0x00000000 $addr_seg
    #  set_property range 4G $addr_seg
    #}

    if { [catch {
      save_bd_design 
      validate_bd_design
      save_bd_design 
    } catch_res] } {
      error2file $startdir "problem validating dynamic region" $catch_res
    }

    
    if { $generate_bd } {
      if { [catch {
      set design_name [get_property name [current_bd_design]]
      set_property synth_checkpoint_mode Hierarchical [get_files ${design_name}.bd]
      generate_target {synthesis simulation implementation} [get_files ${design_name}.bd] 
      add_files -norecurse [make_wrapper -top -files [get_files ${design_name}.bd]]
      update_compile_order -fileset sources_1
      update_compile_order -fileset sim_1
      } catch_res] } {
        error2file $startdir "problem with dynamic region generation" $catch_res
    }
    }

    #set run_time [expr [clock seconds] - $start_time]
    #puts "PROFILE:create_ocl_region_bd took $run_time seconds"

    # Return info
    # TODO: add debug, perf info that was added to BD
    return $ocl_content_dict
  }; # end create_ocl_region_bd

  proc is_profiling_enabled {kernels} {
    foreach kernel_inst $kernels {
      if { [dict get $kernel_inst DEBUG] >= 2 } {
        return true
      }
    }
    return false
  }
  
  proc is_debug_enabled {debug_settings} {
    if { [dict exists $debug_settings KERNEL_DEBUG] } {
      if { [dict get $debug_settings KERNEL_DEBUG] } {
        if { [dict exists $debug_settings SIMULATOR] && [dict get $debug_settings SIMULATOR] == "Xsim" } {
          return true
        }
      }
    }
    return false
  }
  
  proc is_protocol_checker_enabled {debug_settings} {
    if { [dict exists $debug_settings PROTOCOL_CHECKER] } {
      if { [dict get $debug_settings PROTOCOL_CHECKER] } {
          return true
      }
    }
    return false
  }

  proc enable_protocol_checker {ocl_content_dict kernels} {
    set clk_obj [get_bd_net [dict get $ocl_content_dict clk_kernel_net]]
    set rst_obj [get_bd_net [dict get $ocl_content_dict rst_kernel_sync_net]]
    
    # Add protocol checker in all AXI-MM ports on all kernels
    set aximmPorts [list]
    foreach kernel_inst $kernels {
      set cu_inst [dict get $kernel_inst NAME]
      set cu_axi_pins [get_bd_intf_pins -of_objects [get_bd_cells $cu_inst] -filter {VLNV =~ "*aximm*"} -quiet]
      foreach cu_axi_pin $cu_axi_pins {
        lappend aximmPorts $cu_axi_pin
      }
    }
    add_protocol_checker $clk_obj $rst_obj $aximmPorts
  
  }; # end enable_protocol_checker 

  ################################################################################
  # add_protocol_checker
  #   Description:
  #     Insert axi protocol checker for HW emulation into OCL region
  #   Arguments:
  #     clk_obj      clock object to use
  #     rst_obj      reset object to use
  #     aximmPorts   list of AXI intf ports for protocol checking
  #
  ################################################################################
  proc add_protocol_checker {clk_obj rst_obj aximmPorts} {
    if {[llength $aximmPorts] == 0} {
      puts "WARNING: no ports specified for protocol checking"
      return
    }
    
    # Insert monitor interface block on each port
    foreach pinName $aximmPorts {
      if { [get_bd_intf_pins $pinName] eq "" } {
        puts "WARNING: interface pin $pinName not found in current block diagram"
        continue
      }
      
      # Instantiate monitor
      set tmpName "axi_protocol_checker_[string trimleft $pinName "/"]"
      set ipName [string map {"/" "_"} $tmpName]
      puts "INFO: adding $ipName for protocol checking..."
      set mon_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_checker $ipName]
      
      connect_bd_net -net $clk_obj [get_bd_pins $ipName/aclk]
      connect_bd_net -net $rst_obj [get_bd_pins $ipName/aresetn]
      
      # Connect AXI port
      connect_bd_intf_net [get_bd_intf_pins $ipName/PC_AXI] [get_bd_intf_pins $pinName]
    }
  }; # end add_protocol_checker

  proc update_debug_resources {ocl_content_dict kernels} {
    #
    # Monitor kernels 
    #
    set clk_obj [get_bd_net [dict get $ocl_content_dict clk_kernel_net]]
    set rst_obj [get_bd_net [dict get $ocl_content_dict rst_kernel_sync_net]]
     
    # Monitor all AXI-MM ports on all kernels
    set perfMonPorts [list]
    foreach kernel_inst $kernels {
      set cu_inst [dict get $kernel_inst NAME]
      #set cu_axi_pins [get_bd_intf_pins -of_objects [get_bd_cells $cu_inst] -filter {VLNV =~ "*aximm*" && CONFIG.PROTOCOL =~ "AXI4"} -quiet]
      set cu_axi_pins [get_bd_intf_pins -of_objects [get_bd_cells $cu_inst] -filter {VLNV =~ "*aximm*" && CONFIG.PROTOCOL =~ "AXI4"} -quiet]
      foreach cu_axi_pin $cu_axi_pins {
        lappend perfMonPorts $cu_axi_pin
      }
    }
    
    puts "Adding kernel debug resources: ports = ${perfMonPorts}" 
    add_kernel_debug $clk_obj $rst_obj ${perfMonPorts}
    
    #
    # Monitor interconnect masters
    #
    set clk_obj [get_bd_net [dict get $ocl_content_dict clk_interconnect_net]]
    set rst_obj [get_bd_net [dict get $ocl_content_dict rst_interconnect_sync_net]]
     
    # Monitor all AXI-MM master ports on master interconnect
    set perfMonPorts [list]
    set interconCells [get_bd_cells -hier -filter {NAME=~"m_axi_interconnect_M*"}]
    set master_pins [get_bd_intf_pins -of_objects $interconCells -filter {MODE =~ "Master"} -quiet]
    foreach master_pin $master_pins {
      lappend perfMonPorts $master_pin
    }
    
    puts "Adding kernel debug resources: ports = ${perfMonPorts}" 
    add_kernel_debug $clk_obj $rst_obj ${perfMonPorts}
  }; # end update_debug_resources
  
  ################################################################################
  # add_kernel_debug
  #   Description:
  #     Insert simple debug monitoring for HW emulation into OCL region
  #   Arguments:
  #     clk_obj      clock object to use
  #     rst_obj      reset object to use
  #     monNameList  list of AXI intf ports to monitor
  #
  ################################################################################
  proc add_kernel_debug {clk_obj rst_obj monNameList} {
    if {[llength $monNameList] == 0} {
      puts "WARNING: no ports specified for kernel debugging"
      return
    }
    
    # Insert monitor interface block on each port
    foreach pinName $monNameList {
      if { [get_bd_intf_pins $pinName] eq "" } {
        puts "WARNING: interface pin $pinName not found in current block diagram"
        continue
      }
      
      # Instantiate monitor
      set tmpName "xilmonitor_[string trimleft $pinName "/"]"
      set ipName [string map {"/" "_"} $tmpName]
      puts "INFO: adding $ipName for kernel debug monitoring..."
      set mon_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:sdx_aximm_wv $ipName]
      #set_property CONFIG.C_MON_FIFO_ENABLE 0 $mon_obj
      #set_property C_REG_ALL_MONITOR_SIGNALS 0 $mon_obj
      
      # Connect clock and reset
      #connect_bd_net -net $clk_obj [get_bd_pins $ipName/core_aclk]
      #connect_bd_net -net $rst_obj [get_bd_pins $ipName/core_aresetn]
      connect_bd_net -net $clk_obj [get_bd_pins $ipName/mon_axi_aclk]
      connect_bd_net -net $rst_obj [get_bd_pins $ipName/mon_axi_aresetn]
      
      # Connect AXI port
      connect_bd_intf_net [get_bd_intf_pins $ipName/mon_axi] [get_bd_intf_pins $pinName]
    }
  }; # end add_kernel_debug

  proc update_profiling_resources {ocl_content_dict kernels profiling} {
    set clk_obj [get_bd_net [dict get $ocl_content_dict clk_kernel_net]]
    set rst_obj [get_bd_net [dict get $ocl_content_dict rst_kernel_sync_net]]
    set intercon_obj [dict get $ocl_content_dict slave_interconnect]
    
    foreach profiling_inst $profiling {
      set name         [dict get $profiling_inst NAME]
      set baseAddress  [dict get $profiling_inst ADDR_OFFSET]
      set kernel_cells [dict get $profiling_inst SLOTS]
      set useCounters  [dict get $profiling_inst USE_COUNTERS]
      set useTrace     [dict get $profiling_inst USE_TRACE]
      set offloadType  [dict get $profiling_inst OFFLOAD_TYPE]
      set profileTypes [dict get $profiling_inst PROFILE_TYPES]
    
      set perfMonPorts [list]
      
      puts "Adding profiling $name - address: $baseAddress, counters: $useCounters, trace: $useTrace, offload: $offloadType, types: $profileTypes, kernels: $kernel_cells" 
      add_profiling $intercon_obj $clk_obj $rst_obj ${baseAddress} ${useCounters} ${useTrace} ${offloadType} ${profileTypes} ${perfMonPorts} $kernel_cells
    }
  }; # end update_profiling_resources
  
  ################################################################################
  # add_profiling
  #   Description:
  #     Insert device profiling monitor framework into OCL region
  #   Arguments:
  #     intercon_obj  interconnect cell to use
  #     clk_obj       clock object to use
  #     rst_obj       reset object to use
  #     baseAddress   base address used for APM
  #     useCounters   false: do not include counters, true: include APM counters
  #     useTrace      false: do not include trace,    true: include APM trace
  #     offloadType   false: AXI-Lite,                true: AXI-MM
  #     profileTypes  list of profile types corresponding to kernel_cells
  #                   1: kernel stalls, 2: pipes/streams, 3: external memory, 4: kernel starts/stops
  #     monNameList   list of AXI intf ports to monitor
  #     kernel_cells  list of kernel cells
  #
  ################################################################################
  proc add_profiling {intercon_obj clk_obj rst_obj baseAddress useCounters useTrace offloadType profileTypes monNameList kernel_cells} {
    # Constants
    set maxAXISlaves 16
    set maxAXIMasters 16
    set fifoDepth 4096
    # NOTE: this provides 64K range for APM and 4K range for stream FIFOs
    # This is a limitation on the APM core (see CR 871245)
    set apmRange      0x10000
    set fifoBaseAddress [expr $baseAddress - 0x3000]
    set fifoRange 0x1000
    set logIds 0
    set logLengths 1
    set protocol "AXI4"
    set protocol2 "AXI4S"
    # Internal blocking signals
    set startNameInt "stall_start_int"
    set doneNameInt "stall_done_int"
    # External stream port blocking signals
    set startNameStr "stall_start_str"
    set doneNameStr "stall_done_str"
    # External memory port blocking signals
    set startNameExt "stall_start_ext"
    set doneNameExt "stall_done_ext"
    # Kernel operation signals
    set startNameKernel "event_start"
    set doneNameKernel "event_done"
    set apmName "xilmonitor_apm"
    set jtagMasterName "xilmonitor_master"
    set broadcastName "xilmonitor_broadcast"
    set subsetNames [list xilmonitor_subset0 xilmonitor_subset1 xilmonitor_subset2 xilmonitor_subset3]
    set fifoNames [list xilmonitor_fifo0 xilmonitor_fifo1 xilmonitor_fifo2 xilmonitor_fifo3]
    set broadcastPortNames [list M00_AXIS M01_AXIS M02_AXIS M03_AXIS M04_AXIS M05_AXIS M06_AXIS M07_AXIS M08_AXIS M09_AXIS M10_AXIS M11_AXIS M12_AXIS M13_AXIS M14_AXIS M15_AXIS]
    set addrSegNames [list XIL_SEG_FIFO0 XIL_SEG_FIFO1 XIL_SEG_FIFO2 XIL_SEG_FIFO3 XIL_SEG_FIFO4 XIL_SEG_FIFO5 XIL_SEG_FIFO6 XIL_SEG_FIFO7]
    # AXI-MM ports
    set apmPorts [list SLOT_0_AXI SLOT_1_AXI SLOT_2_AXI SLOT_3_AXI SLOT_4_AXI SLOT_5_AXI SLOT_6_AXI SLOT_7_AXI]
    set apmPortClocks [list slot_0_axi_aclk slot_1_axi_aclk slot_2_axi_aclk slot_3_axi_aclk slot_4_axi_aclk slot_5_axi_aclk slot_6_axi_aclk slot_7_axi_aclk]
    set apmPortResets [list slot_0_axi_aresetn slot_1_axi_aresetn slot_2_axi_aresetn slot_3_axi_aresetn slot_4_axi_aresetn slot_5_axi_aresetn slot_6_axi_aresetn slot_7_axi_aresetn]
    # AXI-Stream ports
    set apmStreamPorts [list SLOT_0_AXIS SLOT_1_AXIS SLOT_2_AXIS SLOT_3_AXIS SLOT_4_AXIS SLOT_5_AXIS SLOT_6_AXIS SLOT_7_AXIS]
    set apmStreamPortClocks [list slot_0_axis_aclk slot_1_axis_aclk slot_2_axis_aclk slot_3_axis_aclk slot_4_axis_aclk slot_5_axis_aclk slot_6_axis_aclk slot_7_axis_aclk]
    set apmStreamPortResets [list slot_0_axis_aresetn slot_1_axis_aresetn slot_2_axis_aresetn slot_3_axis_aresetn slot_4_axis_aresetn slot_5_axis_aresetn slot_6_axis_aresetn slot_7_axis_aresetn]
    # Other ports
    set apmExtEventClocks [list ext_clk_0 ext_clk_1 ext_clk_2 ext_clk_3 ext_clk_4 ext_clk_5 ext_clk_6 ext_clk_7]
    set apmOtherClocks [list s_axi_aclk core_aclk]
    set apmExtEventResets [list ext_rstn_0 ext_rstn_1 ext_rstn_2 ext_rstn_3 ext_rstn_4 ext_rstn_5 ext_rstn_6 ext_rstn_7]
    set apmOtherResets [list s_axi_aresetn core_aresetn]
    set apmStartNames [list ext_event_0_cnt_start ext_event_1_cnt_start ext_event_2_cnt_start ext_event_3_cnt_start ext_event_4_cnt_start ext_event_5_cnt_start ext_event_6_cnt_start ext_event_7_cnt_start]
    set apmDoneNames [list ext_event_0_cnt_stop ext_event_1_cnt_stop ext_event_2_cnt_stop ext_event_3_cnt_stop ext_event_4_cnt_stop ext_event_5_cnt_stop ext_event_6_cnt_stop ext_event_7_cnt_stop]
    set interconSlaves [list S00_AXI S01_AXI S02_AXI S03_AXI S04_AXI S05_AXI S06_AXI S07_AXI S08_AXI S09_AXI S10_AXI S11_AXI S12_AXI S13_AXI S14_AXI S15_AXI]
    set interconMasters [list M00_AXI M01_AXI M02_AXI M03_AXI M04_AXI M05_AXI M06_AXI M07_AXI M08_AXI M09_AXI M10_AXI M11_AXI M12_AXI M13_AXI M14_AXI M15_AXI]
    set interconSlaveClocks [list S00_ACLK S01_ACLK S02_ACLK S03_ACLK S04_ACLK S05_ACLK S06_ACLK S07_ACLK S08_ACLK S09_ACLK S10_ACLK S11_ACLK S12_ACLK S13_ACLK S14_ACLK S15_ACLK]
    set interconSlaveResets [list S00_ARESETN S01_ARESETN S02_ARESETN S03_ARESETN S04_ARESETN S05_ARESETN S06_ARESETN S07_ARESETN S08_ARESETN S09_ARESETN S10_ARESETN S11_ARESETN S12_ARESETN S13_ARESETN S14_ARESETN S15_ARESETN]
    set interconMasterClocks [list M00_ACLK M01_ACLK M02_ACLK M03_ACLK M04_ACLK M05_ACLK M06_ACLK M07_ACLK M08_ACLK M09_ACLK M10_ACLK M11_ACLK M12_ACLK M13_ACLK M14_ACLK M15_ACLK]
    set interconMasterResets [list M00_ARESETN M01_ARESETN M02_ARESETN M03_ARESETN M04_ARESETN M05_ARESETN M06_ARESETN M07_ARESETN M08_ARESETN M09_ARESETN M10_ARESETN M11_ARESETN M12_ARESETN M13_ARESETN M14_ARESETN M15_ARESETN]
    set interconSlaveRegSlices [list S00_HAS_REGSLICE S01_HAS_REGSLICE S02_HAS_REGSLICE S03_HAS_REGSLICE S04_HAS_REGSLICE S05_HAS_REGSLICE S06_HAS_REGSLICE S07_HAS_REGSLICE S08_HAS_REGSLICE S09_HAS_REGSLICE S10_HAS_REGSLICE S11_HAS_REGSLICE S12_HAS_REGSLICE S13_HAS_REGSLICE S14_HAS_REGSLICE S15_HAS_REGSLICE]
    set interconMasterRegSlices [list M00_HAS_REGSLICE M01_HAS_REGSLICE M02_HAS_REGSLICE M03_HAS_REGSLICE M04_HAS_REGSLICE M05_HAS_REGSLICE M06_HAS_REGSLICE M07_HAS_REGSLICE M08_HAS_REGSLICE M09_HAS_REGSLICE M10_HAS_REGSLICE M11_HAS_REGSLICE M12_HAS_REGSLICE M13_HAS_REGSLICE M14_HAS_REGSLICE M15_HAS_REGSLICE]
    set broadcastRemap [list M00_TDATA_REMAP M01_TDATA_REMAP M02_TDATA_REMAP M03_TDATA_REMAP M04_TDATA_REMAP M05_TDATA_REMAP M06_TDATA_REMAP M07_TDATA_REMAP M08_TDATA_REMAP M09_TDATA_REMAP M10_TDATA_REMAP M11_TDATA_REMAP M12_TDATA_REMAP M13_TDATA_REMAP M14_TDATA_REMAP M15_TDATA_REMAP]
    set apmProtocols [list CONFIG.C_SLOT_0_AXI_PROTOCOL CONFIG.C_SLOT_1_AXI_PROTOCOL CONFIG.C_SLOT_2_AXI_PROTOCOL CONFIG.C_SLOT_3_AXI_PROTOCOL CONFIG.C_SLOT_4_AXI_PROTOCOL CONFIG.C_SLOT_5_AXI_PROTOCOL CONFIG.C_SLOT_6_AXI_PROTOCOL CONFIG.C_SLOT_7_AXI_PROTOCOL]
    
    #
    # Error Checking
    #
   
    # Ensure correct amount of monitor ports (max of 8 supported by single APM)
    set numMonPorts [llength $monNameList]
    if {$numMonPorts < 0 || $numMonPorts > 8} {
      puts "WARNING: number of ports must be between 0 and 8."
      return
    }
    if {$numMonPorts == 0} {
      set logIds 0
      set logLengths 0
    } else {
      # Ensure monitor names are valid nets
      foreach pinName $monNameList {
        if { [get_bd_intf_pins $pinName] eq "" } {
          puts "WARNING: the interface pin $pinName was not found in the current block diagram"
          return
        }
      }
    }
   
    if {[llength $kernel_cells] == 0} {
      puts "WARNING: no kernels found to monitor in add_profiling"
      return 
    }

    #
    # Initialization
    #
    puts "Adding performance monitoring framework..."

    set numKernels [llength $kernel_cells]
    put "numKernels = $numKernels, kernel_cells = $kernel_cells"
    if {$numKernels > $numMonPorts} {
      set numPorts $numKernels
    } else {
      set numPorts $numMonPorts
    }
    
    set currNumMasters [get_property CONFIG.NUM_MI $intercon_obj]
    set numMasters [expr {$currNumMasters + 1}];
    
    # Calculate trace bits and number of masters required 
    if {$useTrace} {
      set bitsPerSlot [expr 10 + (6 * 4 * $logIds) + (16 * $logLengths)]
      set traceBits [expr int(ceil((18 + ($bitsPerSlot * $numPorts)) / 8.0) * 8)]
      if {$traceBits < 56} {
        set traceBits 56 
      }
      
      # Limit bit width of corner case w/ 8 kernels to 3 FIFOs
      # NOTE: this ignores the upper two bits of the 98-bit trace word
      if {$numMonPorts == 0 && $numKernels == 8} {
        set traceBits 96
      }
        
      # NOTE: the number of bytes is always a multiple of 4 since the
      # broacaster zero pads to an integer number of 32-bit words
      set traceWords [expr int(ceil($traceBits/32.0))]
      set traceBytes [expr 4 * int($traceWords)]
      set traceBytesApm [expr int(ceil($traceBits/8.0))]
      incr numMasters $traceWords
    }
    
    # Make sure there's enough masters
    if {$numMasters > $maxAXIMasters} {
      puts "WARNING: cannot monitor kernel performance, there are not enough masters left on the AXI interconnect"
      return
    }
    
    set_property -dict [list CONFIG.NUM_MI $numMasters] $intercon_obj
    
    # Delete objects if they already exist (catch to ignore warnings) 
    if {[get_bd_cells $apmName -quiet] != {}} {delete_bd_objs [get_bd_cells $apmName]}
    if {[get_bd_cells $broadcastName -quiet] != {}} {delete_bd_objs [get_bd_cells $broadcastName]}
    if {[get_bd_cells $jtagMasterName -quiet] != {}} {delete_bd_objs [get_bd_cells $jtagMasterName]}
    
    for { set i 0 } { $i < [llength $fifoNames] } { incr i } {
      set subsetName [lindex $subsetNames $i]
      if {[get_bd_cells $subsetName -quiet] != {}} {delete_bd_objs [get_bd_cells $subsetName]}
      set fifoName [lindex $fifoNames $i]
      if {[get_bd_cells $fifoName -quiet] != {}} {delete_bd_objs [get_bd_cells $fifoName]}
    }
    
    puts "  APM monitored signals:"
    for { set i 0 } { $i < $numMonPorts } { incr i } {
      puts "    Port $i: [lindex $monNameList $i]"
    }
    
    #
    # Insert APM
    #
    puts "  Inserting AXI performance monitor: $apmName..."
    set apm_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_perf_mon $apmName]
    
    # Always use profile/trace configuration mode
    set_property CONFIG.C_NUM_MONITOR_SLOTS $numPorts $apm_obj
    set_property CONFIG.C_ENABLE_PROFILE $useCounters $apm_obj
    set_property CONFIG.C_ENABLE_TRACE [expr {$useTrace?1:0}] $apm_obj 
    if {$useCounters} {
      set_property CONFIG.C_HAVE_SAMPLED_METRIC_CNT 1 $apm_obj
    } 
    # Enable flags: write/read address, write/read last data, SW register write
    if {$useTrace} {
      set_property CONFIG.C_FIFO_AXIS_DEPTH 16 $apm_obj
      set_property CONFIG.C_EN_WR_ADD_FLAG 1 $apm_obj 
      set_property CONFIG.C_EN_FIRST_WRITE_FLAG 0 $apm_obj 
      set_property CONFIG.C_EN_LAST_WRITE_FLAG 1 $apm_obj 
      set_property CONFIG.C_EN_RESPONSE_FLAG 0 $apm_obj 
      set_property CONFIG.C_EN_RD_ADD_FLAG 1 $apm_obj 
      set_property CONFIG.C_EN_FIRST_READ_FLAG 0 $apm_obj 
      set_property CONFIG.C_EN_LAST_READ_FLAG 1 $apm_obj 
      set_property CONFIG.C_EN_SW_REG_WR_FLAG 1 $apm_obj 
      set_property CONFIG.C_EN_EXT_EVENTS_FLAG 1 $apm_obj 
      set_property CONFIG.C_SHOW_AXI_IDS $logIds $apm_obj
      set_property CONFIG.C_SHOW_AXI_LEN $logLengths $apm_obj
    }
    
    for { set i 0 } { $i < $numPorts } { incr i } {
      set_property -dict [list [lindex $apmProtocols $i] $protocol] $apm_obj
    }
   
    # Connect all clock and reset pins on APM
    for { set i 0 } { $i < [llength $apmOtherClocks] } { incr i } {
      connect_bd_net -net $clk_obj [get_bd_pins $apmName/[lindex $apmOtherClocks $i]]
      connect_bd_net -net $rst_obj [get_bd_pins $apmName/[lindex $apmOtherResets $i]]
    }
    
    if {$useTrace} {
      connect_bd_net -net $clk_obj [get_bd_pins $apmName/m_axis_aclk]
      connect_bd_net -net $rst_obj [get_bd_pins $apmName/m_axis_aresetn]
    }
    
    for { set i 0 } { $i < $numPorts } { incr i } {
      connect_bd_net -net $clk_obj [get_bd_pins $apmName/[lindex $apmPortClocks $i]]
      connect_bd_net -net $rst_obj [get_bd_pins $apmName/[lindex $apmPortResets $i]]
    }
    
    # Add trace infrastructure
    if {$useTrace} {
      if {!$offloadType} {
        #
        # Insert AXI broadcaster
        #
        puts "  Inserting AXI broadcaster: $broadcastName..."
        set broadcast_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster $broadcastName]
        
        set_property -dict [list CONFIG.NUM_MI [expr int($traceWords)]] $broadcast_obj
        set_property -dict [list CONFIG.S_TDATA_NUM_BYTES.VALUE_SRC USER] $broadcast_obj
        set_property -dict [list CONFIG.S_TDATA_NUM_BYTES $traceBytesApm] $broadcast_obj
        set_property -dict [list CONFIG.M_TDATA_NUM_BYTES.VALUE_SRC USER] $broadcast_obj
        set_property -dict [list CONFIG.M_TDATA_NUM_BYTES $traceBytes] $broadcast_obj
      
        set zeroPadBits [expr int(32*$traceWords - $traceBits)]
        set zeroPadStr "$zeroPadBits'b"
        for { set i 0 } { $i < $zeroPadBits } { incr i } {
          append zeroPadStr "0"
        }
        #zero pad bits of the apm fifo
        for { set i 0 } { $i < $traceWords } { incr i } {
          set remapParam [lindex $broadcastRemap $i]
          if {$zeroPadBits > 0} {
            set remapValue "$zeroPadStr,tdata[[expr $traceBits-1]:0]"
          } else {
            set remapValue "tdata[[expr $traceBits-1]:0]" 
          }
          set_property -dict [list CONFIG.$remapParam $remapValue] $broadcast_obj
        }
        
        connect_bd_net -net $clk_obj [get_bd_pins -of_objects $broadcast_obj -filter {DIR == I && TYPE == clk}]
        connect_bd_net -net $rst_obj [get_bd_pins -of_objects $broadcast_obj -filter {DIR == I && TYPE == rst}]
          
        #
        # Insert subset converters
        #
        puts "  Inserting $traceWords AXI subset converters..."
        for { set i 0 } { $i < $traceWords } { incr i } {
          set subsetName [lindex $subsetNames $i] 
          set subset_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter $subsetName]
      
          set_property -dict [list CONFIG.S_TDATA_NUM_BYTES.VALUE_SRC USER CONFIG.M_TDATA_NUM_BYTES.VALUE_SRC USER] $subset_obj
          set_property -dict [list CONFIG.S_TDATA_NUM_BYTES [expr 4*int($traceWords)]] $subset_obj
          set_property -dict [list CONFIG.M_TDATA_NUM_BYTES {4}] $subset_obj
          set_property -dict [list CONFIG.TDATA_REMAP tdata[[expr ($i+1)*32-1]:[expr $i*32]]] $subset_obj
          
          set subsetClkPins [get_bd_pins -of_objects $subset_obj -filter {DIR == I && TYPE == clk}]
          connect_bd_net -net $clk_obj $subsetClkPins
          set subsetRstPins [get_bd_pins -of_objects $subset_obj -filter {DIR == I && TYPE == rst}]
          connect_bd_net -net $rst_obj $subsetRstPins
        }
        
        #
        # Insert AXI FIFOs
        #
        puts "  Inserting $traceWords AXI FIFOs..."
        for { set i 0 } { $i < $traceWords } { incr i } {
          set fifoName [lindex $fifoNames $i] 
          set fifo_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s $fifoName]
          
          set_property CONFIG.C_DATA_INTERFACE_TYPE 0 $fifo_obj
          set_property CONFIG.C_RX_FIFO_DEPTH $fifoDepth $fifo_obj
          #set_property CONFIG.C_S_AXI4_DATA_WIDTH 32 $fifo_obj
          set_property CONFIG.C_USE_RX_CUT_THROUGH true $fifo_obj
          set_property CONFIG.C_USE_TX_DATA 0 $fifo_obj
          
          set fifoClkPins [get_bd_pins -of_objects $fifo_obj -filter {DIR == I && TYPE == clk}]
          connect_bd_net -net $clk_obj $fifoClkPins
          set fifoRstPins [get_bd_pins -of_objects $fifo_obj -filter {DIR == I && TYPE == rst}]
          connect_bd_net -net $rst_obj $fifoRstPins
        }
      } else {
         #
         # Insert AXI FIFO
         #
         puts "  Inserting AXI Stream FIFO..."
         set fifoName [lindex $fifoNames 0] 
         set fifo_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s $fifoName]
          
         set_property CONFIG.C_DATA_INTERFACE_TYPE 1 $fifo_obj
         set_property CONFIG.C_S_AXI4_DATA_WIDTH 512 $fifo_obj
         set_property CONFIG.C_RX_FIFO_DEPTH $fifoDepth $fifo_obj
         set_property CONFIG.C_RX_FIFO_PF_THRESHOLD [expr $fifoDepth - 5] $fifo_obj
         set_property CONFIG.C_USE_RX_CUT_THROUGH true $fifo_obj
         set_property CONFIG.C_USE_TX_DATA 0 $fifo_obj
        
         set fifoClkPins [get_bd_pins -of_objects $fifo_obj -filter {DIR == I && TYPE == clk}]
         connect_bd_net -net $clk_obj $fifoClkPins
         set fifoRstPins [get_bd_pins -of_objects $fifo_obj -filter {DIR == I && TYPE == rst}]
         connect_bd_net -net $rst_obj $fifoRstPins
      }
      
      #
      # Connect kernel start/stop 
      #
      set ii 0
      foreach kernel_cell $kernel_cells {
        if { $ii >= $numPorts } {
          break
        }

        # Get pin names of what we want to monitor
        # profileType  1: kernel stalls, 2: pipes/streams, 3: external memory, 4: kernel starts/stops
        set profileType [lindex $profileTypes $ii]
        if {$profileType == 1} {
          set startPin [get_bd_pins -quiet $kernel_cell/$startNameInt]
          set donePin [get_bd_pins -quiet $kernel_cell/$doneNameInt]
        } elseif {$profileType == 2} {
          set startPin [get_bd_pins -quiet $kernel_cell/$startNameStr]
          set donePin [get_bd_pins -quiet $kernel_cell/$doneNameStr]
        } elseif {$profileType == 3} {
          set startPin [get_bd_pins -quiet $kernel_cell/$startNameExt]
          set donePin [get_bd_pins -quiet $kernel_cell/$doneNameExt]
        } elseif {$profileType == 4} {
          set startPin [get_bd_pins -quiet $kernel_cell/$startNameKernel]
          set donePin [get_bd_pins -quiet $kernel_cell/$doneNameKernel]
        } else {
          set startPin ""
          set donePin ""
        }
        
        if {$startPin ne "" && $donePin ne ""} {
          puts "  Monitoring start/done on kernel $kernel_cell... "
          connect_bd_net $startPin [get_bd_pins $apm_obj/[lindex $apmStartNames $ii]]
          connect_bd_net $donePin [get_bd_pins $apm_obj/[lindex $apmDoneNames $ii]]
        }
        
        incr ii
      }
    }
    
    # Connect external event clocks/resets
    for { set i 0 } { $i < $numPorts } { incr i } {
      connect_bd_net -net $clk_obj [get_bd_pins $apmName/[lindex $apmExtEventClocks $i]]
      connect_bd_net -net $rst_obj [get_bd_pins $apmName/[lindex $apmExtEventResets $i]]
    }
    
    #
    # Make Connections
    #
    puts "  Connecting all blocks... "
    
    # Monitor ports on APM
    for { set i 0 } { $i < $numMonPorts } { incr i } {
      connect_bd_intf_net [get_bd_intf_pins $apmName/[lindex $apmPorts $i]] [get_bd_intf_pins [lindex $monNameList $i]]
    }
    
    if {$useTrace} {
      if {!$offloadType} {
        # AXI-Stream from the APM to the broadcaster
        connect_bd_intf_net [get_bd_intf_pins $apmName/M_AXIS] [get_bd_intf_pins $broadcastName/S_AXIS]
      
        # AXI-Stream from the broadcaster to the subset converters and then to FIFOs
        for { set i 0 } { $i < $traceWords } { incr i } {
          set portName [lindex $broadcastPortNames $i]
          set subsetName [lindex $subsetNames $i]
          connect_bd_intf_net [get_bd_intf_pins $broadcastName/$portName] [get_bd_intf_pins $subsetName/S_AXIS]
          
          set fifoName [lindex $fifoNames $i]
          connect_bd_intf_net [get_bd_intf_pins $subsetName/M_AXIS] [get_bd_intf_pins $fifoName/AXI_STR_RXD]
        }
      } else {
        # AXI-Stream from the APM to the FIFO
        set fifoName [lindex $fifoNames 0]
        connect_bd_intf_net [get_bd_intf_pins $apmName/M_AXIS] [get_bd_intf_pins $fifoName/AXI_STR_RXD]
        
        #
        # TODO: Connect AXI-MM on FIFO!!
        #
        #connect_bd_intf_net ??? [get_bd_intf_pins $fifoName/S_AXI_FULL]
        #create_bd_addr_seg -offset ??? -range ??? ??? [get_bd_addr_segs $fifoName/S_AXI_FULL/Mem0] ???
      }
    }
    
    # Interconnect master to APM
    set interconIndex [expr $numMasters-1]
    set axiMasterName [lindex $interconMasters $interconIndex]
    set axiClkName [lindex $interconMasterClocks $interconIndex]
    set axiResetName [lindex $interconMasterResets $interconIndex]
    set axiMasterRegSlice [lindex $interconMasterRegSlices $interconIndex]
    connect_bd_intf_net [get_bd_intf_pins $intercon_obj/$axiMasterName] [get_bd_intf_pins $apmName/s_axi]
    set interconProps [list CONFIG.NUM_MI $numMasters CONFIG.$axiMasterRegSlice {1}]
    
    # Connect clock and reset nets
    # NOTE: for SmartConnect, these pins don't exist
    if {[get_bd_pins $intercon_obj/$axiClkName -quiet] != {}} {
      connect_bd_net -net $clk_obj [get_bd_pins $intercon_obj/$axiClkName]
    }
    if {[get_bd_pins $intercon_obj/$axiResetName -quiet] != {}} {
      connect_bd_net -net $rst_obj [get_bd_pins $intercon_obj/$axiResetName]
    }
    
    # Assign address
    set ctrlAddrSpace [get_bd_addr_spaces -of_objects [get_bd_intf_pins $intercon_obj/S00_AXI]]
    create_bd_addr_seg -offset $baseAddress -range $apmRange $ctrlAddrSpace [get_bd_addr_segs $apmName/S_AXI/Reg] XIL_SEG_APM
    
    # Interconnect masters to AXI FIFOs
    if {$useTrace} {
      for { set i 0 } { $i < $traceWords } { incr i } {
        set fifoName [lindex $fifoNames $i]
        set interconIndex [expr $numMasters-2-$i]
        set axiMasterName [lindex $interconMasters $interconIndex]
        set axiClkName [lindex $interconMasterClocks $interconIndex]
        set axiResetName [lindex $interconMasterResets $interconIndex]
        set axiMasterRegSlice [lindex $interconMasterRegSlices $interconIndex]
        lappend interconProps CONFIG.$axiMasterRegSlice {1}
        connect_bd_intf_net [get_bd_intf_pins $intercon_obj/$axiMasterName] [get_bd_intf_pins $fifoName/S_AXI]
        
        # Connect clock and reset nets
        # NOTE: for SmartConnect, these pins don't exist
        if {[get_bd_pins $intercon_obj/$axiClkName -quiet] != {}} {
          connect_bd_net -net $clk_obj [get_bd_pins $intercon_obj/$axiClkName]
        }
        if {[get_bd_pins $intercon_obj/$axiResetName -quiet] != {}} {
          connect_bd_net -net $rst_obj [get_bd_pins $intercon_obj/$axiResetName]
        }
        
        # Assign address
        set fifoAddress [expr $fifoBaseAddress + ($i * $fifoRange)]
        set segName [lindex $addrSegNames $i]
        create_bd_addr_seg -offset $fifoAddress -range $fifoRange $ctrlAddrSpace [get_bd_addr_segs $fifoName/S_AXI/Mem0] $segName
      }
    }
    set_property -dict $interconProps $intercon_obj
     
    puts "  Completed marking for performance"
  }; # end add_profiling
  
  ################################################################################
  # add_profiling_new
  #   Description:
  #     Insert device profiling into IPI diagram
  #     NOTE: this uses the next generation monitor IP (i.e., SDx 2017.1)
  #   Arguments:
  #     master_obj   AXI master for SW timestamps, etc.
  #     clk_obj      clock net 
  #     rst_obj      reset net (for peripherals)
  #     rst_obj2     reset net (for interconnect)
  #     baseAddress  base address for AXI Lite slaves on monitor cores
  #     useCounters  false: do not include counters, true: include counters
  #     useTrace     false: do not include trace,    true: include trace
  #     monNameList  list of AXI interface ports to monitor
  #
  ################################################################################
  proc add_profiling_new {master_obj clk_obj rst_obj rst_obj2 baseAddress useCounters useTrace monNameList} {
    # Constants
    set maxAXISlaves 64
    set maxAXIMasters 64
    set monFifoDepth 1024
    set fifoDepth 4096
    set monRange 0x1000
    set monBaseAddress [expr $baseAddress + $monRange]
    set monName "xilmon_mon"
    set funnelName "xilmon_tm"
    set broadcastName "xilmon_broadcast"
    set fifo0Name "xilmon_fifo0"
    set fifo1Name "xilmon_fifo1"
    #set convName "xilmon_conv"
    #set regName "xilmon_reg"
    set mdmName "xilmon_mdm"
    set interconName "xilmon_intercon"
    # Other ports
    set monClocks [list core_clk m_axi_clk s_axi_clk]
    set monResets [list core_resetn m_axi_resetn s_axi_resetn]
    set funnelClocks [list trace_clk axi_lite_clk]
    set funnelResets [list trace_resetn axi_lite_resetn]
    set addrSegNames [list XIL_SEG_MON0 XIL_SEG_MON1 XIL_SEG_MON2 XIL_SEG_MON3 XIL_SEG_MON4 XIL_SEG_MON5 XIL_SEG_MON6 XIL_SEG_MON7]
    set interconSlaves [list S00_AXI S01_AXI S02_AXI S03_AXI S04_AXI S05_AXI S06_AXI S07_AXI S08_AXI S09_AXI S10_AXI S11_AXI S12_AXI S13_AXI S14_AXI S15_AXI]
    set interconMasters [list M00_AXI M01_AXI M02_AXI M03_AXI M04_AXI M05_AXI M06_AXI M07_AXI M08_AXI M09_AXI M10_AXI M11_AXI M12_AXI M13_AXI M14_AXI M15_AXI]
    set interconSlaveClocks [list S00_ACLK S01_ACLK S02_ACLK S03_ACLK S04_ACLK S05_ACLK S06_ACLK S07_ACLK S08_ACLK S09_ACLK S10_ACLK S11_ACLK S12_ACLK S13_ACLK S14_ACLK S15_ACLK]
    set interconSlaveResets [list S00_ARESETN S01_ARESETN S02_ARESETN S03_ARESETN S04_ARESETN S05_ARESETN S06_ARESETN S07_ARESETN S08_ARESETN S09_ARESETN S10_ARESETN S11_ARESETN S12_ARESETN S13_ARESETN S14_ARESETN S15_ARESETN]
    set interconMasterClocks [list M00_ACLK M01_ACLK M02_ACLK M03_ACLK M04_ACLK M05_ACLK M06_ACLK M07_ACLK M08_ACLK M09_ACLK M10_ACLK M11_ACLK M12_ACLK M13_ACLK M14_ACLK M15_ACLK]
    set interconMasterResets [list M00_ARESETN M01_ARESETN M02_ARESETN M03_ARESETN M04_ARESETN M05_ARESETN M06_ARESETN M07_ARESETN M08_ARESETN M09_ARESETN M10_ARESETN M11_ARESETN M12_ARESETN M13_ARESETN M14_ARESETN M15_ARESETN]
    set interconSlaveRegSlices [list S00_HAS_REGSLICE S01_HAS_REGSLICE S02_HAS_REGSLICE S03_HAS_REGSLICE S04_HAS_REGSLICE S05_HAS_REGSLICE S06_HAS_REGSLICE S07_HAS_REGSLICE S08_HAS_REGSLICE S09_HAS_REGSLICE S10_HAS_REGSLICE S11_HAS_REGSLICE S12_HAS_REGSLICE S13_HAS_REGSLICE S14_HAS_REGSLICE S15_HAS_REGSLICE]
    set interconMasterRegSlices [list M00_HAS_REGSLICE M01_HAS_REGSLICE M02_HAS_REGSLICE M03_HAS_REGSLICE M04_HAS_REGSLICE M05_HAS_REGSLICE M06_HAS_REGSLICE M07_HAS_REGSLICE M08_HAS_REGSLICE M09_HAS_REGSLICE M10_HAS_REGSLICE M11_HAS_REGSLICE M12_HAS_REGSLICE M13_HAS_REGSLICE M14_HAS_REGSLICE M15_HAS_REGSLICE]

    #
    # Error Checking
    #
   
    # Ensure correct number of monitor ports
    set numPorts [llength $monNameList]
    if {$numPorts <= 0 || $numPorts > 63} {
      puts "WARNING: number of ports must be between 1 and 63."
      return
    }

    #
    # Initialization
    #
    puts "Adding performance monitoring..."
    
    # Calculate number of bits in trace output
    set traceBits 64
    
    # NOTE: the number of bytes is always a multiple of 4 since the
    # broacaster zero pads to an integer number of 32-bit words
    set traceWords [expr int(ceil($traceBits/32.0))]
    set traceBytes [expr 4 * int($traceWords)]
    set traceBytesMon [expr int(ceil($traceBits/8.0))]
    
    # 
    # Insert cores
    #
    
    # AXI-MM monitors
    puts "  Inserting AXI-MM monitors: $monName..."
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      #set mon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:Trace_Monitor_AXI_Master $currMonName]
      set mon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:SDx_Monitor_AXI_Master $currMonName]
      set_property CONFIG.C_TRACE_READ_ID [expr 2*$i] $mon_obj
      set_property CONFIG.C_TRACE_WRITE_ID [expr 2*$i+1] $mon_obj
      
      # Settings for SDSoC IP
      #set_property CONFIG.CAPTURE_BURSTS 1 $mon_obj
      # Settings for next-gen IP
      set_property CONFIG.C_ENABLE_COUNTERS [expr {$useCounters?1:0}] $mon_obj
      set_property CONFIG.C_ENABLE_TRACE [expr {$useTrace?1:0}] $mon_obj
      set_property CONFIG.C_WRITE_START_SELECT "First Data" $mon_obj
      set_property CONFIG.C_WRITE_STOP_SELECT "Last Data" $mon_obj
      set_property CONFIG.C_READ_START_SELECT "First Data" $mon_obj
      set_property CONFIG.C_READ_STOP_SELECT "Last Data" $mon_obj
      set_property CONFIG.C_TRACE_FIFO_DEPTH $monFifoDepth $mon_obj
      set_property CONFIG.C_MON_AXI_ID_WIDTH 5 $mon_obj
      set_property CONFIG.C_MON_FIFO_ENABLE 1 $mon_obj
      set_property CONFIG.C_REG_ALL_MONITOR_SIGNALS 1 $mon_obj
      set_property CONFIG.C_NUM_REG_STAGES 3 $mon_obj
    } 
    
    # Trace funnel
    puts "  Inserting trace funnel: $funnelName..."
    #set funnel_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:Trace_Monitor $funnelName]
    set funnel_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:SDx_Trace_Monitor $funnelName]
    set_property CONFIG.NUM_TRACE_PORTS [expr 2*$numPorts] $funnel_obj
   
    # AXI Stream broadcaster
    puts "  Inserting AXI Stream broadcaster: $broadcastName..."
    set broadcast_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster $broadcastName]
    set_property CONFIG.NUM_MI 2 $broadcast_obj
    set_property -dict [list CONFIG.S_TDATA_NUM_BYTES.VALUE_SRC USER CONFIG.M_TDATA_NUM_BYTES.VALUE_SRC USER] $broadcast_obj
    set_property CONFIG.S_TDATA_NUM_BYTES 8 $broadcast_obj
    set_property CONFIG.M_TDATA_NUM_BYTES 4 $broadcast_obj
    set_property CONFIG.M00_TDATA_REMAP {tdata[31:0]} $broadcast_obj
    set_property CONFIG.M01_TDATA_REMAP {tdata[63:32]} $broadcast_obj
    
    # AXI Stream FIFOs
    puts "  Inserting AXI Stream FIFOs..."
    set fifo0_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s $fifo0Name]
    set_property CONFIG.C_DATA_INTERFACE_TYPE 0 $fifo0_obj
    set_property CONFIG.C_RX_FIFO_DEPTH $fifoDepth $fifo0_obj
    set_property CONFIG.C_RX_FIFO_PF_THRESHOLD [expr $fifoDepth - 5] $fifo0_obj
    set_property CONFIG.C_USE_RX_CUT_THROUGH true $fifo0_obj
    set_property CONFIG.C_USE_TX_DATA 0 $fifo0_obj
        
    set fifo1_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s $fifo1Name]
    set_property CONFIG.C_DATA_INTERFACE_TYPE 0 $fifo1_obj
    set_property CONFIG.C_RX_FIFO_DEPTH $fifoDepth $fifo1_obj
    set_property CONFIG.C_RX_FIFO_PF_THRESHOLD [expr $fifoDepth - 5] $fifo1_obj
    set_property CONFIG.C_USE_RX_CUT_THROUGH true $fifo1_obj
    set_property CONFIG.C_USE_TX_DATA 0 $fifo1_obj
    
    # AXI stream data FIFO
    #puts "  Inserting AXI Stream data FIFO: $fifoName..."
    #set fifo_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo $fifoName]
    #set_property CONFIG.FIFO_DEPTH $fifoDepth $fifo_obj
   
    # AXI stream data width converter
    #puts "  Inserting AXI Stream data width converter: $convName..."
    #set conv_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter $convName]
    #set_property CONFIG.M_TDATA_NUM_BYTES 4 $conv_obj
    
    # AXI FIFO register
    #puts "  Inserting AXI FIFO register: $regName..."
    #set reg_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:sdx_fifo_register $regName]
    #set_property CONFIG.ENABLE_INPUT true $reg_obj

    # MicroBlaze debug module
    puts "  Inserting MicroBlaze debug module: $mdmName..."
    set mdm_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:mdm $mdmName]
    set_property CONFIG.C_MB_DBG_PORTS 0 $mdm_obj
    set_property CONFIG.C_DBG_REG_ACCESS 0 $mdm_obj
    set_property CONFIG.C_DBG_MEM_ACCESS 1 $mdm_obj
    set_property CONFIG.C_TRACE_OUTPUT 0 $mdm_obj
    set_property CONFIG.C_S_AXI_ADDR_WIDTH 4 $mdm_obj
       
    # AXI interconnect
    puts "  Inserting AXI interconnect: $interconName..."
    set numSlaves 2
    set numMasters [expr $numPorts + 3]
    set intercon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect $interconName]
    set_property CONFIG.NUM_SI $numSlaves $intercon_obj
    set_property CONFIG.NUM_MI $numMasters $intercon_obj
    
    for { set i 0 } { $i < $numSlaves } { incr i } {
      set axiSlaveRegSlice [lindex $interconSlaveRegSlices $i]
      set_property CONFIG.$axiSlaveRegSlice 1 $intercon_obj
    }
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiMasterRegSlice [lindex $interconMasterRegSlices $i]
      set_property CONFIG.$axiMasterRegSlice 1 $intercon_obj
    }
    
    #
    # Connect clocks & resets
    #
    
    # Clocks
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      for { set j 0 } { $j < [llength $monClocks] } { incr j } {
        #puts "Connecting $currMonName/[lindex $monClocks $j] to $clk_obj..."
        connect_bd_net -net $clk_obj [get_bd_pins $currMonName/[lindex $monClocks $j]]
      }
    }
    
    for { set i 0 } { $i < [llength $funnelClocks] } { incr i } {
      connect_bd_net -net $clk_obj [get_bd_pins $funnelName/[lindex $funnelClocks $i]]
    }
    
    #connect_bd_net -net $clk_obj [get_bd_pins $convName/aclk]
    #connect_bd_net -net $clk_obj [get_bd_pins $regName/AXI_ACLK]
    connect_bd_net -net $clk_obj [get_bd_pins $mdmName/M_AXI_ACLK]
    connect_bd_net -net $clk_obj [get_bd_pins $broadcastName/aclk]
    set fifo0ClkPins [get_bd_pins -of_objects $fifo0_obj -filter {DIR == I && TYPE == clk}]
    connect_bd_net -net $clk_obj $fifo0ClkPins
    set fifo1ClkPins [get_bd_pins -of_objects $fifo1_obj -filter {DIR == I && TYPE == clk}]
    connect_bd_net -net $clk_obj $fifo1ClkPins
    
    # Interconnect clocks
    # NOTE: for SmartConnect, these pins don't exist
    for { set i 0 } { $i < $numSlaves } { incr i } {
      set axiClkName [lindex $interconSlaveClocks $i]
      if {[get_bd_pins $intercon_obj/$axiClkName -quiet] != {}} {
        connect_bd_net -net $clk_obj [get_bd_pins $intercon_obj/$axiClkName]
      }
    }
    
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiClkName [lindex $interconMasterClocks $i]
      if {[get_bd_pins $intercon_obj/$axiClkName -quiet] != {}} {
        connect_bd_net -net $clk_obj [get_bd_pins $intercon_obj/$axiClkName]
      }
    }
    
    connect_bd_net -net $clk_obj [get_bd_pins $intercon_obj/ACLK]
    
    # Resets
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      for { set j 0 } { $j < [llength $monResets] } { incr j } {
        connect_bd_net -net $rst_obj [get_bd_pins $currMonName/[lindex $monResets $j]]
      }
    }
    
    for { set i 0 } { $i < [llength $funnelResets] } { incr i } {
      connect_bd_net -net $rst_obj [get_bd_pins $funnelName/[lindex $funnelResets $i]]
    }
    
    #connect_bd_net -net $rst_obj [get_bd_pins $convName/aresetn]
    #connect_bd_net -net $rst_obj [get_bd_pins $regName/AXI_ARESETN]
    connect_bd_net -net $rst_obj [get_bd_pins $mdmName/M_AXI_ARESETN]
    connect_bd_net -net $rst_obj [get_bd_pins $broadcastName/aresetn]
    set fifo0RstPins [get_bd_pins -of_objects $fifo0_obj -filter {DIR == I && TYPE == rst}]
    connect_bd_net -net $rst_obj $fifo0RstPins
    set fifo1RstPins [get_bd_pins -of_objects $fifo1_obj -filter {DIR == I && TYPE == rst}]
    connect_bd_net -net $rst_obj $fifo1RstPins
    
    # Interconnect resets
    # NOTE: for SmartConnect, these pins don't exist
    for { set i 0 } { $i < $numSlaves } { incr i } {
      set axiResetName [lindex $interconSlaveResets $i]
      if {[get_bd_pins $intercon_obj/$axiResetName -quiet] != {}} {
        connect_bd_net -net $rst_obj [get_bd_pins $intercon_obj/$axiResetName]
      }
    }
    
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiResetName [lindex $interconMasterResets $i]
      if {[get_bd_pins $intercon_obj/$axiResetName -quiet] != {}} {
        connect_bd_net -net $rst_obj [get_bd_pins $intercon_obj/$axiResetName]
      }
    }
    
    connect_bd_net -net $rst_obj2 [get_bd_pins $intercon_obj/ARESETN]
    
    #
    # Make Connections
    #
    puts "  Connecting all blocks... "
    
    # Monitor ports
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      connect_bd_intf_net [get_bd_intf_pins $currMonName/MON_M_AXI] [get_bd_intf_pins [lindex $monNameList $i]]
      
      set tracePort0 TRACE_[expr 2*$i]
      set tracePort1 TRACE_[expr 2*$i+1]
      connect_bd_intf_net [get_bd_intf_pins $currMonName/TRACE_OUT_0] [get_bd_intf_pins $funnelName/$tracePort0]
      connect_bd_intf_net [get_bd_intf_pins $currMonName/TRACE_OUT_1] [get_bd_intf_pins $funnelName/$tracePort1]
    }
    
    #connect_bd_intf_net [get_bd_intf_pins $funnelName/M_AXIS] [get_bd_intf_pins $fifoName/S_AXIS]
    #connect_bd_intf_net [get_bd_intf_pins $fifoName/M_AXIS] [get_bd_intf_pins $convName/S_AXIS]
    #connect_bd_net [get_bd_pins $fifoName/axis_data_count] [get_bd_pins $regName/S_AXIS_count]
    #connect_bd_intf_net [get_bd_intf_pins $convName/M_AXIS] [get_bd_intf_pins $regName/S_AXIS]
    connect_bd_intf_net [get_bd_intf_pins $funnelName/M_AXIS] [get_bd_intf_pins $broadcastName/S_AXIS]
    
    connect_bd_intf_net [get_bd_intf_pins $broadcastName/M00_AXIS] [get_bd_intf_pins $fifo0Name/AXI_STR_RXD]
    connect_bd_intf_net [get_bd_intf_pins $broadcastName/M01_AXIS] [get_bd_intf_pins $fifo1Name/AXI_STR_RXD]
    
    # Interconnect slaves
    connect_bd_intf_net $master_obj [get_bd_intf_pins $interconName/S00_AXI]
    connect_bd_intf_net [get_bd_intf_pins $mdmName/M_AXI] [get_bd_intf_pins $interconName/S01_AXI]
    
    # Interconnect masters
    #connect_bd_intf_net [get_bd_intf_pins $interconName/M00_AXI] [get_bd_intf_pins $regName/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins $interconName/M00_AXI] [get_bd_intf_pins $fifo0Name/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins $interconName/M01_AXI] [get_bd_intf_pins $fifo1Name/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins $interconName/M02_AXI] [get_bd_intf_pins $funnelName/S_AXI]
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      set axiMasterName [lindex $interconMasters [expr $i+3]]
      connect_bd_intf_net [get_bd_intf_pins $interconName/$axiMasterName] [get_bd_intf_pins $currMonName/S_AXI]
    }
    
    # Assign addresses
    set ctrlAddrSpace0 [get_bd_addr_spaces -of_objects [get_bd_intf_pins $intercon_obj/S00_AXI]]
    set ctrlAddrSpace1 [get_bd_addr_spaces -of_objects [get_bd_intf_pins $intercon_obj/S01_AXI]]
    #create_bd_addr_seg -offset $baseAddress -range $monRange $ctrlAddrSpace0 [get_bd_addr_segs $regName/S_AXI/Reg] XIL_SEG0_REG
    #create_bd_addr_seg -offset $baseAddress -range $monRange $ctrlAddrSpace1 [get_bd_addr_segs $regName/S_AXI/Reg] XIL_SEG1_REG
    create_bd_addr_seg -offset $baseAddress -range $monRange $ctrlAddrSpace0 [get_bd_addr_segs $fifo0Name/S_AXI/Mem0] XIL_SEG0_FIFO0
    create_bd_addr_seg -offset $baseAddress -range $monRange $ctrlAddrSpace1 [get_bd_addr_segs $fifo0Name/S_AXI/Mem0] XIL_SEG1_FIFO0
    create_bd_addr_seg -offset [expr $baseAddress + $monRange] -range $monRange $ctrlAddrSpace0 [get_bd_addr_segs $fifo1Name/S_AXI/Mem0] XIL_SEG0_FIFO1
    create_bd_addr_seg -offset [expr $baseAddress + $monRange] -range $monRange $ctrlAddrSpace1 [get_bd_addr_segs $fifo1Name/S_AXI/Mem0] XIL_SEG1_FIFO1
    create_bd_addr_seg -offset [expr $baseAddress + 2*$monRange] -range $monRange $ctrlAddrSpace0 [get_bd_addr_segs $funnelName/S_AXI/Reg] XIL_SEG0_FUNNEL
    create_bd_addr_seg -offset [expr $baseAddress + 2*$monRange] -range $monRange $ctrlAddrSpace1 [get_bd_addr_segs $funnelName/S_AXI/Reg] XIL_SEG1_FUNNEL
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      set currSeg0Name XIL_SEG0_MON$i
      set currSeg1Name XIL_SEG1_MON$i
      set currAddress [expr $baseAddress + ($i+3)*$monRange]
      create_bd_addr_seg -offset $currAddress -range $monRange $ctrlAddrSpace0 [get_bd_addr_segs $currMonName/S_AXI/S_AXI] $currSeg0Name
      create_bd_addr_seg -offset $currAddress -range $monRange $ctrlAddrSpace1 [get_bd_addr_segs $currMonName/S_AXI/S_AXI] $currSeg1Name
    }
    
    puts "  Completed adding profiling (NEW)"
  }; # end add_profiling_new
  
  proc update_addr_seg_info {port_dict} {
    # Set ADDR_OFFSET and ADDR_RANGE if missing based off ADDR_SEGS info
    #puts "DBG: addr_seg info: $port_dict"
    if { ![dict exists $port_dict ADDR_SEGS] } {
      return $port_dict
    }
    set segs [dict get $port_dict ADDR_SEGS]
    set num_segs [llength $segs]
    set offset 0x0
    set range 0x0
    if { $num_segs == 1 } {
      set seg_dict [lindex $segs 0]
      set offset [dict get $seg_dict OFFSET]
      set range [dict get $seg_dict RANGE]
      #puts "DBG: updated addr_seg info (1) offset=$offset range=$range"
    } elseif { $num_segs > 1 } {
      set bn_offset [hex2bignum $offset]
      set bn_range [hex2bignum $range]
      set seg_name_dict [dict create]
      foreach seg_dict $segs {
        set seg_name [dict get $seg_dict NAME]
        set bn_curr_offset [hex2bignum [dict get $seg_dict OFFSET]]
        set bn_curr_range  [hex2bignum [dict get $seg_dict RANGE]]
        if { 0 } {
          if { [dict exists $seg_name_dict $seg_name] } {
            set bn_prev_offset [dict get $seg_name_dict $seg_name OFFSET]
            set bn_prev_range  [dict get $seg_name_dict $seg_name RANGE]
            if { $bn_curr_offset < $bn_prev_offset } {
              dict set seg_name_dict $seg_name OFFSET $bn_curr_offset
            }
            dict set seg_name_dict $seg_name RANGE [math::bignum::add $bn_prev_range $bn_curr_range]
          } else {
            dict set seg_name_dict $seg_name OFFSET $bn_curr_offset
            dict set seg_name_dict $seg_name RANGE $bn_curr_range
          }
        }
        set bn_range [math::bignum::add $bn_range $bn_curr_range]
        if { $bn_curr_offset < $bn_offset } {
          set bn_offset $bn_curr_offset
        }
      }
      set offset [bignum2hex $bn_offset]
      set range [bignum2hex $bn_range]
      #puts "DBG: updated addr_seg info (2) offset=$offset range=$range"
    } else {
      set offset [dict_get_default $port_dict ADDR_OFFSET $offset]
      set range  [dict_get_default $port_dict ADDR_RANGE $range]
      #puts "DBG: updated addr_seg info (3) offset=$offset range=$range"
    }
    dict set port_dict ADDR_OFFSET $offset
    dict set port_dict ADDR_RANGE $range
    return $port_dict
  }; # end update_addr_seg_info

  proc update_addressing {ip_ns_prefix dsa_ports ocl_content_dict} {
    set s_port_name [${ip_ns_prefix}get_name_ext_si]
    set s_dict {}
    set m_ports {}
    foreach port_dict $dsa_ports {
      set name [dict get $port_dict NAME]
      set mode [string toupper [dict get $port_dict MODE]]
      set type [string toupper [dict_get_default $port_dict TYPE $mode]]
      if { $type eq "STREAM" } { continue }
      if { $mode eq "SLAVE" } {
        if { [string equal -nocase $s_port_name $name] } {
          set s_dict [update_addr_seg_info $port_dict]
        }
      } elseif { $mode eq "MASTER" } {
        lappend m_ports [update_addr_seg_info $port_dict]
      }
    }

    #assign address for slave address

    set slvExt  [get_bd_intf_ports $s_port_name]
    #Get slave segments associated with this external slave interface
    set vSS [lsort [get_bd_addr_segs -addressables -of_objects $slvExt]]
    set nSS [llength $vSS]
    #Get master address spaces associated with this external slave interface
    set AS [get_bd_addr_spaces -of_objects $slvExt]
    if {$nSS < 1} {
       error "Did not find slave address segments for $slvExt"
    }
    set kernel_insts [dict get $ocl_content_dict kernels]
    # NOTE: this check is not valid if profiling was added
    #set nKernels [llength $kernel_insts]
    #if { $nSS != $nKernels } {
    #   error "Expected number of slave address segments ($nSS) to match number of kernels ($nKernels)"
    #}

    set kernel_dict [dict create]
    foreach kernel_inst $kernel_insts {
      set ss_key "[dict get $kernel_inst cell]/[dict get $kernel_inst SLAVE]"
      dict set kernel_dict [string toupper $ss_key] $kernel_inst
    }

    set use_zero_offset false
    #set use_zero_offset true; # set to true to override map.tcl offset values and use 0x0000 instead (temporary fix)
    set s_offset [dict get $s_dict ADDR_OFFSET] 
    if { !$use_zero_offset && $s_offset > 0 } {
      set s_offset_bn [hex2bignum $s_offset]
    }
    foreach SS $vSS {
      # Addressing for APM and trace FIFOs is done in add_profiling
      if {[string first xilmonitor $SS] >= 0} {
        continue
      }
      
      set ss_key [string toupper [file dirname $SS]]
      if { ![dict exists $kernel_dict $ss_key] } {
        error "Could not find kernel for slave address segment: $ss_key\nKnown kernel paths: [dict keys $kernel_dict]"
      }
      set kernel_inst [dict get $kernel_dict $ss_key]
      if { [dict exists $kernel_inst FOUND_SS] } {
        error "Expected one slave segment per kernel: $ss_key"
      }
      dict set kernel_dict $ss_key FOUND_SS true
      set k_cell [dict get $kernel_inst cell]
      set k_offset [dict get $kernel_inst ADDR_OFFSET]
      set k_range [dict get $kernel_inst ADDR_RANGE]
      set seg_name "ocl_slave_seg_[string range ${k_cell} 1 end]"
      if { $use_zero_offset } {
        if { ![info exists curr_offset] } {
          set curr_offset [hex2bignum 0]
        }
        set k_offset [bignum2hex $curr_offset]
        set curr_offset [math::bignum::add $curr_offset [hex2bignum $k_range]]
      } elseif { $s_offset > 0 } {
        set curr_offset [math::bignum::sub [hex2bignum $k_offset] $s_offset_bn]
        set k_offset [bignum2hex $curr_offset]
      }
      puts "INFO: mapping $SS into $AS offset=$k_offset range=$k_range : $seg_name"
      create_bd_addr_seg -offset $k_offset -range $k_range $AS $SS $seg_name
    }

   
    #assign address for master address
    foreach m_port_dict $m_ports {
      set m_port_name  [dict get $m_port_dict NAME]
      set m_offset     [dict get $m_port_dict ADDR_OFFSET]
      set m_range      [dict get $m_port_dict ADDR_RANGE]
      set m_addr_width [dict get $m_port_dict ADDR_WIDTH]
      set ExtSS        [get_bd_addr_segs -of_objects [get_bd_intf_ports $m_port_name]]
      assign_bd_address $ExtSS
           
      set vEclMS [lsort [get_bd_addr_segs -excluded -of_objects $ExtSS]]
      if { [llength $vEclMS] } {
        puts "INFO: include_bd_addr_seg $vEclMS"
        include_bd_addr_seg $vEclMS 
      } 
        
      set vExtMS [lsort [get_bd_addr_segs -of_objects $ExtSS]]
      foreach ExtMS $vExtMS {
        #puts "ETP: updating $ExtMS offset=$m_offset range=$m_range"
        set_property offset $m_offset $ExtMS
        set_property range  $m_range  $ExtMS
      }
    }; # end m_ports loop

    if { [is_sdaccel_debug] } { 
      ${ip_ns_prefix}show_all_addrs "DBG: "
    }
  }; # end update_addressing

  proc hex2bignum {val} {
    regsub -nocase {^0x} $val {} val
    return [math::bignum::fromstr [string tolower $val] 16]
  }
  proc bignum2hex {bn} {
    return "0x[math::bignum::tostr $bn 16]"
  }

  proc is_sdaccel_debug {} {
    set is_dbg false
    if { [info exists ::env(SDACCEL_DEBUG)] } {
      set is_dbg [expr bool($::env(SDACCEL_DEBUG))]
    }
    return $is_dbg
  }; # end is_sdaccel_debug


  proc update_port_config {dsa_ports created_ports_dict} {
    set missing_ports {}
    foreach port_dict $dsa_ports {
      set name [dict get $port_dict NAME]
      set mode [string toupper [dict get $port_dict MODE]]
      set type [string toupper [dict_get_default $port_dict TYPE $mode]]
      set config {}
      if { $type eq "RESET" || $type eq "RST" || $type eq "CLK" || $type eq "CLOCK" || $type eq "INTERRUPT" } {
        if { [dict exists $port_dict CONFIG] } {
          set config [dict get $port_dict CONFIG]
        }
      } elseif { $type eq "STREAM" } {
        if { [dict exists $port_dict CONFIG] } {
          set config [dict get $port_dict CONFIG]
        }
      } elseif { $mode eq "MASTER" } {
        set config [get_intf_config $port_dict true]
      } elseif { $mode eq "SLAVE" } {
        set config [get_intf_config $port_dict false]
      }

      if { [dict exists $created_ports_dict $name] } {
        if { [llength $config] } {
          set port_obj [dict get $created_ports_dict $name]
          set_property -dict $config $port_obj
        }
      } else {
        lappend missing_ports $name
      }
    }

    if { [llength $missing_ports] } {
      set all_ports [lsort -dictionary [dict keys $created_ports_dict]]
      error "Did not create [llength $missing_ports] expected port(s): $missing_ports\nCreated ports: $all_ports"
    }
  }; # end update_port_config

  
  proc update_kernel_resources {kernel_resources ocl_content_dict ip_ns_prefix ocl_config_dict} {
    set mems  [dict_get_default $kernel_resources MEMORIES {}]
    set pipes [dict_get_default $kernel_resources PIPES {}]
    if { [llength $mems] == 0 && [llength $pipes] == 0 } {
      # Must run always this proc to handle tieing off unused AXI interfaces
      # return
    }

    set rsrc_names {}
    set all_rsrcs_dict [dict create]
    set conns [dict_get_default $kernel_resources CONNECTIONS {}]
    set kern_dict [dict create]
    set kernel_insts [dict get $ocl_content_dict kernels]
    foreach inst_dict $kernel_insts {
      dict set kern_dict [dict get $inst_dict NAME] $inst_dict
    }

    set mem_conns [${ip_ns_prefix}filter_conns $conns "memory"]
    set external_mem_names {}
    foreach rsrc_dict $mems {
      set name [dict get $rsrc_dict NAME]
      if { [dict exists $all_rsrcs_dict $name] } {
        puts "WARNING: memory name is not unique, using only first instance: $name"
        continue
      }
      lappend rsrc_names $name
      set rsrc_conns [${ip_ns_prefix}get_conn_matches $mem_conns "memory" $name]
      set is_external [string equal -nocase "external" [dict_get_default $rsrc_dict LINKAGE ""]]
      if { $is_external } {
        lappend external_mem_names $name
      }
      dict set rsrc_dict IS_PIPE false
      dict set rsrc_dict CONNECTIONS $rsrc_conns
      dict set all_rsrcs_dict $name $rsrc_dict
    }

    set pipe_conns [${ip_ns_prefix}filter_conns $conns "pipe"]
    set external_pipe_names {}
    set external_pipe_core_ports [dict create]
    foreach rsrc_dict $pipes {
      set name [dict get $rsrc_dict NAME]
      if { [dict exists $all_rsrcs_dict $name] } {
        puts "WARNING: pipe name is not unique, using only first instance: $name"
        continue
      }
      lappend rsrc_names $name
      set is_external [string equal -nocase "external" [dict_get_default $rsrc_dict LINKAGE ""]]
      if { $is_external } {
        lappend external_pipe_names $name
      }
      set rsrc_conns [${ip_ns_prefix}get_conn_matches $pipe_conns "pipe" $name]
      set core_port ""
      foreach conn_dict $rsrc_conns {
        if { [string equal -nocase [dict get $conn_dict OTHER_TYPE] "CORE"] } {
          if { $core_port ne "" } {
            error "Multiple connections to same core port '$core_port' for pipe '$name'"
          }
          set core_port [dict get $conn_dict OTHER_PORT]
        }
      }
      if { !$is_external && $core_port ne "" } {
        puts "WARNING: Found non-external pipe connection to core: pipe $name, core port '$core_port'"
        lappend external_pipe_names $name
        set is_external true
        dict set rsrc_dict LINKAGE "external"
      }
      
      if { $is_external } {
        if { $core_port eq "" } {
          error "External pipe core port is not set: $conn_dict"
        }
        if { [dict exists $external_pipe_core_ports $core_port] } {
          error "Too many connections to external pipe core port: $port"
        }
        dict set rsrc_dict EXTERNAL_PORT_NAME $core_port
        dict set external_pipe_core_ports $core_port true
        set TDATA_NUM_BYTES [dict get $ocl_config_dict ${core_port}_TDATA_NUM_BYTES]
        set TUSER_WIDTH [dict get $ocl_config_dict ${core_port}_TUSER_WIDTH]
        set fifo_config [${ip_ns_prefix}get_axis_config $TUSER_WIDTH $TDATA_NUM_BYTES "fifo"]
        dict set rsrc_dict CONFIG $fifo_config
      }
      dict set rsrc_dict IS_PIPE true
      dict set rsrc_dict CONNECTIONS $rsrc_conns
      dict set all_rsrcs_dict $name $rsrc_dict
    }

    # Get shared clock/reset nets
    set i_clk_net [get_bd_net [dict get $ocl_content_dict clk_interconnect_net]]
    set i_rst_net [get_bd_net [dict get $ocl_content_dict rst_interconnect_sync_net]]
    set k_clk_net [get_bd_net [dict get $ocl_content_dict clk_kernel_net]]
    set k_rst_net [get_bd_net [dict get $ocl_content_dict rst_kernel_sync_net]]

    # Create external memory bridge
    set has_s_mem [dict_get_default $ocl_config_dict HAS_S_MEM 0]
    set num_external_mems [llength $external_mem_names]
    if { $has_s_mem } {
      set s_mem_bridge_m_axi [${ip_ns_prefix}create_mem_bridge $ocl_content_dict $ocl_config_dict $i_clk_net $i_rst_net $num_external_mems]
    } elseif { $num_external_mems } {
      error "DSA does not support S_MEM interface"
    }

    # Create external memory interconnect
    set enable_smartconnect [dict_get_default $ocl_config_dict ENABLE_SMARTCONNECT 0]
    if { $num_external_mems && $has_s_mem } {
      if { $num_external_mems == 1 } {
        dict set all_rsrcs_dict [lindex $external_mem_names 0] EXTERNAL_CONNECTION $s_mem_bridge_m_axi
      } else {
        set s_mem_use_sc [${ip_ns_prefix}use_smart_connect "ext_mem" $enable_smartconnect]
        set s_mem_has_second_clock [expr {![string equal -nocase $k_clk_net $i_clk_net]}]
        set s_mem_intercon [${ip_ns_prefix}create_interconnect "s_mem_intercon" [list CONFIG.NUM_MI $num_external_mems CONFIG.NUM_SI 1] $s_mem_use_sc $s_mem_has_second_clock]
        connect_bd_intf_net $s_mem_bridge_m_axi [get_bd_intf_pins $s_mem_intercon/[${ip_ns_prefix}get_name_intercon_si 0]]
        if { $s_mem_use_sc } {
          connect_bd_net -net $i_clk_net [get_bd_pins $s_mem_intercon/aclk]
          connect_bd_net -net $i_rst_net [get_bd_pins $s_mem_intercon/aresetn]
          set clk2 [get_bd_pins -quiet $s_mem_intercon/aclk1]
          if { $clk2 ne "" } {
            connect_bd_net -net $k_clk_net $clk2
            #connect_bd_net -net $k_rst_net [get_bd_pins $s_mem_intercon/aresetn1]
          }
        } else {
          connect_bd_net -net $i_clk_net [get_bd_pins $s_mem_intercon/ACLK]
          connect_bd_net -net $i_rst_net [get_bd_pins $s_mem_intercon/ARESETN]
          connect_bd_net -net $i_clk_net [get_bd_pins $s_mem_intercon/S*_ACLK]
          connect_bd_net -net $i_rst_net [get_bd_pins $s_mem_intercon/S*_ARESETN]
          connect_bd_net -net $k_clk_net [get_bd_pins $s_mem_intercon/M*_ACLK]
          connect_bd_net -net $k_rst_net [get_bd_pins $s_mem_intercon/M*_ARESETN]
        }
        for {set idx 0} {$idx < $num_external_mems} {incr idx} {
          set name [lindex $external_mem_names $idx]
          dict set all_rsrcs_dict $name EXTERNAL_CONNECTION [get_bd_intf_pins $s_mem_intercon/[${ip_ns_prefix}get_name_intercon_mi $idx]]
        }
      }
    }

    # DRC for external pipe connections
    set pipe_ext_intf_names [${ip_ns_prefix}get_axis_names $ocl_config_dict]
    set missing_pipes {}
    foreach intf_name [lsort -dictionary [dict keys $external_pipe_core_ports]] {
      if { [lsearch -exact $pipe_ext_intf_names $intf_name] < 0 } {
        lappend missing_pipes $intf_name
      }
    }
    if { [llength $missing_pipes] } {
      error "DSA does not support requested external pipes: $missing_pipes"
    }

    # Terminate unused external pipe ports
    foreach intf_name $pipe_ext_intf_names {
      if { [dict exists $external_pipe_core_ports $intf_name] } {
        continue
      }
      set intf_port [get_bd_intf_ports /$intf_name]
      set conn "M_AXIS"
      set term "S_AXIS"
      if { [string equal -nocase "Slave" [get_property MODE $intf_port]] } {
        set conn "S_AXIS"
        set term "M_AXIS"
      }
      set TDATA_NUM_BYTES [dict get $ocl_config_dict ${intf_name}_TDATA_NUM_BYTES]
      set TUSER_WIDTH [dict get $ocl_config_dict ${intf_name}_TUSER_WIDTH]
      set axis_reg [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:* ${intf_name}_tieoff_reg_slice]
      set axis_config [${ip_ns_prefix}get_axis_config $TUSER_WIDTH $TDATA_NUM_BYTES "regslice"]
      set_property -dict $axis_config $axis_reg
      ${ip_ns_prefix}terminate_intf $axis_reg/$term
      connect_bd_intf_net $intf_port [get_bd_intf_pins $axis_reg/$conn]
      #puts "ETP: get_bd_intf_pins $axis_reg: [get_bd_intf_pins $axis_reg/*]"
      #puts "ETP: get_bd_ports: [get_bd_ports]"
      connect_bd_net [get_bd_ports [${ip_ns_prefix}get_axis_clk_name $intf_name]] [get_bd_pins $axis_reg/aclk]
      connect_bd_net [get_bd_ports [${ip_ns_prefix}get_axis_rst_name $intf_name]] [get_bd_pins $axis_reg/aresetn]
      ${ip_ns_prefix}dont_touch $axis_reg
      ${ip_ns_prefix}dont_touch_intf $intf_port
    }

    set res_dict [dict create]
    foreach r_name $rsrc_names {
      set rsrc_dict [dict get $all_rsrcs_dict $r_name]
      connect_resource $rsrc_dict $k_clk_net $k_rst_net $ip_ns_prefix $enable_smartconnect
    }
    return $res_dict
  }; # end update_kernel_resources

  proc connect_resource {rsrc_dict clk_net rst_net ip_ns_prefix enable_smartconnect} {
    set rsrc_name [dict get $rsrc_dict NAME]
    if {![dict exists $rsrc_dict CONNECTIONS] } {
      puts "WARNING: Expected memory/pipe '$rsrc_name' in connection"
      return
    }
    set conn_dict [dict get $rsrc_dict CONNECTIONS]

    if { [dict get $rsrc_dict IS_PIPE] } {
      # Handle pipe
      set core_side ""
      foreach pipe_side {S M} {
        set pipe_port "${pipe_side}_AXIS"
        set pipe_conn_side [${ip_ns_prefix}get_conn_other_sides $conn_dict "PIPE" "" $pipe_port]
        if { [llength $pipe_conn_side] != 1 } {
          error "Expected one pipe connection for $rsrc_name $pipe_port but got [llength $pipe_conn_side]: $pipe_conn_side"
        }
        set pipe_conn_side [lindex $pipe_conn_side 0]
        set conn_type [dict get $pipe_conn_side TYPE]
        set conn_port [dict get $pipe_conn_side PORT]
        if { [string equal -nocase $conn_type "CORE"] } {
          set core_side $pipe_side
          set pin [get_bd_intf_port -quiet $conn_port]
          if { $pin eq "" } {
            error "Could not find pipe external port for $rsrc_name $pipe_port: $conn_port"
          }
        } elseif { [string equal -nocase $conn_type "KERNEL"] } {
          set conn_inst [dict get $pipe_conn_side NAME]
          set pin [get_bd_intf_pins -quiet /$conn_inst/$conn_port]
          if { $pin eq "" } {
            error "Could not find pipe connection for $rsrc_name $pipe_port: $conn_inst/$conn_port"
          }
        } else {
          error "Unexpected pipe connection type '$conn_type' for $rsrc_name $pipe_port: $pipe_conn_side"
        }
        set ${pipe_side}_PIN $pin
      }; # end pipe_side loop

      set fifo_config [dict create]
      if { [dict exists $rsrc_dict CONFIG] } {
        set fifo_config [dict get $rsrc_dict CONFIG]
      }
      dict set fifo_config CONFIG.FIFO_DEPTH [dict get $rsrc_dict DEPTH]
      #puts "DBG: fifo config: $fifo_config"

      if { [dict exists $rsrc_dict EXTERNAL_PORT_NAME] } {
        set core_port [dict get $rsrc_dict EXTERNAL_PORT_NAME]
        set clk_name [${ip_ns_prefix}get_axis_clk_name $core_port]
        set rst_name [${ip_ns_prefix}get_axis_rst_name $core_port]
        set clk_port [get_bd_ports $clk_name -filter {DIR == I && TYPE == clk}]
        set ext_clk_net [create_bd_net "${clk_name}_net"]
        connect_bd_net -net $ext_clk_net $clk_port
        set rst_port [get_bd_ports $rst_name -filter {DIR == I && TYPE == rst}]
        set ext_rst_net [create_bd_net "${rst_name}_net"]
        connect_bd_net -net $ext_rst_net $rst_port

        if { $core_side eq "M" } {
          set s_clk_net $clk_net
          set s_rst_net $rst_net
          set m_clk_net $ext_clk_net
          set m_rst_net $ext_rst_net
        } else {
          set s_clk_net $ext_clk_net
          set s_rst_net $ext_rst_net
          set m_clk_net $clk_net
          set m_rst_net $rst_net
        }
      } else {
        set s_clk_net $clk_net
        set s_rst_net $rst_net
        set m_clk_net ""
        set m_rst_net ""
      }
      
      ${ip_ns_prefix}connect_pipe_fifo $rsrc_name $S_PIN $M_PIN $s_clk_net $s_rst_net $fifo_config $m_clk_net $m_rst_net

    } else { 
      # Handle memory
      set connections {}
      set mem_conn_sides [${ip_ns_prefix}get_conn_other_sides $conn_dict "MEMORY"]
      foreach mem_conn_side $mem_conn_sides {
        set conn_type [dict get $mem_conn_side TYPE]
        if { [string equal -nocase $conn_type "CORE"] } {
          # These are handled by $rsrc_dict EXTERNAL_CONNECTION 
          continue
        }
        set conn_port [dict get $mem_conn_side PORT]
        set conn_inst [dict get $mem_conn_side NAME]
        set pin [get_bd_intf_pins -quiet "/$conn_inst/$conn_port"]
        if { $pin eq "" } {
          error "Could not find memory connection for $rsrc_name to $conn_type $conn_inst/$conn_port"
        }
        lappend connections $pin
      }
      set addr_offset [dict get $rsrc_dict ADDR_OFFSET]
      set addr_range  [dict get $rsrc_dict ADDR_RANGE]
      set data_width  [dict_get_default $rsrc_dict DATA_WIDTH 0]
      set ext_conn    [dict_get_default $rsrc_dict EXTERNAL_CONNECTION {}]
      ${ip_ns_prefix}connect_mem $rsrc_name $clk_net $rst_net $connections $addr_offset $addr_range $data_width $ext_conn $enable_smartconnect
    }
  }; # end connect_resource

  proc get_implicit_ocl_ip_config {dsa_ports ocl_ip_vlnv} {
    set num_clks 0
    set found_modes [dict create]
    set implicit_ip_config [dict create]
    foreach port_dict $dsa_ports {
      set mode [string toupper [dict get $port_dict MODE]]
      set type [string toupper [dict_get_default $port_dict TYPE $mode]]
      if { $type eq "CLOCK" || $type eq "CLK"} {
        incr num_clks
      }
      
      if { $mode ne "MASTER" && $mode ne "SLAVE" } {
        continue
      }
      set name [dict get $port_dict NAME]
      if { $name ne "S_AXI" && $name ne "M_AXI" } {
        continue
      }

      set is_master [expr {$mode eq "MASTER"}]

      set ip_props [list USER_WIDTH]
      if { $is_master } {
        set prefix "M_"
        lappend ip_props M_DATA_WIDTH M_ADDR_WIDTH M_ID_WIDTH
      } else {
        set prefix "S_"
        lappend ip_props S_DATA_WIDTH S_ADDR_WIDTH
      }

      set count 1
      if { [dict exists $found_modes $mode] } {
        incr count [dict get $found_modes $mode]
      }
      dict set found_modes $mode $count
      foreach ip_prop $ip_props {
        set port_prop $ip_prop
        regsub "^${prefix}" $port_prop {} port_prop
        if { ![dict exists $port_dict $port_prop] } {
          puts "WARNING: did not find '$port_prop' value in '$name' $mode platform port dict"
          continue
        }
        set new_val [dict get $port_dict $port_prop]
        if { $count == 1 } {
          dict set implicit_ip_config $ip_prop $new_val
        } else {
          set curr_val [dict get $implicit_ip_config $ip_prop]
          if { $curr_val != $new_val } {
            set mode_desc ""
            if { $port_prop ne $ip_prop } {
              set " $mode"
            }
            error "Value of '$port_prop' must be the same in all$mode_desc platform interfaces, found '$curr_val' and '$new_val'"
          }
        }
      }
      if { $is_master } {
        dict set implicit_ip_config "NUM_MI" $count
      }
    }; # end ports loop
    #if { $num_clks > 2 || $num_clks < 1 } {
    #  error "Expected 1 or 2 platform clocks but found $num_clks"
    #}
    #dict set implicit_ip_config HAS_KERNEL_CLOCK [expr {$num_clks == 2}]
    return $implicit_ip_config
  }; # end get_implicit_ocl_ip_config

  proc update_kernel_info {kernels_name} {
    upvar $kernels_name kernels
    if { [llength $kernels] == 0 } {
      set default_vlnv "xilinx.com:ip:ocl_axi_addone:*"
      puts "Using default kernel(s): 1x $default_vlnv"
      lappend kernels [dict create VLNV $default_vlnv]
    }

    set default_kernel [dict create \
      MASTER      m_axi_gmem \
      SLAVE       s_axi_control \
      CLK         ap_clk \
      RST         ap_rst_n \
      ADDR_OFFSET 0x00000000 \
      ADDR_RANGE  0x1000 \
      CONFIG      {} \
      DEBUG       0 \
    ];
    
    set new_kernels {}
    foreach k_dict $kernels {
      if { ![dict exists $k_dict VLNV] } {
        error "Kernel must specify a VLNV: $k_dict"
      }
      set new_k_dict [dict merge $default_kernel $k_dict]
      dict set new_k_dict MASTER [lsort -unique [dict get $new_k_dict MASTER]]
      lappend new_kernels $new_k_dict
    }
    set kernels $new_kernels
  }; # end update_kernel_info

  proc update_ocl_ip_info {ocl_ip_dict dsa_ports} {
    if { [dict exists $ocl_ip_dict VLNV] } {
      set ocl_ip_vlnv [dict get $ocl_ip_dict VLNV] 
    } else {
      set ocl_ip_vlnv "xilinx.com:ip:ocl_block:1.0"
      dict set ocl_ip_dict VLNV $ocl_ip_vlnv
    }
    
    # Derive HIP congfig from DSA port parameters then check that the actual HIP config values match 
    set implicit_ip_config [get_implicit_ocl_ip_config $dsa_ports $ocl_ip_vlnv]

    set res_config $implicit_ip_config
    if { [dict exists $ocl_ip_dict CONFIG] } {
      foreach {name value} [dict get $ocl_ip_dict CONFIG] {
        regsub -nocase {^CONFIG\.} $name {} name
        set name [string toupper $name]
        if { [dict exists $implicit_ip_config $name] } {
          set implicit_value [dict get $implicit_ip_config $name]
          if { $value != $implicit_value } {
            error "OCL IP value for '$name' derived from boundary information ($implicit_value) does not match explicit value ($value)" 
          }
        } else {
          dict set res_config $name $value
        }
      }
    }
    if { ![dict exists $res_config SYNC_RESET] } {
      # Use synq-reset if not specified
      dict set res_config SYNC_RESET 1
    }
    set varname "SDACCEL_OCL_BLOCK_CONFIG"
    if { [info exists ::env($varname)] } {
      set varval $::env($varname)
      puts "INFO: Using env($varname) value: $varval"
      # last dict passed to dict merge takes precedence
      set res_config [dict merge $res_config $varval]
    }
    puts "INFO: Updated OCL block configuration: $res_config"
    return $res_config
  }; # end update_ocl_ip_info

  proc get_idbridge_ip { idbridges ext_mst_name} {
      foreach idbridge $idbridges {
          set EXT_MST_NAME [dict get $idbridge EXT_PORT_NAME ]
          if {[string match -nocase $ext_mst_name $EXT_MST_NAME]} {
              return [dict get $idbridge NAME]
          }
      }
  }

  proc get_intf_addr_seg { intf } {
      set addr_space [lindex [get_bd_addr_spaces -of_objects $intf] 0 ]
      set addr_seg   [lindex [get_bd_addr_segs -of_objects $addr_space] 0 ]
      return $addr_seg
  }

  proc set_port_config {config port} {
    if { [llength $config] } {
      set_property -dict $config $port
    }
  }

  proc get_intf_config {port_dict is_master} {
    set props [list PROTOCOL ADDR_WIDTH DATA_WIDTH]
    #if { !$is_master } {
    #  lappend props MAX_BURST_LENGTH
    #}
    set config {}
    foreach prop $props {
      if { [dict exists $port_dict $prop] } {
        lappend config CONFIG.$prop [dict get $port_dict $prop]
      }
    }
    if { 0 } {
      # TODO: set user widths
      # Set all the user widths to the same value
      set user_width [dict get $port_dict USER_WIDTH]
      foreach prop [list ARUSER_WIDTH AWUSER_WIDTH BUSER_WIDTH RUSER_WIDTH WUSER_WIDTH] {
        lappend config CONFIG.$prop $user_width
      }
    }
    return $config
  }

  proc get_idbridge_config {port_dict} {
    set config {}
    foreach prop [list PROTOCOL ADDR_WIDTH DATA_WIDTH] {
      lappend config CONFIG.$prop [dict get $port_dict $prop]
    }
    return $config
  }

  # sourcing ocl_block_utils.tcl
  proc source_ocl_ip_tcl_file {vlnv {ipdir ""}} {
    set ns "ocl_block_utils"
    set ns_prefix "${ns}::" 
    if { [namespace exists ::$ns] } {
      return $ns_prefix
    }

    set varname "SDACCEL_OCL_BLOCK_UTILS"
    if { [info exists ::env($varname)] && $::env($varname) ne "" } {
      set path $::env($varname)
      puts "INFO: Using env($varname) value: $path"
    } else {
      set path [file join [get_script_dir] ${ns}.tcl]
    }
    if { [file exists $path] } {
      puts "Sourcing file: $path"
      namespace eval :: [list source -notrace $path]
      return $ns_prefix
    }

    error "Could not find file: $path"

    if { $ipdir eq "" } {
      set ips [get_ipdefs -all $vlnv]
      if { [llength $ips] > 1 } {
        set files {}
        foreach ip $ips {
          lappend files [get_property XML_FILE_NAME $ip]
        }
        error "Found multiple '$vlnv' IP in catalog: $files"
      } elseif { [llength $ips] == 0 } {
        error "Could not find IP in catalog: $vlnv"
      }
      set ip [lindex $ips 0]
      set path [get_property XML_FILE_NAME $ip]
      set ipdir [file dirname $path]
    }
    if { ![file exists $ipdir] } {
      error "Could not find '$vlnv' IP root: $ipdir"
    }
    
    set path [file join $ipdir bd ${ns}.tcl]
    if { [file exists $path] } {
      puts "Sourcing $vlnv IP file: $path"
      namespace eval :: [list source -notrace $path]
      return $ns_prefix
    }
    set first_path [file join $ipdir bd ${ns}.tcl]
    error "Could not find '$vlnv' file: $path"
  }; # end source_ocl_ip_tcl_file

  proc init_ocl_project {dsa_part config_info {kernel_ip_dirs {}}} {
    set design_name      [dict get $config_info design_name]
    set project_name     [dict get $config_info synth_proj_name]

    create_project -part $dsa_part -force $project_name $project_name
    set_property tool_flow SDx [current_project]
    
    if { $kernel_ip_dirs ne "" } {
      puts "Setting ip_repo_paths: $kernel_ip_dirs"
      set_property ip_repo_paths $kernel_ip_dirs [current_project] 
      update_ip_catalog
    }

    # this is moved to HPIKernelCompiler::writeDefaultVivadoParams_
    # set_msg_config -id "Timing 38-282" -new_severity ERROR 

    create_bd_design $design_name -bdsource SDACCEL
    current_bd_design $design_name 

    # append to "More Options", instead of overwriting
    set more_option [get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]]
    set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value "$more_option -mode out_of_context" -objects [get_runs synth_1]; 
    # puts "--- DEBUG: [get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]]"
  }; # end init_ocl_project

  proc update_kernel_clocks { kernel_clock_freqs } {
    dict for {kernel_clk dict_clock} $kernel_clock_freqs {
      set kernel_clk_inst [string range $kernel_clk 0 [string last _ $kernel_clk]-1]
      set clk_freq [dict get $dict_clock freq]
      set is_user_set   [dict get $dict_clock is_user_set]
      if { [string equal -nocase $is_user_set "true" ] } {
      set clkFreqHZ [expr {int($clk_freq*1000000)}]
        set_property -dict [list CONFIG.FREQ_HZ $clkFreqHZ] [get_bd_cells $kernel_clk_inst]
      }
    }
  }; # end update_kernel_clocks

  # Add profiling for DDR banks (soc platforms)
  proc add_axi_perf_mons_banks { dsa_dr_bd } {
    # open BD of dynamic region
    open_bd_design $dsa_dr_bd
    
    #TODO : Remove this block once generic pcie flow is available
    #get_bd_cell of sdaccel_generic_pcie
    set sdaccel_gen_pcie [get_bd_cells * -filter {VLNV=~xilinx.com:ip:sdaccel_generic_pcie:*} -quiet]
    if { [llength $sdaccel_gen_pcie] > 0 } { 
      set ddr0_ui_clk [get_bd_cells ddr0_ui_clk -quiet]
      set numGlobalMemories [get_property CONFIG.NUMBER_OF_GLOBAL_MEMORIES $sdaccel_gen_pcie]
      for {set i 0} {$i < 4} {incr i} {
        set perf_mon [ create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_perf_mon:1.0 sim_axi_perf_mon_${i} ]
        set_property -dict [list CONFIG.MONITOR_ID BANK${i}] $perf_mon

        connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aclk] [get_bd_pins $ddr0_ui_clk/clk]
        connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aresetn] [get_bd_pins $ddr0_ui_clk/sync_rst]
        connect_bd_intf_net [get_bd_intf_pins $perf_mon/MON_AXI] [get_bd_intf_pins $sdaccel_gen_pcie/C${i}_DDR_SAXI]
      }
    } else {
      set ddrx [get_bd_cells * -filter {VLNV=~ xilinx.com:user:ddrx:*} -quiet]
      if { [llength $ddrx] > 0 } { 
        set ddr0_ui_clk [get_bd_cells ddr0_ui_clk -quiet]
        set numGlobalMemories [get_property CONFIG.C_NUMBER_OF_GLOBAL_MEMORIES $ddrx]
        for {set i 0} {$i < 4} {incr i} {
          set perf_mon [ create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_perf_mon:1.0 sim_axi_perf_mon_${i} ]
          set_property -dict [list CONFIG.MONITOR_ID BANK${i}] $perf_mon
  
          connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aclk] [get_bd_pins $ddr0_ui_clk/clk]
          connect_bd_net [get_bd_pins sim_axi_perf_mon_${i}/axi_aresetn] [get_bd_pins $ddr0_ui_clk/sync_rst]
          connect_bd_intf_net [get_bd_intf_pins $perf_mon/MON_AXI] [get_bd_intf_pins $ddrx/C${i}_DDR_SAXI]
        }
      }
    }
  }; # end add_axi_perf_mons_banks
  
  # Add profiling for accelerator ports (pcie platforms)
  proc add_axi_perf_mons_ports { dsa_dr_bd } {
    # open BD of dynamic region
    open_bd_design $dsa_dr_bd
    
    set i 0
    set cu_instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    set cu_masters [get_bd_intf_pins -quiet -of $cu_instances -filter "Mode==Master"]
    
    foreach master $cu_masters {
      puts "--- DEBUG: adding monitor to CU master: $master"
      set perf_mon [ create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_axi_perf_mon:1.0 sim_axi_perf_mon2_${i} ]
      # This property is used in RPC call
      set cu_master_name $master
      set monId [string trimleft $master "/"]
      set monId [string map {"/" ":"} $monId]
      #set monId [string toupper $monId]

      puts "--- DEBUG: setting monitor ID $monId"
      set_property -dict [list CONFIG.MONITOR_ID $monId ] $perf_mon
      add_debug_ip AXI_MM_MONITOR $perf_mon $master $i
      
      set monClock [get_clk_from_intf_pin $master]
      set monReset [get_reset_from_intf_pin $master]
      if {$monReset eq ""} {
        puts "WARNING: using default reset in Emulation flow"
        set monReset [get_bd_pins /psr_kernel_clk/peripheral_aresetn]
      }
      puts "--- DEBUG: using clock: $monClock and reset: $monReset"
      connect_bd_net [get_bd_pins sim_axi_perf_mon2_${i}/axi_aclk] [get_bd_pins $monClock]
      connect_bd_net [get_bd_pins sim_axi_perf_mon2_${i}/axi_aresetn] [get_bd_pins $monReset]
      connect_bd_intf_net [get_bd_intf_pins $perf_mon/MON_AXI] [get_bd_intf_pins $master]
      incr i
    }
  }; # end add_axi_perf_mons_ports

  proc add_accel_mons { dsa_dr_bd } {
    # open BD of dynamic region
    open_bd_design $dsa_dr_bd
    
    set i 0
    set cu_instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    
    foreach cu $cu_instances {
      # Grab the AXI-Lite slave and associated clock/reset
      set monSlave [lindex [get_bd_intf_pins -quiet -of_objects $cu -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}] 0]
      set monClock [get_clk_from_intf_pin $monSlave]
      set monReset [get_reset_from_intf_pin $monSlave]
      if {$monReset eq ""} {
        puts "WARNING: using default reset in Emulation flow"
        set monReset [get_bd_pins /psr_kernel_clk/peripheral_aresetn]
      }
      puts "--- DEBUG: using clock: $monClock, reset: $monReset, slave: $monSlave"
      
      # If all looks good, then insert monitor
      if {($monSlave ne "") && ($monClock ne "") && ($monReset ne "")} {
        puts "--- DEBUG: adding monitor to CU: $cu"
        set accel_mon [ create_bd_cell -type ip -vlnv xilinx.com:Debug:sim_sdx_accel_monitor sim_accel_mon_${i}]
        # This property is used in RPC call
        if {[string index $cu 0] == "/"} {
          set cu_name [string range $cu 1 [string length $cu]]
        }
        set_property -dict [list CONFIG.MONITOR_ID $cu_name] $accel_mon
        add_debug_ip ACCEL_MONITOR $accel_mon $cu_name $i
      
        connect_bd_net [get_bd_pins $accel_mon/axi_aclk] [get_bd_pins $monClock]
        connect_bd_net [get_bd_pins $accel_mon/axi_aresetn] [get_bd_pins $monReset]
        connect_bd_intf_net [get_bd_intf_pins $accel_mon/MON_AXI] [get_bd_intf_pins $monSlave]
        incr i
      }
    }
  }; # end add_accel_mons
  
  proc add_protocol_checker_unip { dsa_dr_bd } {
    # open BD of dynamic region
    open_bd_design $dsa_dr_bd

    # Monitor all AXI-MM ports on all compute units
    set perfMonPorts [list]
    set accelCells [get_bd_cells * -filter {VLNV =~ "xilinx.com:hls:*"} -quiet]
    foreach accel $accelCells {
      set accelMasters [get_bd_intf_pins -of_objects $accel -quiet]
      foreach pinName $accelMasters {
        # Instantiate monitor
        set tmpName "axi_protocol_checker_[string trimleft $pinName "/"]"
        set ipName [string map {"/" "_"} $tmpName]
        puts "--- DEBUG: Adding $ipName for kernel protocol checking..."
        set protocol_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_checker $ipName]
        # Connect clock and reset
        set currClock [get_clk_from_intf_pin $pinName]
        set currReset [get_reset_from_intf_pin $pinName]
        if { ($currClock eq "") || ($currReset eq "") } {
          delete_bd_objs $protocol_obj
          puts "WARNING: unable to insert $ipName"
          continue
        }
        connect_bd_net [get_bd_pins $currClock] [get_bd_pins $ipName/aclk]
        connect_bd_net [get_bd_pins $currReset] [get_bd_pins $ipName/aresetn]

        # Connect AXI port"
        connect_bd_intf_net [get_bd_intf_pins $ipName/PC_AXI] [get_bd_intf_pins $pinName]
      }
    }
    save_bd_design
  } 

  #Procedure to return kernel name for a given run
  proc get_kernel_name_from_run {kernel_run} {
    set cand_fs [get_property srcset $kernel_run]
    if {[get_property fileset_type $cand_fs] != "BlockSrcs"} {return}
    set cand_files [get_files -of_objects $cand_fs -norecurse]
    if {[llength $cand_files] != 1} {return}
    set cand_file [lindex $cand_files 0]
    if {[get_property FILE_TYPE $cand_file] != "IP"} {return}
    set cand_ip [get_ips -all [get_property IP_TOP $cand_file]]
    if {$cand_ip == {}} {return}
    set prop_val [get_property SDX_KERNEL $cand_ip]
    if {[get_property SDX_KERNEL $cand_ip] && [get_property SDX_KERNEL_TYPE $cand_ip] eq "hls"} {
      set fields [split [get_property IPDEF $cand_ip] ":"]
      lassign $fields vender slibrary ipname version
      return $ipname
    }
  }

  # Procedure for tracking report files
  proc log_generated_reports {log_file runs} {
    set failed [catch {
      set generated_reports_fh [open $log_file a]
      puts $generated_reports_fh [join [get_generated_reports $runs] "\n"]
      close $generated_reports_fh
    } _error]
    if { $failed } {
      puts "WARNING: Failed while trying to create a log with all generated reports, error: '${_error}'"
      puts "         The flow will continue, but generated reports may not be listed correctly."
    }
  }

  # Assemble the content of the generated reports log
  proc get_generated_reports {runs} {
    set log_content {}
    foreach run $runs {
      set props [list_property $run STEPS.*.REPORTS]
      foreach prop $props {
        set run_step_reports [get_property $prop $run]
        foreach run_step_report $run_step_reports {
          set report_obj [get_report_configs $run_step_report]
          if { [llength $report_obj] > 0 } {        
            set output_file [get_property OUTPUT_FILE $report_obj]
            # NOTE: report_type has <report_command>:<version>
            set report_type [get_property REPORT_TYPE $report_obj]
            set report_type_list [split ${report_type} ":"]
            set report_command [lindex ${report_type_list} 0]
            set version [lindex ${report_type_list} 1]
            set report_name [get_property NAME $report_obj]
            set kernel_name [get_kernel_name_from_run $run]
            if { $output_file != "" } {
              set file_path [file join [get_property directory $run] $output_file]
              lappend log_content "${report_command}|${version}|${report_name}|${file_path}|${kernel_name}"
            }
          }
        }
      }
    }
    return $log_content
  }

  # single project flow for unified platforms
  proc single_project_flow_unip {dsa_info config_info clk_info debug_profile_info} {
    set dsa_dr_bd           [dict get $dsa_info dsa_dr_bd] 
    set dsa_platform_state  [dict get $dsa_info dsa_platform_state] 
    set dsa_part            [dict get $dsa_info dsa_part]
    set dsa_uses_pr         [dict get $dsa_info dsa_uses_pr]
    set link_output_format  [dict get $dsa_info link_output_format]
    set bb_locked_dcp       [dict get $dsa_info bb_locked_dcp]
    set ocl_inst_path       [dict get $dsa_info ocl_region]
    set impl_xdc            [dict get $dsa_info impl_xdc] 
    set uses_pr_shell_dcp   [dict get $dsa_info dsa_uses_pr_shell_dcp]
    set pr_shell_dcp        [dict get $dsa_info dsa_pr_shell_dcp]
    set dsa_dcp_top         [dict get $dsa_info dsa_dcp_top]

    set project_name        [dict get $config_info proj_name] 
    set steps_log           [dict get $config_info steps_log] 
    set output_dir          [dict get $config_info output_dir] 
    set script_only         [dict get $config_info generate_script_only] 
    set run_script_map_file [dict get $config_info run_script_map_file] 
    set num_jobs            [dict get $config_info num_jobs] 
    set lsf_string          [dict get $config_info lsf_string] 
    set synth_props_tcl     [dict get $config_info synth_props_tcl] 
    set report_commands_tcl [dict get $config_info report_commands_tcl] 
    set out_partial_bit     [dict get $config_info out_partial_bitstream]
    set out_partial_clear_bit  [dict get $config_info out_partial_clear_bit]
    set out_full_bit        [dict get $config_info out_full_bitstream]
    set impl_props_tcl      [dict get $config_info impl_props_tcl]
    set encrypt_impl_dcp    [dict get $config_info encrypt_impl_dcp]
    set return_pre_synth    [dict get $config_info return_pre_synth]
    set return_post_synth   [dict get $config_info return_post_synth]
    set return_pre_impl     [dict get $config_info return_pre_impl]
    set enable_dont_partition  [dict get $config_info enable_dont_partition]
    set partition_def       [dict get $config_info partition_def]
    set reconfig_module     [dict get $config_info reconfig_module]

    set kernel_clock_freqs  [dict get $clk_info kernel_clock_freqs]  

    set cwd [pwd]

    # populate the bb_locked dcp in the design 
    #    no-op for soc platforms
    if { ![string equal $dsa_platform_state "pre_synth"] } {
      # pcie platforms
      
      # -- Create the project --
      add_to_steps_log $steps_log "internal step: create_project -part $dsa_part -force $project_name $project_name"
      create_project -part $dsa_part -force $project_name $project_name
      add_to_steps_log $steps_log "internal step: set_property design_mode GateLvl \[current_fileset\]"
      set_property design_mode GateLvl [current_fileset]
      add_to_steps_log $steps_log "internal step: set_property PR_FLOW 1 \[current_project\]"
      set_property PR_FLOW 1 [current_project]

      # Memory initialization isn't support, speed up flow by disabling creation
      # of the BMM / MMI file.
      set_property mem.enable_memory_map_generation 0 [current_project]

      # support bb_locked dcp (enhanced link_design pr flow)
      # bb_locked dcp should always be there for unified platforms since 2018.1
      # abstract shell dcp in 2018.2 only support FaaS
      # if AcceleratorBinaryContent is set to "bitstream", we should bb_locked dcp
      # if AcceleratorBinaryContent is set to "dcp", abstract shell dcp should take precedence
      # necessary error check has already been done in xocc front end, we can only consider the valid usecase here
      if { $bb_locked_dcp ne "" || $uses_pr_shell_dcp} {
        if { [string equal $link_output_format "bitstream"] } {  
          set dsa_dcp $bb_locked_dcp
        } else {
          set dsa_dcp [expr { $uses_pr_shell_dcp ? $pr_shell_dcp : $bb_locked_dcp} ] 
        }

        add_to_steps_log $steps_log "internal step: add_files $dsa_dcp"
        add_files $dsa_dcp

        # -- Create the partion and rm that will contain the bd
        # use dr_bd base name as the dr top
        set dr_top [file rootname [file tail $dsa_dr_bd]]
        add_to_steps_log $steps_log "internal step: create_partition_def -name $partition_def -module $dr_top"
        create_partition_def -name $partition_def -module $dr_top
        add_to_steps_log $steps_log "internal step: create_reconfig_module -name $reconfig_module -partition_def \[get_partition_defs $partition_def \] -top $dr_top"
        create_reconfig_module -name $reconfig_module -partition_def [get_partition_defs $partition_def ] -top $dr_top
        add_to_steps_log $steps_log "internal step: set_property use_blackbox_stub false \[get_filesets $reconfig_module -of_objects \[get_reconfig_modules $reconfig_module\]\]"
        set_property use_blackbox_stub false [get_filesets $reconfig_module -of_objects [get_reconfig_modules $reconfig_module]]
        add_to_steps_log $steps_log "internal step: set_property USE_BLACKBOX_STUB 0 \[get_partition_defs $partition_def\]"
        set_property USE_BLACKBOX_STUB 0 [get_partition_defs $partition_def]
      }
    }

    # populate dr_bd portion of the design 
    set is_single_project_flow true
    init_ocl_project_unip $dsa_info $config_info $clk_info $debug_profile_info $is_single_project_flow
  
    # source report_commands_tcl file if it exists
    if { ![string equal $report_commands_tcl ""] && [file exists $report_commands_tcl] } {
      OPTRACE "START" "Source report_commands_tcl" 
      add_to_steps_log $steps_log "internal step: source $report_commands_tcl"
      source $report_commands_tcl
      OPTRACE "END" "Source report_commands_tcl" 
    }

    # source synth_props_tcl file if it exists
    if { ![string equal $synth_props_tcl ""] && [file exists $synth_props_tcl] } {
      OPTRACE "START" "Source synth_props_tcl" 
      add_to_steps_log $steps_log "internal step: source $synth_props_tcl"
      source $synth_props_tcl
      OPTRACE "END" "Source synth_props_tcl" 
    }

    # populate the bb_locked dcp in the design 
    #    no-op for soc platforms
    if { ![string equal $dsa_platform_state "pre_synth"] } {

      # impl_constrs support
      add_xdc_files $impl_xdc $steps_log
  
      # read the _post_sys_link_gen_constrs.xdc generated by sourcing post_sys_link_tcl
      set post_sys_link_gen_xdc "_post_sys_link_gen_constrs.xdc"
      if { [file exists $post_sys_link_gen_xdc] } {
        add_to_steps_log $steps_log "internal step: add_files $post_sys_link_gen_xdc"
        add_files $post_sys_link_gen_xdc
      }
  
      # when executed in the non-design environment, read_xdc is same as add_files
      apply_dont_partition $enable_dont_partition $steps_log $output_dir
        
      # -- Create the PR configuration alone with data on where the BD will go --
      set config_name "config_1"
      add_to_steps_log $steps_log "internal step: create_pr_configuration -name $config_name -partitions \[list $ocl_inst_path:$reconfig_module\]"
      create_pr_configuration -name $config_name -partitions [list $ocl_inst_path:$reconfig_module]
      # disable the generation of the cell level checkpoints for RMs during post bitstream 
      set_property AUTO_IMPORT 0 [get_pr_configuration $config_name]
      # disable the generation of wrapper black box checkpoint during post bitstream
      set_property USE_BLACKBOX 0 [get_pr_configuration $config_name]
      add_to_steps_log $steps_log "internal step: set_property PR_CONFIGURATION $config_name \[get_runs impl_1\]"
      set_property PR_CONFIGURATION $config_name [get_runs impl_1]
    }

    add_to_steps_log $steps_log "internal step: source $impl_props_tcl"
    OPTRACE "START" "Source impl_props_tcl" 
    source $impl_props_tcl
    OPTRACE "END" "Source impl_props_tcl" 
    
    if { $return_pre_synth } {
      puts "INFO: return_pre_synth enabled, skip the synthesis and implementation"
      return
    }

   if { $script_only } {
      launch_runs impl_1 -to_step write_bitstream -scripts_only
      create_run_script_map_file "synth" $output_dir
      create_run_script_map_file "impl" $output_dir
      return
    }

    if { [string equal $dsa_platform_state "pre_synth"] } {
      set syn_run_name "synth_1"
    } else {
      set syn_run_name "${reconfig_module}_synth_1"
    }

    # synthesis
    puts "--- DEBUG: set_param general.maxThreads 1"
    set_param general.maxThreads 1

    set user_run_script_switch ""
    if { ![string equal $run_script_map_file ""] } {
      set user_run_script_switch "-custom_script $run_script_map_file"
    }

    set lsf_switch ""
    if { ![string equal $lsf_string ""] } {
      set lsf_switch "-lsf $lsf_string"
    }

    #
    # by default, num_jobs is 0
    add_to_steps_log $steps_log "internal step: launch_runs $syn_run_name -jobs $num_jobs $lsf_switch $user_run_script_switch"
    # The existence of this file while synthesis is running tells
    # HPIKernelCompilerSystemFpga::printStatus_ to produce regular
    # "heartbeat" messages.
    close [open __xocc_running_synthesis__ w]
    OPTRACE "START" "Synthesis" "SYNTH,ROLLUP_1"
    launch_runs $syn_run_name -jobs $num_jobs {*}$lsf_switch {*}$user_run_script_switch
    wait_on_run $syn_run_name
    OPTRACE "END" "Synthesis" 
    file delete __xocc_running_synthesis__

    # unset maxThreads parameter
    puts "--- DEBUG: reset_param general.maxThreads"
    reset_param general.maxThreads

    # generate a resource demand report per ip instance
    generate_resource_report $output_dir $steps_log

    # capture synth reports
    set generated_reports_log [file join $output_dir "generated_reports.log"]
    set report_synth_runs [get_runs -filter {IS_SYNTHESIS==1}]
    add_to_steps_log $steps_log "internal step: log_generated_reports for synthesis '${generated_reports_log}'"
    log_generated_reports $generated_reports_log $report_synth_runs

    if { ![check_synth_runs_status $steps_log] } {
      error2file $cwd "One or more synthesis runs failed during dynamic region dcp generation"
    } 

    # implementation
    if { $return_post_synth || $return_pre_impl } {
      puts "INFO: return_pre_impl or return_post_synth enabled, skip running implementation"
      return
    }

    set_property GEN_FULL_BITSTREAM 0 [get_runs impl_1]
    set to_step_switch "-to_step write_bitstream"
    if { [string equal $link_output_format "dcp"] } {
      set to_step_switch ""
    }

    add_to_steps_log $steps_log "internal step: launch_runs impl_1 $to_step_switch $user_run_script_switch"
    launch_runs impl_1 {*}$to_step_switch {*}$user_run_script_switch
    set run_dir [get_property DIRECTORY [get_runs impl_1]]
    # Note: when run fails, wait_on_run may not raise an error
    if { [catch {wait_on_run impl_1} catch_res] } {
      add_to_steps_log $steps_log "status: fail"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region" $catch_res
    }

    # capture impl reports
    set report_impl_runs [get_runs -filter {IS_IMPLEMENTATION==1}]
    add_to_steps_log $steps_log "internal step: log_generated_reports for implementation '${generated_reports_log}'"
    log_generated_reports $generated_reports_log $report_impl_runs

    set run_status [get_property STATUS [get_runs impl_1]]
    # puts "--- DEBUG: run_status is $run_status"
    if { [string match "*ERROR" $run_status] } {
      add_to_steps_log $steps_log "status: fail ($run_status)"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region, $run_status" 
    }

    # aws dcp support
    # copy the post-route dcp to vivado output directory
    if { [string equal $link_output_format "dcp"] } {
      if { $encrypt_impl_dcp} {
        set routed_dcp [glob -nocomplain "$run_dir/encrypted_routed.dcp"]
      } else {
        set routed_dcp [glob -nocomplain "$run_dir/*_routed.dcp"]
      }
      set out_routed_dcp "$output_dir/routed.dcp"
      if { ![string equal $routed_dcp ""] } {
        # puts "--- DEBUG: file copy -force $routed_dcp $out_routed_dcp"
        file copy -force $routed_dcp $out_routed_dcp
      }
    } else {
      # copy the generated bit files to vivado output dir 
      if { $dsa_uses_pr } {
        # there could be one partial bit and one partial clear bit files.
        # kcu1500 generates both bit files while vcu1525 only generats the partial bit file
        set partial_bit [glob -nocomplain "$run_dir/*_partial.bit"]
        set partial_clear_bit [glob -nocomplain "$run_dir/*_partial_clear.bit"]
        # puts "--- DEBUG: partial_bit is $partial_bit"
        # puts "--- DEBUG: partial_clear_bit is $partial_clear_bit"
  
        if { ![string equal $partial_bit ""] && [file exists $partial_bit] } {
          file copy -force $partial_bit $out_partial_bit
        }
        if { ![string equal $partial_clear_bit ""] && [file exists $partial_clear_bit] } {
          file copy -force $partial_clear_bit $out_partial_clear_bit
        }

      } else {
        # flat flow (i.e. zynq)
        set full_bit [glob -nocomplain "$run_dir/*.bit"]
        if { ![string equal $full_bit ""] && [file exists $full_bit] } {
          file copy -force $full_bit $out_full_bit
        }
      }
    }

    # Copy LTX files up to ipi dir
    set ltx_files [glob -nocomplain "$run_dir/*.ltx"]
    if {[llength $ltx_files] > 0} {
      foreach ltx_file $ltx_files {
        if {[file tail $ltx_file] ne "debug_nets.ltx"} {
          catch {file copy -force $ltx_file $output_dir}
        }
      }
    }
  }; # end single_project_flow_unip
  
  # unified platform support
  proc init_ocl_project_unip {dsa_info config_info clk_info debug_profile_info {is_single_project_flow false}} {
    OPTRACE "START" "Front end project & BD setup" "ROLLUP_1,PROJECT"
    set dsa_dr_bd           [dict get $dsa_info dsa_dr_bd] 
    set dsa_rebuild_tcl     [dict get $dsa_info dsa_rebuild_tcl] 
    set pre_sys_link_tcl    [dict get $dsa_info pre_sys_link_tcl] 
    set post_sys_link_tcl   [dict get $dsa_info post_sys_link_tcl] 
    set user_post_sys_link_tcl [dict get $dsa_info user_post_sys_link_tcl] 
    set synth_xdc           [dict get $dsa_info synth_xdc] 
    set dsa_ip_repo         [dict get $dsa_info dsa_ip_repo] 
    set dsa_ip_cache        [dict get $dsa_info dsa_ip_cache] 
    set dsa_board_repo      [dict get $dsa_info dsa_board_repo] 
    set dsa_board_part      [dict get $dsa_info dsa_board_part] 
    set dsa_bconn_locked    [dict get $dsa_info dsa_bconn_locked]
    set dsa_bconn_unlocked  [dict get $dsa_info dsa_bconn_unlocked]
    set dsa_platform_state  [dict get $dsa_info dsa_platform_state] 
    set dsa_part            [dict get $dsa_info dsa_part]

    # if { $is_single_project_flow } {
    #   set project_name      [dict get $config_info proj_name] 
    # } else {
    #   set project_name      [dict get $config_info synth_proj_name] 
    # }
    set user_ip_repo        [dict get $config_info user_ip_repo] 
    set kernel_ip_dirs      [dict get $config_info kernel_ip_dirs] 
    set install_ip_cache    [dict get $config_info install_ip_cache] 
    set remote_ip_cache     [dict get $config_info remote_ip_cache] 
    set no_ip_cache         [dict get $config_info no_ip_cache] 
    set no_dsa_ip_cache     [dict get $config_info no_dsa_ip_cache] 
    set no_install_ip_cache [dict get $config_info no_install_ip_cache] 
    set ip_cache_report     [dict_get_default $config_info ip_cache_report {}]
    set user_board_repo     [dict get $config_info user_board_repo]
    set user_bconn          [dict get $config_info user_bconn]
    set dr_bd_tcl           [dict get $config_info dr_bd_tcl] 
    set webtalk_flag        [dict get $config_info webtalk_flag] 
    set is_hw_emu           [dict get $config_info is_hw_emu] 
    if { $is_single_project_flow } {
      set project_name      [dict get $config_info proj_name] 
    } else {
      if {$is_hw_emu} {
        set project_name      [dict get $config_info emu_proj_name] 
      } else {
        set project_name      [dict get $config_info synth_proj_name] 
      }
    }
    set design_name         [dict get $config_info design_name]
    set steps_log           [dict get $config_info steps_log] 
    set protocol_checker    [dict get $config_info protocol_checker] 
    set output_dir          [dict get $config_info output_dir] 
    set reconfig_module     [dict get $config_info reconfig_module]

    set kernel_clock_freqs  [dict get $clk_info kernel_clock_freqs]  

    set startdir [pwd]
    global env

    # pre_sys_link_tcl needs to be sourced before creating the project
    if { ![string equal $pre_sys_link_tcl ""] && [file exists $pre_sys_link_tcl] } {
      OPTRACE "START" "Source pre_sys_link Tcl script" 
      puts "--- DEBUG: source $pre_sys_link_tcl"
      add_to_steps_log $steps_log "internal step: source $pre_sys_link_tcl"
      source $pre_sys_link_tcl
      OPTRACE "END" "Source pre_sys_link Tcl script"
    }

    OPTRACE "START" "Create project" 
    # there are two ways of creating project
    #    if user specifies rebuild_tcl, we should source it (soc platforms)
    #    else if user specifies bd, we should create a project and import the bd (pcie platforms)
    if { ![string equal $dsa_rebuild_tcl ""] && [file exists $dsa_rebuild_tcl] } {
      set dsa_prj_dir [file dirname $dsa_rebuild_tcl]
      set ::origin_dir_loc $dsa_prj_dir
      set ::user_project_name $project_name
 
      puts "--- DEBUG: source $dsa_rebuild_tcl to create $project_name project"
      add_to_steps_log $steps_log "internal step: source $dsa_rebuild_tcl"
      if { [catch {source $dsa_rebuild_tcl} catch_res] } {
        error2file $startdir "problem rebuilding project $project_name" $catch_res
      }
    } else {
      # for single project flow, the project has already been created
      if { !$is_single_project_flow } {
        # create the ipiprj project for ocl dcp generation
        puts "--- DEBUG: create_project -part $dsa_part -force $project_name $project_name"
        add_to_steps_log $steps_log "internal step: create_project -part $dsa_part -force $project_name $project_name"
        create_project -part $dsa_part -force $project_name $project_name
      }

      # set a board_part_repo_paths property on current project. $user has higher priority than $dsa (first one wins)
      set_board_repo_paths_property $user_board_repo $dsa_board_repo
      # set the board part
      if {$dsa_board_part ne ""} {
        puts "--- DEBUG: set_property board_part $dsa_board_part \[current_project\]"
        set_property board_part $dsa_board_part [current_project]
      }
 
      # set a board_connections property on current project. $user has higher priority than $dsa_unlocked. $dsa_locked cannot be overwritten (last one wins) 
      set_board_connections_property $dsa_bconn_unlocked $user_bconn $dsa_bconn_locked
    }
    OPTRACE "END" "Create project"

    OPTRACE "START" "Create IP caching environment" 
    # Set this property here to cover both cases above.
    set_property tool_flow SDx [current_project]

    # construct ip_repo_paths with the order below (first one wins)
    #  1. User IP repo from --user_ip_repo_paths
    #  2. User emulation IP repo (i.e. $::env(SDX_EM_REPO)) -- hw_emu only
    #  3. Kernel IP definitions (vpl --iprepo switch value)
    #  4. IP definitions from DSA IP repo
    #  5. IP cache dir from Install area (/proj/xbuilds/2018.2_daily_latest/installs/lin64/SDx/2018.2/data/cache/xilinx)
    #  6. IP cache stored inside DSA
    #  7. $::env(XILINX_SDX)/data/emulation/hw_em/ip_repo  -- hw_emu only
    #  8. $::env(XILINX_VIVADO)/data/emulation/hw_em/ip_repo  -- hw_emu only
    #  9. SDx Specific Xilinx IP repo from install area (/proj/xbuilds/2018.2_daily_latest/installs/lin64/SDx/2018.2/data/ip/)
    # 10. General Xilinx IP repo from install area (/proj/xbuilds/2018.2_daily_latest/installs/lin64/Vivado/2018.2/data/ip/)
    # note: 10 is automatically handled by IP Services as the final fallback, so we don't need to add it explicitly

    # 1. append the user ip repo
    if { $user_ip_repo ne "" } {
      lappend ip_repo_paths {*}$user_ip_repo 
    } 
    # 2. append user emulation ip repo (hw_emu only)
    if { $is_hw_emu && [info exists ::env(SDX_EM_REPO)] } {
      lappend ip_repo_paths $::env(SDX_EM_REPO)
    }
    # 3. append kernel ip repo
    lappend ip_repo_paths {*}$kernel_ip_dirs
    # 4. append DSA ip repo. Append only in hw flows. hw_emu flow uses its own copy of these ip's which are inside $(XILINX_SDX)/data/emulation/hw_em/ip_repo
    if { $dsa_ip_repo ne "" && !$is_hw_emu} {
      lappend ip_repo_paths $dsa_ip_repo 
    }
    # 5. append xilinx ip cache dir from install area
    # e.g. /proj/xbuilds/2017.1_sdx_0420_1/installs/lin64/SDx/2017.1/data/cache/xilinx 
    if { !$no_ip_cache && !$no_install_ip_cache && $install_ip_cache ne "" } {
      lappend ip_repo_paths $install_ip_cache 
    }
    # 6. append DSA ip cache
    if { !$no_ip_cache && !$no_dsa_ip_cache && $dsa_ip_cache ne "" } {
      lappend ip_repo_paths $dsa_ip_cache 
    }
    # for debug and profiling (hw_emu only)
    if { $is_hw_emu } {
      # 7. append SDX specific xilinx emulation ip repo
      if { [info exists ::env(XILINX_SDX)] } {
        lappend ip_repo_paths $::env(XILINX_SDX)/data/emulation/hw_em/ip_repo 
      }
      # 8. append General xilinx emulation ip repo
      if { [info exists ::env(XILINX_VIVADO)] } {
        lappend ip_repo_paths $::env(XILINX_VIVADO)/data/emulation/hw_em/ip_repo 
      }
    }
    # 9. append SDx Specific xilinx ip repo from install area
    if { [info exists ::env(XILINX_SDX)] } {
      lappend ip_repo_paths $::env(XILINX_SDX)/data/ip
    }

    if { $ip_repo_paths ne "" } {
      puts "--- DEBUG: setting ip_repo_paths: $ip_repo_paths"
      set_property ip_repo_paths $ip_repo_paths [current_project] 
      puts "--- DEBUG: update_ip_catalog"
      update_ip_catalog
    }

    # ip caching
    if { $no_ip_cache } { 
      puts "--- DEBUG: config_ip_cache -disable_cache"
      config_ip_cache -disable_cache
    } else {
      if { $remote_ip_cache ne ""} {
        puts "--- DEBUG: config_ip_cache -use_cache_location $remote_ip_cache"
        config_ip_cache -use_cache_location $remote_ip_cache
      } 
      # from nabeel: project level cache became default in 2016.3, no need
      # to explicitly call "config_ip_cache -use_project_cache" in else clause
    }

    OPTRACE "END" "Create IP caching environment"
    OPTRACE "START" "Import / add dynamic bd" 
        
    if { [string equal $dsa_rebuild_tcl ""] || ![file exists $dsa_rebuild_tcl] } {
      # add DR BD from DSA (pcie platforms)
      set rm_switch ""
      if { $is_single_project_flow} {
        set rm_switch "-of_objects [get_reconfig_modules $reconfig_module]"
      }
      puts "--- DEBUG: import_files -norecurse $dsa_dr_bd $rm_switch"
      add_to_steps_log $steps_log "internal step: import_files -norecurse $dsa_dr_bd $rm_switch"
      # we should use import_files to copy the bd file to the local project
      # 1. the temporaray location might be read-only 2. user could potentially delete the temporary location
      import_files -norecurse $dsa_dr_bd {*}$rm_switch
    }

    # get the base file name of $dsa_dr_bd
    set bd_file [file tail $dsa_dr_bd]
    # for soc platform, there is no dr_bd in dsa
    if { ![string equal $dsa_rebuild_tcl ""] && [file exists $dsa_rebuild_tcl] } {
      set bd_file [file tail [lindex [get_files *.bd] 0]]
    }
    OPTRACE "END" "Import / add dynamic bd"
    OPTRACE "START" "Open bd and insert kernels" 

    puts "--- DEBUG: open_bd_design -auto_upgrade \[get_files $bd_file\]"
    add_to_steps_log $steps_log "internal step: open_bd_design -auto_upgrade \[get_files $bd_file\]"
    # open the BD design first, then upgrade IPs to newest version if have new version.
    open_bd_design -auto_upgrade [get_files $bd_file]
    
    set_property synth_checkpoint_mode Hierarchical [get_files $bd_file]
    # note: dr_bd_tcl is generated by system linker
    puts "--- DEBUG: source $dr_bd_tcl"
    add_to_steps_log $steps_log "internal step: source $dr_bd_tcl"
    source $dr_bd_tcl

    puts "--- DEBUG: save_bd_design"
    save_bd_design

    OPTRACE "END" "Open bd and insert kernels"
    OPTRACE "START" "Insert debug / profiling support" 

    # synth_constrs support
    add_xdc_files $synth_xdc $steps_log
    
    # temporary
    # set ips [get_ips -quiet -all -filter "SDX_KERNEL==true"]
    # puts "ips is $ips"
    # puts "--- DEBUG: ip instance properties:"

    #update kernel frequencies provided using --kernel_frequency
    if { $is_hw_emu } {
      if { [catch {update_kernel_clocks $kernel_clock_freqs } catch_res] } {
        error2file $startdir "Could not change the kernel frequencies provided using --kernel_frequency" $catch_res
      }
      if { $protocol_checker } {
        if { [catch { add_protocol_checker_unip $dsa_dr_bd } catch_res] } {
          error2file $startdir "Could not add protocol checkers on kernel boundary" $catch_res
        }
      }
      
      # Add performance monitoring for emulation (different for soc and pcie platforms)
      if { [string equal $dsa_platform_state "pre_synth"] } {
        # soc platforms: monitor DDR banks only
        if { [catch {add_axi_perf_mons_banks $dsa_dr_bd } catch_res] } {
          error2file $startdir "Could not add axi profilers on ddr banks in hw_em" $catch_res
        }
      } else {
        # pcie platforms: monitor CU ports and CUs
        if { [catch {add_axi_perf_mons_ports $dsa_dr_bd } catch_res] } {
          error2file $startdir "Could not add axi profilers on accel ports in hw_em" $catch_res
        }
        if { [catch {add_accel_mons $dsa_dr_bd } catch_res] } {
          error2file $startdir "Could not add accel profilers in hw_em" $catch_res
        }
      }
    }
    
    # Debug/profiling info
    add_to_steps_log $steps_log "internal step: inserting profiling and debug cores"
    # Insert lapc if requested for SDAccel designs
    set debug_info [dict_get_default $debug_profile_info debug {}]
    if { [catch {update_axi_checkers $dsa_dr_bd $is_hw_emu $debug_info} catch_res] } {
      error2file $startdir "Could not add axi protocol checkers into dynamic region" $catch_res
    }

    # Insert profiling (as requested)
    puts "--- DEBUG: inserting profiling cores"
    set profile_info [dict_get_default $debug_profile_info profile {}]
    
    # Insert profiling cores based on compute_unit/port info in profile_info
    # puts "--- DEBUG: profile_info is $profile_info"
    set kernel_debug [dict_get_default $debug_info kernel_debug false]
    if { [catch {update_unified_profiling $profile_info $dsa_dr_bd $is_hw_emu $kernel_debug} catch_res] } {
      error2file $startdir "Profiling not added to dynamic region" $catch_res
    }

    # Insert SystemILA debug core(s) based on compute_unit/port info in debug_info
    puts "--- DEBUG: inserting SystemILA debug cores"
    # puts "--- DEBUG: debug_info is $debug_info"
    if { [catch {insert_chipscope_debug $dsa_dr_bd $is_hw_emu $debug_info} catch_res] } {
      error2file $startdir "Could not add ChipScope ILA to dynamic region" $catch_res
    }

    # Connect compute_unit(s) BSCAN Interface to Debug Bridge
    puts "--- DEBUG: connecting BSCAN interfaces of compute unit(s)"
    # puts "--- DEBUG: debug_info is $debug_info"
    if { [catch {connect_bscan_ports $dsa_dr_bd $is_hw_emu } catch_res] } {
      error2file $startdir "Could not connect BSCAN interfaces of dynamic region to Debug Bridge" $catch_res
    }

    OPTRACE "END" "Insert debug / profiling support"
    OPTRACE "START" "IPI address assignments" 

    # this is needed to generate address_map.xml
    puts "--- DEBUG: assign_bd_address"
    add_to_steps_log $steps_log "internal step: assign_bd_address"
    assign_bd_address

    OPTRACE "END" "IPI address assignments"
    OPTRACE "START" "Validate BD" 

    puts "--- DEBUG: validate_bd_design -force"
    validate_bd_design -force
    OPTRACE "END" "Validate BD" 

    # post_sys_link_tcl needs to be sourced after sourcing dr_bd_tcl
    if { ![string equal $post_sys_link_tcl ""] && [file exists $post_sys_link_tcl] } {
      OPTRACE "START" "Sourcing DSA post_sys_link Tcl script" 
      puts "--- DEBUG: source $post_sys_link_tcl"
      add_to_steps_log $steps_log "internal step: source $post_sys_link_tcl"
      source $post_sys_link_tcl
      # this generates a xdc file _post_sys_link_gen_constrs.xdc

      # bd validation is not needed here. sourcing a post-sys-link tcl hook *could* change the bd, in 
      # which case, it is dsa developer's responsibility to call validation in that tcl hook

      puts "--- DEBUG: save_bd_design"
      save_bd_design

      set post_sys_link_gen_xdc "_post_sys_link_gen_constrs.xdc"
      if { ![file exists $post_sys_link_gen_xdc] } {
        puts "WARNING: the output of $post_sys_link_gen_xdc doesn't exist - $post_sys_link_gen_xdc"
      } else {
        # move the file to output_dir
        if { ![file exists $output_dir/$post_sys_link_gen_xdc] } {
          puts "--- DEBUG: file rename $post_sys_link_gen_xdc $output_dir"
          file rename $post_sys_link_gen_xdc $output_dir
        }
      }
      OPTRACE "END" "Sourcing DSA post_sys_link Tcl script"
    }

    if { ![string equal $user_post_sys_link_tcl ""] && [file exists $user_post_sys_link_tcl] } {
      OPTRACE "START" "Sourcing user post_sys_link Tcl script" 

      puts "--- DEBUG: source $user_post_sys_link_tcl"
      add_to_steps_log $steps_log "internal step: source $user_post_sys_link_tcl"
      source $user_post_sys_link_tcl

      puts "--- DEBUG: validate_bd_design -force"
      validate_bd_design -force

      puts "--- DEBUG: save_bd_design"
      save_bd_design
      OPTRACE "END" "Sourcing user post_sys_link Tcl script"
    }


    # metadata for webtalk
    if { $webtalk_flag ne "" } { 
      puts "--- DEBUG: bd::util_cmd set_bd_source $webtalk_flag \[current_bd_design\]"
      regenerate_bd_layout
      bd::util_cmd set_bd_source $webtalk_flag [current_bd_design]
      save_bd_design
    }

    OPTRACE "START" "Create address map and debug IP profile files" 

    # generate address_map.tcl
    puts "--- DEBUG: writing address_map.xml"
    add_to_steps_log $steps_log "internal step: writing address_map.xml"
    write_addr_map_unip $output_dir

    # generate debug/profile IP file
    # this depends on assign_bd_address, so it has to be called after
    puts "--- DEBUG: writing debug ip"
    write_debug_ip_unip $output_dir

    OPTRACE "END" "Create address map and debug IP profile files"
    OPTRACE "START" "Generate output products" 

    # generate_target is required for write_hwdef
    puts "--- DEBUG: generate_target all \[get_files $bd_file\]"
    add_to_steps_log $steps_log "internal step: generate_target all \[get_files $bd_file\]"
    generate_target all [get_files $bd_file]

    # ip early cache check (if an ip is already generated, this prevents an occ run to be created for that ip)
    if { !$no_ip_cache } { 
      puts "--- DEBUG: config_ip_cache -export \[get_ips -all -of_object \[get_files $bd_file\]\]"
      catch {config_ip_cache -export [get_ips -all -of_object [get_files $bd_file]}
      if { $ip_cache_report ne "" } {
        # Create a single file with all the information correctly formatted as JSON.
        # It would be nice to just have the ::debug::debug_cache_miss build the file,
        # but it only takes one IP at a time. And just appending to a file doesn't add
        # the JSON open and close braces, and separator commas needed. JSON is nice,
        # but not entirely flexible in its application. And this is probably slightly
        # more efficient since we aren't opening and closing the file repeatedly.
        set report_file [open $ip_cache_report "w"]
        puts $report_file "{ \"ips\": \["
        set first_entry true
        foreach file [get_files *.xci] { 
          if {$first_entry} {
            set first_entry false
          } else { 
            puts $report_file ","
          }
          set json_entry [::debug::debug_cache_miss $file -json]
          puts -nonewline $report_file $json_entry
        }
        puts $report_file ""
        puts $report_file "\] }"
      }
    }

    if { [string equal $dsa_platform_state "pre_synth"] } {
      # for SoC platform, create hdf file
      puts "--- DEBUG: write_hwdef -force -file $output_dir/system.hdf"
      add_to_steps_log $steps_log "internal step: write_hwdef -force -file $output_dir/system.hdf"
      write_hwdef -force -file $output_dir/system.hdf

      # for SoC platform, let's create the wrapper
      puts "--- DEBUG: add_files -norecurse \[make_wrapper -top -files \[get_files $bd_file\]\]"
      add_to_steps_log $steps_log "internal step: add_files -norecurse \[make_wrapper -top -files \[get_files $bd_file\]\]"
      add_files -norecurse [make_wrapper -top -files [get_files $bd_file]]
      # for SoC unified platform, skip setting -mode out_of_context because it IS the full design
    } else {
      # in single project flow mode, vivado knows to add --out_of_context to synthesis runs automatically
      if { !$is_single_project_flow } {
        # for PCIE, use BD as the top, do NOT create wrapper since it will
        # introduce another layer in hierarchy
        set bd_base [file root $bd_file]

        # get the bd file base name, assume it is same as the module name
        add_to_steps_log $steps_log "internal step: set_property TOP $bd_base \[current_fileset\]"
        set_property TOP $bd_base [current_fileset]

        # append to "More Options", instead of overwriting
        set more_option [get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]]
        set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value "$more_option -mode out_of_context" -objects [get_runs synth_1]; 
        # puts "--- DEBUG: [get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]]"
      }
    }

    copy_ooc_xdc_files $bd_file $is_hw_emu $kernel_clock_freqs $output_dir

    if { $is_hw_emu } {
      # set new_clk_freq_file "_new_clk_freq"
      set new_clk_freq_file "$output_dir/_new_clk_freq"
      write_orig_clk_freq $new_clk_freq_file $design_name $clk_info err_str
    }

    OPTRACE "END" "Generate output products"

    OPTRACE "END" "Front end project & BD setup"
    # for testing only
    # error2file $startdir "problem initialize syn project" 
  }; # end init_ocl_project_unip

  proc copy_ooc_xdc_files {bd_file is_hw_emu kernel_clock_freqs output_dir} {
    # moved section below from ipirun.tcl to here
    # Copy the OOC constraint files in BD, and add them to the top level design in order for
    # the clock constraints to be applied
    # set_param project.loadTopLevelOOCConstrs 1
    set ooc_xdc_files [get_files -of_object [get_files $bd_file] -norecurse -filter { FILE_TYPE == "XDC" && USED_IN =~ "*out_of_context*" }]
    foreach ooc_xdc_file $ooc_xdc_files {
      if {![string equal $ooc_xdc_file ""] && [file exists $ooc_xdc_file]} {
        set used_in_value [get_property used_in $ooc_xdc_file]
        set xdc_file_copy "[file rootname [file tail $ooc_xdc_file]]_copy.xdc"
        set xdc_file_copy $output_dir/$xdc_file_copy
        # file copy $ooc_xdc_file ./$xdc_file_copy
        file copy $ooc_xdc_file $xdc_file_copy
        if { !$is_hw_emu } { 
          # create a kernel clock constraint for synthesis, and overwrite the default frequency from dsa
          write_user_synth_clock_constraint $xdc_file_copy $kernel_clock_freqs
        } 

        puts "--- DEBUG: add_files $xdc_file_copy -fileset \[current_fileset -constrset\]"
        set xdc_file_obj [add_files $xdc_file_copy -fileset [current_fileset -constrset]]
        puts "--- DEBUG: set_property used_in $used_in_value $xdc_file_obj"
        set_property used_in $used_in_value $xdc_file_obj
        puts "--- DEBUG: set_property processing_order early $xdc_file_obj"
        set_property processing_order "early" $xdc_file_obj
      }
    }
  }

  proc write_addr_map_unip { output_dir } {
    # Note: there is already an open bd design

    # create Address Map file
    set xml_file $output_dir/address_map.xml
    set fp [open $xml_file w] 
    set addr_segs [get_bd_addr_segs -hier]
    # puts "--- DEBUG: current_bd_design: [current_bd_design]"
    # puts "--- DEBUG: addr_segs is $addr_segs"
    puts $fp "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    puts $fp "<xd:addressMap xmlns:xd=\"http://www.xilinx.com/xd\">"
    foreach addr_seg $addr_segs {
      set path [get_property PATH $addr_seg]
      set offset [get_property OFFSET $addr_seg]
      # puts "--- DEBUG: addr_seg: $addr_seg\n\tpath: $path\n\toffset: $offset"
      if {$offset != ""} {
        set range [format 0x%X [get_property RANGE $addr_seg]]
        set high_addr [format 0x%X [expr $offset + $range - 1]]
        set slave [get_bd_addr_segs -of_object $addr_seg]

        if { [regexp {([^/]+)/([^/]+)/([^/]+)$} $path match componentRef addressSpace segment] } {

        } elseif { [regexp {([^/]+)/([^/]+)$} $path match addressSpace segment] }  {
          # In this case, address space is an external interface. For now, 
          # just use addressSpace as componentRef
          set componentRef $addressSpace
        } else {
          puts "warning: path doesn't match the regular expression ($path)"
          continue
        }

        if { [regexp {([^/]+)/([^/]+)/([^/]+)$} $slave match slaveRef slaveMemoryMap slaveSegment] } {
          set slaveIntfPin [get_bd_intf_pins -of_objects $slave]                      
        
        } elseif { [regexp {/([^/]+)/([^/]+)$} $slave match slaveMemoryMap slaveSegment] }  {
          # In this case, address segement is an external interface.
          set slaveIntfPin [get_bd_intf_ports -of_objects $slave]                      
          set slaveRef $slaveMemoryMap
        } else {
           puts "warning: slave doesn't match the regular expression ($slave)"
           continue
        }
        # set slaveIntfPin [get_bd_intf_pins -of_objects $slave]                      

        if { ![regexp {([^/]+)$} $slaveIntfPin match slaveInterface] } {
          puts "warning: slaveIntfPin doesn't match the regular expression ($slaveIntfPin)"
          continue
        }

        puts $fp "  <xd:addressRange xd:componentRef=\"${componentRef}\" xd:addressSpace=\"${addressSpace}\" xd:segment=\"${segment}\" xd:slaveRef=\"${slaveRef}\"\
xd:slaveInterface=\"${slaveInterface}\" xd:slaveSegment=\"${slaveSegment}\" xd:baseAddr=\"${offset}\" xd:range=\"${range}\"/>"                                
      }                                                                             
    }                                                                               
    puts $fp "</xd:addressMap>"    
    close $fp
  }

  proc create_bitstreams_unip { dsa_info config_info clk_info } {
    OPTRACE "START" "Create implementation project" "ROLLUP_AUTO,PROJECT"

    set dsa_part         [dict get $dsa_info dsa_part]
    set dsa_uses_pr      [dict get $dsa_info dsa_uses_pr]
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set link_output_format     [dict get $dsa_info link_output_format]
    set dsa_board_part   [dict get $dsa_info dsa_board_part] 
    set dsa_ip_cache     [dict get $dsa_info dsa_ip_cache] 

    set design_name      [dict get $config_info design_name]
    set project_name     [dict get $config_info impl_proj_name]
    set ocl_dcp          [dict get $config_info ocl_dcp]
    set out_partial_bit  [dict get $config_info out_partial_bitstream]
    set out_partial_clear_bit  [dict get $config_info out_partial_clear_bit]
    set out_full_bit     [dict get $config_info out_full_bitstream]
    set impl_props_tcl   [dict get $config_info impl_props_tcl]
    set kernels          [dict get $config_info kernels]
    set enable_util_report     [dict get $config_info enable_util_report] 
    set script_only      [dict get $config_info generate_script_only] 
    set run_script_map_file    [dict get $config_info run_script_map_file] 
    set steps_log        [dict get $config_info steps_log] 
    set encrypt_impl_dcp [dict get $config_info encrypt_impl_dcp]
    set return_pre_impl  [dict get $config_info return_pre_impl]
    set no_ip_cache      [dict get $config_info no_ip_cache] 
    set no_dsa_ip_cache  [dict get $config_info no_dsa_ip_cache] 
    set output_dir       [dict get $config_info output_dir] 

    # cwd is the ipi directory
    set cwd [pwd]
    set start_time [clock seconds]


    OPTRACE "START" "Update platform checkpoint" 
    update_platform_checkpoint_unip $dsa_info $config_info $clk_info
    OPTRACE "END" "Update platform checkpoint"

    OPTRACE "START" "Create gatelevel project" 
    add_to_steps_log $steps_log "internal step: create_project $project_name $project_name -part $dsa_part -force"
    create_project $project_name $project_name -part $dsa_part -force
    set_property tool_flow SDx [current_project]
    set_property coreContainer.enable 1 [current_project]
    set_property design_mode GateLvl [current_fileset]

    # set the board part. Needed for correct ip cache hits.
    if {$dsa_board_part ne ""} {
      puts "--- DEBUG: set_property board_part $dsa_board_part \[current_project\]"
      set_property board_part $dsa_board_part [current_project]
    }

    OPTRACE "END" "Create gatelevel project"
    OPTRACE "START" "Configure implementation run" 

    # opt_design needs the ip cache for MIG
    if { !$no_ip_cache && !$no_dsa_ip_cache && $dsa_ip_cache ne "" } {
      lappend ip_repo_paths $dsa_ip_cache 
    }
    if { $ip_repo_paths ne "" } {
      puts "--- DEBUG: setting ip_repo_paths: $ip_repo_paths"
      set_property ip_repo_paths $ip_repo_paths [current_project] 
    }


    set updated_full_dcp "$output_dir/updated_full_design.dcp"
    add_to_steps_log $steps_log "internal step: add_files $updated_full_dcp"
    add_files $updated_full_dcp

    if { $script_only } {
      launch_runs impl_1 -to_step write_bitstream -scripts_only
      create_run_script_map_file "impl" $output_dir
      return
    }

    # Note: this must be after set_param project.writeIntermediateCheckpoints
    add_to_steps_log $steps_log "internal step: source $impl_props_tcl"
    source $impl_props_tcl

    OPTRACE "END" "Configure implementation run"
    OPTRACE "END" "Create implementation project"

    # pass -cell to write_bitstream to only generate the partial bit files for pr
    if { $dsa_uses_pr } {
      set more_option [get_property {STEPS.WRITE_BITSTREAM.ARGS.MORE OPTIONS} [get_runs impl_1]]
      set_property -name {STEPS.WRITE_BITSTREAM.ARGS.MORE OPTIONS} -value "$more_option -cell $ocl_inst_path" -objects [get_runs impl_1] 
    }

    # temporary, compiler.returnPreImpl support
    if { $return_pre_impl } {
      puts "INFO: return_pre_impl enabled, skip running implementation"
      return
    }

    # custom run script support
    set user_run_script_switch ""
    if { ![string equal $run_script_map_file ""] } {
      set user_run_script_switch "-custom_script $run_script_map_file"
    }

    # aws dcp support
    # if acceleratorBinaryContent in DSA is set to "dcp", we should skip write_bitstream
    # and use post route dcp as the output
    set to_step_switch "-to_step write_bitstream"
    if { [string equal $link_output_format "dcp"] } {
      set to_step_switch ""
    }

    add_to_steps_log $steps_log "internal step: launch_runs impl_1 $to_step_switch $user_run_script_switch"
    launch_runs impl_1 {*}$to_step_switch {*}$user_run_script_switch
    set run_dir [get_property DIRECTORY [get_runs impl_1]]
    # Note: when run fails, wait_on_run may not raise an error
    if { [catch {wait_on_run impl_1} catch_res] } {
      add_to_steps_log $steps_log "status: fail"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region" $catch_res
    }

    set run_status [get_property STATUS [get_runs impl_1]]
    # puts "--- DEBUG: run_status is $run_status"
    if { [string match "*ERROR" $run_status] } {
      add_to_steps_log $steps_log "status: fail ($run_status)"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region, $run_status" 
    }

    # aws dcp support
    # copy the post-route dcp to ipi directory
    if { [string equal $link_output_format "dcp"] } {
      if { $encrypt_impl_dcp} {
        set routed_dcp [glob -nocomplain "$run_dir/encrypted_routed.dcp"]
      } else {
        set routed_dcp [glob -nocomplain "$run_dir/*_routed.dcp"]
      }
      set out_routed_dcp "$output_dir/routed.dcp"
      if { ![string equal $routed_dcp ""] } {
        # puts "--- DEBUG: file copy -force $routed_dcp $out_routed_dcp"
        file copy -force $routed_dcp $out_routed_dcp
      }
    } else {
      # copy the generated bit files to ipi dir (pwd)
      if { $dsa_uses_pr } {
        set partial_bit [glob -nocomplain "$run_dir/*.bit"]
        set partial_clear_bit [glob -nocomplain "$run_dir/*_clear.bit"]
        # puts "--- DEBUG: partial_bit is $partial_bit"
        # puts "--- DEBUG: partial_clear_bit is $partial_clear_bit"
        if { [llength $partial_bit] == 2 && [llength $partial_clear_bit] == 1} {
          # puts "--- DEBUG: *.bit returns more than one bit files"
          set idx [lsearch $partial_bit $partial_clear_bit]
          set partial_bit [lreplace $partial_bit $idx $idx]
          # puts "--- DEBUG: partial_bit is $partial_bit"
        }
  
        if { ![string equal $partial_bit ""] && [file exists $partial_bit] } {
          file copy -force $partial_bit $out_partial_bit
        }
        if { ![string equal $partial_clear_bit ""] && [file exists $partial_clear_bit] } {
          file copy -force $partial_clear_bit $out_partial_clear_bit
        }
      } else {
        # flat flow (i.e. zynq)
        set full_bit [glob -nocomplain "$run_dir/*.bit"]
        if { ![string equal $full_bit ""] && [file exists $full_bit] } {
          file copy -force $full_bit $out_full_bit
        }
      }
    }

    # Copy all LTX files (except debug_nets.ltx) up to ipi dir
    # ltx files are generated as part write_bitstream
    set ltx_files [glob -nocomplain "$run_dir/*.ltx"]
    if {[llength $ltx_files] > 0} {
      foreach ltx_file $ltx_files {
        if {[file tail $ltx_file] ne "debug_nets.ltx"} {
          catch {file copy -force $ltx_file $output_dir}
        }
      }
    }
  }

  proc update_platform_checkpoint_unip { dsa_info config_info clk_info } {
    set dsa_full_dcp     [dict get $dsa_info dsa_dcp]
    set bb_locked_dcp    [dict get $dsa_info bb_locked_dcp]
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set impl_xdc         [dict get $dsa_info impl_xdc] 
    set dsa_platform_state     [dict get $dsa_info dsa_platform_state] 
    set uses_pr_shell_dcp      [dict get $dsa_info dsa_uses_pr_shell_dcp]
    set pr_shell_dcp     [dict get $dsa_info dsa_pr_shell_dcp]

    set ocl_dcp          [dict get $config_info ocl_dcp]
    set enable_util_report     [dict get $config_info enable_util_report] 
    set script_only      [dict get $config_info generate_script_only] 
    set steps_log        [dict get $config_info steps_log] 
    set enable_dont_partition  [dict get $config_info enable_dont_partition]
    set kernels          [dict get $config_info kernels] 
    set output_dir       [dict get $config_info output_dir] 

    set kernel_clock_freqs     [dict get $clk_info kernel_clock_freqs]  

    set startdir [pwd]    
    set updated_full_dcp "$output_dir/updated_full_design.dcp"

    # for SoC unified platform, skip all the steps below
    # simply copy $ocl_dcp to $updated_full_dcp
    if { [string equal $dsa_platform_state "pre_synth"] } {
      add_to_steps_log $steps_log "internal step: copy $ocl_dcp to $updated_full_dcp"
      file copy -force $ocl_dcp $updated_full_dcp
      return
    }

    # in export_script mode, skip all the steps below, 
    # simply copy $dsa_full_dcp to $updated_full_design.dcp
    if { $script_only } {
      file copy -force $dsa_full_dcp $updated_full_dcp
      return
    }

    # if dsa has both bb_locked dcp and abstract shell (pr shell) dcp 
    # abstract shell takes precedence
    if { $bb_locked_dcp ne "" && $uses_pr_shell_dcp } {
      puts "--- DEBUG: Abstract shell dcp has precedece over BB locked dcp"
      set bb_locked_dcp ""
    }

    # support bb_locked (blackboxed and locked) dcp from DSA
    # enhanced link_design pr flow
    if { $bb_locked_dcp ne "" } {
      add_to_steps_log $steps_log "internal step: add_files $bb_locked_dcp"
      add_files $bb_locked_dcp
      add_to_steps_log $steps_log "internal step: add_files $ocl_dcp"
      add_files $ocl_dcp
      add_to_steps_log $steps_log "internal step: set_property SCOPED_TO_CELLS $ocl_inst_path \[get_files $ocl_dcp\]"
      set_property SCOPED_TO_CELLS $ocl_inst_path [get_files $ocl_dcp]
      
      # impl_constrs support
      add_xdc_files $impl_xdc $steps_log

      # read the _post_sys_link_gen_constrs.xdc generated by sourcing post_sys_link_tcl
      set post_sys_link_gen_xdc "$output_dir/_post_sys_link_gen_constrs.xdc"
      if { [file exists $post_sys_link_gen_xdc] } {
        add_to_steps_log $steps_log "internal step: add_files $post_sys_link_gen_xdc"
        add_files $post_sys_link_gen_xdc
      }

      # when executed in the non-design environment, read_xdc is same as add_files
      apply_dont_partition $enable_dont_partition $steps_log $output_dir
      
      add_to_steps_log $steps_log "internal step: link_design -reconfig_partitions $ocl_inst_path"
      if { [catch {
        link_design -reconfig_partitions $ocl_inst_path
      } catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $startdir "problem linking updated full design" $catch_res
      }

      # create a user clock constraint if set (--kernel_freq support)
      # this tcl procs calls get_clocks, get_pins which required an opened design
      # for 2017.4 move it to after calling link_design
      write_user_impl_clock_constraint $ocl_inst_path $kernel_clock_freqs $steps_log $output_dir
 
      # verify the dont_partition constraints are applied
      # puts "--- DEBUG: verify dont_partition constraints"
      # puts "[get_cells -hier -filter DONT_PARTITION]"
      # report_property [get_cells -hier -filter DONT_PARTITION]

      add_to_steps_log $steps_log "internal step: write_checkpoint $updated_full_dcp"
      if { [catch {write_checkpoint $updated_full_dcp} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $startdir "problem writing out an updated full checkpoint" $catch_res
      }

      if { [catch {close_project} catch_res] } {
        error2file $startdir "problem closing diskless project" $catch_res
      }

      return
    }

    # legacy link_design pr flow 
    ### Open the platform DCP (or the PR shell checkpoint)
    if { $uses_pr_shell_dcp } {
      add_to_steps_log $steps_log "internal step: open_checkpoint $pr_shell_dcp"
      if { [catch {
        open_checkpoint $pr_shell_dcp
      } catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $startdir "problem reading DSA checkpoint" $catch_res
      }
    } else {
      if { [catch {
        add_to_steps_log $steps_log "internal step: add_files $dsa_full_dcp"
        add_files $dsa_full_dcp
        add_to_steps_log $steps_log "internal step: link_design"
        link_design
      } catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $startdir "problem reading DSA checkpoint" $catch_res
      }

      add_to_steps_log $steps_log "internal step: update_design -black_box -cell \[get_cells $ocl_inst_path\]"
      if { [catch {update_design -black_box -cell [get_cells $ocl_inst_path]} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $startdir "problem updating DSA design" $catch_res
      }

      add_to_steps_log $steps_log "internal step: lock_design -level routing"
      if { [catch {lock_design -level routing} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $startdir "problem locking DSA design" $catch_res
      }
    }

    ### Read in the dynamic region DCP
    add_to_steps_log $steps_log "internal step: read_checkpoint -cell $ocl_inst_path $ocl_dcp"
    if { [catch {read_checkpoint -cell $ocl_inst_path $ocl_dcp} catch_res] } {
      add_to_steps_log $steps_log "status: fail"
      error2file $startdir "problem reading dynamic region checkpoint" $catch_res
    }

    # impl_constrs support
    foreach xdc_name [dict keys $impl_xdc] {
      set xdc_info [dict get $impl_xdc $xdc_name]
      set file_path [dict get $xdc_info file_path]
  
      if { ![string equal $file_path ""] && [file exists $file_path] } {
        add_to_steps_log $steps_log "internal step: read_xdc $file_path"
        read_xdc $file_path
      }
    }

    # read the _post_sys_link_gen_constrs.xdc generated by sourcing post_sys_link_tcl
    set post_sys_link_gen_xdc "_post_sys_link_gen_constrs.xdc"
    if { [file exists $post_sys_link_gen_xdc] } {
      add_to_steps_log $steps_log "internal step: read_xdc $post_sys_link_gen_xdc"
      read_xdc $post_sys_link_gen_xdc
    }

    apply_dont_partition $enable_dont_partition $steps_log $output_dir

    # verify the dont_partition constraints are applied
    # puts "--- DEBUG: verify dont_partition constraints"
    # puts "[get_cells -hier -filter DONT_PARTITION]"
    # report_property [get_cells -hier -filter DONT_PARTITION]

    # create a user clock constraint if set (--kernel_freq support)
    write_user_impl_clock_constraint $ocl_inst_path $kernel_clock_freqs $steps_log $output_dir

    add_to_steps_log $steps_log "internal step: write_checkpoint $updated_full_dcp"
    if { [catch {write_checkpoint $updated_full_dcp} catch_res] } {
      add_to_steps_log $steps_log "status: fail"
      error2file $startdir "problem writing out an updated full checkpoint" $catch_res
    }

    if { [catch {close_project} catch_res] } {
      error2file $startdir "problem closing diskless project" $catch_res
    }
  }

  # used by --reuse_impl
  proc create_bitstreams_without_implementation { dsa_info config_info clk_info } {
    set dsa_uses_pr      [dict get $dsa_info dsa_uses_pr]
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set is_unified       [dict get $dsa_info is_unified]
    set parent_rm_inst_path ""
    if { [dict exists $dsa_info parent_rm_instance_path] } {
      set parent_rm_inst_path  [dict get $dsa_info parent_rm_instance_path]
    }

    set design_name      [dict get $config_info design_name]
    set out_partial_bit  [dict get $config_info out_partial_bitstream]
    set out_full_bit     [dict get $config_info out_full_bitstream]
    set steps_log        [dict get $config_info steps_log] 
    set reuse_impl_dcp   [dict get $config_info reuse_impl_dcp] 
    set output_dir       [dict get $config_info output_dir] 
    
    # open reuse_impl_dcp and run write_bistream
    # open_checkpoint creates a diskless project
    add_to_steps_log $steps_log "internal step: open_checkpoint $reuse_impl_dcp"
    open_checkpoint $reuse_impl_dcp

    # Make sure the design is fully routed
    if { ![report_route_status -boolean_check ROUTED_FULLY] } {
      puts "ERROR: The supplied design '$reuse_impl_dcp' is not fully routed. Please supply a routed design when using the --reuse_impl option."
      add_to_steps_log $steps_log "status: fail"
      set startdir [pwd]
      error2file $startdir "improper dcp supplied (not routed)"
      #return false
    }

    # timing check and frequency scaling
    set is_in_run false
    if { ![report_timing_and_scale_freq $ocl_inst_path $is_unified $design_name $output_dir $clk_info $is_in_run] } {
      return false
    }

    set out_bit $out_full_bit
    set cell_switch ""
    if { $dsa_uses_pr } {
      set out_bit $out_partial_bit
      set cell_switch "-cell $ocl_inst_path"
      if { $parent_rm_inst_path ne "" } {
        set cell_switch "-cell $parent_rm_inst_path"
      }
    }

    add_to_steps_log $steps_log "internal step: write_bitstream $cell_switch -force $out_bit"
    write_bitstream {*}$cell_switch -force $out_bit
  }

  # used to add synth_constrs and impl_constrs files in dsa
  proc add_xdc_files {xdc_dict steps_log} { 
    foreach xdc_name [dict keys $xdc_dict] {
      set xdc_info [dict get $xdc_dict $xdc_name]
      set file_path [dict get $xdc_info file_path]
      set used_in [dict get $xdc_info used_in]
      set processing_order [dict get $xdc_info processing_order]
  
      if { [string equal $file_path ""] || ![file exists $file_path] } {
        continue;
      }

      puts "--- DEBUG: add_files $file_path -fileset \[current_fileset -constrset\]"
      add_to_steps_log $steps_log "internal step: add_files $file_path -fileset \[current_fileset -constrset\]"
      add_files $file_path -fileset [current_fileset -constrset]
      if {$used_in ne ""} {
        puts "--- DEBUG: set_property USED_IN \"$used_in\" \[get_files $file_path\]"
        set_property USED_IN $used_in [get_files $file_path]
      }
      if {$processing_order ne ""} {
        puts "--- DEBUG: set_property PROCESSING_ORDER \"$processing_order\" \[get_files $file_path\]"
        set_property PROCESSING_ORDER $processing_order [get_files $file_path]
      }
      # puts "--- DEBUG: processing order for $file_path: [get_property processing_order [get_files $file_path]]"
    }
  }

  proc generate_kernel_inst_path_data { steps_log output_dir} { 
    add_to_steps_log $steps_log "internal step: creating $output_dir/_kernel_inst_paths.dat"
    set outfile [open "$output_dir/_kernel_inst_paths.dat" w]
    puts $outfile "# This file was automatically generated by SDx"
    puts $outfile "version: 1.0"

    # bd is already open at this point, verify with get_bd_design or current_bd_design
    # puts "--- DEBUG: current_bd_design:\n[join [current_bd_design] \n]"

    set bd_name [get_property name [current_bd_design]]
    # set ips [get_ips -quiet -all -filter "SDX_KERNEL==true"]
    # puts "ips: $ips"
    # puts "--- DEBUG: ip instance properties:"
    # report_property $ips

    set instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    # puts "--- DEBUG: bd cells: $instances:"
    if { [llength $instances] > 0 } { 
      foreach instance $instances {
        # $instance returns "/OCL_Region_0/adder_stage_cu0"
        # we need to prepend the wrapper and bd name
        # puts "--- DEBUG: instance properties:"
        # report_property $instance
        # get the ip component name (xilinx.com:hls:vadd:1.0)
        set vlnv [get_property VLNV $instance]
        # we are only interested in the "name" portion
        set vlnv_list [split $vlnv ":"]
        set name [lindex $vlnv_list 2]
        
        set kernel_inst [get_property SDX_KERNEL_INST $instance]
        set kernel_type [get_property SDX_KERNEL_TYPE $instance]
        puts "--- DEBUG: bd cell: $instance; kernel_inst: $kernel_inst; kernel_type: $kernel_type"
        set instance "/${bd_name}_wrapper/${bd_name}_i$instance"
        puts $outfile "$name:"
        puts $outfile "   instance path: $instance"
        puts $outfile "   type: $kernel_type"
      }
    }

    close $outfile
  }

  # return false if any run fails
  proc check_synth_runs_status { steps_log } {
    # check for any run failure
    # and write the "cookie file" for Dennis' messaging support
    set any_run_fail false
    set runs [get_runs -filter {IS_SYNTHESIS == 1}]
    puts "--- DEBUG: get_filesets: [get_filesets]"
    foreach _run $runs {
      set run_name [get_property NAME $_run]
      # puts "--- DEBUG: run: $run_name"
      set run_status [get_property STATUS $_run]
      set run_dir [get_property DIRECTORY $_run]
      set run_fileset [get_property SRCSET $_run]
      # puts "--- DEBUG: run_fileset: $run_fileset"

      # having a run returned by get_runs does NOT guarantee the run dir would exist
      if { ![file exists $run_dir] } {
        puts "--- DEBUG: the run directory for run '$run_name' doesn't exist"
        continue;
      }

      add_to_steps_log $steps_log "internal step: launched run $run_name"

      # generate the cookie file for Dennis' messaging support
      set cookie_file $run_dir/.xocc_runmsg.txt
      set outfile [open $cookie_file w]
      
      # single project flow, the "top" level synthesis run is not synth_1, it is <rm>_synth_1
      # it is associated with reconfig module
      set fs_obj [get_filesets $run_fileset]
      # puts "--- DEBUG: fs_obj is '$fs_obj'"
      if { $fs_obj == "" } {
        puts $outfile "Compiling (reconfig module level synthesis checkpoint) dynamic region"
        continue
      }

      # TODO: hard-coded "synth_1"
      if { [string equal $run_name "synth_1"] } {
        puts $outfile "Compiling (top level synthesis checkpoint) dynamic region"
      } else {
        # set ip_file [get_files -norecurse -of_objects [get_fileset $run_fileset]]
        set ip_file [get_files -norecurse -of_objects $fs_obj]
        # puts "--- DEBUG: ip_file: $ip_file"
        # ip_top is only applicable to ip file type
        set file_type [get_property FILE_TYPE $ip_file]
        set ip_top ""
        if { [string equal -nocase $file_type "ip"] } {
          set ip_top [get_property IP_TOP $ip_file] 
          # puts "--- DEBUG: ip_top: $ip_top"
        }

        puts $outfile "Compiling (synthesis checkpoint) kernel/IP: $ip_top"
      }
      puts $outfile "Log file: $run_dir/runme.log"
      close $outfile

      # puts "--- DEBUG: run '$_run' has status '$run_status'"
      if { [string equal $run_status "synth_design ERROR"] } {
        puts "ERROR: run '$_run' failed, please look at the run log file '$run_dir/runme.log' for more information"
        add_to_steps_log $steps_log "status: fail"
        add_to_steps_log $steps_log "log: $run_dir/runme.log"
        # set any_run_fail true
        return false
      }
      if { [string equal $run_status "Scripts Generated"] } {
        puts "ERROR: run '$_run' couldn't start because one or more of the prerequisite runs failed"
        # set any_run_fail true
        return false
      }
    }
    return true
  }

  proc report_utilization_drc_synth { dsa_vbnv utilization config_info} {
    set enable_util_report  [dict get $config_info enable_util_report] 
    set threshold   [dict get $config_info utilization_threshold] 
    set kernels     [dict get $config_info kernels] 
    set steps_log   [dict get $config_info steps_log] 
    set output_dir  [dict get $config_info output_dir] 

    set availluts   [dict get $utilization luts]
    set availregisters      [dict get $utilization registers]
    set availbrams  [dict get $utilization brams]
    set availdsps   [dict get $utilization dsps]
    set startdir [pwd]

    if { $enable_util_report } {
      puts "Post-synthesis utilization DRC check..."
      puts "available resources:" 
      puts "   luts      : $availluts"
      puts "   registers : $availregisters"
      puts "   brams     : $availbrams"
      puts "   dsps      : $availdsps"

      # get the utilization numbers for dynamic region
      set ocl_utils [get_utilization]
    
      # compare the utilization with ones from DSA
      foreach util $ocl_utils {
        # puts "demand utilization is $util"
        set utilspec [split $util ":"]
        # puts "[lindex $utilspec 0] [lindex $utilspec 1] [lindex $utilspec 2]"
        if {[string equal -nocase [lindex $utilspec 0] "LUT"]} {
          set luts [lindex $utilspec 1]
        }
        if {[string equal -nocase [lindex $utilspec 0] "REG"]} {
          set registers [lindex $utilspec 1]
        }
        if {[string equal -nocase [lindex $utilspec 0] "BRAM"]} {
          set brams [lindex $utilspec 1]
        }
        if {[string equal -nocase [lindex $utilspec 0] "DSP"]} {
          set dsps [lindex $utilspec 1]
        }
      } 
      puts "required resources:"
      puts "   luts      : $luts"
      puts "   registers : $registers"
      puts "   brams     : $brams"
      puts "   dsps      : $dsps"
    
      # if dsa doesn't contains utilization data, the avilable resource number would be set to -1
      if { $availluts == -1 || $availregisters == -1 || $availbrams == -1 || $availbrams == -1 } {
        puts "WARNING: There is no resource utilization data in DSA, utilization DRC is skipped"
      }

      if { $availluts != -1 && $luts >= $threshold * $availluts} {
        warning2file $startdir "CRITICAL WARNING: The available LUTs may not be sufficient to accommodate the kernels"
        if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-04 -d $luts -d $availluts -f $threshold }
      }
      if { $availregisters != -1 && $registers >= $threshold * $availregisters} {
        warning2file $startdir "CRITICAL WARNING: The available Registers may not be sufficient to accommodate the kernels"
        if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-03 -d $registers -d $availregisters -f $threshold }
      }
      if { $availbrams != -1 && $brams >= $threshold * $availbrams} {
        warning2file $startdir "CRITICAL WARNING: The available BRAMs may not be sufficient to accommodate the kernels"
        if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-02 -d $brams -d $availbrams -f $threshold }
      }
      if { $availdsps != -1 && $dsps >= $threshold * $availdsps} {
        warning2file $startdir "CRITICAL WARNING: The available DSPs may not be sufficient to accommodate the kernels"
        if {[is_drcv]} { ::drcv::create_violation ACCELERATOR-FIT-01 -d $dsps -d $availdsps -f $threshold }
      }
    
      # generate the utilizaiton reports, one for each kernel
      set sdx_util_string ""
      # puts "--- DEBUG:  generating kernel utilizaiton reports after dynamic region dcp synthesis"
      foreach kernel_inst [get_cells -hier -filter "SDX_KERNEL==true"] {
        if { ![string equal $kernel_inst ""] } {
          puts "--- DEBUG: kernel instance is $kernel_inst"
          # report_property $kernel_inst
          # get the kernel name (for hls kernel, the orig_ref_name seems to be the kernel name) 
          set kernel [get_property ORIG_REF_NAME $kernel_inst]

          # vadd_cu0/inst
          set ki_split [split $kernel_inst "/"]
          # assume the second to the last element is the kernel instance name (i.e. "mmult_cu1")
          # this is not reliable, but couldn't figure out a better way
          set kernel_inst_base [lindex $ki_split end-1]

          set sdx_util_string "$sdx_util_string $kernel:$kernel_inst:$kernel_inst_base"
        }
      }

      if {$sdx_util_string ne ""} {
        add_to_steps_log $steps_log "internal step: report_sdx_utilization -kernels \"$sdx_util_string\" -file \"$output_dir/kernel_util_synthed.rpt\" -name kernel_util_synthed"
        report_sdx_utilization -kernels "$sdx_util_string" -file "$output_dir/kernel_util_synthed.rpt" -name kernel_util_synthed
      }
    } else {
      puts "INFO: post-synthesis utilization DRC check skipped"
    }
  }

  proc create_run_script_map_file { run_type output_dir {kernels ""} } {
    # get all the kernels
    if { $kernels eq "" && [string equal $run_type "synth"] } {
      set instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
      # puts "--- DEBUG: bd cells: $instances:"
      if { [llength $instances] > 0 } { 
        foreach instance $instances {
          # $instance returns "/OCL_Region_0/adder_stage_cu0"
          # get the ip component name (xilinx.com:hls:vadd:1.0)
          set vlnv [get_property VLNV $instance]
          # we are only interested in the "name" portion
          set vlnv_list [split $vlnv ":"]
          set name [lindex $vlnv_list 2]
          lappend kernels $name
        }
      }
    }
    puts "--- DEBUG: create_run_script_map_file: kernels: $kernels"

    # the cwd is "ipi"
    set file_exist [file exists "$output_dir/run_script_map.dat"]
    set outfile [open "$output_dir/run_script_map.dat" a+]
    
    # header
    if { !$file_exist} {
      puts $outfile "#"
      puts $outfile "# Run script mapping file created by SDx"
      puts $outfile "#"
      puts $outfile "# This is the template file for user to use custom script feature"
      puts $outfile "# Format: <run name>: <custom script>"
      puts $outfile "# Usage:"
      puts $outfile "#   User can modify this file directly, to specify a custom script for a particular run,"
      puts $outfile "#   first find the entry below that matches the run name, uncomment it, replace the default"
      puts $outfile "#   run script with the *absolute* path to the custom script"
      puts $outfile "#   note: do NOT use the original (default) run script as the custom script"
      puts $outfile "# Note: if the custom script doesn't exist, it will be ignored by vivado"
    }

    # <run name> : <run driver script>
    if { [string equal $run_type "synth"] } { 
      set runs [get_runs -filter {IS_SYNTHESIS == 1}]
      puts $outfile ""
      puts $outfile "# ################"
      puts $outfile "# Synthesis runs"
      puts $outfile "# ################"
    } else {
      set runs [get_runs -filter {IS_IMPLEMENTATION == 1}]
      puts $outfile ""
      puts $outfile "# #################"
      puts $outfile "# Implmentation runs"
      puts $outfile "# #################"
    }

    # group the runs, list the kernel ooc runs first
    # for synthesis, there are three groups - top level, kernel ooc, other ip ooc
    set top_level ""
    set kernel_ooc ""
    set other_ooc ""
    foreach _run $runs {
      set run_name [get_property NAME [get_runs $_run]]
      if { [string equal $run_name "synth_1"] || [string equal $run_name "impl_1"] } {
        lappend top_level $_run
        continue;
      } 
     
      set kernel_ooc_run_found false
      foreach _kernel $kernels {
        if { [string match "*_${_kernel}_*" $run_name] } {
          lappend kernel_ooc $_run
          set kernel_ooc_run_found true
          break;
        }
      }
      if { $kernel_ooc_run_found } {
        continue;
      }
      
      lappend other_ooc $_run
    }

    # top level runs, i.e. synth_1 or impl_1
    if { [llength $top_level] > 0 } {
      puts $outfile "#"
      puts $outfile "# top level runs"
      puts $outfile "# ---------------------------------------"
    }

    foreach _run $top_level {
      set run_dir [get_property DIRECTORY [get_runs $_run]]
      set run_name [get_property NAME [get_runs $_run]]
      # get the run driver script
      set run_script [glob -nocomplain "$run_dir/*.tcl"]

      puts $outfile ""
      puts $outfile "# $run_name: $run_script"
    }

    # kernel ooc runs
    if { [llength $kernel_ooc] > 0 } {
      puts $outfile "#"
      puts $outfile "# kernel ooc runs"
      puts $outfile "# ---------------------------------------"
    }

    foreach _run $kernel_ooc {
      set run_dir [get_property DIRECTORY [get_runs $_run]]
      set run_name [get_property NAME [get_runs $_run]]
      # get the run driver script
      set run_script [glob -nocomplain "$run_dir/*.tcl"]

      if { $run_script ne ""} { 
        puts $outfile ""
        puts $outfile "# $run_name: $run_script"
      }
    }

    # other ooc runs (supporting ips)
    if { [llength $other_ooc] > 0 } {
      puts $outfile "#"
      puts $outfile "# supporting ip ooc runs"
      puts $outfile "# ---------------------------------------"
    }

    foreach _run $other_ooc {
      set run_dir [get_property DIRECTORY [get_runs $_run]]
      set run_name [get_property NAME [get_runs $_run]]
      # get the run driver script
      set run_script [glob -nocomplain "$run_dir/*.tcl"]

      if { $run_script ne ""} { 
        puts $outfile ""
        puts $outfile "# $run_name: $run_script"
      }
    }

    close $outfile
  }
  
  proc add_to_steps_log { steps_log content {indent "   "} } {
    if { [catch {set outfile [open $steps_log a+]} catch_res] } {
      puts "--- DEBUG: problem opening file $steps_log: $catch_res"
    }

    if { [string match "internal step:*" $content] } {
      puts $outfile "${indent}-----------------------"
      puts $outfile "${indent}$content"
    
      # get current timestamp
      set systemTime [clock seconds]
      puts $outfile "${indent}timestamp: [clock format $systemTime -format {%d %B %Y %H:%M:%S}]"
    } else {
      puts $outfile "${indent}$content"
    }

    close $outfile
  }

  proc create_ocl_dcp {dsa_info utilization config_info} {
    #set start_time [clock seconds]
    set dsa_vbnv    [dict get $dsa_info dsa_vbnv]

    set ocl_dcp     [dict get $config_info ocl_dcp] 
    set kernels     [dict get $config_info kernels] 
    set enable_util_report  [dict get $config_info enable_util_report] 
    set script_only [dict get $config_info generate_script_only] 
    set run_script_map_file [dict get $config_info run_script_map_file] 
    set num_jobs    [dict get $config_info num_jobs] 
    set lsf_string  [dict get $config_info lsf_string] 
    set steps_log   [dict get $config_info steps_log] 
    set synth_props_tcl      [dict get $config_info synth_props_tcl] 
    set output_dir  [dict get $config_info output_dir]  

    set startdir [pwd]

    # set maxThread parameter to 1
    # note this thread is different from job. You can specify how many jobs to
    # launch at the same time for launch_runs. But for each job, synthesis can
    # start more than one threads (up to 8). If you set the jobs to 8, it could 
    # start 8*8=64 threads which takes a huge amount of memory resources
    puts "--- DEBUG: set_param general.maxThreads 1"
    set_param general.maxThreads 1

    # For CR-990048, see if the run is set to use OOC.
    set more_option [get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]]
    set before_more_find [string first "-mode out_of_context" $more_option]

    # source synth_props_tcl file if it exists
    if { ![string equal $synth_props_tcl ""] && [file exists $synth_props_tcl] } {
      OPTRACE "START" "Source synth_props_tcl" 
      add_to_steps_log $steps_log "internal step: source $synth_props_tcl"
      source $synth_props_tcl
      OPTRACE "END" "Source synth_props_tcl" 
    }

    # Now, for CR-990048, see if the run has been changed to no longer use OOC,
    # and add it back in, if necessary. We append, instead of overwriting, to
    # keep the user's settings which were applied above, but may have as a side
    # effect, removed the OOC setting. This can happen if the synth_props_tcl
    # does something like change the strategy, which by default clears "More Options".
    set more_option [get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]]
    if {$before_more_find != -1 && [string first "-mode out_of_context" $more_option] == -1} {
      set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value "$more_option -mode out_of_context" -objects [get_runs synth_1]; 
    }

    if { $script_only } {
      launch_runs synth_1 -scripts_only
      create_run_script_map_file "synth" $output_dir $kernels
      return;
    }

    # custom run script support
    set user_run_script_switch ""
    if { ![string equal $run_script_map_file ""] } {
      set user_run_script_switch "-custom_script $run_script_map_file"
    }
    set lsf_switch ""
    if { ![string equal $lsf_string ""] } {
      set lsf_switch "-lsf $lsf_string"
    }
    # by default, num_jobs is 0
    add_to_steps_log $steps_log "internal step: launch_runs synth_1 -jobs $num_jobs $lsf_switch $user_run_script_switch"
    # The existence of this file while synthesis is running tells
    # HPIKernelCompilerSystemFpga::printStatus_ to produce regular
    # "heartbeat" messages.
    close [open __xocc_running_synthesis__ w]
    OPTRACE "START" "Synthesis" "SYNTH,ROLLUP_1"
    launch_runs synth_1 -jobs $num_jobs {*}$lsf_switch {*}$user_run_script_switch
    wait_on_run synth_1
    OPTRACE "END" "Synthesis"
    file delete __xocc_running_synthesis__
    

    OPTRACE "START" "stitch_dcp" "PROJECT"
    # unset maxThreads parameter
    puts "--- DEBUG: reset_param general.maxThreads"
    reset_param general.maxThreads

    if { ![check_synth_runs_status $steps_log] } {
      error2file $startdir "One or more synthesis runs failed during dynamic region dcp generation"
    }  

    add_to_steps_log $steps_log "internal step: open_run synth_1 -name synth_1"
    open_run synth_1 -name synth_1
    send_msg_id {101-1} {status} {Linking the synthesized kernels: calling write_checkpoint}

    add_to_steps_log $steps_log "internal step: write_checkpoint $ocl_dcp -force"
    write_checkpoint $ocl_dcp -force
    send_msg_id {101-1} {status} {Linking the synthesized kernels: calling report_utilization_drc_synth}
    
    OPTRACE "END" "stitch_dcp"
    OPTRACE "START" "stitch_report_utilization" "REPORT"
    report_utilization_drc_synth $dsa_vbnv $utilization $config_info

    send_msg_id {101-1} {status} {Linking the synthesized kernels: report_utilization_drc_synth complete}
    OPTRACE "END" "stitch_report_utilization"

    #set run_time [expr [clock seconds] - $start_time]
    #puts "PROFILE:create_ocl_dcp took $run_time seconds"
    
  }; # end create_ocl_dcp

  # used for both unified platforms and non-unified platforms
  proc write_sdx_tcl_hooks {dsa_info config_info clk_info} {
    set steps_log        [dict get $config_info steps_log] 

    add_to_steps_log $steps_log "internal step: creating sdx tcl hooks for implementation run"
    write_sdx_pre_init_hook $config_info
    write_sdx_post_init_hook $dsa_info $config_info $clk_info 
    write_sdx_pre_opt_hook $config_info $dsa_info
    write_sdx_post_opt_hook $config_info $dsa_info
    write_sdx_pre_place_hook $dsa_info $config_info $clk_info 
    write_sdx_post_place_hook $config_info 
    write_sdx_post_route_hook $dsa_info $config_info $clk_info 
  }

  proc write_sdx_pre_init_hook { config_info } {
    set scripts_dir      [dict get $config_info scripts_dir] 
    set local_dir        [dict get $config_info local_dir] 
    global vivado_error_file
    global vivado_warn_file

    set sdx_pre_init_tcl "$scripts_dir/_sdx_pre_init.tcl"
    set outfile [open $sdx_pre_init_tcl w]
    # puts $outfile "puts \"sourcing _sdx_pre_init.tcl\""
    puts $outfile "# This file was automatically generated by SDx"
    puts $outfile "set vivado_error_file $vivado_error_file"
    puts $outfile "set vivado_warn_file $vivado_warn_file"
    puts $outfile ""

    # import ocl_util::* tcl procs so that 'ocl_util::' prefix is not needed
    # puts $outfile "source [ dict get [ info frame 0 ] file ]"
    # to increase the portability, we copy ocl_util to local (ipi directory)
    puts $outfile "source ../../../$local_dir/ocl_util.tcl"
    puts $outfile "namespace import ocl_util::*"
    # puts $outfile "# get_script_dir returns [get_script_dir]"
    puts $outfile ""
    puts $outfile "set _is_sdx_post_route_run false"
    puts $outfile ""

    close $outfile
  }

  # --kernel_frequency support for implementation (i.e. adding clock constraints)
  # for single project flow only
  proc write_sdx_post_init_hook { dsa_info config_info clk_info } {
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set steps_log        [dict get $config_info steps_log] 
    set scripts_dir      [dict get $config_info scripts_dir] 
    set output_dir       [dict get $config_info output_dir]  
    set kernel_clock_freqs     [dict get $clk_info kernel_clock_freqs]  

    set sdx_post_init_tcl "$scripts_dir/_sdx_post_init.tcl"
    set outfile [open $sdx_post_init_tcl w]
    puts $outfile "# This file was automatically generated by SDx"
    puts $outfile "write_user_impl_clock_constraint \"$ocl_inst_path\" \"$kernel_clock_freqs\" \"\" \"../../../$output_dir\"" 

    close $outfile
  }

  proc write_sdx_pre_opt_hook { config_info dsa_info } {
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set scripts_dir      [dict get $config_info scripts_dir] 
    # failfast_config is only available for unified platform
    set failfast_config ""
    if { [dict exists $config_info failfast_config] } {
      set failfast_config  [dict get $config_info failfast_config]  
    }

    set sdx_pre_opt_tcl "$scripts_dir/_sdx_pre_opt.tcl"
    set outfile [open $sdx_pre_opt_tcl w]
    if { [dict exists $failfast_config pre_opt_design] } {
      set failfast_args [dict get $failfast_config pre_opt_design]
      # TODO: this is not needed
      if { [llength $failfast_args] == 0} {
        set failfast_args ""
      }
      # added on 4/9/2018 - to support macro expansion for reporting
      report_failfast_helper $config_info $dsa_info $failfast_args $outfile
    }
    
    close $outfile
  }

  ## helper for failfast macro expansion
  proc report_failfast_helper {config_info dsa_info failfast_args outfile} {
      # added on 4/9/2018 - to support macro expansion for reporting
      if { [string equal $failfast_args "__OCL_TOP__"] } {
        set ocl_inst_path    [dict get $dsa_info ocl_region]
        # If the ocl_region is empty (SoC), then drop the -pblock and -cell
        if { [string equal $ocl_inst_path ""] } {
          puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast -detailed_report full.postopt -file full.postopt.failfast.rpt} _error\]} {"
          puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
          puts $outfile "}"
        } else {
          puts $outfile "set oclPblock \[get_pblocks -quiet -filter {PARENT==ROOT && EXCLUDE_PLACEMENT} -of \[get_cells $ocl_inst_path/*\]\] "
          puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast -detailed_report $ocl_inst_path.postopt -file $ocl_inst_path.postopt.failfast.rpt -pblock \$oclPblock -cell $ocl_inst_path} _error\]} {"
          puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
          puts $outfile "}"
        }
      } elseif { [string equal $failfast_args "__SLR__"] } {
        puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast -detailed_report bySLR.postplace -file bySLR.postplace.failfast.rpt -by_slr} _error\]} {"
        puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
        puts $outfile "}"
      } elseif { [string equal $failfast_args "__KERNEL_NAMES__"] } {
        puts $outfile "foreach kernel_inst \[get_cells -hier -filter \"SDX_KERNEL==true\"\] {"
        # get the kernel name (for hls kernel, the orig_ref_name seems to be the kernel name) 
        puts $outfile "  set kernel_name \[get_property ORIG_REF_NAME \$kernel_inst\]"
        puts $outfile "  set oclPblock \[get_pblocks -quiet -filter {PARENT==ROOT && EXCLUDE_PLACEMENT} -of \[get_cells \$kernel_inst\]\] "
        puts $outfile "  # Skip if oclPblock is empty, SoC Platforms will match this criteria"
        puts $outfile "  if {!\[string equal \$oclPblock \"\"\]} {"
        puts $outfile "    if {\[catch {::tclapp::xilinx::designutils::report_failfast -show_resource -detailed_report \$kernel_name.postsynth -file \$kernel_name.postsynth.failfast.rpt -cell \$kernel_inst -pblock  \$oclPblock} _error\]} {"
        puts $outfile "      puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
        puts $outfile "    }"
        puts $outfile "  }"
        puts $outfile "}"
      } else {
        puts $outfile "if {\[catch {::tclapp::xilinx::designutils::report_failfast $failfast_args} _error\]} {"
        puts $outfile "  puts \"The report_failfast command failed with message '\${_error}', the flow will continue but this report will be missing.\""
        puts $outfile "}"
      }
    }

  proc write_sdx_post_opt_hook { config_info dsa_info} {
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set scripts_dir      [dict get $config_info scripts_dir] 
    # failfast_config is only available for unified platform
    set failfast_config ""
    if { [dict exists $config_info failfast_config] } {
      set failfast_config  [dict get $config_info failfast_config]  
    }

    set sdx_post_opt_tcl "$scripts_dir/_sdx_post_opt.tcl"
    set outfile [open $sdx_post_opt_tcl w]
    if { [dict exists $failfast_config post_opt_design] } {
      set failfast_args [dict get $failfast_config post_opt_design]
      if { [llength $failfast_args] == 0} {
        set failfast_args ""
      }
      # added on 4/9/2018 - to support macro expansion for reporting
      report_failfast_helper $config_info $dsa_info $failfast_args $outfile
    }
    
    close $outfile
  }

  proc write_sdx_pre_place_hook { dsa_info config_info clk_info } {
    set ocl_inst_path          [dict get $dsa_info ocl_region]
    set dsa_dcp                [dict get $dsa_info dsa_dcp]
    set parent_rm_inst_path ""
    if { [dict exists $dsa_info parent_rm_instance_path] } {
      set parent_rm_inst_path  [dict get $dsa_info parent_rm_instance_path]
    }

    set xocc_optimize_level    [dict get $config_info xocc_optimize_level]
    set scripts_dir            [dict get $config_info scripts_dir] 

    set lock_slack_threshold   [dict get $clk_info lock_slack_threshold]

    set is_xpr [expr {$parent_rm_inst_path ne ""}]

    # write the kernel clock info file for Steven Li
    set sdx_pre_place_tcl "$scripts_dir/_sdx_pre_place.tcl"
    set outfile [open $sdx_pre_place_tcl w]
    # puts $outfile "puts \"sourcing _sdx_pre_place.tcl\""
    puts $outfile "# This file was automatically generated by SDx"

    # move post_init tcl hook to here
    puts $outfile "set xocc_optimize_level $xocc_optimize_level"
    puts $outfile "set_property SEVERITY {Warning} \[get_drc_checks HDPR-5\]"
    # CR 955574 - Turn off BUFG insertion during opt_design
    puts $outfile "set_param logicopt.enableBUFGinsertHFN 0"
    puts $outfile ""

    # expanded PR specific operations (not applicable for unified platform)
    if { $is_xpr } { 
      set is_incr_flow [dict get $config_info is_incr_flow]
      # move pre_place tcl hook here
      if { $is_incr_flow } {
        puts $outfile ""
        puts $outfile "read_checkpoint -incremental { ../../../$dsa_dcp }"
      }

      set enable_lock_crit_insts [dict get $config_info enable_lock_crit_insts]
      if { $enable_lock_crit_insts } {
        # for xpr, we need to execute the following tcl code (from Steven) to lock down
        # critical instances (rci stands for readcheckpoint -incremental)
        puts $outfile ""
        puts $outfile "# lock down critical instances"
        # puts $outfile "puts \"lock down critical instance\""
        puts $outfile "lock_crit_cells ../../../$dsa_dcp $lock_slack_threshold" 
        puts $outfile "if { \[get_param project.writeIntermediateCheckpoints\] } {"
        puts $outfile "  write_checkpoint xcl_design_wrapper_post_rci.dcp" 
        puts $outfile "}"
      } else {
        puts "INFO: locking down critical instances is disabled"
      }
    }

    close $outfile
  }

  proc write_sdx_post_place_hook { config_info } {
    set enable_util_report    [dict get $config_info enable_util_report] 
    set kernels               [dict get $config_info kernels]
    set scripts_dir           [dict get $config_info scripts_dir] 

    set sdx_post_place [open "$scripts_dir/_sdx_post_place.tcl" w]
    puts $sdx_post_place "# This file was automatically generated by SDx"
    # puts $sdx_post_place "puts \"DEBUG: sourcing _sdx_post_place.tcl\""

    # generate the utilization reports after place_design
    puts $sdx_post_place "# utilization reports"
    puts $sdx_post_place "report_utilization_impl $enable_util_report \"$kernels\" \"placed\""

    close $sdx_post_place
  }

  # this tcl hook does the all the timing report/frequency scaling operations
  proc write_sdx_post_route_hook { dsa_info config_info clk_info } {
    set ocl_inst_path         [dict get $dsa_info ocl_region]
    set is_unified            [dict get $dsa_info is_unified]
    set dsa_full_dcp          [dict get $dsa_info dsa_dcp]
    set pr_shell_dcp          [dict get $dsa_info dsa_pr_shell_dcp]
    set dsa_uses_pr_shell_dcp [dict get $dsa_info dsa_uses_pr_shell_dcp]
    set link_output_format    [dict get $dsa_info link_output_format]

    set design_name           [dict get $config_info design_name]
    set enable_util_report    [dict get $config_info enable_util_report] 
    set kernels               [dict get $config_info kernels]
    set clbinary_name         [dict get $config_info clbinary_name]
    set encrypt_impl_dcp      [dict get $config_info encrypt_impl_dcp]
    set enable_pr_verify      [dict get $config_info enable_pr_verify]
    set local_dir             [dict get $config_info local_dir] 
    set scripts_dir           [dict get $config_info scripts_dir] 
    set output_dir            [dict get $config_info output_dir] 
    # failfast_config is only available for unified platform
    set failfast_config ""
    if { [dict exists $config_info failfast_config] } {
      set failfast_config  [dict get $config_info failfast_config]  
    }

    # generate the sdx tclhook for utilization report generation after place_design
    set sdx_post_route [open "$scripts_dir/_sdx_post_route.tcl" w]
    puts $sdx_post_route "# This file was automatically generated by SDx"
    # puts $sdx_post_route "puts \"DEBUG: sourcing _sdx_post_route.tcl\""
    puts $sdx_post_route ""
    puts $sdx_post_route "if {\$_is_sdx_post_route_run} {"
    puts $sdx_post_route " puts \"_sdx_post_route tcl hook has already been executed once\""
    puts $sdx_post_route " return true"
    puts $sdx_post_route "}"
    puts $sdx_post_route "set _is_sdx_post_route_run true"
    puts $sdx_post_route ""
    if { $encrypt_impl_dcp } {
      puts $sdx_post_route "# generate encrypted implemented checkpoint file"
      puts $sdx_post_route "if { !\[file exists encrypted_routed.dcp\] } {"
      puts $sdx_post_route "  write_checkpoint -encrypt encrypted_routed.dcp"
      puts $sdx_post_route "}"
      puts $sdx_post_route ""
    }
    puts $sdx_post_route "# generate cookie file for messaging"
    puts $sdx_post_route "write_cookie_file_impl \"$clbinary_name\""
    puts $sdx_post_route ""
    puts $sdx_post_route "# utilization reports"
    puts $sdx_post_route "report_utilization_impl $enable_util_report \"$kernels\" \"routed\""
    puts $sdx_post_route ""
    puts $sdx_post_route "# timing analysis and frequencly scaling"
    puts $sdx_post_route "if { !\[report_timing_and_scale_freq \"$ocl_inst_path\" \"$is_unified\" \"$design_name\" \"$output_dir\" \"$clk_info\"\] } {"
    puts $sdx_post_route "  return false"
    puts $sdx_post_route "}"
    puts $sdx_post_route ""

    if {$enable_pr_verify} {
      if { $dsa_uses_pr_shell_dcp } {
        set dsa_dcp $pr_shell_dcp
      } else {
        set dsa_dcp $dsa_full_dcp
      }
      if {$dsa_dcp ne ""} {
        # to increase the portability, support relative path
        if { [string first ".local_dsa" $dsa_dcp] != -1 || 
             [string first "$local_dir" $dsa_dcp] != -1 } {
          set dsa_dcp "../../../$dsa_dcp"
        }

        puts $sdx_post_route "# verify pr with the dsa dcp"
        puts $sdx_post_route "pr_verify -in_memory -additional $dsa_dcp"
        puts $sdx_post_route ""
      }
    }

    # aws dcp support
    # ltx files are generated as part of write_bitstream, since for Faas, we stop at post route_design,
    # we need to run write_debug_probes commands explicitly to generate them
    if { [string equal $link_output_format "dcp"] } {
      # puts $sdx_post_route "write_debug_probes -force -quiet -no_partial_ltxfile \[format \"%s/%s\" \".\" debug_nets.ltx\]"
      puts $sdx_post_route "# generate ltx files"
      puts $sdx_post_route "write_debug_probes -force -quiet -no_partial_ltxfile \[format \"%s/%s\" \".\" \[get_property TOP \[current_design\]\]\]"
    }

    if { [dict exists $failfast_config post_route_design] } {
      set failfast_args [dict get  $failfast_config post_route_design]
      if { [llength $failfast_args] == 0} {
        set failfast_args ""
      }
      # added on 4/9/2018 - to support macro expansion for reporting
      report_failfast_helper $config_info $dsa_info $failfast_args $sdx_post_route
    }

    close $sdx_post_route
  }

  proc report_utilization_impl {enable_util_report kernels run_step} {
    if { $enable_util_report } { 
      set sdx_util_string ""

      foreach kernel_inst [get_cells -hier -filter "SDX_KERNEL==true"] {
        if { ![string equal $kernel_inst ""] } {
          puts "--- DEBUG: kernel instance is $kernel_inst"
          # report_property $kernel_inst
          # get the kernel name (for hls kernel, the orig_ref_name seems to be the kernel name) 
          set kernel [get_property ORIG_REF_NAME $kernel_inst]

          # xcl_design_i/expanded_region/u_ocl_region/opencldesign_i/mmult_cu1/inst
          set ki_split [split $kernel_inst "/"]
          # assume the second to the last element is the kernel instance name (i.e. "mmult_cu1")
          # this is not reliable, but couldn't figure out a better way
          set kernel_inst_base [lindex $ki_split end-1]

          set sdx_util_string "$sdx_util_string $kernel:$kernel_inst:$kernel_inst_base"
        }
      }

      if {$sdx_util_string ne ""} {
        puts "--- DEBUG: report_sdx_utilization -kernels \"$sdx_util_string\" -file \"kernel_util_${run_step}.rpt\" -name kernel_util_${run_step}"
        report_sdx_utilization -kernels "$sdx_util_string" -file "kernel_util_${run_step}.rpt" -name kernel_util_${run_step}
      }
    }
  }

  proc write_cookie_file_impl { clbinary_name} { 
    # write the "cookie file" for Dennis' messaging support
    set run_dir [pwd]
    set cookie_file ./.xocc_runmsg.txt
    set outfile [open $cookie_file w]
    puts $outfile "Compiling (bitstream) accelerator binary: $clbinary_name"
    puts $outfile "Log file: $run_dir/runme.log"
    close $outfile
  }

  proc report_timing_and_scale_freq {ocl_inst_path is_unified design_name output_dir clk_info {is_in_run true} } {
    set worst_negative_slack    [dict get $clk_info worst_negative_slack]
    set error_on_hold_violation [dict get $clk_info error_on_hold_violation]
    set skip_timing_and_scaling [dict get $clk_info skip_timing_and_scaling]
    set enable_auto_freq_scale  [dict get $clk_info enable_auto_freq_scale]
    set startdir [pwd]

    # used for internal developer only
    if {$skip_timing_and_scaling} {
      return true
    }

    set routed_timing_dcp ${design_name}_routed_timing.dcp
    # Check hold violation before trying frequency scaling per Steven's request
    set timingHoldPaths [get_timing_paths -hold -quiet]
    if { [llength $timingHoldPaths] > 0 && [get_property SLACK $timingHoldPaths] < 0} {
      # The command above will return the worst hold slack. If it's negative, we error out.
      if { ![file exists $routed_timing_dcp] } {
        write_checkpoint $routed_timing_dcp
      }
      report_timing_summary -hold -file ${design_name}_timing_summary_hold.rpt
      # when there is a hold violation, it can be caused by huge failures in setup timing
      # so setup timing report should always be there.
      report_timing_summary -slack_lesser_than $worst_negative_slack -file ${design_name}_timing_summary.rpt

      if { $error_on_hold_violation } {
        error2file $startdir "design did not meet timing - hold violation"
      } else {
        puts "WARNING: Hold violation detected, it will be ignored due to user setting."
      }
    }

    set err_str "Design failed to meet timing"
    set new_clk_freq_file [expr { $is_in_run ? "../../../$output_dir/_new_clk_freq" : "$output_dir/_new_clk_freq"} ] 
    if {$enable_auto_freq_scale} {
      set is_timing_failure [expr [write_new_clk_freq $new_clk_freq_file $ocl_inst_path $is_unified $clk_info err_str] == "0"]
    } else {
      set is_timing_failure [expr [write_orig_clk_freq $new_clk_freq_file $design_name $clk_info err_str] == "0"] 
    }
    if { $is_timing_failure } {
      if { ![file exists $routed_timing_dcp] } {
        write_checkpoint $routed_timing_dcp
      }
      report_timing_summary -slack_lesser_than $worst_negative_slack -file ${design_name}_timing_summary.rpt
      error2file $startdir $err_str
    }
    return true
  }

  proc apply_dont_partition { enable_dont_partition steps_log output_dir} {
    if { $enable_dont_partition } {
      add_to_steps_log $steps_log "internal step: read_xdc $output_dir/dont_partition.xdc"

      # create the dont partition xdc for kernels
      # 1. Creating a dont_partition.xdc file what will contain a dont_partition constraint for all kernels.
      # 2. Adding the dont_partition.xdc to the project prior to running implementation.
      # puts "--- DEBUG: get_cells: [get_cells -hier -filter "SDX_KERNEL==true"]"
      
      set dontpartition [open "$output_dir/dont_partition.xdc" w]
      puts $dontpartition "set_property DONT_PARTITION TRUE \[get_cells -hier -filter {SDX_KERNEL==true}\]"
      close $dontpartition

      read_xdc $output_dir/dont_partition.xdc
    }
  }

  proc lock_crit_cells { dsa_dcp slack } {

    # puts "lock_crit_cells, dsa_dcp is $dsa_dcp, slack is $slack"
    if {$slack <= 0} {
      return
    }

    set crit_cells [get_cells -hier -filter "SETUP_SLACK != \"\" && SETUP_SLACK <= $slack"]
    if {[llength $crit_cells] == 0} {
      return
    }

    puts "Locking down [llength $crit_cells] critical cells"

    # rci params
    set_param place.incremental.pinGuidancePercForBBlkUnguiding -1
    set_param place.incremental.pinGuidancePercForGenUnguiding -1
    set_param place.incremental.partialShapeGuidanceThresh 0
    set_param place.incremental.clearPnRIncaseOfNoIncr false
    set_param route.incremental.doNotClearPhysDBInRCI true
    set_param place.incremental.doNotClearProgDelaysInRCI true
    set_param place.incremental.forceDefaultFlow true

    read_checkpoint -incremental $dsa_dcp -only_reuse $crit_cells -ignore_routing

    #lock down macros to prevent being moved by placer
    set crit_macro_cells [get_cells -filter { PRIMITIVE_TYPE =~ BLOCKRAM.*.* || PRIMITIVE_TYPE =~ DSP48E2 } $crit_cells ]
    if { [llength $crit_macro_cells] > 0 } {
      set_property is_loc_fixed 1 $crit_macro_cells
    }
  }

  proc create_bitstreams_with_run { dsa_info config_info clk_info } {
    OPTRACE "START" "Create implementation project" "ROLLUP_AUTO,PROJECT"

    set dsa_part         [dict get $dsa_info dsa_part]
    set dsa_uses_pr      [dict get $dsa_info dsa_uses_pr]
    set dsa_uses_pr_shell_dcp  [dict get $dsa_info dsa_uses_pr_shell_dcp]
    set pr_shell_dcp     [dict get $dsa_info dsa_pr_shell_dcp]
    set uses_static_synth_dcp  [dict get $dsa_info dsa_uses_static_synth_dcp]
    set dsa_full_dcp     [dict get $dsa_info dsa_dcp]
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set link_output_format     [dict get $dsa_info link_output_format]

    set design_name      [dict get $config_info design_name]
    set project_name     [dict get $config_info impl_proj_name]
    set ocl_dcp          [dict get $config_info ocl_dcp]
    set out_partial_bit  [dict get $config_info out_partial_bitstream]
    set out_partial_clear_bit  [dict get $config_info out_partial_clear_bit]
    set out_full_bit     [dict get $config_info out_full_bitstream]
    set impl_props_tcl   [dict get $config_info impl_props_tcl]
    set enable_dont_partition  [dict get $config_info enable_dont_partition]
    set kernels          [dict get $config_info kernels]
    set enable_util_report     [dict get $config_info enable_util_report] 
    set script_only      [dict get $config_info generate_script_only] 
    set run_script_map_file    [dict get $config_info run_script_map_file] 
    set steps_log        [dict get $config_info steps_log] 
    set encrypt_impl_dcp        [dict get $config_info encrypt_impl_dcp]
    set output_dir       [dict get $config_info output_dir] 

    set kernel_clock_freqs     [dict get $clk_info kernel_clock_freqs]  

    set cwd [pwd]
    set start_time [clock seconds]

    OPTRACE "START" "Create gatelevel project"
    add_to_steps_log $steps_log "internal step: create_project $project_name $project_name -part $dsa_part -force"
    create_project $project_name $project_name -part $dsa_part -force
    set_property tool_flow SDx [current_project]
    set_property coreContainer.enable 1 [current_project]
    set_property design_mode GateLvl [current_fileset]

    OPTRACE "END" "Create gatelevel project"
    OPTRACE "START" "Examine static netlist"

    # in export_script mode, there is no $ocl_dcp generated
    if { $script_only } {
      # we simply add $dsa_full_dcp
      add_files $dsa_full_dcp
      link_design

      launch_runs impl_1 -to_step write_bitstream -scripts_only
      create_run_script_map_file "impl" $output_dir
      # for non-unified paltforms, we need to move "run_script_map.dat" one level up
      # so that this file is at the same level as xclbin
      file copy $output_dir/run_script_map.dat ..
      return
    } 

    ### Open the platform DCP or the PR shell checkpoint
    ### For pr shell dcp, the design is already blackboxed
    if { !$dsa_uses_pr_shell_dcp } {
      if { [catch {
        add_to_steps_log $steps_log "internal step: import_files $dsa_full_dcp"
        send_msg_id {101-1} {status} {Linking the synthesized kernels: calling import_file}
        import_files $dsa_full_dcp

        add_to_steps_log $steps_log "internal step: link_design"
        send_msg_id {101-1} {status} {Linking the synthesized kernels: calling link_design}
        link_design
      } catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem reading DSA checkpoint" $catch_res
      }

      add_to_steps_log $steps_log "internal step: update_design -black_box -cell \[get_cells $ocl_inst_path\]"
      send_msg_id {101-1} {status} {Linking the synthesized kernels: calling update_design}

      if { [catch {update_design -black_box -cell [get_cells $ocl_inst_path]} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem updating DSA design" $catch_res
      }

    } else {
      if { [catch {
        add_to_steps_log $steps_log "internal step: add_files $pr_shell_dcp"
        add_files $pr_shell_dcp
        add_to_steps_log $steps_log "internal step: link_design"
        link_design
      } catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem reading DSA checkpoint" $catch_res
      }
    }

    if { !$uses_static_synth_dcp } {
      add_to_steps_log $steps_log "internal step: lock_design -level routing"
      send_msg_id {101-1} {status} {Linking the synthesized kernels: calling lock_design}

      if { [catch {lock_design -level routing} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem locking DSA design" $catch_res
      }
    }
    OPTRACE "END" "Examine static netlist"
    OPTRACE "START" "Prepare dynamic netlist"

    # prototype: write the checkpoint to overwrite imported dsa_full_dcp for --interactive
    # set dsa_full_dcp_basename [file tail $dsa_full_dcp]
    # set imported_dsa_full_dcp [get_files $dsa_full_dcp_basename]
    # puts "--- DEBUG: the imported dsa_full_dcp is $imported_dsa_full_dcp"
    # puts "--- DEBUG: file copy $imported_dsa_full_dcp $imported_dsa_full_dcp.bk"
    # file copy $imported_dsa_full_dcp $imported_dsa_full_dcp.bk
    # puts "--- DEBUG: write_checkpoint -force $imported_dsa_full_dcp"
    # write_checkpoint -force $imported_dsa_full_dcp

    ### Read in the dynamic region DCP
    add_to_steps_log $steps_log "internal step: read_checkpoint -cell $ocl_inst_path $ocl_dcp"
    send_msg_id {101-1} {status} {Linking the synthesized kernels: calling read_checkpoint}

    if { [catch {read_checkpoint -cell $ocl_inst_path $ocl_dcp} catch_res] } {
      add_to_steps_log $steps_log "status: fail"
      error2file $cwd "problem reading dynamic region checkpoint" $catch_res
    }

    apply_dont_partition $enable_dont_partition $steps_log $output_dir

    # create a user clock constraint if set
    write_user_impl_clock_constraint $ocl_inst_path $kernel_clock_freqs $steps_log $output_dir

    OPTRACE "END" "Prepare dynamic netlist"
    OPTRACE "START" "Configure implementation run"

    # Note: this must be after set_param project.writeIntermediateCheckpoints
    add_to_steps_log $steps_log "internal step: source $impl_props_tcl"
    source $impl_props_tcl
    
    # pass -cell to write_bitstream to only generate the partial bit files for pr
    if { $dsa_uses_pr } {
      set more_option [get_property {STEPS.WRITE_BITSTREAM.ARGS.MORE OPTIONS} [get_runs impl_1]]
      set_property -name {STEPS.WRITE_BITSTREAM.ARGS.MORE OPTIONS} -value "$more_option -cell $ocl_inst_path" -objects [get_runs impl_1] 
    }

    # custom run script support
    set user_run_script_switch ""
    if { ![string equal $run_script_map_file ""] } {
      set user_run_script_switch "-custom_script $run_script_map_file"
    }

    # aws dcp support
    # if acceleratorBinaryContent in DSA is set to "dcp", we should skip write_bitstream
    # and use post route dcp as the output
    set to_step_switch "-to_step write_bitstream"
    if { [string equal $link_output_format "dcp"] } {
      set to_step_switch ""
    }

    add_to_steps_log $steps_log "internal step: launch_runs impl_1 $to_step_switch $user_run_script_switch"
    send_msg_id {101-1} {status} {Linking the synthesized kernels: launching implementation run}

    OPTRACE "END" "Configure implementation run"
    OPTRACE "END" "create_impl_project"

    launch_runs impl_1 {*}$to_step_switch {*}$user_run_script_switch
    set run_dir [get_property DIRECTORY [get_runs impl_1]]
    # Note: when run fails, wait_on_run may not raise an error
    if { [catch {wait_on_run impl_1} catch_res] } {
      add_to_steps_log $steps_log "status: fail"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region" $catch_res
    }

    set run_status [get_property STATUS [get_runs impl_1]]
    # puts "--- DEBUG: run_status is $run_status"
    if { [string match "*ERROR" $run_status] } {
      add_to_steps_log $steps_log "status: fail ($run_status)"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region, $run_status" 
    }

    # aws dcp support
    # copy the post-route dcp to ipi directory
    if { [string equal $link_output_format "dcp"] } {
      if { $encrypt_impl_dcp} {
        set routed_dcp [glob -nocomplain "$run_dir/encrypted_routed.dcp"]
      } else {
        set routed_dcp [glob -nocomplain "$run_dir/*_routed.dcp"]
      }
      set out_routed_dcp "$output_dir/routed.dcp"
      if { ![string equal $routed_dcp ""] } {
        puts "--- DEBUG: file copy -force $routed_dcp $out_routed_dcp"
        file copy -force $routed_dcp $out_routed_dcp
      }
    } else {
      # copy the generated bit files to ipi dir (pwd)
      if { $dsa_uses_pr } {
        set partial_bit [glob -nocomplain "$run_dir/*.bit"]
        set partial_clear_bit [glob -nocomplain "$run_dir/*_clear.bit"]
        # puts "--- DEBUG: partial_bit is $partial_bit"
        # puts "--- DEBUG: partial_clear_bit is $partial_clear_bit"
        # $partial_bit may contain two files - partial bit and partial clear bit 
        if { [llength $partial_bit] == 2 && [llength $partial_clear_bit] == 1} {
          puts "--- DEBUG: *.bit returns more than one bit files"
          set idx [lsearch $partial_bit $partial_clear_bit]
          # remove the partial clear bit file from $partial_bit
          set partial_bit [lreplace $partial_bit $idx $idx]
          # puts "--- DEBUG: partial_bit is $partial_bit"
        }

        if { ![string equal $partial_bit ""] && [file exists $partial_bit] } {
          file copy -force $partial_bit $out_partial_bit
        }
        if { ![string equal $partial_clear_bit ""] && [file exists $partial_clear_bit] } {
          file copy -force $partial_clear_bit $out_partial_clear_bit
        }
      } else {
        # flat flow (i.e. zynq)
        set full_bit [glob -nocomplain "$run_dir/*.bit"]
        if { ![string equal $full_bit ""] && [file exists $full_bit] } {
          file copy -force $full_bit $out_full_bit
        }
      }
    }
 
    # set run_time [expr [clock seconds] - $start_time]
    # puts "PROFILE: create_bitstreams_with_run took $run_time seconds"
    
  }; # create_bitstreams_with_run


  proc create_bitstreams_with_runs_for_expanded_pr { dsa_info config_info clk_info } {
    
    OPTRACE "START" "impl_link_design_xpr" "PROJECT"

    set dsa_part         [dict get $dsa_info dsa_part]
    set dsa_full_dcp     [dict get $dsa_info dsa_dcp]
    set dsa_static_xdef  [dict get $dsa_info dsa_static_xdef]
    set ocl_inst_path    [dict get $dsa_info ocl_region]
    set parent_rm_inst_path    [dict get $dsa_info parent_rm_instance_path]
    set link_output_format     [dict get $dsa_info link_output_format]

    set design_name      [dict get $config_info design_name]
    set project_name     [dict get $config_info impl_proj_name]
    set ocl_dcp          [dict get $config_info ocl_dcp]
    set out_partial_bit  [dict get $config_info out_partial_bitstream]
    set out_partial_clear_bit  [dict get $config_info out_partial_clear_bit]
    set impl_props_tcl   [dict get $config_info impl_props_tcl]
    set enable_dont_partition  [dict get $config_info enable_dont_partition]
    set kernels          [dict get $config_info kernels]
    set enable_util_report     [dict get $config_info enable_util_report] 
    set script_only      [dict get $config_info generate_script_only] 
    set run_script_map_file    [dict get $config_info run_script_map_file] 
    set steps_log        [dict get $config_info steps_log] 
    set encrypt_impl_dcp [dict get $config_info encrypt_impl_dcp]
    set output_dir       [dict get $config_info output_dir] 

    set kernel_clock_freqs     [dict get $clk_info kernel_clock_freqs]  

    set cwd [pwd]
    set start_time [clock seconds]

    set updated_full_dcp "updated_full_design.dcp"
    # in export_script mode, there is no $ocl_dcp generated
    if { $script_only } {
      # we simply copy $dsa_full_dcp to $updated_full_dcp
      file copy -force $dsa_full_dcp $updated_full_dcp

    } else {
      add_to_steps_log $steps_log "internal step: open_checkpoint -skip_xdef $dsa_full_dcp"
      if { [catch {open_checkpoint -skip_xdef $dsa_full_dcp} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem reading DSA full checkpoint" $catch_res
      }

      add_to_steps_log $steps_log "internal step: read_xdef -no_clear $dsa_static_xdef"
      if { [catch {read_xdef -no_clear $dsa_static_xdef} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem reading static xdef" $catch_res
      }
      
      add_to_steps_log $steps_log "internal step: update_design -black_box -cell \[get_cells $ocl_inst_path\]"
      if { [catch {update_design -black_box -cell [get_cells $ocl_inst_path]} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem black-boxing dynamic region design" $catch_res
      }

      # check the number of RMs. Amazon platform contains two PRs (RMs)
      set pr_cells [get_cells -hierarchical -filter { HD.RECONFIGURABLE == "TRUE" }] 
      set number_rms [ llength $pr_cells]
      # puts "--- DEBUG: number_rms is $number_rms"
      # puts "--- DEBUG: pr_cells is $pr_cells"

      # foreach pr_cell $pr_cells {
      #   puts "--- DEBUG: pblock for $pr_cell is [get_pblocks -hdpr -of_objects $pr_cell]"
      # }
      # puts "--- DEBUG: get all pblocks"
      # puts "[join [get_pblocks] \n]"

      add_to_steps_log $steps_log "internal step: lock_design -exclude_cells $parent_rm_inst_path -level routing"
      if { [catch {lock_design -exclude_cells $parent_rm_inst_path -level routing} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem locking non expanded PR region" $catch_res
      }

      add_to_steps_log $steps_log "internal step: read_checkpoint -cell $ocl_inst_path $ocl_dcp"
      if { [catch {read_checkpoint -cell $ocl_inst_path $ocl_dcp} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem reading dynamic region checkpoint" $catch_res
      }

      apply_dont_partition $enable_dont_partition $steps_log $output_dir

      # create a user clock constraint if set
      write_user_impl_clock_constraint $ocl_inst_path $kernel_clock_freqs $steps_log $output_dir

      add_to_steps_log $steps_log "internal step: write_checkpoint $updated_full_dcp"
      if { [catch {write_checkpoint $updated_full_dcp} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem writing out an updated full checkpoint" $catch_res
      }

      add_to_steps_log $steps_log "internal step: close_project"
      if { [catch {close_project} catch_res] } {
        add_to_steps_log $steps_log "status: fail"
        error2file $cwd "problem closing diskless project" $catch_res
      }
    }

    OPTRACE "END" "impl_link_design_xpr"

    # create a vivado impl project
    add_to_steps_log $steps_log "internal step: create_project $project_name $project_name -part $dsa_part -force"
    create_project $project_name $project_name -part $dsa_part -force
    set_property tool_flow SDx [current_project]
    set_property coreContainer.enable 1 [current_project]
    set_property design_mode GateLvl [current_fileset]

    add_to_steps_log $steps_log "internal step: add_files $updated_full_dcp"
    add_files $updated_full_dcp

    if { $script_only } {
      launch_runs impl_1 -to_step write_bitstream -scripts_only
      create_run_script_map_file "impl" $output_dir
      # for non-unified paltforms, we need to move "run_script_map.dat" one level up
      # so that this file is at the same level as xclbin
      file copy $output_dir/run_script_map.dat ..
      return
    }

    add_to_steps_log $steps_log "internal step: source $impl_props_tcl"
    source $impl_props_tcl

    # for aws, there could be two prs (pblocks), so there are two _partial.bit files, we are only
    # interested in _CL_partial.bit. 
    # write_bitstream without -cell will generate three bit files - two partial bit files and a full bit file
    # passing -cell to write_bitstream only generates one partial bit (_CL_partial) file for expanded pr
    set more_option [get_property {STEPS.WRITE_BITSTREAM.ARGS.MORE OPTIONS} [get_runs impl_1]]
    set_property -name {STEPS.WRITE_BITSTREAM.ARGS.MORE OPTIONS} -value "$more_option -cell $parent_rm_inst_path" -objects [get_runs impl_1] 

    # custom run script support
    set user_run_script_switch ""
    if { ![string equal $run_script_map_file ""] } {
      set user_run_script_switch "-custom_script $run_script_map_file"
    }

    # aws dcp support
    # if acceleratorBinaryContent in DSA is set to "dcp", we should skip write_bitstream
    # and use post route dcp as the output
    set to_step_switch "-to_step write_bitstream"
    if { [string equal $link_output_format "dcp"] } {
      set to_step_switch ""
    }

    add_to_steps_log $steps_log "internal step: launch_runs impl_1 $to_step_switch $user_run_script_switch"
    launch_runs impl_1 {*}$to_step_switch {*}$user_run_script_switch

    set run_dir [get_property DIRECTORY [get_runs impl_1]]
    # Note: when run fails, wait_on_run may not raise an error
    if { [catch {wait_on_run impl_1} catch_res] } {
      add_to_steps_log $steps_log "status: fail"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region" $catch_res
    }

    set run_status [get_property STATUS [get_runs impl_1]]
    # puts "--- DEBUG: run_status is $run_status"
    if { [string match "*ERROR" $run_status] } {
      add_to_steps_log $steps_log "status: fail ($run_status)"
      add_to_steps_log $steps_log "log: $run_dir/runme.log"
      error2file $cwd "problem implementing dynamic region, $run_status" 
    }

    # aws dcp support
    # copy the post-route dcp to ipi directory
    if { [string equal $link_output_format "dcp"] } {
      if { $encrypt_impl_dcp} {
        set routed_dcp [glob -nocomplain "$run_dir/encrypted_routed.dcp"]
      } else {
        set routed_dcp [glob -nocomplain "$run_dir/*_routed.dcp"]
      }
      set out_routed_dcp "$output_dir/routed.dcp"
      if { ![string equal $routed_dcp ""] } {
        puts "--- DEBUG: file copy -force $routed_dcp $out_routed_dcp"
        file copy -force $routed_dcp $out_routed_dcp
      }
    } else {
      # copy the generated partial (and partial clear) bit files to ipi dir (pwd)
      # The name of the generated bit file is NOT fixed, it depends on the partition pblock name
      # For aws, there are two prs (pblocks), but tool only generates one partial bit file
      #          (i.e. _CL_partial.bit) since we pass -cell switch to write_bitstream
      set partial_bit [glob -nocomplain "$run_dir/*.bit"]
      set partial_clear_bit [glob -nocomplain "$run_dir/*_clear.bit"]
      puts "--- DEBUG: partial_bit is $partial_bit"
      puts "--- DEBUG: partial_clear_bit is $partial_clear_bit"
      if { [llength $partial_bit] == 2 && [llength $partial_clear_bit] == 1} {
        puts "--- DEBUG: *.bit returns more than one bit files"
        set idx [lsearch $partial_bit $partial_clear_bit]
        set partial_bit [lreplace $partial_bit $idx $idx]
        puts "--- DEBUG: partial_bit is $partial_bit"
      }

      if { ![string equal $partial_bit ""] && [file exists $partial_bit] } {
        file copy -force $partial_bit $out_partial_bit
      }
      if { ![string equal $partial_clear_bit ""] && [file exists $partial_clear_bit] } {
        file copy -force $partial_clear_bit $out_partial_clear_bit
      }
    }


    # set run_time [expr [clock seconds] - $start_time]
    # puts "PROFILE: create_bitstreams_with_run took $run_time seconds"
    
  }; # create_bitstreams_with_run_for_exapnded_pr

  proc create_bitstreams { dsa_info config_info clk_info } { 
    set dsa_uses_pr        [dict get $dsa_info dsa_uses_pr]
    set dsa_uses_pr_shell_dcp      [dict get $dsa_info dsa_uses_pr_shell_dcp]
    set pr_shell_dcp       [dict get $dsa_info dsa_pr_shell_dcp]
    set dsa_uses_static_synth_dcp  [dict get $dsa_info dsa_uses_static_synth_dcp]
    set dsa_full_dcp       [dict get $dsa_info dsa_dcp]
    set dsa_static_xdef    [dict get $dsa_info dsa_static_xdef]
    set ocl_inst_path      [dict get $dsa_info ocl_region]
    set parent_rm_instance_path    [dict get $dsa_info parent_rm_instance_path]
    set is_unified         [dict get $dsa_info is_unified]

    set design_name        [dict get $config_info design_name]
    set ocl_dcp            [dict get $config_info ocl_dcp]
    set out_ocl_bitstream  [dict get $config_info out_partial_bitstream]
    set out_platform_bitstream     [dict get $config_info out_full_bitstream]
    set gen_extra_run_data [dict get $config_info gen_extra_run_data]
    set steps_log          [dict get $config_info steps_log] 
    set output_dir         [dict get $config_info output_dir] 

    set kernel_clock_freqs         [dict get $clk_info kernel_clock_freqs]  
    set worst_negative_slack       [dict get $clk_info worst_negative_slack]
    set max_frequency              [dict get $clk_info max_frequency]

    set startdir [pwd]    
    set start_time [clock seconds]

    OPTRACE "START" "Phase: Create bitstream" "ROLLUP_AUTO"

    ### Open the platform DCP or the PR shell checkpoint
    ### For pr shell dcp, the design is already blackboxed
    if { !$dsa_uses_pr_shell_dcp } {
      if { $dsa_static_xdef != "" } {
        # expanded PR support
        set_param hd.useStaticResourceForRMRouting 1
        catch {set_param hd.checkIllegalUpdateDesignBlackbox false}

        if { [catch {open_checkpoint -skip_xdef $dsa_full_dcp} catch_res] } {
          error2file $startdir "problem reading DSA checkpoint" $catch_res
        }
        if { [catch {read_xdef -no_clear $dsa_static_xdef} catch_res] } {
          error2file $startdir "problem reading DSA xdef" $catch_res
        }
      } else {
        if { [catch {open_checkpoint $dsa_full_dcp} catch_res] } {
          error2file $startdir "problem reading DSA checkpoint" $catch_res
        }
      }

      if { [catch {update_design -black_box -cell [get_cells $ocl_inst_path]} catch_res] } {
        error2file $startdir "problem updating DSA design" $catch_res
      }
    } else {
      #Temp hack to disable MLO when opening dcp created with older vivado version
      set_param logicopt.enableMandatoryLopt 0
      if { [catch {open_checkpoint $pr_shell_dcp} catch_res] } {
        error2file $startdir "problem reading DSA shell checkpoint" $catch_res
      }
      set_param logicopt.enableMandatoryLopt 1
    }

    if { [catch {
      if { !$dsa_uses_static_synth_dcp } {
        if { $dsa_static_xdef != "" } {
          lock_design -level routing -static
        } else {
          lock_design -level routing
        }
      }
    } catch_res] } {
      error2file $startdir "problem locking DSA design" $catch_res
    }

    ### Read in the dynamic region DCP
    if { [catch {read_checkpoint -cell $ocl_inst_path $ocl_dcp} catch_res] } {
      error2file $startdir "problem reading dynamic region checkpoint" $catch_res
    }

    # create a user clock constraint if set
    write_user_impl_clock_constraint $ocl_inst_path $kernel_clock_freqs $steps_log $output_dir

    ### Complete the flow
    if { [catch {opt_design} catch_res] } {
      error2file $startdir "problem optimizing design" $catch_res
    }
    set_property SEVERITY {Warning} [get_drc_checks HDPR-5]
    if { [catch {place_design} catch_res] } {
      error2file $startdir "problem placing design" $catch_res
    }
    if { [catch {route_design} catch_res] } {
      error2file $startdir "problem routing design" $catch_res
    }
    
    set timingFailedPaths [ get_timing_paths -quiet -slack_lesser_than $worst_negative_slack ]
    set isPostRouteDcpGenerated false
    if { [ llength $timingFailedPaths ] > 0 } {
      OPTRACE "START" "Frequency Scaling"
      # if there are timing paths that do not meet specified WNS, try frequency scaling
      write_checkpoint ${design_name}_routed_timing.dcp
      set isPostRouteDcpGenerated true
      report_timing_summary -slack_lesser_than $worst_negative_slack -file ${design_name}_timing_summary.rpt
      OPTRACE "END" "Frequency Scaling"
    } 

    # Added hold violation check per Steven's request
    set hold [ get_property SLACK [get_timing_paths -hold -quiet] ] 
    # The command above will return the worst hold slack. If it's negative, we error out.
    if { $hold < 0 } {
      if { !$isPostRouteDcpGenerated } {
        OPTRACE "START" "write_checkpoint" "CHECKPOINT"
        write_checkpoint ${design_name}_routed_timing.dcp
        OPTRACE "END" "write_checkpoint"
      }
      report_timing_summary -hold -file ${design_name}_timing_summary_hold.rpt
      # puts "ERROR: Design failed to meet timing - hold violation."
      error2file $startdir "design did not meet timing - hold violation"
      # return false
    }

    # Based on Steven's request
    # Even if timing was met for given WNS, use the freq scaling proc to write the final freq in the xclbin
    # In case where kernel clk frequency is overwritten by user(parameter/pre-hook),this will ensure that the scaled 
    # frequency is written out instead of the frequency from the DSA.
    set new_clk_freq_file "_new_clk_freq" 
    if { [write_new_clk_freq $new_clk_freq_file $ocl_inst_path $is_unified $clk_info error_string] == "0" } {
      # if frequency scaling fails, issue timing failed error and abort
      puts "ERROR: Design failed to meet timing."
      puts "ERROR: Failed timing checks (paths):\n\t[ join $timingFailedPaths \n\t ]\n\n"
      puts "ERROR: Please check the routed checkpoint(${design_name}_routed_timing.dcp) and timing summary report(${design_name}_timing_summary.rpt) for more information."
      error2file $startdir "$error_string"
      # return false
    }
 
    # generate timing summary and utilization reports
    if { $gen_extra_run_data } {
      set rootname [file rootname $ocl_dcp]
      OPTRACE "START" "Timing summary and utilization reports" "ROLLUP_AUTO"
      OPTRACE "START" "write_checkpoint" "CHECKPOINT"
      write_checkpoint ${rootname}_routed.dcp
      OPTRACE "END" "write_checkpoint" 
      OPTRACE "START" "Create reports" "REPORT"
      report_utilization -file ${rootname}_utilization_routed.rpt
      report_timing_summary -max_paths 10 -file ${rootname}_timing_summary_routed.rpt
      OPTRACE "END" "Create reports" 
      OPTRACE "START" "Timing summary and utilization reports" "ROLLUP_AUTO"
    }

    ### Write out the bitstreams
    if { [catch {
    if { $dsa_uses_pr } {
      set rm_inst_path $ocl_inst_path
      if { $parent_rm_instance_path != "" } {
        set rm_inst_path $parent_rm_instance_path
      } 
      write_bitstream -cell $rm_inst_path $out_ocl_bitstream -force
    } else {
      write_bitstream $out_platform_bitstream -force
    }
    } catch_res] } {
      error2file $startdir "problem writing design bitstream" $catch_res
    }
    
    # set run_time [expr [clock seconds] - $start_time]
    # puts "PROFILE:create_bitstreams took $run_time seconds"
    
    OPTRACE "END" "Phase: Create bitstream"

  }; # create_bitstreams

  proc write_orig_clk_freq {new_clk_freq_file design_name clk_info err_str} {
    set kernel_clock_freqs    [dict get $clk_info kernel_clock_freqs]  
    set system_clock_freqs    [dict get $clk_info system_clock_freqs]  
    set worst_negative_slack  [dict get $clk_info worst_negative_slack]
    upvar $err_str _err_str

    set routed_timing_dcp ${design_name}_routed_timing.dcp
    set timing_summary_rpt ${design_name}_timing_summary.rpt
    puts "--- DEBUG: clock frequency scaling is disabled for this flow, perform the normal timing check instead"
    puts "--- DEBUG: get_timing_paths -quiet -slack_lesser_than $worst_negative_slack"
    set timingFailedPaths [ get_timing_paths -quiet -slack_lesser_than $worst_negative_slack ]
    if { [llength $timingFailedPaths] > 0 } {
      set _err_str "Design failed to meet timing.\n"
      append _err_str "    Failed timing checks (paths):\n\t[ join $timingFailedPaths \n\t ]\n\n"
      append _err_str "    Please check the routed checkpoint ($routed_timing_dcp) and timing summary report ($timing_summary_rpt) for more information."

      return 0;
    }

    # write the original clock frequencies in _new_ocl_freq file
    set outfile [open $new_clk_freq_file w]
    dict for {kernel_clk dict_clock} $kernel_clock_freqs {
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 
      puts $outfile "kernel:$clk_id:$kernel_clk:$orig_clk_freq"
    }

    dict for {system_clk dict_clock} $system_clock_freqs {
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 
      # note for system clock, the clk_id is an empty string
      puts $outfile "system:$clk_id:$system_clk:$orig_clk_freq"
    }

    close $outfile
    return 1
  }

  # ocl_util::write_new_clk_freq
  #
  #     Writes frequency data to file, used by runtime to set MMCM control registers.
  #     Output data is for scalable system clocks and kernel clocks.
  #
  # Parameters:
  #
  #     new_clk_freq_file Path to output file for scalable system and kernel clock results
  #     ocl_inst_path
  #     is_unified        True for a unified platform, false otherwise
  #     clk_info          Dictionary
  #     err_str
  #
  # Results:
  #     Returns 0 indicates frequency scaling failure; return 1 indicate success
  #
  # TODO: what should we do if ocl_inst_path is empty (for SoC unified platform)

  proc write_new_clk_freq {new_clk_freq_file ocl_inst_path is_unified clk_info err_str} {
    # set is_unified            [dict get $dsa_info is_unified] 
    # set ocl_inst_path         [dict get $dsa_info ocl_region]

    set kernel_clock_freqs    [dict get $clk_info kernel_clock_freqs]  
    set system_clock_freqs    [dict get $clk_info system_clock_freqs]  
    set worst_negative_slack  [dict get $clk_info worst_negative_slack]

    upvar $err_str _err_str
    set startdir [pwd]

    puts "Starting auto-frequency scaling ..."
    # initialize kernel_pin_freqs
    foreach kernel_clk [dict keys $kernel_clock_freqs] {
      set kernel_pin_path "$ocl_inst_path/$kernel_clk"
      set dict_clock [dict get $kernel_clock_freqs $kernel_clk]
      set orig_clock_freq [dict get $dict_clock freq]
      set orig_clock_freq [format "%.1f" $orig_clock_freq]
      set kernel_pin_clock_map($kernel_pin_path) $kernel_clk

      # kernel_pin_freqs is a tcl array
      set kernel_pin_freqs($kernel_pin_path) $orig_clock_freq
      puts "kernel clock '$kernel_clk':"
      puts "   clock pin path     : $kernel_pin_path"
      puts "   original frequency : ${orig_clock_freq} MHz"
    }
    puts ""

    foreach system_clk [dict keys $system_clock_freqs] {
      set system_pin_path [lindex [get_pins -of_objects [get_clocks $system_clk]] 0]
      set dict_clock [dict get $system_clock_freqs $system_clk]
      set orig_clock_freq [dict get $dict_clock freq] 
      set orig_clock_freq [format "%.1f" $orig_clock_freq]
      set system_pin_clock_map($system_pin_path) $system_clk

      # kernel_pin_freqs is a tcl array
      set system_pin_freqs($system_pin_path) $orig_clock_freq
      puts "system clock '$system_clk':"
      puts "   clock pin path     : $system_pin_path"
      puts "   original frequency : ${orig_clock_freq} MHz"
    }
    puts ""

    # call steven li's auto frequency scaling tcl proc, kernel_pin_freqs and system_pin_freqs contains the scaled frequencies
    # note: get_achievable_kernel_freq not only tries to scale the scalable clocks, it also reports
    #       any unscalable clock (e.g. system clock) which doesn't meet timing (worse than wns)
    set failing_system_clocks ""
    set achieved ""
    set ret [get_achievable_kernel_freq $worst_negative_slack kernel_pin_freqs system_pin_freqs failing_system_clocks]
    puts "Auto-frequency scaling completed"

    # returns 0 if any system clock slack < worst negative slack, in which case, the kernel clock frequencies are NOT scaled?
    if { $ret  == "0" } {
      set err_freq ""
      if { !$is_unified } {
        foreach kernel_pin [array names kernel_pin_freqs] {
          # only doing this for primary kernel clock
          if { [string match *ACLK $kernel_pin] || [string match *KERNEL_CLK $kernel_pin] || [string match *DATA_CLK $kernel_pin] } {
            validate_new_clk_freq $ocl_util::Kernel $clk_info $kernel_pin kernel_pin_clock_map kernel_pin_freqs _err_str new_ocl_freq
            break
          }
        }
      } else {
        # unified platforms, clock names are not hard-coded
        # find the mimimum new_ocl_freq 
        set min_new_ocl_freq 0
        foreach kernel_pin [array names kernel_pin_freqs] {
          validate_new_clk_freq $ocl_util::Kernel $clk_info $kernel_pin kernel_pin_clock_map kernel_pin_freqs _err_str new_ocl_freq
          if { $min_new_ocl_freq == 0 } {
            set min_new_ocl_freq $new_ocl_freq 
          }
          # puts "min_new_ocl_freq is $min_new_ocl_freq; new_ocl_freq is $new_ocl_freq"
          if { $min_new_ocl_freq > $new_ocl_freq } {
            set min_new_ocl_freq $new_ocl_freq 
          }
        }
        set new_ocl_freq $min_new_ocl_freq
      }

      # $new_ocl_freq could have decimal places, so round it down 
      set err_freq [round_down $new_ocl_freq]
      set _err_str "Design did not meet timing. An unscalable system clock did not meet its required target frequency. Please try specifying a clock frequency lower than $err_freq MHz using the '--kernel_frequency' switch for the next compilation. For all system clocks, this design is using $worst_negative_slack nanoseconds as the threshold worst negative slack (WNS) value. List of system clocks with timing failure:"
      set report_clock_list ""
      foreach _sys_clk [dict keys $failing_system_clocks] {
        set _slack [dict get $failing_system_clocks $_sys_clk]
        append _err_str "\nsystem clock: $_sys_clk; slack: $_slack ns"
        append report_clock_list "\nsystem clock: $_sys_clk; slack: $_slack ns"
      }

      # AUTO-FREQ-SCALING-01
      if {[is_drcv]} { ::drcv::create_violation AUTO-FREQ-SCALING-01 -s $err_freq -s $worst_negative_slack -s $report_clock_list }
      return 0
    }

    # write the new clock frequencies in _new_ocl_freq file
    set output_dir [file dirname $new_clk_freq_file]
    set outfile [open $new_clk_freq_file w]
    foreach kernel_pin [array names kernel_pin_freqs] {
      if { ![validate_new_clk_freq $ocl_util::Kernel $clk_info $kernel_pin kernel_pin_clock_map kernel_pin_freqs _err_str new_ocl_freq] } {
        close $outfile
        return 0 
      }
   
      set kernel_clk $kernel_pin_clock_map($kernel_pin)
      set dict_clock [dict get $kernel_clock_freqs $kernel_clk]
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 

      if { $new_ocl_freq < $orig_clk_freq } {
        warning2file $output_dir "WARNING: One or more timing paths failed timing targeting $orig_clk_freq MHz for kernel clock '$kernel_clk'. The frequency is being automatically changed to $new_ocl_freq MHz to enable proper functionality"
        # AUTO-FREQ-SCALING-04
        if {[is_drcv]} { ::drcv::create_violation AUTO-FREQ-SCALING-04 -REF [list type OTHER -name $kernel_clk] -s $orig_clk_freq -s $new_ocl_freq }
      }

      # write the new ocl frequency to the file "_new_clk_freq" regardless the clock has been scaled or not
      # in the case where the clock is not scaled, the new frequency would be same as original frequency
      puts $outfile "kernel:$clk_id:$kernel_clk:$new_ocl_freq"
      append achieved "\nKernel: $kernel_clk = $new_ocl_freq MHz "
    }

    foreach system_pin [array names system_pin_freqs] {
      if { ![validate_new_clk_freq $ocl_util::System $clk_info $system_pin system_pin_clock_map system_pin_freqs _err_str new_clk_freq] } {
        close $outfile
        return 0 
      }
   
      set system_clk $system_pin_clock_map($system_pin)
      set dict_clock [dict get $system_clock_freqs $system_clk]
      set orig_clk_freq [dict get $dict_clock freq]
      set clk_id [dict get $dict_clock clk_id] 

      if { $new_clk_freq < $orig_clk_freq } {
        warning2file $output_dir "WARNING: One or more timing paths failed timing targeting $orig_clk_freq MHz for system clock '$system_clk'. The frequency is being automatically changed to $new_clk_freq MHz to enable proper functionality"
        # AUTO-FREQ-SCALING-07
        if {[is_drcv]} { ::drcv::create_violation AUTO-FREQ-SCALING-07 -REF [list type OTHER -name $system_clk] -s $orig_clk_freq -s $new_clk_freq }
      }

      # write the new ocl frequency to the file "_new_clk_freq" regardless the clock has been scaled or not
      # in the case where the clock is not scaled, the new frequency would be same as original frequency
      puts $outfile "system:$clk_id:$system_clk:$new_clk_freq"
      append achieved "\nSystem: $system_clk = $new_clk_freq MHz "
    }

    close $outfile
    # This is the right place to affirm the final achieved frequencies for the scalable clock domains.
    if {[is_drcv]} { ::drcv::create_affirmation PLATFORM-CLOCK-DOMAINS-01 -s $achieved }
    return 1;
  }

  # retun the validated new ocl freq
  # new_clk_freq is an output argument
  # err_str is an output argument
  proc validate_new_clk_freq { clk_type clk_info clock_pin pin_clock_map clk_pin_freqs err_str new_clk_freq} {
    upvar $err_str _err_str
    upvar $new_clk_freq _new_clk_freq
    upvar $clk_pin_freqs _clk_pin_freqs
    upvar $pin_clock_map _pin_clock_map

    set max_frequency        [dict get $clk_info max_frequency]
    set min_frequency        [dict get $clk_info min_frequency]

    # clock_freqs can either be kernel_clock_freqs or system_clock_freqs depending on $clk_type 
    set clock_freqs [dict get $clk_info ${clk_type}_clock_freqs]  
    set clk $_pin_clock_map($clock_pin)
    set dict_clock [dict get $clock_freqs $clk]
    set orig_clk_freq [dict get $dict_clock freq]
    set orig_clk_freq [format "%.1f" $orig_clk_freq]
    set _new_clk_freq $_clk_pin_freqs($clock_pin)

    puts "$clk_type clock '$clk':"
    puts "   original frequency : ${orig_clk_freq} MHz"
    puts "   scaled frequency   : ${_new_clk_freq} MHz"
    if {[is_drcv]} { set clk_ref [::drcv::create_reference OTHER -name $clk] }

    # CR 964071: We should error out below 60Mhz. Nothing slower than this is supported
    # compiler.minFrequencyLimit
    if { $_new_clk_freq < $min_frequency } {
      set _err_str "auto frequency scaling failed because the auto scaled frequency '$_new_clk_freq MHz' is lower than the minimum frequency limit supported by the runtime ($min_frequency MHz)."
      if {[is_drcv]} {
        if {$clk_type eq $ocl_util::System} {
          # AUTO-FREQ-SCALING-05 is for system clock minimum
          ::drcv::create_violation AUTO-FREQ-SCALING-05 -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -s $min_frequency
        } else {
          # AUTO-FREQ-SCALING-02 is for kernel clock minimum
          ::drcv::create_violation AUTO-FREQ-SCALING-02 -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -s $min_frequency
        }
      }
      set _new_clk_freq $min_frequency
      return 0 
    }

    # runtime has a hard cap for maximum frequency of 500MHz, it the scaled frequency is larger 
    # than 500, we should cap it to 500.
    # compiler.maxFrequencyLimit
    if { $_new_clk_freq > $max_frequency } {
      puts "INFO: The maximum frequency supported by the runtime is $max_frequency MHz, which this design achieved. The compiler will not select a frequency value higher than the runtime maximum."
      if {[is_drcv]} {
        if {$clk_type eq $ocl_util::System} {
          # AUTO-FREQ-SCALING-06 is for system clock maximum
          ::drcv::create_affirmation AUTO-FREQ-SCALING-06 -s $max_frequency -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -actual_string_value $_new_clk_freq -threshold_string_value $max_frequency
        } else {
          # AUTO-FREQ-SCALING-03 is for kernel clock maximum
          ::drcv::create_affirmation AUTO-FREQ-SCALING-03 -s $max_frequency -REF $clk_ref -s $orig_clk_freq -s $_new_clk_freq -actual_string_value $_new_clk_freq -threshold_string_value $max_frequency
        }
      }
      set _new_clk_freq $max_frequency
    }

    # cap the new frequency so that it is not higher than orignal frequency
    if { $_new_clk_freq > $orig_clk_freq } {
      puts "WARNING: The auto scaled frequency '$_new_clk_freq MHz' exceeds the original specified frequency. The compiler will select the original specified frequency of '$orig_clk_freq' MHz."
      if {[is_drcv]} {
        # AUTO-FREQ-SCALING-08
        ::drcv::create_violation AUTO-FREQ-SCALING-08 -REF $clk_ref -s $_new_clk_freq -s $orig_clk_freq
      }
      set _new_clk_freq $orig_clk_freq
    }

    return 1
  }

  proc get_dsa_info {dsa_name dsa_file_name dsa_dcp_name ocl_region_name build_flow_name use_pr_name} {
    upvar $dsa_file_name dsa_file $dsa_dcp_name dsa_dcp $ocl_region_name ocl_region $build_flow_name build_flow $use_pr_name use_pr
    set dsa_path $env(RDI_ROOT)/data/sdaccel/board_support/$dsa_name/
    if { ![file exists $dsa_path] } {
      error "Could not find '$dsa_name' at $dsa_path"
    }
    set dsa_file [glob -nocomplain $dsa_path/*.dsa]
    if { [llength $dsa_file] != 1 } {
      error "Could not find single .dsa file in $dsa_path"
    }
    set cwd [pwd]
    set unzip_dir "$cwd/dsa_unzip/$dsa_name"
    file mkdir $unzip_dir
    cd $unzip_dir
    if { [catch {upzip $dsa_file} res] } {
      cd $cwd
      error "Problem unzipping dsa: $res"
    }
    cd $cwd

    set dsa_xml_file $unzip_dir/dsa.xml
    if { ![file exists $dsa_xml_file] } {
      set dsa_xml_file [glob -nocomplain $unzip_dir/*.xml]
      if { [llength $dsa_xml_file] != 1 } {
        error "Could not find DSA xml file in $unzip_dir"
      }
    }
    set dsa_dcp [glob -nocomplain $unzip_dir/*.dcp]
    if { [llength $dsa_dcp] != 1 } {
      error "Could not find DSA dcp file in $unzip_dir"
    }

    set fp [open "somefile" r]
    set file_data [read $fp]
    close $fp
    
    set data [split $file_data "\n"]
    set build_flow ""
    set ocl_region ""
    set use_pr ""
    foreach line $data {
      regexp {Build Flow="([^"]*)"} $line {} build_flow; #])" <-- fix vim syntax highlighting
      regexp {InstancePath="([^"]*)"} $line {} ocl_region; #])"
      regexp {Param Name="USE_PR" Value="([^"]*)"} $line {} use_pr; #])"
    }
  }; # end get_dsa_info

  proc get_achievable_kernel_freq {sysClkWnsTolerance kernelPinFreqArray sysPinFreqArray failingSysClksDict} {
    upvar $kernelPinFreqArray kernelPinFreqs
    upvar $sysPinFreqArray sysPinFreqs
    upvar $failingSysClksDict failingSysClks

    # initialize combined_pin_freqs
    foreach k_k [array names kernelPinFreqs] {
      set combined_pin_freqs($k_k) $kernelPinFreqs($k_k)
    }
    foreach s_k [array names sysPinFreqs] {
      set combined_pin_freqs($s_k) $sysPinFreqs($s_k)
    }

    #scale clocks
    set ret [get_achievable_kernel_freq_ $sysClkWnsTolerance combined_pin_freqs failingSysClks]
    if { $ret == "0" } {
      return $ret
    }

    #update pin freq arrays
    foreach k_k [array names kernelPinFreqs] {
      set kernelPinFreqs($k_k) $combined_pin_freqs($k_k)
    }
    foreach s_k [array names sysPinFreqs] {
      set sysPinFreqs($s_k) $combined_pin_freqs($s_k)
    }

    return $ret
  }

  # Compute the acheivable kernel frequency
  # Authur: Steven Li 
  # Input: sysClkWnsTolerance: the tolerance in which we consider the system clocks as meeting timing, typical value 0ns or -0.1ns. 
  #        kernelPinFreqArray - array containing the kernel clock pin names and their corresponding the returned scale freq
  #
  # Return: A list of achievable kernel frequencies in MHz unit with 1 decimal point
  #         For each kernel clock pin, compute the achievable kernel frequency, or unchange if the kernel clock pin is not found, or it's not connected to a clock
  #         The computed scaled frequencies are stored in the kernelPinFreqArray
  #         0 if any system clock slack < sysClkWnsTolerance
  #         1 if success

  proc get_achievable_kernel_freq_ {sysClkWnsTolerance kernelPinFreqArray failingSysClksDict} {
    upvar $kernelPinFreqArray kernelPinFreqs
    upvar $failingSysClksDict failingSysClks
    # puts "--- DEBUG: sysClkWnsTolerance is $sysClkWnsTolerance"
    # foreach kernel_pin [array names kernelPinFreqs] {
    #   set new_ocl_freq $kernelPinFreqs($kernel_pin)
    #   puts "--- DEBUG: $kernel_pin : $new_ocl_freq"
    # }

    set kernelClksToScale 0
    set success 1

    foreach kernelClkPin [array names kernelPinFreqs] {
      set pin [get_pins $kernelClkPin]
      if {$pin == ""} {
        # kernel clock pin is unconnected and optimized away
        puts "INFO: Pin $kernelClkPin not found"
        continue
      }

      set clk [get_clocks -of_objects $pin]
      if {$clk == ""} {
        # kernel clock pin is unconnected
        puts "INFO: Pin $pin has no clock"
        continue
      }
      puts "--- DEBUG: clock is '$clk' for pin '$pin'"

      # for dynamic platform (due to the dr bd boundary), it is a valid case
      # to NOT have a timing path for the secondary clock (which is used to
      # drive rtl kernel)
      set tps [get_timing_paths -group $clk]
      if {[llength $tps] == 0} {
        # kernel clock does not have timing paths
        puts "INFO: Clock $clk has no timing paths"
        continue
      }
      
      if {[info exists clkToKernelPins($clk)]} {
        lappend clkToKernelPins($clk) $kernelClkPin
      } else {
        set clkToKernelPins($clk) [list $kernelClkPin]
      }

      set kernelPinFreqs($kernelClkPin) 0
      incr kernelClksToScale 1
    }

    # puts "--- DEBUG: kernelClksToScale is $kernelClksToScale"
    # foreach _clk [array names clkToKernelPins] {
    #   set _pins $clkToKernelPins($_clk)
    #   puts "--- DEBUG: kernel clk '$_clk': $_pins"
    # }

    set tps [get_timing_paths -max_paths 1 -sort_by group]

    # tps is already sorted from worst clock to best clock
    # loop through each clock until slack >= sysClkWnsTolerance and the kernel freq is computed
    foreach tp $tps {
      set slk [get_property SLACK $tp]
      set grp [get_property GROUP $tp]
      # puts "--- DEBUG: Path=$tp\n\t Group=$grp Slack=$slk"
      #report_property $tp

      if {$grp == "**async_default**"} {
        continue
      }

      if {$slk < $sysClkWnsTolerance} {
        # puts "--- DEBUG: \$slk < \$sysClkWnsTolerance"
        if {[info exists clkToKernelPins($grp)]} {
          # puts "--- DEBUG: grp '$grp' exists in clkToKernelPins"
          set period [get_property PERIOD [get_clocks [get_property ENDPOINT_CLOCK $tp]]]
          set freq [expr int(10000.0 / ($period - $slk)) / 10.0]
          # puts "--- DEBUG: freq = $freq"

          foreach kernelPin $clkToKernelPins($grp) {
            # puts "--- DEBUG: set kernelPinFreqs($kernelPin) to $freq"
            set kernelPinFreqs($kernelPin) $freq
            incr kernelClksToScale -1
          }
        } else {
          # negative WNS for system clock, cannot scale frequency
          puts "WARNING: cannot scale kernel clocks: the failing system clock is $grp:$slk, the wns tolerance is $sysClkWnsTolerance"
          dict set failingSysClks $grp $slk
          # continue with other clocks until the scaled freq of all kernel clocks are computed
          set success 0
        }
      } else {
        # slack is better than $sysClkWnsTolerance
        # puts "--- DEBUG: \$slk > \$sysClkWnsTolerance"
        if {$kernelClksToScale == 0} {
          return $success
        } else {
          if {[info exists clkToKernelPins($grp)]} {
            # puts "--- DEBUG: grp '$grp' exists in clkToKernelPins"
            # Kernel slack is within the tolerance.  Treat it as 0 so as to compute the target frequency
            if {$slk < 0} {
              set slk 0
            }
            set period [get_property PERIOD [get_clocks [get_property ENDPOINT_CLOCK $tp]]]
            set freq [expr int(10000.0 / ($period - $slk)) / 10.0]
        
            # puts "freq: $freq"

            foreach kernelPin $clkToKernelPins($grp) {
              # puts "--- DEBUG: set kernelPinFreqs($kernelPin) to $freq"
              set kernelPinFreqs($kernelPin) $freq
              incr kernelClksToScale -1
            }
          }
        }
      }
    }

    # all the clocks in kernelPinFreqs should be scaled at this point
    if { $kernelClksToScale > 0 } {
      puts "WARNING: there are $kernelClksToScale clock(s) that couldn't be scaled, scaling algorithm needs to be checked"
      # set success 0
    }

    # Not all kernel clocks are found
    return $success
}

  # round down any number to an integer
  proc round_down {val} {
    set fl [expr {floor($val)}]
    set retval [format "%.0f" $fl]
    return $retval
  }; # end round_down  

  # convert frequency in MHz to period in ns
  proc convert_freq_to_period {freq} {
    return [expr {1000.000 / $freq}]
  }; # end convert_freq_to_period

  # convert period in ns to frequency in MHz
  proc convert_period_to_freq {period} {
    return [expr {1000 / $period}] 
  }; # end convert_period_to_freq

  # initialize clkwiz debug instance run
  proc initialize_clkwiz_debug {} {
    load librdi_iptasks.so
    set partinfo [get_property PART [current_project]]
    Init_Clkwiz [current_project] test1 $partinfo
  }; # end initialize_clkwiz_debug

  # un-initialize clkwiz debug instance run
  proc uninitialize_clkwiz_debug {} {
    UnInit_Clkwiz [current_project] test1
  }; # end uninitialize_clkwiz_debug

  # get property from clkwiz instance
  proc get_clkwiz_prop {prop} {
    set val [GetClkwizProperty [current_project] test1 $prop]
    return $val
  }; # end get_clkwiz_prop

  # set clkwiz instance properties
  proc set_clkwiz_prop {clock_freq_orig clock_freq} {
    SetClkwizProperty [current_project] test1 UseFinePS true 
    # GetClosestSolution <project_name> <instance_name> <requested output frequencies of clks separated by spaces> <requested phases of clocks separated by spaces> <requested duty cycles of clocks separated by spaces> <primary clock frequency> <secondary clock frequency> <number of output clocks> <minimum output jiter used> <non default phase or duty cycle> <primitive (MMCM or PLL)> <debug mode> <clkout XiPhy Enable> <clkout XiPhy Freq>
    GetClosestSolution [current_project] test1 $clock_freq 0 50 $clock_freq_orig 0 1 false false false false false false
  }; # end set_clkwiz_prop

  # create clock constraint(s) on the output pin of mmcm for implementation, overwriting a default generated clock
  proc write_user_impl_clock_constraint {inst dict_clock_freqs steps_log output_dir} {
    set uninit_wiz true
    set user_impl_clk_xdc "_user_impl_clk.xdc"
    set fo_xdc_file [open $output_dir/$user_impl_clk_xdc w]

    foreach clock_name [dict keys $dict_clock_freqs] {
      set dict_clock [dict get $dict_clock_freqs $clock_name]
      set is_user_set [dict get $dict_clock is_user_set]
      if { [string equal -nocase $is_user_set "true" ] } {
        set clock_freq [dict get $dict_clock freq]
        #set clock_freq_orig [dict get $dict_clock freq_orig]
        set outpin_mmcm [get_pins [get_property SOURCE_PINS [get_clocks -of_objects [get_pins $inst/$clock_name]]]]
        set gclock [get_clocks -of_objects [get_pins $outpin_mmcm]]
        set gclock_name [get_property NAME $gclock]
        set inpin_mmcm [get_property SOURCE $gclock]
        set clock_period [get_property PERIOD [get_clocks -of_objects [get_pins $inpin_mmcm]]]  
        set clock_freq_orig [round_down [convert_period_to_freq $clock_period]]
        if { $uninit_wiz } {
          initialize_clkwiz_debug
          set uninit_wiz false
        }
        set_clkwiz_prop $clock_freq_orig $clock_freq
        set clkout0_divide [round_down [get_clkwiz_prop ChosenDiv0]]
        set divclk_divide [round_down [get_clkwiz_prop ChosenD]]
        set divide_by [expr {$clkout0_divide * $divclk_divide}]
        set multiply_by [round_down [get_clkwiz_prop ChosenM]]
    
        puts "--- DEBUG: write_user_impl_clock_constraint:\n\tcreate_generated_clock -name $gclock_name -divide_by $divide_by -multiply_by $multiply_by -source $inpin_mmcm $outpin_mmcm"
        # create_generated_clock -name $gclock_name -divide_by $divide_by -multiply_by $multiply_by -source $inpin_mmcm $outpin_mmcm
        puts $fo_xdc_file "\n# Kernel clock overridden by user"
        puts $fo_xdc_file "create_generated_clock -name $gclock_name -divide_by $divide_by -multiply_by $multiply_by -source $inpin_mmcm $outpin_mmcm"

        #puts "DBG: $clock_freq_orig, $clock_freq, $gclock_name, $divide_by, $multiply_by, $inpin_mmcm, $outpin_mmcm"
        #create_clock -name USER_$clock_name -period $clock_period $source_pin
      }
    }
    close $fo_xdc_file 
    # read_xdc applies the constraints immediately if a design is open
    # read_xdc behaves same as add_files if there is no open design
    if {$steps_log ne ""} {
      add_to_steps_log $steps_log "internal step: read_xdc $output_dir/$user_impl_clk_xdc"
    }
    read_xdc $output_dir/$user_impl_clk_xdc
    
    if { !$uninit_wiz } {
      uninitialize_clkwiz_debug 
    }
  }; # end write_user_impl_clock_constraint

  # create clock constraint(s) for synthesis, overwriting the default frequency from dsa
  proc write_user_synth_clock_constraint {xdc_file dict_clock_freqs} {
    set fo_xdc_file [open ./$xdc_file a]
    foreach clock_name [dict keys $dict_clock_freqs] {
      set dict_clock [dict get $dict_clock_freqs $clock_name]
      set is_user_set [dict get $dict_clock is_user_set]
      if { [string equal -nocase $is_user_set "true" ] } {
        set clock_freq [dict get $dict_clock freq]
        set clock_period [convert_freq_to_period $clock_freq]
        puts $fo_xdc_file "\n# Kernel clock overridden by user"
        puts $fo_xdc_file "create_clock -name USER_$clock_name -period $clock_period \[get_ports $clock_name\]"
        puts "--- DEBUG: write_user_synth_clock_constraint:\n\tcreate_clock -name USER_$clock_name -period $clock_period \[get_ports $clock_name\]"
      }
    }
    close $fo_xdc_file 
  }; # end write_user_synth_clock_constraint 

  # set a board_part_repo_paths property given two lists which are added in order. (first one wins)
  proc set_board_repo_paths_property { from_first from_second } {
    set board_property [list]
    if { $from_first ne "" } {
      lappend board_property {*}$from_first
    }
    if { $from_second ne "" } {
      lappend board_property {*}$from_second
    }
    if { $board_property ne "" } {
      puts "--- DEBUG: set_property board_part_repo_paths $board_property \[current_project\]"
      set_property board_part_repo_paths $board_property [current_project]
    } 
  }; # end set_board_repo_paths_property 

  # set a board_connections property given three lists which are added in order. (last one wins)
  proc set_board_connections_property { from_first from_second from_third} {
    set board_property [list]
    if { $from_first ne "" } {
      lappend board_property {*}$from_first
    }
    if { $from_second ne "" } {
      lappend board_property {*}$from_second
    }
    if { $from_third ne "" } {
      lappend board_property {*}$from_third
    }
    if { $board_property ne "" } {
      puts "--- DEBUG: set_property board_connections $board_property \[current_project\]"
      set_property board_connections $board_property [current_project]
    }
  }; # end set_board_connections_property

  # generate a resource demand report per ip instance after OOC synth is done 
  proc generate_resource_report { output_dir steps_log } {
    set sdx_all_ips [get_ips -quiet -all -filter "SDX_KERNEL==true"]
    puts "--- DEBUG: get_ips -quiet -all -filter \"SDX_KERNEL==true\": $sdx_all_ips"
    set size_all_ips [llength $sdx_all_ips]

    if { $size_all_ips > 0 } {
      set resource_usage_report [file join $output_dir "resource.json"]
      add_to_steps_log $steps_log "internal step: generating resource usage report '${resource_usage_report}'"
      set rdata_file [open $resource_usage_report "w"]
      puts $rdata_file "\{"
      puts $rdata_file "    \"Used Resources\": \["
      set index_ip 0

      foreach sdx_ip $sdx_all_ips {
        puts $rdata_file "        \{"
        puts $rdata_file "            \"ip_instance\": \"$sdx_ip\","

        set rdata [get_property dcp_resource_data $sdx_ip]
        puts "--- DEBUG: get_property dcp_resource_data $sdx_ip: $rdata"
        puts $rdata_file "            \"resources\": \["
        set rdata_list [regexp -all -inline {\S+} $rdata]
        set size_rdata_list [llength $rdata_list]
        if { $size_rdata_list > 0 } {
          set index_rdata 0
          foreach rdata_item $rdata_list {
            incr index_rdata
            set is_odd [expr {($index_rdata % 2) != 0}]
            if { $is_odd } {
              puts $rdata_file "                \{"
              puts -nonewline $rdata_file "                    \"$rdata_item\": "
            } else {
              puts $rdata_file "\"$rdata_item\""
              if { $index_rdata == $size_rdata_list } {
                puts $rdata_file "                \}"
              } else {
                puts $rdata_file "                \},"
              }
            }
          }
        }
        puts $rdata_file "            \]"
        #puts "--- DEBUG: reporting IP properties of $sdx_ip"
        #report_property $sdx_ip

        incr index_ip
        if { $index_ip == $size_all_ips } {
          puts $rdata_file "        \}"
        } else {
          puts $rdata_file "        \},"
        }
      }

      puts $rdata_file "    \]"
      puts $rdata_file "\}"
      close $rdata_file
    }
  }; # end generate_resource_report 

  ################################################################################
  # get_clk_from_intf_pin
  #   Description:
  #     Get clock pin given AXI interface pin
  #   Arguments:
  #     intfPin          AXI interface pin
  ################################################################################
  proc get_clk_from_intf_pin {intfPin} {
    set currPin [get_bd_intf_pins $intfPin -quiet]
    set currCell [get_bd_cells -of_objects $currPin -quiet]
    if {$currCell eq ""} {
      puts "WARNING: unable to find clock from interface pin $intfPin"
      return ""   
    }
    
    # Non-hierarchy method
    set pinName [string range $intfPin [expr [string last "/" $intfPin]+1] [string length $intfPin]]
    #puts "--- DEBUG get_clk_from_intf_pin: pin = $intfPin, cell = $currCell, pinName = $pinName"

    set clockPins [get_bd_pins -of_objects $currCell -filter {TYPE == clk}]
    #puts "--- DEBUG get_clk_from_intf_pin: clock pins = $clockPins"
    foreach clockPin $clockPins {
      set associatedBusif [get_property CONFIG.ASSOCIATED_BUSIF $clockPin]
      if {[string first $pinName $associatedBusif] >= 0} {
        return $clockPin
      }
    }
    
    # Hierarchical method
    #puts "--- DEBUG get_clk_from_intf_pin: use hierarchical method..."
    set connObj [find_bd_objs -quiet -relation connected_to -boundary_type lower -stop_at_interconnect -thru_hier $currPin]
    set connCell [get_bd_cells -quiet -of_objects $connObj]
    set pinName [string range $connObj [expr [string last "/" $connObj]+1] [string length $connObj]]
    #puts "--- DEBUG get_clk_from_intf_pin: object = $connObj, cell = $connCell, pin = $pinName"

    set clockPins [get_bd_pins -of_objects $connCell -filter {TYPE == clk}]
    #puts "--- DEBUG get_clk_from_intf_pin: clock pins = $clockPins"
    foreach clockPin $clockPins {
      set associatedBusif [get_property CONFIG.ASSOCIATED_BUSIF $clockPin]
      if {[string first $pinName $associatedBusif] >= 0} {
        return $clockPin
      }
    }
    
    return ""
  }
   
  ################################################################################
  # get_reset_from_intf_pin
  #   Description:
  #     Get reset pin given AXI interface pin
  #   Arguments:
  #     intfPin          AXI interface pin
  ################################################################################
  proc get_reset_from_intf_pin {intfPin} {
    set clockPin [get_clk_from_intf_pin $intfPin]
    set currPin [get_bd_intf_pins $intfPin -quiet]
    set currCell [get_bd_cells -of_objects $currPin -quiet]
    if {$currCell eq ""} {
      puts "WARNING: unable to find reset from interface pin $intfPin"
      return "" 
    }
    
    set resetPin [string tolower [get_property CONFIG.ASSOCIATED_RESET $clockPin -quiet]]
    #puts "--- DEBUG get_reset_from_intf_pin: ASSOCIATED_RESET clockPin = $clockPin, resetPin = $resetPin"
    # Grab first one if multiple ones are listed
    if {[string first ":" $resetPin] >= 0} {
      set resetPin [string range $resetPin 0 [expr [string first ":" $resetPin] - 1]]
    }
    
    if {$resetPin eq ""} {
      # Hierarchical method
      #puts "--- DEBUG get_reset_from_intf_pin: use hierarchical method..."
      set connObj [find_bd_objs -quiet -relation connected_to -boundary_type lower -stop_at_interconnect -thru_hier $currPin]
      set connCell [get_bd_cells -quiet -of_objects $connObj]
      set pinName [string range $connObj [expr [string last "/" $connObj]+1] [string length $connObj]]
      #puts "--- DEBUG get_reset_from_intf_pin: object = $connObj, cell = $connCell, pin = $pinName"

      set resetPins [get_bd_pins -quiet -of_objects $connCell -filter {TYPE == rst} -quiet]
      #puts "--- DEBUG get_reset_from_intf_pin: reset pins = $resetPins"
      foreach resetPin $resetPins {
        return $resetPin
      }
    
      # Find it another way
      set resetPin [lindex [get_bd_pins -of_objects $currCell -filter {TYPE == rst} -quiet] 0]
      if {$resetPin eq ""} {
        puts "WARNING: unable to find reset from interface pin $intfPin"
        set resetPin [get_bd_pins -quiet "/memory_subsystem/aresetn"]
      }
      return "$resetPin"
    }
    
    set hierName [string range $clockPin 0 [expr [string last "/" $clockPin] - 1]]
    set hierNet [get_bd_nets -quiet -of_objects [get_bd_pins -quiet $hierName/$resetPin]]
    set hierDriverPin [lindex [get_bd_pins -quiet -of_objects $hierNet -filter {DIR == O}] 0]
    puts "--- DEBUG get_reset_from_intf_pin: name = $hierName, net = $hierNet, driver pin = $hierDriverPin"
    if {$hierDriverPin eq ""} {
      return "$currCell/$resetPin"
    }
    return $hierDriverPin
  }
  
  ################################################################################
  # get_axi_lite_interconnect
  # get_axi_lite_clk
  # get_axi_lite_reset
  #   Description:
  #     Get AXI Lite interconnect, clock, and reset
  #   Arguments:
  #     none
  ################################################################################
  set axiLiteIntercon "interconnect_axilite_user"
  
  proc set_axi_lite_interconnect {ipCell} {
    global axiLiteIntercon
    #set axiLitebdnet [get_bd_intf_nets -of_objects [get_bd_intf_pins -of_objects $ip_cell -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}]]
    #set axiLiteInterconList [get_bd_cells -hier -of_objects [get_bd_intf_pins -of_objects $axiLitebdnet -filter {MODE == Master}]]
    #set axiLiteIntercon [lindex $axiLiteInterconList 0]
    
    set axiLitePin [get_bd_intf_pins -of_objects $ipCell -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}]
    set axiLiteObj [find_bd_objs -relation connected_to -stop_at_interconnect -thru_hier $axiLitePin]
    set axiLiteIntercon [get_bd_cells -of_objects $axiLiteObj]
    
    puts "--- DEBUG set_axi_lite_interconnect:"
    puts "--- DEBUG   IP cell : $ipCell"
    puts "--- DEBUG   AXI-Lite pin : $axiLitePin"
    puts "--- DEBUG   AXI-Lite interconnect : $axiLiteIntercon"
  }

  proc get_axi_lite_interconnect {} {
    global axiLiteIntercon
    return $axiLiteIntercon
  }
  
  proc get_axi_lite_clk {} {
    set interconName [get_axi_lite_interconnect]
    set mgmt_clk [find_bd_objs -relation connected_to -thru_hier -stop_at_interconnect [get_bd_pins $interconName/S00_ACLK] ]
    return $mgmt_clk
  }
  
  proc get_axi_lite_reset {} {
    set interconName [get_axi_lite_interconnect]
    set mgmt_reset [find_bd_objs -relation connected_to -thru_hier -stop_at_interconnect [get_bd_pins $interconName/S00_ARESETN] ]
    return $mgmt_reset
  }
  
  # Global variable for debug and profile IP data
  set debug_ip_list [list]
   
  ################################################################################
  # add_debug_ip
  #   Description:
  #     Add to list of debug IP
  #   Arguments:
  #     type          type of IP (string in debug_ip_types dict)
  #     instance      name of instance (used for matching to get base address)
  #     name          name string used in metadata (e.g., cu_name/port_name)
  #     properties    core-specific properties (default is 0)
  ################################################################################
  proc add_debug_ip { type instance {name "none"} {properties 0} } {
    global debug_ip_list
    set debug_ip [dict create type $type instance $instance name $name properties $properties]
    lappend debug_ip_list $debug_ip
  }
  
  proc write_debug_ip_entry { fp type index properties base_address name last } {
    puts $fp "      \"debug_ip_data\": \{"
    puts $fp "        \"m_type\": \"$type\","
    puts $fp "        \"m_index\": \"$index\","
    puts $fp "        \"m_properties\": \"$properties\","
    puts $fp "        \"m_base_address\": \"$base_address\","
    puts $fp "        \"m_name\": \"$name\""
    if { $last } {
      puts $fp "      \}"
    } else {
      puts $fp "      \},"
    }
  }
  
  ################################################################################
  # write_debug_ip_unip
  #   Description:
  #     Write out DEBUG_IP_LAYOUT.json file
  #   Arguments:
  #     none    
  ################################################################################
  proc write_debug_ip_unip { output_dir } {
    # Note: there is already an open bd design

    global debug_ip_list
    #global debug_ip_types
    set debug_ip_types { "UNDEFINED" 0 "LAPC" 1 "ILA" 2 "AXI_MM_MONITOR" 3 \
      "AXI_TRACE_FUNNEL" 4 "AXI_MONITOR_FIFO_LITE" 5 "AXI_MONITOR_FIFO_FULL" 6 }
      
    if {![info exists debug_ip_list]} {
      return
    }
    
    set major_version 1
    set minor_version 0
    set patch 0
    set num_entries [llength $debug_ip_list]
    
    # No file written if no debug IP to report
    if {$num_entries == 0} {
      return
    }
    
    # set outfile ./debug_ip_layout.rtd
    set outfile $output_dir/debug_ip_layout.rtd
    puts "--- DEBUG: writing $outfile"
    set fp [open $outfile w]

    # write header
    puts $fp "\{"
    puts $fp "  \"schema_version\": \{"
    puts $fp "    \"major\": \"${major_version}\","
    puts $fp "    \"minor\": \"${minor_version}\","
    puts $fp "    \"patch\": \"${patch}\""
    puts $fp "  \},"
    puts $fp "  \"debug_ip_layout\": \{"
    puts $fp "    \"m_count\": \"${num_entries}\","
    puts $fp "    \"m_debug_ip_data\": \{"

    set i 0
    set addr_segs [get_bd_addr_segs -hier]
    
    foreach debug_ip $debug_ip_list {
      set type [dict get $debug_ip type]
      #set typenum [dict_get_default $debug_ip_types $type [dict get $debug_ip_types UNDEFINED]]
      set instance [dict get $debug_ip instance]
      set properties [dict get $debug_ip properties]
      set name [dict get $debug_ip name]
      #set name [string map {"/" "."} $name]
      if {[string index $name 0] == "/"} {
        set name [string range $name 1 [string length $name]]
      }
      
      set base_address 0xdeadbeef
      
      set index 0
      scan [regexp -inline {\d?\d} $instance] "%d" index

      # get base address (search address segs)
      foreach addr_seg $addr_segs {           
        set offset [get_property OFFSET $addr_seg]
        if {$offset != ""} {
          #set range [format 0x%X [get_property RANGE $addr_seg]]                 
          set slave [get_bd_addr_segs -of_object $addr_seg]

          # Catch incompatible trace FIFO addresses
          set foundFull [string first FULL $slave]
          if {($type == "AXI_MONITOR_FIFO_LITE" && $foundFull >= 0)
               || ($type == "AXI_MONITOR_FIFO_FULL" && $foundFull < 0)} {
            continue 
          }
          
          if { ![regexp {([^/]+)/([^/]+)/([^/]+)$} $slave match slaveRef slaveMemoryMap slaveSegment] } {
            puts "--- DEBUG: slave doesn't match regular expression (slave: $slave)"
            continue
          }
          #puts "slave = $slave, instance = $instance, slaveRef = $slaveRef, offset = $offset"
          # Accelerator monitors include name of CU. We need to explicitely specify those
          if {[string first $slaveRef $instance] >= 0} {
            if {[string first xilmonitor $instance] >= 0 && [string first xilmonitor $slaveRef] < 0} {
              continue
            }
            set base_address $offset
            break
          }
        }
      }
      
      incr i
      set last [expr {($i == $num_entries) ? true : false}]
      puts "--- DEBUG IP: inst = ${instance}, type = ${type}, addr = ${base_address}, name = ${name}"
      write_debug_ip_entry $fp $type $index $properties $base_address $name $last
    }
    
    # write footer
    puts $fp "    \}"
    puts $fp "  \}"
    puts $fp "\}"
    close $fp
  }; # end write_debug_ip_unip
  
  ################################################################################
  # write_cu_masters_unip
  #   Description:
  #     writes list of all CU masters for monitoring purposes
  #   Arguments:
  #     none
  ################################################################################
  proc write_cu_masters_unip {} {
    set fd [open "./cu_masters.info" "w"]
    set cu_instances [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    set cu_masters [get_bd_intf_pins -quiet -of $cu_instances -filter "Mode==Master"]
    foreach master $cu_masters {
      puts $fd [string map {"/" ":"} [string trimleft $master "/"]]
    }
    close $fd
  }

  ################################################################################
  # get_host_masters
  #   Description:
  #     gets a list of host masters
  #     NOTE: for v5.2 platforms, this includes multiple masters
  #   Arguments:
  #     none
  ################################################################################
  proc get_host_masters {} {
    set hostList [list]
    
    if {[get_bd_intf_pins "axi_vip_data/M_AXI" -quiet] != {}} {
      lappend hostList "axi_vip_data/M_AXI"
    } elseif {[get_bd_intf_pins "aws_0/M_AXI_PCIS" -quiet] != {}} {
      lappend hostList "aws_0/M_AXI_PCIS"
    } else {
      # find AXI-MM slaves on memory subsystem
      set slaves [get_bd_intf_pins -of_objects [get_bd_cells "memory_subsystem"] -filter {CONFIG.PROTOCOL == AXI4 && MODE == Slave}]
      foreach slave $slaves {
        set net [get_bd_intf_nets -of_objects $slave]
        set master [get_bd_intf_pins -of_objects $net -filter {MODE == Master}]
        set masterCell [get_bd_cells -quiet -hier -of_objects $master -filter {SDX_KERNEL != true}]
        if {$masterCell != {}} {
          lappend hostList $master 
        }
      }
    }
    
    return $hostList
  }
  
  ################################################################################
  # update_unified_profiling
  #   Description:
  #     add profiling for unified platforms, including monitoring:
  #     host and kernel masters, protocols for HW emulation, and 
  #     stall monitoring (in 2018.x)
  #   Arguments:
  #     profile_info     profile dictionary from compiler
  #     dsa_dr_bd        dynamic region block diagram
  #     is_hw_emu        true: is HW emulation; false: not HW emulation
  #     kernel_debug     true: kernel debug is on; false: kernel debug is off
  ################################################################################
  proc update_unified_profiling { profile_info dsa_dr_bd is_hw_emu kernel_debug } {
    # NOTE: the BD of the dynamic region is assumed to be open
    set name [dict_get_default $profile_info NAME "profile_monitors"]
    # Host and kernel masters (board only)
    if { !$is_hw_emu && ($profile_info != {})} {
      puts "--- DEBUG: Adding profiling of host and kernel masters..."

      set slots [dict get $profile_info DATA]
      set stallSlots [dict get $profile_info STALL]
      set execSlots [dict get $profile_info EXEC]
      set numDataSlots [llength $slots]
      set numStallSlots [llength $stallSlots]
      set numExecSlots [llength $execSlots]
      set is_exec_enabled [expr {$numDataSlots == 0 && $numStallSlots == 0 ? 1 : 0}]
      # Trace Infrastructure is setup based on this flag
      set useTrace 0
      if {$is_exec_enabled} {
          foreach data $execSlots {
            if {[dict get $data option] eq "all"} {set useTrace 1}
          }
      } else {
          foreach data $slots {
            if {[dict get $data option] eq "all"} {set useTrace 1}
          }
          foreach data $stallSlots {
            if {[dict get $data option] eq "all"} {set useTrace 1}
          }
      }
      puts "--- DEBUG: useTrace : $useTrace"

      # Trace back to axi lite interconnect from the first slot
      if {$is_exec_enabled} {
        if {!$numExecSlots} {
          puts "WARNING: Empty profile data..ignoring profiling"
          return
        }
        set firstCUCell [get_bd_cells [dict get [lindex $execSlots 0] port]]
      } else {
        if {$numDataSlots} {
          set firstPort [dict get [lindex $slots 0] port]
          set firstCUCell [get_bd_cells -of_objects [get_bd_intf_pins $firstPort]]  
        } else {
          set firstCUCell [get_bd_cells [dict get [lindex $stallSlots 0] port]]
        }
      }
      set_axi_lite_interconnect $firstCUCell

      # Set default mon clock for trace IPs
      set default_ap_clk [lrange [get_bd_pins -of_objects $firstCUCell -filter {Type=="clk"}] 0 0]
      set default_ap_rst [lrange [get_bd_pins -of_objects $firstCUCell -filter {Type=="rst"}] 0 0]
      if {$default_ap_rst == ""} {
        set default_ap_rst [get_bd_pins "/memory_subsystem/aresetn"]
      }
      # Free up AXI lite master
      set axiLiteIntercon [get_axi_lite_interconnect]
      set liteMaster [get_bd_intf_pins $axiLiteIntercon/M00_AXI]
      set liteSlave [get_bd_intf_pins -of_objects [get_bd_intf_nets -of_objects $liteMaster] -filter {Mode=="Slave"}]
      delete_bd_objs [get_bd_cells -of_objects $liteSlave]
        
      # Specify trace clock/reset
      set traceClock  [get_axi_lite_clk]
      set traceReset  [get_axi_lite_reset]
      set hostMasters [get_host_masters]
      
      # Add master and clock for AXI full
      # NOTE: assumes only one profiler
      set fullMaster "dummy"
      if {$useTrace} {
        set axiFullIntercon memory_subsystem/interconnect_data/interconnect_aximm_host
        
        # Case #1: non-dynamic platforms (e.g., xilinx_kcu1500_4ddr-xpr_5_0)
        if {[get_bd_cells $axiFullIntercon -quiet] != {}} {     
          # Add and connect a clock
          set currNumClocks [get_property CONFIG.NUM_CLKS [get_bd_cells $axiFullIntercon]]
          set_property CONFIG.NUM_CLKS [expr $currNumClocks + 1] [get_bd_cells $axiFullIntercon]
          connect_bd_net $traceClock [get_bd_pins $axiFullIntercon/aclk1]
          # Add a master
          set currNumMasters [get_property CONFIG.NUM_MI [get_bd_cells $axiFullIntercon]]
          set_property CONFIG.NUM_MI [expr $currNumMasters + 1] [get_bd_cells $axiFullIntercon]
          set fullMaster [get_bd_intf_pins $axiFullIntercon/M0${currNumMasters}_AXI]
        # Case #2: dynamic platforms, v5.2
        } elseif {[get_bd_intf_pins "regslice_data_periph_M_AXI" -quiet] != {}} {
          if {[get_bd_cells "regslice_periph_null" -quiet] != {}} {
            delete_bd_objs [get_bd_cells "regslice_periph_null"]
          }
      
          set fullMaster [get_bd_intf_pins "regslice_data_periph_M_AXI"]
          
          set traceClock [get_clk_from_intf_pin $fullMaster]
          #set traceReset [get_reset_from_intf_pin $fullMaster]
          set traceReset [get_bd_pins "slr0/reset_controllers/psreset_gate_pr_data_interconnect_aresetn"]
          puts "--- DEBUG setting trace clock = $traceClock, reset = $traceReset"
        # Case #3: dynamic platforms, v5.0 or v5.1
        } else {
          set hostInterconName "interconnect_aximm_host"
          # Must be dynamic platform!
          # For now, rip out current connection and add 1x2 SmartConnect
          set hostMaster [lindex $hostMasters 0]
          set hostDataWidth [get_property CONFIG.DATA_WIDTH [get_bd_intf_pins $hostMaster]]
          set hostNet [get_bd_intf_nets -of_objects [get_bd_intf_pins $hostMaster]]
          set hostSlavePin [get_bd_intf_pins -of_objects $hostNet -filter {MODE == Slave}]
          delete_bd_objs $hostNet
          set hostIntercon [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect $hostInterconName]
          set_property CONFIG.NUM_SI 1 $hostIntercon
          set_property CONFIG.NUM_MI 2 $hostIntercon
          set_property CONFIG.NUM_CLKS 2 $hostIntercon

          # CR 994345: add bypass reg slice to specify data width
          set hostRegName "reg_aximm_host" 
          set hostReg [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice $hostRegName]
          set_property CONFIG.DATA_WIDTH.VALUE_SRC USER $hostReg
          set_property CONFIG.DATA_WIDTH $hostDataWidth $hostReg
          set_property CONFIG.REG_AW 0 $hostReg
          set_property CONFIG.REG_AR 0 $hostReg
          set_property CONFIG.REG_W  0 $hostReg
          set_property CONFIG.REG_R  0 $hostReg
          set_property CONFIG.REG_B  0 $hostReg

          set hostClock [get_clk_from_intf_pin $hostMaster]
          set hostReset [get_reset_from_intf_pin $hostMaster]
          connect_bd_net [get_bd_pins $hostClock] [get_bd_pins $hostInterconName/aclk]
          connect_bd_net [get_bd_pins $hostReset] [get_bd_pins $hostInterconName/aresetn]
          connect_bd_net [get_bd_pins $hostClock] [get_bd_pins $hostRegName/aclk]
          connect_bd_net [get_bd_pins $hostReset] [get_bd_pins $hostRegName/aresetn]
          connect_bd_net $traceClock [get_bd_pins $hostInterconName/aclk1]

          connect_bd_intf_net [get_bd_intf_pins $hostMaster] [get_bd_intf_pins $hostInterconName/S00_AXI]
          connect_bd_intf_net [get_bd_intf_pins $hostInterconName/M00_AXI] [get_bd_intf_pins $hostRegName/S_AXI]
          connect_bd_intf_net [get_bd_intf_pins $hostRegName/M_AXI] $hostSlavePin
          set fullMaster [get_bd_intf_pins $hostInterconName/M01_AXI]
          # Specify new host master
          lset hostMasters 0 "$hostInterconName/M00_AXI"
        } 
      }
      
      # Create complete list for data profiling (hosts + kernels)
      set dataSlots [list]
      set numHostMasters [llength $hostMasters]
      foreach hostMaster $hostMasters {
        lappend dataSlots [dict create port $hostMaster option counters host 1]
      }
      foreach kernelMaster $slots {
        dict append kernelMaster host 0
        lappend dataSlots $kernelMaster
      }
      
      puts "--- DEBUG: Adding kernel data profiling $name - lite master: $liteMaster, full master: $fullMaster useTrace : $useTrace"
      puts "--- DEBUG:   trace clock: $traceClock, trace reset: $traceReset"
      puts "--- DEBUG:   slots: $dataSlots"
      add_kernel_data_profiling $liteMaster $fullMaster $traceClock \
                                $traceReset $useTrace $dataSlots $numHostMasters \
                                $default_ap_clk $default_ap_rst
      #set slots [lreplace $slots 0 0]
      
      # Mutual Exclusion of data,stall and exec options
      set accelCells {}
      if {$is_exec_enabled} {
        puts "--- DEBUG: Adding only exec monitoring"
        foreach cell $execSlots {
          set execPort [get_bd_cells [dict get $cell port]]
          set execOpt [dict get $cell option]
          lappend accelCells [dict create port $execPort option $execOpt stall off]
        }
      } else {
        puts "--- DEBUG : Adding exec by default"
        set masterCellsList [list]
        foreach master $slots {
          set masterPort [dict get $master port]
          lappend masterCellsList [get_bd_cells -of_objects [get_bd_intf_pins $masterPort]]
        }
        set masterCellsList [lsort -unique $masterCellsList]
        foreach cell $masterCellsList {
          if {$useTrace} {
              lappend accelCells [dict create port $cell option all stall off]
            } else {
              lappend accelCells [dict create port $cell option counters stall off]
            }
        }
        foreach cell $stallSlots {
          set stallCell [get_bd_cells [dict get $cell port]]
          set stallOpt [expr { $useTrace ? "all" : [dict get $cell option] } ]
          set stallDict [dict create port $stallCell option $stallOpt stall on]
          set id [lsearch -exact $masterCellsList $stallCell]
          if {$id >= 0} {
            set accelCells [lreplace $accelCells $id $id $stallDict]
          } else {
            lappend accelCells $stallDict
          }
        }
        set accelCells [lsort -unique $accelCells]
      }
      puts "--- DEBUG: After kernel data profiling accelCells $accelCells"
      add_accel_monitors $is_hw_emu $name $accelCells $traceClock $traceReset
      # Create hierarchy
      group_bd_cells $name [get_bd_cells xilmon*]
      save_bd_design
      puts "--- DEBUG: Completed adding kernel data profiling"
    }
    
    #
    # Protocol monitors for detailed kernel trace (HW emulation only)
    #
    if { $is_hw_emu && $kernel_debug } {
      puts "--- DEBUG: Adding protocol monitors..."
    
      # Write cu masters list to a file
      # write_cu_masters_unip
  
      # Monitor all AXI-MM ports on all compute units
      set perfMonPorts [list]
      set accelCells [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
      foreach accel $accelCells {
        set accelMasters [get_bd_intf_pins -of_objects $accel -filter {MODE == Master} -quiet]
        foreach master $accelMasters {
          lappend perfMonPorts $master
        }
      }
      
      puts "--- DEBUG: Monitoring ports = ${perfMonPorts}" 
      add_protocol_monitors ${perfMonPorts} false
      
      # Monitor all DDR bank masters
      set perfMonPorts [list]
      set bankMasterCells [get_bd_cells -filter {NAME =~ "interconnect_aximm_ddrmem*"} -quiet]
      lappend bankMasterCells [get_bd_cells -filter {NAME =~ "memory_subsystem"} -quiet]
      foreach masterCell $bankMasterCells {
        set memoryMasters [get_bd_intf_pins -of_objects $masterCell -filter {MODE == Master} -quiet]
        foreach master $memoryMasters {
          lappend perfMonPorts $master
        }
      }
      
      puts "--- DEBUG: Monitoring ports = ${perfMonPorts}" 
      add_protocol_monitors ${perfMonPorts} true
      save_bd_design
      puts "--- DEBUG: Completed adding protocol monitoring"
    }
  }; # end update_unified_profiling

  ################################################################################
  # add_kernel_data_profiling
  #   Description:
  #     Insert device profiling of kernel masters into IPI diagram
  #     NOTE: this uses the next generation monitor IP
  #   Arguments:
  #     liteMaster       AXI Lite master (BD interface pin)
  #     fullMaster       AXI Full master (BD interface pin)
  #     traceClock       Trace clock (BD pin)
  #     traceReset       Trace reset (BD pin)
  #     useTrace         Use Trace (boolean)
  #     monitorList      List of AXI interface port names to monitor
  #     numHostMasters   Number of host masters (depends on DSA)
  #     default_ap_clk   Clock from first cu. Used to setup trace
  #     default_ap_rst   Reset associated with default_ap_clk
  ################################################################################
  proc add_kernel_data_profiling {liteMaster fullMaster traceClock \
                                  traceReset useTrace monitorList numHostMasters \
                                  default_ap_clk default_ap_rst} {
    # Constants
    set hostIndex 0
    set maxAXISlaves 64
    set maxAXIMasters 64
    set monFifoDepth 1024
    set fifoDepth 8192
    set monName "xilmon_mon"
    set funnelName "xilmon_tm"
    set fifoName "xilmon_fifo0"
    set interconName "xilmon_intercon"
    
    #
    # Initialization
    #

    # Ensure correct number of monitor ports
    # NOTE: # ports = # CU masters + {1|4} for host; max # of trace ports on funnel = 63
    set numPorts [llength $monitorList]
    if {$numPorts <= 0 || $numPorts > 31} {
      puts "WARNING: Total number of ports (host inclusive) to monitor must be between 1 and 31."
      puts "numPorts : $numPorts numHostMasters : $numHostMasters"
      return
    }

    # Make sure interface pins exist
    set monitorPins {}
    for { set i 0 } { $i < $numPorts } { incr i } {
      set monitorPinName [ dict get [lindex $monitorList $i] port]
      puts "DEBUG: Monitor Pin found $monitorPinName"
      if { [get_bd_intf_pins $monitorPinName -quiet] eq "" } {
        puts "WARNING: unable to find interface pin $monitorPinName"
        return
      }
      
      lappend monitorPins [get_bd_intf_pins $monitorPinName]
    }
    
    # Gather list of unique clocks
    # NOTE: only needed for SmartConnect
    #set uniqueClockList [list $traceClock]
    #for { set i 0 } { $i < $numPorts } { incr i } {
    #  set clockPin [get_clk_from_intf_pin [lindex $monitorPins $i]]
    #  if {[lsearch $uniqueClockList $clockPin] < 0} {
    #    lappend uniqueClockList $clockPin
    #  }
    #}
    #puts "uniqueClockList = $uniqueClockList"
    
    # 
    # Insert cores
    #
    
    # AXI-MM monitors
    puts "--- DEBUG: Inserting AXI-MM monitors: $monName..."
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      set currPort [dict get [lindex $monitorList $i] port]
      set currUseTrace [expr {[dict get [lindex $monitorList $i] option] eq "all" ? 1 : 0 }]
      set currHost [dict get [lindex $monitorList $i] host]
      set mon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:Monitor_AXI_Master $currMonName]
      set_property CONFIG.TRACE_READ_ID [expr 2*$i] $mon_obj
      set_property CONFIG.TRACE_WRITE_ID [expr 2*$i+1] $mon_obj
      set_property CONFIG.CAPTURE_BURSTS 1 $mon_obj
      set_property CONFIG.ID_WIDTH 5 $mon_obj
      set_property CONFIG.ENABLE_DEBUG 1 $mon_obj
      
      set useCounters 1
      set_property CONFIG.ENABLE_COUNTERS $useCounters $mon_obj
      # Don't turn on trace for host monitor
      set_property CONFIG.ENABLE_TRACE $currUseTrace $mon_obj
      
      if { [info exists ::env(SDX_PROFILING_REG_STAGES)] } {
        set_property CONFIG.NUM_REG_STAGES $::env(SDX_PROFILING_REG_STAGES) $mon_obj
      } else {
        set_property CONFIG.NUM_REG_STAGES 0 $mon_obj
      }
      
      set properties [expr ($currHost << 2) + ($useCounters << 1) + $currUseTrace]
      add_debug_ip AXI_MM_MONITOR $currMonName $currPort $properties
    }
    
    # Setup Trace Infrastructure
    if { $useTrace } {
      # Trace funnel
      puts "--- DEBUG: Inserting trace funnel: $funnelName..."
      set funnel_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:Trace_Integrator $funnelName]
      set tracePorts [expr 2*($numPorts-$numHostMasters)]
      set_property CONFIG.NUM_TRACE_PORTS $tracePorts $funnel_obj
   
      add_debug_ip AXI_TRACE_FUNNEL $funnelName none $tracePorts 
   
      # AXI Stream FIFO
      puts "--- DEBUG: Inserting AXI Stream FIFO: $fifoName..."
      set fifo_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s $fifoName]
      set_property CONFIG.C_DATA_INTERFACE_TYPE 1 $fifo_obj
      set_property CONFIG.C_S_AXI4_DATA_WIDTH 64 $fifo_obj
      set_property CONFIG.C_RX_FIFO_DEPTH $fifoDepth $fifo_obj
      set_property CONFIG.C_RX_FIFO_PF_THRESHOLD [expr $fifoDepth - 5] $fifo_obj
      set_property CONFIG.C_USE_RX_CUT_THROUGH true $fifo_obj
      set_property CONFIG.C_USE_TX_DATA 0 $fifo_obj
    
      add_debug_ip AXI_MONITOR_FIFO_LITE $fifoName
      add_debug_ip AXI_MONITOR_FIFO_FULL $fifoName

      # Trace Clocks
      set funnelClkPins [get_bd_pins -of_objects $funnel_obj -filter {DIR == I && TYPE == clk}]
      connect_bd_net $traceClock [get_bd_pins $funnelName/trace_clk]
      connect_bd_net $default_ap_clk [get_bd_pins $funnelName/mon_clk]
      set fifoClkPins [get_bd_pins -of_objects $fifo_obj -filter {DIR == I && TYPE == clk}]
      connect_bd_net $traceClock $fifoClkPins
      # Trace Resets
      set funnelRstPins [get_bd_pins -of_objects $funnel_obj -filter {DIR == I && TYPE == rst}]
      connect_bd_net $traceReset [get_bd_pins $funnelName/trace_resetn]
      connect_bd_net $default_ap_rst [get_bd_pins $funnelName/mon_resetn]
      set fifoRstPins [get_bd_pins -of_objects $fifo_obj -filter {DIR == I && TYPE == rst}]
      connect_bd_net $traceReset $fifoRstPins
      # AXI-MM full for trace offload
      connect_bd_intf_net $fullMaster [get_bd_intf_pins $fifoName/S_AXI_FULL]
      # Funnel to FIFO connection
      connect_bd_intf_net [get_bd_intf_pins $funnelName/M_AXIS] [get_bd_intf_pins $fifoName/AXI_STR_RXD]
    }
    
    # AXI interconnect
    # NOTE: use v2 AXI interconnect instead of Smart Connect since max # SI or MI = 64
    puts "--- DEBUG: Inserting AXI interconnect: $interconName..."
    set numSlaves 1
    set numMasters [expr { $useTrace ? ($numPorts + 2) : $numPorts } ]
    set intercon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect $interconName]
    #set intercon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect $interconName]
    set_property CONFIG.NUM_SI $numSlaves $intercon_obj
    set_property CONFIG.NUM_MI $numMasters $intercon_obj
    #set_property CONFIG.NUM_CLKS [llength $uniqueClockList] $intercon_obj
    
    for { set i 0 } { $i < $numSlaves } { incr i } {
      set axiSlaveRegSlice [expr { ($i >= 10) ? "S${i}_HAS_REGSLICE" : "S0${i}_HAS_REGSLICE" } ]
      set_property CONFIG.$axiSlaveRegSlice 1 $intercon_obj
    }
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiMasterRegSlice [expr { ($i >= 10) ? "M${i}_HAS_REGSLICE" : "M0${i}_HAS_REGSLICE" } ]
      set_property CONFIG.$axiMasterRegSlice 1 $intercon_obj
    }
    
    #
    # Connect clocks & resets
    #
    puts "--- DEBUG: Connecting clocks and resets..."
    
    # Clocks
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      set currUseTrace [get_property CONFIG.ENABLE_TRACE [get_bd_cells $currMonName]]
      set currClock [get_clk_from_intf_pin [lindex $monitorPins $i]]
      
      #puts "Connecting $currClock to $currMonName/mon_clk"
      connect_bd_net [get_bd_pins $currClock] [get_bd_pins $currMonName/mon_clk]
      if {$currUseTrace} {
        #puts "Connecting $traceClock to $currMonName/trace_clk"
        connect_bd_net $traceClock [get_bd_pins $currMonName/trace_clk]
      }
    }
    
    #puts "Connecting $default_ap_clk to $interconName/ACLK"
    #connect_bd_net $traceClock [get_bd_pins $interconName/ACLK]
    connect_bd_net $default_ap_clk [get_bd_pins $interconName/ACLK]
    
    for { set i 0 } { $i < $numSlaves } { incr i } {
      set currClock [get_clk_from_intf_pin $liteMaster]
      set axiClkName [expr { ($i >= 10) ? "S${i}_ACLK" : "S0${i}_ACLK" } ]
      #puts "Connecting $currClock to $interconName/$axiClkName"
      connect_bd_net [get_bd_pins $currClock] [get_bd_pins $interconName/$axiClkName]
    }
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiClkName [expr { ($i >= 10) ? "M${i}_ACLK" : "M0${i}_ACLK" } ]
      
      if {$i < $numPorts} {
        set currClock [get_clk_from_intf_pin [lindex $monitorPins $i]]
        #puts "Connecting $currClock to $interconName/$axiClkName"
        connect_bd_net [get_bd_pins $currClock] [get_bd_pins $interconName/$axiClkName]
      } else {
        #puts "Connecting $traceClock to $interconName/$axiClkName"
        connect_bd_net $traceClock [get_bd_pins $interconName/$axiClkName]
      }
    }
    
    # Resets
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      set currUseTrace [get_property CONFIG.ENABLE_TRACE [get_bd_cells $currMonName]]
      set currReset [get_reset_from_intf_pin [lindex $monitorPins $i]]
      
      puts "Connecting port reset: $currReset to $currMonName/mon_resetn"
      connect_bd_net [get_bd_pins $currReset] [get_bd_pins $currMonName/mon_resetn]
      if {$currUseTrace} {
        puts "Connecting port reset: $traceReset to $currMonName/trace_resetn"
        connect_bd_net $traceReset [get_bd_pins $currMonName/trace_resetn]
      }
    }

    # Interconnect reset
    #puts "Connecting $default_ap_rst to $interconName/ARESETN"
    #connect_bd_net $traceReset [get_bd_pins $interconName/ARESETN]
    connect_bd_net $default_ap_rst [get_bd_pins $interconName/ARESETN]
    
    for { set i 0 } { $i < $numSlaves } { incr i } {
      set currReset [get_bd_pins [get_reset_from_intf_pin $liteMaster]]
      set axiRstName [expr { ($i >= 10) ? "S${i}_ARESETN" : "S0${i}_ARESETN" } ]
      if {[get_property DIR $currReset] == "I"} {
        set currReset [find_bd_objs -relation connected_to -thru_hier $currReset]
      }
      
      puts "Connecting slave reset: $currReset to $interconName/$axiRstName"
      connect_bd_net $currReset [get_bd_pins $interconName/$axiRstName]
    }
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiRstName [expr { ($i >= 10) ? "M${i}_ARESETN" : "M0${i}_ARESETN" } ]
      
      if {$i < $numPorts} {
        set currReset [get_reset_from_intf_pin [lindex $monitorPins $i]]
        puts "Connecting master reset: $currReset to $interconName/$axiRstName"
        connect_bd_net [get_bd_pins $currReset] [get_bd_pins $interconName/$axiRstName]
      } else {
        puts "Connecting master reset: $traceReset to $interconName/$axiRstName"
        connect_bd_net $traceReset [get_bd_pins $interconName/$axiRstName]
      }
    }
    
    #
    # Make Connections
    #
    puts "--- DEBUG: Connecting all blocks..."
    
    # Monitor ports
    set index 0
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      set currUseTrace [get_property CONFIG.ENABLE_TRACE [get_bd_cells $currMonName]]
      connect_bd_intf_net [get_bd_intf_pins $currMonName/MON_M_AXI] [lindex $monitorPins $i]
      
      # Connect trace for non-host ports
      if { $currUseTrace } {
        set tracePort0 TRACE_${index}
        set tracePort1 TRACE_[expr $index + 1]
        incr index 2
        connect_bd_intf_net [get_bd_intf_pins $currMonName/TRACE_OUT_0] [get_bd_intf_pins $funnelName/$tracePort0]
        connect_bd_intf_net [get_bd_intf_pins $currMonName/TRACE_OUT_1] [get_bd_intf_pins $funnelName/$tracePort1]
        set monPortNet [get_bd_intf_nets -of_objects [get_bd_intf_pins $currMonName/MON_M_AXI]]
        set currCUCell [get_bd_cells -of_objects [get_bd_intf_pins -of_objects $monPortNet -filter {MODE == Master}]]
        set accelAxiLiteSlave [get_bd_intf_pins -of_objects $currCUCell -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}]
        connect_bd_intf_net -quiet $accelAxiLiteSlave [get_bd_intf_pins $currMonName/MON_S_AXI]
      }
    }
    
    # Interconnect slaves
    connect_bd_intf_net $liteMaster [get_bd_intf_pins $interconName/S00_AXI]
    
    # Interconnect masters
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currMonName ${monName}$i
      set axiMasterName [expr { ($i >= 10) ? "M${i}_AXI" : "M0${i}_AXI" } ]
      connect_bd_intf_net [get_bd_intf_pins $interconName/$axiMasterName] [get_bd_intf_pins $currMonName/S_AXI]
    }
    
    if { $useTrace } {
    set axiMasterName [expr { ($numPorts >= 10) ? "M${numPorts}_AXI" : "M0${numPorts}_AXI" } ]
    connect_bd_intf_net [get_bd_intf_pins $interconName/$axiMasterName] [get_bd_intf_pins $fifoName/S_AXI]
    set pp1 [expr $numPorts + 1]
    set axiMasterName [expr { ($pp1 >= 10) ? "M${pp1}_AXI" : "M0${pp1}_AXI" } ]
    connect_bd_intf_net [get_bd_intf_pins $interconName/$axiMasterName] [get_bd_intf_pins $funnelName/S_AXI]
  }
  }; # end add_kernel_data_profiling
  
  ################################################################################
  # add_protocol_monitors
  #   Description:
  #     Insert debug monitoring for HW emulation into dynamic region of unified platforms
  #   Arguments:
  #     monNameList  list of AXI intf ports to monitor
  #     isDDR        true: monitors for DDR banks; false not for DDR
  #
  ################################################################################
  proc add_protocol_monitors {monNameList isDDR} {
    if {[llength $monNameList] == 0} {
      puts "WARNING: no ports specified for protocol monitoring"
      return
    }
    
    # Insert monitor interface block on each port
    foreach pinName $monNameList {
      if { [get_bd_intf_pins $pinName -quiet] eq "" } {
        puts "WARNING: interface pin $pinName not found in current block diagram"
        continue
      }
      
      # Instantiate monitor
      if {$isDDR} {
        if {[string last 3 $pinName] >= 0} {
          set tmpName "xilmonitor_ddrmem3"
        } elseif {[string last 2 $pinName] >= 0} {
          set tmpName "xilmonitor_ddrmem2"
        } elseif {[string last 1 $pinName] >= 0} {
          set tmpName "xilmonitor_ddrmem1"
        } else {
          set tmpName "xilmonitor_ddrmem0"
        }
      } else {
        set tmpName "xilmonitor_[string trimleft $pinName "/"]"
      }
      set ipName [string map {"/" "_"} $tmpName]
      puts "--- DEBUG: Adding $ipName for kernel debug monitoring..."
      set mon_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:sdx_aximm_wv $ipName]
      
      # Connect clock and reset
      set currClock [get_clk_from_intf_pin $pinName]
      set currReset [get_reset_from_intf_pin $pinName]
      if {$currClock eq ""} {
        delete_bd_objs $mon_obj
        puts "WARNING: unable to insert $ipName"
        continue
      }
      if {$currReset eq ""} {
        puts "WARNING: using default reset in Emulation flow"
        set currReset [get_bd_pins /psr_kernel_clk/peripheral_aresetn]
      }
      connect_bd_net [get_bd_pins $currClock] [get_bd_pins $ipName/mon_axi_aclk]
      connect_bd_net [get_bd_pins $currReset] [get_bd_pins $ipName/mon_axi_aresetn]
      
      # Connect AXI port
      connect_bd_intf_net [get_bd_intf_pins $ipName/mon_axi] [get_bd_intf_pins $pinName]
    }
  }; # end add_protocol_monitors
  
  ################################################################################
  # add_accel_monitors
  #   Description:
  #     Insert profile monitoring of accelerators into dynamic region of unified platforms
  #   Arguments:
  #     is_hw_emu        true: HW emulation run; false: otherwise 
  #     name             Name of hierarchical block
  #     accelList        List of accelerators to monitor
  #     traceClock       Clock that runs the trace system
  #     traceReset       Reset for traceClock
  ################################################################################
  proc add_accel_monitors {is_hw_emu name accelList traceClock traceReset} {
    # Constants (same as in add_kernel_data_profiling)
    set fifoDepth 4096
    set funnelName "xilmon_tm"
    set fifoName "xilmon_fifo0"
    set interconName "xilmon_intercon"
    
    # Ensure correct number of monitor ports
    set numPorts [llength $accelList]
    if {$numPorts <= 0 || $numPorts > 30} {
      puts "WARNING: number of Accelerators to monitor must be between 1 and 30."
      return
    }
    
    # Get trace clock/reset (if not already defined)
    set firstAccel [get_bd_cells [dict get [lindex $accelList 0] port]]
    set_axi_lite_interconnect $firstAccel
    set accelClock [get_bd_pins -of_objects $firstAccel -filter {TYPE == clk}]
    set accelReset [get_bd_pins -of_objects $firstAccel -filter {TYPE == rst}]
    if {[expr {[llength $accelClock] != 1 || [llength $accelReset] != 1}]} {
      puts "WARNING : Kernel $firstAccel has non standard number of clocks/resets"
      set accelSlave [lindex [get_bd_intf_pins -quiet -of_objects $firstAccel -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}] 0]
      set accelClock [get_clk_from_intf_pin $accelSlave]
      set accelReset [get_reset_from_intf_pin $accelSlave]
    }
      
    # Get AXI Lite master
    set axiLiteIntercon [get_axi_lite_interconnect]
    set liteMaster [get_bd_intf_pins $axiLiteIntercon/M00_AXI]
      
    # Add another master (HW emulation only)
    if { $is_hw_emu } {
      set currNumMasters [get_property CONFIG.NUM_MI [get_bd_cells $axiLiteIntercon]]
      set_property CONFIG.NUM_MI [expr $currNumMasters + 1] [get_bd_cells $axiLiteIntercon]
      set masterName [expr { ($currNumMasters >= 10) ? "M${currNumMasters}_AXI" : "M0${currNumMasters}_AXI" } ]
      set liteMaster [get_bd_intf_pins $axiLiteIntercon/$masterName]
      
      set axiClkName [expr { ($currNumMasters >= 10) ? "M${currNumMasters}_ACLK" : "M0${currNumMasters}_ACLK" } ]
      set axiRstName [expr { ($currNumMasters >= 10) ? "M${currNumMasters}_ARESETN" : "M0${currNumMasters}_ARESETN" } ]
      connect_bd_net $accelClock [get_bd_pins $axiLiteIntercon/$axiClkName]
      connect_bd_net $accelReset [get_bd_pins $axiLiteIntercon/$axiRstName]
    }
    
    # Insert monitor on each accelerator
    set count 0
    foreach accelDict $accelList {
      set accelName [get_bd_cells -quiet [dict get $accelDict port]]
      set currUseTrace [expr {[dict get $accelDict option] eq "all" ? 1 : 0} ]
      set useStall [expr {[dict get $accelDict stall] eq "on" ? 1 : 0 }]
      if { $accelName == {} } {
        puts "WARNING: accelerator $accelName not found in current block diagram"
        continue
      }
      
      # Instantiate monitor
      set monName "xilmonitor_[string trimleft $accelName "/"]"
      #set monName $name/[string map {"/" "_"} $tmpName]
      if { [get_bd_cells -quiet $monName] != {} } {
        delete_bd_objs [get_bd_cells $monName]
      }
      puts "--- DEBUG: Adding $monName for accelerator monitoring..."
      set mon_obj [ create_bd_cell -type ip -vlnv xilinx.com:ip:sdx_accel_monitor $monName]
      set_property CONFIG.TRACE_ID [expr 64 + ($count * 16)] $mon_obj
      set_property CONFIG.ENABLE_TRACE $currUseTrace $mon_obj
      set_property CONFIG.STALL_MON $useStall $mon_obj
      
      # Connect clock and reset
      set accelClock [get_bd_pins -of_objects $accelName -filter {TYPE == clk}]
      set accelReset [get_bd_pins -of_objects $accelName -filter {TYPE == rst}]
      if {[expr {[llength $accelClock] != 1 || [llength $accelReset] != 1}]} {
      puts "WARNING : Kernel $accelName has non standard number of clocks/resets"
      set accelSlave [lindex [get_bd_intf_pins -quiet -of_objects $accelName -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}] 0]
      set accelClock [get_clk_from_intf_pin $accelSlave]
      set accelReset [get_reset_from_intf_pin $accelSlave]
    }
      if { ($accelClock eq "") || ($accelReset eq "") } {
        delete_bd_objs $mon_obj
        puts "WARNING: unable to insert $monName"
        continue
      }
      connect_bd_net [get_bd_pins $accelClock] [get_bd_pins $monName/ap_clk]
      connect_bd_net [get_bd_pins $accelReset] [get_bd_pins $monName/ap_resetn]
      if ($currUseTrace) {
        connect_bd_net $traceClock [get_bd_pins $monName/trace_clk]
        connect_bd_net $traceReset [get_bd_pins $monName/trace_resetn]
      }
      
      # Connect control signals
      if {[get_bd_pins -quiet $accelName/event_start] != {}
          && [get_bd_pins -quiet $accelName/event_done] != {}} {
        set_property CONFIG.AXI_LITE_SLAVE_MON 0 $mon_obj
        connect_bd_net [get_bd_pins $accelName/event_start] [get_bd_pins $monName/event_start]
        connect_bd_net [get_bd_pins $accelName/event_done] [get_bd_pins $monName/event_done]  
      } else {
        # Monitor AXI lite slave instead
        set_property CONFIG.AXI_LITE_SLAVE_MON 1 $mon_obj
        set accelAxiLiteSlave [get_bd_intf_pins -of_objects $accelName -filter {CONFIG.PROTOCOL == AXI4LITE && MODE == Slave}]
        connect_bd_intf_net $accelAxiLiteSlave [get_bd_intf_pins $monName/s_axi_mon]
      }
      
      if {$useStall} {
        if {[get_bd_pins -quiet $accelName/stall_start_ext] != {}} {
          connect_bd_net [get_bd_pins $accelName/stall_start_ext] [get_bd_pins $monName/stall_start_ext]
          connect_bd_net [get_bd_pins $accelName/stall_done_ext] [get_bd_pins $monName/stall_done_ext]
          connect_bd_net [get_bd_pins $accelName/stall_start_str] [get_bd_pins $monName/stall_start_str]
          connect_bd_net [get_bd_pins $accelName/stall_done_str] [get_bd_pins $monName/stall_done_str]
          connect_bd_net [get_bd_pins $accelName/stall_start_int] [get_bd_pins $monName/stall_start_int]
          connect_bd_net [get_bd_pins $accelName/stall_done_int] [get_bd_pins $monName/stall_done_int]
        } else {
          # User forgot to compile with stall
          set useStall 0
        }
      }
    
      # Connect trace ports only if trace integrator is available
      if { !$is_hw_emu && $currUseTrace} {
        set firstPort 0
        set fullFunnelName $funnelName
        
        if { [get_bd_cells -quiet $fullFunnelName] != {} } {
          set funnel_obj [get_bd_cells $fullFunnelName]
          set currNumPorts [get_property CONFIG.NUM_TRACE_PORTS $funnel_obj]
          
          set firstPort $currNumPorts
          if { [get_bd_intf_pins -quiet $monName/trace_out] != {} && $firstPort < 63 } {
            set numPorts [expr $currNumPorts + 1]
            set_property CONFIG.NUM_TRACE_PORTS $numPorts $funnel_obj
            connect_bd_intf_net -quiet [get_bd_intf_pins $monName/trace_out] [get_bd_intf_pins $fullFunnelName/TRACE_${firstPort}]
          } else {
            # No port available on Trace Integrator
            set currUseTrace 0
            set_property CONFIG.ENABLE_TRACE $currUseTrace $mon_obj
          }
        } else {
          # No Trace Integrator IP Available
          set currUseTrace 0
          set_property CONFIG.ENABLE_TRACE $currUseTrace $mon_obj
        }
      }
      
      # Add AXI interconnect (if needed) and connect AXI slave
      set numMasters 1
      set fullInterconName $interconName
      if {[get_bd_cells -quiet $fullInterconName] != {}} {
        set intercon_obj [get_bd_cells $fullInterconName]
        set numMasters [expr [get_property CONFIG.NUM_MI $intercon_obj] + 1]
        set_property CONFIG.NUM_MI $numMasters $intercon_obj
      } else {
        set intercon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect $fullInterconName]
        set_property CONFIG.NUM_MI $numMasters $intercon_obj
        
        connect_bd_intf_net $liteMaster [get_bd_intf_pins $fullInterconName/S00_AXI]
        set liteMasterClk [get_bd_pins [get_clk_from_intf_pin $liteMaster]]
        set liteMasterRst [get_bd_pins [get_reset_from_intf_pin $liteMaster]]
        connect_bd_net $liteMasterClk [get_bd_pins $fullInterconName/ACLK]
        connect_bd_net $liteMasterRst [get_bd_pins $fullInterconName/ARESETN]
        connect_bd_net $liteMasterClk [get_bd_pins $fullInterconName/S00_ACLK]
        connect_bd_net $liteMasterRst [get_bd_pins $fullInterconName/S00_ARESETN]
      }
      set masterNum [expr $numMasters - 1]
      set masterName [expr { ($masterNum >= 10) ? "M${masterNum}_AXI" : "M0${masterNum}_AXI" } ]
      puts "--- DEBUG Add Accel Mons : connecting $monName to mastername $fullInterconName/$masterName"
      connect_bd_intf_net [get_bd_intf_pins $monName/s_axi] [get_bd_intf_pins $fullInterconName/$masterName]
      
      set axiClkName [expr { ($masterNum >= 10) ? "M${masterNum}_ACLK" : "M0${masterNum}_ACLK" } ]
      set axiRstName [expr { ($masterNum >= 10) ? "M${masterNum}_ARESETN" : "M0${masterNum}_ARESETN" } ]
      connect_bd_net [get_bd_pins $accelClock] [get_bd_pins $fullInterconName/$axiClkName]
      connect_bd_net [get_bd_pins $accelReset] [get_bd_pins $fullInterconName/$axiRstName]
      
      set properties [expr ($useStall << 2) + 2 + $currUseTrace]
      add_debug_ip ACCEL_MONITOR $monName $accelName $properties

      incr count
    }
  }; # end add_accel_monitors

  # ****************************************************************************
  # insert_chipscope_debug -
  #     Given debug_info containing xocc command line compute_unit/port pairs,
  #     instantiate and connect SystemILA debug cores to the AXI interfaces
  #     requested
  #
  # TODO: Env var to turn on additional tcl settings file
  # ****************************************************************************
  proc insert_chipscope_debug {dsa_dr_bd is_hw_emu debug_info} {
    set chipscope_debugs [dict_get_default $debug_info chipscope_debugs [dict create]]
    set name [dict_get_default $chipscope_debugs name ""]
    if { $is_hw_emu } {
      return
    }
    if {$name eq ""} {
      puts "--- DEBUG: insert_chipscope_debug: No chipscope_debugs dict name - nothing to insert"
      return
    }
    set compute_units [dict_get_default $chipscope_debugs compute_units {}]
    if {[llength $compute_units] == 0} {
      puts "--- DEBUG: insert_chipscope_debug: No compute units - nothing to insert"
      return
    }

    open_bd_design $dsa_dr_bd
    set ila_probes [get_ila_probes $compute_units]
    set system_ila_cells [apply_automation $ila_probes]
    rename_ila_nets $ila_probes
    update_system_ila_props $system_ila_cells
    apply_user_ila_properties
    #validate_bd_design -force
    save_bd_design
  }

  # *****************************************************************************************
  # connect_bscan_ports -
  #     Connect the BSCAN interface ports of the kernel(s)(slave(s)) and debug bridge(master)
  #   Arguments:
  #     dsa_dr_bd        block diagram name: diagram in which the connections should be made
  #     is_hw_emu        true: HW emulation run; false: otherwise 
  #
  # *****************************************************************************************
  proc connect_bscan_ports {dsa_dr_bd is_hw_emu} {
    if { $is_hw_emu } {
      return
    }

    open_bd_design $dsa_dr_bd

    #instantiated debug bridge exists?
    set dbgs [get_bd_cells -quiet -hier -filter {VLNV =~ "*ip:debug_bridge*"}]
    #no debug bridge instances, do nothing
    if { [llength $dbgs] == 0} {
      return
    }

    #multiple debug bridge instances, warn
    if {[llength $dbgs] > 1 } {
      puts "WARNING: Could not connect BSCAN interface ports as there are $dbgs debug bridge instances found in the design. A single debug bridge is expected "
      return
    }
   
    #kernel(s) with BSCAN slave interfaces?      
    #ASSUMPTION: all the BSCAN slave interfaces found are unconnected by default 
    set accelBscanIntfs {}
    set accelCells [get_bd_cells -quiet -hier -filter "SDX_KERNEL==true"]
    foreach accel $accelCells {
      set accelSlaves [get_bd_intf_pins -of_objects $accel -filter {VLNV =~ "*interface:bscan_rtl*" && MODE == Slave} -quiet]
      set accelBscanIntfs [concat $accelBscanIntfs [lrange $accelSlaves 0 end]] 
    }

    #no slave BSCAN interfaces, do nothing  
    if {[llength $accelBscanIntfs] == 0} {
      return
    }
    
    #check for the limit and set the total BSCAN master interfaces on debug bridge
    #TODO: get the maximum BSCAN master interfaces from the IP
    set maxBSCANIntfs 16
    set dbg [lindex $dbgs 0]
    set curMBscan [get_property CONFIG.C_NUM_BS_MASTER $dbg]
    set totalMBscan [expr [llength $accelBscanIntfs] + $curMBscan]

    if { $totalMBscan > $maxBSCANIntfs } {
      error "Number of required master BSCAN interfaces $totalMBscan exceeds the limit 16"
      return false
    } 
    set_property CONFIG.C_NUM_BS_MASTER $totalMBscan $dbg -quiet

    #connect the slaves to unconnected master slots
    set slaveIdx 0
    set dbgMasters [get_bd_intf_pins -of_objects $dbg -filter {VLNV =~ "*interface:bscan_rtl*" && MODE == Master} -quiet]
    foreach master $dbgMasters {
      set intfNet [get_bd_intf_net -of $master -quiet]
      if {$intfNet != ""} {
        continue
      }
      set slaveIf [lindex $accelBscanIntfs $slaveIdx]   
      connect_bd_intf_net [get_bd_intf_pins $master -quiet ] [get_bd_intf_pins $slaveIf -quiet] -quiet 
    }

    save_bd_design
  }

  
  # get_clock_for_cu -
  #    Given a compute unit bd_cell, return the compute unit clock pin
  #
  proc get_clock_for_cu {cell} {
    set clk {}
    set clockPins [get_bd_pins -of $cell -filter {DIR==I && TYPE==clk}]
    # There should be only 1 pin, just in case, just take the first for ILA probing
    # TODO: Is it possible to create compute unit with multiple clocks?
    if {[llength $clockPins] > 0} {
      set clk [lindex $clockPins 0]
    } 
    return $clk
  }

  # get_source_clock_for_cu -
  #    Given a compute unit bd_cell, return the compute unit clock source pin/port
  #    if there are multiple clock input, return the highest frequency clock pin source
  #

  proc get_source_clock_for_cu {cell} {
    
    set clkSrc {}
    set clockPins [get_bd_pins -of $cell -filter {DIR==I && TYPE==clk}]
    set clk {}
    if {[llength $clockPins] > 0} {
      set maxFreq 0
      foreach pin $clockPins {
        set pinFreq [get_property CONFIG.FREQ_HZ $pin]
        if { [expr $pinFreq > $maxFreq] } {
          set maxFreq $pinFreq
          set clk $pin
        } 
      }      
    } 
    if {$clk != ""} {
      set clkSrc [get_bd_pins -of [get_bd_nets -of $clk] -filter {DIR==O && TYPE==clk}]
      if {$clkSrc == ""} {
        set clkSrc  [get_bd_ports -of [get_bd_nets -of $clk] -filter {DIR==I && TYPE==clk}]
      }
     
    }
    return $clkSrc
  }



  # get_reset_for_cu
  #   Given a compute unit bd cell, return the reset pin
  #
  proc get_reset_for_cu {cell} {
    set clk [get_clock_for_cu $cell]
    set resetPin [string tolower [get_property CONFIG.ASSOCIATED_RESET $clk]]
    return [get_bd_pins "$cell/$resetPin"]
  }

  # get_ila_probes -
  # Given a compute_units dictionary, return the ila connections as a list
  #    {compute_unit {pins...} compute_unit {pins...}}
  #
  proc get_ila_probes {compute_units} {
    set ila_probes {}
    foreach cu $compute_units {
      set automation_params {}
      set cu_name [dict_get_default $cu name false]
      set cu_pins [dict_get_default $cu ports {}]
      set cu_cell [get_bd_cells $cu_name]
      set intf_pins {}
      foreach cu_pin $cu_pins {
        if {[llength $cu_cell] > 0} {
          set intf_pin [get_bd_intf_pins -of [get_bd_cells $cu_name] -filter NAME=~$cu_pin]
          if {[llength $intf_pin] == 0} {
            set cu_pin_lc [string tolower $cu_pin]
            set intf_pin [get_bd_intf_pins -of [get_bd_cells $cu_name] -filter NAME=~${cu_pin_lc}]
          }
          lappend intf_pins $intf_pin
        }
      }
      # Considering all axi interfaces as no specific comput_unit pin is provided to debug 
      if {[llength $cu_cell] > 0 && [llength $cu_pins] == 0} {
            set cu_axi_pins [get_bd_intf_pins -of_objects $cu_cell -filter {VLNV =~ "*axi*" && CONFIG.PROTOCOL =~ "AXI4*" } -quiet]
            foreach cu_axi_pin $cu_axi_pins {
                lappend intf_pins $cu_axi_pin
            }
      }
      lappend ila_probes $cu_cell $intf_pins
    }
    return $ila_probes
  }

  # get_list_diffs -
  # Given a pre-list of cells and a post automation list of cells, compute
  # and return the list differences
  #
  proc get_list_diffs {old_cells new_cells} {
    set diff_cells {}
    array unset tmp_array
    foreach cell $old_cells {
      set tmp_array($cell) 1
    }
    foreach cell $new_cells {
      if {! [info exists tmp_array($cell)]} {
        lappend diff_cells $cell
      }
    }
    return $diff_cells
  }

  # get_system_ilas - 
  # Given a list of pre-automation and post-automation cells, return all system_ila 
  # cells in the new_cells list not in the old_cells list
  #
  # This is used to further customize IP automatically inserted during bd automation
  #
  proc get_system_ilas {old_cells new_cells} {
    set system_ila_cells {}
    set diff_cells [get_list_diffs $old_cells $new_cells]
    foreach cell $diff_cells {
      set vlnv [get_property VLNV $cell]
      # VLNV=xilinx.com:ip:system_ila:1.1
      if {[regexp {xilinx\.com:ip:system_ila:.*} $vlnv]} {
        lappend system_ila_cells $cell
      }
    }
    return $system_ila_cells
  }
  # rename_ila_nets
  # Given the list of ila_probes, 
  # 1. rename the nets of debug enabled slave interface(s) of kernels 
  #
  proc rename_ila_nets {ila_probes} {
    puts "--- DEBUG: Renaming Chipscope nets"
    foreach {cu_cell cu_pins} $ila_probes {
      set cuCell [get_bd_cells $cu_cell]
      set cuCompName [get_property CONFIG.Component_Name $cuCell]
      foreach cu_pin $cu_pins {
        set intf_net [get_bd_intf_nets -of $cu_pin]

        #rename the net to more readabale
        if { [string equal -nocase [get_property MODE $cu_pin] "Slave"] } {
          set curNetName [get_property NAME $intf_net]
          set pinName [get_property NAME [get_bd_intf_pins $cu_pin]]
          set newNetName ${cuCompName}_${pinName}
          if { ![string equal -nocase ${curNetName} ${newNetName}] } {
              set_property NAME ${newNetName} $intf_net
              puts "--- DEBUG: Renamed net ${curNetName} to $newNetName of pin $cu_pin of computing unit $cu_cell"
          }
        }
      }
    } 
  }
  
  # apply_automation -
  # Given the list of ila_probes, mark them for debug then apply bd automation
  # to instantiate and connect the system ila debug cores.
  #
  proc apply_automation {ila_probes} {
    set automation_params {}
    set system_ila_cells {}
    foreach {cu_cell cu_pins} $ila_probes {
      foreach cu_pin $cu_pins {
        #set clk_pin [get_clk_from_intf_pin $cu_pin]
        set clk_pin [bd::clkrst::get_intf_driver_clk [get_bd_intf_pins $cu_pin] ]
        if {$clk_pin == ""} {
           set clk_pin [get_source_clock_for_cu [get_bd_cells $cu_cell]]
        }
        set intf_net [get_bd_intf_nets -of $cu_pin]
        set_property HDL_ATTRIBUTE.DEBUG true $intf_net
        lappend automation_params $intf_net
        set protocol [get_property CONFIG.PROTOCOL [get_bd_intf_pins $cu_pin]]
        if {$protocol == "AXI4" || $protocol == "AXI4LITE" || $protocol == "AXI4S"} {  
           lappend automation_params \
           [list \
             AXI_R_ADDRESS  "Data and Trigger" \
             AXI_R_DATA     "Data and Trigger" \
             AXI_W_ADDRESS  "Data and Trigger" \
             AXI_W_DATA     "Data and Trigger" \
             AXI_W_RESPONSE "Data and Trigger" \
             CLK_SRC        "$clk_pin" \
             SYSTEM_ILA     "Auto" \
             APC_EN         "1" \
           ] 
        } else {
           lappend automation_params \
           [list \
             NON_AXI_SIGNALS "Data and Trigger" \
             CLK_SRC        "$clk_pin" \
             SYSTEM_ILA     "Auto" \
           ] 

        }
      }
    }
    puts "--- DEBUG: automation_params=$automation_params"
    if {[llength $automation_params] > 0} {
      set old_cells [get_bd_cells]
      apply_bd_automation -rule xilinx.com:bd_rule:debug -dict $automation_params
      set new_cells [get_bd_cells]
      set system_ila_cells [get_system_ilas $old_cells $new_cells]
    
      # automation creates some incorrect reset objects - delete them now
      lappend old_cells $system_ila_cells
      set reset_objs [get_list_diffs $old_cells $new_cells]
      if {[llength $reset_objs]} {
        puts "--- DEBUG: delete_bd_objs $reset_objs"
        delete_bd_objs $reset_objs
      }
    }
    return $system_ila_cells
  }

  # update_system_ila_props -
  #   Given a list of system ila cells, apply any necessary IP property updates
  #   that were not automatically applied during automation
  #
  proc update_system_ila_props {system_ila_cells} {
      # After automation we need to find the new system ILA IPs that are inserted
      # and apply parameter changes that are not available in the bd automation
      #   1. Locate all new system_ila IPs inserted by bd automation
      #   2. Apply parameters to the new IPs
      #
    # These are missing from bd automation so must be manually set on the IP
    foreach system_ila $system_ila_cells {
      set props [list \
          CONFIG.C_DATA_DEPTH {1024} \
          CONFIG.C_INPUT_PIPE_STAGES {2} \
      ]
      set num_slots [get_property {CONFIG.C_NUM_MONITOR_SLOTS} $system_ila]
      for {set slot_idx 0} {$slot_idx < $num_slots} {incr slot_idx} {
        lappend props [format "CONFIG.C_SLOT_%d_MAX_RD_BURSTS" $slot_idx] 64
        lappend props [format "CONFIG.C_SLOT_%d_MAX_WR_BURSTS" $slot_idx] 64
      }
      puts "--- DEBUG: $system_ila property update:  $props"
      set_property -dict $props $system_ila
    }
  }

  # Delete any system ILA cores in the top level bd
  proc delete_system_ilas {} { 
    set system_ila_cells {}
    foreach cell [get_bd_cells] {
      if {! [info exists tmp_array($cell)]} {
        set vlnv [get_property VLNV $cell]
        # VLNV=xilinx.com:ip:system_ila:1.1
        if {[regexp {xilinx\.com:ip:system_ila:.*} $vlnv]} {
          lappend system_ila_cells $cell
        }
      }
    }
    if {[llength $system_ila_cells] > 0} {
      puts "--- DEBUG: delete_bd_objs $system_ila_cells"
      delete_bd_objs $system_ila_cells
    }
  }

  # Expert user post processing
  proc apply_user_ila_properties {} {
    if { [info exists ::env(SDX_CHIPSCOPE_TCL)] } {
      set ila_script $::env(SDX_CHIPSCOPE_TCL)
      if { [file exists $ila_script] } {
        puts "--- DEBUG: sourcing SDX_CHIPSCOPE_TCL script: $ila_script"
        source $ila_script
      }
    }
  }


  ################################################################################
  # update_axi_checkers
  #   Description:
  #     add AXI checkers for unified platforms (does not apply to HW emulation)
  #     host and kernel masters
  #   Arguments:
  #     dsa_dr_bd        dynamic region block diagram
  #     is_hw_emu        true: is HW emulation; false: not HW emulation
  #     debug_info     debug dictionary from compiler
  ################################################################################
  proc update_axi_checkers {dsa_dr_bd is_hw_emu debug_info} {
    if { ($debug_info == {}) } {
      return
    }

    # Contains everything to check (except host)
    # E.g., all AXI masters on all accelerators
    #       {accel_1/m_axi_gmem0 accel_1/m_axi_gmem1 accel_2/m_axi_gmem}
    set protocol_debugs [dict_get_default $debug_info protocol_debugs {}]

    if {$protocol_debugs == {}} {
      return
    }

    if { $is_hw_emu } {
      puts "WARNING: Light Weight AXI protocol checker insertion is supported only in hardware flow. They are not supported in hardware emulation."
      return
    }

    set compute_units [dict_get_default $protocol_debugs compute_units {}]

    puts "--- DEBUG: AXI protocol debug dictionary: $compute_units"
    if {$compute_units == {}} {
      error "No compute units/ports specified for AXI protocol checker insertion"
      return
    }

    #
    # kernel masters
    #
    puts "--- DEBUG: Adding lightweight axi protocol checkers for kernel masters..."

    # open BD of dynamic region
    open_bd_design $dsa_dr_bd

    # Trace back to axi lite interconnect from the first cu
    set firstCUCell [get_bd_cells [dict get [lindex $compute_units 0] name]]
    set_axi_lite_interconnect $firstCUCell

    # Check the number of interconnects in interconnect_axilite_user and add 
    # an additional master for the protocol checkers
    set interconobj  [get_axi_lite_interconnect]
    set currentMasters [get_property CONFIG.NUM_MI $interconobj]
    if {$currentMasters > 63} {
      error "Unable to add additional master on the axi-interconnect for inserting \
            AXI-protocol checkers. Current number of masters is $currentMasters. Skipping AXI \
            protocol checker insertion."
      return
    }

    set_property CONFIG.NUM_MI [expr $currentMasters + 1] $interconobj
    set currentMasterName [expr { ($currentMasters >= 10) ? "M${currentMasters}" : "M0${currentMasters}" }]

    #Enable regslice on the newly added master
    set axiMasterRegSlice "${currentMasterName}_HAS_REGSLICE"
    puts "PC: Setting regslice on new master: $axiMasterRegSlice"
    set_property CONFIG.$axiMasterRegSlice 1 $interconobj

    #Prepare checker lists to insert based on dictionary passed in
    #if "all" is specified for computeunit then it would already be expanded
    #if "all" is specified for interfaces then expand to include all masters
    set checkerList {}
    foreach checker_inst $compute_units {
      set name  [dict get $checker_inst name]
      set slots [dict get $checker_inst ports]
      set cu [get_bd_cells $name]
      if { $slots eq "all" } {
        set accelMasters [get_bd_intf_pins -of_objects $cu -filter {MODE == Master}]
        foreach master $accelMasters {
          lappend checkerList $master
        }
      } else {
        foreach slot $slots {
          set intf_pin [get_bd_intf_pins -of $cu -filter NAME=~$slot]
          #Portnames in kernel.xml are in uppercase while the in the BD 
          #they are in lower case (M_AXI_GMEM vs m_axi_gmem). 
          #So solution is to lowercase the compare if first compare fails
          if {[llength $intf_pin] == 0} {
            set cu_pin_lc [string tolower $slot]
            set intf_pin [get_bd_intf_pins -of $cu -filter NAME=~${cu_pin_lc}]
          }
          lappend checkerList $intf_pin
        }
      }
    }

    puts "PC: Prepared checker list"
    #sanity checks
    set numPorts [llength $checkerList]
    if {$numPorts <= 0 || $numPorts > 63} {
      error "Number of axi protocol checkers requested must be between 1 and 63."
      return
    }
    # Make sure interface pins exist
    set checkerPins {}
    for { set i 0 } { $i < $numPorts } { incr i } {
      set checkerPinName [lindex $checkerList $i]
      if { [get_bd_intf_pins $checkerPinName -quiet] eq "" } {
        error "Unable to find interface pin $checkerPinName for AXI protocol checker insertion"
        return
      }

      lappend checkerPins [get_bd_intf_pins $checkerPinName]
    }

    set liteMaster [get_bd_intf_pins "${interconobj}/${currentMasterName}_AXI"]

    #connect the clk and reset of the new master-interface to the slower mgmt clk  
    #This is not performance efficient, but works better in meeting timing

    set mgmt_clk [get_axi_lite_clk]
    set mgmt_reset [get_axi_lite_reset]
    #puts "mgmt_clk = $mgmt_clk mgmt_reset = $mgmt_reset"
    connect_bd_net $mgmt_clk [get_clk_from_intf_pin "${interconobj}/${currentMasterName}_AXI"]

    #puts "PC: Connected $mgmt_clk [get_clk_from_intf_pin "${interconobj}/${currentMasterName}_AXI" ]"

    #get_reset_from_intf_pin did not return correct reset
    #set liteMaster_resetpin [get_bd_pins "interconnect_axilite_user/${currentMasterName}_ARESETN"]
    set liteMaster_resetpin [get_reset_from_intf_pin "${interconobj}/${currentMasterName}_AXI"]
    
    connect_bd_net $mgmt_reset [get_bd_pins $liteMaster_resetpin]
    #puts "PC: Connected $mgmt_reset  $liteMaster_resetpin"

    puts "--- DEBUG: Adding Protocol checkers $name - lite master: $liteMaster"
    puts "--- DEBUG:     slots: $slots"
    add_axi_checkers $liteMaster $interconobj $checkerPins
    
    # Create hierarchy
    group_bd_cells Checkers [get_bd_cells xilproto*]
    save_bd_design
    puts "--- DEBUG: Completed adding axi checkers"
  }; # end update_axi_checkers
  
  ################################################################################
  # add_axi_checkers
  #   Description:
  #     Insert axi protocol checkers into IPI diagram to monitor the ports in checkerList
  #     NOTE: this uses the next generation monitor IP
  #   Arguments:
  #     liteMaster       AXI Lite master (BD interface pin)
  #     interconnectAxiLite      AXI Lite interconnect
  #     checkerPins      List of AXI interface ports to monitor
  ################################################################################
  proc add_axi_checkers {liteMaster interconnectAxiLite checkerPins} {
    # Constants
    set protoName "xilproto"
    set interconName "xilproto_intercon"

    #
    # Initialization
    #
   
    # Ensure correct number of checker ports
    set numPorts [llength $checkerPins]

    puts "---DEBUG: Adding AXI protocol checkers ..."

    # 
    # Insert cores
    #
    
    # AXI-Protocol Checkers
    puts "--- DEBUG: Inserting AXI-Protocol Checkers: $protoName..."
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currProtoName ${protoName}$i
      set proto_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_checker:2.0 $currProtoName]

	  #Lightweight
	  set_property -dict [list CONFIG.LIGHT_WEIGHT {1}] [get_bd_cells $currProtoName]
      #enable saxi
      set_property -dict [list CONFIG.ENABLE_CONTROL {1}] $proto_obj
      #These max rd/wr bursts to max (64). Kernels very unlikley to exceed this high value
      set_property -dict [list CONFIG.MAX_RD_BURSTS {64} CONFIG.MAX_WR_BURSTS {64}] [get_bd_cells $currProtoName]
      #set to maximum
	  set_property -dict [list CONFIG.MAX_AW_WAITS {1024} CONFIG.MAX_AR_WAITS {1024} CONFIG.MAX_W_WAITS {1024} CONFIG.MAX_R_WAITS {1024} CONFIG.MAX_B_WAITS {1024}] [get_bd_cells  $currProtoName]
	  set_property -dict [list CONFIG.MAX_CONTINUOUS_WTRANSFERS_WAITS {65536} CONFIG.MAX_WLAST_TO_AWVALID_WAITS {65536} CONFIG.MAX_WRITE_TO_BVALID_WAITS {65536} CONFIG.MAX_CONTINUOUS_RTRANSFERS_WAITS {65536}] [get_bd_cells $currProtoName]
	  
      add_debug_ip LAPC $currProtoName [lindex $checkerPins $i]
    }

    # AXI interconnect
    # NOTE: use v2 AXI interconnect instead of Smart Connect since max # SI or MI = 64
    puts "--- DEBUG: Inserting AXI interconnect: $interconName..."
    set numSlaves 1
    set numMasters $numPorts
    set intercon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect $interconName]
    #set intercon_obj [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect $interconName]
    set_property CONFIG.NUM_SI $numSlaves $intercon_obj
    set_property CONFIG.NUM_MI $numMasters $intercon_obj

    for { set i 0 } { $i < $numSlaves } { incr i } {
      set axiSlaveRegSlice [expr { ($i >= 10) ? "S${i}_HAS_REGSLICE" : "S0${i}_HAS_REGSLICE" } ]
      set_property CONFIG.$axiSlaveRegSlice 1 $intercon_obj
    }
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiMasterRegSlice [expr { ($i >= 10) ? "M${i}_HAS_REGSLICE" : "M0${i}_HAS_REGSLICE" } ]
      set_property CONFIG.$axiMasterRegSlice 1 $intercon_obj
    }
    #
    # Connect clocks & resets  
    #
    puts "--- DEBUG: Connecting clocks and resets..."
    
    # Clocks
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currProtoName ${protoName}$i
      set currClock [get_clk_from_intf_pin [lindex $checkerPins $i]]
      
      connect_bd_net [get_bd_pins $currClock] [get_bd_pins $currProtoName/aclk]
    }

    set interconnect_axilite_clk [find_bd_objs -relation connected_to -thru_hier [get_bd_pins -quiet $interconnectAxiLite/ACLK]]
    puts "---DEBUG Connecting:  [get_bd_port $interconnect_axilite_clk] [get_bd_pins $interconName/ACLK]"
    connect_bd_net  [get_bd_port $interconnect_axilite_clk] [get_bd_pins $interconName/ACLK]
    
    for { set i 0 } { $i < $numSlaves } { incr i } {
      set axiClkName [expr { ($i >= 10) ? "S${i}_ACLK" : "S0${i}_ACLK" } ]
      puts "---DEBUG Connecting:  [get_bd_port $interconnect_axilite_clk] [get_bd_pins $interconName/$axiClkName]"
      connect_bd_net  [get_bd_port $interconnect_axilite_clk] [get_bd_pins $interconName/$axiClkName]
    }
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiClkName [expr { ($i >= 10) ? "M${i}_ACLK" : "M0${i}_ACLK" } ]
      
      set currClock [get_clk_from_intf_pin [lindex $checkerPins $i]]
      connect_bd_net [get_bd_pins $currClock] [get_bd_pins $interconName/$axiClkName]
    }
    
    # Resets
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currProtoName ${protoName}$i
      set currReset [get_reset_from_intf_pin [lindex $checkerPins $i]]
      #puts "PC: CheckerPin [lindex $checkerPins $i] reset is $currReset"
      #puts "PC: Connecting0 [get_bd_pins $currReset] to [get_bd_pins $currProtoName/aresetn]"
      connect_bd_net [get_bd_pins $currReset] [get_bd_pins $currProtoName/aresetn]
    }

    # Interconnect reset
    set interconnect_axilite_reset [find_bd_objs -relation connected_to -thru_hier [get_bd_pins -quiet $interconnectAxiLite/ARESETN]]
    puts "---DEBUG Connecting:  $interconnect_axilite_reset [get_bd_pins $interconName/ARESETN]"
    connect_bd_net $interconnect_axilite_reset [get_bd_pins $interconName/ARESETN]

    for { set i 0 } { $i < $numSlaves } { incr i } {
      set axiRstName [expr { ($i >= 10) ? "S${i}_ARESETN" : "S0${i}_ARESETN" } ]
      puts "---DEBUG Connecting slave reset: $interconnect_axilite_reset to $interconName/$axiRstName"
      connect_bd_net $interconnect_axilite_reset [get_bd_pins $interconName/$axiRstName]
    }
    for { set i 0 } { $i < $numMasters } { incr i } {
      set axiRstName [expr { ($i >= 10) ? "M${i}_ARESETN" : "M0${i}_ARESETN" } ]
      
      set currReset [get_reset_from_intf_pin [lindex $checkerPins $i]]
	  #puts "PC: Connecting3:  [get_bd_pins $currReset] to [get_bd_pins $interconName/$axiRstName]"
      connect_bd_net [get_bd_pins $currReset] [get_bd_pins $interconName/$axiRstName]
    }
    
    # Make Connections
    #
    puts "---DEBUG: Connecting all blocks... "
    
    # Checker ports
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currProtoName ${protoName}$i
      connect_bd_intf_net [get_bd_intf_pins $currProtoName/PC_AXI] [lindex $checkerPins $i]
    }
    
    # Interconnect slaves
    connect_bd_intf_net $liteMaster [get_bd_intf_pins $interconName/S00_AXI]
    
    # Interconnect masters
    for { set i 0 } { $i < $numPorts } { incr i } {
      set currProtoName ${protoName}$i
      set axiMasterName [expr { ($i >= 10) ? "M${i}_AXI" : "M0${i}_AXI" } ]
      connect_bd_intf_net [get_bd_intf_pins $interconName/$axiMasterName] [get_bd_intf_pins $currProtoName/S_AXI]
    }

    puts "  Completed adding AXI checkers at ports: $checkerPins"
  }; # end add_axi_checkers  
################################PC###################################

}; # end namespace


