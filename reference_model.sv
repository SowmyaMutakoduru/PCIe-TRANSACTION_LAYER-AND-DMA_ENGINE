class reference extends uvm_subscriber#(transaction);
  `uvm_component_utils(reference)
  uvm_analysis_imp#(transaction, reference) ref_ap;
  uvm_analysis_port#(bit [31:0]) ref_sb;
  transaction exp_tr;
  bit [31:0] trans[$];

  reg [31:0]mem[7:0];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ref_ap = new("ref_ap", this);
    ref_sb = new("ref_sb", this);
    for(int i=0;i<8;i++)begin
    mem[i]=i+1;
  end

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase (phase);
  endfunction

  function void write(transaction t);
    exp_tr=extract_from_mem(t);
  //`uvm_info("REFERENCE", $sformatf("ref packet: %p",exp_tr), UVM_LOW);
  endfunction
  
  extern function transaction extract_from_mem(transaction t);
    
endclass

function transaction reference::extract_from_mem(transaction t);
  int addr, length;
  addr = t.tlp_descriptor_payload[0];
  length = t.tlp_descriptor_payload[2];
  //`uvm_info("REFERENCE",$sformatf("ref packet: %d %d",addr, length), UVM_LOW);
  for(int i=0;i<length; i++)begin
    ref_sb.write(mem[addr+i]);
    //$display("ref_data %d",mem[addr+i]);
  end

endfunction
