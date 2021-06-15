module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,jal,jsp,jump;
wire rformat,lw,sw,beq,nori;

assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);	//opcode=4, 000100
assign nori=(~in[5])& (~in[4])&in[3]&in[2]&(~in[1])&in[0];	//opcode=13, in binary=001101
assign sllv= (~in[5])&(~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]); //opcode=4, in binary=000100

assign jal= (~in[5])& 	(~in[4])& 	(~in[3])&	(~in[2])& 	in[1]& 		in[0];
assign jsp= (~in[5])& 	in[4]& 		(~in[3])& 	(~in[2])& 	in[1]& 		(~in[0]);

assign jump= jal|jsp;

assign regdest=rformat|sllv;
assign alusrc=lw|sw|nori;
assign memtoreg=lw;
assign regwrite=rformat|lw|nori|sllv|jal;
assign memread=lw;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat|nori|sllv;
assign aluop2= ((~aluop1)&beq)|nori;

endmodule
