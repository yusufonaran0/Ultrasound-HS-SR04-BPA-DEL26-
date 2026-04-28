`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
    reg start_meas;

    wire trig;
    wire done;

    hs_sr04_trigger dut (
        .clk(clk),
        .rst(rst),
        .start_meas(start_meas),
        .trig(trig),
        .done(done)
    );

    always #5 clk = ~clk; // 100 MHz

    integer count_trig_high;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        rst = 1;
        start_meas = 0;
        count_trig_high = 0;

        #20;
        rst = 0;

        // Start measurement exactly before a rising edge
        #7;
        start_meas = 1;

        @(posedge clk);
        #1;
        start_meas = 0;

        // Count all HIGH cycles of trig
        while (!done) begin
            @(posedge clk);
            #1;

            if (trig)
                count_trig_high = count_trig_high + 1;
        end

        $display("DONE detected at time %0t", $time);
        $display("TRIG HIGH cycles = %0d", count_trig_high);

        if (count_trig_high == 1000)
            $display("PASS: Correct 10us trigger pulse");
        else
            $display("ERROR: Expected 1000 cycles, got %0d", count_trig_high);

        #50;
        $finish;
    end

endmodule
