module vga_controller #(
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

    localparam int h_active = 640;
    localparam int h_fp     = 16;
    localparam int h_sync   = 96;
    localparam int h_bp     = 48;
    localparam int h_total  = h_active + h_fp + h_sync + h_bp;

    localparam int v_active = 480;
    localparam int v_fp     = 10;
    localparam int v_sync   = 2;
    localparam int v_bp     = 33;
    localparam int v_total  = v_active + v_fp + v_sync + v_bp;

    localparam logic h_pol = 1'b0;
    localparam logic v_pol = 1'b0;

    logic [9:0] h_count;
    logic [9:0] v_count;

    logic active_area;
    logic hsync_area;
    logic vsync_area;

    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == h_total - 1) begin
                h_count <= 10'd0;

                if (v_count == v_total - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    always_comb begin
        active_area = (h_count < h_active) && (v_count < v_active);

        hsync_area = (h_count >= h_active + h_fp) &&
                     (h_count <  h_active + h_fp + h_sync);

        vsync_area = (v_count >= v_active + v_fp) &&
                     (v_count <  v_active + v_fp + v_sync);
    end

    always_comb begin
        if (!rst_n) begin
            hsync = ~h_pol;
            vsync = ~v_pol;

            vga_red   = '0;
            vga_green = '0;
            vga_blue  = '0;
        end else begin
            hsync = hsync_area ? h_pol : ~h_pol;
            vsync = vsync_area ? v_pol : ~v_pol;

            if (active_area) begin
                vga_red   = image_red;
                vga_green = image_green;
                vga_blue  = image_blue;
            end else begin
                vga_red   = '0;
                vga_green = '0;
                vga_blue  = '0;
            end
        end
    end

endmodule