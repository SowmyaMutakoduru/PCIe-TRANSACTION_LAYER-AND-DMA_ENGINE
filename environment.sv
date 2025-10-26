class environment extends uvm_env;
  `uvm_component_utils(environment)
  agent agnt;
  output_agent o_agnt;
  scoreboard sb;
  reference rm;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt=agent::type_id::create("agnt", this);
    o_agnt=output_agent::type_id::create ("o_agnt", this);
    sb=scoreboard::type_id::create ("sb", this);
    rm=reference::type_id::create ("rm", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase (phase);
    o_agnt.to_sb.connect(sb.from_mon);
    agnt.to_rm.connect(rm.ref_ap);
    rm.ref_sb.connect(sb.from_rm);
  endfunction

endclass
