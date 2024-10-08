class reg2apb_adapter extends uvm_reg_adapter;

  // factory registration macro
  `uvm_object_utils(reg2apb_adapter)

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new (string name = "reg2apb_adapter" );
    super.new(name);

    // Does the protocol the Agent is modeling support byte enables?
    // 0 = NO
    // 1 = YES
    supports_byte_enable = 0;

    // Does the Agent's Driver provide separate response sequence items?
    // i.e. Does the driver call seq_item_port.put()
    // and do the sequences call get_response()?
    // 0 = NO
    // 1 = YES
    provides_responses = 0;

  endfunction: new

  //--------------------------------------------------------------------
  // reg2bus
  //--------------------------------------------------------------------
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    apb_seq_item trans_h = apb_seq_item::type_id::create("trans_h");

    trans_h.we = (rw.kind == UVM_READ) ? 1'b0 : 1'b1;
    trans_h.addr = rw.addr;
    trans_h.data = rw.data;
    trans_h.delay = 1;
    return trans_h;

  endfunction: reg2bus

  //--------------------------------------------------------------------
  // bus2reg
  //--------------------------------------------------------------------
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    apb_seq_item trans_h;
    if (!$cast(trans_h, bus_item)) begin
      `uvm_fatal("NOT_BUS_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = (trans_h.we == 1'b1) ? UVM_WRITE : UVM_READ;
    rw.addr = trans_h.addr;
    rw.data = trans_h.data;
    rw.status = UVM_IS_OK;

  endfunction: bus2reg

endclass: reg2apb_adapter
 
// Utility Sequences
//`include "apb_seq.svh"
//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
//
// Class Description:
//
//
class apb_seq extends uvm_sequence #(apb_seq_item);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_seq)

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
extern function new(string name = "apb_seq");
extern task body;

endclass:apb_seq

function apb_seq::new(string name = "apb_seq");
  super.new(name);
endfunction

task apb_seq::body;
  apb_seq_item req;

  begin
    req = apb_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  end

endtask:body
//`include "apb_read_seq.svh"
//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
//
// Class Description:
//
//
class apb_read_seq extends uvm_sequence #(apb_seq_item);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_read_seq)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
rand logic [31:0] addr;
logic [31:0] data;

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_read_seq");
extern task body;

endclass:apb_read_seq

function apb_read_seq::new(string name = "apb_read_seq");
  super.new(name);
endfunction

task apb_read_seq::body;
  apb_seq_item req = apb_seq_item::type_id::create("req");;

  begin
    start_item(req);
    req.we = 0;
    req.addr = addr;
    finish_item(req);
    data = req.data;
  end

endtask:body
//`include "apb_write_seq.svh"
//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
//
// Class Description:
//
//
class apb_write_seq extends uvm_sequence #(apb_seq_item);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_write_seq)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
rand logic [31:0] addr;
rand logic [31:0] data;

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_write_seq");
extern task body;

endclass:apb_write_seq

function apb_write_seq::new(string name = "apb_write_seq");
  super.new(name);
endfunction

task apb_write_seq::body;
  apb_seq_item req = apb_seq_item::type_id::create("req");;

  begin
    start_item(req);
    req.we = 1;
    req.addr = addr;
    req.data = data;
    finish_item(req);
  end

endtask:body
