module regc(regc_out,regc_in,regc_addr,regc_wren,clk,reset);
      
output [15:0]regc_out;//feature vector MFCC

input [6:0]regc_addr;//truy cap 2^7=128 thanh ghi
input [15:0]regc_in;
input regc_wren;//regc_wren=0:read,regc_wren=1:write
input clk,reset;

parameter WIDTH=127;//128 thanh ghi
integer i;

reg [15:0] registers[WIDTH:0];//128 thanh ghi,moi thanh ghi 16bits

// The asynchronous read logic
assign regc_out = registers[regc_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  else
    if(regc_wren)// The synchronous write logic
      registers[regc_addr]<=regc_in;
end
endmodule
