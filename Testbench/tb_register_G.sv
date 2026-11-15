`timescale 1ns/1ps

module tb_register_G;

    logic       Gin;
    logic       Clk;
    logic [8:0] Alu_result;
    logic [8:0] G_data;

    integer tests_passed;

    register_G DUT (
        .Gin(Gin),
        .Clk(Clk),
        .Alu_result(Alu_result),
        .G_data(G_data)
    );

    always #5 Clk = ~Clk;

    task automatic apply_cycle(
        input logic       enable_value,
        input logic [8:0] result_value
    );
        begin
            @(negedge Clk);
            Gin = enable_value;
            Alu_result = result_value;
            @(posedge Clk);
            #1;
        end
    endtask

    task automatic check_G(input logic [8:0] expected_value);
        begin
            if (G_data !== expected_value) begin
                $fatal(1, "G REGISTER FAIL: Expected=%h Actual=%h",
                    expected_value, G_data);
            end
            tests_passed = tests_passed + 1;
        end
    endtask

    initial begin
        Clk = 1'b0;
        Gin = 1'b0;
        Alu_result = 9'b0;
        tests_passed = 0;

        apply_cycle(1'b1, 9'd15);
        check_G(9'd15);

        // G must retain its value while Gin is low.
        apply_cycle(1'b0, 9'd99);
        check_G(9'd15);

        // G must load the next ALU result when enabled.
        apply_cycle(1'b1, 9'h1FE);
        check_G(9'h1FE);

        apply_cycle(1'b0, 9'h001);
        check_G(9'h1FE);

        $display("PASS: tb_register_G completed %0d test cases.", tests_passed);
        $finish;
    end

endmodule
