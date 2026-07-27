set TOP cpu
set_host_options -max_cores 4

source ../scripts/createLib.tcl

analyze -format sverilog ../rtl/0.bus_if.sv
analyze -format sverilog ../rtl/1.ctrl.sv
analyze -format sverilog ../rtl/1.regs.sv
analyze -format sverilog ../rtl/1.ula.sv
analyze -format sverilog ../rtl/2.cpu.sv

elaborate      $TOP
set_top_module $TOP

source ../constraints/timing.tcl
source ../constraints/floorplan.tcl

set_parasitic_parameters \
    -corner default      \
    -early_spec tlup_min \
    -late_spec  tlup_max

compile_fusion
place_opt
clock_opt
route_auto
route_opt

write_verilog   ../syn/mapped.$T.v
report_timing > ../report/timing.$T.rpt
report_area   > ../report/area.$T.rpt
