`timescale 1ns/1ps

module buzzer_control (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] distance_cm,
    output reg         buzzer
);

    reg [31:0] counter;
    reg [31:0] threshold;

    always @(*) begin
        if (distance_cm > 16'd100)
            threshold = 32'd0;
        else if (distance_cm > 16'd50)
            threshold = 32'd5_000_000;
        else if (distance_cm > 16'd20)
            threshold = 32'd2_000_000;
        else if (distance_cm > 16'd5)
            threshold = 32'd800_000;
        else
            threshold = 32'd1;
    end

    always @(posedge clk) begin
        if (rst) begin
            counter <= 32'd0;
            buzzer  <= 1'b0;
        end
        else begin
            if (threshold == 32'd0) begin
                buzzer  <= 1'b0;
                counter <= 32'd0;
            end
            else if (threshold == 32'd1) begin
                buzzer  <= 1'b1;
                counter <= 32'd0;
            end
            else begin
                if (counter >= threshold) begin
                    buzzer  <= ~buzzer;
                    counter <= 32'd0;
                end
                else begin
                    counter <= counter + 1'b1;
                end
            end
        end
    end

endmodule