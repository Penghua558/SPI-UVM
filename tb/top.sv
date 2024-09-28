module top;

import uvm_pkg::*;
import env_pkg::*;

// PCLK and PRESETn
//
logic PCLK;
logic PRESETn;

//
// Instantiate the pin interfaces:
//
pmd901_if u_pmd901_if();
pmd901_bus_if u_pmd901_bus_if(PCLK, PRESETn);

//
// Instantiate the BFM interfaces:
//

pmd901_timecheck u_timecheck(
    .clk(u_pmd901_if.clk),
    .csn(u_pmd901_if.csn)
);

pmd901_driver_bfm u_pmd901_drv_bfm(
    .clk(u_pmd901_if.clk),
    .csn(u_pmd901_if.csn),
    .bend(u_pmd901_if.bend),
    .park(u_pmd901_if.park),
    .mosi(u_pmd901_if.mosi),
    .fault(u_pmd901_if.fault),
    .fan(u_pmd901_if.fan),
    .ready(u_pmd901_if.ready)
);

pmd901_monitor_bfm u_pmd901_mon_bfm(
    .clk(u_pmd901_if.clk),
    .csn(u_pmd901_if.csn),
    .bend(u_pmd901_if.bend),
    .park(u_pmd901_if.park),
    .mosi(u_pmd901_if.mosi),
    .fault(u_pmd901_if.fault),
    .fan(u_pmd901_if.fan),
    .ready(u_pmd901_if.ready)
);

pmd901_bus_driver_bfm u_pmd901_BUS_drv_bfm(
    .i_clk(u_pmd901_bus_if.i_clk),
    .i_rstn(u_pmd901_bus_if.i_rstn),
    .wdata(u_pmd901_bus_if.wdata),
    .we(u_pmd901_bus_if.we),
    .dev_enable(u_pmd901_bus_if.dev_enable),
    .dev_bending(u_pmd901_bus_if.dev_bending)
);

pmd901_bus_monitor_bfm u_pmd901_BUS_mon_bfm(
    .i_clk(u_pmd901_bus_if.i_clk),
    .i_rstn(u_pmd901_bus_if.i_rstn),
    .wdata(u_pmd901_bus_if.wdata),
    .we(u_pmd901_bus_if.we),
    .dev_enable(u_pmd901_bus_if.dev_enable),
    .dev_bending(u_pmd901_bus_if.dev_bending)
);
  
// DUT
spi_top#(
.SCLK_DIVIDER(8'd8),
.SPI_TRANSMIT_DELAY(12'd2001),
.CS_N_HOLD_COUNT(6'd3)
) DUT(
    .clk(PCLK),
    .rstn(PRESETn),
    .wdata(u_pmd901_bus_if.wdata),
    .we(u_pmd901_bus_if.we),
    .dev_enable(u_pmd901_bus_if.dev_enable),
    .dev_bending(u_pmd901_bus_if.dev_bending),
    .fault(u_pmd901_if.fault),
    .fan(u_pmd901_if.fan),
    .ready(u_pmd901_if.ready),
    .park(u_pmd901_if.park),
    .bending(u_pmd901_if.bend),
    .sclk(u_pmd901_if.clk),
    .cs_n(u_pmd901_if.csn),
    .mosi(u_pmd901_if.mosi)
);


// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin
  import uvm_pkg::uvm_config_db;
  uvm_config_db#(virtual pmd901_monitor_bfm)::set(null, "uvm_test_top",
      "PMD901_mon_bfm", u_pmd901_mon_bfm);
  uvm_config_db#(virtual pmd901_driver_bfm)::set(null, "uvm_test_top",
      "PMD901_drv_bfm", u_pmd901_drv_bfm);

  uvm_config_db #(virtual pmd901_bus_monitor_bfm)::set(null, "uvm_test_top",
      "PMD901_BUS_mon_bfm", u_pmd901_BUS_mon_bfm);
  uvm_config_db #(virtual pmd901_bus_driver_bfm)::set(null, "uvm_test_top",
      "PMD901_BUS_drv_bfm", u_pmd901_BUS_drv_bfm);
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
