`timescale 1ns/1ps

module display_driver (
    input  wire        clk,
    input  wire        rst,
    input  wire        hold_active,
    input  wire        valid_meas,
    input  wire [15:0] distance_cm,

    output reg  [6:0]  seg,
    output reg  [7:0]  an,
    output wire        dp
);

    localparam [4:0]
        CH_H     = 5'd16,
        CH_DASH  = 5'd17,
        CH_BLANK = 5'd18;

    // Simulation-oriented refresh
    wire refresh_ce;

    clk_en #(
        .MAX(100_000)
    ) u_clk_en (
        .clk (clk),
        .rst (rst),
        .ce  (refresh_ce)
    );

    wire [2:0] scan_sel;

    counter #(
        .N(3)
    ) u_scan_counter (
        .clk (clk),
        .rst (rst),
        .en  (refresh_ce),
        .cnt (scan_sel)
    );

    wire [15:0] disp_val;
    assign disp_val = (distance_cm > 16'd999) ? 16'd999 : distance_cm;

    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;

    always @(*) begin
        hundreds = (disp_val / 100) % 10;
        tens     = (disp_val / 10)  % 10;
        ones     =  disp_val % 10;
    end

    reg [4:0] digit7, digit6, digit5, digit4, digit3, digit2, digit1, digit0;

    always @(*) begin
        digit7 = CH_BLANK; // D1
        digit6 = CH_BLANK; // D2
        digit5 = CH_BLANK; // D3
        digit4 = CH_BLANK; // D4
        digit3 = CH_BLANK; // D5
        digit2 = CH_BLANK; // D6
        digit1 = CH_BLANK; // D7
        digit0 = 5'hC;     // D8 = C

        if (hold_active)
            digit7 = CH_H;

        if (valid_meas) begin
            digit3 = {1'b0, hundreds};
            digit2 = {1'b0, tens};
            digit1 = {1'b0, ones};
        end
        else begin
            digit3 = CH_DASH;
            digit2 = CH_DASH;
            digit1 = CH_DASH;
        end
    end

    reg [4:0] current_char;

    always @(*) begin
        an = 8'b1111_1111;
        current_char = CH_BLANK;

        case (scan_sel)
            3'd0: begin an = 8'b1111_1110; current_char = digit0; end
            3'd1: begin an = 8'b1111_1101; current_char = digit1; end
            3'd2: begin an = 8'b1111_1011; current_char = digit2; end
            3'd3: begin an = 8'b1111_0111; current_char = digit3; end
            3'd4: begin an = 8'b1110_1111; current_char = digit4; end
            3'd5: begin an = 8'b1101_1111; current_char = digit5; end
            3'd6: begin an = 8'b1011_1111; current_char = digit6; end
            3'd7: begin an = 8'b0111_1111; current_char = digit7; end
            default: begin an = 8'b1111_1111; current_char = CH_BLANK; end
        endcase
    end

    wire [6:0] seg_bin2seg;

    bin2seg u_bin2seg (
        .bin (current_char[3:0]),
        .seg (seg_bin2seg)
    );

    always @(*) begin
        case (current_char)
            CH_H:     seg = 7'b100_1000;
            CH_DASH:  seg = 7'b111_1110;
            CH_BLANK: seg = 7'b111_1111;
            default:  seg = seg_bin2seg;
        endcase
    end

    assign dp = 1'b1;

endmodule
