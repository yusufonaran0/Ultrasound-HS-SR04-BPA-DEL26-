`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
    reg hold_active;
    reg valid_meas;
    reg [15:0] distance_cm;

    wire [6:0] seg;
    wire [7:0] an;
    wire dp;

    display_driver dut (
        .clk(clk),
        .rst(rst),
        .hold_active(hold_active),
        .valid_meas(valid_meas),
        .distance_cm(distance_cm),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    always #5 clk = ~clk; // 100 MHz

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        rst = 1;
        hold_active = 0;
        valid_meas = 0;
        distance_cm = 0;

        #50;
        rst = 0;

        // No valid measurement: display dashes and C
        valid_meas = 0;
        distance_cm = 16'd0;
        repeat (300) @(posedge clk);

        // Valid measurement: display 123C
        valid_meas = 1;
        distance_cm = 16'd123;
        repeat (300) @(posedge clk);

        // Hold active: H + 123C
        hold_active = 1;
        repeat (300) @(posedge clk);

        // Saturation test: distance > 999 should display 999C
        hold_active = 0;
        distance_cm = 16'd1200;
        repeat (300) @(posedge clk);

        $display("display_driver test finished.");
        $finish;
    end

endmodule
