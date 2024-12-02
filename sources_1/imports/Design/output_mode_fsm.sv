module output_mode_fsm (
    input  logic clk,
    input  logic reset,
    input  logic [2:0] mode_select,  // Two-bit input for mode selection
    output logic pwm_enable,
    output logic r2r_enable,
    output logic buzzer_enable,
    output logic chrip_mode,
    output logic sawtooth_mode
);
    typedef enum logic [2:0] {
        OFF_MODE = 3'b000,
        PWM_MODE = 3'b001,
        R2R_MODE = 3'b010,
        SAWTOOTH_MODE = 3'b011,
        BUZZER_MODE = 3'b100,
        CHRIP_MODE = 3'b101
    } statetype;

    statetype current_state, next_state;

    // State register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= OFF_MODE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = statetype'(mode_select);  // Directly use mode_select as the next state
    end

    // Output logic
    always_comb begin
        pwm_enable = 0;
        r2r_enable = 0;
        buzzer_enable = 0;
        chrip_mode = 0;
        sawtooth_mode = 0;
        case (current_state)
            PWM_MODE:    pwm_enable = 1;
            R2R_MODE:    r2r_enable = 1;
            BUZZER_MODE: buzzer_enable = 1;
            CHRIP_MODE:  begin chrip_mode = 1; buzzer_enable = 1; end
            SAWTOOTH_MODE: begin sawtooth_mode = 1; pwm_enable = 1; end
            OFF_MODE:    ; // All outputs remain 0
            default:     ; // All outputs remain 0
        endcase
    end
endmodule