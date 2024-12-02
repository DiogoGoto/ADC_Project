//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2024 08:26:36 AM
// Design Name: 
// Module Name: ADC_Project_Top_Level
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


module ADC_Project_Top_Level(
        input  logic        clk,
        input  logic        reset,
        input  logic [15:0] switches_in,
        input  logic        comp_r2r, 
        input  logic        comp_pwm,
        input               vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
        input               vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
        input logic         adc_mode_bt,
        input logic         scaled_mode_bt,
        input logic         display_mode_bt,
        output logic        CA, CB, CC, CD, CE, CF, CG, DP,
        output logic        AN1, AN2, AN3, AN4,
        output logic        pwm_out,
        output logic [7:0]  R2R_out
    );



    // Internal signal declarations
    //============================================================================
    // XADC Signals
    logic        xadc_en;               // XADC enable
    logic        xadc_ready;            // Data ready from XADC
    logic        xadc_ready_pulse;      // Ready Pulse from XADC
    logic [15:0] xadc_raw;              // Raw ADC data
    logic [15:0] xadc_ave;              // Data Avareraged but not scaled
    logic [15:0] xadc_scaled;           // Scaled ADC data for display, plus pipelinging register
    logic [6:0]  daddr_in;              // XADC address
    //logic [4:0]  channel_out;         // Current XADC channel
    //logic        eoc_out;             // End of conversion
    logic        eos_out;               // End of sequence
    logic        busy_out;              // XADC busy signal
    // PWM ADC
    logic        pwm_en;                // PWM ADC enable
    logic        pwm_ready;             // Data ready from PWM
    logic [15:0] pwm_raw;               // Raw ADC data
    logic [15:0] pwm_ave;               // Data Avareraged but not scaled
    logic [15:0] pwm_scaled;            // Scaled ADC data for display, plus pipelinging register

    // R2R ADC 
    logic        r2r_en;                 // R2R ADC enable
    logic        r2r_ready;              // Data ready from R2R
    logic [15:0] r2r_raw;                // Raw ADC data
    logic [15:0] r2r_ave;                // Data Avareraged but not scaled
    logic [15:0] r2r_scaled;             // Scaled ADC data for display, plus pipelinging register


    //Other Signals
    logic        sa_en;                   // Enable signal for successive approximation
    logic [15:0] bin_values;              // Hold the values for the HEX to BCD converter
    logic [15:0] bcd_values;              // Holds the conversion of the hex to bcd
    logic [15:0] display_values;          // Values to be displayed
    //============================================================================

    // Constants
    localparam CHANNEL_ADDR = 7'h1f;     // XA4/AD15 (for XADC4)
        

    // Menu Sub System
    //============================================================================
    Menu_Subsystem MENU_SUBSYSTEM(
        //For Menu Selection
        .clk            (clk),
        .reset          (reset),
        .in_mode        (adc_mode_bt), // button select ADC
        .scale_val_in   (scaled_mode_bt), // Averaging mode and change algorithm
        .hex_BCD_in     (display_mode_bt), // selects btw BCD and Hex
        //Interactions with outer modules: For the Bin_to_BCD module
        .switches_in    (switches_in), //[15:0]
        .bin_out        (bin_values), // [15:0]
        //Inputs for XADC
        .XADC_raw(xadc_raw), .XADC_ave(xadc_ave), .XADC_scaled(xadc_scaled), //[15:0] 
        //Inputs for PWM Ramp ADC
        .PWM_raw(pwm_raw), .PWM_ave(pwm_ave), .PWM_scaled(pwm_scaled),
        //Inputs for R2R DAC
        .R2R_raw(r2r_raw), .R2R_ave(r2r_ave), .R2R_scaled(r2r_scaled),                      
        //Interaction with seven segment display
        .bin_to_BCD_out(bcd_values), //[15:0] //Output of the Bin to BCD converter
        .seven_segment_in(display_values), //[15:0]        //Input to the display subsystem
        //Interaction with ADC/DAC processing
        .successive_approx(sa_en),
        .XADC_EN(xadc_en), .R2R_EN(r2r_en), .PWM_EN(pwm_en)
    );
    //============================================================================
    
    // Display Subsystem
    //============================================================================
    //  BIN to BCD Converter
        bin_to_bcd BIN2BCD (
        .clk    (clk),
        .reset  (reset),
        .bin_in (bin_values),
        .bcd_out(bcd_values)
    );

    // Seven Segment Display Subsystem
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk            (clk), 
        .reset          (reset), 
        .sec_dig1       (display_values[3:0]),     // Lowest digit
        .sec_dig2       (display_values[7:4]),     // Second digit
        .min_dig1       (display_values[11:8]),    // Third digit
        .min_dig2       (display_values[15:12]),   // Highest digit
        .decimal_point  (decimal_pt),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), 
        .CE(CE), .CF(CF), .CG(CG), .DP(DP), 
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    //============================================================================    

    // XADC 
    //============================================================================
    // XADC instantiation
    xadc_wiz_0 XADC_INST (
        .di_in      (16'h0000),        // Not used for reading
        .daddr_in   (CHANNEL_ADDR),    // Channel address
        .den_in     (xadc_en),         // Enable signal
        .dwe_in     (1'b0),            // Not writing, so set to 0
        .drdy_out   (xadc_ready),      // Data ready signal (when high, ADC data is valid)
        .do_out     (xadc_raw),       // ADC data output
        .dclk_in    (clk),             // Use system clock
        .reset_in   (reset),           // Active-high reset
        .vp_in      (1'b0),            // Not used, leave disconnected
        .vn_in      (1'b0),            // Not used, leave disconnected
        .vauxp15    (vauxp15),         // Auxiliary analog input (positive)
        .vauxn15    (vauxn15),         // Auxiliary analog input (negative)
        .channel_out(),                // Current channel being converted
        .eoc_out    ()      ,         // End of conversion
        .alarm_out  (),                // Not used
        .eos_out    (eos_out),         // End of sequence
        .busy_out   (busy_out)         // XADC busy signal
    );

    // Pulser
    rising_edge XADC_READY_PULSER (
        .clk    (clk),
        .reset  (reset),
        .in     (xadc_ready),
        .out    (xadc_ready_pulse)
    );
    
    // Instantiate the adc_processing module
    adc_processing #(
        .SCALING_FACTOR (310866),
        .SHIFT_FACTOR   (19),
        .NEGATIVE_FACTOR (12)
    )
    XADC_PROC (
        .clk             (clk),
        .reset           (reset),
        .ready           (xadc_ready_pulse), // MIGHT NOT WORK needs to be a 1-clk cycle pulse 
        .data            (xadc_raw), //input [15:0] data,
        .ave_data        (xadc_ave),
        .scaled_adc_data (xadc_scaled)
    );
    //============================================================================

    // PWM ADC (WIP)
    //============================================================================

    pwm_adc #(
        .WIDTH             (8),           // Bit width for duty_cycle
        .CLOCK_FREQ        (100_000_000), // Clock frequency (in Hz)
        .SAMPLING_FREQ     (2000)         // Sampling frequency(in Hz) 
    )
    PWM_ADC (
        .clk        (clk),
        .reset      (reset),
        .pwm_en     (pwm_en),
        .sa_en      (sa_en),
        .comparator (comp_pwm),
        .data_ready (pwm_ready),
        .adc_out    (pwm_raw), //[15:0] 
        .pwm_out    (pwm_out)  //
    );

    adc_processing #(
        .SCALING_FACTOR  (310866),
        .SHIFT_FACTOR    (19),
        .NEGATIVE_FACTOR (12)
    )
    PWM_PROC (
        .clk             (clk),
        .reset           (reset),
        .ready           (pwm_ready),
        .data            (pwm_raw), //input [15:0] data,
        .ave_data        (pwm_ave),
        .scaled_adc_data (pwm_scaled)
        );
    //============================================================================

    // R2R ADC
    //============================================================================
    r2r_adc #(
        .WIDTH             (8),           // Bit width for duty_cycle
        .CLOCK_FREQ        (100_000_000), // Clock frequency (in Hz)
        .SAMPLING_FREQ     (2000)         // Sampling frequency(in Hz) 
    )    R2R_ADC (
        .clk        (clk),
        .reset      (reset),
        .r2r_en     (r2r_en),
        .sa_en      (sa_en),
        .comparator (comp_r2r),
        .data_ready (r2r_ready),
        .adc_out    (r2r_raw), //[15:0] 
        .r2r_out    (R2R_out)  //[WIDTH-1:0] 
    );

    adc_processing #(
        .SCALING_FACTOR  (310866),
        .SHIFT_FACTOR    (19),
        .NEGATIVE_FACTOR (12)
    )
    R2R_PROC (
        .clk             (clk),
        .reset           (reset),
        .ready           (r2r_ready),
        .data            (r2r_raw), //input [15:0] data,
        .ave_data        (r2r_ave),
        .scaled_adc_data (r2r_scaled)
        );
    //============================================================================

endmodule