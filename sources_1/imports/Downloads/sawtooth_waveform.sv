// Triangle PWM and R2R Generator Module
// Generates a 1 Hz sawtooth waveform using PWM by adjusting the duty cycle.

module sawtooth_generator
    #(
        parameter int WIDTH = 8,                   // Bit width for duty_cycle
        parameter int CLOCK_FREQ = 100_000_000,    // System clock frequency in Hz
        parameter real WAVE_FREQ = 2000.0             // Desired triangle wave frequency in Hz
    )
    (
        input  logic clk,      // System clock (100 MHz)
        input  logic reset,    // Active-high reset
        input  logic enable,   // Active-high enable
        input  logic comparator, // Output from downcounter (enables duty_cycle update)
        output logic data_ready, // Pulse High when valid data is send to the output
        output logic [WIDTH-1:0]duty_cycle,  // PWM duty cycle output
        output logic [15:0] adc_out
    );

    // Calculate maximum duty cycle value based on WIDTH
    localparam int MAX_DUTY_CYCLE = (2 ** WIDTH) - 1;  // 255 for WIDTH = 8
    // Total steps for duty_cycle (up and down)
    localparam int TOTAL_STEPS = MAX_DUTY_CYCLE * 2;   // 510 steps
    // Calculate downcounter PERIOD to achieve desired wave frequency
    localparam int DOWNCOUNTER_PERIOD = integer'(CLOCK_FREQ / (WAVE_FREQ * TOTAL_STEPS));

    // Ensure DOWNCOUNTER_PERIOD is positive
    initial begin
        if (DOWNCOUNTER_PERIOD <= 0) begin
            $error("DOWNCOUNTER_PERIOD must be positive. Adjust CLOCK_FREQ or WAVE_FREQ.");
        end
    end

    // Internal signals
    logic zero;              
    //logic [WIDTH-1:0] duty_cycle; // Duty cycle value for PWM
  

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
        if (reset) begin
            duty_cycle <= 0;    // Initialize duty_cycle to 0 on reset
        end else if (enable) begin
            if (zero) begin
                if (duty_cycle == MAX_DUTY_CYCLE) begin
                   duty_cycle <= 0;
                end else begin
                    duty_cycle <= duty_cycle + 1; // Increment duty_cycle
                end
            end
            else duty_cycle <= duty_cycle;
            
        end else begin
            // Optionally reset duty_cycle when enable is low
            duty_cycle <= 0;
        end
    end
    
    // Output Logic
    always_ff @(posedge clk) begin
        if(reset) begin
            data_ready <= 0;
        end
        else if(comparator) begin
                adc_out <= {4'b0, duty_cycle, 4'b0};
                data_ready <= 1;
        end
        else
        begin
                adc_out <= adc_out;
                data_ready <= 0;
        end 
    end


endmodule
