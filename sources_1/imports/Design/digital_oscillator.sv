`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2024 12:43:13 PM
// Design Name: 
// Module Name: digital_oscillator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module digital_oscillator
    #(
    parameter N=8
    )
    
    (
    input logic clk,
    input logic reset,
    input logic [N-1:0] increment,
    input logic [N-1:0] soft_max,
    output logic [N-1:0] count,
    output logic F_out
    );
    always_ff @ (posedge clk) begin
        if (reset)
            count <= 0;
        else if (count > soft_max)
            count <= 0;
        else
            count <= count + increment;
    end
    
    assign F_out  = (count == 0) ? 1 : 0;
            
    
    
endmodule
