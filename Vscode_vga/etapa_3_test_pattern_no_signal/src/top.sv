`timescale 1ns / 1ps

module vga_top (

    input  logic        sys_clock,
    input  logic        reset,

    output logic        Hsync,
    output logic        Vsync,

    output logic [3:0]  vgaRed,
    output logic [3:0]  vgaGreen,
    output logic [3:0]  vgaBlue
);

    // Active-low reset from SW1
    logic resetn;

    assign resetn = ~reset;

    // Pixel clock for VGA
    logic pix_clk;

   clk_vga_wrapper u_clk_vga_wrapper (
        .clk_out1_0 (pix_clk),
        .reset      (resetn),
        .sys_clock  (sys_clock)
    );

    // VGA controller instance
    vga_controller #(
        .color_w    (4),
        .image_red  (4'h0),
        .image_green(4'h0),
        .image_blue (4'hf)
    ) u_vga_controller (
        .pix_clk  (pix_clk),
        .rst_n    (resetn),

        .hsync    (Hsync),
        .vsync    (Vsync),

        .vga_red  (vgaRed),
        .vga_green(vgaGreen),
        .vga_blue (vgaBlue)
    );

endmodule