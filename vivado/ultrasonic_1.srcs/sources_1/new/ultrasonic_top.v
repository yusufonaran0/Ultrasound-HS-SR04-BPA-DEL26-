`timescale 1ns/1ps

module ultrasonic_top (
    input  wire       clk,
    input  wire       btnu,
    input  wire       btnd,
    input  wire       echo,

    output wire       trig,
    output wire       buzzer,
    output wire [6:0] seg,
    output wire [7:0] an,
    output wire       dp,
    output wire [3:0] led
);

    wire        w_hold_state;
    wire        w_start_trigger;
    wire        w_trigger_done;
    wire        w_echo_done;
    wire        w_echo_timeout;
    wire        w_measuring;
    wire        w_valid_data;

    wire [31:0] w_echo_count;
    wire [15:0] w_distance_cm_raw;
    wire        w_buzzer_raw;

    reg  [15:0] r_distance_cm;
    reg         r_valid_meas;

    debounce u_debounce_hold (
        .clk   (clk),
        .rst   (btnu),
        .pin   (btnd),
        .state (w_hold_state),
        .press ()
    );

    measurement_control u_measurement_control (
        .clk           (clk),
        .rst           (btnu),
        .btn_hold      (w_hold_state),
        .trigger_done  (w_trigger_done),
        .echo_done     (w_echo_done),
        .echo_timeout  (w_echo_timeout),
        .start_trigger (w_start_trigger),
        .measuring     (w_measuring),
        .valid_data    (w_valid_data)
    );

    hs_sr04_trigger u_hs_sr04_trigger (
        .clk        (clk),
        .rst        (btnu),
        .start_meas (w_start_trigger),
        .trig       (trig),
        .done       (w_trigger_done)
    );

    sr04_echo_capture u_sr04_echo_capture (
        .clk          (clk),
        .rst          (btnu),
        .echo         (echo),
        .start_meas   (w_start_trigger),
        .echo_count   (w_echo_count),
        .echo_done    (w_echo_done),
        .echo_timeout (w_echo_timeout)
    );

    distance_converter u_distance_converter (
        .echo_count  (w_echo_count),
        .distance_cm (w_distance_cm_raw)
    );

    always @(posedge clk) begin
        if (btnu) begin
            r_distance_cm <= 16'd0;
            r_valid_meas  <= 1'b0;
        end
        else begin
            if (!w_hold_state) begin
                if (w_echo_done) begin
                    r_distance_cm <= w_distance_cm_raw;
                    r_valid_meas  <= 1'b1;
                end
                else if (w_echo_timeout) begin
                    r_valid_meas  <= 1'b0;
                end
            end
        end
    end

    display_driver u_display_driver (
        .clk         (clk),
        .rst         (btnu),
        .hold_active (w_hold_state),
        .valid_meas  (r_valid_meas),
        .distance_cm (r_distance_cm),
        .seg         (seg),
        .an          (an),
        .dp          (dp)
    );

    buzzer_control u_buzzer_control (
        .clk         (clk),
        .rst         (btnu),
        .distance_cm (r_distance_cm),
        .buzzer      (w_buzzer_raw)
    );

    assign buzzer = r_valid_meas ? w_buzzer_raw : 1'b0;

    assign led[0] = w_measuring;
    assign led[1] = w_hold_state;
    assign led[2] = r_valid_meas;
    assign led[3] = w_echo_timeout;

endmodule