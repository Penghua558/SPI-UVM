interface pmd901_monitor_bfm (
  input logic clk,
  input logic csn,
  input logic bend,
  input logic park,

  input logic mosi,
  input logic fault,
  input logic fan,
  input logic ready
);

clocking mon_cb@(posedge clk);
   input mosi; 
endclocking: mon_cb 

`include "uvm_macros.svh"
import uvm_pkg::*;
import pmd901_agent_pkg::*;
import pmd901_agent_dec::*;

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

//------------------------------------------
// Assertions 
//------------------------------------------
property csnhold;
 realtime current_time;
  ($fell(csn),current_time=$realtime) |=>
 first_match(##[1:$]($fell(clk) or $rose(clk))) ##0 (($realtime - current_time) >= 0.4us);
endproperty

endinterface: pmd901_monitor_bfm
