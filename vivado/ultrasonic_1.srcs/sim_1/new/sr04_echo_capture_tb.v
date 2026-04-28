`timescale 1ns/1ps

module sr04_echo_capture_tb;

    reg clk;
    reg rst;
    reg echo;
    reg start_meas;

    wire [31:0] echo_count;
    wire        echo_done;
    wire        echo_timeout;

    // DUT
    sr04_echo_capture uut (
        .clk          (clk),
        .rst          (rst),
        .echo         (echo),
        .start_meas   (start_meas),
        .echo_count   (echo_count),
        .echo_done    (echo_done),
        .echo_timeout (echo_timeout)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst        = 1'b1;
        echo       = 1'b0;
        start_meas = 1'b0;

        #50;
        rst = 1'b0;

        // ------------------------------------------------
        // CASE 1: normal echo pulse
        // ------------------------------------------------
        #20;
        start_meas = 1'b1;
        #10;
        start_meas = 1'b0;

        // wait before echo rises
        #300;
        echo = 1'b1;

        // echo stays high for 1000 ns
        #1000;
        echo = 1'b0;

        #500;

        // ------------------------------------------------
        // CASE 2: timeout (never raises)
        // ------------------------------------------------
        start_meas = 1'b1;
        #10;
        start_meas = 1'b0;

        // wait long enough for timeout:
        // TIMEOUT_CYCLES = 3_000_000 @ 10 ns = 30 ms
        #31000000;

        // ------------------------------------------------
        // CASE 3: another normal pulse
        // ------------------------------------------------
        start_meas = 1'b1;
        #10;
        start_meas = 1'b0;

        #200;
        echo = 1'b1;
        #5800;   // about 1 cm equivalent in raw count scale
        echo = 1'b0;

        #1000;

        $finish;
    end

endmodule