`timescale 1ns / 1ps

module ROM (
    input  [15:0] addr,
    input         en,
    input         clk,
    output reg [15:0] dout
);
    reg [7:0] ROM_DATA [0:127];
    integer i;

    initial begin
        ROM_DATA[0] = 8'hF0; ROM_DATA[1] = 8'h01; // IN R1
        ROM_DATA[2] = 8'hF0; ROM_DATA[3] = 8'h22; // OUT R1
        ROM_DATA[4] = 8'h00; ROM_DATA[5] = 8'h00; // NOP
        ROM_DATA[6] = 8'h00; ROM_DATA[7] = 8'h00; // NOP
        for (i = 32; i < 128; i = i + 1) begin
            ROM_DATA[i] = 8'h00;
        end
    end

    always @(posedge clk) begin
        if (en) begin
            //: dout[7:0] recebe addr+1 e dout[15:8] recebe addr
            dout[7:0]  <= ROM_DATA[addr + 1];
            dout[15:8] <= ROM_DATA[addr];
        end
    end

endmodule