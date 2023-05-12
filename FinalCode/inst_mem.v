/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

module inst_mem(
    input wire [7:0] address,
    input wire write_enable,
    input wire [7:0] write_address,
    input wire [31:0] write_data,
    output wire [31:0] instr_out
);

reg [31:0] memory [255:0];

assign instr_out = memory[address];
integer i;

initial begin
    for (i = 0; i < 255 ; i = i + 1) begin
        memory[i] = 0;
    end

    //code for bubble sort
    memory[0] = {6'b001000 , 5'd0 , 5'd23 , 16'd0}; //addi
    memory[1] = {6'b001000 , 5'd0 , 5'd16 , 16'd0}; //addi
    memory[2] = {6'b001000 , 5'd0 , 5'd22 , 16'd9}; //addi
    memory[3] = {6'b001000 , 5'd0 , 5'd17 , 16'd0}; //addi
    memory[4] = {6'b000000 , 5'd17 , 5'd23 , 5'd15 , 5'd0 , 6'd32}; //add
    memory[5] = {6'b100011 , 5'd15 , 5'd8, 16'd0}; //lw
    memory[6] = {6'b100011 , 5'd15 , 5'd9, 16'd1}; //lw
    memory[7] = {6'b000000 , 5'd8  , 5'd9, 5'd10 , 5'd0, 6'b101010}; //slt
    memory[8] = {6'b000101 , 5'd10 , 5'd0, 16'd2}; //bne
    memory[9] = {6'b101011 , 5'd15 , 5'd9, 16'd0}; //sw
    memory[10] = {6'b101011 , 5'd15 , 5'd8, 16'd1}; //sw
    memory[11] = {6'b001000 , 5'd17 , 5'd17 , 16'd1}; //addi
    memory[12] = {6'b000000 , 5'd22 , 5'd16 , 5'd21 , 5'd0 , 6'd34}; //sub
    memory[13] = {6'b000101 , 5'd17 , 5'd21, 16'd65526}; //bne
    memory[14] = {6'b001000 , 5'd16 , 5'd16 , 16'd1}; //addi
    memory[15] = {6'b001000 , 5'd0 , 5'd17 , 16'd0} ;//addi
    memory[16] = {6'b000101 , 5'd16 , 5'd22, 16'd65523}; //bne
end

always @(posedge write_enable) begin
    memory[write_address] <= write_data;
end

endmodule
