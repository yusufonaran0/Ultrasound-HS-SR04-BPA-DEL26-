`timescale 1ns/1ps

module testbench;

    reg clk;
    reg btnu;
    reg btnd;
    reg echo;

    wire trig;
    wire buzzer;
    wire [6:0] seg;
    wire [7:0] an;
    wire dp;
    wire [3:0] led;

    ultrasonic_top dut (
        .clk(clk),
        .btnu(btnu),
        .btnd(btnd),
        .echo(echo),
        .trig(trig),
        .buzzer(buzzer),
        .seg(seg),
        .an(an),
        .dp(dp),
        .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");

        // Selective dump: do NOT dump clk, seg, an for top-level long simulation
        $dumpvars(0, btnu);
        $dumpvars(0, btnd);
        $dumpvars(0, echo);
        $dumpvars(0, trig);
        $dumpvars(0, dut.w_echo_done);
        $dumpvars(0, dut.w_echo_count);
        $dumpvars(0, dut.w_distance_cm_raw);
        $dumpvars(0, dut.r_distance_cm);
        $dumpvars(0, dut.r_valid_meas);
        $dumpvars(0, led);

        clk  = 0;
        btnu = 1;
        btnd = 0;
        echo = 0;

        #100;
        btnu = 0;

        wait (trig == 1'b1);
        $display("TRIG started at %0t", $time);

        wait (trig == 1'b0);
        $display("TRIG ended at %0t", $time);

        repeat (300) @(posedge clk);

        // Shorter top-level test: 5800 cycles = 1 cm
        @(posedge clk);
        #1 echo = 1'b1;

        repeat (5800) @(posedge clk);

        @(posedge clk);
        #1 echo = 1'b0;

        wait (dut.w_echo_done == 1'b1);
        $display("ECHO_DONE detected at %0t", $time);

        @(posedge clk);
        #1;

        $display("echo_count  = %0d", dut.w_echo_count);
        $display("raw_dist    = %0d", dut.w_distance_cm_raw);
        $display("stored_dist = %0d", dut.r_distance_cm);
        $display("valid_meas  = %0d", dut.r_valid_meas);
        $display("led         = %b", led);

        if (dut.r_distance_cm == 16'd1 && dut.r_valid_meas == 1'b1)
            $display("PASS: ultrasonic_top measured 1 cm correctly");
        else
            $display("ERROR: expected 1 cm, got %0d", dut.r_distance_cm);

        btnd = 1'b1;
        repeat (50) @(posedge clk);

        if (led[1] == 1'b1)
            $display("PASS: hold mode active");
        else
            $display("ERROR: hold mode not active");

        #100;
        $finish;
    end

endmodule
