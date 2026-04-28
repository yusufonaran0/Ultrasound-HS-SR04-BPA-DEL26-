`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
    reg echo;
    reg start_meas;

    wire [31:0] echo_count;
    wire echo_done;
    wire echo_timeout;

    sr04_echo_capture dut (
        .clk(clk),
        .rst(rst),
        .echo(echo),
        .start_meas(start_meas),
        .echo_count(echo_count),
        .echo_done(echo_done),
        .echo_timeout(echo_timeout)
    );

    always #5 clk = ~clk; // 100 MHz

    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        rst = 1;
        echo = 0;
        start_meas = 0;

        #30;
        rst = 0;

        // Start echo capture
        @(posedge clk);
        start_meas = 1;
        @(posedge clk);
        start_meas = 0;

        // Wait a little before echo rises
        repeat (10) @(posedge clk);

        // Echo HIGH for 5800 clock cycles = approximately 1 cm
        echo = 1;
        repeat (5800) @(posedge clk);
        echo = 0;

        // Wait for echo_done
        repeat (20) begin
            @(posedge clk);
            #1;
            if (echo_done) begin
                $display("ECHO_DONE detected");
                $display("echo_count = %0d", echo_count);
            end
        end

        if (echo_timeout) begin
            $display("ERROR: unexpected timeout");
        end
        else if (echo_count >= 32'd5798 && echo_count <= 32'd5802) begin
            $display("PASS: echo pulse captured correctly");
        end
        else begin
            $display("ERROR: expected about 5800, got %0d", echo_count);
        end

        $finish;
    end

endmodule
