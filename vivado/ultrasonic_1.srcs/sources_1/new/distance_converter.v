`timescale 1ns/1ps

module distance_converter (
    input  wire [31:0] echo_count,
    output wire [15:0] distance_cm
);

    assign distance_cm = echo_count / 32'd5800;

endmodule