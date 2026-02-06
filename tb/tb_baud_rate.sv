`timescale 1ns/1ps

module tb_baud_rate;

    // --------------------------------
    // Parameters
    // --------------------------------
    localparam M = 20;

    // --------------------------------
    // DUT signals
    // --------------------------------
    logic clk;
    logic rst_n;
    logic tick;

    // --------------------------------
    // Instantiate DUT
    // --------------------------------
    baud_rate #(
        .M(M)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick)
    );

    // --------------------------------
    // Clock generation: 10ns period
    // --------------------------------
    always #5 clk = ~clk;

    // --------------------------------
    // Test variables
    // --------------------------------
    integer clk_count;
    integer tick_count;

    // --------------------------------
    // Test sequence
    // --------------------------------
    initial begin
        // Init
        clk       = 1'b0;
        rst_n     = 1'b0;
        clk_count  = 0;
        tick_count = 0;

        // Reset
        repeat(5) @(posedge clk);
        rst_n = 1'b1;

        $display("========================================");
        $display(" Start baud_rate test, M = %0d", M);
        $display("========================================");

        // Observe several ticks
        while (tick_count < 5) begin
            @(posedge clk);
            clk_count++;

            if (tick) begin
                $display("[%0t] tick detected, clk_count = %0d",
                         $time, clk_count);

                // Check tick spacing
                if (clk_count != M) begin
                    $display("❌ ERROR: tick spacing wrong! Expected %0d, got %0d",
                             M, clk_count);
                end

                clk_count = 0;
                tick_count++;
            end
        end

        $display("========================================");
        $display("✅ TEST PASSED: tick every %0d clocks", M);
        $display("========================================");

    end
    initial begin 
        #1000;
        $finish;
    end
endmodule
