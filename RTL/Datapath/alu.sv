module alu (
    input logic [8:0]   A_data,
    input logic [8:0]   Bus,
    input logic         Addsub,
    output logic [8:0]  Alu_result
);

// Addsub = 0 : + otherwise -

	assign Alu_result = Addsub ? A_data - Bus : A_data + Bus;

endmodule
