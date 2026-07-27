class mySeq extends uvm_sequence;
    `uvm_object_utils(mySeq)

    function new(string name="mySeq");
        super.new(name);
    endfunction

    virtual task body();
        instr i = instr::type_id::create("i");

        // Sanity check
        i = instr::type_id::create("i");
        i.instr = 'hD0; i.cte = 'hAA;
        start_item(i); finish_item(i);

        i = instr::type_id::create("i");
        i.instr = 'hD1; i.cte = 'h11;
        start_item(i); finish_item(i);

        i = instr::type_id::create("i");
        i.instr = 'hD2; i.cte = 'h22;
        start_item(i); finish_item(i);

        i = instr::type_id::create("i");
        i.instr = 'hD3; i.cte = 'h33;
        start_item(i); finish_item(i);
        
        repeat (1000) begin
            i = instr::type_id::create("i");
            i.randomize();
            start_item(i);
            finish_item(i);
        end

    endtask
endclass