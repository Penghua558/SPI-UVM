class pmd901_sequencer extends uvm_sequencer#(pmd901_trans, pmd901_trans);
`uvm_component_utils(pmd901_trans)

// Standard UVM Methods:
extern function new(string name="pmd901_sequencer", uvm_component parent = null);
endclass: pmd901_sequencer

function apb_slave_sequencer::new(string name="apb_slave_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction
