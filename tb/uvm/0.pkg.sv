`define uvm_default_new(s)              \
                                        \
    `uvm_object_utils(s)                \
                                        \    
    function new(string name = `"s`");  \
        super.new(name);                \
    endfunction

// End uvm_default_new

package pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import cpu_pkg::*;
    `include "1.item.sv"
    `include "2.seq.sv"
    `include "3.driver.sv"
    `include "3.monitor.sv"
    `include "4.agent.sv"
    `include "4.score.sv"
    `include "5.env.sv"
    `include "6.test.sv"

endpackage
