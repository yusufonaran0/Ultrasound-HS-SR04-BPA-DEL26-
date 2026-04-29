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

    //UPADATED FOR IMPLEMENT.  60 ms waiting interval between two measurements at 100 MHz: 
    // 100_000_000 Hz * 0.060 s = 6_000_000 clock cycles
    localparam integer MEAS_INTERVAL_CYCLES = 6_000_000;

    localparam [2:0]
        IDLE          = 3'd0,
        TRIGGER       = 3'd1,
        WAIT_ECHO     = 3'd2,
        DONE          = 3'd3,
        HOLD          = 3'd4,
        WAIT_INTERVAL = 3'd5;

    reg [2:0]  current_state;
    reg [22:0] interval_counter; // enough for 0..6,000,000

    always @(posedge clk) begin
        if (rst) begin
            current_state    <= IDLE;
            interval_counter <= 23'd0;
            start_trigger    <= 1'b0;
            measuring        <= 1'b0;
            valid_data       <= 1'b0;
        end
        else begin
            start_trigger <= 1'b0;
            valid_data    <= 1'b0;

            case (current_state)

                IDLE: begin
                    measuring        <= 1'b0;
                    interval_counter <= 23'd0;

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

                    if (trigger_done) begin
                        current_state <= WAIT_ECHO;
                    end
                end

                WAIT_ECHO: begin
                    measuring <= 1'b1;

                    if (echo_done || echo_timeout) begin
                        valid_data       <= 1'b1;
                        interval_counter <= 23'd0;
                        current_state    <= DONE;
                    end
                end

                DONE: begin
                    measuring <= 1'b0;

                    if (btn_hold) begin
                        current_state <= HOLD;
                    end
                    else begin
                        interval_counter <= 23'd0;
                        current_state    <= WAIT_INTERVAL;
                    end
                end

                WAIT_INTERVAL: begin
                    measuring <= 1'b0;

                    if (btn_hold) begin
                        interval_counter <= 23'd0;
                        current_state    <= HOLD;
                    end
                    else if (interval_counter >= MEAS_INTERVAL_CYCLES - 1) begin
                        interval_counter <= 23'd0;
                        start_trigger    <= 1'b1;
                        current_state    <= TRIGGER;
                    end
                    else begin
                        interval_counter <= interval_counter + 1'b1;
                    end
                end

                HOLD: begin
                    measuring        <= 1'b0;
                    interval_counter <= 23'd0;

                    if (!btn_hold) begin
                        start_trigger <= 1'b1;
                        current_state <= TRIGGER;
                    end
                end

                default: begin
                    current_state    <= IDLE;
                    interval_counter <= 23'd0;
                    start_trigger    <= 1'b0;
                    measuring        <= 1'b0;
                    valid_data       <= 1'b0;
                end

            endcase
        end
    end

endmodule
