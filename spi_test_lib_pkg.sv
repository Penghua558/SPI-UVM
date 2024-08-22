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
// Package Description:
//
package spi_test_lib_pkg;

  // Standard UVM import & include:
  import uvm_pkg::*;
`include "uvm_macros.svh"

  // Any further package imports:
  import spi_env_pkg::*;
  import apb_agent_pkg::*;
  import spi_agent_pkg::*;
  import spi_bus_sequence_lib_pkg::*;
  import spi_test_seq_lib_pkg::*;
  import spi_reg_pkg::*;
  import intr_pkg::*;

  // Includes:
//`include "spi_test_base.svh"
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
class spi_test_base extends uvm_test;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(spi_test_base)

  //------------------------------------------
  // Data Members
  //------------------------------------------

  //------------------------------------------
  // Component Members
  //------------------------------------------
  // The environment class
  spi_env m_env;
  // Configuration objects
  spi_env_config m_env_cfg;
  apb_agent_config m_apb_cfg;
  spi_agent_config m_spi_cfg;
  // Register map
  spi_reg_block spi_rb;
  //Interrupt Utility
  intr_util INTR;

  //------------------------------------------
  // Methods
  //------------------------------------------
  extern virtual function void configure_apb_agent(apb_agent_config cfg);
  // Standard UVM Methods:
  extern function new(string name = "spi_test_base", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
extern function void set_seqs(spi_vseq_base seq);

endclass: spi_test_base

function spi_test_base::new(string name = "spi_test_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void spi_test_base::build_phase(uvm_phase phase);
  virtual intr_bfm temp_intr_bfm;
  // env configuration
  m_env_cfg = spi_env_config::type_id::create("m_env_cfg");
  // Register model
  // Enable all types of coverage available in the register model
  uvm_reg::include_coverage("*", UVM_CVR_ALL);
  // Create the register model:
  spi_rb = spi_reg_block::type_id::create("spi_rb");
  // Build and configure the register model
  spi_rb.build();
  // Assign a handle to the register model in the env config
  m_env_cfg.spi_rb = spi_rb;
  // APB configuration
  m_apb_cfg = apb_agent_config::type_id::create("m_apb_cfg");
  configure_apb_agent(m_apb_cfg);
  if (!uvm_config_db #(virtual apb_monitor_bfm)::get(this, "", "APB_mon_bfm", m_apb_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual apb_driver_bfm) ::get(this, "", "APB_drv_bfm", m_apb_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_drv_bfm from uvm_config_db. Have you set() it?")
  m_env_cfg.m_apb_agent_cfg = m_apb_cfg;
  // The SPI is not configured as such
  m_spi_cfg = spi_agent_config::type_id::create("m_spi_cfg");
  if (!uvm_config_db #(virtual spi_monitor_bfm)::get(this, "", "SPI_mon_bfm", m_spi_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual spi_driver_bfm) ::get(this, "", "SPI_drv_bfm", m_spi_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_spi_cfg.has_functional_coverage = 0;
  m_env_cfg.m_spi_agent_cfg = m_spi_cfg;
  // Insert the interrupt virtual interface into the env_config:
  INTR = intr_util::type_id::create("INTR");
  if (!uvm_config_db #(virtual intr_bfm)::get(this, "", "INTR_bfm", temp_intr_bfm) )
    `uvm_fatal("VIF CONFIG", "Cannot get() interface INTR_bfm from uvm_config_db. Have you set() it?")
  INTR.set_bfm(temp_intr_bfm);
  m_env_cfg.INTR = INTR;
  
  uvm_config_db #(spi_env_config)::set(this, "*", "spi_env_config", m_env_cfg);
  m_env = spi_env::type_id::create("m_env", this);
endfunction: build_phase

//
// Convenience function to configure the apb agent
//
// This can be overloaded by extensions to this test base class
function void spi_test_base::configure_apb_agent(apb_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.has_functional_coverage = 0;
  cfg.has_scoreboard = 0;
  // SPI is on select line 0 for address range 0-18h
  cfg.no_select_lines = 1;
  cfg.start_address[0] = 32'h0;
  cfg.range[0] = 32'h18;
endfunction: configure_apb_agent

function void spi_test_base::set_seqs(spi_vseq_base seq);
  seq.m_cfg = m_env_cfg;

//  seq.apb = m_env.m_apb_agent.m_sequencer;
  seq.spi = m_env.m_spi_agent.m_sequencer;
endfunction
//`include "spi_reg_test.svh"
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
class spi_reg_test extends spi_test_base;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(spi_reg_test)

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "spi_reg_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

endclass: spi_reg_test

function spi_reg_test::new(string name = "spi_reg_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void spi_reg_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

task spi_reg_test::run_phase(uvm_phase phase);

  register_test_vseq t_seq =  register_test_vseq::type_id::create("t_seq");
  set_seqs(t_seq);

  phase.raise_objection(this, "Test Started");
  t_seq.start(null);
  #100;
  phase.drop_objection(this, "Test Finished");
endtask: run_phase

function void spi_reg_test::report_phase(uvm_phase phase);
      uvm_coreservice_t cs_;
      uvm_report_server svr;
      cs_ = uvm_coreservice_t::get();
      svr = cs_.get_report_server();
      
      if ((svr.get_severity_count(UVM_ERROR) == 0) & (svr.get_id_count("uvm_reg_hw_reset_seq") == 7))
         `uvm_info("** UVM TEST PASSED **", "No reset errors detected", UVM_LOW)
      else
         `uvm_error("!! UVM TEST FAILED !!", "Register reset errors detected")

endfunction
//`include "spi_interrupt_test.svh"
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
class spi_interrupt_test extends spi_test_base;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(spi_interrupt_test)

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "spi_interrupt_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: spi_interrupt_test

function spi_interrupt_test::new(string name = "spi_interrupt_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void spi_interrupt_test::build_phase(uvm_phase phase);
  uvm_reg::include_coverage("*", UVM_CVR_ADDR_MAP, this);
  super.build_phase(phase);
endfunction: build_phase

task spi_interrupt_test::run_phase(uvm_phase phase);

  config_interrupt_test t_seq = config_interrupt_test::type_id::create("t_seq");
  set_seqs(t_seq);

  phase.raise_objection(this, "Test Started");
  t_seq.start(null);
  #100;
  phase.drop_objection(this, "Test Finished");

endtask: run_phase
//`include "spi_poll_test.svh"
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
class spi_poll_test extends spi_test_base;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(spi_poll_test)

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "spi_poll_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: spi_poll_test

function spi_poll_test::new(string name = "spi_poll_test", uvm_component parent = null);
  super.new(name, parent);
  $display("LuanTran here  new phase test");
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void spi_poll_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

task spi_poll_test::run_phase(uvm_phase phase);

  config_polling_test t_seq = config_polling_test::type_id::create("t_seq");
  set_seqs(t_seq);
  phase.raise_objection(this, "Test Started");
  t_seq.start(null);
  #1000ns;
  phase.drop_objection(this, "Test Finished");
endtask: run_phase
endpackage: spi_test_lib_pkg