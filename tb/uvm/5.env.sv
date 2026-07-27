class myEnv extends uvm_env;
    `uvm_component_utils(myEnv)

    function new(string name="myEnv", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    
    myAgent agent;
    myScore score;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = myAgent::type_id::create("myAgent",this);
        score = myScore::type_id::create("myScore",this);
    endfunction 

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.pub.connect(score.sub);
    endfunction
endclass