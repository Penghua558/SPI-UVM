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
import pmd901_agent_dec::*;

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

task sample_on_power_change(pmd901_trans item);
// we are intrested the moment working PMD901
// is powered down or powered up
    @(park);
    item.speed = 16'd0;
endtask

task sample_on_bending_change(pmd901_trans item);
// make transaction when pin bending changes outside
// SPI transmit
    @(bend iff csn);
    item.speed = 16'd0;
endtask

function automatic work_status_e get_work_status();
    case({park, bend})
        2'b0?: return pmd901_agent_dec::POWER_DOWN;
        2'b10: return pmd901_agent_dec::NORMAL_WORKING;
        2'b11: return pmd901_agent_dec::BENDING_WORKING;
        default: return pmd901_agent_dec::POWER_DOWN;
    endcase
endfunction

task sample_on_spi_transmit(pmd901_trans item);
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
            item.speed = item.speed << 1;
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
            sample_on_power_change(item);
            end
            begin
            sample_on_bending_change(item);
            end
            begin
            sample_on_spi_transmit(item);
            end
        join_any;
        disable fork;

        item.work_status = get_work_status();
        item.overheat = ready;
        item.close2overheat = fan;
        item.spi_violated = fault;

        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask

endinterface: pmd901_monitor_bfm
