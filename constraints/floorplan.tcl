foreach layer {M1 M3 M5 M7 M9} {
	set_attribute               \
		-name routing_direction \
		-value vertical         \
		[get_layer $layer ]  
}

foreach layer {M2 M4 M6 M8 MRDL} {
	set_attribute               \
		-name routing_direction \
		-value horizontal       \
		[get_layer $layer ]  
}

#initialize_floorplan -side_length {40 40}
