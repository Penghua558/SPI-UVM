//////////////////////////////////////////////////////////////////////
////                                                              ////
////  spi_shift.v                                                 ////
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

module spi_shift#(
    parameter [5:0] CS_N_HOLD_COUNT = 6'd3
)(
    // system clock is esstienaly the same as s_clk, except s_clk will be
    // pulled HIGH once SPI transmit is not undergoing.
    input wire clk,
    input wire rst,
    input wire spi_start,
    input wire [15:0] p_in,

    input wire miso,
    output reg spi_ready,
    output reg s_clk,
    output reg cs_n,
    output reg mosi // MSB is transmitted at first
);


  parameter [2:0] IDLE = 3'b0;
  parameter [2:0] CS_N_HOLD = 3'b010;
  parameter [2:0] DATA_OUT = 3'b100;

  reg [2:0] next_state;
  reg [2:0] current_state;
  reg [5:0] cs_n_hold_cnt;
  reg [15:0] motor_speed;
  reg [4:0] spi_transmit_cnt;

  always@(posedge clk or posedge rst) begin
      if (rst) begin
          current_state <= IDLE;
          s_clk <= 1'b1;
          cs_n <= 1'b1;
          mosi <= 1'b0;
          spi_ready <= 1'b1;

          cs_n_hold_cnt <= 6'd0;
          spi_transmit_cnt <= 5'd0;
      end else begin
          current_state <= next_state;

          case(current_state)
              IDLE: begin
                  s_clk <= 1'b1;
                  cs_n <= 1'b1;
                  mosi <= 1'b0;
                  spi_ready <= 1'b1;
              end
              CS_N_HOLD: begin
                  cs_n <= 1'b0;
                  s_clk <= 1'b1;
                  mosi <= 1'b0;
                  spi_ready <= 1'b0;
                  motor_speed <= p_in;

                  if (cs_n_hold_cnt == CS_N_HOLD_COUNT)
                      cs_n_hold_cnt <= 6'd0;
                  else
                    cs_n_hold_cnt <= cs_n_hold_cnt + 6'd1;
              end
              DATA_OUT: begin
                  cs_n <= 1'b0;
                  s_clk <= clk;
                  spi_ready <= 1'b0;

                  if (spi_transmit_cnt == 5'd16)
                    spi_transmit_cnt <= 5'd0;
                  else
                    spi_transmit_cnt <= spi_transmit_cnt + 5'd1;

                  mosi <= motor_speed[15];
                  motor_speed <= motor_speed << 1;
              end
              default: begin
                  s_clk <= 1'b1;
                  cs_n <= 1'b1;
                  mosi <= 1'b0;
                  spi_ready <= 1'b1;
              end
          endcase
      end
  end

  always@(*) begin
      case(current_state)
          IDLE: begin
              if (spi_start)
                  next_state = CS_N_HOLD;
              else
                  next_state = IDLE;
          end
          CS_N_HOLD: begin
              if (cs_n_hold_cnt == CS_N_HOLD_COUNT)
                  next_state = DATA_OUT;
              else
                  next_state = CS_N_HOLD;
          end
          DATA_OUT: begin
              if (spi_transmit_cnt == 5'd16)
                  next_state = IDLE;
              else
                  next_state = DATA_OUT;
          end
          default: next_state = IDLE;
      endcase
  end

endmodule
