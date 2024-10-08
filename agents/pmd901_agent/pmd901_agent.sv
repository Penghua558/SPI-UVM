class pmd901_agent extends uvm_component;

`uvm_component_utils(pmd901_agent)

//------------------------------------------
// Data Members
//------------------------------------------
pmd901_agent_config m_cfg;

uvm_analysis_port #(pmd901_trans) ap;
pmd901_monitor m_monitor;
pmd901_driver m_driver;
pmd901_sequencer m_sequencer;
pmd901_recorder m_recorder;

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "pmd901_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: pmd901_agent 

function pmd901_agent::new(string name = "pmd901_agent", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void pmd901_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg = pmd901_agent_config::get_config(this);
    // Monitor is always present
    m_monitor = pmd901_monitor::type_id::create("m_monitor", this);
    m_recorder = pmd901_recorder::type_id::create("m_recorder", this);
    // Only build the driver and sequencer if active
    if(m_cfg.active == UVM_ACTIVE) begin
      m_driver = pmd901_driver::type_id::create("m_driver", this);
      m_sequencer = pmd901_sequencer::type_id::create("m_sequencer", this);
    end
endfunction: build_phase

function void pmd901_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  ap.connect(m_recorder.analysis_export);
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction: connect_phase
