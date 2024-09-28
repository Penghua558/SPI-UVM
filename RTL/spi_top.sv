// Code your design here
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  spi_top.v                                                   ////
////                                                              ////
////  This file is part of the SPI IP core project                ////
////  http://www.opencores.org/projects/spi/                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Srot (simons@opencores.org)                     ////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002 Authors                                   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

// This spi_top module has been modified from the original to add in 
// an APB interface
//
//

`include "timescale.v"
`include "spi_defines.v"
`include "spi_clgen.v"
`include "spi_shift.v"
`include "spi_reg.v"
`include "cdc_handshaking.v"
`include "spi_initiator.v"

module spi_top#(
// divide input clock frequency by SCLK_DIVIDER*2
parameter [7:0] SCLK_DIVIDER = 8'd8,
parameter [11:0] SPI_TRANSMIT_DELAY = 12'd2001,
parameter [5:0] CS_N_HOLD_COUNT = 6'd3
)
(
    // clock frequency 100MHz
    input wire clk, 
    input wire rstn,
    input wire [15:0] wdata,
    input wire we,

    input wire dev_enable,
    input wire dev_bending,

    // PMD901 signals
    // active HIGH, SPI violation, currently no use
    input wire fault,
    // active HIGH, PMD901 close to overheat, currently no use
    input wire fan,
    // active HIGH, PMD901 overheat, currently no use
    input wire ready,

    output reg park,
    output reg bending,

  // SPI signals
    output reg sclk,
    output reg cs_n,
    output reg mosi
);

  parameter Tp = 1;
                                               
  // Internal signals
  wire sclk_gen_o; // SPI clock derived from module input clock
  wire spi_ready; // asserted to indicate recent SPI transmit has completed
  wire spi_ready_crossed; // signal of spi_ready crossed different clock domain
  wire spi_start; // asserted to start a new SPI transmit
  wire spi_start_crossed; // signal of spi_start crossed different clock domain
  wire [15:0] motor_speed;
  
  spi_clgen clgen (.clk_in(clk), .rst(!rstn), 
                   .divider(SCLK_DIVIDER), .clk_out(sclk_gen_o), .pos_edge(pos_edge), 
                   .neg_edge(neg_edge));
  always@(posedge clk) begin
      park <= dev_enable;
      bending <= dev_bending;
  end

  spi_reg pmd901_reg(
    .clk(clk),
    .rstn(rstn),
    .wdata(wdata),
    .we(we),

    .motor_speed(motor_speed)
  );

  spi_initiator #(
    .SPI_TRANSMIT_DELAY(SPI_TRANSMIT_DELAY)
  ) transmit_initiator(
    .clk(clk),
    .rstn(rstn),
    .spi_ready(spi_ready_crossed),
    .spi_start(spi_start)
  );

  cdc_handshaking spi_start_crossing(
    .old_clk(clk),
    .data_in(spi_start),
    .new_clk(sclk_gen_o),

    .data_out(spi_start_crossed)
  );

  cdc_handshaking spi_ready_crossing(
    .old_clk(sclk_gen_o),
    .data_in(spi_ready),
    .new_clk(clk),

    .data_out(spi_ready_crossed)
  );

  
  spi_shift#(
    .CS_N_HOLD_COUNT(CS_N_HOLD_COUNT)
  ) shift (
      .clk(sclk_gen_o), 
      .rst(!rstn),
      .spi_start(spi_start_crossed),
      .p_in(motor_speed),

      .miso(),
      .spi_ready(spi_ready),
      .s_clk(sclk), 
      .cs_n(cs_n),
      .mosi(mosi));
endmodule
