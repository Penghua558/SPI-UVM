import pmd901_agent_pkg::*;
class pmd901_monitor extends uvm_component;

`uvm_component_utils(pmd901_monitor)


protected virtual pmd901_monitor_bfm m_bfm;
//------------------------------------------
// Data Members
//------------------------------------------
pmd901_agent_config m_cfg;


//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(pmd901_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "pmd901_monitor", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void pmd901_monitor::notify_transaction(pmd901_trans item);
endclass: pmd901_monitor 

function pmd901_monitor::new(string name = "pmd901_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function pmd901_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg = pmd901_agent_config::get_config(this);
    m_bfm = m_cfg.mon_bfm;
    m_bfm.proxy = this;

    ap = new("ap", this);
endfunction: build_phase

task pmd901_monitor::run_phase(uvm_phase phase);
    m_bfm.run();
endtask

function void pmd901_monitor::notify_transaction(pmd901_trans item);
  ap.write(item);
endfunction: notify_transaction
