interface pmd901_bus_driver_bfm (
    input logic i_clk,
    input logic i_rstn,
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

task reset();
    while (!i_rstn) begin
        wdata <= 16'd0;
        we <= 1'b0;
        dev_enable <= 1'b0;
        dev_bending <= 1'b0;
        @(posedge i_clk);
    end
endtask: reset 

task drive(pmd901_bus_trans req);
    `uvm_info("DRIVER", "printing req content", UVM_MEDIUM)
    req.print();
    @(posedge i_clk);
    wdata <= req.speed;
    we <= req.we;
    dev_enable <= req.enable;
    dev_bending <= req.bending;
endtask: drive 

endinterface: pmd901_bus_driver_bfm
