import uvm_pkg::*;
import cpu_pkg::st_t;

interface probe_if(
    input bit clk,
    input bit [7:0] r [0:3],
    input st_t st,
    input bit [7:0] pc, ir, cte,
    input bit [1:0] flags);

    clocking cb @(posedge clk);
        default input #2 output #2;
        input r, st, pc, ir, cte, flags;
    endclocking

endinterface

module uvm_tb;
	
    bit clk, rst_n;
    initial begin
        forever #5 clk = ~clk;
    end

	bus_if bus(clk);
	cpu dut(
        .clk    (clk),
        .rst_n  (bus.rst_n),
        .data   (bus.data),
        .addr   (bus.addr ),
        .bus_wr (bus.wr   )
    );

    // Cria uma sonda para ter acesso aos 
    // sinais internos do processador
    bind dut probe_if probe_inst 
    (
        .clk(clk),
        .r(i_regs.r),
        .st(i_ctrl.current_state),
        .pc(pc), .ir(ir), .cte(cte_reg),
        .flags(i_ctrl.flags_reg)
    );

    initial begin
        uvm_config_db #(virtual bus_if)
            ::set(null, "*", "vif", bus);
        uvm_config_db #(virtual probe_if)
            ::set(null, "*", "probe", dut.probe_inst);

        run_test();
    end

    initial begin
        $fsdbDumpfile("sim/novas.fsdb");
        $fsdbDumpvars(0, uvm_tb);
    end

endmodule