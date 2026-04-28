`timescale 1ns/1ps

module ultrasonic_top_tb;

    reg clk;
    reg btnu;
    reg btnd;
    reg echo;

    wire trig;
    wire buzzer;
    wire [6:0] seg;
    wire [7:0] an;
    wire dp;
    wire [3:0] led;

    // DUT
    ultrasonic_top uut (
        .clk    (clk),
        .btnu   (btnu),
        .btnd   (btnd),
        .echo   (echo),
        .trig   (trig),
        .buzzer (buzzer),
        .seg    (seg),
        .an     (an),
        .dp     (dp),
        .led    (led)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        btnu = 1'b1;
        btnd = 1'b0;
        echo = 1'b0;

        // reset
        #100;
        btnu = 1'b0;

        // ----------------------------------------------------
        // Measurement 1
        // Wait until trigger is generated and completed,
        // then generate echo pulse
        // ----------------------------------------------------
        #12000;
        echo = 1'b1;
        #58000;      // around 10 cm
        echo = 1'b0;

        #100000;

        // ----------------------------------------------------
        // Measurement 2
        // ----------------------------------------------------
        #12000;
        echo = 1'b1;
        #116000;     // around 20 cm
        echo = 1'b0;

        #100000;

        // ----------------------------------------------------
        // HOLD button press
        // because debounce exists, keep button high long enough
        // ----------------------------------------------------
        btnd = 1'b1;
        #200;
        btnd = 1'b1;
        #1000;

        // stay in hold
        #50000;

        // release hold
        btnd = 1'b0;
        #1000;

        // ----------------------------------------------------
        // Measurement 3 after hold release
        // ----------------------------------------------------
        #12000;
        echo = 1'b1;
        #290000;     // around 50 cm
        echo = 1'b0;

        #100000;

        // ----------------------------------------------------
        // Timeout case: no echo pulse
        // ----------------------------------------------------
        #32000000;

        #100000;

  
        
        $finish;
    end

endmodule