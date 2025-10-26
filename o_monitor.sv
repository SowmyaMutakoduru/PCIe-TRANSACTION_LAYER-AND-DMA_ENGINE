class o_monitor extends uvm_monitor;
  `uvm_component_utils(o_monitor)
  virtual intf if_f;
  transaction tr;
  int mon_count=0;
  int data;
  int length;
  uvm_analysis_port#(bit [31:0])mon_ap_sb;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase (phase);
    mon_ap_sb=new("mon_ap_sb",this);
    if(!uvm_config_db#(virtual intf)::get(this,"","if_f",if_f))
    `uvm_fatal(get_type_name(),"vif is not set")
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      tr=transaction::type_id::create ("tr");
      wait(if_f.tl.tl_tb_valid && if_f.tl.tl_tb_ready);//read req dw0
      repeat(4)@(posedge if_f.clk);//dw1,dw2

      wait(if_f.tl.tl_tb_valid && if_f.tl.tl_tb_ready);//data_tlp
      if(if_f.tl.tl_tb[7:0] != 0 )begin
        length = if_f.tl.tl_tb[7:0];
        //`uvm_info("op mon",$sformatf("monitor %d",length), UVM_LOW);
        repeat(2)@(posedge if_f.clk);
          repeat(length)@(posedge if_f.clk)begin
          data =if_f.tl.tl_tb;
          //`uvm_info("op mon",$sformatf("monitor %d",data), UVM_LOW);
          mon_ap_sb.write(data);
        end
      end
      else begin
        repeat(2)@(posedge if_f.clk)begin
          wait(if_f.tl.tb_tl_valid && if_f.tl.tb_tl_ready);
        end
      end
    end
  endtask
endclass
