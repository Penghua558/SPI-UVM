interface pmd901_bus_monitor_bfm (
    input logic i_clk, 
    input logic i_rstn,
    input logic [15:0] wdata,
    input logic we,
    input logic dev_enable,
    input logic dev_bending
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import pmd901_bus_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
pmd901_bus_monitor proxy;

//------------------------------------------
// Methods
//------------------------------------------
task wait_for_reset();
    wait(i_rstn);
endtask: wait_for_reset 

task run();
    pmd901_bus_trans item;
    pmd901_bus_trans cloned_item;
    item = pmd901_bus_trans::type_id::create("item");

    forever begin
        @(posedge i_clk);
        item.speed = wdata;
        item.we = we;
        item.enable = dev_enable;
        item.bending = dev_bending;

        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask

endinterface: pmd901_bus_monitor_bfm
