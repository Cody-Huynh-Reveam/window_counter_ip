`timescale 1ns / 1ps

// Module for counting events in an array of slots with individual counters
module window_count #(
    parameter NUM_SLOTS = 6,     // Number of slots in the array
    parameter WIDTH = 16          // Bit width for each counter
)( 
    input wire clk,              // Clock input
    input wire resetn,           // Active-low reset signal
    input wire eventTrigger,      // Trigger signal for counting events
    input wire [15:0] TIME_LIMIT, // Time limit for resetting counters
    output reg [3:0] arkCount,   // Count of currently active slots
    output wire out,              // Output signal indicating all slots are active
    output wire [WIDTH-1:0] counter_test0, // Test output for the first counter
    output wire [WIDTH-1:0] counter_test1, // Test output for the second counter
    output wire [WIDTH-1:0] counter_test2, // Test output for the third counter
    output wire [WIDTH-1:0] counter_test3  // Test output for the fourth counter
);

    // Array of counters for each slot
    reg [WIDTH-1:0] counters[NUM_SLOTS-1:0]; 
    // Assign test outputs to individual counters
    assign counter_test0 = counters[0];
    assign counter_test1 = counters[1];
    assign counter_test2 = counters[2];
    assign counter_test3 = counters[3];
    
    integer i;                   // Loop variable for iterations
    integer x;                   // Variable for tracking the current slot index

    // Initialize the slot index
    initial x = 0;

    // Initial block to set up the module's starting state
    initial begin
        arkCount <= 0; // Initialize active slot count to zero
        // Reset all counters to zero
        for (i = 0; i < NUM_SLOTS; i = i + 1) begin
            counters[i] <= 0; 
        end
    end

    // Always block triggered on the positive edge of the clock
    always @(posedge clk) begin
        if (!resetn) begin // Check for active-low reset
            // Reset all counters to zero on reset
            for (i = 0; i < NUM_SLOTS; i = i + 1) begin
                counters[i] <= 0; // Reset each counter
            end
            arkCount <= 0; // Reset active slot count
        end else begin
            // Iterate through each slot to update counters
            for (i = 0; i < NUM_SLOTS; i = i + 1) begin
                if (counters[i] > 0) begin // Only update if the counter is active
                    // Check if the counter has reached the TIME_LIMIT
                    if (counters[i] >= TIME_LIMIT) begin
                        counters[i] <= 0; // Reset the counter
                        arkCount <= arkCount - 1; // Decrement active count
                    end else begin
                        counters[i] <= counters[i] + 1; // Increment the counter
                    end
                end
            end
        end
    end

    // Always block triggered on the positive edge of the eventTrigger signal
    always @(posedge eventTrigger) begin
        arkCount <= arkCount + 1; // Increment the count of active slots
        // Check the current slot index and update the corresponding counter
        if (x < NUM_SLOTS-1) begin
            if (counters[x] == 0) begin
                counters[x] <= 1; // Activate the counter for the current slot
            end
        end else begin // Reset the index if it exceeds the number of slots
            if (counters[x] == 0) begin
                counters[x] <= 1; // Activate the counter for the current slot
            end
            x <= 0; // Reset the slot index to 0
        end
        x <= x + 1; // Move to the next slot index
    end

    // Output is high if the count of active slots equals the total number of slots
    assign out = (arkCount == NUM_SLOTS);

endmodule
