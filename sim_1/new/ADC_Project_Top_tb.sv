`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 10:18:47 PM
// Design Name: 
// Module Name: ADC_Project_Top_tb
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


module ADC_Project_Top_tb();

    // Local parameters
    //============================================================================
    localparam CLK_PERIOD = 10; // System clock period in ns
    localparam INDEX_DELAY = 62_500; //ns = 62.5us
    localparam MS_1 = 1_000_000;
    //============================================================================

    //Inputs
    //============================================================================
    logic clk = 0; // System clock (100 MHz)
    logic reset = 1; // Active-high reset

 
    logic        comp_r2r; // comp_r2r input
    logic        comp_pwm; // comp_r2r input
    logic        algorithm_sel_bt = 0;
    logic [15:0] switches_in = 16'b0;
    logic         adc_mode_bt = 0;
    logic         scaled_mode_bt = 0;
    logic         display_mode_bt= 0;
    

    //Outputs
    logic CA, CB, CC, CD, CE, CF, CG, DP, AN1, AN2, AN3, AN4;
    logic [7:0] R2R_out;
    logic pwm_out;
    //============================================================================

    // Clock generation
    //============================================================================
    initial begin
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    //============================================================================


    // Instantiate the r2r_adc module
    //============================================================================
    ADC_Project_Top_Level DUT (
        .clk             (clk),                                   
        .reset           (reset),                                 
        .switches_in     (switches_in),                           
        .comp_r2r        (comp_r2r),                              
        .comp_pwm        (comp_r2r),                              
        .adc_mode_bt     (adc_mode_bt),                           
        .scaled_mode_bt  (scaled_mode_bt),                        
        .display_mode_bt (display_mode_bt),
        .algorithm_sel_bt(algorithm_sel_bt),                      
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG), .DP(DP),        
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4),                                                    
        .pwm_out         (pwm_out),                               
        .R2R_out         (R2R_out)                       
    );                        // not required, i.e. .R2R_out()
    //============================================================================


    //Simulation Variables
    logic testvector [100000:0]; //Array of test bits
    logic [31:0] vectornum; //Index of the test vector

    // Simulation logic
    //============================================================================
    initial begin
        // Reset the system
        reset = 1;
        #30;
        reset = 0;
        #5;
        // setup
        #100;
        comp_r2r = 0 ;
        adc_mode_bt = 1; // Enables Successive approximations 

        #(51*MS_1);

        adc_mode_bt = 0;

        for (int i = 0; i<3; i++ ) begin
            #(51*MS_1); algorithm_sel_bt = ~algorithm_sel_bt;
            if(i>1)begin
                adc_mode_bt = ~adc_mode_bt;
            end
        end
            

        // Loads values
        for (int i = 0; i<280; i++) begin
            // comp_r2r signal
            comp_r2r = 1; //bit 7
            #INDEX_DELAY; // 62.5 us
            comp_r2r = 1; //bit 6
            #INDEX_DELAY; // 62.5 us
            comp_r2r = 0; //bit 5
            #INDEX_DELAY; // 62.5 us
            comp_r2r = 1; //bit 4
            #INDEX_DELAY; // 62.5 us
            comp_r2r = 1; //bit 3
            #INDEX_DELAY; // 62.5 us
            comp_r2r = 0; //bit 2
            #INDEX_DELAY; // 62.5 us
            comp_r2r = 1; //bit 1
            #INDEX_DELAY; // 62.5 us
            comp_r2r = 0; //bit 0
            #INDEX_DELAY; // 62.5 us
        end
        #(10 * MS_1)
        $stop;
    end

     //============================================================================
endmodule
