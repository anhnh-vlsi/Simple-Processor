module register_ADDR (
	input logic 		Clk,
	input logic 		ADDRin,
	input logic [8:0]	Bus,
	output logic [8:0]	ADDR
);

	always_ff @(posedge Clk) begin
		if (ADDRin) 
			ADDR <= Bus;
	end

endmodule
