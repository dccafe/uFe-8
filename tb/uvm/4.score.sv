class myScore extends uvm_scoreboard;
	`uvm_component_utils(myScore)
	
	view v;
	virtual probe_if probe;
	uvm_analysis_imp #(view, myScore) sub;

	function new(string name="myScore", uvm_component parent=null);
		super.new(name, parent);
		this.v = new();
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		uvm_config_db #(virtual probe_if) 
			::get (this, "", "probe", probe);

		sub = new("sub",this);
	endfunction

	virtual function void write(view v);

		// Get values
		bit [7:0] res, exp;

		// Save new data from the bus
		bit [7:0] instr = v.bus[fetch].data; 
		bit [7:0] cte   = v.bus[2].data; //fetch_cte

		// Decode instruction bits
		bit [2:0] opc  = instr[7:5];
		bit       c    = instr[4];
		bit [1:0] src  = instr[3:2];
		bit [1:0] dst  = instr[1:0];

		bit [7:0] op1 = c ? cte : v.cpu[4].r[src];
		bit [7:0] op2 =           v.cpu[4].r[dst];

		bit [1:0] jump_cond = instr[1:0];
		bit jump_taken = 0;
		case (jump_cond)
			0: jump_taken =  v.cpu[0].f[0]; // JC
			1: jump_taken =  v.cpu[0].f[1]; // JZ
			2: jump_taken = ~v.cpu[0].f[1]; // JNZ
			3: jump_taken =  1;             // JMP
			default : /* default */;
		endcase

		case (opc)
			6: exp = op1;       // MOV
			0: exp = op1 + op2; // ADD
			1: exp = op1 & op2; // AND
			2: exp = op1 ^ op2; // XOR
			3: exp = op1 | op2; // OR
			4: begin // LD @Rs, Rd
				exp = c ? 
					v.bus[fetch_cte].data :
					v.bus[exec].data;
			end
			5: begin // ST Rs/#i, @Rd
				if(!v.bus[4].wr)
					`uvm_error("SCORE", 
						$sformatf("FAIL: Instruction STORE not setting bus WR"))
				
				if (v.bus[4].data != op1)
					`uvm_error("SCORE", 
						$sformatf("FAIL: Bus data (%h) != src val  (%h)", v.bus[4].data, op1))

				if (v.bus[4].addr != op2)
					`uvm_error("SCORE", 
						$sformatf("FAIL: Bus addr (%h) != dst addr (%h)", v.bus[4].addr, op2))

				exp = c ?
					v.bus[fetch_cte].data :
					v.bus[4].data;
			end
			7: begin // JMPs
				if(jump_taken)
					exp = cte;
				else
					exp = v.bus[4].addr;
			end
			default : $display("Should never happen");
		endcase

		// For jump operations
		// Result = cpu destination register
		case (opc)
			5: res = op1;
			7: res = v.bus[5].addr;
			default : res = v.cpu[5].r[dst];
		endcase

		// For Store operation
		// result is src register


		if(res == exp)
			`uvm_info("SCORE", 
				$sformatf("PASS: %h == %h", res, exp), UVM_HIGH)
		else begin
			`uvm_error("SCORE", 
				$sformatf("FAIL: %h != %h", res, exp))
			`uvm_info("SCORE", 
				$sformatf("While checking i:{%h (%h %h %h %h), %h}", 
					instr, opc, c, src, dst, cte), UVM_LOW)
			`uvm_info("SCORE", 
				$sformatf("Operands where: %h %h", 
					op1, op2), UVM_LOW)
			`uvm_info("SCORE", 
				$sformatf("%s---------------------------------", 
					v.print()), UVM_LOW)
	   	

		end
	endfunction
endclass

