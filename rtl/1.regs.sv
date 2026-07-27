module regs #(N=8)
(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low	

	input  logic         wr,
	input  logic [N-1:0] in,
	input  logic [  1:0] s1, s2,
	output logic [N-1:0] o1, o2
);

logic [N-1:0] r [0:3];

assign o1 = r[s1];
assign o2 = r[s2];

always_ff @(posedge clk or negedge rst_n) begin : reg_bank
	if(~rst_n) begin
		r[0] <= 0;
		r[1] <= 0;
		r[2] <= 0;
		r[3] <= 0;
	end else begin
		if(wr)
			r[s2] <= in;
	end
end

endmodule : regs