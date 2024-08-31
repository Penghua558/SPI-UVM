interface pmd901_driver_bfm (
  input logic clk,
  input logic csn,
  input logic bend,
  input logic park,
  input logic mosi,

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
endtask: wait_inputs_isknown

function automatic work_status_e get_work_status();
    case({park, bend})
        2'b0?: return pmd901_agent_dec::POWER_DOWN;
        2'b10: return pmd901_agent_dec::NORMAL_WORKING;
        2'b11: return pmd901_agent_dec::BENDING_WORKING;
        default: return pmd901_agent_dec::POWER_DOWN;
    endcase
endfunction

task setup_on_power_change(ref pmd901_trans req);
// we are intrested the moment working PMD901 
// is powered down or powered up
    @(park);
    req.speed = 16'd0;
endtask

task setup_on_bending_change(ref pmd901_trans req);
// make transaction when pin bending changes outside 
// SPI transmit
    @(bending iff csn);
    req.speed = 16'd0;
endtask

task setup_on_spi_transmit(ref pmd901_trans req);
    // if device is not powered up, then we wait
    // for it, since there's no intrest to transmit 
    // a powered down PMD901 transaction
    wait(park == 1'b1);
    // wait for csn pulled down to initiate a 
    // SPI transmit
    @(negedge csn);

    fork
        begin
            @(posedge csn);
        end
        forever begin: sample_data
            @drv_cb;
            req.speed << 1;
            req.speed[0] = drv_cb.mosi;
        end
    join_any
    disable fork;
endtask

task setup_phase(ref pm901_trans req);
    fork
        begin
        setup_on_power_change(req);
        end
        begin
        setup_on_bending_change(req);
        end
        begin
        setup_on_spi_transmit(req);
        end
    join_any
    disable fork;

    req.work_status = get_work_status();
endtask: setup_phase 

task access_phase(pmd901_trans rsp);
    fan = rsp.close2overheat;
    ready = rsp.overheat;
    fault = rsp.spi_violated;
endtask: access_phase
  
endinterface: pmd901_driver_bfm
