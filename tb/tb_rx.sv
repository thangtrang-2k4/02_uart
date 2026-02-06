`timescale 1ns/1ps

module tb_rx;

    // --------------------------------
    // Parameters
    // --------------------------------
    localparam int DBIT    = 8;
    localparam int SB_TICK = 16;
    localparam int DB_TICK = 16;

    // clock 100 MHz
    localparam int CLK_PERIOD = 10;

    // baud_rate divider
    // tick_freq = clk / M
    localparam int M = 54;

    // --------------------------------
    // Signals
    // --------------------------------
    logic clk;
    logic rst_n;
    logic tick;
    logic rx;

    logic [DBIT-1:0] dout;
    logic rx_done_tick;

    // --------------------------------
    // Clock generation
    // --------------------------------
    always #(CLK_PERIOD/2) clk = ~clk;

    // --------------------------------
    // Baud rate generator
    // --------------------------------
    baud_rate #(
        .M(M)
    ) baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick)
    );

    // --------------------------------
    // RX DUT
    // --------------------------------
    rx #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK),
        .DB_TICK(DB_TICK)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .tick(tick),
        .dout(dout),
        .rx_done_tick(rx_done_tick)
    );

    // --------------------------------
    // TASK: wait N tick
    // --------------------------------
    task wait_tick(input int n);
        int i;
        begin
            for (i = 0; i < n; i++)
                @(posedge tick);
        end
    endtask

    // --------------------------------
    // TASK: send one UART bit
    // --------------------------------
    task send_uart_bit(input logic bit_val);
        begin
            rx <= bit_val;
            wait_tick(DB_TICK);
        end
    endtask

    // --------------------------------
    // TASK: send one UART byte
    // --------------------------------
    task send_uart_byte(input logic [7:0] data);
        int i;
        begin
            // START bit
            send_uart_bit(1'b0);

            // DATA bits (LSB first)
            for (i = 0; i < DBIT; i++)
                send_uart_bit(data[i]);

            // STOP bit
            send_uart_bit(1'b1);
        end
    endtask

    // --------------------------------
    // Test sequence
    // --------------------------------
    initial begin
        // init
        clk   = 0;
        rx    = 1;   // idle = 1
        rst_n = 0;

        repeat (5) @(posedge clk);
        rst_n = 1;

        repeat (5) @(posedge clk);

        // --------------------------------
        // TEST 1
        // --------------------------------
        $display("[%0t] Sending 0xA5", $time);
        send_uart_byte(8'hA5);

        // wait RX done
        @(posedge clk);
        while (!rx_done_tick)
            @(posedge clk);

        $display("[%0t] RX DONE: dout = 0x%02X", $time, dout);

        if (dout == 8'hA5)
            $display("✅ TEST 1 PASSED");
        else
            $display("❌ TEST 1 FAILED");

        // --------------------------------
        // TEST 2
        // --------------------------------
        repeat (50) @(posedge clk);

        $display("[%0t] Sending 0x3C", $time);
        send_uart_byte(8'h3C);

        @(posedge clk);
        while (!rx_done_tick)
            @(posedge clk);

        $display("[%0t] RX DONE: dout = 0x%02X", $time, dout);

        if (dout == 8'h3C)
            $display("✅ TEST 2 PASSED");
        else
            $display("❌ TEST 2 FAILED");

    end
    initial begin
        #100000;
        $finish;
    end

endmodule
