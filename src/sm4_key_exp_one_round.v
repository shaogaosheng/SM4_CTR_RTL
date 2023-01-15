module SM4_KEY_EXP_ONE_ROUND(
    input         [127 : 0]    sm4_key_exp_in,
    input         [31  : 0]    sm4_key_cki,
    output  wire  [31  : 0]    sm4_rkey_out
);

wire [31:0] sm4_key_exp_in_0part;
wire [31:0] sm4_key_exp_in_1part;
wire [31:0] sm4_key_exp_in_2part;
wire [31:0] sm4_key_exp_in_3part;

wire [31:0] sm4_key_exp_sbox_in;
wire [31:0] sm4_key_exp_sbox_out;

wire [7:0]  sm4_key_exp_sbox_in_0part;
wire [7:0]  sm4_key_exp_sbox_in_1part;
wire [7:0]  sm4_key_exp_sbox_in_2part;
wire [7:0]  sm4_key_exp_sbox_in_3part;

wire [7:0]  sm4_key_exp_sbox_out_0part;
wire [7:0]  sm4_key_exp_sbox_out_1part;
wire [7:0]  sm4_key_exp_sbox_out_2part;
wire [7:0]  sm4_key_exp_sbox_out_3part;

wire [31:0] sm4_key_exp_sbox_out_left_shift_13bit;
wire [31:0] sm4_key_exp_sbox_out_left_shift_23bit;
wire [31:0] sm4_key_exp_shift_out;

assign    { sm4_key_exp_in_0part,
            sm4_key_exp_in_1part,
            sm4_key_exp_in_2part,
            sm4_key_exp_in_3part}    =    sm4_key_exp_in;

assign sm4_key_exp_sbox_in   = sm4_key_exp_in_1part ^ sm4_key_exp_in_2part ^ sm4_key_exp_in_3part ^ sm4_key_cki;

assign    { sm4_key_exp_sbox_in_0part,
            sm4_key_exp_sbox_in_1part,
            sm4_key_exp_sbox_in_2part,
            sm4_key_exp_sbox_in_3part}    =    sm4_key_exp_sbox_in;

assign sm4_key_exp_sbox_out  = {sm4_key_exp_sbox_out_0part, sm4_key_exp_sbox_out_1part, sm4_key_exp_sbox_out_2part, sm4_key_exp_sbox_out_3part};

assign sm4_key_exp_sbox_out_left_shift_13bit = {sm4_key_exp_sbox_out[18:0], sm4_key_exp_sbox_out[31:19]};
assign sm4_key_exp_sbox_out_left_shift_23bit = {sm4_key_exp_sbox_out[8:0], sm4_key_exp_sbox_out[31:9]};
assign sm4_key_exp_shift_out = sm4_key_exp_sbox_out ^ sm4_key_exp_sbox_out_left_shift_13bit ^ sm4_key_exp_sbox_out_left_shift_23bit;

assign sm4_rkey_out = sm4_key_exp_shift_out ^ sm4_key_exp_in_0part;

SM4_SBOX U0_SM4_SBOX(
	.sm4_box_in (sm4_key_exp_sbox_in_0part),
	.sm4_box_out (sm4_key_exp_sbox_out_0part)
);

SM4_SBOX U1_SM4_SBOX(
	.sm4_box_in (sm4_key_exp_sbox_in_1part),
	.sm4_box_out (sm4_key_exp_sbox_out_1part)
);

SM4_SBOX U2_SM4_SBOX(
	.sm4_box_in (sm4_key_exp_sbox_in_2part),
	.sm4_box_out (sm4_key_exp_sbox_out_2part)
);

SM4_SBOX U3_SM4_SBOX(
	.sm4_box_in (sm4_key_exp_sbox_in_3part),
	.sm4_box_out (sm4_key_exp_sbox_out_3part)
);

endmodule