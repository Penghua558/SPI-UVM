package pmd901_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "pmd901_trans.sv"


//`include "spi_seq_item.svh"
//`include "spi_agent_config.svh"
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
class spi_agent_config extends uvm_object;

localparam string s_my_config_id = "spi_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(spi_agent_config)

// BFM Virtual Interfaces
virtual spi_monitor_bfm mon_bfm;
virtual spi_driver_bfm  drv_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_ACTIVE;
bit has_functional_coverage = 0;

//------------------------------------------
// Methods
//------------------------------------------
extern static function spi_agent_config get_config( uvm_component c);
// Standard UVM Methods:
extern function new(string name = "spi_agent_config");

endclass: spi_agent_config

function spi_agent_config::new(string name = "spi_agent_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function spi_agent_config spi_agent_config::get_config( uvm_component c );
  spi_agent_config t;

  if (!uvm_config_db #(spi_agent_config)::get(c, "", s_my_config_id, t) )
     `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction
//`include "spi_driver.svh"
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
class spi_driver extends uvm_driver #(spi_seq_item, spi_seq_item);

// UVM Factory Registration Macro
//
`uvm_component_utils(spi_driver)

// Virtual Interface
local virtual spi_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
spi_agent_config m_cfg;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "spi_driver", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: spi_driver

function spi_driver::new(string name = "spi_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void spi_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `get_config(spi_agent_config, m_cfg, "spi_agent_config")
  m_bfm = m_cfg.drv_bfm;
endfunction : build_phase
  
// This driver is really an SPI slave responder
task spi_driver::run_phase(uvm_phase phase);
  spi_seq_item req;
  spi_seq_item rsp;

  m_bfm.wait_cs_isknown();

  forever begin
    seq_item_port.get_next_item(req);
    m_bfm.drive(req);
    seq_item_port.item_done();
  end
endtask 
//`include "spi_monitor.svh"
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
class spi_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(spi_monitor);

// Virtual Interface
local virtual spi_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
spi_agent_config m_cfg;

//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(spi_seq_item) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "spi_monitor", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
  
extern function void notify_transaction(spi_seq_item item);

endclass: spi_monitor

function spi_monitor::new(string name = "spi_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void spi_monitor::build_phase(uvm_phase phase);
  `get_config(spi_agent_config, m_cfg, "spi_agent_config")
  m_bfm = m_cfg.mon_bfm;
  m_bfm.proxy = this;
  
  ap = new("ap", this);
endfunction: build_phase

task spi_monitor::run_phase(uvm_phase phase);
  m_bfm.run();
endtask: run_phase

function void spi_monitor::report_phase(uvm_phase phase);
// Might be a good place to do some reporting on no of analysis transactions sent etc

endfunction: report_phase

function void spi_monitor::notify_transaction(spi_seq_item item);
  ap.write(item);
endfunction : notify_transaction
typedef uvm_sequencer#(spi_seq_item) spi_sequencer;
//`include "spi_agent.svh"
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
class spi_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(spi_agent)

//------------------------------------------
// Data Members
//------------------------------------------
spi_agent_config m_cfg;
  
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(spi_seq_item) ap;
spi_monitor   m_monitor;
spi_sequencer m_sequencer;
spi_driver    m_driver;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "spi_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: spi_agent


function spi_agent::new(string name = "spi_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void spi_agent::build_phase(uvm_phase phase);
  `get_config(spi_agent_config, m_cfg, "spi_agent_config")
  // Monitor is always present
  m_monitor = spi_monitor::type_id::create("m_monitor", this);
  m_monitor.m_cfg = m_cfg;
  // Only build the driver and sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver = spi_driver::type_id::create("m_driver", this);
    m_driver.m_cfg = m_cfg;
    m_sequencer = spi_sequencer::type_id::create("m_sequencer", this);
  end
endfunction: build_phase

function void spi_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction: connect_phase
// Utility Sequences
//`include "spi_seq.svh"
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
class spi_seq extends uvm_sequence #(spi_seq_item);

// UVM Factory Registration Macro
//
`uvm_object_utils(spi_seq)

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
extern function new(string name = "spi_seq");
extern task body;

endclass:spi_seq

function spi_seq::new(string name = "spi_seq");
  super.new(name);
endfunction

task spi_seq::body;
  spi_seq_item req;

  begin
    req = spi_seq_item::type_id::create("req");
    start_item(req);
    if(!req.randomize()) begin
      `uvm_error("body", "req randomization failure")
    end
    finish_item(req);
  end

endtask:body

class spi_rand_seq extends uvm_sequence #(spi_seq_item);

  `uvm_object_utils(spi_rand_seq)

  function new(string name = "spi_rand_seq");
    super.new(name);
  endfunction

  rand int unsigned BITS;
  rand logic rx_edge;

  task body;
    spi_seq_item req = spi_seq_item::type_id::create("req");

    start_item(req);
    if (!req.randomize() with {req.no_bits == BITS; req.RX_NEG == rx_edge;}) begin
      `uvm_error("body", "req randomization failure")
    end
    finish_item(req);

  endtask:body
endclass: spi_rand_seq
endpackage: spi_agent_pkg
