class myAgent extends uvm_agent;
    `uvm_component_utils(myAgent)

    myDriver                driver;
    myMonitor               monitor;
    uvm_sequencer #(instr) sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer = uvm_sequencer #(instr)
                    ::type_id::create("sequencer", this);
        driver  = myDriver
                    ::type_id::create("driver",    this);
        monitor = myMonitor
                    ::type_id::create("monitor",   this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(
            sequencer.seq_item_export);
    endfunction
endclass 
