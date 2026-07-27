class myMonitor extends uvm_monitor;
    `uvm_component_utils(myMonitor)

    virtual bus_if   vif;
    virtual probe_if probe;
    uvm_analysis_port #(view) pub;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db #(virtual bus_if) 
            ::get (this, "", "vif", vif);
        uvm_config_db #(virtual probe_if) 
            ::get (this, "", "probe", probe);
        pub = new("pub", this);
    endfunction

    virtual task main_phase (uvm_phase phase);
        int st;
        view  v = view::type_id::create("v");
        view v1, v2;
        super.main_phase(phase);

        v1 = new();
        forever begin

            @(vif.cb);

            if (probe.cb.st == 0) begin
                v2 = v1;
                v1 = new();
                // 5 is the result
                v2.bus[5].addr = vif.cb.addr;
                v2.bus[5].data = vif.cb.data; 
                v2.bus[5].wr   = vif.cb.wr; 
                v2.cpu[5].r    = probe.cb.r;
                v2.cpu[5].f    = probe.cb.flags;
                pub.write(v2);
            end

            v1.bus[probe.cb.st].addr = vif.cb.addr;
            v1.bus[probe.cb.st].data = vif.cb.data; 
            v1.bus[probe.cb.st].wr   = vif.cb.wr; 
            v1.cpu[probe.cb.st].r    = probe.cb.r;
            v1.cpu[probe.cb.st].f    = probe.cb.flags;

            
        end
    endtask 
  
endclass
