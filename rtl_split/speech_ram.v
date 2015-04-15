module speech_ram(speech_data,speech_addr,speech_wren);

output [15:0]speech_data;

input speech_wren;
input [21:0]speech_addr;

reg [15:0] data_ram[0:4194303];//2^22 address
integer i;
initial begin 
  $display("TETETTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
  $readmemh("sample.txt", data_ram);   
  
  //for(i=0;i<4194303;i=i+1) begin
     //$display("data_ram =%h",data_ram[i]);  
  //end  
end
assign speech_data = speech_wren?0:data_ram[speech_addr];
//always@(posedge clk or negedge reset)
//begin
//  if(reset==0)
//    begin
//      speech_data<=0;
//    end
//  else
//    begin
//      $display("speech_data = %h", speech_data);
//    end
//end
endmodule
