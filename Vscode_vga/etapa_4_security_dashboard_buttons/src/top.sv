`timescale 1ns / 1ps

module vga_top (
    input  logic       sys_clock,
    input  logic       reset,

    input  logic       btnU,
    input  logic       btnR,
    input  logic       btnD,
    input  logic       btnL,

    output logic       Hsync,
    output logic       Vsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue
);

    logic resetn;
    logic pix_clk;

    assign resetn = ~reset;

    clk_vga_wrapper u_clk_vga_wrapper (
        .clk_out1_0 (pix_clk),
        .reset      (resetn),
        .sys_clock  (sys_clock)
    );

    vga_controller #(
        .color_w(4)
    ) u_vga_controller (
        .pix_clk   (pix_clk),
        .rst_n     (resetn),

        .btn_u     (btnU),
        .btn_r     (btnR),
        .btn_d     (btnD),
        .btn_l     (btnL),

        .hsync     (Hsync),
        .vsync     (Vsync),

        .vga_red   (vgaRed),
        .vga_green (vgaGreen),
        .vga_blue  (vgaBlue)
    );

endmodule