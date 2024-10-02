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
    output wire s_clk,
    output reg cs_n,
    output reg mosi // MSB is transmitted at first
);


  parameter [3:0] IDLE = 4'b0;
  parameter [3:0] CS_N_HOLD = 4'b0010;
  parameter [3:0] DATA_OUT = 4'b0100;
  parameter [3:0] SCLK_GATE = 4'b1000;

  reg [3:0] next_state;
  reg [3:0] current_state;
  reg [5:0] cs_n_hold_cnt;
  reg [15:0] motor_speed;
  reg [4:0] spi_transmit_cnt;
  // 1 means gate is in effect, which would pull s_clk HIGH
  // 0 means gate is not in effect, s_clk would be equal to clk
  reg s_clk_gate = 1'b1;
  reg sclk_gate_cnt = 1'b0;

  assign s_clk = s_clk_gate | clk;

  always@(posedge clk or posedge rst) begin
      if (rst) begin
          current_state <= IDLE;
          s_clk_gate <= 1'b1;
          cs_n <= 1'b1;
          mosi <= 1'b0;
          spi_ready <= 1'b1;

          cs_n_hold_cnt <= 6'd0;
          spi_transmit_cnt <= 5'd0;
      end else begin
          current_state <= next_state;

          case(current_state)
              IDLE: begin
                  s_clk_gate <= 1'b1;
                  cs_n <= 1'b1;
                  mosi <= 1'b0;
                  spi_ready <= 1'b1;
                  sclk_gate_cnt <= 1'b0;
              end
              CS_N_HOLD: begin
                  cs_n <= 1'b0;
                  s_clk_gate <= 1'b1;
                  mosi <= 1'b0;
                  spi_ready <= 1'b0;
                  sclk_gate_cnt <= 1'b0;
                  motor_speed <= p_in;

                  if (cs_n_hold_cnt == CS_N_HOLD_COUNT)
                      cs_n_hold_cnt <= 6'd0;
                  else
                    cs_n_hold_cnt <= cs_n_hold_cnt + 6'd1;
              end
              DATA_OUT: begin
                  cs_n <= 1'b0;
                  s_clk_gate <= 1'b0;
                  spi_ready <= 1'b0;
                  sclk_gate_cnt <= 1'b0;

                  if (spi_transmit_cnt == 5'd15)
                    spi_transmit_cnt <= 5'd0;
                  else
                    spi_transmit_cnt <= spi_transmit_cnt + 5'd1;

                  mosi <= motor_speed[15];
                  motor_speed <= motor_speed << 1;
              end
              SCLK_GATE: begin
                  cs_n <= 1'b0;
                  s_clk_gate <= 1'b1;
                  spi_ready <= 1'b0;
                  mosi <= 1'b0;
                  sclk_gate_cnt <= 1'b1;
              end
              default: begin
                  s_clk_gate <= 1'b1;
                  cs_n <= 1'b1;
                  mosi <= 1'b0;
                  spi_ready <= 1'b1;
                  sclk_gate_cnt <= 1'b0;
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
              if (spi_transmit_cnt == 5'd15)
                  next_state = SCLK_GATE;
              else
                  next_state = DATA_OUT;
          end
          SCLK_GATE: begin
            if (sclk_gate_cnt)
                next_state = IDLE;
            else
                next_state = SCLK_GATE;
          end
          default: next_state = IDLE;
      endcase
  end

endmodule
