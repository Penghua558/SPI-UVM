//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
//
// BFM Interface Description:
//
//
interface apb_driver_bfm (
  input         PCLK,
  input         PRESETn,

  output logic [15:0] PADDR,
  input  logic [15:0] PRDATA,
  output logic [15:0] PWDATA,
  output logic [15:0] PSEL, // Only connect the ones that are needed
  output logic PENABLE,
  output logic PWRITE,
  input  logic PREADY
);

import apb_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
int apb_index = 0;
//------------------------------------------
// Methods
//------------------------------------------

task automatic reset();
    while (!PRESETn) begin
        PADDR <= 16'd0;
        PWDATA <= 16'd0;
        PSEL <= 16'd0;
        PENABLE <= 1'b0;
        PWRITE <= 1'b0;
        @(posedge PCLK);
    end
endtask

function void set_apb_index(int index);
    apb_index = index;
endfunction: set_apb_index

task drive (apb_seq_item req);
    int apb_index;

    repeat(req.delay)
        @(posedge PCLK);
    PSEL[apb_index] <= 1'b1;
    PADDR <= req.addr;
    PWDATA <= req.wdata;
    PWRITE <= req.wr;
    @(posedge PCLK);
    PENABLE <= 1'b1;
    while (!PREADY)
        @(posedge PCLK);
    if(PWRITE == 0)
        req.rdata = PRDATA;
    @(posedge PCLK);
    PSEL[apb_index] <= 1'b0;
    PENABLE <= 1'b0;
endtask: drive

endinterface: apb_driver_bfm
