module spi_reg(
    input wire clk,
    input wire rstn,
    input wire [15:0] wdata,
    input wire we,

    output reg [15:0] motor_speed
);

always@(posedge clk or negedge rstn) begin
    if (!rstn)
        motor_speed <= 16'd0;
    else begin
        if (we) begin
            motor_speed <= wdata;
        end else begin
            motor_speed <= motor_speed;
        end
    end
end
endmodule
