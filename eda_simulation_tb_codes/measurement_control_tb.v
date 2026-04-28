`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
    reg btn_hold;
    reg trigger_done;
    reg echo_done;
    reg echo_timeout;

    wire start_trigger;
    wire measuring;
    wire valid_data;

    measurement_control dut (
        .clk(clk),
        .rst(rst),
        .btn_hold(btn_hold),
        .trigger_done(trigger_done),
        .echo_done(echo_done),
        .echo_timeout(echo_timeout),
        .start_trigger(start_trigger),
        .measuring(measuring),
        .valid_data(valid_data)
    );

    always #5 clk = ~clk;

    task pulse_trigger_done;
        begin
            @(posedge clk); trigger_done = 1;
            @(posedge clk); trigger_done = 0;
        end
    endtask

    task pulse_echo_done;
        begin
            @(posedge clk); echo_done = 1;
            @(posedge clk); echo_done = 0;
        end
    endtask

    task pulse_timeout;
        begin
            @(posedge clk); echo_timeout = 1;
            @(posedge clk); echo_timeout = 0;
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        rst = 1;
        btn_hold = 0;
        trigger_done = 0;
        echo_done = 0;
        echo_timeout = 0;

        #30;
        rst = 0;

        // Normal measurement cycle
        repeat (3) @(posedge clk);
        pulse_trigger_done();

        repeat (5) @(posedge clk);
        pulse_echo_done();

        repeat (3) @(posedge clk);

        // Hold mode test
        btn_hold = 1;
        repeat (5) @(posedge clk);

        // Release hold
        btn_hold = 0;
        repeat (3) @(posedge clk);
        pulse_trigger_done();

        repeat (5) @(posedge clk);
        pulse_timeout();

        repeat (5) @(posedge clk);

        $display("measurement_control FSM test finished.");
        $finish;
    end

endmodule
