`timescale 1ns/1ps

module debounce (
    input  wire clk,
    input  wire rst,
    input  wire pin,
    output wire state,
    output wire press
);

    localparam integer SHIFT_LEN = 4;
    localparam integer MAX       = 2;   // simulation value

    wire ce_sample;
    reg  sync0, sync1;
    reg  [SHIFT_LEN-1:0] shift_reg;
    reg  debounced, delayed;

    wire [SHIFT_LEN-1:0] next_shift;
    assign next_shift = {shift_reg[SHIFT_LEN-2:0], sync1};

    clk_en #(
        .MAX(MAX)
    ) clock_inst (
        .clk(clk),
        .rst(rst),
        .ce (ce_sample)
    );

    always @(posedge clk) begin
        if (rst) begin
            sync0     <= 1'b0;
            sync1     <= 1'b0;
            shift_reg <= {SHIFT_LEN{1'b0}};
            debounced <= 1'b0;
            delayed   <= 1'b0;
        end
        else begin
            sync0 <= pin;
            sync1 <= sync0;

            if (ce_sample) begin
                shift_reg <= next_shift;

                if (&next_shift)
                    debounced <= 1'b1;
                else if (~|next_shift)
                    debounced <= 1'b0;
            end

            delayed <= debounced;
        end
    end

    assign state = debounced;
    assign press = debounced & ~delayed;

endmodule