module register_A (
    input logic [8:0]   Bus,
    input logic         Ain,
    input logic         Clock,
    output logic [8:0]  A_data
);

	always_ff @(posedge Clock) begin
		if (Ain) A_data <= Bus;
	end

endmodule
