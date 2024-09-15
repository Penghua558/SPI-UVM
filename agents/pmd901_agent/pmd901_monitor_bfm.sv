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

import pmd901_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
pmd901_monitor proxy;

//------------------------------------------
// Methods
//------------------------------------------
task wait_inputs_isknown();
  while(csn === 1'hx || park === 1'hx || bend === 1'hx) begin
    #1;
  end
endtask: wait_inputs_isknown

task sample_on_power_change();
// we are intrested the moment working PMD901 
// is powered down or powered up
    @(park);
    item.speed = 16'd0;
endtask

task sample_on_bending_change();
// make transaction when pin bending changes outside 
// SPI transmit
    @(bending iff csn);
    item.speed = 16'd0;
endtask

task sample_on_spi_transmit();
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
            @mon_cb;
            item.speed << 1;
            item.speed[0] = mon_cb.mosi;
        end
    join_any
    disable fork;
endtask

task run();
    pmd901_trans item;
    pmd901_trans cloned_item;
    item = pmd901_trans::type_id::create("item");

    forever begin
        fork
            begin
            sample_on_power_change();
            end
            begin
            sample_on_bending_change();
            end
            begin
            sample_on_spi_transmit();
            end
        join_any
        disable fork;
        
        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask

endinterface: pmd901_monitor_bfm
