module reghw(ham_data,ham_addr,clk,reset);
      
output [4:0]ham_data;//hamming window coefficient (5bits 2's complement)
reg [4:0]ham_data;

//input [6:0]ham_addr;//truy cap 2^7=128 thanh ghi, can 80 thanh ghi
//Thuong 29Oct13 begin
input [7:0]ham_addr;//truy cap 2^7=128 thanh ghi, can 80 thanh ghi 
//Thuong 29Oct13 end
//input wr_en;
input clk,reset;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    ham_data<=0;
  end
  else
  begin
/*-----assign different register to output----*/
    case(ham_addr)
	    0:  ham_data <= 1;
	    1:  ham_data <= 1;
	    2:  ham_data <= 1;
	    3:  ham_data <= 1;
	    4:  ham_data <= 1;
	    5:  ham_data <= 1;
	    6:  ham_data <= 1;
	    7:  ham_data <= 1;
	    8:  ham_data <= 1;
	    9:  ham_data <= 1;
	    10: ham_data <= 1;
	    11: ham_data <= 1;
	    12: ham_data <= 2;
	    13: ham_data <= 2;
	    14: ham_data <= 2;
	    15: ham_data <= 2;
	    16: ham_data <= 2;
	    17: ham_data <= 2;
	    18: ham_data <= 3;
	    19: ham_data <= 3;
	    20: ham_data <= 3;
	    21: ham_data <= 3;
	    22: ham_data <= 3;
	    23: ham_data <= 4;
	    24: ham_data <= 4;
	    25: ham_data <= 4;
	    26: ham_data <= 4;
	    27: ham_data <= 5;
	    28: ham_data <= 5;
	    29: ham_data <= 5;
	    30: ham_data <= 5;
	    31: ham_data <= 6;
	    32: ham_data <= 6;
	    33: ham_data <= 6;
	    34: ham_data <= 6;
	    35: ham_data <= 7;
	    36: ham_data <= 7;
	    37: ham_data <= 7;
	    38: ham_data <= 8;
	    39: ham_data <= 8;
	    40: ham_data <= 8;
	    41: ham_data <= 9;
	    42: ham_data <= 9;
	    43: ham_data <= 9;
	    44: ham_data <= 9;
	    45: ham_data <= 10;
	    46: ham_data <= 10;
	    47: ham_data <= 10;
	    48: ham_data <= 10;
	    49: ham_data <= 11;
	    50: ham_data <= 11;
	    51: ham_data <= 11;
	    52: ham_data <= 12;
	    53: ham_data <= 12;
	    54: ham_data <= 12;
	    55: ham_data <= 12;
	    56: ham_data <= 13;
	    57: ham_data <= 13;
	    58: ham_data <= 13;
	    59: ham_data <= 13;
	    60: ham_data <= 13;
	    61: ham_data <= 14;
	    62: ham_data <= 14;
	    63: ham_data <= 14;
	    64: ham_data <= 14;
	    65: ham_data <= 14;
	    66: ham_data <= 14;
	    67: ham_data <= 15;
	    68: ham_data <= 15;
	    69: ham_data <= 15;
	    70: ham_data <= 15;
	    71: ham_data <= 15;
	    72: ham_data <= 15;
	    73: ham_data <= 15;
	    74: ham_data <= 15;
	    75: ham_data <= 15;
	    76: ham_data <= 15;
	    77: ham_data <= 15;
	    78: ham_data <= 15;
	    79: ham_data <= 15;
	    80: ham_data <= 15;
	    81: ham_data <= 15;
	    82: ham_data <= 15;
	    83: ham_data <= 15;
	    84: ham_data <= 15;
	    85: ham_data <= 15;
	    86: ham_data <= 15;
	    87: ham_data <= 15;
	    88: ham_data <= 15;
	    89: ham_data <= 15;
	    90: ham_data <= 15;
	    91: ham_data <= 15;
	    92: ham_data <= 15;
	    93: ham_data <= 14;
	    94: ham_data <= 14;
	    95: ham_data <= 14;
	    96: ham_data <= 14;
	    97: ham_data <= 14;
	    98: ham_data <= 14;
	    99: ham_data <= 13;
	    100:ham_data <= 13;
	    101:ham_data <= 13;
	    102:ham_data <= 13;
	    103:ham_data <= 13;
	    104:ham_data <= 12;
	    105:ham_data <= 12;
	    106:ham_data <= 12;
	    107:ham_data <= 12;
	    108:ham_data <= 11;
	    109:ham_data <= 11;
	    110:ham_data <= 11;
	    111:ham_data <= 10;
	    112:ham_data <= 10;
	    113:ham_data <= 10;
	    114:ham_data <= 10;
	    115:ham_data <= 9;
	    116:ham_data <= 9;
	    117:ham_data <= 9;
	    118:ham_data <= 9;
	    119:ham_data <= 8;
	    120:ham_data <= 8;
	    121:ham_data <= 8;
	    122:ham_data <= 7;
	    123:ham_data <= 7;
	    124:ham_data <= 7;
	    125:ham_data <= 6;
	    126:ham_data <= 6;
	    127:ham_data <= 6;
	    128:ham_data <= 6;
	    129:ham_data <= 5;
	    130:ham_data <= 5;
	    131:ham_data <= 5;
	    132:ham_data <= 5;
	    133:ham_data <= 4;
	    134:ham_data <= 4;
	    135:ham_data <= 4;
	    136:ham_data <= 4;
	    137:ham_data <= 3;
	    138:ham_data <= 3;
	    139:ham_data <= 3;
	    140:ham_data <= 3;
	    141:ham_data <= 3;
	    142:ham_data <= 2;
	    143:ham_data <= 2;
	    144:ham_data <= 2;
	    145:ham_data <= 2;
	    146:ham_data <= 2;
	    147:ham_data <= 2;
	    148:ham_data <= 1;
	    149:ham_data <= 1;
	    150:ham_data <= 1;
	    151:ham_data <= 1;
	    152:ham_data <= 1;
	    153:ham_data <= 1;
	    154:ham_data <= 1;
	    155:ham_data <= 1;
	    156:ham_data <= 1;
	    157:ham_data <= 1;
	    158:ham_data <= 1;
	    159:ham_data <= 1;
      default:  ham_data<=0;
    endcase
  end
end
endmodule
