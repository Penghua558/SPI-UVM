class pmd901_bus_agent extends uvm_component;

`uvm_component_utils(pmd901_bus_agent)

//------------------------------------------
// Data Members
//------------------------------------------
pmd901_bus_agent_config m_cfg;

uvm_analysis_port #(pmd901_bus_trans) ap;
pmd901_bus_monitor m_monitor;
pmd901_bus_driver m_driver;
pmd901_bus_sequencer m_sequencer;

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "pmd901_bus_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: pmd901_bus_agent 

function pmd901_bus_agent::new(string name = "pmd901_bus_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pmd901_bus_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg = pmd901_bus_agent_config::get_config(this);
    // Monitor is always present
    m_monitor = pmd901_bus_monitor::type_id::create("m_monitor", this);
    // Only build the driver and sequencer if active
    if(m_cfg.active == UVM_ACTIVE) begin
      m_driver = pmd901_bus_driver::type_id::create("m_driver", this);
      m_sequencer = pmd901_bus_sequencer::type_id::create("m_sequencer", this);
    end
endfunction: build_phase

function void pmd901_bus_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction: connect_phase
