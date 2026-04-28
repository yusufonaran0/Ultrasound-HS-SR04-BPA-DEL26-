`timescale 1ns/1ps

module testbench;

    reg  [31:0] echo_count;
    wire [15:0] distance_cm;

    distance_converter dut (
        .echo_count(echo_count),
        .distance_cm(distance_cm)
    );

    task check;
        input [31:0] test_count;
        input [15:0] expected_cm;
        begin
            echo_count = test_count;
            #10;

            if (distance_cm !== expected_cm) begin
                $display("ERROR: echo_count=%0d distance_cm=%0d expected=%0d",
                         test_count, distance_cm, expected_cm);
            end
            else begin
                $display("PASS : echo_count=%0d distance_cm=%0d",
                         test_count, distance_cm);
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        check(32'd0,      16'd0);
        check(32'd5800,   16'd1);
        check(32'd11600,  16'd2);
        check(32'd29000,  16'd5);
        check(32'd58000,  16'd10);
        check(32'd290000, 16'd50);
        check(32'd580000, 16'd100);

        // integer division test
        check(32'd5799,   16'd0);
        check(32'd11599,  16'd1);

        $display("distance_converter test finished.");
        $finish;
    end

endmodule
