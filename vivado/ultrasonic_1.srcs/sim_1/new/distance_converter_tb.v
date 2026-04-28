`timescale 1ns/1ps

module distance_converter_tb;

    reg  [31:0] echo_count;
    wire [15:0] distance_cm;

    // DUT
    distance_converter uut (
        .echo_count  (echo_count),
        .distance_cm (distance_cm)
    );

    initial begin
        echo_count = 32'd0;
        #20;

        echo_count = 32'd5800;    // ~1 cm
        #20;

        echo_count = 32'd11600;   // ~2 cm
        #20;

        echo_count = 32'd58000;   // ~10 cm
        #20;

        echo_count = 32'd290000;  // ~50 cm
        #20;

        echo_count = 32'd580000;  // ~100 cm
        #20;

        $finish;
    end

endmodule