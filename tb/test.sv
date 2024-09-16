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
// After setting dev_enable to 1, we randomize wdata and dev_bending 60 times.
//
import env_pkg::*;
import pmd901_bus_agent_pkg::*;
import pmd901_agent_pkg::*;
class test extends uvm_test;

// UVM Factory Registration Macro
//
`uvm_component_utils(test)

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Component Members
//------------------------------------------
// The environment class
env m_env;
// Configuration objects
env_config m_env_cfg;

bit test_enable;
bit test_bending;

//------------------------------------------
// Methods
//------------------------------------------
extern function void configure_pmd901_agent(pmd901_agent_config cfg);
extern function void configure_pmd901_bus_agent(pmd901_bus_agent_config cfg);
// Standard UVM Methods:
extern function new(string name = "test", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task  main_phase(uvm_phase phase);

endclass: test

function test::new(string name = "test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void test::build_phase(uvm_phase phase);
  // env configuration
  m_env_cfg = env_config::type_id::create("m_env_cfg");

  configure_pmd901_agent(m_env_cfg.m_pmd901_agent_cfg);
  configure_pmd901_bus_agent(m_env_cfg.m_pmd901_bus_agent_cfg);

  if (!uvm_config_db #(virtual pmd901_driver_bfm)::get(this, "", 
      "PMD901_drv_bfm", m_env_cfg.m_pmd901_agent_cfg.drv_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual pmd901_driver_bfm)::get(...) failed");
  if (!uvm_config_db #(virtual pmd901_monitor_bfm)::get(this, "", 
      "PMD901_drv_bfm", m_env_cfg.m_pmd901_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual pmd901_monitor_bfm)::get(...) failed");

  if (!uvm_config_db #(virtual pmd901_bus_driver_bfm)::get(this, "", 
      "PMD901_BUS_drv_bfm", m_env_cfg.m_pmd901_bus_agent_cfg.drv_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual pmd901_driver_bfm)::get(...) failed");
  if (!uvm_config_db #(virtual pmd901_bus_monitor_bfm)::get(this, "", 
      "PMD901_BUS_drv_bfm", m_env_cfg.m_pmd901_bus_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual pmd901_monitor_bfm)::get(...) failed");

  m_env = env::type_id::create("m_env", this);

  uvm_config_db #(uvm_object)::set(this, "m_env*", "env_config", m_env_cfg);
  uvm_config_db #(uvm_object)::set(this, "m_env*", 
      "pmd901_agent_config", m_env_cfg.m_pmd901_agent_cfg);
  uvm_config_db #(uvm_object)::set(this, "m_env*", 
      "pmd901_bus_agent_config", m_env_cfg.m_pmd901_bus_agent_cfg);
endfunction: build_phase


// This can be overloaded by extensions to this base class
function void test::configure_pmd901_agent(pmd901_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.disable_spi_violation = 1'b0;
  cfg.disable_close2overheat = 1'b0;
  cfg.disable_overheat = 1'b0;
endfunction: configure_pmd901_agent

function void test::configure_pmd901_bus_agent(pmd901_bus_agent_config cfg);
  cfg.active = UVM_ACTIVE;
endfunction: configure_pmd901_bus_agent

task test::main_phase(uvm_phase phase);
    pmd901_sequence pmd901_seq = pmd901_sequence::type_id::create("pmd901_seq");

    pmd901_bus_enable_sequence pmd901_enable_seq = 
        pmd901_bus_enable_sequence::type_id::create("pmd901_enable_seq");
    pmd901_bus_rand_speed_bending_sequence pmd901_speed_seq = 
        pmd901_bus_rand_speed_bending_sequence::type_id::create("pmd901_speed_seq");

    phase.raise_objection(this);
    fork
        pmd901_seq.read_n_drive(m_env.m_pmd901_agent.m_sequencer);
        begin
        // enable PMD901 first
            test_enable = 1'b1;
            pmd901_enable_seq.set_enable(test_enable, m_env.m_pmd901_bus_agent.m_sequencer);
            repeat(60) begin
                pmd901_speed_seq.rand_speed_bending(test_enable, m_env.m_pmd901_bus_agent.m_sequencer);
            end
            `uvm_info("TEST", "Finished generating speed stimulus", UVM_MEDIUM)
        end
    join_any
    phase.drop_objection(this);
endtask
