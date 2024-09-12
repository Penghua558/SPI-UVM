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


task setup_on_power_change(pmd901_trans req);
// we are intrested the moment working PMD901 
// is powered down or powered up
    @(park);
    req.speed = 16'd0;
endtask

task setup_on_bending_change(pmd901_trans req);
// make transaction when pin bending changes outside 
// SPI transmit
    @(bending iff csn);
    req.speed = 16'd0;
endtask

task setup_on_spi_transmit(pmd901_trans req);
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

task drive(pmd901_bus_trans req);
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

task access_phase(pmd901_trans req, pmd901_trans rsp);
    fan <= rsp.close2overheat;
    ready <= rsp.overheat;
    fault <= rsp.spi_violated;
endtask: access_phase
  
endinterface: pmd901_bus_driver_bfm
