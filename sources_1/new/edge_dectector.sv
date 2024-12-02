`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 04:05:09 PM
// Design Name: 
// Module Name: edge_dectector
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


module edge_dectector(
    input logic clk,
    input logic reset,
    input logic data_in,
    output logic pulse
    );
    
        logic old_data;
    
    // added these 3 lines for the pulser 
  always_ff@(posedge clk)
    if (reset)
       old_data <= 0;
    else
       old_data <= data_in;
       
  assign pulse = old_data && ~data_in; // generate 1-clk pulse when ready goes high
endmodule
