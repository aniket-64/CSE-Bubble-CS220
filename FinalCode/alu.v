`include "adder32bit.v"

/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] operation,
    input [4:0] shamt,
    output [31:0] out,
    output wire carry_out
);

wire [31:0] sum;
wire c_out;
reg [31:0] b_inp;
reg cin;
adder add32(.a(a), .b(b_inp), .c_in(cin), .c_out(c_out), .sum(sum));
// instatntiate adder module to implement addition and subtraction.

wire [31:0] or_out;
wire [31:0] and_out;
wire [31:0] nor_out;
genvar i, j, k;

generate
    for (i = 0; i<32 ; i = i+1) begin: or_loop
        or or_gate(or_out[i], a[i], b[i]);
    end
endgenerate
// instantiate a 32 bit wide or gate

generate
    for (j = 0; j<32 ; j = j+1) begin: and_loop
        and and_gate(and_out[j], a[j], b[j]);
    end
endgenerate
// instantiate a 32 bit wide and gate

generate
    for(k = 0; k<32; k = k+1) begin: not_loop
        not not_gate(nor_out[k], or_out[k]);
    end
endgenerate
// instantiate a 32 bit wide nor gate for nor functionality


wire [31:0] sll_out, srl_out;

sll sll32(.a(b_inp), .b(shamt), .out(sll_out));
srl srl32(.a(b_inp), .b(shamt), .out(srl_out));

wire [31:0] slt_out, slteq_out, eq_out, neq_out, gt_out, gteq_out;

// if either of a or b is -ve, i.e. a[31] or b[31] = 1, we must handle that case separately from +ve a and b.
assign slt_out = ((a[31]==1 || b[31]==1)?((a>b) ? 1 : 0):((a<b) ? 1 : 0));
assign slteq_out = ((a[31]==1 || b[31]==1)?((a<b) ? 0 : 1):((a>b) ? 0 : 1));
assign eq_out = ((a==b)? 1 : 0);
assign neq_out = ((a != b)? 1: 0);
assign gteq_out = ((a[31]==1 || b[31]==1)?((a<b) ? 1 : 0):((a>=b) ? 1 : 0));
assign gt_out = ((a[31]==1 || b[31]==1)?((a<b) ? 1 : 0):((a>b) ? 1 : 0));


reg [3:0] mux_in_32;
output_mux mux32(out, sum, and_out, or_out, nor_out, sll_out, srl_out, slt_out, slteq_out, eq_out, neq_out, gt_out, gteq_out, mux_in_32);

reg mux_in_1;
cout_mux mux1(carry_out, c_out, mux_in_1);

always @(a, b, cin, operation) begin
    case (operation)
    // depending on the ALU_operation, set the select lines of the mux
        0: begin
            //sum
            b_inp <= b;
            cin <= 0;
            mux_in_32 <= 0;
            mux_in_1 <= 0;
        end 
        1: begin
            //subtract
            b_inp <= ~b;
            cin <= 1;
            mux_in_32 <= 0;
            mux_in_1 <= 1;
        end
        2: begin
            //or
            mux_in_32 <= 1;
            mux_in_1 <= 1;
        end
        3: begin
            //and
            mux_in_32 <= 2;
            mux_in_1 <= 1;
        end
        4: begin
            //nor
            mux_in_32 <= 3;
            mux_in_1 <= 1;
        end
        5: begin
            //slt
            mux_in_32 <= 4;
            mux_in_1 <= 1;
        end
        6: begin
            //slteq
            mux_in_32 <= 5;
            mux_in_1 <= 1;
        end
        7: begin
            //eq
            mux_in_32 <= 6;
            mux_in_1 <= 1;
        end
        8: begin
            // we note that according to the instruction format of MIPS, first operand is in rt reg, i.e. b.
            // and second operand is shamt.
            //sll
            b_inp <= b;
            mux_in_32 <= 7;
            mux_in_1 <= 1;
        end
        9: begin
            //srl
            b_inp <= b;
            mux_in_32 <= 8;
            mux_in_1 <= 1;
        end
        10: begin
            //neq
            mux_in_32 <= 9;
            mux_in_1 <= 1;
        end
        11: begin
            //gt
            mux_in_32 <= 10;
            mux_in_1 <= 1;
        end
        12: begin
            //gteq
            mux_in_32 <= 11;
            mux_in_1 <= 1;
        end
        default: begin
            mux_in_32 <= 12;
            mux_in_1 <= 1;
        end
    endcase
end
    
endmodule



module sll (
    input wire [31:0] a,
    input wire [4:0] b,
    output wire [31:0] out
);
// module for shift left logical function
assign out = a<<b;
    
endmodule



module srl (
    input wire [31:0] a,
    input wire [4:0] b,
    output wire [31:0] out
);
// module for shift right logical function
assign out = a>>b;
    
endmodule



module cout_mux (
    output reg c_out,
    input wire cout_sum,
    input wire mux_in
);
// mux to set the carry_out of ALU
wire zero;
assign zero = 0;

always@(*) begin
    case (mux_in)
        0: c_out <= cout_sum;
        default: c_out <= zero;
    endcase
end
    
endmodule



module output_mux (
    output reg [31:0] out,
    input wire [31:0] sum_out,
    input wire [31:0] and_out,
    input wire [31:0] or_out,
    input wire [31:0] nor_out,
    input wire [31:0] sll_out,
    input wire [31:0] srl_out,
    input wire [31:0] slt_out,
    input wire [31:0] slteq_out,
    input wire [31:0] eq_out,

    input wire [31:0] neq_out,
    input wire [31:0] gt_out,
    input wire [31:0] gteq_out,

    input wire [3:0] mux_in
);
// this mux is used to select the output, from the outputs of adders, or, and etc.

wire [31:0] zero;
assign zero = 0;

always@(*) begin
    case (mux_in)
        4'b0000: out <= sum_out;
        4'b0001: out <= or_out;
        4'b0010: out <= and_out;
        4'b0011: out <= nor_out;
        4'b0100: out <= slt_out;
        4'b0101: out <= slteq_out;
        4'b0110: out <= eq_out;
        4'b0111: out <= sll_out;
        4'b1000: out <= srl_out; 
        4'b1001: out <= neq_out;
        4'b1010: out <= gt_out;
        4'b1011: out <= gteq_out;
        default: out <= zero;
    endcase
end
    
endmodule