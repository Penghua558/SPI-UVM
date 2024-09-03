package pmd901_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "pmd901_trans.sv"
`include "pmd901_agent_config.sv"

`include "pmd901_driver.sv"
`include "pmd901_sequencer.sv"
`include "pmd901_sequence.sv"

`include "pmd901_agent.sv"



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
