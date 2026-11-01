`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2026 03:07:18 AM
// Design Name: 
// Module Name: freq_meter_calc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module freq_meter_calc(
    input sys_clk,
    input sys_rst_n_btn,
    input clk_test,
    output clk_out
    );
    
(* mark_debug = "true" *) wire [33:0] freq;
wire sys_rst_n = ~sys_rst_n_btn & clk_locked;
assign clk_out = clk_test;

parameter CNT_GATE_S_MAX = 28'd74_999_999;
parameter CNT_RISE_MAX   = 28'd12_500_000;

reg [27:0] cnt_gate_s;
(* DONT_TOUCH = "TRUE" *) reg gate_s;

// Software gate counter
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_gate_s <= 28'd0;
    else if (cnt_gate_s == CNT_GATE_S_MAX)
        cnt_gate_s <= 28'd0;
    else
        cnt_gate_s <= cnt_gate_s + 1'b1;
        end

// Software gate signal
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        gate_s <= 1'b0;
    else
        gate_s <= (cnt_gate_s > CNT_RISE_MAX &&
                   cnt_gate_s <= CNT_GATE_S_MAX - CNT_RISE_MAX);
end
                 
// Synchronize gate_s into the test clock domain
(* ASYNC_REG = "TRUE" *) reg gate_s_sync1;
(* ASYNC_REG = "TRUE" *) reg gate_s_sync2;

always @(posedge clk_test or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        gate_s_sync1 <= 1'b0;
        gate_s_sync2 <= 1'b0;
    end
    else begin
        gate_s_sync1 <= gate_s;
        gate_s_sync2 <= gate_s_sync1;
    end
end

reg gate_a;

always @(posedge clk_test or negedge sys_rst_n) begin
    if (!sys_rst_n)
        gate_a <= 1'b0;
    else
        gate_a <= gate_s_sync2;
end

 // Reference and test clock counters
 reg [31:0] cnt_clk_stand;
 reg [31:0] cnt_clk_test;

 // Saved counter values for frequency calculation
 reg [31:0] cnt_clk_stand_reg;
 reg [31:0] cnt_clk_test_reg;
 
 // Test-clock domain: request and acknowledgement
reg count_request;
(* ASYNC_REG = "TRUE" *) reg count_ack_sync1;
(* ASYNC_REG = "TRUE" *) reg count_ack_sync2;

// Reference-clock domain: synchronized request
(* ASYNC_REG = "TRUE" *) reg count_req_sync1;
(* ASYNC_REG = "TRUE" *) reg count_req_sync2;

reg count_ack;
reg [31:0] cnt_clk_test_safe;

// Indicates a completed test count has been received
reg test_count_ready;

// Synchronize acknowledgement into the test-clock domain
always @(posedge clk_test or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        count_ack_sync1 <= 1'b0;
        count_ack_sync2 <= 1'b0;
    end
    else begin
        count_ack_sync1 <= count_ack;
        count_ack_sync2 <= count_ack_sync1;
    end
end

// Synchronize measurement request into the 100 MHz domain
always @(posedge clk_stand or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        count_req_sync1 <= 1'b0;
        count_req_sync2 <= 1'b0;
    end
    else begin
        count_req_sync1 <= count_request;
        count_req_sync2 <= count_req_sync1;
    end
end

 // Gate edge detection
 reg gate_a_stand;
 reg gate_a_test;
 wire gate_a_fall_s;
 wire gate_a_fall_test;

// Synchronize gate_a to the 100 MHz reference clock
(* ASYNC_REG = "TRUE" *) reg gate_a_sync1;
(* ASYNC_REG = "TRUE" *) reg gate_a_sync2;

always @(posedge clk_stand or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        gate_a_sync1 <= 1'b0;
        gate_a_sync2 <= 1'b0;
    end
    else begin
        gate_a_sync1 <= gate_a;
        gate_a_sync2 <= gate_a_sync1;
    end
end

 // 100 MHz reference clock from Clocking Wizard
 wire clk_stand;
 
// Clocking Wizard
wire clk_locked;

clk_wiz_0 clk_wiz_inst (
    .clk_in1(sys_clk),
    .clk_out1(clk_stand),
    .reset(sys_rst_n_btn),
    .locked(clk_locked)
);

// Integrated Logic Analyzer - monitor measured frequency
ila_0 ila_inst (
    .clk(clk_stand),
    .probe0(freq)
);

 // Test clock counter
 always @(posedge clk_test or negedge sys_rst_n) begin
     if (!sys_rst_n)
         cnt_clk_test <= 32'd0;
     else if (!gate_a)
         cnt_clk_test <= 32'd0;
     else
         cnt_clk_test <= cnt_clk_test + 1'b1;
 end

 // Reference clock counter
 always @(posedge clk_stand or negedge sys_rst_n) begin
     if (!sys_rst_n)
         cnt_clk_stand <= 32'd0;
     else if (!gate_a_sync2)
         cnt_clk_stand <= 32'd0;
     else
         cnt_clk_stand <= cnt_clk_stand + 1'b1;
 end

// Detect falling edge of synchronized gate
always @(posedge clk_stand or negedge sys_rst_n) begin
    if (!sys_rst_n)
        gate_a_stand <= 1'b0;
    else
        gate_a_stand <= gate_a_sync2;
end

assign gate_a_fall_s = gate_a_stand && !gate_a_sync2;

 always @(posedge clk_test or negedge sys_rst_n) begin
     if (!sys_rst_n)
         gate_a_test <= 1'b0;
     else
         gate_a_test <= gate_a;
 end

 assign gate_a_fall_test = gate_a_test && !gate_a;

 // Save reference clock count
 always @(posedge clk_stand or negedge sys_rst_n) begin
     if (!sys_rst_n)
         cnt_clk_stand_reg <= 32'd0;
     else if (gate_a_fall_s)
         cnt_clk_stand_reg <= cnt_clk_stand;
 end

 // Save test count and request transfer to reference-clock domain
always @(posedge clk_test or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        cnt_clk_test_reg <= 32'd0;
        count_request <= 1'b0;
    end
    else begin
        // Keep request high until acknowledgement arrives
        if (count_request && count_ack_sync2)
            count_request <= 1'b0;

        // Capture a completed count only when the handshake is idle
        if (gate_a_fall_test &&
            !count_request &&
            !count_ack_sync2) begin
            cnt_clk_test_reg <= cnt_clk_test;
            count_request <= 1'b1;
        end
    end
end
 
// Receive completed test clock count in reference clock domain
always @(posedge clk_stand or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        cnt_clk_test_safe <= 32'd0;
        count_ack <= 1'b0;
        test_count_ready <= 1'b0;
    end
    else begin
        test_count_ready <= 1'b0;
        
        if (count_req_sync2 && !count_ack) begin
            cnt_clk_test_safe <= cnt_clk_test_reg;
            count_ack <= 1'b1;
            test_count_ready <= 1'b1;
        end
        else if (!count_req_sync2) begin
            count_ack <= 1'b0;
        end
    end
end
 
// Frequency calculation using a multi-cycle divider
reg [63:0] dividend;
reg [63:0] quotient;
reg [63:0] remainder;
reg [63:0] divisor;

reg [6:0] div_count;
reg dividing;

reg [63:0] freq_calc;

always @(posedge clk_stand or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        dividend  <= 0;
        quotient  <= 0;
        remainder <= 0;
        divisor   <= 0;
        div_count <= 0;
        dividing  <= 0;
        freq_calc <= 0;
    end
    else if (!dividing) begin
        if (test_count_ready && cnt_clk_stand_reg != 0) begin
            dividend  <= 64'd100_000_000 * cnt_clk_test_safe;
            divisor   <= {32'd0, cnt_clk_stand_reg};
            quotient  <= 0;
            remainder <= 0;
            div_count <= 64;
            dividing  <= 1;
        end
    end
    else begin
        if (div_count != 0) begin
            if ({remainder[62:0], dividend[63]} >= divisor) begin
                remainder <= {remainder[62:0], dividend[63]} - divisor;
                quotient  <= {quotient[62:0], 1'b1};
            end
            else begin
                remainder <= {remainder[62:0], dividend[63]};
                quotient  <= {quotient[62:0], 1'b0};
            end

            dividend  <= dividend << 1;
            div_count <= div_count - 1'b1;
        end
        else begin
            freq_calc <= quotient;
            dividing  <= 0;
        end
    end
end

assign freq = freq_calc[33:0];

endmodule
