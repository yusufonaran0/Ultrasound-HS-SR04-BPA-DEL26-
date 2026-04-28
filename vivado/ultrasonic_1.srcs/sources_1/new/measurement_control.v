`timescale 1ns/1ps

module measurement_control (
    input  wire clk,
    input  wire rst,
    input  wire btn_hold,
    input  wire trigger_done,
    input  wire echo_done,
    input  wire echo_timeout,

    output reg  start_trigger,
    output reg  measuring,
    output reg  valid_data
);

    localparam [2:0]
        IDLE      = 3'd0,
        TRIGGER   = 3'd1,
        WAIT_ECHO = 3'd2,
        DONE      = 3'd3,
        HOLD      = 3'd4;

    reg [2:0] current_state;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= IDLE;
            start_trigger <= 1'b0;
            measuring     <= 1'b0;
            valid_data    <= 1'b0;
        end
        else begin
            start_trigger <= 1'b0;
            valid_data    <= 1'b0;

            case (current_state)
                IDLE: begin
                    measuring <= 1'b0;

                    if (!btn_hold) begin
                        start_trigger <= 1'b1;
                        current_state <= TRIGGER;
                    end
                    else begin
                        current_state <= HOLD;
                    end
                end

                TRIGGER: begin
                    measuring <= 1'b1;

                    if (trigger_done)
                        current_state <= WAIT_ECHO;
                end

                WAIT_ECHO: begin
                    measuring <= 1'b1;

                    if (echo_done || echo_timeout) begin
                        valid_data    <= 1'b1;
                        current_state <= DONE;
                    end
                end

                DONE: begin
                    measuring <= 1'b0;

                    if (btn_hold) begin
                        current_state <= HOLD;
                    end
                    else begin
                        start_trigger <= 1'b1;
                        current_state <= TRIGGER;
                    end
                end

                HOLD: begin
                    measuring <= 1'b0;

                    if (!btn_hold) begin
                        start_trigger <= 1'b1;
                        current_state <= TRIGGER;
                    end
                end

                default: begin
                    current_state <= IDLE;
                    measuring     <= 1'b0;
                end
            endcase
        end
    end

endmodule