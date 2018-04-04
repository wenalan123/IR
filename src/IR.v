module  IR(
        input                   CLOCK_50                ,
        input                   rst_n                   ,
        //ir
        input                   IRDA_RXD                ,
        //hex
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
wire                            ir_dout_vld                     ;
wire    [31: 0]                 ir_dout                         ; 

//======================================================================
// ***************      Main    Code    ****************
//======================================================================





ir_decode   ir_decode_inst(
        .clk                    (CLOCK_50               ),
        .rst_n                  (rst_n                  ),
        //ir
        .ir_din                 (IRDA_RXD               ),
        .ir_dout                (ir_dout                ),
        .ir_dout_vld            (ir_dout_vld            )
);


smg smg_inst(
        .clk                    (CLOCK_50               ),
        .rst_n                  (rst_n                  ),
        //ir
        .ir_data                (ir_dout                ),
        .ir_data_vld            (ir_dout_vld            ),
        //smg
        .HEX0                   (HEX0                   ),
        .HEX1                   (HEX1                   ),
        .HEX2                   (HEX2                   ),
        .HEX3                   (HEX3                   ),
        .HEX4                   (HEX4                   ),
        .HEX5                   (HEX5                   ),
        .HEX6                   (HEX6                   ),
        .HEX7                   (HEX7                   )
);




endmodule
