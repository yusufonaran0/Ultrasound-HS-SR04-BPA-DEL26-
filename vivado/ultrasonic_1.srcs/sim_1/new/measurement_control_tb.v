`timescale 1ns/1ps

module measurement_control_tb;

    reg clk;
    reg rst;

    reg btn_hold;
    reg trigger_done;
    reg echo_done;
    reg echo_timeout;

    wire start_trigger;
    wire measuring;
    wire valid_data;

    // DUT
    measurement_control uut (
        .clk           (clk),
        .rst           (rst),
        .btn_hold      (btn_hold),
        .trigger_done  (trigger_done),
        .echo_done     (echo_done),
        .echo_timeout  (echo_timeout),
        .start_trigger (start_trigger),
        .measuring     (measuring),
        .valid_data    (valid_data)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst          = 1'b1;
        btn_hold     = 1'b0;
        trigger_done = 1'b0;
        echo_done    = 1'b0;
        echo_timeout = 1'b0;

        #50;
        rst = 1'b0;

        // FSM should auto-start
        #50;

        // simulate trigger finished
        trigger_done = 1'b1;
        #10;
        trigger_done = 1'b0;

        #100;

        // simulate echo measurement completed
        echo_done = 1'b1;
        #10;
        echo_done = 1'b0;

        #100;

        // enter hold
        btn_hold = 1'b1;
        #100;

        // release hold
        btn_hold = 1'b0;
        #100;

        // next cycle trigger done
        trigger_done = 1'b1;
        #10;
        trigger_done = 1'b0;

        #100;

        // simulate timeout instead of echo_done
        echo_timeout = 1'b1;
        #10;
        echo_timeout = 1'b0;

        #200;

        $finish;
    end

endmodule