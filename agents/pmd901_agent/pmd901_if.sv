interface pmd901_if;
  logic clk;
  logic csn;
  logic mosi;
  logic bend;
  logic fault;
  logic fan;
  logic ready;
  logic park;

`include "uvm_macros.svh"
import uvm_pkg::*;

//------------------------------------------
// Assertions 
//------------------------------------------
event spi_clk_event;
bit seq_start;
initial begin
forever begin
    fork
        begin
            @(negedge csn);
            seq_start = 1'b1;
        end
        begin
            @(posedge csn);
            seq_start = 1'b0;
        end
        begin
            @(posedge clk);
            seq_start = 1'b0;
        end
    join_any
    disable fork;
    -> spi_clk_event;
end
end

property clocknumber;
    @(spi_clk_event) seq_start |=> !csn[*16] ##1 !$rose(clk);
endproperty

property readyfan;
    @(ready, fan) !(ready & fan);
endproperty


assert property (clocknumber)
else
    `uvm_fatal("PMD901 MONITOR BFM", "Clock cycle number is not 16 during data transmission!")

assert property (readyfan)
else
    `uvm_fatal("PMD901 MONITOR BFM", "Ready and fan should not be asserted at the same time")

endinterface: pmd901_if
