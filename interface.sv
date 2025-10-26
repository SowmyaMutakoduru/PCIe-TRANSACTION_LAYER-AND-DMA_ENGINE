interface intf(input bit clk, rst);
// tb to tl
  logic [31:0] tb_tl;
  logic tb_tl_valid;
  logic tb_tl_ready;

  //tl to dma
  logic tl_dma_tready;
  logic tl_dma_tvalid;
  logic tl_dma_tlast;
  logic [95:0] tl_dma_tuser;
  logic [127:0] tl_dma_tdata;

  //dma to tl
  logic dma_tl_tready;
  logic dma_tl_tvalid;
  logic dma_tl_tlast;
  logic [95:0] dma_tl_tuser;
  logic [31:0] dma_tl_tdata;

  //tl to tb
  logic [31:0] tl_tb;
  logic tl_tb_valid;
  logic tl_tb_ready;

  modport tl( output tb_tl, tb_tl_valid, tl_dma_tready, dma_tl_tvalid, dma_tl_tlast, dma_tl_tuser, dma_tl_tdata, tl_tb_ready ,input tb_tl_ready, tl_dma_tvalid, tl_dma_tlast, tl_dma_tuser, tl_dma_tdata, dma_tl_tready, tl_tb,tl_tb_valid);

  property p1;
    @(posedge clk) disable iff(rst)
    (tb_tl_valid) |-> ##[1:3] tb_tl_ready;
  endproperty

  assert property(p1) begin
   // `uvm_info("ASSERTION1", $sformatf("P1 PASSED"), UVM_LOW)
  end
  else begin
    `uvm_error("A1 FAILED", UVM_LOW)
  end
    
  property p2;
    @(posedge clk) disable iff(rst)
    (tl_tb_valid) |-> ##[0:3] tl_tb_ready;
  endproperty

  assert property (p2)begin
    //`uvm_info("ASSERTION2", $sformatf("P2 PASSED"), UVM_LOW)
  end
  else begin
    `uvm_error("A2 FAILED", UVM_LOW)
  end

endinterface
