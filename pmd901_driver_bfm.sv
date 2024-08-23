interface pmd901_driver_bfm (
  input logic clk,
  input logic cs,
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

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

task wait_csn_isknown();
  while(csn === 1'hx) begin
    #1;
  end
endtask : wait_csn_isknown

task setup_phase(pmd901_seq_item req);
endtask: setup_phase



task setup_phase(ref spi_seq_item req);
  int no_bits;
  
  while(cs == 8'hff) begin
    @(cs);
  end
  `uvm_info("SPI_DRV_RUN:", $sformatf("Starting transmission: %0h RX_NEG State %b, no of bits %0d", req.spi_data, req.RX_NEG, req.no_bits), UVM_LOW)
  no_bits = req.no_bits;
  if(no_bits == 0) begin
    no_bits = 128;
  end
  miso <= req.spi_data[0];
  for(int i = 1; i < no_bits-1; i++) begin
    if(req.RX_NEG == 1) begin
      @(posedge clk);
    end
    else begin
      @(negedge clk);
    end
    miso <= req.spi_data[i];
    if(cs == 8'hff) begin
      break;
    end
  end
endtask : setup_phase 
  
endinterface: pmd901_driver_bfm
