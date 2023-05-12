/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

module data_mem(
    input wire [7:0] address,
    input wire write_enable,
    input wire [7:0] write_address,
    input wire [31:0] write_data,
    output wire [31:0] instr_out
);

// this module stores the data - i.e. the array of numbers to be sorted

reg signed [31:0] memory [255:0];

assign instr_out = memory[address];
integer i;

initial begin
    //array to  be sorted
    memory[0] = 32'd431;
    memory[1] = 32'd4;
    memory[2] = 32'd1;
    memory[3] = 32'd3;
    memory[4] = 32'd0;
    memory[5] = 32'd341;
    memory[6] = 32'd2;
    memory[7] = 32'd5;
    memory[8] = 32'd4294967287; // represents -9, i.e. two's complement of 9
    memory[9] = 32'd64;
    for(i = 10; i<255; i = i+1) begin
        memory[i] = 0;
    end
end

initial begin
    // monitor allows us to see how the array changes as it is sorted
    $monitor("%d, %d, %d, %d, %d, %d, %d, %d, %d, %d", memory[0], memory[1], memory[2], memory[3], memory[4], memory[5], memory[6], memory[7], memory[8], memory[9]);
end

always @(posedge write_enable) begin
    // write when write_enable is high
    memory[write_address] <= write_data;
end

endmodule
