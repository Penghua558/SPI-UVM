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
package apb_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "config_macro.svh"
//`include "apb_seq_item.svh"
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
// Questa recording macro:

//`define uvm_record_field(NAME,VALUE) \
//   $add_attribute(recorder.get_handle(),VALUE,NAME);

//
// Class Description:
//
//
class apb_seq_item extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_seq_item)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
rand logic[31:0] addr;
rand logic[31:0] data;
rand logic we;
rand int delay;

bit error;

//------------------------------------------
// Constraints
//------------------------------------------
constraint addr_alignment {
  addr[1:0] == 0;
}

constraint delay_bounds {
  delay inside {[1:20]};
}

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_seq_item");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function string convert2string();
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:apb_seq_item

function apb_seq_item::new(string name = "apb_seq_item");
  super.new(name);
endfunction

function void apb_seq_item::do_copy(uvm_object rhs);
  apb_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  addr = rhs_.addr;
  data = rhs_.data;
  we = rhs_.we;
  delay = rhs_.delay;

endfunction:do_copy

function bit apb_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  apb_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         addr == rhs_.addr &&
         data == rhs_.data &&
         we   == rhs_.data;
  // Delay is not relevant to the comparison
endfunction:do_compare

function string apb_seq_item::convert2string();
  string s;

  $sformat(s, "%s\n", super.convert2string());
  // Convert to string function reusing s:
  $sformat(s, "%s\n addr\t%0h\n data\t%0h\n we\t%0b\n delay\t%0d\n", s, addr, data, we, delay);
  return s;

endfunction:convert2string

function void apb_seq_item::do_print(uvm_printer printer);
  printer.m_string = convert2string();
endfunction:do_print

function void apb_seq_item:: do_record(uvm_recorder recorder);
  super.do_record(recorder);

  // Use the record macros to record the item fields:
  `uvm_record_field("addr", addr)
  `uvm_record_field("data", data)
  `uvm_record_field("we", we)
  `uvm_record_field("delay", delay)
endfunction:do_record
//`include "apb_agent_config.svh"
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
class apb_agent_config extends uvm_object;

localparam string s_my_config_id = "apb_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_agent_config)

// BFM Virtual Interfaces
virtual apb_monitor_bfm mon_bfm;
virtual apb_driver_bfm  drv_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_ACTIVE;
// Include the APB functional coverage monitor
bit has_functional_coverage = 0;
// Include the APB RAM based scoreboard
bit has_scoreboard = 0;
//
// Address decode for the select lines:
int no_select_lines = 1;
int apb_index = 0; // Which PSEL is the monitor connected to
logic[31:0] start_address[15:0];
logic[31:0] range[15:0];

//------------------------------------------
// Methods
//------------------------------------------
extern static function apb_agent_config get_config( uvm_component c );
// Standard UVM Methods:
extern function new(string name = "apb_agent_config");

endclass: apb_agent_config

function apb_agent_config::new(string name = "apb_agent_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function apb_agent_config apb_agent_config::get_config( uvm_component c );
  apb_agent_config t;

  if (!uvm_config_db #(apb_agent_config)::get(c, "", s_my_config_id, t) )
     `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction
//`include "apb_driver.svh"
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
class apb_driver extends uvm_driver #(apb_seq_item, apb_seq_item);

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_driver)

// Virtual Interface
virtual apb_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
apb_agent_config m_cfg;
  
//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "apb_driver", uvm_component parent = null);
extern task run_phase(uvm_phase phase);
extern function void build_phase(uvm_phase phase);

endclass: apb_driver

function apb_driver::new(string name = "apb_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `get_config(apb_agent_config, m_cfg, "apb_agent_config")
  m_bfm = m_cfg.drv_bfm;
endfunction: build_phase

task apb_driver::run_phase(uvm_phase phase);
  apb_seq_item req;
  apb_seq_item rsp;
  int psel_index;
  
  m_bfm.m_cfg = m_cfg;
  forever
   begin
     m_bfm.clear_sigs();
     seq_item_port.get_next_item(req);
     m_bfm.drive(req);
     seq_item_port.item_done();
   end

endtask: run_phase
//`include "apb_coverage_monitor.svh"
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
// Functional coverage monitor for the APB agent
//
// Collects basic coverage information
//
class apb_coverage_monitor extends uvm_subscriber #(apb_seq_item);

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_coverage_monitor);


//------------------------------------------
// Cover Group(s)
//------------------------------------------
covergroup apb_cov;
OPCODE: coverpoint analysis_txn.we {
  bins write = {1};
  bins read = {0};
}
// To do:
// Monitor is not returning delay info
endgroup

//------------------------------------------
// Component Members
//------------------------------------------
apb_seq_item analysis_txn;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "apb_coverage_monitor", uvm_component parent = null);
extern function void write(T t);
extern function void report_phase(uvm_phase phase);

endclass: apb_coverage_monitor

function apb_coverage_monitor::new(string name = "apb_coverage_monitor", uvm_component parent = null);
  super.new(name, parent);
  apb_cov = new();
endfunction

function void apb_coverage_monitor::write(T t);
  analysis_txn = t;
  apb_cov.sample();
endfunction:write

function void apb_coverage_monitor::report_phase(uvm_phase phase);
// Might be a good place to do some reporting on no of analysis transactions sent etc

endfunction: report_phase
//`include "apb_monitor.svh"
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
class apb_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_monitor);

// Virtual Interface
virtual apb_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
apb_agent_config m_cfg;
  
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(apb_seq_item) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "apb_monitor", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
  
extern function void notify_transaction(apb_seq_item item);
  
// Helper Methods:

extern function void set_apb_index(int index = 0);
  
endclass: apb_monitor

function apb_monitor::new(string name = "apb_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_monitor::build_phase(uvm_phase phase);
  `get_config(apb_agent_config, m_cfg, "apb_agent_config")
  m_bfm = m_cfg.mon_bfm;
  m_bfm.proxy = this;
  set_apb_index(m_cfg.apb_index);
  
  ap = new("ap", this);
endfunction: build_phase

task apb_monitor::run_phase(uvm_phase phase);
  m_bfm.run();
endtask: run_phase

function void apb_monitor::report_phase(uvm_phase phase);
// Might be a good place to do some reporting on no of analysis transactions sent etc

endfunction: report_phase

function void apb_monitor::notify_transaction(apb_seq_item item);
  ap.write(item);
endfunction : notify_transaction

function void apb_monitor::set_apb_index(int index = 0);
  m_bfm.apb_index = index;
endfunction : set_apb_index
typedef uvm_sequencer#(apb_seq_item) apb_sequencer;
//`include "apb_agent.svh"
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
class apb_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_agent)

//------------------------------------------
// Data Members
//------------------------------------------
apb_agent_config m_cfg;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(apb_seq_item) ap;
apb_monitor   m_monitor;
apb_sequencer m_sequencer;
apb_driver    m_driver;
apb_coverage_monitor m_fcov_monitor;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: apb_agent


function apb_agent::new(string name = "apb_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_agent::build_phase(uvm_phase phase);
  `get_config(apb_agent_config, m_cfg, "apb_agent_config")
  // Monitor is always present
  m_monitor = apb_monitor::type_id::create("m_monitor", this);
  m_monitor.m_cfg = m_cfg;
  // Only build the driver and sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver = apb_driver::type_id::create("m_driver", this);
    m_driver.m_cfg = m_cfg;
    m_sequencer = apb_sequencer::type_id::create("m_sequencer", this);
  end
  if(m_cfg.has_functional_coverage) begin
    m_fcov_monitor = apb_coverage_monitor::type_id::create("m_fcov_monitor", this);
  end
endfunction: build_phase

function void apb_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
  if(m_cfg.has_functional_coverage) begin
    m_monitor.ap.connect(m_fcov_monitor.analysis_export);
  end

endfunction: connect_phase
//Reg Adapter for UVM Register Model
//`include "reg2apb_adapter.svh"
 //
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//   Copyright 2010-2018 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
//
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// reg2apb_adapter
//----------------------------------------------------------------------
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
endpackage: apb_agent_pkg
