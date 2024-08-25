interface pmd901_driver_bfm (
  input logic clk,
  input logic csn,
  input logic bend,
  input logic park,

  output logic mosi,
  output logic fault,
  output logic fan,
  output logic ready
);

clocking drv_cb@(posedge clk);
   input mosi; 
endclocking: drv_cb 

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

task wait_inputs_isknown();
  while(csn === 1'hx || park === 1'hx || bend === 1'hx) begin
    #1;
  end
endtask : wait_inputs_isknown

task setup_phase(pmd901_trans req);
endtask: setup_phase

function automatic work_status_e get_work_status();
    case({park, bend})
        2'b0?: return pmd901_agent_dec::POWER_DOWN;
        2'b10: return pmd901_agent_dec::NORMAL_WORKING;
        2'b11: return pmd901_agent_dec::BENDING_WORKING;
        default: return pmd901_agent_dec::POWER_DOWN;
    endcase
endfunction

task setup_phase(ref pm901_trans req);
    // if device is not powered up, then we wait
    // for it, since there's no intrest to transmit 
    // a powered down PMD901 transaction
    wait(park == 1'b1);
    // wait for csn pulled down to initiate a 
    // SPI transmit
    @(negedge csn);
    req.work_status = get_work_status();
endtask : setup_phase 
  
endinterface: pmd901_driver_bfm
