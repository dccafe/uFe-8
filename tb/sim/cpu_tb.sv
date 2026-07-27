module cpu_tb;

logic [7:0] rom [0:21] = 
'{
	8'hD0, 8'h00, 8'hD1, 8'h00, 
	8'hD2, 8'h04, 8'hD3, 8'h03, 
	8'h08, 8'hFC, 8'h0D, 8'hFF, 
	8'h0F, 8'h11, 8'h01, 8'h13, 
	8'hFF, 8'hFE, 8'h08, 8'hFF, 
	8'h13, 8'h00
};

logic clk, rst_n;
wire  [7:0] data;
logic [7:0] addr;

cpu dut (clk, rst_n, data, addr, wr);
assign data = rom[addr];

initial begin
	clk=0; rst_n=1; #1000;
	clk=0; rst_n=0; #1000; // Reset
	clk=0; rst_n=0; #1000;
	clk=0; rst_n=1; #1000;
	for (int i = 0; i < 21*5; i++) begin
		clk=0; #1000;
		clk=1; #1000;
	end
end

initial begin
	$monitor("R0=%d R1=%d R2=%d R3=%d", 
		        dut.i_regs.r[0],
		        dut.i_regs.r[1],
		        dut.i_regs.r[2],
			dut.i_regs.r[3]);
end

// Faz o dump para o verdi
//initial begin
//    $fsdbDumpfile("novas.fsdb");
//    $fsdbDumpvars(0, dut);
//end

endmodule : cpu_tb
