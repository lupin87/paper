module reglog (clk,reset,reglog_addr,reglog_wren,reglog_in, reglog_out );
output [15:0] reglog_out;
input  [2:0] reglog_addr;
input [15:0]reglog_in;
input reglog_wren;//reglog_wren=0:read,reglog_wren=1:write
input clk,reset;

parameter WIDTH=5;//4 thanh ghi
integer i;

reg [15:0] registers[WIDTH:0];//4 thanh ghi

// The asynchronous read logic
assign reglog_out = registers[reglog_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0) begin
    for(i=0;i<=WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  end
  else begin
      if(reglog_wren == 1'b1) begin // The synchronous write logic
      registers[reglog_addr]<=reglog_in;
   end 
   end  //end else
end // end always
endmodule
