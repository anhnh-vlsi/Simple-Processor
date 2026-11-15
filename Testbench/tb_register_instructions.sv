`timescale 1ns/1ps

module tb_register_instruction;

    logic       IRin;
    logic       Clk;
    logic [8:0] DIN;
    logic [8:0] IR;

    integer tests_passed;

    register_instruction DUT (
        .IRin(IRin),
        .Clk(Clk),
        .DIN(DIN),
        .IR(IR)
    );

    always #5 Clk = ~Clk;

    task automatic apply_cycle(
        input logic       enable_value,
        input logic [8:0] instruction_value
    );
        begin
            @(negedge Clk);
            IRin = enable_value;
            DIN = instruction_value;
            @(posedge Clk);
            #1;
        end
    endtask

    task automatic check_IR(input logic [8:0] expected_value);
        begin
            if (IR !== expected_value) begin
                $fatal(1, "IR FAIL: Expected=%h Actual=%h",
                    expected_value, IR);
            end
            tests_passed = tests_passed + 1;
        end
    endtask

    initial begin
        Clk = 1'b0;
        IRin = 1'b0;
        DIN = 9'b0;
        tests_passed = 0;

        // Load the first instruction.
        apply_cycle(1'b1, 9'b001_000_000);
        check_IR(9'b001_000_000);

        // IR must hold its instruction when IRin is low.
        apply_cycle(1'b0, 9'b010_001_010);
        check_IR(9'b001_000_000);

        // Load a different instruction.
        apply_cycle(1'b1, 9'b011_111_000);
        check_IR(9'b011_111_000);

        // Check hold behavior again.
        apply_cycle(1'b0, 9'b000_000_000);
        check_IR(9'b011_111_000);

        $display("PASS: tb_register_instruction completed %0d test cases.", tests_passed);
        $finish;
    end

endmodule
