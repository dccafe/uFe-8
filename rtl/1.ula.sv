module ula #(N = 8) 
(
	input  logic [N-1:0] A,B,
	input  logic [  1:0] op,
	output logic [N-1:0] R,
	output logic [  1:0] flags
);

logic co, z;

assign z = (R == 0);
assign flags = {z, co};

always_comb begin
	co = ~z;
	case (op)
		0: {co,R} = A + B;
		1:     R  = A & B;
		2:     R  = A ^ B;
		3:     R  = A | B;
		default : /* default */;
	endcase
end

endmodule : ula