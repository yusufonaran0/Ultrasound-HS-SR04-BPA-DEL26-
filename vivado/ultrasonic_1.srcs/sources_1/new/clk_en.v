`timescale 1ns/1ps

module clk_en #(
    parameter integer MAX = 4
)(
    input  wire clk,
    input  wire rst,
    output reg  ce
);

    reg [$clog2(MAX)-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            ce  <= 1'b0;
            cnt <= 0;
        end
        else if (cnt == MAX-1) begin
            ce  <= 1'b1;
            cnt <= 0;
        end
        else begin
            ce  <= 1'b0;
            cnt <= cnt + 1'b1;
        end
    end

endmodule