// Triangle PWM and R2R Generator Module
// Generates a 1 Hz triangle waveform using PWM by adjusting the duty cycle.

module ramp_generator
    #(
        parameter int WIDTH = 8,                   // Bit width for duty_cycle
        parameter int CLOCK_FREQ = 100_000_000,    // System clock frequency in Hz
        parameter real WAVE_FREQ = 1000            // Desired triangle wave frequency in Hz
    )
    (
        input  logic clk,      // System clock (100 MHz)
        input  logic reset,    // Active-high reset
        input  logic enable,   // Active-high enable
        input logic comparator, // Comparator input
        output logic data_ready, // Pulses high when data is ready
        output logic [WIDTH-1:0] R2R_out, // R2R ladder output
        output logic [15:0] ADC_OUT  // ADC output - 16-bits long but only 8 bits are used
    );

    // Calculate maximum duty cycle value based on WIDTH
    localparam int MAX_DUTY_CYCLE = (2 ** WIDTH) - 1;  // 255 for WIDTH = 8
    // Total steps for duty_cycle (up and down)
    localparam int TOTAL_STEPS = MAX_DUTY_CYCLE;   // 255 steps //512 only if its triangle shaped
    // Calculate downcounter PERIOD to achieve desired wave frequency
    localparam int DOWNCOUNTER_PERIOD = integer'(CLOCK_FREQ / (WAVE_FREQ * TOTAL_STEPS));

    // Ensure DOWNCOUNTER_PERIOD is positive
    initial begin
        if (DOWNCOUNTER_PERIOD <= 0) begin
            $error("DOWNCOUNTER_PERIOD must be positive. Adjust CLOCK_FREQ or WAVE_FREQ.");
        end
    end

    // Internal signals
    logic zero;                   // Output from downcounter (enables duty_cycle update)
    logic [WIDTH-1:0] duty_cycle; // Duty cycle value for PWM
    logic [15:0] extedend_duty_cycle;
    
    assign R2R_out = duty_cycle; // R2R ladder resistor circuit automatically generates the analog voltage
    assign extedend_duty_cycle = {4'b0, duty_cycle, 4'b0 }; // Extend duty cycle to 16-bits for ADC


    ADC_OUT ADC_R2R(    //Output of the ADC 
        .clk       (clk),             
        .reset     (reset),           
        .comparator(comparator),      
        .duty_cycle(extedend_duty_cycle),
        .data_ready(data_ready),
        .ADC_OUT   (ADC_OUT)
    );



    // Instantiate downcounter module
    downcounter #(
        .PERIOD(DOWNCOUNTER_PERIOD)  // Set downcounter period based on calculations
    ) downcounter_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),  // Use the enable input
        .zero(zero)       // Pulses high every DOWNCOUNTER_PERIOD clock cycles
    );


    // Duty cycle up/down counter logic
    always_ff @(posedge clk) begin
        if (reset)
            duty_cycle <= 0;    // Initialize duty_cycle to 0 on reset
        else if (enable) begin
            if (zero) begin
                    if (duty_cycle == MAX_DUTY_CYCLE) begin
                        duty_cycle <= 0;
                    end else begin
                        duty_cycle <= duty_cycle + 1; // Increment duty_cycle
                    end
            end
        end else begin
            // Optionally reset duty_cycle and dir when enable is low
            duty_cycle <= 0;
        end
    end
    


endmodule
