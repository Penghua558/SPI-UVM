class pmd901_bus_speed_sequence extends uvm_sequence #(pmd901_bus_trans, pmd901_bus_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(pmd901_bus_speed_sequence)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
bit bending;
bit enable;
bit signed [15:0] speed;

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "pmd901_bus_speed_sequence");
extern task body;
extern task set_speed(bit signed [15:0] speed, bit enable, bit bending, uvm_sequencer_base seqr, uvm_sequence_base parent = null);

endclass:pmd901_bus_speed_sequence

function pmd901_bus_speed_sequence::new(string name = "pmd901_bus_speed_sequence");
  super.new(name);
endfunction

task pmd901_bus_speed_sequence::body;
    pmd901_bus_agent_config m_cfg = pmd901_bus_agent_config::get_config(m_sequencer);
    pmd901_bus_trans req;

  req = pmd901_bus_trans::type_id::create("req");

  m_cfg.wait_for_reset();
  // Slave sequence finishes after 60 transfers:

  // Get request
  start_item(req);

  assert (req.randomize() with {
      req.speed == this.speed;
      req.we == 1'b1;
      req.enable == this.enable;
      req.bending == this.bending;
      }
  );

    finish_item(req);
endtask:body

task pmd901_bus_speed_sequence::set_speed(bit signed [15:0] speed, bit enable, bit bending, uvm_sequencer_base seqr, uvm_sequence_base parent = null);
    this.speed = speed;
    this.enable = enable;
    this.bending = bending;
    this.start(seqr, parent); 
endtask: set_speed 
