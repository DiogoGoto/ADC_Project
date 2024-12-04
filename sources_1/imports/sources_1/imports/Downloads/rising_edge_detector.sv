
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 09:40:46 AM
// Design Name: 
// Module Name: edge_detector_and_synchronizer
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


module rising_edge(
    input logic clk,
    input logic reset,
    input logic in,
    output logic out
    );
    
    logic old_in;

    
    always_ff @(posedge clk) begin
        if(reset) old_in <= 0;
        else old_in <= in;
    end
           
    assign out = ~old_in && in;
    
endmodule
