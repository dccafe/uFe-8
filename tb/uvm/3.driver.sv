class myDriver extends uvm_driver #(instr);
	`uvm_component_utils(myDriver)
	
	virtual bus_if vif;
	virtual probe_if probe;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db #(virtual bus_if) 
			::get(this, "", "vif", vif);
		uvm_config_db #(virtual probe_if) 
			::get (this, "", "probe", probe);
	endfunction

	virtual task reset_phase(uvm_phase phase);
		super.reset_phase(phase);
		phase.raise_objection(this);
		`uvm_info("DRIVER","Starting reset", UVM_LOW);
		@(vif.cb);
		vif.cb.rst_n <= 0;
		@(vif.cb);
		vif.cb.rst_n <= 1;
		@(vif.cb);
		@(vif.cb);
		vif.cb.rst_n <= 0;
		@(vif.cb);
		vif.cb.rst_n <= 1;
		@(vif.cb);
		@(vif.cb);
		@(vif.cb);
		vif.cb.rst_n <= 0;
		@(vif.cb);
		vif.cb.rst_n <= 1;
		@(vif.cb);
		@(vif.cb);
		@(vif.cb);
		@(vif.cb);
		vif.cb.rst_n <= 0;
		@(vif.cb);
		vif.cb.rst_n <= 1;
		`uvm_info("DRIVER","Ended reset phase", UVM_LOW);
		phase.drop_objection(this);
	endtask

	virtual task main_phase(uvm_phase phase);
		instr i;
		super.main_phase(phase);
		forever begin
			seq_item_port.get_next_item(i);
			phase.raise_objection(this);

			// For now, CPU does not support
			// malformed jump instructions
			// i.e. cte bit should always be 1
			// for jump instructions

			if(i.instr[7:4] == 14)
				i.instr[4] = 1;

//            `uvm_info("DRIVER",
//                $sformatf("Item {%h,%h}", 
//                          i.instr, i.cte), UVM_NONE);

			// Feed instruction,
			vif.cb.data <= i.instr;
			@(vif.cb); // fetch
			@(vif.cb); // decode 

			// If there is a constant, feed the constant
			if (i.instr[4]) begin
				vif.cb.data <= i.cte;
				@(vif.cb); // fetch cte
			end

			@(vif.cb); // exec

			if (i.instr[7:5] == 5) begin
				// If STORE, release bus
				vif.cb.data <= 'z;
			end

			@(vif.cb); // write

//            `uvm_info("DRIVER",
//                $sformatf("Ending Item"), UVM_NONE);

			seq_item_port.item_done();
			phase.drop_objection(this);

		end
	endtask
endclass

