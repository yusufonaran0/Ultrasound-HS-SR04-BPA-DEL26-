// -----------------------------------------------------------
//! @brief Binary to 7-segment decoder (common anode, 1 digit)
//! @version 2.1
//! @copyright (c) 2018-2026 Tomas Fryza, MIT license
//!
//! This module decodes a 4-bit binary input into control signals
//! for a 7-segment common-anode display. It supports hexadecimal
//! characters.
//!
//!     --a--
//!    |     |
//!    f     b
//!    |     |
//!     --g--
//!    |     |
//!    e     c
//!    |     |
//!     --d--
//
// Notes:
// - Common anode: segment ON = 0, OFF = 1
// - No decimal point is implemented
// - Purely combinational (no clock)
// -----------------------------------------------------------

`timescale 1ns/1ps

module bin2seg (
    input  wire [3:0] bin,  //! 4-bit input
    output reg  [6:0] seg   //! {a,b,c,d,e,f,g} active-low
    // Because `o_seg` is assigned inside an always block (see
    // below), it must be declared as `reg` in Verilog. This does
    // NOT mean it becomes a flip-flop or register in hardware.
);

    //! This describes a combinational logic process.
    //! The @(*) is the sensitivity list. It means: Trigger
    //! this block whenever any signal used inside the block changes.
    always @(*) begin
        case (bin)
            4'h0: seg = 7'b000_0001;
            4'h1: seg = 7'b100_1111;
            4'h2: seg = 7'b001_0010;
            4'h3: seg = 7'b000_0110;
            4'h4: seg = 7'b100_1100;
            4'h5: seg = 7'b010_0100;
            4'h6: seg = 7'b010_0000;
            4'h7: seg = 7'b000_1111;
            4'h8: seg = 7'b000_0000;
            4'h9: seg = 7'b000_0100;
            4'hA: seg = 7'b000_1000;
            4'hB: seg = 7'b110_0000;
            4'hC: seg = 7'b011_0001;
            4'hD: seg = 7'b100_0010;
            4'hE: seg = 7'b011_0000;
            4'hF: seg = 7'b011_1000;

            default: seg = 7'b111_1111;  // Blank for safety
        endcase
    end

endmodule
