class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  virtual intf if_f;
  transaction tr;
  int mon_count=0;
  uvm_analysis_port#(transaction)mon_ap_ref;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_ap_ref=new("mon_ap_ref", this);
    if(!uvm_config_db#(virtual intf) :: get(this,"","if_f",if_f))
    `uvm_fatal(get_type_name() ,"vif is not set")
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      tr=transaction::type_id::create ("tr");
      wait(if_f.tl.tb_tl_valid && if_f.tl.tb_tl_ready)
      wait(if_f.tl.tb_tl[7:0] == 4 )begin
      //`uvm_info("monitor input",$sformatf("monitor"),UVM_LOW);
        repeat(2)@(posedge if_f.clk)begin
          wait(if_f.tl.tb_tl_valid && if_f.tl.tb_tl_ready);
        end
        @(posedge if_f.clk)
        tr.tlp_descriptor_payload[0]= if_f.tb_tl;
        repeat(2)@(posedge if_f.clk)
        tr.tlp_descriptor_payload[2]= if_f.tb_tl;
        // `uvm_info("monitor to reference", $sformatf("to reference port %d", if_f.tb_tl), UVM_LOW);
        mon_ap_ref.write(tr);
      end
    end
  endtask
endclass
