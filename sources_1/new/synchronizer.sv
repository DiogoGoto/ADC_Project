`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 04:09:09 PM
// Design Name: 
// Module Name: synchronizer
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


module synchronizer(
    input  logic clk,
    input  logic reset,
    input  logic in,
    output logic out
    );
    
    logic middle;
    
    always_ff @ (posedge clk)begin
        if(reset)begin
            middle <= 0;
            out    <= 0;
        end
        else begin 
            out <= middle;
            middle <= in;
        end
    end
endmodule
