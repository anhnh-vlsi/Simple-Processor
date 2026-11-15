`timescale 1ns/1ps

module tb_register_file;

    logic       Clk;
    logic [7:0] Rin;
    logic [8:0] Bus;

    logic [8:0] R0, R1, R2, R3;
    logic [8:0] R4, R5, R6, R7;

    logic [8:0] expected [0:7];
    integer tests_passed;
    integer i;

    register_file DUT (
        .Clk(Clk),
        .Rin(Rin),
        .Bus(Bus),
        .R0(R0), .R1(R1), .R2(R2), .R3(R3),
        .R4(R4), .R5(R5), .R6(R6), .R7(R7)
    );

    always #5 Clk = ~Clk;

    task automatic write_register(
        input integer     register_index,
        input logic [8:0] data_value
    );
        begin
            @(negedge Clk);
            Rin = 8'b0000_0001 << register_index;
            Bus = data_value;
            @(posedge Clk);
            #1;
            expected[register_index] = data_value;
        end
    endtask

    task automatic check_register(input integer register_index);
        begin
            case (register_index)
                0: if (R0 !== expected[0]) $fatal(1, "R0 FAIL: expected=%h actual=%h", expected[0], R0);
                1: if (R1 !== expected[1]) $fatal(1, "R1 FAIL: expected=%h actual=%h", expected[1], R1);
                2: if (R2 !== expected[2]) $fatal(1, "R2 FAIL: expected=%h actual=%h", expected[2], R2);
                3: if (R3 !== expected[3]) $fatal(1, "R3 FAIL: expected=%h actual=%h", expected[3], R3);
                4: if (R4 !== expected[4]) $fatal(1, "R4 FAIL: expected=%h actual=%h", expected[4], R4);
                5: if (R5 !== expected[5]) $fatal(1, "R5 FAIL: expected=%h actual=%h", expected[5], R5);
                6: if (R6 !== expected[6]) $fatal(1, "R6 FAIL: expected=%h actual=%h", expected[6], R6);
                7: if (R7 !== expected[7]) $fatal(1, "R7 FAIL: expected=%h actual=%h", expected[7], R7);
                default: $fatal(1, "Invalid register index: %0d", register_index);
            endcase
            tests_passed = tests_passed + 1;
        end
    endtask

    task automatic check_all_registers;
        integer j;
        begin
            for (j = 0; j < 8; j = j + 1)
                check_register(j);
        end
    endtask

    initial begin
        Clk = 1'b0;
        Rin = 8'b0;
        Bus = 9'b0;
        tests_passed = 0;

        for (i = 0; i < 8; i = i + 1)
            expected[i] = 9'bx;

        // Initialize each register using its one-hot write enable.
        for (i = 0; i < 8; i = i + 1)
            write_register(i, 9'h020 + (9'h011 * i));

        Rin = 8'b0;
        check_all_registers();

        // No register may change when all write enables are low.
        @(negedge Clk);
        Rin = 8'b0;
        Bus = 9'h1FF;
        @(posedge Clk);
        #1;
        check_all_registers();

        // Update only R3; all other registers must retain their values.
        write_register(3, 9'h1A5);
        Rin = 8'b0;
        check_all_registers();

        $display("PASS: tb_register_file completed %0d register checks.", tests_passed);
        $finish;
    end

endmodule
