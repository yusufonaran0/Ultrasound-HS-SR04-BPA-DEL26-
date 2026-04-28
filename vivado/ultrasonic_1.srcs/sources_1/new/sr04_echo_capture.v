`timescale 1ns/1ps

module sr04_echo_capture (
    input  wire        clk,
    input  wire        rst,
    input  wire        echo,
    input  wire        start_meas,

    output reg [31:0]  echo_count,
    output reg         echo_done,
    output reg         echo_timeout
);

    localparam integer TIMEOUT_CYCLES = 3_000_000;

    localparam [1:0]
        IDLE       = 2'd0,
        WAIT_RISE  = 2'd1,
        COUNT_HIGH = 2'd2,
        FINISHED   = 2'd3;

    reg [1:0] current_state;
    reg [31:0] timeout_counter;

    reg echo_sync0, echo_sync1;
    reg echo_prev;

    wire echo_rise;
    wire echo_fall;

    assign echo_rise = (echo_sync1 == 1'b1) && (echo_prev == 1'b0);
    assign echo_fall = (echo_sync1 == 1'b0) && (echo_prev == 1'b1);

    always @(posedge clk) begin
        if (rst) begin
            current_state   <= IDLE;
            echo_count      <= 32'd0;
            echo_done       <= 1'b0;
            echo_timeout    <= 1'b0;
            timeout_counter <= 32'd0;
            echo_sync0      <= 1'b0;
            echo_sync1      <= 1'b0;
            echo_prev       <= 1'b0;
        end
        else begin
            echo_done    <= 1'b0;
            echo_timeout <= 1'b0;

            echo_sync0 <= echo;
            echo_sync1 <= echo_sync0;
            echo_prev  <= echo_sync1;

            case (current_state)
                IDLE: begin
                    echo_count      <= 32'd0;
                    timeout_counter <= 32'd0;

                    if (start_meas)
                        current_state <= WAIT_RISE;
                end

                WAIT_RISE: begin
                    timeout_counter <= timeout_counter + 1'b1;

                    if (echo_rise) begin
                        echo_count      <= 32'd0;
                        timeout_counter <= 32'd0;
                        current_state   <= COUNT_HIGH;
                    end
                    else if (timeout_counter >= TIMEOUT_CYCLES) begin
                        echo_timeout  <= 1'b1;
                        current_state <= IDLE;
                    end
                end

                COUNT_HIGH: begin
                    timeout_counter <= timeout_counter + 1'b1;
                    echo_count      <= echo_count + 1'b1;

                    if (echo_fall) begin
                        echo_done     <= 1'b1;
                        current_state <= FINISHED;
                    end
                    else if (timeout_counter >= TIMEOUT_CYCLES) begin
                        echo_timeout  <= 1'b1;
                        current_state <= IDLE;
                    end
                end

                FINISHED: begin
                    current_state <= IDLE;
                end

                default: begin
                    current_state <= IDLE;
                end
            endcase
        end
    end

endmodule