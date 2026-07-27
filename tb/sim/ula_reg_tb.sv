module ula_reg_tb;

parameter N = 8;

logic [N-1:0] A,B;
logic [  1:0] op;
logic [N-1:0] R;
logic [  1:0] flags;

logic clk;
logic rst_n;
logic wr;

logic [N-1:0] in, i;
logic [  2:0] s1, s2;

ula  i_ula (A,B,op,R,flags);
regs i_regs(clk,rst_n,wr,in,s1,s2,A,B);

logic in_sel;

assign in = in_sel? R : i;

initial begin
	clk=0; rst_n=1; in_sel=0; i=1; s1=0; s2=0; wr=1; op=0; #1;
	clk=1; rst_n=0; in_sel=0; i=1; s1=0; s2=0; wr=1; op=0; #1;
	clk=0; rst_n=0; in_sel=0; i=1; s1=0; s2=0; wr=1; op=0; #1;
	clk=1; rst_n=0; in_sel=0; i=0; s1=0; s2=0; wr=1; op=0; #1;
	clk=0; rst_n=1; in_sel=0; i=1; s1=0; s2=0; wr=1; op=0; #1;
	clk=1; rst_n=1; in_sel=0; i=1; s1=0; s2=0; wr=1; op=0; #1;
	clk=0; rst_n=1; in_sel=0; i=2; s1=0; s2=1; wr=1; op=0; #1;
	clk=1; rst_n=1; in_sel=0; i=2; s1=0; s2=1; wr=1; op=0; #1;
	clk=0; rst_n=1; in_sel=0; i=3; s1=0; s2=2; wr=1; op=0; #1;
	clk=1; rst_n=1; in_sel=0; i=3; s1=0; s2=2; wr=1; op=0; #1;
	clk=0; rst_n=1; in_sel=0; i=4; s1=0; s2=3; wr=1; op=0; #1;
	clk=1; rst_n=1; in_sel=0; i=4; s1=0; s2=3; wr=1; op=0; #1;

	clk=0; rst_n=1; in_sel=1; i=2; s1=1; s2=2; wr=0; op=0; #1;
	clk=1; rst_n=1; in_sel=1; i=2; s1=1; s2=2; wr=0; op=1; #1;
	clk=0; rst_n=1; in_sel=1; i=3; s1=1; s2=2; wr=0; op=2; #1;
	clk=1; rst_n=1; in_sel=1; i=3; s1=1; s2=2; wr=0; op=3; #1;
end

initial begin
	$monitor("ck=%d rst=%d si=%d i=%02h s1=%02h s2=%02h wr=%d op=%d A=%02h B=%02h R=%02h f=%d",
		      clk, rst_n, in_sel, i, s1, s2, wr, op,  A,  B,  R, flags );
end

endmodule
