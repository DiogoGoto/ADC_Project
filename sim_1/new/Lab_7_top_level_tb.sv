`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 09:10:24 PM
// Design Name: 
// Module Name: Lab_7_top_level_tb
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


module Lab_7_top_level_tb();

    // Local parameters
    //============================================================================
    localparam CLK_PERIOD = 10; // System clock period in ns
    localparam INDEX_DELAY = 62_500; //ns = 62.5us
    //============================================================================

    //Inputs
    //============================================================================
    logic clk = 0; // System clock (100 MHz)
    logic reset = 1; // Active-high reset
    
    logic [2:0] mode_select= 3'b010;
    logic [1:0] bin_bcd_select=2'b10;
    logic comparator; // Comparator input
    // Comparator input

    //Outputs
    logic CA, CB, CC, CD, CE, CF, CG, DP, AN1, AN2, AN3, AN4, pwm_out, buzzer_out;
    logic [15:0] led;
    logic [7:0] R2R_out;
    //============================================================================

    // Clock generation
    //============================================================================
    initial begin
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    //============================================================================


    // Instantiate the r2r_adc module
    //============================================================================
    lab_7_top_level DUT (
        .clk            (clk),
        .reset          (reset),
        .bin_bcd_select (bin_bcd_select),
        .mode_select    (mode_select),
        .comparator     (comparator),
        //.vauxp15(), // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
        //.vauxn15(), // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4),
        .led            (led),
        .pwm_out        (pwm_out),
        .buzzer_out     (buzzer_out),
        .R2R_out        (R2R_out)
    );                        // not required, i.e. .R2R_out()
    //============================================================================


    // Simulation logic
    //============================================================================
    initial begin
        // Reset the system
        reset = 1;
        comparator = 0;
        #30;
        reset = 0;
        #5;
        // setup
        bin_bcd_select = 2'b10;
        mode_select=3'b010;
        
        for (int i = 0; i<20; i++) begin
        // Comparator signal
        comparator = 1; //bit 7
        #INDEX_DELAY; // 62.5 us
        comparator = 1; //bit 6
        #INDEX_DELAY; // 62.5 us
        comparator = 0; //bit 5
        #INDEX_DELAY; // 62.5 us
        comparator = 1; //bit 4
        #INDEX_DELAY; // 62.5 us
        comparator = 1; //bit 3
        #INDEX_DELAY; // 62.5 us
        comparator = 0; //bit 2
        #INDEX_DELAY; // 62.5 us
        comparator = 1; //bit 1
        #INDEX_DELAY; // 62.5 us
        comparator = 0; //bit 0
        #INDEX_DELAY; // 62.5 us
        #INDEX_DELAY; // 62.5 us
        #INDEX_DELAY; // 62.5 us
        end
        
        // End simulation
        $stop;
    end
//============================================================================
endmodule
