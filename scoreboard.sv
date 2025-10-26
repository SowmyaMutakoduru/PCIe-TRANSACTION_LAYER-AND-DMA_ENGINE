class scoreboard extends uvm_scoreboard;
  `uvm_component_utils (scoreboard)
  `uvm_analysis_imp_decl(_mon)
  `uvm_analysis_imp_decl(_rm)
  int sb_count=0;
  uvm_event Done;
  uvm_analysis_imp_mon#(bit [31:0], scoreboard) from_mon;
  uvm_analysis_imp_rm#(bit [31:0], scoreboard) from_rm ;
  bit[31:0] trans_rm[$], trans_mon[$] ;
  int length;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    from_mon=new("from_mon", this);
    from_rm=new("from_rm", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase (phase);
    Done = new("Done");
    uvm_config_db#(uvm_event)::set(null,"uvm_test_top","Done", Done);
  endfunction

  function void write_mon(bit[31:0] t);
    trans_mon.push_back(t);
    //`uvm_info("SCOREBOARD WRITE MON", $sformatf("trans_mon %p", trans_mon),UVM_LOW);
  endfunction
                        
  function void write_rm(bit[31:0] t);
    trans_rm.push_back(t);
    //`uvm_info("SCOREBOARD WRITE RM", $sformatf("trans_rm %p",trans_rm), UVM_LOW);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      wait(trans_mon.size()>0 && trans_rm.size() >0)begin
        `uvm_info("SCOREBOARD COMPARE", $sformatf("%d %d", trans_rm[0], trans_mon[0]) , UVM_LOW) ;
        if(trans_rm[0] == trans_mon[0]) begin
          trans_mon. pop_front();
          trans_rm.pop_front();
          `uvm_info("SCOREBOARD COMPARE", $sformatf("equal") , UVM_LOW);
        end
        else begin
          trans_mon.pop_front();
          trans_rm.pop_front();
        end
      end
    end
  endtask

endclass
