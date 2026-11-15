module register_A (
    input logic [8:0]   Bus,
    input logic         Ain,
    input logic         Clk,
    output logic [8:0]  A_data
);

	always_ff @(posedge Clk) begin
		if (Ain) A_data <= Bus;
	end

endmodule
