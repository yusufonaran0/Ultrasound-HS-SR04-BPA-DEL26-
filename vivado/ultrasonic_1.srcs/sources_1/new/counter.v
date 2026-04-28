`timescale 1ns/1ps

module counter #(
    parameter integer N = 3
)(
    input  wire clk,
    input  wire rst,
    input  wire en,
    output reg  [N-1:0] cnt
);

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else if (en) begin
            cnt <= cnt + 1'b1;
        end
    end

endmodule