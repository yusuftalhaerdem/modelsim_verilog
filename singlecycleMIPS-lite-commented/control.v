module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2;
wire rformat,lw,sw,beq,nori,sllv;
assign rformat=~|in;
assign sllv= (~in[5])&(~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]); //opcode=4, in binary=000100
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign nori=(~in[5])& (~in[4])&in[3]&in[2]&(~in[1])&in[0];	//opcode=13, in binary=001101
assign regdest=rformat|sllv;
assign alusrc=lw|sw|nori;
assign memtoreg=lw;
assign regwrite=rformat|lw|nori|sllv;
assign memread=lw;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat|nori|sllv;
assign aluop2=beq;
endmodule
