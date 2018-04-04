module  ir_decode(
        input                   clk                     ,
        input                   rst_n                   ,
        //ir
        input                   ir_din                  ,
        output  reg   [31: 0]   ir_dout                 ,
        output  reg             ir_dout_vld 
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
//编码方式：引导码(9ms低电平)+地址码(16位)+数据码(8位)+数据反码(8位)
//数据"0" = 0.56ms低 + 0.56ms高；数据 "1" = 0.56ms低 + 1.68ms高   
//注意：在实际检测的时候高电平和低电平是反过来的，因为经过接收头后会反过来。上
//面的是按照接受端描述的，所以发射端跟这个是相反的。
parameter   MIN_9MS     =       19'd325_000                     ;//6.5ms
parameter   MAX_9MS     =       19'd495_000                     ;//9.9ms
parameter   MIN_4_5MS   =       19'd152_500                     ;//3.05ms
parameter   MAX_4_5MS   =       19'd277_500                     ;//5.55ms
parameter   MIN_560US   =       19'd20_000                      ;//400us
parameter   MAX_560US   =       19'd35_000                      ;//700us
parameter   MIN_1690US  =       19'd75_000                      ;//1500us
parameter   MAX_1690US  =       19'd90_000                      ;//1800us

parameter   IDLE        =       4'b0001                         ;
parameter   CHECK_T9MS  =       4'b0010                         ;
parameter   CHECK_T4_5MS=       4'b0100                         ;
parameter   DATA_DECODE =       4'b1000                         ;

reg     [ 3: 0]                 state_c                         ;
reg     [ 3: 0]                 state_n                         ;

reg     [ 3: 0]                 ir_din_r                        ;
wire                            ir_l2h                          ;
wire                            ir_h2l                          ; 

reg     [18: 0]                 cnt_clk                         ; 
wire                            add_cnt_clk                     ;
wire                            end_cnt_clk                     ; 
reg     [31: 0]                 cnt_data                        ;
wire                            add_cnt_data                    ;
wire                            end_cnt_data                    ;

wire                            check_9ms_start                 ;
wire                            check_4_5ms_start               ;
wire                            data_decode_start               ;
wire                            idle_start                      ; 

wire                            check_9ms_ok                    ; 
wire                            check_4_5ms_ok                  ; 
wire                            check_560us_ok                  ; 
wire                            check_1690us_ok                 ; 



//======================================================================
// ***************      Main    Code    ****************
//======================================================================
//ir_din_r
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            ir_din_r    <=      'd0;
        else
            ir_din_r    <=      {ir_din_r[2:0],ir_din};//打4拍，前3拍是为了做异步处理，防止
end

assign  ir_h2l      =       (!ir_din_r[2]) && ir_din_r[3];
assign  ir_l2h      =       ir_din_r[2] && (!ir_din_r[3]);

//cnt_clk
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_clk <= 0;
    end
    else if(add_cnt_clk)begin
        if(end_cnt_clk)
            cnt_clk <= 0;
        else
            cnt_clk <= cnt_clk + 1;
    end
end

assign  add_cnt_clk     =       (state_c != IDLE); //只要不在空闲状态，就一直加，用来统计高低电平时间      
assign  end_cnt_clk     =       add_cnt_clk && (ir_h2l || ir_l2h);  //不在空闲状态，遇到上升沿或者下降沿就清空 

assign  check_9ms_ok    =       (state_c == CHECK_T9MS) && (cnt_clk >= MIN_9MS) && (cnt_clk <= MAX_9MS);  //6.5-9.9ms则算他们满足
assign  check_4_5ms_ok  =       (state_c == CHECK_T4_5MS) && (cnt_clk >= MIN_4_5MS) && (cnt_clk <= MAX_4_5MS);
assign  check_560us_ok  =       (state_c == DATA_DECODE) && (cnt_clk >= MIN_560US) && (cnt_clk <= MAX_560US);
assign  check_1690us_ok =       (state_c == DATA_DECODE) && (cnt_clk >= MIN_1690US) && (cnt_clk <= MAX_1690US);



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= IDLE;
    end
    else begin
        state_c <= state_n;
    end
end


always@(*)begin
    case(state_c)
        IDLE:begin
            if(check_9ms_start)begin //平时为高，所以检测到下降沿则进入下一个状态
                state_n = CHECK_T9MS;
            end
            else begin
                state_n = state_c;
            end
        end
        CHECK_T9MS:begin
            if(check_4_5ms_start)begin  // 上升沿来了，并且低电平时间满足要求，则进入下一个状态
                state_n = CHECK_T4_5MS;
            end
            else if(ir_l2h && (!check_9ms_ok))begin // 上升沿来了，并且低电平时间不满足要求，则进入空闲状态
                state_n = IDLE;
            end
            else begin
                state_n = state_c;  //保存状态不变，等待上升沿
            end
        end
        CHECK_T4_5MS:begin
            if(data_decode_start)begin 
                state_n = DATA_DECODE;
            end
            else if(ir_h2l && (!check_4_5ms_ok))begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        DATA_DECODE:begin
            if(idle_start)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        default:begin
            state_n = IDLE;
        end
    endcase
end

assign  check_9ms_start         =       (state_c == IDLE) && ir_h2l;
assign  check_4_5ms_start       =       (state_c == CHECK_T9MS) && ir_l2h && check_9ms_ok;
assign  data_decode_start       =       (state_c == CHECK_T4_5MS) && ir_h2l && check_4_5ms_ok;
assign  idle_start              =       (state_c == DATA_DECODE) && ((ir_l2h && !check_560us_ok) || (ir_h2l && !check_560us_ok && !check_1690us_ok) || ir_dout_vld);



//cnt_data
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_data <= 0;
    end
    else if(add_cnt_data)begin
        if(end_cnt_data)
            cnt_data <= 0;
        else
            cnt_data <= cnt_data + 1;
    end
end

assign add_cnt_data = (state_c == DATA_DECODE) && ir_h2l;//最后会有一位停止位，所以最后一个数据是可以有效接受的，这个地方注意一下
assign end_cnt_data = ((state_c == DATA_DECODE) && ((ir_l2h && !check_560us_ok) || (ir_h2l && !check_560us_ok && !check_1690us_ok))) || (add_cnt_data && (cnt_data == 32-1));   

//ir_dout_vld
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            ir_dout_vld     <=      1'b0;
        else if(add_cnt_data && (cnt_data == 32-1))
            ir_dout_vld     <=      1'b1;
        else
            ir_dout_vld     <=      1'b0;
end

//ir_dout
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            ir_dout     <=      'd0;
        else if(add_cnt_data)
            if(check_560us_ok)
                ir_dout[cnt_data]   <=      1'b0;
            else if(check_1690us_ok)
                ir_dout[cnt_data]   <=      1'b1;
end







endmodule
