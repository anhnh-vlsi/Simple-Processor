`timescale 1ns/1ps

module tb_register_A;

    logic [8:0] Bus;
    logic       Ain;
    logic       Clock;
    logic [8:0] A_data;

    integer tests_passed;

    register_A DUT (
        .Bus(Bus),
        .Ain(Ain),
        .Clock(Clock),
        .A_data(A_data)
    );

    always #5 Clock = ~Clock;

    task automatic apply_cycle(
        input logic       enable_value,
        input logic [8:0] bus_value
    );
        begin
            @(negedge Clock);
            Ain = enable_value;
            Bus = bus_value;
            @(posedge Clock);
            #1;
        end
    endtask

    task automatic check_A(input logic [8:0] expected_value);
        begin
            if (A_data !== expected_value) begin
                $fatal(1, "A REGISTER FAIL: Expected=%h Actual=%h",
                    expected_value, A_data);
            end
            tests_passed = tests_passed + 1;
        end
    endtask

    initial begin
        Clock = 1'b0;
        Ain = 1'b0;
        Bus = 9'b0;
        tests_passed = 0;

        // Load data when Ain is asserted.
        apply_cycle(1'b1, 9'd25);
        check_A(9'd25);

        // A must retain its value when Ain is deasserted.
        apply_cycle(1'b0, 9'd100);
        check_A(9'd25);

        // A must accept a new value on a later enabled clock edge.
        apply_cycle(1'b1, 9'h1A5);
        check_A(9'h1A5);

        // Check that another disabled cycle still holds the value.
        apply_cycle(1'b0, 9'h055);
        check_A(9'h1A5);

        $display("PASS: tb_register_A completed %0d test cases.", tests_passed);
        $finish;
    end

endmodule
