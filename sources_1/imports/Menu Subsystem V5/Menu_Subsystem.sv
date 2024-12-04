
module Menu_Subsystem(
//For Menu Selection
    input logic        clk,
    input logic        reset,
    input logic        in_mode,
    input logic        scale_val_in,
    input logic        hex_BCD_in,
    input logic        ADC_sel_in,
    
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
    logic [1:0] out_sel;
    logic [1:0] scale_sel;
    logic hex_BCD_sel;
    logic [1:0] ADC_sel;
    
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
        .in_1(PWM_raw),
        .in_2(PWM_ave),
        .in_3(PWM_scaled),
        .out(PWM_DAC_in),
        .select(scale_sel)
    );
    
     Mux_3 ave_sel_R2R (
        .in_1(R2R_raw),
        .in_2(R2R_ave),
        .in_3(R2R_scaled),
        .out(R2R_DAC_in),
        .select(scale_sel)
    );
    //Instantiate MUX3's for all ADC signals
    
    //Syncronizers and Debouncers for Buttons
    logic        in_mode_DB;
    logic        scale_val_in_DB;
    logic        hex_BCD_in_DB;
    logic        ADC_sel_in_DB;
    
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
        .button(ADC_sel_in),
        .result(ADC_sel_in_DB)
    );
    
    //Instantiate menu_FSM to take in
   menu_FSM FSM 
    (
        .reset(reset),
        .clk(clk),
        .in_mode(in_mode_DB),                       
        .scale_val_in(scale_val_in_DB),                  
        .hex_BCD_in(hex_BCD_in_DB),                    
        .out_sel(out_sel),  
        .scale_sel(scale_sel),
        .hex_BCD_sel(hex_BCD_sel),
        .successive_approx(successive_approx),
        .ADC_sel_in(ADC_sel_in_DB),
        .ADC_sel(ADC_sel)                    
    );
    //Create Multiplexers for pipeline
    
    //MUX 1: Select between Muxes
    logic [15:0] ADC_out;
    
    Mux_3 ADC_select (
        .in_1(XADC_in),
        .in_2(PWM_DAC_in),
        .in_3(R2R_DAC_in),
        .out(ADC_out),
        .select(ADC_sel)
     );
     
     //Associated Enables
     assign XADC_EN = (ADC_sel == 0) ? 1 : 0;
     assign R2R_EN = (ADC_sel == 1) ? 1 : 0;
     assign PWM_EN = (ADC_sel == 2) ? 1 : 0;
      
     //MUX 2: Input Selection (All 0, Switches, ADC)
     Mux_3 Input_pipeline_select (
        .in_1(0),
        .in_2(switches_in),
        .in_3(ADC_out),
        .out(bin_out),
        .select(out_sel)
     );
     
     //MUX 3: Choose between Binary and BCD
     always_comb
        if(hex_BCD_sel) seven_segment_in = bin_to_BCD_out;
        else            seven_segment_in = bin_out;
endmodule
