class myCoverage extends uvm_subscriber #(alu_tx);
    `uvm_component_utils(myCoverage)

    // uvm_analysis_imp #(T, this_type) analysis_export;	// A porta [analysis_export] vem por default no uvm_subscrirber
    alu_tx tx;							                    // Criamos o handle [tx] 

    covergroup cg;						                    // Define o covergroup CG

        opcode_cp : coverpoint tx.opcode {
                        bins ADD  = {ADD};			        // O bins ADD incrementa quando opcode = 3'b000 [=ADD]
                        bins SUB  = {SUB};			        // Etiquetas facilita manutençao do codigo
                        bins AND  = {AND_OP};
                        bins OR	  = {OR_OP};
                        bins XOR  = {XOR_OP};
                        bins NOT  = {NOT_OP};
                        bins SHL  = {SHL};
                        bins SHR  = {SHR};
		} 

        A_cp : coverpoint tx.A { 
                        bins A[ ] = {[0:15]};			    // Cria um vector de 16 bins para A 
	        } 
        B_cp : coverpoint tx.B {
                        bins B[ ] = {[0:15]};			    // Cria um vector de 16 bins para B
                }
        TOTAL_cp: cross opcode_cp, A_cp, B_cp;			    // Multiplicacao matricial entre opcode_cp, A_cp e B_cp 

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();						                    // Instancia o CG na memoria 
    endfunction

    function void write(alu_tx t);
        tx = t;
        cg.sample();						                // Pega os valores de tx, CG incrementa os contadores de bins
	`uvm_info("COV", $sformatf( "COV A=%0d B=%0d OPCODE=%0d ", tx.A, tx.B, tx.opcode ), UVM_LOW )
    endfunction

endclass
