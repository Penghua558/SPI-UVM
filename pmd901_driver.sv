class pmd901_driver extends uvm_driver #(pmd901_trans, pmd901_trans);

`uvm_component_utils(pmd901_trans)

import pmd901_agent_pkg::*;
import pmd901_agent_dec::*;

protected virtual pmd901_driver_bfm m_bfm;
//------------------------------------------
// Data Members
//------------------------------------------
pmd901_agent_config m_cfg;

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "pmd901_driver", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: pmd901_driver 

function pmd901_driver::new(string name = "pmd901_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction
