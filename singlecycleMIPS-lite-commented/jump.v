module jump(fullJump,brPart,jumpIn);
input [25:0] jumpIn;
input [3:0] brPart;
output [31:0] fullJump;
assign fullJump = {brPart, {jumpIn}, 2'b00};	//creates jump istruction
//shift shift_1(jumpPart, jumpIn);

//assign 	 out1 = {{ 16 {in1[15]}}, in1};

endmodule