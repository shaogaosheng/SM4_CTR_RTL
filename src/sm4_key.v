module SM4_KEY (
    input             clk_sys,
    input             sys_rst_n,

    input             sm4_start,
    input    [127:0]  sm4_key_in,
    input             sm4_key_in_vld,

    output   reg [1023:0]   key2core_rkey,
    output   reg          key2core_rkey_vld
);

localparam IDLE          = 1'b0;
localparam KEY_EXPANSION = 1'b1;

localparam FK0 = 32'ha3b1bac6;
localparam FK1 = 32'h56aa3350;
localparam FK2 = 32'h677d9197;
localparam FK3 = 32'hb27022dc;

wire [31:0] sm4_key_in_0part; //sm4_key_in[127:96]
wire [31:0] sm4_key_in_1part; //sm4_key_in[95:64]
wire [31:0] sm4_key_in_2part; //sm4_key_in[63:32]
wire [31:0] sm4_key_in_3part; //sm4_key_in[31:0]

reg [31:0] sm4_key_0part; //sm4_key[127:96], exor(sm4_key_in[127:96], FK0)
reg [31:0] sm4_key_1part; //sm4_key[95:64]
reg [31:0] sm4_key_2part; //sm4_key[63:32]
reg [31:0] sm4_key_3part; //sm4_key[31:0]

wire [127:0] sm4_key_exp_in;
wire [31:0] sm4_rkey_out;

reg [31:0] rkey_reg_array [31:0];
reg [31:0] rkey_reg;

reg [4:0] sm4_round_cnt;
reg fsm_curr_state;
reg fsm_next_state;

wire [31:0]  sm4_key_cki;

assign    { sm4_key_in_0part,
            sm4_key_in_1part,
            sm4_key_in_2part,
            sm4_key_in_3part}    =    sm4_key_in;

//count 0~31
always @(posedge clk_sys)
begin
    if (sys_rst_n == 1'b0) begin
        sm4_round_cnt <= 5'd0;
    end 
    else if (fsm_curr_state == KEY_EXPANSION) begin
        sm4_round_cnt <= sm4_round_cnt + 1'b1;
    end
    else begin
        sm4_round_cnt <= 5'd0;
    end
end

always @(posedge clk_sys)
begin
    if (sys_rst_n == 1'b0) begin
        fsm_curr_state <= 1'b0;
    end
    else begin
        fsm_curr_state <= fsm_next_state;
    end
end

always @(*)
begin
    case (fsm_curr_state)
        IDLE: 
        if ((sm4_start == 1'b1) && (sm4_key_in_vld == 1'b1)) begin
            fsm_next_state = KEY_EXPANSION;
        end 
        else begin
            fsm_next_state = IDLE;
        end
        default:        //KEY_EXPANSION state;
        if (sm4_round_cnt == 5'd31) begin
            fsm_next_state = IDLE;
        end
        else begin
            fsm_next_state = KEY_EXPANSION;
        end
    endcase
end

always @(posedge clk_sys)
begin
    if (sys_rst_n == 1'b0) begin
        sm4_key_0part <= 32'd0;
    end
    else if ((sm4_start == 1'b1) && (sm4_key_in_vld == 1'b1)) begin
        sm4_key_0part <= sm4_key_in_0part ^ FK0;
    end
    else if (fsm_curr_state == KEY_EXPANSION) begin
        sm4_key_0part <= sm4_key_1part;
    end
    else ;
end

always @(posedge clk_sys)
begin
    if (sys_rst_n == 1'b0) begin
        sm4_key_1part <= 32'd0;
    end
    else if ((sm4_start == 1'b1) && (sm4_key_in_vld == 1'b1)) begin
        sm4_key_1part <= sm4_key_in_1part ^ FK1;
    end
    else if (fsm_curr_state == KEY_EXPANSION) begin
        sm4_key_1part <= sm4_key_2part;
    end
    else ;
end

always @(posedge clk_sys)
begin
    if (sys_rst_n == 1'b0) begin
        sm4_key_2part <= 32'd0;
    end
    else if ((sm4_start == 1'b1) && (sm4_key_in_vld == 1'b1)) begin
        sm4_key_2part <= sm4_key_in_2part ^ FK2;
    end
    else if (fsm_curr_state == KEY_EXPANSION) begin
        sm4_key_2part <= sm4_key_3part;
    end
    else ;
end

always @(posedge clk_sys)
begin
    if (sys_rst_n == 1'b0) begin
        sm4_key_3part <= 32'd0;
    end
    else if ((sm4_start == 1'b1) && (sm4_key_in_vld == 1'b1)) begin
        sm4_key_3part <= sm4_key_in_3part ^ FK3;
    end
    else if (fsm_curr_state == KEY_EXPANSION) begin
        sm4_key_3part <= sm4_rkey_out;
    end
    else ;
end

assign sm4_key_exp_in = {sm4_key_0part,sm4_key_1part,sm4_key_2part,sm4_key_3part};

genvar i;
generate
    for (i = 0; i<32; i=i+1) begin : rkey_men
        always @(posedge clk_sys)
        begin
            if (sys_rst_n == 1'b0) begin
                rkey_reg_array[i] <= 32'd0;
            end
            else if ((sm4_round_cnt == i) && (fsm_curr_state == KEY_EXPANSION)) begin
                rkey_reg_array[i] <= sm4_rkey_out;
            end
            else ;
        end
    end
endgenerate


always @(posedge clk_sys)
begin
    if (sys_rst_n == 1'b0) begin
        key2core_rkey_vld <= 1'b0;
    end
    else if (sm4_round_cnt == 5'd31) begin
        key2core_rkey_vld <= 1'b1;
    end
    else if ((sm4_start == 1'b1) && (sm4_key_in_vld == 1'b1)) begin
        key2core_rkey_vld <= 1'b0;
    end
    else ;
end


SM4_KEY_CKI U_SM4_KEY_CKI(
    .clk_sys(clk_sys),
    .sm4_round_cnt(sm4_round_cnt),
    .sm4_key_cki(sm4_key_cki)
);

SM4_KEY_EXP_ONE_ROUND U_SM4_KEY_EXP_ONE_ROUND(
    .sm4_key_exp_in(sm4_key_exp_in),
    .sm4_key_cki(sm4_key_cki),
    .sm4_rkey_out(sm4_rkey_out)
);
    
endmodule