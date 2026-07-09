module vga_top #(
    parameter int color_w = 4,

    parameter logic [color_w-1:0] image_red   = 4'hf,
    parameter logic [color_w-1:0] image_green = 4'h0,
    parameter logic [color_w-1:0] image_blue  = 4'h0
)(
    input  logic pix_clk,
    input  logic rst_n,

    output logic hsync,
    output logic vsync,

    output logic [color_w-1:0] vga_red,
    output logic [color_w-1:0] vga_green,
    output logic [color_w-1:0] vga_blue
);

    vga_controller #(
        .color_w    (color_w),
        .image_red  (image_red),
        .image_green(image_green),
        .image_blue (image_blue)
    ) controller_inst (
        .pix_clk  (pix_clk),
        .rst_n    (rst_n),

        .hsync    (hsync),
        .vsync    (vsync),

        .vga_red  (vga_red),
        .vga_green(vga_green),
        .vga_blue (vga_blue)
    );

endmodule