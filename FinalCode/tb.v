/*
Name: Aniket Suhas Borkar, Rollno. 210135
Name: Vikas Yadav, Rollno. 211166
*/

`timescale 1ns/1ps
`include "top.v"

module tb();

reg clk,rst;

top_module uut (rst , clk);

initial begin
    rst=1;
    #6 rst=0;
end

initial begin
    clk=0;
    forever begin
        #5; clk = ~clk;
    end
end

initial begin
    $dumpfile("newtb.vcd");
    $dumpvars(0,tb);
    #5000 $finish;
end

endmodule


