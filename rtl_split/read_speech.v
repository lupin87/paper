module read_speech(addr_in,sdram_in,sdram_out);

input [15:0]sdram_in;
input [22:0]addr_in;

//output reg sdram_read;
output [7:0]sdram_out;

assign sdram_out=(addr_in[0])?sdram_in[15:8]:sdram_in[7:0];

endmodule
