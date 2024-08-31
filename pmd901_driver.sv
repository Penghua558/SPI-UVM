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

function pmd901_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg = pmd901_agent_config::get_config(this);
    m_bfm = m_cfg.drv_bfm;
endfunction: build_phase

task pmd901_driver::run_phase(uvm_phase phase);
    pmd901_trans req;
    pmd901_trans rsp;

    m_bfm.wait_inputs_isknown();
    forever begin
        seq_item_port.get_next_item(req);
        m_bfm.setup_phase(req);
        seq_item_port.item_done(); 

        seq_item_port.get_next_item(rsp);
        m_bfm.access_phase(req, rsp);
        seq_item_port.item_done();
    end
endtask
