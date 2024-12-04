
module menu_FSM
    (
    input logic        clk,
    input logic        reset,

    //Debounced Buttons
    input logic        in_mode,
    input logic        scale_val_in,
    input logic        hex_BCD_in,
    input logic        ADC_sel_in,

    //Enables
    output logic pwm_en,
    output logic r2r_en,
    output logic sar_en,
    output logic xadc_en,

    // Selects
    output logic [1:0] adc_sel,
    output logic [1:0] scale_sel,
    output logic       hex_BCD_sel,
    output logic [1:0] mode_sel

    );
    
    //Internal Signals
    //====================================================================================
    // Rising Edge pulses
    logic HEX_out;
    logic scale_out;
    logic mode_out;
    logic ADC_sel_out;
    //====================================================================================
    
    // Rising Edge Detector 
    //====================================================================================
    Button_Transition_Detector b1 (
        .reset(reset),
        .clk(clk),
        .sig_in(in_mode),
        .sig_out(mode_out)
    );
    
        Button_Transition_Detector b2 (
        .reset(reset),
        .clk(clk),
        .sig_in(scale_val_in),
        .sig_out(scale_out)
    );
    
        Button_Transition_Detector b3 (
        .reset(reset),
        .clk(clk),
        .sig_in(hex_BCD_in),
        .sig_out(HEX_out)
    );
    
    Button_Transition_Detector b4 (
        .reset(reset),
        .clk(clk),
        .sig_in(ADC_sel_in),
        .sig_out(ADC_sel_out)
    );
    //====================================================================================

    // FMS
    //====================================================================================
    // ADC Select
    adc_sel_FMS ADC_SEL_FSM (
        .clk        (clk),
        .reset      (reset),
        .adc_bt     (ADC_sel_out),
        .adc_sel    (adc_sel),
        .pwm_en     (pwm_en),
        .r2r_en     (r2r_en),
        .sar_en     (sar_en),
        .xadc_en    (xadc_en)
    );

    // Scale Select
    scaled_FSM SCALE_SEL_FSM (
        .clk        (clk),
        .reset      (reset),
        .scale_bt   (scale_out),
        .scale_sel  (scale_sel)
    );

    //Bin to BCD Select
    bin_BCD_FSM BIN_BCD_SEL_FSM (
        .clk        (clk),
        .reset      (reset),
        .bin_bcd_bt (HEX_out),
        .hex_bcd_sel(hex_BCD_sel)
    );

    // Mode Select
    mode_FSM MODE_SEL_FSM (
        .clk        (clk),
        .reset      (reset),
        .mode_bt    (mode_out),
        .mode_sel   (mode_sel)
    );
    //====================================================================================

/*
    always_ff @ (posedge clk) begin //Counter 1: Input select (All zeros, Switches, ADC's)    
        if (reset)
            out_sel <= 'b0;
        else if (mode_out == 1) begin
            if(out_sel < 2)
                out_sel <= out_sel + 1;
            else
                out_sel <= 0;
        end
    end

    always_ff @ (posedge clk) begin //Counter 2: BCD or HEX      
            if (reset)
                hex_BCD_sel <= 0;
            else if (HEX_out == 1) begin //Input mode counter
                hex_BCD_sel = ~hex_BCD_sel;
        end
     end
     
   always_ff @ (posedge  clk) begin //Counter 3: scaling Modality
        if(reset)
            scale_sel <= 0;
            
        else if (scale_out == 1)
        
            if(scale_sel < 2) scale_sel <= scale_sel + 1;
            else scale_sel <= 0;
        else scale_sel <= scale_sel;
   end
   
   //Modification: This changes how to switch the ADC modality, so we need a good way to select ADC's and the Successive approximation
   typedef enum logic [2:0] {S0,S1,S2,S3,S4} ADCstate;
   ADCstate state, next_state;
   
   always_ff @ (posedge clk)
   if(reset)
        state <= S0;
   else
        state <= next_state;
   
   //State Register for ADC select
   always_comb
        case(state)
            S0: next_state = ADC_sel_out ? S1 : S0;
            S1: next_state = ADC_sel_out ? S2 : S1;
            S2: next_state = ADC_sel_out ? S3 : S2;
            S3: next_state = ADC_sel_out ? S4 : S3;
            S4: next_state = ADC_sel_out ? S0 : S4;
            default: next_state = S0;
        endcase
   //Output logic for successive approx
   always_comb
        if (state == S1) successive_approx = 1;
        else if (state == S3) successive_approx = 1;
        else successive_approx = 0;
        
   //Output logic for ADC sel
      always_comb
        case(state)
            S0: ADC_sel = 0;
            S1: ADC_sel = 0;
            S2: ADC_sel = 1;
            S3: ADC_sel = 1;
            S4: ADC_sel = 2;
            default: ADC_sel = 0;
        endcase
   
*/  
endmodule
