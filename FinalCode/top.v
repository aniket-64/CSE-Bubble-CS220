`timescale 1ns/1ps
`include "alu.v"
`include "control.v"
`include "data_mem.v"
`include "inst_mem.v"

/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

module top_module (
    input wire rst,
    input wire clk
);

reg start;

reg [31:0] PC;
wire [31:0] PC_next, instruction;

reg[31:0] registers [31:0];
// register file

integer i;

initial begin
    // initialise registers
    for (i = 0; i< 32; i = i + 1) begin
        registers[i] = 32'b0;
    end
    registers[29] = 32'd255; // stack pointer
end

// parse the instruction fields
wire[31:0] rs_reg_data, rt_reg_data;
assign rs_reg_data = registers[instruction[25:21]];
assign rt_reg_data = registers[instruction[20:16]];
// data in the registers indicated by rs and rt fields of the instruction
wire [4:0] shamt;
assign shamt = instruction[10:6];
// shamt field
wire[31:0] Immediate;
// Immediate field of the instruction

wire[4:0] Reg_Destination;
//whether result is stored in rt or rd
wire ALU_source, Memory_write, Mem_or_ALUto_Reg, RegWrite_en, link;
// wires to carry the outputs of the control unit

wire[31:0] Mem_Data_out, ALUout, Reg_DataToWrite;
// wires to carry memory's data output, ALU output, and what data to write to registers

// initialise ALU
wire[3:0] ALU_operation;
wire ALU_carry;
wire[31:0] ALU_in1, ALU_in2;
assign ALU_in1 = rs_reg_data;

// choose where ALU gets its second input from
mux ALU_in2_choice (
    .a(rt_reg_data) , 
    .b(Immediate) , 
    .s_in(ALU_source) , 
    .out(ALU_in2)
);

alu alu32(
    .a(ALU_in1),
    .b(ALU_in2), 
    .operation(ALU_operation), 
    .shamt(shamt),
    .out(ALUout), 
    .carry_out(ALU_carry)
);

// branching control
wire[1:0] PC_cntrl;
//PC_updater's control signal
//0 = pc+1 , 1 = branch , 2= jump to address from reg , 3=jump unconditional

wire [31:0] PC_plus_1;
assign PC_plus_1 = PC + 1;
// calculate PC+1 explicitly. This is needed to store the return address in jal instruction (when link is 1)

wire ALUflag;
// flag for comparison operation performed by ALU
// The way the ALU is designed is such that the output itself is 1 or 0 depending on the comparison is true or false
// so, ALUflag is LSB of ALUout
assign ALUflag = ALUout[0];

// instantiate the mux which handles PC updation (branch, jump, jr, PC+1)
PC_selector_mux PC_updater(
    .PC(PC),
    .sel(PC_cntrl),
    .Immediate(Immediate),
    .Reg_val(rs_reg_data),
    .ALU_flag(ALUflag),
    .out(PC_next)
);

// this mux decides whether the data to be written to register comes from memory read output or from ALUout
mux Mem_or_ALU_choice (
    .a(ALUout), 
    .b(Mem_Data_out), 
    .s_in(Mem_or_ALUto_Reg), 
    .out(Reg_DataToWrite)
);

// since inst memory is not modified, we disable its write port, by keeping it 0 always
wire zero;
wire [31:0] zero32;
wire [7:0] zero8;
assign zero8 = 0;
assign zero32 = 0;
assign zero = 0;

//since the instruction memory has only 8 address bits, prune PC to take its lower 8 bits
// since we plan to implement only bubble sort, its enough to have only 2^8 word instruction memory size
wire [7:0] PC_pruned;
assign PC_pruned = PC[7:0];

// instantiate the instruction memory
inst_mem inst(
    .write_address(zero8), 
    .write_enable(zero), 
    .write_data(zero32), 
    .address(PC_pruned), 
    .instr_out(instruction)
);

wire MemWriteFinal;
assign MemWriteFinal = (~clk) & Memory_write;
// MemWriteFinal is the signal which handles writes to datamemory. Writes occur only if Memory_write is high.
// writing to memory on negedge of clk (if Memory_write is high)

wire [7:0] data_mem_address;
assign data_mem_address = ALUout[7:0];

data_mem data(
    .write_enable(MemWriteFinal),
    .write_data(rt_reg_data), 
    .write_address(data_mem_address), 
    .address(data_mem_address),
    .instr_out(Mem_Data_out)
);


// instantiate the control unit
control unit_control(
    .ALU_source(ALU_source), 
    .instruction(instruction), 
    .PC_cntrl(PC_cntrl), 
    .Mem_or_ALUto_Reg(Mem_or_ALUto_Reg), 
    .Immediate_SignExtended(Immediate),
    .operation(ALU_operation), 
    .Reg_Destination(Reg_Destination), 
    .Memory_write(Memory_write), 
    .Reg_Write(RegWrite_en), 
    .link(link)
);

always@(posedge clk) begin
    if(rst) begin
        // reset the execution state
        PC = 0;
        // ensure registers are restored to original state
        for (i = 0; i< 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
        registers[29] = 32'd255; // stack pointer
    end
    else begin
        // if not rst, go to the next PC
        PC = PC_next;
    end
end

always @(negedge clk) begin
    // register write access done on negedge of clk to avoid data race
    if (RegWrite_en) registers[Reg_Destination] = Reg_DataToWrite;
    if(link) registers[31] = PC_plus_1;
    // store return address of jal instruction
end

endmodule





module mux #(
    parameter k = 32
) (
    input wire [k-1:0] a,
    input wire [k-1:0] b,
    input wire s_in,
    output wire [k-1:0] out
);

wire [k-1:0] s;
assign s = {k{s_in}};

assign out = a&(~s) | b&s;
    
endmodule





module PC_selector_mux (
    input wire [31:0] PC,
    input wire [1:0] sel,
    input wire [31:0] Immediate,
    input wire [31:0] Reg_val,
    input wire ALU_flag,
    output reg [31:0] out
);

wire [31:0] PC_plus_1;
assign PC_plus_1 = PC + 1;
wire [31:0] branch_address;
assign branch_address = PC + 1 + Immediate;
wire [31:0] jump_address;
assign jump_address = Immediate;

always @(*) begin
    case (sel)
        0: out <= PC_plus_1;
        1: begin
            if(ALU_flag) begin
                out <= branch_address;
            end
            else begin
                out <= PC_plus_1;
            end
        end
        2: out <= Reg_val;
        3: out <= jump_address;
    endcase
end
    
endmodule