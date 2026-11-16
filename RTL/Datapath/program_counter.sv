module program_counter (
	input logic			Clk,
	input logic			Resetn,
	input logic			PCin,
	input logic 		Incr_pc,
	input logic [8:0]	Bus,
	output logic [8:0]	PC
);

	always_ff @(posedge Clk or negedge Resetn) begin
		if (!Resetn)
			PC <= 9'b0;
		else begin
			if (PCin)
				PC <= Bus;
			else if (Incr_pc)
				PC <= PC + 9'b1;
		end	
	end

endmodule
