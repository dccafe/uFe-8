package cpu_pkg;
    typedef enum {
        fetch, 
        decode, 
        fetch_cte, 
        exec, 
        write
    } st_t;
endpackage

interface bus_if 
#(
    parameter AW = 8,
    parameter DW = 8
) (
    input bit clk
);

    logic rst_n, wr;
    logic [AW-1:0] addr;
    wire  [DW-1:0] data;

    // Resolve synchornous operations
    // from testbench point of view
    clocking cb @(posedge clk);
        default input #2 output #2;
        input  addr, wr;
        output rst_n;
        inout  data;
    endclocking

    modport master 
    (
        input clk, rst_n,
        output addr, wr,
        inout  data
    );

    modport slave 
    (
        input clk, rst_n,
        input wr, addr, 
        inout data
    );

endinterface

