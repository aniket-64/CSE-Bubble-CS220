/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

module control (
    input wire [31:0] instruction,
    output reg [3:0] operation,
    output reg [31:0] Immediate_SignExtended,
    output reg [4:0] Reg_Destination,
    output reg [1:0] PC_cntrl,
    output reg Memory_write,
    output reg ALU_source,
    output reg Mem_or_ALUto_Reg,
    output reg Reg_Write,
    output reg link
);
// this module sets the control signals depending on the instruction recieved

wire[31:0] signed_im, unsigned_im;
assign signed_im = { {16{instruction[15]}} , instruction[15:0]};
assign unsigned_im = { 16'd0 , instruction[15:0]};
// depending on the purpose, Immediate maybe interpreted as signed or not

wire [4:0] rs,rt,rd;
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
// parse instruction

always@(instruction) begin
    link = 0;
    Reg_Write = 0;
    // casewise handling of each instruction
    case(instruction[31:26])

        6'b000000: begin
            //R type

            PC_cntrl = 0;
            // in opcode 000000 type, PC = PC+1 always, except jr instruction
            Reg_Destination = rd;
            // destination register of output is rd, not rt
            ALU_source = 0;
            // operand comes from registers only, not Immediate
            Memory_write = 0;
            // data memory is not written
            Mem_or_ALUto_Reg = 0;
            // Reg must get its data to be written from ALU
            Reg_Write = 1;

            case (instruction[5:0])
            // set ALU opcodes
                6'b100000: begin
                    //add
                    operation = 0;
                end
                6'b100001: begin
                    //addu
                    operation = 0;
                end
                6'b100010: begin
                    //sub
                    operation = 1;
                end
                6'b100011: begin
                    //subu
                    operation = 1;
                end
                6'b100100: begin
                    //and                    
                    operation = 3;
                end
                6'b100101: begin
                    //or
                    operation = 2;
                end
                6'b100111: begin
                    //nor
                    operation = 4;
                end
                6'b101010: begin
                    //slt
                    operation = 5;
                end
                6'b000000: begin
                    //sll
                    operation = 8;
                end
                6'b000010: begin
                    //srl
                    operation = 9;
                end
                6'b001000: begin   
                //jr instruction
                // in this, we must change the PC control, and set the select line of PC_updater mux to jump to address in reg mode
                    PC_cntrl = 2;
                    operation = 0;
                end

            endcase
        end

        6'b000010: begin
            // j type
            // j
            PC_cntrl = 3;
            Memory_write = 0;
            Mem_or_ALUto_Reg = 0;
            Reg_Write = 0;
        end

        6'b000011: begin
            // j type
            // jal
            PC_cntrl = 3;
            Memory_write = 0;
            Mem_or_ALUto_Reg = 0;
            Reg_Write = 0;
            link = 1;
        end
        // in both j and jal, the PC-updater must take the address to jump to from the instruction (immediate field)
        // in both, memory is not written, neither registers.
        // in jal link must also be set to high, so that ra value is updated to PC+1

        default: begin
            // i type

            // if it is branch type (beq, bgt, etc) then PC-updater must be set to branch mode (PC+ 1 + offset)
            // ALU operation must be set to appropriate comparison (equals, greater than etc)
            // Neither memory nor reg are to be written.
            // the Immediate field(offset) is interpreted with its sign

            // if it is immediate type arithmetic/logical operation,
            // ALU 2nd input comes from immediate field so ALUsrc =1
            // Registers are written, so RegWrite = 1
            // input to registers must come from ALU so Mem_or_ALUto_Reg = 0
            // depending on signed or unsigned type of instruction Immediate may be imterpreted as needed

            case (instruction[31:26])
                6'b000100: begin
                    //beq
                    PC_cntrl = 1;
                    Reg_Destination = rt;
                    ALU_source = 0;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 0;
                    operation = 7;
                    Immediate_SignExtended = signed_im;
                end 
                6'b000101: begin
                    //bneq
                    PC_cntrl = 1;
                    Reg_Destination = rt;
                    ALU_source = 0;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 0;
                    operation = 10;
                    Immediate_SignExtended = signed_im;
                end
                6'b001010: begin
                    //slti
                    PC_cntrl = 0;
                    Reg_Destination = rt;
                    ALU_source = 1;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 1;
                    Immediate_SignExtended = signed_im;
                    operation = 5;
                end
                6'b001000: begin
                    //addi
                    PC_cntrl = 0;
                    Reg_Destination = rt;
                    ALU_source = 1;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 1;
                    Immediate_SignExtended = signed_im;
                    operation = 0;
                end
                6'b001001: begin
                    //addiu
                    PC_cntrl = 0;
                    Reg_Destination = rt;
                    ALU_source = 1;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 1;
                    Immediate_SignExtended = unsigned_im;
                    operation = 0;
                end
                6'b001100: begin
                    //andi
                    PC_cntrl = 0;
                    Reg_Destination = rt;
                    ALU_source = 1;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 1;
                    Immediate_SignExtended = signed_im;
                    operation = 3;
                end
                6'b001101: begin
                    //ori
                    PC_cntrl = 0;
                    Reg_Destination = rt;
                    ALU_source = 1;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 1;
                    Immediate_SignExtended = signed_im;
                    operation = 2;
                end
                6'b101011: begin
                    //sw
                    // in sw or lw, address is calculated in the ALu, so opcode is for addition (0). memory is written in sw,
                    // so Memory_write =1. offset is signed. Second input of ALU is the offset stored in the immediate field, so ALU_source =1
                    PC_cntrl = 0;
                    Reg_Destination = rt;
                    ALU_source = 1;
                    Memory_write = 1;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 0;
                    Immediate_SignExtended = signed_im;
                    operation = 0;
                end
                6'b100011: begin
                    //lw
                    PC_cntrl = 0;
                    Reg_Destination = rt;
                    ALU_source = 1;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 1;
                    Reg_Write = 1;
                    Immediate_SignExtended = signed_im;
                    operation = 0;
                end
                6'b111111: begin
                    //bgt
                    PC_cntrl = 1;
                    Reg_Destination = rt;
                    ALU_source = 0;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 0;
                    operation = 11;
                    Immediate_SignExtended = signed_im;
                end
                6'b111110: begin
                    //bgte
                    PC_cntrl = 1;
                    Reg_Destination = rt;
                    ALU_source = 0;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 0;
                    operation = 12;
                    Immediate_SignExtended = signed_im;
                end
                6'b111101: begin
                    //ble
                    PC_cntrl = 1;
                    Reg_Destination = rt;
                    ALU_source = 0;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 0;
                    operation = 5;
                    Immediate_SignExtended = signed_im;
                end
                6'b111100: begin
                    //bleq
                    PC_cntrl = 1;
                    Reg_Destination = rt;
                    ALU_source = 0;
                    Memory_write = 0;
                    Mem_or_ALUto_Reg = 0;
                    Reg_Write = 0;
                    operation = 6;
                    Immediate_SignExtended = signed_im;
                end
            endcase

        end

    endcase
end
    
endmodule