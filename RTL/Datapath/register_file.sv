module register_file (
    input logic         Clk,
    input logic [7:0]   Rin,
    input logic [8:0]   Bus,
    output logic [8:0]  R0,
    output logic [8:0]  R1,
    output logic [8:0]  R2,
    output logic [8:0]  R3,
    output logic [8:0]  R4,
    output logic [8:0]  R5,
    output logic [8:0]  R6,
    output logic [8:0]  R7
);

	always_ff @(posedge Clk) begin
        if (Rin[0]) R0 <= Bus;
        if (Rin[1]) R1 <= Bus;
        if (Rin[2]) R2 <= Bus;
        if (Rin[3]) R3 <= Bus;
        if (Rin[4]) R4 <= Bus;
        if (Rin[5]) R5 <= Bus;
        if (Rin[6]) R6 <= Bus;
        if (Rin[7]) R7 <= Bus;
    end

endmodule
