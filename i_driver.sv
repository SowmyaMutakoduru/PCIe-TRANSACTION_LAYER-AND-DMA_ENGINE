class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
  virtual intf if_f;
  transaction tlps ;
  int drv_count=0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf)::get(this,"","if_f",if_f))
    `uvm_fatal(get_type_name(),"vif is not set")
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    repeat(1)begin
    drive();
    end
  endtask

  task drive();

    seq_item_port.get_next_item(tlps);
    wait(if_f.tl.tb_tl_ready && !if_f.rst);
    //$display ("after handshake");
    @(posedge if_f.clk);
    if_f.tl.tb_tl_valid = 1;
    if_f.tl.tb_tl = tlps. tlp_doorbell_header[0];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps. tlp_doorbell_header[1];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps. tlp_doorbell_header[2];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps.tlp_doorbell_payload;
    @(posedge if_f.clk);
    if_f.tl.tb_tl_valid = 0;

    if_f.tl.tl_tb_ready = 1;
    wait(if_f.tl.tl_tb_valid && if_f.tl.tl_tb_ready);
    repeat(4)@(posedge if_f.clk);

      @(posedge if_f.clk)
    if_f.tl.tb_tl_valid = 1;
    if_f.tl.tb_tl = tlps.tlp_descriptor_header[0];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps.tlp_descriptor_header[1];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps.tlp_descriptor_header[2];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps.tlp_descriptor_payload[0];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps.tlp_descriptor_payload[1];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps.tlp_descriptor_payload[2];
    @(posedge if_f.clk);
    if_f.tl.tb_tl = tlps.tlp_descriptor_payload[3];
    @(posedge if_f.clk);
    if_f.tl.tb_tl_valid = 0;

    wait(if_f.tl.tl_tb_valid && if_f.tl.tl_tb_ready);
    drv_count++;
    seq_item_port.item_done();

  endtask

endclass
