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

 `include "config_macro.svh"
 `include "apb_if.sv"
 `include "agents/pmd901_slave_agent/pmd901_if.sv"
 `include "agents/pmd901_slave_agent/pmd901_agent_pkg.sv"
 `include "spi_if.sv"
 `include "apb_agent_pkg.sv"
 `include "apb_driver_bfm.sv"
 `include "apb_monitor_bfm.sv"
 `include "spi_agent_pkg.sv"
 `include "spi_driver_bfm.sv"
 `include "spi_monitor_bfm.sv"
 `include "spi_reg_pkg.sv"
 `include "intr_if.sv"
 `include "intr_pkg.sv"
 `include "intr_bfm.sv"
 `include "spi_env_pkg.sv"
 `include "spi_bus_sequence_lib_pkg.sv"
 `include "spi_test_seq_lib_pkg.sv"
 `include "spi_test_lib_pkg.sv"
module top;
  // pragma attribute hdl_top partition_module_xrtl

`include "timescale.v"

// PCLK and PRESETn
//
logic PCLK;
logic PRESETn;

//
// Instantiate the pin interfaces:
//
apb_if APB(PCLK, PRESETn);   // APB interface
spi_if SPI();  // SPI Interface
intr_if INTR();   // Interrupt
pmd901_if PMD901_IF();

//
// Instantiate the BFM interfaces:
//
apb_monitor_bfm APB_mon_bfm(
   .PCLK    (APB.PCLK),
   .PRESETn (APB.PRESETn),
   .PADDR   (APB.PADDR),
   .PRDATA  (APB.PRDATA),
   .PWDATA  (APB.PWDATA),
   .PSEL    (APB.PSEL),
   .PENABLE (APB.PENABLE),
   .PWRITE  (APB.PWRITE),
   .PREADY  (APB.PREADY)
);
apb_driver_bfm APB_drv_bfm(
   .PCLK    (APB.PCLK),
   .PRESETn (APB.PRESETn),
   .PADDR   (APB.PADDR),
   .PRDATA  (APB.PRDATA),
   .PWDATA  (APB.PWDATA),
   .PSEL    (APB.PSEL),
   .PENABLE (APB.PENABLE),
   .PWRITE  (APB.PWRITE),
   .PREADY  (APB.PREADY)
);

pmd901_driver_bfm PMD901_drv_bfm(
    .clk(PMD901_IF.clk),
    .csn(PMD901_IF.csn),
    .bend(PMD901_IF.bend),
    .park(PMD901_IF.park),
    .mosi(PMD901_IF.mosi),
    .fault(PMD901_IF.fault),
    .fan(PMD901_IF.fan),
    .ready(PMD901_IF.ready)
);

pmd901_monitor_bfm PMD901_mon_bfm(
    .clk(PMD901_IF.clk),
    .csn(PMD901_IF.csn),
    .bend(PMD901_IF.bend),
    .park(PMD901_IF.park),
    .mosi(PMD901_IF.mosi),
    .fault(PMD901_IF.fault),
    .fan(PMD901_IF.fan),
    .ready(PMD901_IF.ready)
);

intr_bfm INTR_bfm(
   .IRQ  (INTR.IRQ),
   .IREQ (INTR.IREQ)
);

  
// DUT
spi_top#(
.SCLK_DIVIDER(8'd8),
.SPI_TRANSMIT_DELAY(12'd2001),
.CS_N_HOLD_COUNT(6'd3)
) DUT(
);


// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin //tbx vif_binding_block
  import uvm_pkg::uvm_config_db;
  uvm_config_db #(virtual apb_monitor_bfm)::set(null, "uvm_test_top", "APB_mon_bfm", APB_mon_bfm);
  uvm_config_db #(virtual apb_driver_bfm) ::set(null, "uvm_test_top", "APB_drv_bfm", APB_drv_bfm);
  uvm_config_db #(virtual spi_monitor_bfm)::set(null, "uvm_test_top", "SPI_mon_bfm", SPI_mon_bfm);
  uvm_config_db #(virtual spi_driver_bfm) ::set(null, "uvm_test_top", "SPI_drv_bfm", SPI_drv_bfm);
  uvm_config_db #(virtual intr_bfm)       ::set(null, "uvm_test_top", "INTR_bfm", INTR_bfm);
  run_test();
end

//
// Clock and reset initial block:
//
initial begin
  PCLK = 0;
  forever #10ns PCLK = ~PCLK;
end
initial begin 
  PRESETn = 0;
  repeat(4) @(posedge PCLK);
  PRESETn = 1;
end

initial begin
          $dumpfile("dump.vcd");
          $dumpvars;
          #1000us
          $finish;
end 

endmodule: top
