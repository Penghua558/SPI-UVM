class pmd901_bus_sequencer extends uvm_sequencer#(pmd901_bus_trans, pmd901_bus_trans);
`uvm_component_utils(pmd901_bus_sequencer)

// Standard UVM Methods:
extern function new(string name="pmd901_bus_sequencer", uvm_component parent = null);
endclass: pmd901_bus_sequencer

function pmd901_bus_sequencer::new(string name="pmd901_bus_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction
