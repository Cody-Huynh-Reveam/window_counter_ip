`timescale 1ns / 1ps

module tb_window_count;

    // Parameters
    parameter NUM_SLOTS = 6;        // Number of slots in the array
    parameter WIDTH = 16;           // Bit width for counters
    parameter TIME_LIMIT = 3000;    // Time limit for counters

    // Testbench signals
    reg clk;
    reg resetn;
    reg eventTrigger;
    reg [15:0] time_limit;
    wire [3:0] arkCount;            // Count of active slots
    wire out;                       // Output signal if all slots are active
    wire [WIDTH-1:0] counter_test0;
    wire [WIDTH-1:0] counter_test1;
    wire [WIDTH-1:0] counter_test2;
    wire [WIDTH-1:0] counter_test3;

    // Instantiate the window_count module
    window_count #(
        .NUM_SLOTS(NUM_SLOTS),
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .resetn(resetn),
        .eventTrigger(eventTrigger),
        .TIME_LIMIT(time_limit),
        .arkCount(arkCount),
        .out(out),
        .counter_test0(counter_test0),
        .counter_test1(counter_test1),
        .counter_test2(counter_test2),
        .counter_test3(counter_test3)
    );

    // Clock generation: 10 kHz clock period = 100,000 ns
    initial begin
        clk = 0;
        forever #50 clk = ~clk; // Toggle clock every 50 ns (10 kHz)
    end

    // Stimulus process
    initial begin
        // Initialize signals
        resetn = 0;
        eventTrigger = 0;
        time_limit = TIME_LIMIT; // Set time limit to 3000

        // Apply reset
        #100;
        resetn = 1; // Release reset
        #50;

        // Trigger events
        repeat (6) begin
            #200; // Wait for 200 ns between events
            eventTrigger = 1; // Assert event trigger
            #100; // Hold trigger high
            eventTrigger = 0; // Deassert event trigger
        end

        // Wait for some time to observe outputs
        #10000; // Wait long enough to observe counter increments and resets

        // Finish simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | arkCount: %d | out: %b | counter_test0: %d | counter_test1: %d | counter_test2: %d | counter_test3: %d", 
                  $time, arkCount, out, counter_test0, counter_test1, counter_test2, counter_test3);
    end

endmodule
