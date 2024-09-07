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
`include "cdc_handshaking.v"
`include "spi_initiator.v"

module spi_top #(
// divide input clock frequency by SCLK_DIVIDER*2
parameter SCLK_DIVIDER = 8'd8
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

  rstn, PADDR, PWDATA, PRDATA, PSEL,
  PWRITE, PENABLE, PREADY, PSLVERR,
  // Interrupt
  IRQ,
  // SPI signals
  ss_pad_o, sclk_pad_o, mosi_pad_o, miso_pad_i
);

  parameter Tp = 1;
  
  input                            clk;            // APB System Clock
  input                            rstn;         // APB Reset - Active low
  input [4:0]                      PADDR;           // APB Address
  input [31:0]                     PWDATA;          // Write data
  output[31:0]                     PRDATA;          // Read data
  input                            PWRITE;
  input                            PSEL;
  input                            PENABLE;
  output                           PREADY;
  output                           PSLVERR;
  output                           IRQ;
                                                     
  // SPI signals                                     
  output          [`SPI_SS_NB-1:0] ss_pad_o;         // slave select
  output                           sclk_pad_o;       // serial clock
  output                           mosi_pad_o;       // master out slave in
  input                            miso_pad_i;       // master in slave out
                                                     
  reg                     [32-1:0] PRDATA;
  reg                              PREADY;
  reg                              IRQ;
                                               
  // Internal signals
  reg       [`SPI_CTRL_BIT_NB-1:0] ctrl;             // Control and status register
  reg                     [32-1:0] wb_dat;           // wb data out
  wire         [`SPI_MAX_CHAR-1:0] rx;               // Rx register
  wire                             rx_negedge;       // miso is sampled on negative edge
  wire                             tx_negedge;       // mosi is driven on negative edge
  wire    [`SPI_CHAR_LEN_BITS-1:0] char_len;         // char len
  wire                             lsb;              // lsb first on line
  wire                             ie;               // interrupt enable
  wire                             spi_ctrl_sel;     // ctrl register select
  wire                       [3:0] spi_tx_sel;       // tx_l register select
  wire                             spi_ss_sel;       // ss register select
  wire                             pos_edge;         // recognize posedge of sclk
  wire                             neg_edge;         // recognize negedge of sclk
  wire sclk_gen_o; // SPI clock derived from module input clock
  wire spi_ready; // asserted to indicate recent SPI transmit has completed
  wire spi_ready_crossed; // signal of spi_ready crossed different clock domain
  wire spi_start; // asserted to start a new SPI transmit
  wire spi_start_crossed; // signal of spi_start crossed different clock domain
  
  
  
  assign ss_pad_o = ~((ss & {`SPI_SS_NB{tip & ass}}) | (ss & {`SPI_SS_NB{!ass}}));
  
  spi_clgen clgen (.clk_in(clk), .rst(!rstn), 
                   .divider(SCLK_DIVIDER), .clk_out(sclk_gen_o), .pos_edge(pos_edge), 
                   .neg_edge(neg_edge));

  reg pmd901_reg(
    .clk(clk),
    .rstn(rstn),
    .wdata(wdata),
    .we(we),

    .motor_speed(motor_speed)
  );

  spi_initiator #(
    .SPI_TRANSMIT_DELAY(2001)
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

  
  spi_shift shift (.clk(clk), .rst(!rstn), .len(char_len[`SPI_CHAR_LEN_BITS-1:0]),
                   .latch(spi_tx_sel[3:0] & {4{PWRITE}}), .byte_sel(4'hF), .lsb(lsb), 
                   .pos_edge(pos_edge), .neg_edge(neg_edge), 
                   .rx_negedge(rx_negedge), .tx_negedge(tx_negedge),
                   .tip(tip), .last(last_bit), 
                   .p_in(PWDATA), .p_out(rx), 
                   .s_clk(sclk_gen_o), .s_in(miso_pad_i), .s_out(mosi_pad_o));
endmodule
