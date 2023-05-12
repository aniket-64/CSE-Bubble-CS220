/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

module full_adder(
    input wire a,
    input wire b,
    input wire c_in,
    output wire sum,
    output wire c_out
);

wire temp_1;
wire temp_2, temp_3, temp_4;

xor xor_1(temp_1, a, b);
xor xor_2(sum, temp_1, c_in);

or or_1(temp_2, a, b);
and and_1(temp_3, temp_2, c_in);
and and_2(temp_4, a, b);
or or_2(c_out, temp_3, temp_4);

// gate logic for full adder

endmodule