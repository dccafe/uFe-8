create_power_domain PD -include_scope

set power_nets  {VDD}
set ground_nets {VSS}

foreach net [concat $power_nets $ground_nets] { 
	create_supply_net  $net -domain PD  
	create_supply_port $net -domain PD -direction in  
	connect_supply_net $net -ports $net 
}

set_domain_supply_net -primary_power_net VCCD -primary_ground_net VSSD PD

add_port_state VDDIO -state {ON 1.8}
add_port_state VDDA  -state {ON 1.8}
add_port_state VCCD  -state {ON 1.8}
add_port_state VSSIO -state {ON 0}
add_port_state VSSA  -state {ON 0}
add_port_state VSSD  -state {ON 0}

create_pst -supplies {VDDIO VDDA VCCD VSSIO VSSA VSSD} power_table
add_pst_state -pst power_table -state {ON ON ON ON ON ON} ALL_ON

# ----------------------------------------------------------------

create_supply_net VDD
create_supply_net VSS
create_supply_set ss_main -function {power VDD} -function {ground VSS}
create_power_domain PD_TOP -elements {cpu} -supply {primary ss_main}

create_supply_port VDD -domain PD_TOP -direction in
create_supply_port VSS -domain PD_TOP -direction in
connect_supply_net VDD -ports VDD
connect_supply_net VSS -ports VSS

add_power_state \
	-supply ss_main \
	-state main_OFF { \
		-supply_expr { power  == {OFF}           && \
					   ground == {FULL_ON 0.0} } } \
	-state ON_1p16  { \
		-supply_expr { power  == {FULL_ON 1.16 } && \
					   ground == {FULL_ON 0.0} } } \
	-state ON_0p95  { \
		-supply_expr { power  == {FULL_ON 0.95 } && \
		 			   ground == {FULL_ON 0.0} } } \
	-state ON_0p75  { \
		-supply_expr { power  == {FULL_ON 0.75 } && \
					   ground == {FULL_ON 0.0} } }

# Level shifters
# Isolation 
# Retention
