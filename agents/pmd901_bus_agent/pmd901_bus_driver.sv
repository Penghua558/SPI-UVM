class pmd901_bus_driver extends uvm_driver #(pmd901_bus_trans, pmd901_bus_trans);

`uvm_component_utils(pmd901_bus_driver)


protected virtual pmd901_bus_driver_bfm m_bfm;
//------------------------------------------
// Data Members
//------------------------------------------
pmd901_bus_agent_config m_cfg;

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "pmd901_bus_driver", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
endclass: pmd901_bus_driver 

function pmd901_bus_driver::new(string name = "pmd901_bus_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function pmd901_bus_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg = pmd901_bus_agent_config::get_config(this);
    m_bfm = m_cfg.drv_bfm;
endfunction: build_phase

task pmd901_bus_driver::run_phase(uvm_phase phase);
    pmd901_bus_trans req;

    m_bfm.reset();
    forever begin
        seq_item_port.get_next_item(req);
        m_bfm.drive(req);
        seq_item_port.item_done(); 
    end
endtask
