module TB_SM4_KEY ();

reg clk_sys;
reg sys_rst_n;

reg sm4_start;
reg [127:0] sm4_key_in;
reg sm4_key_in_vld;

wire [31:0] key2core_rkey;
wire key2core_rkey_vld;

initial begin
    clk_sys = 1;
    sys_rst_n = 0;
    sm4_start = 1'b0;
    sm4_key_in[127:0] = 128'd0;
    sm4_key_in_vld = 1'b0;

    #20 sys_rst_n = 1;
    #10
    sm4_start <= 1'b1;
    sm4_key_in[127:0] <= 128'h0123456789abcdeffedcba9876543210;
    sm4_key_in_vld <= 1'b1;
    #2
    sm4_start <= 1'b0;
    sm4_key_in[127:0] <= 128'd0;
    sm4_key_in_vld <= 1'b0;
    #80
    $stop;
end

always #1 clk_sys = ~clk_sys;

SM4_KEY U_SM4_KEY(
    .clk_sys(clk_sys),
    .sys_rst_n(sys_rst_n),
    .sm4_start(sm4_start),
    .sm4_key_in(sm4_key_in),
    .sm4_key_in_vld(sm4_key_in_vld),
    .key2core_rkey(key2core_rkey),
    .key2core_rkey_vld(key2core_rkey_vld)
);



    
endmodule