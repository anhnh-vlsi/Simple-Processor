module register_AF (
    input  logic [8:0] Bus,
    input  logic       AFin,
    input  logic       Clk,
    output logic [8:0] AF_data
);

    always_ff @(posedge Clk) begin
        if (AFin)
            AF_data <= Bus;
    end

endmodule
