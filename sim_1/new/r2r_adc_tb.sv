`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 06:45:47 PM
// Design Name: 
// Module Name: r2r_adc_tb
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

//TESTBENCH FOR R2R_ADC MODULE
module r2r_adc_tb();

    // Local parameters
    //============================================================================
    localparam CLK_PERIOD = 10; // System clock period in ns
    //============================================================================

    //Inputs
    //============================================================================
    logic clk = 0; // System clock (100 MHz)
    logic reset = 1; // Active-high reset
    
    logic enable; // Active-high enable
    logic comparator; // Comparator input

    //Outputs
    logic [15:0] data; // ADC data output
    logic [7:0] R2R_out_internal; // R2R ladder output
    //============================================================================

    // Clock generation
    //============================================================================
    initial begin
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    //============================================================================


    // Instantiate the r2r_adc module
    //============================================================================
        r2r_adc #(
        .WIDTH      (8),           // Bit width for duty_cycle (e.g. 8)
        .CLOCK_FREQ (100_000_000), // System clock frequency in Hz (e.g. 100_000_000)
        .WAVE_FREQ  (1000)    // Desired triangle wave frequency in Hz (e.g. 1.0)
    ) DUT (
        .clk        (clk),                   // Connect to system clock
        .reset      (reset),               // Connect to system reset
        .enable     (enable),        // Connect to enable signal
        .comparator (comparator),     // Connect to comparator signal
        .R2R_out    (R2R_out_internal),  // Connect to R2R ladder header, can leave empty if 
        .ADC_OUT    (data)
    );                                  // not required, i.e. .R2R_out()
    //============================================================================


    // Simulation logic
    //============================================================================
    initial begin
        // Reset the system
        reset = 1;
        enable = 0;
        comparator = 0;
        #30;
        reset = 0;
        #5;

        // Enable the system
        enable = 1;

        // Comparator signal
        comparator = 1;
        #500000; // 500 us
        comparator = 0;
        #500000;
        comparator = 1;
        #750000; // 750 us
        comparator = 0;
        #300000;
        // End simulation
        $finish;
    end
//============================================================================

endmodule
