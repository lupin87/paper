module rege(regffte_out,regffte_in,regffte_addr,regffte_wren,clk,reset);
      
output [40:0]regffte_out;//energy coefficient

//input [5:0]regffte_addr;//truy cap 2^6=64 thanh ghi, can 64 he so nang luong,SF
input [6:0]regffte_addr;//truy cap 2^7=128 thanh ghi, can 64 he so nang luong,SF
input [40:0]regffte_in;
input regffte_wren;//regffte_wren=0:read,regffte_wren=1:write
input clk,reset;

//parameter WIDTH=63;//64 thanh ghi
parameter WIDTH=127;//128 thanh ghi
integer i;

reg [40:0] registers[WIDTH:0];//64 thanh ghi,moi thanh ghi 41bits

// The asynchronous read logic
assign regffte_out = registers[regffte_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  else
    if(regffte_wren)// The synchronous write logic
      registers[regffte_addr]<=regffte_in;
end
endmodule
