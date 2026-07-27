class instr extends uvm_sequence_item;    
    `uvm_default_new(instr)

	rand bit [7:0] instr;	// Instrução
	rand bit [7:0] cte;		// Dados

endclass 

// Bus snapshot
class bus_state extends uvm_object;    
    `uvm_default_new(bus_state)

    bit [7:0] addr;
    bit [7:0] data;
    bit       wr;

endclass

// CPU snapshot
class cpu_state extends uvm_object;    
    `uvm_default_new(cpu_state)

    bit [7:0] r [0:3];  // CPU Regs
    bit [1:0] f;        // CPU Flags

endclass

// View of all cpu and bus states
class view extends uvm_sequence_item;
  `uvm_object_utils(view)

  bus_state bus [0:5];
  cpu_state cpu [0:5];

  function new(string name = "view");
    super.new(name);
    foreach (bus[i]) begin
        bus[i] = bus_state::type_id::create($sformatf("bus[%0d]", i));
    end
    foreach (cpu[i]) begin
        cpu[i] = cpu_state::type_id::create($sformatf("cpu[%0d]", i));
    end
  endfunction

  function string print();
    return { "\n", 
    $sformatf("      FE | DE | FC | EX | WR | RES\n"),
    $sformatf("ADDR: %h | %h | %h | %h | %h | %h\n",
      bus[0].addr, bus[1].addr, bus[2].addr, bus[3].addr, bus[4].addr, bus[5].addr),
    $sformatf("DATA: %h | %h | %h | %h | %h | %h\n",
      bus[0].data, bus[1].data, bus[2].data, bus[3].data, bus[4].data, bus[5].data),
    $sformatf("  WR:  %h |  %h |  %h |  %h |  %h |  %h\n",
      bus[0].wr,   bus[1].wr,   bus[2].wr,   bus[3].wr,   bus[4].wr,   bus[5].wr  ),
    $sformatf("  R0: %h | %h | %h | %h | %h | %h\n",
      cpu[0].r[0], cpu[1].r[0], cpu[2].r[0], cpu[3].r[0], cpu[4].r[0], cpu[5].r[0]),
    $sformatf("  R1: %h | %h | %h | %h | %h | %h\n",
      cpu[0].r[1], cpu[1].r[1], cpu[2].r[1], cpu[3].r[1], cpu[4].r[1], cpu[5].r[1]),
    $sformatf("  R2: %h | %h | %h | %h | %h | %h\n",
      cpu[0].r[2], cpu[1].r[2], cpu[2].r[2], cpu[3].r[2], cpu[4].r[2], cpu[5].r[2]),
    $sformatf("  R3: %h | %h | %h | %h | %h | %h\n",
      cpu[0].r[3], cpu[1].r[3], cpu[2].r[3], cpu[3].r[3], cpu[4].r[3], cpu[5].r[3]),
    $sformatf("  ZC: %b | %b | %b | %b | %b | %b\n",
      cpu[0].f,    cpu[1].f,    cpu[2].f,    cpu[3].f,    cpu[4].f   , cpu[5].f   )
    };
  endfunction 

    function void copy(view v);
        foreach (v.bus[i]) begin
            this.bus[i].copy(v.bus[i]);
        end
        foreach (cpu[i]) begin
            this.cpu[i].copy(v.cpu[i]);
        end
    endfunction

endclass