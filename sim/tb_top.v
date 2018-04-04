`timescale		1ns/1ns 

module	tb_top;

//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
reg                             clk                             ;       
reg                             rst_n                           ;       
reg                             ir_din                          ; 
wire        [31: 0]             ir_dout                         ; 
wire                            ir_dout_vld                     ; 
//======================================================================
// ***************      Main    Code    ****************
//======================================================================
always  #5      clk    =       ~clk;

task    tx_low();
    begin    
        ir_din      <=      1'b0;
        #120
        ir_din      <=      1'b1;
        #120;
    end
endtask

task    tx_high();
    begin
        ir_din      <=      1'b0;
        #120
        ir_din      <=      1'b1;
        #220;
    end
endtask


task    tx_byte(
                input   [ 7:0]  data
                );
        integer i;
        for(i=0; i<8; i=i+1) begin
            if(data[i])
                tx_high();
            else
                tx_low();
        end
endtask

initial begin
	clk		<=		1'b1;
	rst_n	<=		1'b0;
    ir_din  <=      1'b1;
	#100
	rst_n	<=		1'b1;
    #100

    ir_din  <=      1'b0;
    #400
    ir_din  <=      1'b1;
    #200
    tx_byte(8'h12);
    tx_byte(8'h34);
    tx_byte(8'haa);
    tx_byte(8'h55);
    ir_din  <=      1'b0;//发送停止位
    #100
    ir_din  <=      1'b1;


end


//例化
ir_decode   ir_decode_inst(
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        //ir
        .ir_din                 (ir_din                 ),
        .ir_dout                (ir_dout                ),
        .ir_dout_vld            (ir_dout_vld            )
);
defparam  ir_decode_inst.MIN_9MS     =       19'd32;//6.5ms
defparam  ir_decode_inst.MAX_9MS     =       19'd49;//9.9ms
defparam  ir_decode_inst.MIN_4_5MS   =       19'd15;//3.05ms
defparam  ir_decode_inst.MAX_4_5MS   =       19'd27;//5.55ms
defparam  ir_decode_inst.MIN_560US   =       19'd10;//400us
defparam  ir_decode_inst.MAX_560US   =       19'd15;//700us
defparam  ir_decode_inst.MIN_1690US  =       19'd20;//1500us
defparam  ir_decode_inst.MAX_1690US  =       19'd25;//1800us


endmodule
