`timescale 1ns/1ps

module hs_sr04_trigger_tb;

    reg clk;
    reg rst;
    reg start_meas;

    wire trig;
    wire done;

    // DUT
    hs_sr04_trigger uut (
        .clk        (clk),
        .rst        (rst),
        .start_meas (start_meas),
        .trig       (trig),
        .done       (done)
    );

    // 100 MHz clock -> 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        // init
        rst        = 1'b1;
        start_meas = 1'b0;

        // reset
        #50;
        rst = 1'b0;

        // first trigger request
        #20;
        start_meas = 1'b1;
        #10;
        start_meas = 1'b0;

        // wait enough time for 10 us pulse + done
        #12000;

        // second trigger request
        start_meas = 1'b1;
        #10;
        start_meas = 1'b0;

        #12000;

        $finish;
    end

endmodule