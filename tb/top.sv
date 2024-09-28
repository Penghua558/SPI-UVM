`include "agents/pmd901_agent/pmd901_agent_pkg.sv"
`include "agents/pmd901_bus_agent/pmd901_bus_agent_pkg.sv"
`include "tb/env_pkg.sv"
`include "tb/test.sv"
module top;

import env_pkg::*;
`include "timescale.v"

// PCLK and PRESETn
//
logic PCLK;
logic PRESETn;

//
// Instantiate the pin interfaces:
//
pmd901_if PMD901_IF();
pmd901_bus_if PMD901_BUS_IF(PCLK, PRESETn);

//
// Instantiate the BFM interfaces:
//

pmd901_timecheck timecheck(
    .clk(PMD901_IF.clk),
    .csn(PMD901_IF.csn)
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

pmd901_bus_driver_bfm PMD901_BUS_drv_bfm(
    .clk(PMD901_BUS_IF.clk),
    .rstn(PMD901_BUS_IF.rstn),
    .wdata(PMD901_BUS_IF.wdata),
    .we(PMD901_BUS_IF.we),
    .dev_enable(PMD901_BUS_IF.dev_enable),
    .dev_bending(PMD901_BUS_IF.dev_bending)
);

pmd901_bus_monitor_bfm PMD901_BUS_mon_bfm(
    .clk(PMD901_BUS_IF.clk),
    .rstn(PMD901_BUS_IF.rstn),
    .wdata(PMD901_BUS_IF.wdata),
    .we(PMD901_BUS_IF.we),
    .dev_enable(PMD901_BUS_IF.dev_enable),
    .dev_bending(PMD901_BUS_IF.dev_bending)
);
  
// DUT
spi_top#(
.SCLK_DIVIDER(8'd8),
.SPI_TRANSMIT_DELAY(12'd2001),
.CS_N_HOLD_COUNT(6'd3)
) DUT(
    .clk(PCLK),
    .rstn(PRESETn),
    .wdata(PMD901_BUS_IF.wdata),
    .we(PMD901_BUS_IF.we),
    .dev_enable(PMD901_BUS_IF.dev_enable),
    .dev_bending(PMD901_BUS_IF.dev_bending),
    .fault(PMD901_IF.fault),
    .fan(PMD901_IF.fan),
    .ready(PMD901_IF.ready),
    .park(PMD901_IF.park),
    .bending(PMD901_IF.bend),
    .sclk(PMD901_IF.clk),
    .cs_n(PMD901_IF.csn),
    .mosi(PMD901_IF.mosi)
);


// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin //tbx vif_binding_block
  import uvm_pkg::uvm_config_db;
  uvm_config_db #(virtual pmd901_monitor_bfm)::set(null, "uvm_test_top", 
      "PMD901_mon_bfm", PMD901_mon_bfm);
  uvm_config_db #(virtual pmd901_driver_bfm) ::set(null, "uvm_test_top", 
      "PMD901_drv_bfm", PMD901_drv_bfm);

  uvm_config_db #(virtual pmd901_bus_monitor_bfm)::set(null, "uvm_test_top", 
      "PMD901_BUS_mon_bfm", PMD901_BUS_mon_bfm);
  uvm_config_db #(virtual pmd901_bus_driver_bfm)::set(null, "uvm_test_top", 
      "PMD901_BUS_drv_bfm", PMD901_BUS_drv_bfm);
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
  PRESETn = 1;
  repeat(4) @(posedge PCLK);
  PRESETn = 0;
  repeat(4) @(posedge PCLK);
  PRESETn = 1;
end

initial begin
  $wlfdumpvars();
end

endmodule: top
