`timescale 1ns / 1ps

module RAM (
    input clk,
    input we,
    input  [15:0] din,
    input  [15:0] addr,
    output reg [15:0] dout
);

    reg [7:0] RAM_data [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            RAM_data[i] = 8'h00;
        end
    end

    always @(posedge clk) begin
        if (we) begin
            RAM_data[addr]     <= din[7:0];
            RAM_data[addr + 1] <= din[15:8];
        end
    end

    always @(posedge clk) begin
        dout[7:0]  <= RAM_data[addr];
        dout[15:8] <= RAM_data[addr + 1];
    end

endmodule