`include "fulladder.v"

/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

module adder (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire c_in,
    output wire [31:0] sum,
    output wire c_out
);

wire [30:0] temp_carry;
// temp wire to store carry

full_adder fa0(.a(a[0]), .b(b[0]), .c_in(c_in), .c_out(temp_carry[0]), .sum(sum[0]));
genvar i;
// generate block for instatiating 1 bit full adder
generate for ( i=0 ; i<30 ; i=i+1 ) begin : add_loop
        full_adder fa(.a(a[i+1]), .b(b[i+1]), .c_in(temp_carry[i]), .c_out(temp_carry[i+1]), .sum(sum[i+1]));
        end
endgenerate
full_adder fa31(.a(a[31]), .b(b[31]), .c_in(temp_carry[30]), .c_out(c_out), .sum(sum[31]));


endmodule