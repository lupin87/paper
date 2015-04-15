module model_ram(fram_dataout,fram_addr,fram_wren);

output [7:0]fram_dataout;

input fram_wren;
input [20:0]fram_addr;

reg [7:0] model_ram[0:2097152];//2^21 address
//integer i;
initial begin 
  $display("TETETTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
//  $readmemh("model_13_12_2012.txt", model_ram);   
  $readmemh("model_Trung_7_Dec_2013.txt", model_ram);   
  
  //for(i=0;i<2097152;i=i+1) begin
     //$display("model_ram =%h",model_ram[i]);  
  //end  
end
assign fram_dataout = fram_wren?0:model_ram[fram_addr];
endmodule
