if {![info exists T]} {
	set T 1
}

set T 1
set clkName my_clock
set inp [get_ports {data* }]
set out [get_ports {data* addr* bus_wr}]

# Clock
create_clock -name $clkName -period $T clk

set_clock_uncertainty   -setup [expr $T*0.1 ] $clkName
set_clock_transition      -max [expr $T*0.1 ] $clkName
set_clock_latency -source -max [expr $T*0.05] $clkName
set_clock_latency         -max [expr $T*0.03] $clkName
set_input_transition      -min [expr $T*0.01] $inp
set_input_transition      -max [expr $T*0.10] $inp
set_input_delay           -max [expr $T*0.4 ] -clock $clkName [get_ports $inp]
set_output_delay          -max [expr $T*0.5 ] -clock $clkName [get_ports $out]
set_load                  -max 0.04 $out
