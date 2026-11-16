module register_W (
	input logic			Clk,
	input logic 		W_D,
	output logic 		W
);

	always_ff @(posedge Clk) begin
		W <= W_D;
	end

endmodule
