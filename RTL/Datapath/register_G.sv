module register_G (
    input logic         Gin,
    input logic         Clk,
    input logic [8:0]   Alu_result,
    output logic [8:0]  G_data
);

	always_ff @(posedge Clk) begin
		if (Gin) G_data <= Alu_result;
	end

endmodule
