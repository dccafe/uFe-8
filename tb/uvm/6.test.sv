class myTest extends uvm_test;
    `uvm_component_utils(myTest)

    myEnv env;
    mySeq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = myEnv::type_id::create("env", this);
        seq = mySeq::type_id::create("seq");
    endfunction

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
