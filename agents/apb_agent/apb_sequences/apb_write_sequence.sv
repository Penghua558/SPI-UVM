class apb_write_sequence extends uvm_sequence #(apb_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_write_sequence)

import apb_agent_dec::*;

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
logic [15:0] addr;
logic [15:0] data;

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_write_sequence");
extern task body;
extern task write(bit [15:0] addr, bit [15:0] data, uvm_sequencer_base seqr, 
    uvm_sequencer_base parent = null);

endclass:apb_write_sequence

function apb_write_sequence::new(string name = "apb_write_sequence");
  super.new(name);
endfunction

task apb_write_sequence::body;
    apb_trans req = apb_trans::type_id::create("req");;

    begin
        start_item(req);
        assert(req.randomize() with {
            wr == WRITE;
            addr == local::addr;
            wdata == local::data;
        });
        finish_item(req);
    end
endtask:body

task write(bit [15:0] addr, bit [15:0] data, uvm_sequencer_base seqr, 
    uvm_sequencer_base parent = null);
    this.addr = addr;
    this.data = data;
    this.start(seqr, parent);
endtask
