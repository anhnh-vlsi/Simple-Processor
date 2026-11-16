module register_DOUT (
	input logic 		Clk,
	input logic 		DOUTin,
	input logic [8:0]	Bus,
	output logic [8:0]	DOUT
);

	always_ff @(posedge Clk) begin
		if (DOUTin)
			DOUT <= Bus;
	end

endmodule
