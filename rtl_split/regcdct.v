module regcdct(cdct_addr,cdct_data,clk,reset);

output [7:0]cdct_data;//DCT coefficient (8bits 2's complement)
reg [7:0]cdct_data;

input [7:0]cdct_addr;//188 thanh ghi he so DCT
input clk,reset;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    cdct_data<=0;
  end
  else
  begin

//-----assign different register to output----
    case(cdct_addr)
        //Cn1
0:	cdct_data<=	63;
1:	cdct_data<=	62;
2:	cdct_data<=	60;
3:	cdct_data<=	56;
4:	cdct_data<=	52;
5:	cdct_data<=	46;
6:	cdct_data<=	40;
7:	cdct_data<=	33;
8:	cdct_data<=	25;
9:	cdct_data<=	17;
10:	cdct_data<=	8;
11:	cdct_data<=	0;

        //Cn2
16:	cdct_data<=	63	;
17:	cdct_data<=	58	;
18:	cdct_data<=	49	;
19:	cdct_data<=	36	;
20:	cdct_data<=	21	;
21:	cdct_data<=	4	;
22:	cdct_data<=	-13	;
23:	cdct_data<=	-29	;
24:	cdct_data<=	-43	;
25:	cdct_data<=	-54	;
26:	cdct_data<=	-61	;
27:	cdct_data<=	-64	;

        //Cn3
32:	cdct_data<=	62	;
33:	cdct_data<=	52	;
34:	cdct_data<=	33	;
35:	cdct_data<=	8	;
36:	cdct_data<=	-17	;
37:	cdct_data<=	-40	;
38:	cdct_data<=	-56	;
39:	cdct_data<=	-63	;
40:	cdct_data<=	-60	;
41:	cdct_data<=	-46	;
42:	cdct_data<=	-25	;
43:	cdct_data<=	0	;
        //Cn4
48:	cdct_data<=	61	;
49:	cdct_data<=	43	;
50:	cdct_data<=	13	;
51:	cdct_data<=	-21	;
52:	cdct_data<=	-49	;
53:	cdct_data<=	-63	;
54:	cdct_data<=	-58	;
55:	cdct_data<=	-36	;
56:	cdct_data<=	-4	;
57:	cdct_data<=	29	;
58:	cdct_data<=	54	;
59:	cdct_data<=	64	;

        //Cn5
64:	cdct_data<=	60	;
65:	cdct_data<=	33	;
66:	cdct_data<=	-8	;
67:	cdct_data<=	-46	;
68:	cdct_data<=	-63	;
69:	cdct_data<=	-52	;
70:	cdct_data<=	-17	;
71:	cdct_data<=	25	;
72:	cdct_data<=	56	;
73:	cdct_data<=	62	;
74:	cdct_data<=	40	;
75:	cdct_data<=	0	;

        //Cn6
80:	cdct_data<=	58	;
81:	cdct_data<=	21	;
82:	cdct_data<=	-29	;
83:	cdct_data<=	-61	;
84:	cdct_data<=	-54	;
85:	cdct_data<=	-13	;
86:	cdct_data<=	36	;
87:	cdct_data<=	63	;
88:	cdct_data<=	49	;
89:	cdct_data<=	4	;
90:	cdct_data<=	-43	;
91:	cdct_data<=	-64	;

        //Cn7
96:	cdct_data<=	56	;
97:	cdct_data<=	8	;
98:	cdct_data<=	-46	;
99:	cdct_data<=	-62	;
100:	cdct_data<=	-25	;
101:	cdct_data<=	33	;
102:	cdct_data<=	63	;
103:	cdct_data<=	40	;
104:	cdct_data<=	-17	;
105:	cdct_data<=	-60	;
106:	cdct_data<=	-52	;
107:	cdct_data<=	0	;

       //Cn8
112:	cdct_data<=	54	;
113:	cdct_data<=	-4	;
114:	cdct_data<=	-58	;
115:	cdct_data<=	-49	;
116:	cdct_data<=	13	;
117:	cdct_data<=	61	;
118:	cdct_data<=	43	;
119:	cdct_data<=	-21	;
120:	cdct_data<=	-63	;
121:	cdct_data<=	-36	;
122:	cdct_data<=	29	;
123:	cdct_data<=	64	;

        //cn9
128:	cdct_data<=	52	;
129:	cdct_data<=	-17	;
130:	cdct_data<=	-63	;
131:	cdct_data<=	-25	;
132:	cdct_data<=	46	;
133:	cdct_data<=	56	;
134:	cdct_data<=	-8	;
135:	cdct_data<=	-62	;
136:	cdct_data<=	-33	;
137:	cdct_data<=	40	;
138:	cdct_data<=	60	;
139:	cdct_data<=	0	;

        //Cn10
144:	cdct_data<=	49	;
145:	cdct_data<=	-29	;
146:	cdct_data<=	-61	;
147:	cdct_data<=	4	;
148:	cdct_data<=	63	;
149:	cdct_data<=	21	;
150:	cdct_data<=	-54	;
151:	cdct_data<=	-43	;
152:	cdct_data<=	36	;
153:	cdct_data<=	58	;
154:	cdct_data<=	-13	;
155:	cdct_data<=	-64	;

        //Cn11
160:	cdct_data<=	46	;
161:	cdct_data<=	-40	;
162:	cdct_data<=	-52	;
163:	cdct_data<=	33	;
164:	cdct_data<=	56	;
165:	cdct_data<=	-25	;
166:	cdct_data<=	-60	;
167:	cdct_data<=	17	;
168:	cdct_data<=	62	;
169:	cdct_data<=	-8	;
170:	cdct_data<=	-63	;
171:	cdct_data<=	0	;

        //Cn12
176:	cdct_data<=	43	;
177:	cdct_data<=	-49	;
178:	cdct_data<=	-36	;
179:	cdct_data<=	54	;
180:	cdct_data<=	29	;
181:	cdct_data<=	-58	;
182:	cdct_data<=	-21	;
183:	cdct_data<=	61	;
184:	cdct_data<=	13	;
185:	cdct_data<=	-63	;
186:	cdct_data<=	-4	;
187:	cdct_data<=	64	;

default:cdct_data<=0;
    endcase
  end
end
endmodule
