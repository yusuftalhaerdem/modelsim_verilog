module alucont(aluop1,aluop0,f3,f2,f1,f0,gout,balrz);//Figure 4.12 
input aluop1,aluop0,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;
output balrz;
always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin

if(aluop1&aluop0)gout=3'b100;		//ALU control=100 (nori)
if(~(aluop1|aluop0))gout=3'b010;
if((~aluop1)&aluop0)gout=3'b110;
if(aluop1&(~aluop0))//R-type
begin

	// add new control signals are here 
	//	8		4		2		1
	//balrz has function code of 22, so probably we need and update here .x
	if ( f3&	f2&		f1&		(~f0))gout = 3'b110;
//	if ( f3&	f2&		f1&		(~f0))balrz = 1'b1;

	if (~(f3|f2|f1|f0))gout=3'b010; 	//function code=0000,ALU control=010 (add)
	if (f1&f3&(~f2)&(~f0))gout=3'b111;			//function code=1010,ALU control=111 (set on less than)
	if (f1&~(f3)&~(f2)&~(f0))gout=3'b110;		//function code=0010,ALU control=110 (sub)
	if (f2&f0&~(f3)&~(f1))gout=3'b001;			//function code=0101,ALU control=001 (or)
	if (f2&~(f0)&~(f1)&~(f3))gout=3'b000;		//function code=0100,ALU control=000 (and)
	if((~f3)|f2|(~f1)|(~f0))gout=3'b011;	//function code=0100, ALU control=011 (sll)
	
end
end
endmodule
