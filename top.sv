`include "uvm_macros.svh"
import uvm_pkg::*;

`include "dma.v"
`include "tl_dma.v"
`include "interface.sv"
`include "tlp.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "i_driver.sv"
`include "i_monitor.sv"
`include "o_monitor.sv"
`include "i_agent.sv"
`include "output_agent.sv"
`include "reference_model.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "basetest.sv"

module top;

  bit clk, rst;
  intf if_f(clk, rst);

  wire w_tl_dma_tvalid;
  wire w_tl_dma_tready;
  wire [95:0]w_tl_dma_tuser;
  wire [127:0]w_tl_dma_tdata;
  wire w_tl_dma_tlast;

  wire w_dma_tl_tvalid;
  wire w_dma_tl_tready;
  wire [95:0] w_dma_tl_tuser;
  wire [31:0] w_dma_tl_tdata;
  wire w_dma_tl_tlast;

  tl_dma dut1(.clk(clk), .rst(rst), .tb_tl(if_f.tb_tl), .tb_tl_valid(if_f.tb_tl_valid), .tb_tl_ready(if_f.tb_tl_ready), . tl_dma_tready(w_tl_dma_tready), .tl_dma_tvalid(w_tl_dma_tvalid), .tl_dma_tuser(w_tl_dma_tuser), . tl_dma_tlast(w_tl_dma_tlast), .tl_dma_tdata(w_tl_dma_tdata), .dma_tl_tready(w_dma_tl_tready), .dma_tl_tvalid(w_dma_tl_tvalid), .dma_tl_tlast(w_dma_tl_tlast), .dma_tl_tuser(w_dma_tl_tuser), .dma_tl_tdata(w_dma_tl_tdata), .tl_tb(if_f.tl_tb), .tl_tb_valid(if_f.tl_tb_valid), .tl_tb_ready(if_f.tl_tb_ready));

  dma dut2(.clk(clk), .rst(rst), .tl_dma_tready(w_tl_dma_tready), .tl_dma_tvalid(w_tl_dma_tvalid), .tl_dma_tlast(w_tl_dma_tlast), .tl_dma_tuser(w_tl_dma_tuser), .tl_dma_tdata(w_tl_dma_tdata), .dma_tl_tready(w_dma_tl_tready), .dma_tl_tvalid(w_dma_tl_tvalid), .dma_tl_tlast(w_dma_tl_tlast), .dma_tl_tuser(w_dma_tl_tuser), .dma_tl_tdata(w_dma_tl_tdata));

  property p3;
    @(posedge clk) disable iff(rst)
    (w_tl_dma_tvalid) |-> ##[0:3] w_tl_dma_tready;
  endproperty

  assert property(p3) begin
    //`uvm_info("ASSERTION3", $sformatf("P3 PASSED"), UVM_LOW)
  end
  else begin
  	`uvm_error("A3 FAILED", UVM_LOW)
  end

  property p4;
    @(posedge clk) disable iff(rst)
    (w_dma_tl_tvalid) |-> ##[0:3] w_dma_tl_tready;
  endproperty

  assert property(p4)begin
   // `uvm_info("ASSERTION4", $sformatf("P4 PASSED"), UVM_LOW)
  end
  else begin
    `uvm_error("A4 FAILED", UVM_LOW)
  end

  always #5 clk = ~clk;

  initial begin
    uvm_config_db#(virtual intf)::set(uvm_root::get(),"*","if_f",if_f);
    clk=0;
    rst=1;
    #20; 
    rst = 0;
    #500;
    $finish();
  end

  initial begin
    run_test("basetest");
  end
  
endmodule
