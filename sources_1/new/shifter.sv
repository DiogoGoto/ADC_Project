`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 11:28:03 PM
// Design Name: 
// Module Name: shifter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module shifter #(
    parameter int WIDTH = 16,
    parameter int SHIFT = 4
)
(
    input logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
    );

    assign out = in >>> SHIFT;
endmodule
