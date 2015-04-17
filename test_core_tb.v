 //date:16/11/2011
`timescale 1ns/1ps
//`include "./test_core.v"
// `include "./test_core_new.v"
//`include "./test_core_new.v"
module test_core_tb;

//khai bao bien ngo vao
reg clk;
reg start;
reg reset;
//reg [7:0]fram_datain;

//khai bao bien ngo ra
wire result_ack;//bao ket thuc nhan dang
wire [5:0]result;//chi so tu
wire overflow;//bao ket qua nhan dang khong dang tin cay

//goi module test
test_core test_core(result_ack,result,overflow,start,clk,reset,fft_finish);
`include "./dump.v"

//  initial
//      begin
//	 #30000ns $finish;
//       end
initial begin
     $vcdpluson(1,test_core_tb);
     $vcdpluson(0,test_core_tb.test_core);
end // initial begin

integer f;
always @ (fft_finish)
      begin
       if (fft_finish == 1'b1) begin
        f = $fopen("output.txt");
        $fmonitor(f, "time=%5d, result=%d\n", $time,result[5:0] );
        $display("time=%5d, result=%d\n", $time,result[5:0] );
        #500;
        $fclose(f);
        $finish;
       end
      end // initial begin
////gan gia tri ngo vao
initial
begin
 clk=1'b0;
 reset=1'b0;
 start=1'b0;
 //fram_datain=0;//from Speech RAM
 #40
 reset=1'b1;
 start=1'b0;
 #100
 start=1'b1;
 #200
 start=1'b0;
end
 always
 #10
 clk=~clk;
 endmodule


