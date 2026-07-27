module ctrl #(N=8) 
(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	input  logic [N-1:0] instr,
	input  logic [  1:0] ula_flags,

	output logic pc_ld, 
				 pc_cnt, 
				 cte_en,
				 bus_wr, 
	output logic [1:0] bus_addr_sel,
	output logic reg_wr,
				 ula_A_sel,

	output logic [   1:0] reg_in_sel,
				 reg_s1, reg_s2, 
				 ula_op
);

import cpu_pkg::*;
st_t current_state, next_state;

logic [2:0] op;
logic [1:0] src, dst, flags_reg;
logic cte, cond_met;

assign {op,cte,src,dst} = instr;

always_comb begin
	cond_met = 0;
	case (dst)
		0: cond_met =  flags_reg[0];	// JC
		1: cond_met =  flags_reg[1];	// JZ
		2: cond_met = ~flags_reg[1];	// JNZ
		3: cond_met =  1;				// JMP
	endcase
end


// output logic
always_comb begin
	reg_in_sel   = 'x;
	pc_ld        = 'x;
	pc_cnt       = 'x;
	cte_en       = 'x;
	reg_wr       = 'x;
	ula_A_sel    = 'x;
	reg_s1       = 'x;
	reg_s2       = 'x;
	ula_op       = 'x;
	bus_wr       = 'x;
	bus_addr_sel = 'x;

	case (current_state) 
		fetch: begin
			reg_in_sel   = 'x;
			pc_ld        = 0;
			pc_cnt       = 1;
			cte_en       = 0;
			reg_wr       = 0;
			ula_A_sel    = 'x;
			reg_s1       = 'x;
			reg_s2       = 'x;
			ula_op       = 'x;
			bus_wr       = 0;
			bus_addr_sel = 0;

		end

		decode: begin
			reg_in_sel   = 'x;
			pc_ld        = 0;
			pc_cnt       = 0;
			cte_en       = 0;
			reg_wr       = 0;
			ula_A_sel    = 'x;
			reg_s1       = 'x;
			reg_s2       = 'x;
			ula_op       = 'x;
			bus_wr       = 0;
			bus_addr_sel = 0;
		end

		fetch_cte: begin
			reg_in_sel   = 'x;
			pc_ld        = 0;
			pc_cnt       = 0;
			cte_en       = 1;
			reg_wr       = 0;
			ula_A_sel    = 'x;
			reg_s1       = 'x;
			reg_s2       = 'x;
			ula_op       = 'x;
			bus_wr       = 0;
			bus_addr_sel = 0;

		end

		exec: begin
			reg_in_sel   = 'x;
			pc_ld        = 0;
			pc_cnt       = 0;
			cte_en       = 0;
			reg_wr       = 0;
			ula_A_sel    = ~cte;
			reg_s1       = src;
			reg_s2       = dst;
			ula_op       = op[1:0];
			bus_wr       = 0;
			bus_addr_sel = 0;
			case(op)
				4: bus_addr_sel = 1; // LD (addr = src)
				5: bus_addr_sel = 2; // ST (addr = dst)
			endcase
		end

		write: begin
			case (op)
				0,1,2,3: reg_in_sel = 0;
				4:       reg_in_sel = 1;
				6:       reg_in_sel = 2;
				default: reg_in_sel = 'x;
			endcase
			pc_ld        = op==7?cond_met:0;
			pc_cnt       = 0;
			cte_en       = 0;
			reg_wr       = 1;
			case(op)
				5: reg_wr = 0;
				7: reg_wr = 0;
			endcase
			ula_A_sel    = ~cte;
			reg_s1       = src;
			reg_s2       = dst;
			ula_op       = op[1:0];
			bus_wr       = op==5;
			bus_addr_sel = 0;
			case(op)
				4: bus_addr_sel = 1; // LD (addr = src)
				5: bus_addr_sel = 2; // ST (addr = dst)
			endcase

		end

	endcase 
end

// next_state state logic
always_comb begin
	next_state <= fetch;
	case (current_state)
		fetch:     next_state <= decode;
		decode:    next_state <= cte?fetch_cte:exec;  
		fetch_cte: next_state <= exec;
		exec:      next_state <= write;
		write:     next_state <= fetch;
		default : /* default */;
	endcase
end

// state flip flops
always_ff @(posedge clk or negedge rst_n) begin : state_ff
	if(~rst_n) begin
		current_state <= fetch;
	end else begin
		current_state <= next_state;
	end
end

// Flags FF
always_ff @(posedge clk or negedge rst_n) begin : flags_ff
	if(~rst_n) begin
		flags_reg <= 0;
	end else begin
		if(current_state == exec && op[2] == 0)
			flags_reg <= ula_flags;
	end
end

endmodule : ctrl
