module cpu #(N=8)
(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	inout  wire  [N-1:0] data,
	output logic [N-1:0] addr,
	output bus_wr
);

logic [N-1:0] reg_in, o1, o2, src, dst, res, cte_reg, ir, pc;
logic [  1:0] bus_addr_sel, reg_in_sel, reg_s1, reg_s2, ula_flags, ula_op;

ctrl i_ctrl (clk, rst_n, 
	ir, ula_flags, pc_ld, fetch_instr, fetch_cte,
	bus_wr, bus_addr_sel, reg_wr, ula_A_sel, 
	reg_in_sel, reg_s1, reg_s2, ula_op);
regs i_regs (clk, rst_n, 
	reg_wr, reg_in, reg_s1, reg_s2, 
	o1, o2);
ula  i_ula  (src, dst, ula_op, res, ula_flags);

assign dst = o2;

// Muxes
// Bus data connection
assign src  = ula_A_sel? o1 : cte_reg;
assign data = bus_wr   ? src: 'z;


always_comb begin
	reg_in = src;
	case(reg_in_sel)
		0: reg_in = res;
		1: reg_in = data;
	endcase
end

always_comb begin
	addr = dst;
	case(bus_addr_sel)
		0: addr = pc;
		1: addr = src;
	endcase
end

// Program Counter
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pc <= 0;
	end else if (pc_ld) begin
		pc <= cte_reg;
	end else if (fetch_instr || fetch_cte) begin
		pc <= pc + 1;
	end
end

// Instruction Register
always_ff @(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		ir <= 0;
	end else if(fetch_instr) begin
		ir <= data;
	end
end

// Constant Register
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cte_reg <= 0;
	end else if(fetch_cte) begin
		cte_reg <= data;
	end
end



endmodule : cpu