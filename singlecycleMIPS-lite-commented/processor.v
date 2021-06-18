module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,	//Output of shift left 2 unit
new_pc_value,
data_mem_addr;

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
read_reg_1,
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1;		//Write data input of Register File

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;


// zel 
wire [31:0] jump32, out5, out13, writeData, out16;
wire jal, jsp, jumpSignal, wDataChange, balrz;
wire [4:0] out15;
assign wDataChange = jal;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//data_mem_addr stores address,datab stores the value to be written
datmem[data_mem_addr[4:0]+3]=datab[7:0];
datmem[data_mem_addr[4:0]+2]=datab[15:8];
datmem[data_mem_addr[4:0]+1]=datab[23:16];
datmem[data_mem_addr[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];


// registers

assign dataa=registerfile[read_reg_1];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[out15]= regwrite ? writeData:registerfile[out15];//Write data to register

//read data from memory, sum stores address
assign dpack={	datmem[data_mem_addr[5:0]],datmem[data_mem_addr[5:0]+1],
				datmem[data_mem_addr[5:0]+2],datmem[data_mem_addr[5:0]+3]};

//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

// load pc
always @(negedge clk)
pc=new_pc_value;	//changed by zel

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,
jal,jsp,jumpSignal,bgtz);	//added by zel

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout, balrz);

//Shift-left 2 unit
shift shift2(sextad,extad);

//AND gate
assign pcsrc=(branch && zout)
 || ((~(dataa[31:30])) && (~zout) && bgtz); // added by zel



//added by zel
//jal
jump jumpComponent(jump32,adder1out[31:28],instruc[25:0]);		//creating the 32 bit jump
mult2_to_1_32 mux13(out5, out4, jump32, jumpSignal);	//last operant before pc change
mult2_to_1_32 mux14(out13, out3, adder1out, wDataChange);	//last operant before writeData
mult2_to_1_5 mux15(out15, out1, 5'b11111 , wDataChange|balrz);	// changes the address of register to write

//jsp
mult2_to_1_5 mux16(read_reg_1, inst25_21, 5'b11100,jsp);	// changes read_reg_1 to 28 according to jsp
mult2_to_1_32 mux17(data_mem_addr, sum, dataa, jsp);	// changes readData according to jsp
mult2_to_1_32 mux18(out16, out5, dpack, jsp);	// changes pc value in next clock according to jsp

//balrz		// i have failed that
mult2_to_1_32 muxWdata(writeData, adder1out, out13, balrz);
assign regwrite = regwrite | balrz;
mult2_to_1_32 mux19(new_pc_value, out16, dataa, balrz);

//bgtz		bgtz



// part appended by zel is finished


//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule

