class pmd901_bus_rand_speed_bending_sequence extends uvm_sequence #(
    pmd901_bus_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(pmd901_bus_rand_speed_bending_sequence)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
bit enable;

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "pmd901_bus_rand_speed_bending_sequence");
extern task body;
extern task rand_speed_bending(bit enable, uvm_sequencer_base seqr, 
    uvm_sequence_base parent = null);

endclass:pmd901_bus_rand_speed_bending_sequence

function pmd901_bus_rand_speed_bending_sequence::new(
    string name = "pmd901_bus_rand_speed_bending_sequence");
  super.new(name);
endfunction

task pmd901_bus_rand_speed_bending_sequence::body;
    pmd901_bus_agent_config m_cfg = pmd901_bus_agent_config::get_config(
        m_sequencer);
    pmd901_bus_trans req;

  req = pmd901_bus_trans::type_id::create("req");

  m_cfg.wait_for_reset();
  // Slave sequence finishes after 60 transfers:

  // Get request
  start_item(req);

  assert (req.randomize() with {
      req.we == 1'b1;
      req.enable == this.enable;
      }
  );

    finish_item(req);
endtask:body

task pmd901_bus_rand_speed_bending_sequence::rand_speed_bending(bit enable, 
    uvm_sequencer_base seqr, uvm_sequence_base parent = null);
    this.enable = enable;
    this.start(seqr, parent); 
endtask: rand_speed_bending 
