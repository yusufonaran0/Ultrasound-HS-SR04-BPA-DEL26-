// -----------------------------------------------------------
//! @brief N-bit synchronous up counter with enable
//! @version 2.1
//! @copyright (c) 2019-2026 Tomas Fryza, MIT license
//!
//! This design implements a parameterizable N-bit binary up
//! counter with synchronous, high-active reset and clock
//! enable input. The counter wraps around to zero after
//! reaching its maximum value (2^N − 1).
//
// Notes:
// - Synchronous design (positive edge of clk)
// - High-active synchronous reset
// - Enable input controls counting
// - Modulo 2^N operation (automatic wrap-around)
// -----------------------------------------------------------

`timescale 1ns/1ps

module counter #(
    // "#()" after a module name introduces a parameter list
    parameter N = 3  //! Number of bits for the counter
)(
    input  wire clk,         //! Main clock
    input  wire rst,         //! High-active synchronous reset
    input  wire en,          //! Clock enable
    output reg  [N-1:0] cnt  //! Counter value
);

    //! Clocked, sequential process, triggered when clk rises
    //! from 0 to 1 (positive edge of a signal)
    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;  // Reset counter; non-blocking assignment (<=)
        end
        else if (en) begin
            cnt <= cnt + 1'b1;  // Increment counter when enabled
        end
    end

endmodule
