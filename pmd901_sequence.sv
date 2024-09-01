class pmd901_sequence extends uvm_sequence #(pmd901_trans, pmd901_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(pmd901_sequence)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
bit [31:0] memory [int];

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "pmd901_sequence");
extern task body;

endclass:pmd901_sequence

function pmd901_sequence::new(string name = "pmd901_sequence");
  super.new(name);
endfunction

task pmd901_sequence::body;
  apb_slave_agent_config m_cfg = apb_slave_agent_config::get_config(m_sequencer);
  apb_slave_seq_item req;
  apb_slave_seq_item rsp;

  req = apb_slave_seq_item::type_id::create("req");
  rsp = apb_slave_seq_item::type_id::create("rsp");

  m_cfg.wait_for_reset();
  // Slave sequence finishes after 60 transfers:
  repeat(60) begin

    // Get request
    start_item(req);
    finish_item(req);

    // Prepare memory for response:
    if (req.rw) begin
      memory[req.addr] = req.wdata;
    end
    else begin
      if(!memory.exists(req.addr)) begin
        memory[req.addr] = 32'hdeadbeef;
      end
    end

    // Respond:
    start_item(rsp);
    rsp.copy(req);
    assert (rsp.randomize() with {if(!rsp.rw) rsp.rdata == memory[rsp.addr];});
    finish_item(rsp);
  end

endtask:body
