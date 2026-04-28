`timescale 1ns/1ps

module hs_sr04_trigger (
    input  wire clk,
    input  wire rst,
    input  wire start_meas,
    output reg  trig,
    output reg  done
);

    localparam integer TRIG_CYCLES = 1000;
    localparam integer CNT_WIDTH   = 10;

    reg [CNT_WIDTH-1:0] cnt;
    reg active;

    always @(posedge clk) begin
        if (rst) begin
            trig   <= 1'b0;
            done   <= 1'b0;
            cnt    <= {CNT_WIDTH{1'b0}};
            active <= 1'b0;
        end
        else begin
            done <= 1'b0;

            if (!active) begin
                trig <= 1'b0;
                cnt  <= {CNT_WIDTH{1'b0}};

                if (start_meas) begin
                    active <= 1'b1;
                    trig   <= 1'b1;
                    cnt    <= {{(CNT_WIDTH-1){1'b0}}, 1'b1};
                end
            end
            else begin
                if (cnt < TRIG_CYCLES) begin
                    trig <= 1'b1;
                    cnt  <= cnt + 1'b1;
                end
                else begin
                    trig   <= 1'b0;
                    done   <= 1'b1;
                    active <= 1'b0;
                    cnt    <= {CNT_WIDTH{1'b0}};
                end
            end
        end
    end

endmodule