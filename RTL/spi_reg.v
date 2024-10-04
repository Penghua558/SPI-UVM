module spi_reg(
    input wire clk,
    input wire rstn,

    input wire [15:0] addr,
    input wire [15:0] wdata,
    input wire wr,
    output reg [15:0] rdata,

    input wire i_fan,
    input wire i_fault,
    input wire i_ready,
    output wire [15:0] o_motor_speed,
    output wire o_park,
    output wire o_bending
);

reg [15:0] addr_d;
reg [15:0] wdata_d;
reg wr_d;

reg [15:0] motor_speed;
reg park;
reg bending;
reg fan;
reg fault;
reg ready;

always@(posedge clk) begin
    fan <= i_fan;
    fault <= i_fault;
    ready <= i_ready;
end

assign o_motor_speed = motor_speed;
assign o_park = park;
assign o_bending = bending;

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rdata <= 16'd0;
    end else begin
        if (wr) begin
        // write operation
            case(addr)
                16'd0: motor_speed <= wdata;
                16'd1: park        <= wdata[0];
                16'd2: bending     <= wdata[0];
                default:;
            endcase
        end else begin
        // read operation
            case(addr)
                16'd0: rdata <= motor_speed;
                16'd1: rdata <= {15'd0, park};
                16'd2: rdata <= {15'd0, bending};
                16'd3: rdata <= {15'd0, fan};
                16'd4: rdata <= {15'd0, fault};
                16'd5: rdata <= {15'd0, ready};
                default: rdata <= 16'd0;
            endcase
        end
    end
end
endmodule
