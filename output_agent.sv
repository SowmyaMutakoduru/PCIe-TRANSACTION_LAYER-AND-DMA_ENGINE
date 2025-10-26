class output_agent extends uvm_agent;
  `uvm_component_utils(output_agent)
  uvm_analysis_export#(bit [31:0]) to_sb;
  o_monitor mon;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    to_sb = new("to_sb", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon=o_monitor::type_id::create("o_mon", this) ;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase (phase);
    mon.mon_ap_sb.connect(to_sb);
  endfunction
  
endclass
