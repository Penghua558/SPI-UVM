interface pmd901_bus_driver_bfm (
    input logic rstn,
    output logic [15:0] wdata,
    output logic we,
    output logic dev_enable,
    output logic dev_bending
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import pmd901_bus_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

task wait_for_reset();
    @(negedge rstn);
    wdata <= 16'd0;
    we <= 1'b0;
    dev_enable <= 1'b0;
    dev_bending <= 1'b0;
endtask: wait_for_reset 

task drive(pmd901_bus_trans req);
    wdata <= req.speed;
    we <= req.we;
    dev_enable <= req.enable;
    dev_bending <= req.dev_bending;
endtask: drive 

endinterface: pmd901_bus_driver_bfm
