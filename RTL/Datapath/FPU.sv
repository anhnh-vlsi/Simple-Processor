module FPU (
    input  logic [8:0] AF_data,
    input  logic [8:0] Bus,
    input  logic       AddSubF,
    output logic [8:0] FPU_result
);

    logic [4:0] exp_a;
    logic [4:0] exp_b;
    logic [4:0] exp_big;
    logic [4:0] exp_small;
    logic [4:0] exp_work;

    logic [4:0] sig_a;
    logic [4:0] sig_b;

    logic [7:0] ext_a;
    logic [7:0] ext_b;
    logic [7:0] big_ext;
    logic [7:0] small_ext;
    logic [7:0] small_shifted;
    logic [7:0] result_ext;

    logic [8:0] add_tmp;
    logic [8:0] sub_tmp;
    logic [5:0] rounded_sig;
    logic [4:0] final_sig;

    logic sign_a;
    logic sign_b;
    logic sign_big;
    logic sign_small;
    logic result_sign;
    logic round_up;

    logic [4:0] shift_amount;
    integer norm_step;

    function automatic logic [7:0] shift_right_jam(
        input logic [7:0] value,
        input logic [4:0] amount
    );
        logic [7:0] shifted;
        logic sticky;
        integer k;
        begin
            shifted = value;
            sticky = 1'b0;
            for (k = 0; k < 15; k = k + 1) begin
                if (k < amount) begin
                    sticky = sticky | shifted[0];
                    shifted = shifted >> 1;
                end
            end
            shifted[0] = shifted[0] | sticky;
            shift_right_jam = shifted;
        end
    endfunction

    always_comb begin
        exp_a = (AF_data[7:4] == 4'b0000) ? 5'd1 : {1'b0, AF_data[7:4]};
        exp_b = (Bus[7:4] == 4'b0000) ? 5'd1 : {1'b0, Bus[7:4]};

        if (AF_data[7:4] == 4'b0000)
            sig_a = {1'b0, AF_data[3:0]};
        else
            sig_a = {1'b1, AF_data[3:0]};

        if (Bus[7:4] == 4'b0000)
            sig_b = {1'b0, Bus[3:0]};
        else
            sig_b = {1'b1, Bus[3:0]};

        ext_a = {sig_a, 3'b000};
        ext_b = {sig_b, 3'b000};

        sign_a = AF_data[8];
        sign_b = Bus[8] ^ AddSubF;

        exp_big = 5'd0;
        exp_small = 5'd0;
        exp_work = 5'd0;
        big_ext = 8'd0;
        small_ext = 8'd0;
        small_shifted = 8'd0;
        result_ext = 8'd0;
        add_tmp = 9'd0;
        sub_tmp = 9'd0;
        rounded_sig = 6'd0;
        final_sig = 5'd0;
        sign_big = 1'b0;
        sign_small = 1'b0;
        result_sign = 1'b0;
        round_up = 1'b0;
        shift_amount = 5'd0;
        norm_step = 0;
        FPU_result = 9'b0;

        if ((AF_data[7:0] == 8'b0) && (Bus[7:0] == 8'b0)) begin
            FPU_result = 9'b0;
        end
        else if (AF_data[7:0] == 8'b0) begin
            FPU_result = {sign_b, Bus[7:0]};
        end
        else if (Bus[7:0] == 8'b0) begin
            FPU_result = AF_data;
        end
        else begin
            if ((exp_a > exp_b) || ((exp_a == exp_b) && (sig_a >= sig_b))) begin
                exp_big = exp_a;
                exp_small = exp_b;
                big_ext = ext_a;
                small_ext = ext_b;
                sign_big = sign_a;
                sign_small = sign_b;
            end
            else begin
                exp_big = exp_b;
                exp_small = exp_a;
                big_ext = ext_b;
                small_ext = ext_a;
                sign_big = sign_b;
                sign_small = sign_a;
            end

            shift_amount = exp_big - exp_small;
            small_shifted = shift_right_jam(small_ext, shift_amount);
            exp_work = exp_big;
            result_sign = sign_big;

            if (sign_big == sign_small) begin
                add_tmp = {1'b0, big_ext} + {1'b0, small_shifted};
                if (add_tmp[8]) begin
                    result_ext = add_tmp[8:1];
                    result_ext[0] = result_ext[0] | add_tmp[0];
                    exp_work = exp_work + 1'b1;
                end
                else begin
                    result_ext = add_tmp[7:0];
                end
            end
            else begin
                sub_tmp = {1'b0, big_ext} - {1'b0, small_shifted};
                result_ext = sub_tmp[7:0];
                for (norm_step = 0; norm_step < 4; norm_step = norm_step + 1) begin
                    if ((result_ext[7] == 1'b0) && (exp_work > 5'd1) && (result_ext != 8'b0)) begin
                        result_ext = {result_ext[6:0], 1'b0};
                        exp_work = exp_work - 1'b1;
                    end
                end
            end

            if (result_ext == 8'b0) begin
                FPU_result = 9'b0;
            end
            else begin
                round_up = result_ext[2] &&
                           (result_ext[1] || result_ext[0] || result_ext[3]);
                rounded_sig = {1'b0, result_ext[7:3]} + (round_up ? 6'd1 : 6'd0);

                if (rounded_sig[5]) begin
                    final_sig = 5'b10000;
                    exp_work = exp_work + 1'b1;
                end
                else begin
                    final_sig = rounded_sig[4:0];
                end

                if (exp_work > 5'd15) begin
                    FPU_result = {result_sign, 4'hF, 4'hF};
                end
                else if ((exp_work == 5'd1) && (final_sig[4] == 1'b0)) begin
                    FPU_result = {result_sign, 4'b0000, final_sig[3:0]};
                end
                else begin
                    FPU_result = {result_sign, exp_work[3:0], final_sig[3:0]};
                end
            end
        end
    end

endmodule
