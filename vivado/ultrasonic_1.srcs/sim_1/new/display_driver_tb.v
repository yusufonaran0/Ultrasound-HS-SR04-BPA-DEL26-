`timescale 1ns/1ps

module display_driver_tb;

    reg clk;
    reg rst;
    reg hold_active;
    reg valid_meas;
    reg [15:0] distance_cm;

    wire [6:0] seg;
    wire [7:0] an;
    wire dp;

    // DUT
    display_driver uut (
        .clk         (clk),
        .rst         (rst),
        .hold_active (hold_active),
        .valid_meas  (valid_meas),
        .distance_cm (distance_cm),
        .seg         (seg),
        .an          (an),
        .dp          (dp)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst         = 1'b1;
        hold_active = 1'b0;
        valid_meas  = 1'b0;
        distance_cm = 16'd0;

        #50;
        rst = 1'b0;

        // invalid measurement -> should show dashes
        #2000;

        // valid 123 cm
        valid_meas  = 1'b1;
        distance_cm = 16'd123;
        #4000;

        // valid 7 cm
        distance_cm = 16'd7;
        #4000;

        // hold active
        hold_active = 1'b1;
        #4000;

        // clamp test (>999)
        distance_cm = 16'd1450;
        #4000;

        // invalid again
        valid_meas = 1'b0;
        #4000;

        $finish;
    end

endmodule