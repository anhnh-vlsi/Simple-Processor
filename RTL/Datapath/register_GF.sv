module register_GF (
    input  logic [8:0] FPU_result,
    input  logic       GFin,
    input  logic       Clk,
    output logic [8:0] GF_data
);

    always_ff @(posedge Clk) begin
        if (GFin)
            GF_data <= FPU_result;
    end

endmodule
