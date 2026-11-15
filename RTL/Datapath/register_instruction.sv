module register_instruction (
    input logic         IRin,
    input logic         Clk,
    input logic [8:0]   DIN,
    output logic [8:0]  IR
);

	always_ff @(posedge Clk) begin
		if (IRin) IR <= DIN;
	end

endmodule
