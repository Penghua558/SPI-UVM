class pmd901_bus_enable_sequence extends uvm_sequence #(pmd901_bus_trans, pmd901_bus_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(pmd901_bus_enable_sequence)

import pmd901_bus_agent_dec::*;

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "pmd901_bus_enable_sequence");
extern task body;
extern task enable(uvm_sequencer_base seqr, uvm_sequence_base parent = null);

endclass:pmd901_bus_enable_sequence

function pmd901_bus_enable_sequence::new(string name = "pmd901_bus_enable_sequence");
  super.new(name);
endfunction

task pmd901_bus_enable_sequence::body;
    super.body;
    pmd901_bus_agent_config m_cfg = pmd901_bus_agent_config::get_config(m_sequencer);
    pmd901_bus_trans req;

  req = pmd901_bus_trans::type_id::create("req");

  m_cfg.wait_for_reset();
  // Slave sequence finishes after 60 transfers:
  repeat(repeat_num) begin

    // Get request
    start_item(req);

    assert (req.randomize() with {
        req.we = 1'b0;
        req.enable = 1'b1;
        req.bending = 1'b0;
        }
    );

    finish_item(req);
  end
endtask:body

task enable(uvm_sequencer_base seqr, uvm_sequence_base parent = null);
    this.start(seqr, parent); 
endtask: enable
