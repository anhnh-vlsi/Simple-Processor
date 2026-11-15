`timescale 1ns/1ps

module tb_alu;

    logic [8:0] A_data;
    logic [8:0] Bus;
    logic       Addsub;
    logic [8:0] Alu_result;

    integer tests_passed;

    alu DUT (
        .A_data(A_data),
        .Bus(Bus),
        .Addsub(Addsub),
        .Alu_result(Alu_result)
    );

    task automatic check_alu(
        input logic [8:0] a_value,
        input logic [8:0] bus_value,
        input logic       addsub_value,
        input logic [8:0] expected_value
    );
        begin
            A_data = a_value;
            Bus = bus_value;
            Addsub = addsub_value;
            #1;

            if (Alu_result !== expected_value) begin
                $fatal(1,
                    "ALU FAIL: A=%0d Bus=%0d Addsub=%0b Expected=%0d Actual=%0d",
                    a_value, bus_value, addsub_value, expected_value, Alu_result);
            end

            tests_passed = tests_passed + 1;
        end
    endtask

    initial begin
    	$dumpfile("wave.vcd");
    	$dumpvars(0, tb_alu);
        tests_passed = 0;
        A_data = '0;
        Bus = '0;
        Addsub = 1'b0;

        // ADD tests: Addsub = 0.
        check_alu(9'd0,   9'd0,   1'b0, 9'd0);
        check_alu(9'd10,  9'd5,   1'b0, 9'd15);
        check_alu(9'd255, 9'd1,   1'b0, 9'd256);
        check_alu(9'd511, 9'd1,   1'b0, 9'd0);   // 9-bit overflow wraparound
        check_alu(9'd300, 9'd250, 1'b0, 9'd38);  // 550 modulo 512

        // SUB tests: Addsub = 1.
        check_alu(9'd10,  9'd3,   1'b1, 9'd7);
        check_alu(9'd3,   9'd10,  1'b1, 9'd505); // 9-bit underflow wraparound
        check_alu(9'd0,   9'd1,   1'b1, 9'd511);
        check_alu(9'd511, 9'd511, 1'b1, 9'd0);

        $display("PASS: tb_alu completed %0d test cases.", tests_passed);
        $finish;
    end

endmodule
