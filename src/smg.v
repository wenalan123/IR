module  smg(
        input                   clk                     ,
        input                   rst_n                   ,
        //ir
        input         [31: 0]   ir_data                 ,
        input                   ir_data_vld             ,
        //smg
        output  wire  [ 6: 0]   HEX0                    ,
        output  wire  [ 6: 0]   HEX1                    ,
        output  wire  [ 6: 0]   HEX2                    ,
        output  wire  [ 6: 0]   HEX3                    ,
        output  wire  [ 6: 0]   HEX4                    ,
        output  wire  [ 6: 0]   HEX5                    ,
        output  wire  [ 6: 0]   HEX6                    ,
        output  wire  [ 6: 0]   HEX7                    
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
reg     [ 3: 0]                 hex_in0                         ;
reg     [ 3: 0]                 hex_in1                         ;
reg     [ 3: 0]                 hex_in2                         ;
reg     [ 3: 0]                 hex_in3                         ;
reg     [ 3: 0]                 hex_in4                         ;
reg     [ 3: 0]                 hex_in5                         ;
reg     [ 3: 0]                 hex_in6                         ;
reg     [ 3: 0]                 hex_in7                         ;


//======================================================================
// ***************      Main    Code    ****************
//======================================================================
//ir_data_tmp
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            {hex_in0,hex_in1,hex_in2,hex_in3,hex_in4,hex_in5,hex_in6,hex_in7}   <=      'd0;
        else if(ir_data_vld == 1'b1)
            {hex_in0,hex_in1,hex_in2,hex_in3,hex_in4,hex_in5,hex_in6,hex_in7}   <=     ir_data;
end




smg_decoder smg_decoder_inst0(
        .hex_in                 (hex_in0                ),
        .hex_out                (HEX0                   )
);
smg_decoder smg_decoder_inst1(
        .hex_in                 (hex_in1                ),
        .hex_out                (HEX1                   )
);
smg_decoder smg_decoder_inst2(
        .hex_in                 (hex_in2                ),
        .hex_out                (HEX2                   )
);
smg_decoder smg_decoder_inst3(
        .hex_in                 (hex_in3                ),
        .hex_out                (HEX3                   )
);
smg_decoder smg_decoder_inst4(
        .hex_in                 (hex_in4                ),
        .hex_out                (HEX4                   )
);
smg_decoder smg_decoder_inst5(
        .hex_in                 (hex_in5                ),
        .hex_out                (HEX5                   )
);
smg_decoder smg_decoder_inst6(
        .hex_in                 (hex_in6                ),
        .hex_out                (HEX6                   )
);
smg_decoder smg_decoder_inst7(
        .hex_in                 (hex_in7                ),
        .hex_out                (HEX7                   )
);



endmodule
