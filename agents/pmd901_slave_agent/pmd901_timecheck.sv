module pmd901_timecheck(
    input wire clk,
    input wire csn
);

`include "uvm_macros.svh"
import uvm_pkg::*;

reg csn_hold_notifier = 1'b0;
reg spi_start_notifier = 1'b0;

specify
    $hold(negedge csn, clk, 400ns, csn_hold_notifier);
    $hold(posedge csn, negedge csn, 20us, spi_start_notifier);
endspecify

always@(*) begin
    if (csn_hold_notifier)
        `uvm_fatal("PMD901 TIMECHECK", "Hold sclk at least 400ns after SPI transmission starts")
    if (spi_start_notifier)
        `uvm_fatal("PMD901 TIMECHECK", "wait at least 20us between 2 SPI transmissions")
end

endmodule
