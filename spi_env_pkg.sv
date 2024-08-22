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
package spi_env_pkg;

  // Standard UVM import & include:
  import uvm_pkg::*;
`include "uvm_macros.svh"

  // Any further package imports:
  import apb_agent_pkg::*;
  import spi_agent_pkg::*;
  import spi_reg_pkg::*;
  import intr_pkg::*;

  // Includes:
//`include "spi_env_config.svh"
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
class spi_env_config extends uvm_object;

  localparam string s_my_config_id = "spi_env_config";
  localparam string s_no_config_id = "no config";
  localparam string s_my_config_type_error_id = "config type error";

  // UVM Factory Registration Macro
  //
  `uvm_object_utils(spi_env_config)

  // Interrupt Utility - used in the wait for interrupt task
  //
  intr_util INTR;

  //------------------------------------------
  // Data Members
  //------------------------------------------
  // Whether env analysis components are used:
  bit has_functional_coverage = 0;
  bit has_spi_functional_coverage = 1;
  bit has_reg_scoreboard = 0;
  bit has_spi_scoreboard = 1;

  // Configurations for the sub_components
  apb_agent_config m_apb_agent_cfg;
  spi_agent_config m_spi_agent_cfg;

  // SPI Register block
  spi_reg_block spi_rb;

  //------------------------------------------
  // Methods
  //------------------------------------------
  extern static function spi_env_config get_config( uvm_component c);
    extern task wait_for_interrupt;
  extern function bit is_interrupt_cleared;
  // Standard UVM Methods:
  extern function new(string name = "spi_env_config");

endclass: spi_env_config

function spi_env_config::new(string name = "spi_env_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function spi_env_config spi_env_config::get_config( uvm_component c );
  spi_env_config t;

  if (!uvm_config_db #(spi_env_config)::get(c, "", s_my_config_id, t) )
    `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction

// This task is a convenience method for sequences waiting for the interrupt
// signal
task spi_env_config::wait_for_interrupt;
  INTR.wait_for_interrupt();
endtask: wait_for_interrupt

// Check that interrupt has cleared:
function bit spi_env_config::is_interrupt_cleared;
  return INTR.is_interrupt_cleared();
endfunction: is_interrupt_cleared
//`include "spi_scoreboard.svh"
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

class spi_scoreboard extends uvm_component;

  `uvm_component_utils(spi_scoreboard)

  uvm_tlm_analysis_fifo #(spi_seq_item) spi; // Both mosi & miso come in together

  // Register Model Handle - assigned by the env code from the contents
  // of its configuration object
  spi_reg_block spi_rb;

  // Data buffers:
  logic[31:0] mosi[3:0];
  logic[31:0] miso[3:0];
  logic[127:0] mosi_regs = 0;
  // Bit count:
  logic[7:0] bit_cnt;
  //
  // Statistics:
  //
  int no_transfers;
  int no_tx_errors;
  int no_rx_errors;
  int no_cs_errors;

    bit error;
    logic[31:0] rx_data;
    logic[127:0] miso_data;
    uvm_reg_data_t spi_read_data;
    spi_seq_item item;
    bit rx_neg;
    bit lsb;
                    
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    spi = new("miso", this);
  endfunction: build_phase

  // What this scoreboard does:
  //
  // It relies on the fact that the register model is kept updated by the
  // predictor in the test bench and that there are no accesses to the
  // rxtx registers during the SPI data transfer
  //
  //
  // When it receives a SPI transaction it compares the current version of
  // the rxtx register models - i.e. the tx data - against the SPI MOSI data observed
  // It then processes the rx data, according to the configured format, and reads the
  // SPI DUT rx data register to make sure it matches before
  // updating the rxtx register models with the expected values for the
  // SPI MISO data. An sequence is expected to read back from these registers using
  // the mirror() method in order to detect any data errors.
  //

  task run_phase(uvm_phase phase);
    no_transfers = 0;
    no_tx_errors = 0;
    no_rx_errors = 0;
    no_cs_errors = 0;

    track_spi;

  endtask: run_phase

  task track_spi;
//    spi_seq_item item;

    logic[127:0] tx_data;
    logic[127:0] mosi_data;
//    logic[127:0] miso_data;
    logic[127:0] rev_miso;
    logic[127:0] bit_mask;
//    logic[31:0] rx_data;
//    uvm_reg_data_t spi_read_data;
    uvm_status_e status;

//    bit error;

    forever begin
      error = 0;
      spi.get(item);
      no_transfers++;
      bit_cnt = spi_rb.ctrl.char_len.get_mirrored_value();
      // Corner case for bit count equal to zero:
      if(bit_cnt == 8'b0) begin
        bit_cnt = 128;
      end
      // Deal with the mosi data (TX)
      tx_data[31:0] = spi_rb.rxtx0.get_mirrored_value();
      tx_data[63:32] = spi_rb.rxtx1.get_mirrored_value();
      tx_data[95:64] = spi_rb.rxtx2.get_mirrored_value();
      tx_data[127:96] = spi_rb.rxtx3.get_mirrored_value();

      // Fix the data comparison mask for the number of bits
      bit_mask = 0;
      for(int i = 0; i < bit_cnt; i++) begin
        bit_mask[i] = 1;
      end

      if(spi_rb.ctrl.tx_neg.get_mirrored_value() == 1) begin
        mosi_data = item.nedge_mosi; // To be compared against write data
      end
      else begin
        mosi_data = item.pedge_mosi;
      end
      if(spi_rb.ctrl.lsb.get_mirrored_value() == 1) begin
        for(int i = 0; i < bit_cnt; i++) begin
          if(tx_data[i] != mosi_data[i]) begin
            error = 1;
          end
        end
        if(error == 1) begin
          `uvm_error("SPI_SB_MOSI_LSB:", $sformatf("Expected mosi value %0h actual %0h", tx_data, mosi_data))
        end
      end
      else begin
        for(int i = 0; i < bit_cnt; i++) begin
          if(tx_data[i] != mosi_data[(bit_cnt-1) - i]) begin
            error = 1;
          end
        end
        if(error == 1) begin // Need to reverse the mosi_data bits
          rev_miso = 0;
          for(int i = 0; i < bit_cnt; i++) begin
            rev_miso[(bit_cnt-1) - i] = mosi_data[i];
          end
          `uvm_error("SPI_SB_MOSI_MSB:", $sformatf("Expected mosi value %0h actual %0h", tx_data, rev_miso))
        end
      end
      if(error == 1) begin
        no_tx_errors++;
      end

      // Reset the error bit
      error = 0;
      // Check the miso data (RX)
      if(spi_rb.ctrl.rx_neg.get_mirrored_value() == 1) begin
        rx_neg = 1;
        miso_data = item.pedge_miso;
      end
      else begin
        rx_neg = 0;
        miso_data = item.nedge_miso;
      end
      if(spi_rb.ctrl.lsb.get_mirrored_value() == 0) begin
        // reverse the bits lsb -> msb, and so on
        lsb = 0;
        rev_miso = 0;
        for(int i = 0; i < bit_cnt; i++) begin
          rev_miso[(bit_cnt-1) - i] = miso_data[i];
        end
        miso_data = rev_miso;
      end
      else begin
        lsb = 1;
      end

      // The following sets up the rx data so that it is
      // bit masked according to the no of bits
      rx_data = spi_rb.rxtx0.get_mirrored_value();
      // Read the received data
      spi_rb.rxtx0.read(status, spi_read_data);
      for(int i = 0; ((i < 32) && (i < bit_cnt)); i++) begin
        rx_data[i] = miso_data[i];
        if(spi_read_data[i] != miso_data[i]) begin
          error = 1;
          $display("bit_cnt %0d", bit_cnt);
          `uvm_error("SPI_SB_RXD_0:", $sformatf("Bit%0d Expected RX data value %0h actual %0h", i, spi_read_data[31:0], miso_data))
        end
      end
      // Get the register model to check that the data it next reads back from this
      // register is as predicted
      // This is somewhat redundant given the earlier read check, but it does check the
      // read back path
      assert(spi_rb.rxtx0.predict(rx_data));

      rx_data = spi_rb.rxtx1.get_mirrored_value();
      spi_rb.rxtx1.read(status, spi_read_data);
      for(int i = 32; ((i < 64) && (i < bit_cnt)); i++) begin
        rx_data[i-32] = miso_data[i];
        if(spi_read_data[i-32] != miso_data[i]) begin
          error = 1;
          `uvm_error("SPI_SB_RXD_1:", $sformatf("Bit%0d Expected RX data value %0h actual %0h", i, spi_read_data[31:0], miso_data))
        end
      end
      assert(spi_rb.rxtx1.predict(rx_data));

      rx_data = spi_rb.rxtx2.get_mirrored_value();
      spi_rb.rxtx2.read(status, spi_read_data);
      for(int i = 64; ((i < 96) && (i < bit_cnt)); i++) begin
        rx_data[i-64] = miso_data[i];
        if(spi_read_data[i-64] != miso_data[i]) begin
          error = 1;
          `uvm_error("SPI_SB_RXD_2:", $sformatf("Bit%0d Expected RX data value %0h actual %0h", i, spi_read_data[31:0], miso_data))
        end
      end

      assert(spi_rb.rxtx2.predict(rx_data));

      rx_data = spi_rb.rxtx3.get_mirrored_value();
      spi_rb.rxtx3.read(status, spi_read_data);
      for(int i = 96; ((i < 128) && (i < bit_cnt)); i++) begin
        rx_data[i-96] = miso_data[i];
        if(spi_read_data[i-96] != miso_data[i]) begin
          error = 1;
          `uvm_error("SPI_SB_RXD_3:", $sformatf("Bit %0d Expected RX data value %0h actual %0h", i, spi_read_data[31:0], miso_data))
        end
      end
      assert(spi_rb.rxtx3.predict(rx_data));

      if(error == 1) begin
        no_rx_errors++;
      end

      // Check the chip select lines
      //spi_rb.ss.cs.read(status, spi_read_data);
      //if(spi_rb.ss.cs.get_mirrored_value() != {56'h0, ~item.cs}) begin
      //  `uvm_error("SPI_SB_CS:", $sformatf("Expected cs value %b actual %b", spi_rb.ss.cs.get_mirrored_value(), ~item.cs))
      //  no_cs_errors++;
      //end
    end

  endtask: track_spi

  function void report_phase(uvm_phase phase);

    if(no_transfers == 0) begin
      `uvm_info("SPI_SB_REPORT:", "No SPI transfers took place", UVM_LOW)
    end
    if((no_cs_errors == 0) && (no_tx_errors == 0) && (no_rx_errors == 0) && (no_transfers > 0)) begin
      `uvm_info("SPI_SB_REPORT:", $sformatf("Test Passed - %0d transfers occured with no errors", no_transfers), UVM_LOW)
      `uvm_info("** UVM TEST PASSED **", $sformatf("Test Passed - %0d transfers occured with no errors", no_transfers), UVM_LOW)
    end
    if(no_tx_errors > 0) begin
      `uvm_error("SPI_SB_REPORT:", $sformatf("Test Failed - %0d TX errors occured during %0d transfers", no_tx_errors, no_transfers))
    end
    if(no_rx_errors > 0) begin
      `uvm_error("SPI_SB_REPORT:", $sformatf("Test Failed - %0d RX errors occured during %0d transfers", no_rx_errors, no_transfers))
    end
    if(no_cs_errors > 0) begin
      `uvm_error("SPI_SB_REPORT:", $sformatf("Test Failed - %0d CS errors occured during %0d transfers", no_cs_errors, no_transfers))
    end

  endfunction: report_phase

endclass: spi_scoreboard
//`include "spi_env.svh"
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
class spi_env extends uvm_env;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(spi_env)
  //------------------------------------------
  // Data Members
  //------------------------------------------
  apb_agent m_apb_agent;
  spi_agent m_spi_agent;
  spi_env_config m_cfg;
  spi_scoreboard m_scoreboard;

  // Register layer adapter
  reg2apb_adapter m_reg2apb;
  // Register predictor
  uvm_reg_predictor#(apb_seq_item) m_apb2reg_predictor;

  //------------------------------------------
  // Constraints
  //------------------------------------------

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "spi_env", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass:spi_env

function spi_env::new(string name = "spi_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void spi_env::build_phase(uvm_phase phase);
  if (!uvm_config_db #(spi_env_config)::get(this, "", "spi_env_config", m_cfg))
    `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration spi_env_config from uvm_config_db. Have you set() it?")

  uvm_config_db #(apb_agent_config)::set(this, "m_apb_agent*",
                                         "apb_agent_config",
                                         m_cfg.m_apb_agent_cfg);
  m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);

  // Build the register model predictor
  m_apb2reg_predictor = uvm_reg_predictor#(apb_seq_item)::type_id::create("m_apb2reg_predictor", this);
  m_reg2apb = reg2apb_adapter::type_id::create("m_reg2apb");

  uvm_config_db #(spi_agent_config)::set(this, "m_spi_agent*",
                                         "spi_agent_config",
                                         m_cfg.m_spi_agent_cfg);
  m_spi_agent = spi_agent::type_id::create("m_spi_agent", this);

  if(m_cfg.has_spi_scoreboard) begin
    m_scoreboard = spi_scoreboard::type_id::create("m_scoreboard", this);
  end
endfunction:build_phase

function void spi_env::connect_phase(uvm_phase phase);

  // Only set up register sequencer layering if the spi_rb is the top block
  // If it isn't, then the top level environment will set up the correct sequencer
  // and predictor
  if(m_cfg.spi_rb.get_parent() == null) begin
    if(m_cfg.m_apb_agent_cfg.active == UVM_ACTIVE) begin
      m_cfg.spi_rb.spi_reg_block_map.set_sequencer(m_apb_agent.m_sequencer, m_reg2apb);
    end

    //
    // Register prediction part:
    //
    // Replacing implicit register model prediction with explicit prediction
    // based on APB bus activity observed by the APB agent monitor
    // Set the predictor map:
    m_apb2reg_predictor.map = m_cfg.spi_rb.spi_reg_block_map;
    // Set the predictor adapter:
    m_apb2reg_predictor.adapter = m_reg2apb;
    // Disable the register models auto-prediction
    m_cfg.spi_rb.spi_reg_block_map.set_auto_predict(0);
    // Connect the predictor to the bus agent monitor analysis port
    m_apb_agent.ap.connect(m_apb2reg_predictor.bus_in);
  end

  if(m_cfg.has_spi_scoreboard) begin
    m_spi_agent.ap.connect(m_scoreboard.spi.analysis_export);
    m_scoreboard.spi_rb = m_cfg.spi_rb;
  end

endfunction: connect_phase
endpackage: spi_env_pkg
