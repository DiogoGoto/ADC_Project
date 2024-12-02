//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 02:45:26 PM
// Design Name: 
// Module Name: ADC_OUT
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


module ADC_OUT(
    input logic clk,
    input logic reset,
    input logic comparator,
    output logic data_ready,
    input logic [15:0] duty_cycle,
    output logic [15:0] ADC_OUT
    );
    
    // Ensure the algorithm only produce a result when Vref goes above Vin
    edge_dectector FALLING_DETECTOR (
        .clk    (clk),
        .reset  (reset),
        .data_in(comparator),
        .pulse  (data_ready)
    );
    
    // Logic save the value when the comparator 
    always_ff @ (posedge  clk) begin
        if (reset) begin
            ADC_OUT <= 0;
        end
        else if(data_ready)begin
            ADC_OUT <= duty_cycle;
        end
        else begin
            ADC_OUT <= ADC_OUT;

        end   
    end
        
endmodule
