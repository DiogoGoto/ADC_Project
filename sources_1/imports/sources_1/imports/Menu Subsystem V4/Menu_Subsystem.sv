
module Menu_Subsystem(
//For Menu Selection
    input logic        clk,
    input logic        reset,
    input logic        in_mode,            // 
    input logic        scale_val_in,       //
    input logic        hex_BCD_in,
    input logic        adc_sel_in,
    
//Interactions with outer modules: For the Bin_to_BCD module
    input logic [15:0] switches_in,
    output logic [15:0] bin_out,
    
//Inputs for XADC
    input logic [15:0] XADC_raw,XADC_ave,XADC_scaled,
//Inputs for PWM Ramp ADC
                       PWM_raw, PWM_ave, PWM_scaled,
//Inputs for R2R DAC
                       R2R_raw, R2R_ave, R2R_scaled,
                       
//Interaction with seven segment display
    input logic [15:0] bin_to_BCD_out,
    output logic [15:0] seven_segment_in,
//Interaction with ADC/DAC processing
    output logic successive_approx,
    output logic XADC_EN, R2R_EN, PWM_EN
);
    //Initialize intermediate signals
    logic [1:0] scale_sel;
    logic [1:0] adc_sel;
    logic [1:0] mode_sel;
    logic hex_BCD_sel;
    
    //Syncronizers and Debouncers for Buttons
    logic        in_mode_DB;
    logic        scale_val_in_DB;
    logic        hex_BCD_in_DB;
    logic        adc_sel_in_DB;
    
    debounce DB1(
        .clk(clk),
        .reset(reset),
        .button(in_mode),
        .result(in_mode_DB)
    );
    
        debounce DB2(
        .clk(clk),
        .reset(reset),
        .button(scale_val_in),
        .result(scale_val_in_DB)
    );
    
        debounce DB3(
        .clk(clk),
        .reset(reset),
        .button(hex_BCD_in),
        .result(hex_BCD_in_DB)
    );

     debounce DB4(
        .clk(clk),
        .reset(reset),
        .button(adc_sel_in),
        .result(adc_sel_in_DB)
    );

    //Instantiate menu_FSM to take in
   menu_FSM FSM 
    (
        .clk            (clk),
        .reset          (reset),
        .in_mode        (in_mode_DB),                       
        .scale_val_in   (scale_val_in_DB),                  
        .hex_BCD_in     (hex_BCD_in_DB), 
        .ADC_sel_in     (adc_sel_in_DB),

        .pwm_en         (PWM_EN),
        .r2r_en         (R2R_EN),
        .sar_en         (successive_approx),     
        .xadc_en        (XADC_EN),       

        .adc_sel        (adc_sel),
        .scale_sel      (scale_sel),  
        .hex_BCD_sel    (hex_BCD_sel),
        .mode_sel       (mode_sel)
    );
   
    //shifting raw data to fix locaiton
    logic [15:0] shifted_pwm, shifted_r2r;

    shifter PWM_SHIFTER (
        .in  (PWM_raw),
        .out (shifted_pwm)
    );

    shifter R2R_SHIFTER (
        .in  (R2R_raw),
        .out (shifted_r2r)
    );

    //Intermediate signals AFTER averaging MUX:
    logic [15:0] PWM_DAC_in, R2R_DAC_in, XADC_in;
    Mux_3 ave_sel_XADC (
        .in_1(XADC_raw),
        .in_2(XADC_ave),
        .in_3(XADC_scaled),
        .out(XADC_in),
        .select(scale_sel)
    );
    
    Mux_3 ave_sel_PWM (
        .in_1(shifted_pwm),
        .in_2(PWM_ave),
        .in_3(PWM_scaled),
        .out(PWM_DAC_in),
        .select(scale_sel)
    );
    
     Mux_3 ave_sel_R2R (
        .in_1(shifted_r2r),
        .in_2(R2R_ave),
        .in_3(R2R_scaled),
        .out(R2R_DAC_in),
        .select(scale_sel)
    );
    //Instantiate MUX3's for all ADC signals
    
    //Create Multiplexers for pipeline
    //MUX 1: FOR BETWEEN DAC/ADC MODULES AND BIN TO BCD
    logic [15:0] ADC_out;

    Mux_3 ADCs_MUX (
        .in_1(PWM_DAC_in),
        .in_2(R2R_DAC_in),
        .in_3(XADC_in),
        .out(ADC_out),
        .select(adc_sel)
    );

    Mux_3 OUTPUT_MUX (
        .in_1(16'b0000000000000000),
        .in_2(switches_in),
        .in_3(ADC_out),
        .out(bin_out),
        .select(mode_sel)
    );
    //MUX 2: FOR BETWEEN BIN TO BCD AND SEVEN SEGMENT MODULE    
    always_comb begin : MUX_HEX_BCD
        if(hex_BCD_sel == 1)
            seven_segment_in = bin_out;
        else
            seven_segment_in = bin_to_BCD_out;  
     
    end
     
endmodule
