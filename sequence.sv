class sequencet extends uvm_sequence #(transaction);
  `uvm_object_utils(sequencet)
  transaction tr;
  
  function new(string name="sequencet");
    super.new(name);
    $display("NEW-SEQUENCE");
  endfunction
  
  task body();
    if(starting_phase != null) begin
    uvm_objection objection = starting_phase.get_objection();
  end

    tr=transaction::type_id::create ("tr");
    forever begin
      start_item(tr);
      assert(tr.randomize());
      //$display("tlps randomized");
      finish_item(tr);
      if(starting_phase != null) begin
        starting_phase.drop_objection(this);
      end
    end
  endtask
  
endclass
