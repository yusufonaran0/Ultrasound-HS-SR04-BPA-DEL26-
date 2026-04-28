`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
    reg [15:0] distance_cm;

    wire buzzer;

    buzzer_control dut (
        .clk(clk),
        .rst(rst),
        .distance_cm(distance_cm),
        .buzzer(buzzer)
    );

    always #5 clk = ~clk; // 100 MHz

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        rst = 1;
        distance_cm = 16'd150;

        #30;
        rst = 0;

        // Far distance: buzzer OFF
        distance_cm = 16'd150;
        repeat (50) @(posedge clk);

        // Medium/far range: slow beep threshold
        distance_cm = 16'd75;
        repeat (50) @(posedge clk);

        // Medium range
        distance_cm = 16'd35;
        repeat (50) @(posedge clk);

        // Close range
        distance_cm = 16'd10;
        repeat (50) @(posedge clk);

        // Very close: buzzer constant ON
        distance_cm = 16'd3;
        repeat (20) @(posedge clk);

        $display("buzzer_control test finished.");
        $finish;
    end

endmodule
