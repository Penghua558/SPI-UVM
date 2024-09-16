import pmd901_agent_dec::*;
class pmd901_sequence extends uvm_sequence #(pmd901_trans, pmd901_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(pmd901_sequence)


//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
bit signed [15:0] working_speed;

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "pmd901_sequence");
extern task body;
extern task read_n_drive(uvm_sequencer_base seqr, uvm_sequence_base parent = null);

endclass:pmd901_sequence

function pmd901_sequence::new(string name = "pmd901_sequence");
  super.new(name);
  working_speed = 16'd0;
endfunction

task pmd901_sequence::body;
    pmd901_agent_config m_cfg;
    pmd901_trans req;
    pmd901_trans rsp;

    m_cfg = pmd901_agent_config::get_config(m_sequencer);
    req = pmd901_trans::type_id::create("req");
    rsp = pmd901_trans::type_id::create("rsp");

    m_cfg.wait_inputs_isknown();
    // Slave sequence finishes after 60 transfers:
    // Get request
    start_item(req);
    finish_item(req);

    if (req.work_status != POWER_DOWN) begin
        working_speed = req.speed;
    end

    // Respond:
    start_item(rsp);
    rsp.copy(req);
    assert (rsp.randomize() with {
        if(m_cfg.disable_spi_violation) rsp.spi_violated == 1'b0;
        if(m_cfg.disable_close2overheat) rsp.close2overheat == 1'b0;
        if(m_cfg.disable_overheat) rsp.overheat == 1'b0;
        }
    );
    finish_item(rsp);
endtask:body

task pmd901_sequence::read_n_drive(uvm_sequencer_base seqr, uvm_sequence_base parent = null);
    this.start(seqr, parent); 
endtask: read_n_drive
