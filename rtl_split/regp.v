module regp(regmel_out,regmel_in,regmel_addr,regmel_wren,clk,reset);
      
output [44:0]regmel_out;//power coefficient

input [4:0]regmel_addr;//truy cap 2^5=32 thanh ghi, can 23 he so cong suat,S
input [44:0]regmel_in;
input regmel_wren;//regmel_wren=0:read,regmel_wren=1:write
input clk,reset;

parameter WIDTH=31;//32 thanh ghi
integer i;

reg [44:0] registers[WIDTH:0];//32 thanh ghi,moi thanh ghi 45bits

// The asynchronous read logic
assign regmel_out = registers[regmel_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  else
    if(regmel_wren)// The synchronous write logic
      registers[regmel_addr]<=regmel_in;
end
endmodule
