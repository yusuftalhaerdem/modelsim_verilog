module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2;
wire rformat,lw,sw,beq,nori;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign nori=(~in[5])& (~in[4])&in[3]&in[2]&(~in[1])&in[0];	//opcode=13, in binary=001101
assign regdest=rformat;
assign alusrc=lw|sw|nori;
assign memtoreg=lw;
assign regwrite=rformat|lw|nori;
assign memread=lw;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat|nori;
assign aluop2=beq|nori;
endmodule
