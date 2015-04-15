wire signed [20:0] out1;
wire signed [39:0] out2;
wire signed [15:0] out3;
assign out1 = test_core_tb.test_core.fecore.window.out;
assign out2 = test_core_tb.test_core.fecore.regfft.fft_inr;
assign out3 = test_core_tb.test_core.fecore.preemp.in;

integer f;
//initial begin
//  f = $fopen("output.txt");
//  $fmonitor(f, "time=%5d, result=%h\n", $time, );
//  #1000 
//  $fclose(f);
//  $finish;
//end

//test addmel block
//initial  begin
//force test_core_tb.test_core.fecore.addmel.sel = 0;
//force test_core_tb.test_core.fecore.log.en = test_core_tb.test_core.fecore.regp.regmel_wren;
//end




//always @ (posedge clk) begin
//   if (test_core_tb.test_core.fecore.preemp.en) begin	
//   $display ("%d",out3);
//   end
//end









//always @ (test_core_tb.test_core.fecore.window.out) begin
//   $display ("%d",out1);
//end
//
//reg [31:0] count;
//always @(posedge test_core_tb.test_core.fecore.regfft.fft_wren or negedge reset) begin
//    if (reset == 1'b0) begin
//      count <= 0;
//    end
//    else begin
//      count <= count + 1;
//end
//end
//always @(count) begin
//   if ((count >= 1185)&& (count <=1346)) begin
//     $display ("%d",out2);
//end 
//end 
//
//wire [7:0] fft_addr;
//wire signed [39:0] out_r;
//wire signed [39:0] out_i;
//assign out_r = test_core_tb.test_core.fecore.regfft.fft_inr;
//assign out_i = test_core_tb.test_core.fecore.regfft.fft_ini;
//assign fft_addr = test_core_tb.test_core.fecore.regfft.fft_addr;
//
///////////////////////////////////////////////
// test Stage 1
//always @ (posedge clk) begin
//   if ((test_core_tb.test_core.fecore.regfft.fft_wren==1'b1)&&(test_core_tb.test_core.fecore.fecon.state==5))
//       $display ("%d  %d",fft_addr+1,out_r);
//end
///////////////////////////////////////////////
// test Stage 2
//always @ (posedge clk) begin
//   if ((test_core_tb.test_core.fecore.regfft.fft_wren==1'b1)&&(test_core_tb.test_core.fecore.fecon.state==6))
//       $display ("%d  %d %d",fft_addr+1,out_r,out_i);
//end
///////////////////////////////////////////////
// test Stage 3
//always @ (posedge clk) begin
//   if ((test_core_tb.test_core.fecore.regfft.fft_wren==1'b1)&&(test_core_tb.test_core.fecore.fecon.state==6)&&({test_core_tb.test_core.fecore.fecon.counterf==1}))
//       $display ("%d  %d %d",fft_addr+1,out_r,out_i);
//end
///////////////////////////////////////////////
// test Stage 4
//always @ (posedge clk) begin
//   if ((test_core_tb.test_core.fecore.regfft.fft_wren==1'b1)&&(test_core_tb.test_core.fecore.fecon.state==6)&&({test_core_tb.test_core.fecore.fecon.counterf==2}))
//       $display ("%d  %d %d",fft_addr+1,out_r,out_i);
//end
///////////////////////////////////////////////
// test Stage 5
//always @ (posedge clk) begin
//   if ((test_core_tb.test_core.fecore.regfft.fft_wren==1'b1)&&(test_core_tb.test_core.fecore.fecon.state==6)&&({test_core_tb.test_core.fecore.fecon.counterf==3}))
//       $display ("%d  %d %d",fft_addr+1,out_r,out_i);
//end
