`timescale 1ns/1ps

module tb_multiplexer;

    logic       DINout;
    logic       Gout;
    logic [7:0] Rout;

    logic [8:0] DIN;
    logic [8:0] G_data;
    logic [8:0] R0, R1, R2, R3;
    logic [8:0] R4, R5, R6, R7;
    logic [8:0] Bus;

    integer tests_passed;
    integer i;

    multiplexer DUT (
        .DINout(DINout),
        .Gout(Gout),
        .Rout(Rout),
        .DIN(DIN),
        .G_data(G_data),
        .R0(R0), .R1(R1), .R2(R2), .R3(R3),
        .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .Bus(Bus)
    );

    task automatic check_bus(input logic [8:0] expected_value);
        begin
            #1;
            if (Bus !== expected_value) begin
                $fatal(1,
                    "MUX FAIL: Rout=%b Gout=%b DINout=%b Expected=%h Actual=%h",
                    Rout, Gout, DINout, expected_value, Bus);
            end
            tests_passed = tests_passed + 1;
        end
    endtask

    initial begin
        tests_passed = 0;

        DIN = 9'h101;
        G_data = 9'h155;
        R0 = 9'h010;
        R1 = 9'h021;
        R2 = 9'h032;
        R3 = 9'h043;
        R4 = 9'h054;
        R5 = 9'h065;
        R6 = 9'h076;
        R7 = 9'h087;

        DINout = 1'b0;
        Gout = 1'b0;
        Rout = 8'b0;
        check_bus(9'b0); // No source selected.

        // Verify each register input using one-hot Rout.
        for (i = 0; i < 8; i = i + 1) begin
            Rout = 8'b0000_0001 << i;
            check_bus(9'h010 + (9'h011 * i));
        end

        // Verify the G input.
        Rout = 8'b0;
        Gout = 1'b1;
        check_bus(G_data);

        // Verify the external DIN input.
        Gout = 1'b0;
        DINout = 1'b1;
        check_bus(DIN);

        // Invalid multi-hot register selection falls through to default zero.
        DINout = 1'b0;
        Rout = 8'b0000_0011;
        check_bus(9'b0);

        $display("PASS: tb_multiplexer completed %0d test cases.", tests_passed);
        $finish;
    end

endmodule
