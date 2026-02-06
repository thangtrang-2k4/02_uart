`timescale 1ns/1ps

module tb_tx;

    // -------------------------------------------------
    // Parameters
    // -------------------------------------------------
    localparam int DBIT    = 8;
    localparam int DB_TICK = 16;
    localparam int SB_TICK = 16;

    // Baud-rate divider (small value for fast simulation)
    localparam int M = 8;

    // -------------------------------------------------
    // Signals
    // -------------------------------------------------
    logic clk;
    logic rst_n;

    logic tick;
    logic tx_start;
    logic [DBIT-1:0] din;

    logic tx;
    logic tx_done_tick;

    // -------------------------------------------------
    // Clock generation (100 MHz)
    // -------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------------------------------
    // DUT: baud_rate
    // -------------------------------------------------
    baud_rate #(
        .M(M)
    ) u_baud_rate (
        .clk   (clk),
        .rst_n (rst_n),
        .tick  (tick)
    );

    // -------------------------------------------------
    // DUT: tx
    // -------------------------------------------------
    tx #(
        .DBIT(DBIT),
        .DB_TICK(DB_TICK),
        .SB_TICK(SB_TICK)
    ) u_tx (
        .clk          (clk),
        .rst_n        (rst_n),
        .tick         (tick),
        .tx_start     (tx_start),
        .din          (din),
        .tx           (tx),
        .tx_done_tick (tx_done_tick)
    );

    // -------------------------------------------------
    // Reset
    // -------------------------------------------------
    initial begin
        rst_n     = 0;
        tx_start = 0;
        din      = '0;

        #50;
        rst_n = 1;
    end

    // -------------------------------------------------
    // Test sequence
    // -------------------------------------------------
    initial begin
        // Wait reset release
        @(posedge rst_n);
        repeat(5) @(posedge clk);

        // ------------------------------
        // Send first byte
        // ------------------------------
        send_byte(8'h55);   // 01010101

        // Wait until transmission done
        wait (tx_done_tick);
        $display("[%0t] TX DONE (0x55)", $time);

        repeat(20) @(posedge clk);

        // ------------------------------
        // Send second byte
        // ------------------------------
        send_byte(8'hA3);

        wait (tx_done_tick);
        $display("[%0t] TX DONE (0xA3)", $time);

    end
    initial begin 
        #100000;

        $finish;
    end

    // -------------------------------------------------
    // Task: send one UART byte
    // -------------------------------------------------
    task send_byte(input logic [DBIT-1:0] data);
        begin
            @(posedge clk);
            din      <= data;
            tx_start <= 1'b1;

            @(posedge clk);
            tx_start <= 1'b0;

            $display("[%0t] SEND BYTE = 0x%0h", $time, data);
        end
    endtask

    // -------------------------------------------------
    // Monitor (optional but very helpful)
    // -------------------------------------------------
    initial begin
        $monitor("[%0t] tx=%b state tx_done=%b",
                 $time, tx, tx_done_tick);
    end

endmodule
