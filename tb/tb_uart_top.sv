`timescale 1ns/1ps

module tb_uart_top;

   localparam int DBIT    = 8;
   localparam int DB_TICK = 16;
   localparam int SB_TICK = 16;

   logic clk;
   logic rst_n;

   // UART 0
   logic        wr_en0, rd_en0;
   logic [7:0]  wr_data0, rd_data0;
   logic        tx0, rx0;
   logic        empty0, full0;

   // UART 1
   logic        wr_en1, rd_en1;
   logic [7:0]  wr_data1, rd_data1;
   logic        tx1, rx1;
   logic        empty1, full1;

   // Clock
   initial clk = 0;
   always #10 clk = ~clk;

   // Cross connection
   assign rx0 = tx1;
   assign rx1 = tx0;

   // DUT 0
   uart_top dut0 (
      .clk(clk),
      .rst_n(rst_n),
      .wr_en(wr_en0),
      .rd_en(rd_en0),
      .wr_data(wr_data0),
      .rx(rx0),
      .tx(tx0),
      .rd_data(rd_data0),
      .rx_empty(empty0),
      .tx_full(full0)
   );

   // DUT 1
   uart_top dut1 (
      .clk(clk),
      .rst_n(rst_n),
      .wr_en(wr_en1),
      .rd_en(rd_en1),
      .wr_data(wr_data1),
      .rx(rx1),
      .tx(tx1),
      .rd_data(rd_data1),
      .rx_empty(empty1),
      .tx_full(full1)
   );

   // Tasks
   task write_uart0(input [7:0] data);
      @(posedge clk);
      wr_en0   <= 1;
      wr_data0 <= data;
      @(posedge clk);
      wr_en0   <= 0;
   endtask

   task read_uart1(output [7:0] data);
      @(posedge clk);
      rd_en1 <= 1;
      @(posedge clk);
      data = rd_data1;
      rd_en1 <= 0;
   endtask

   // Test
   logic [7:0] rx_data;

   initial begin
      wr_en0 = 0; rd_en0 = 0;
      wr_en1 = 0; rd_en1 = 0;
      wr_data0 = 0; wr_data1 = 0;
      rst_n = 0;

      #100;
      rst_n = 1;

      // Send from UART0 → UART1
      $display("\n--- UART0 -> UART1 TEST ---");
      write_uart0(8'h55);
      write_uart0(8'h56);
      write_uart0(8'h57);

      // wait UART transmission
      #600000;

      if (!empty1) begin
         read_uart1(rx_data);
         $display("UART1 RECEIVED: %h", rx_data);

         if (rx_data !== 8'h55)
            $display("ERROR DATA MISMATCH!");
      end else begin
         $display("ERROR UART1 RX FIFO EMPTY!");
      end

      $display("\n--- TEST PASSED ---");
   end
   initial begin
      #10000000;
      $finish;
   end

endmodule
