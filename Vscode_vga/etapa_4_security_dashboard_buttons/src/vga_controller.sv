`timescale 1ns / 1ps

module vga_controller #(
    parameter int color_w = 4
)(
    input  logic               pix_clk,
    input  logic               rst_n,

    input  logic               btn_u,
    input  logic               btn_r,
    input  logic               btn_d,
    input  logic               btn_l,

    output logic               hsync,
    output logic               vsync,
    output logic [color_w-1:0] vga_red,
    output logic [color_w-1:0] vga_green,
    output logic [color_w-1:0] vga_blue
);

    // VGA 640x480 @ 60Hz
    localparam int H_ACTIVE = 640;
    localparam int H_FP     = 16;
    localparam int H_SYNC   = 96;
    localparam int H_BP     = 48;
    localparam int H_TOTAL  = H_ACTIVE + H_FP + H_SYNC + H_BP;

    localparam int V_ACTIVE = 480;
    localparam int V_FP     = 10;
    localparam int V_SYNC   = 2;
    localparam int V_BP     = 33;
    localparam int V_TOTAL  = V_ACTIVE + V_FP + V_SYNC + V_BP;

    localparam logic H_POL = 1'b0;
    localparam logic V_POL = 1'b0;

    // Dashboard layout
    localparam int HEADER_H = 50;
    localparam int FOOTER_Y = 440;

    localparam int MAP_X0 = 20;
    localparam int MAP_Y0 = 60;
    localparam int MAP_X1 = 620;
    localparam int MAP_Y1 = 430;

    localparam int ZONE_W = 130;
    localparam int ZONE_H = 90;

    // Zone positions
    localparam int BASE_X  = 40;
    localparam int BASE_Y  = 80;

    localparam int ALERT_X = 470;
    localparam int ALERT_Y = 80;

    localparam int SAFE_X  = 40;
    localparam int SAFE_Y  = 320;

    localparam int CHECK_X = 470;
    localparam int CHECK_Y = 320;

    // Drone settings
    localparam int DRONE_SIZE = 20;

    localparam int DRONE_MIN_X = MAP_X0 + 3;
    localparam int DRONE_MAX_X = MAP_X1 - DRONE_SIZE - 3;

    localparam int DRONE_MIN_Y = MAP_Y0 + 3;
    localparam int DRONE_MAX_Y = MAP_Y1 - DRONE_SIZE - 3;

    localparam int DRONE_START_X = (H_ACTIVE - DRONE_SIZE) / 2;
    localparam int DRONE_START_Y = (V_ACTIVE - DRONE_SIZE) / 2;

    // Movement speed
    localparam int SAFE_SPEED  = 2;
    localparam int CHECK_SPEED = 4;
    localparam int ALERT_SPEED = 7;

    // Status values
    localparam logic [1:0] STATUS_SAFE  = 2'd0;
    localparam logic [1:0] STATUS_CHECK = 2'd1;
    localparam logic [1:0] STATUS_ALERT = 2'd2;

    logic [9:0] h_count;
    logic [9:0] v_count;

    logic [9:0] drone_x;
    logic [9:0] drone_y;

    logic active_area;
    logic hsync_area;
    logic vsync_area;
    logic frame_tick;

    logic [1:0] btn_u_sync;
    logic [1:0] btn_r_sync;
    logic [1:0] btn_d_sync;
    logic [1:0] btn_l_sync;

    logic btn_u_s;
    logic btn_r_s;
    logic btn_d_s;
    logic btn_l_s;

    logic drone_in_alert;
    logic drone_in_check;

    logic [1:0] status;
    logic [3:0] move_step;

    logic drone_area;
    logic drone_border;

    logic text_pixel;
    logic [11:0] text_rgb;
    logic [3:0] status_text_id;

    logic [11:0] background_rgb;
    logic [11:0] drone_rgb;
    logic [11:0] final_rgb;

    assign active_area = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

    assign hsync_area = (h_count >= H_ACTIVE + H_FP) &&
                        (h_count <  H_ACTIVE + H_FP + H_SYNC);

    assign vsync_area = (v_count >= V_ACTIVE + V_FP) &&
                        (v_count <  V_ACTIVE + V_FP + V_SYNC);

    assign frame_tick = (h_count == H_TOTAL - 1) &&
                        (v_count == V_TOTAL - 1);

    assign btn_u_s = btn_u_sync[1];
    assign btn_r_s = btn_r_sync[1];
    assign btn_d_s = btn_d_sync[1];
    assign btn_l_s = btn_l_sync[1];

    // Drone touches red alert zone
    assign drone_in_alert =
        (drone_x + DRONE_SIZE > ALERT_X) &&
        (drone_x < ALERT_X + ZONE_W) &&
        (drone_y + DRONE_SIZE > ALERT_Y) &&
        (drone_y < ALERT_Y + ZONE_H);

    // Drone touches yellow check zone
    assign drone_in_check =
        (drone_x + DRONE_SIZE > CHECK_X) &&
        (drone_x < CHECK_X + ZONE_W) &&
        (drone_y + DRONE_SIZE > CHECK_Y) &&
        (drone_y < CHECK_Y + ZONE_H);

    assign status = drone_in_alert ? STATUS_ALERT :
                    drone_in_check ? STATUS_CHECK :
                    STATUS_SAFE;

    assign move_step = drone_in_alert ? ALERT_SPEED :
                       drone_in_check ? CHECK_SPEED :
                       SAFE_SPEED;

    assign drone_area =
        active_area &&
        (h_count >= drone_x) &&
        (h_count <  drone_x + DRONE_SIZE) &&
        (v_count >= drone_y) &&
        (v_count <  drone_y + DRONE_SIZE);

    assign drone_border =
        drone_area &&
        (
            (h_count == drone_x) ||
            (h_count == drone_x + DRONE_SIZE - 1) ||
            (v_count == drone_y) ||
            (v_count == drone_y + DRONE_SIZE - 1)
        );

    // Horizontal and vertical VGA counters
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 10'd0;

                if (v_count == V_TOTAL - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    // Synchronize physical buttons to pixel clock
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            btn_u_sync <= 2'b00;
            btn_r_sync <= 2'b00;
            btn_d_sync <= 2'b00;
            btn_l_sync <= 2'b00;
        end else begin
            btn_u_sync <= {btn_u_sync[0], btn_u};
            btn_r_sync <= {btn_r_sync[0], btn_r};
            btn_d_sync <= {btn_d_sync[0], btn_d};
            btn_l_sync <= {btn_l_sync[0], btn_l};
        end
    end

    // Drone movement on X axis
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            drone_x <= DRONE_START_X;
        end else if (frame_tick) begin
            if (btn_l_s && !btn_r_s) begin
                if (drone_x > DRONE_MIN_X + move_step)
                    drone_x <= drone_x - move_step;
                else
                    drone_x <= DRONE_MIN_X;
            end else if (btn_r_s && !btn_l_s) begin
                if (drone_x < DRONE_MAX_X - move_step)
                    drone_x <= drone_x + move_step;
                else
                    drone_x <= DRONE_MAX_X;
            end
        end
    end

    // Drone movement on Y axis
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            drone_y <= DRONE_START_Y;
        end else if (frame_tick) begin
            if (btn_u_s && !btn_d_s) begin
                if (drone_y > DRONE_MIN_Y + move_step)
                    drone_y <= drone_y - move_step;
                else
                    drone_y <= DRONE_MIN_Y;
            end else if (btn_d_s && !btn_u_s) begin
                if (drone_y < DRONE_MAX_Y - move_step)
                    drone_y <= drone_y + move_step;
                else
                    drone_y <= DRONE_MAX_Y;
            end
        end
    end

    function automatic logic inside_rect(
        input int px,
        input int py,
        input int rx,
        input int ry,
        input int rw,
        input int rh
    );
        inside_rect = (px >= rx) &&
                      (px <  rx + rw) &&
                      (py >= ry) &&
                      (py <  ry + rh);
    endfunction

    function automatic logic rect_border(
        input int px,
        input int py,
        input int rx,
        input int ry,
        input int rw,
        input int rh,
        input int border
    );
        rect_border = inside_rect(px, py, rx, ry, rw, rh) &&
        (
            (px < rx + border) ||
            (px >= rx + rw - border) ||
            (py < ry + border) ||
            (py >= ry + rh - border)
        );
    endfunction

    function automatic logic [11:0] get_dashboard_rgb(
        input int px,
        input int py,
        input logic [1:0] current_status
    );
        get_dashboard_rgb = 12'h001;

        // Header color changes depending on status
        if (py < HEADER_H) begin
            if (current_status == STATUS_ALERT)
                get_dashboard_rgb = 12'h700;
            else if (current_status == STATUS_CHECK)
                get_dashboard_rgb = 12'h770;
            else
                get_dashboard_rgb = 12'h070;
        end

        // Footer area
        else if (py >= FOOTER_Y) begin
            get_dashboard_rgb = 12'h111;
        end

        // Main background
        else begin
            get_dashboard_rgb = 12'h002;
        end

        // Main map area
        if (inside_rect(px, py, MAP_X0, MAP_Y0, MAP_X1 - MAP_X0, MAP_Y1 - MAP_Y0)) begin
            get_dashboard_rgb = 12'h012;

            // Simple grid
            if ((px[4:0] == 5'd0) || (py[4:0] == 5'd0))
                get_dashboard_rgb = 12'h123;
        end

        // Colored zones
        if (inside_rect(px, py, BASE_X, BASE_Y, ZONE_W, ZONE_H))
            get_dashboard_rgb = 12'h027;

        if (inside_rect(px, py, ALERT_X, ALERT_Y, ZONE_W, ZONE_H))
            get_dashboard_rgb = 12'h700;

        if (inside_rect(px, py, SAFE_X, SAFE_Y, ZONE_W, ZONE_H))
            get_dashboard_rgb = 12'h073;

        if (inside_rect(px, py, CHECK_X, CHECK_Y, ZONE_W, ZONE_H))
            get_dashboard_rgb = 12'h770;

        // Borders
        if (rect_border(px, py, MAP_X0, MAP_Y0, MAP_X1 - MAP_X0, MAP_Y1 - MAP_Y0, 2))
            get_dashboard_rgb = 12'hFFF;

        if (rect_border(px, py, BASE_X, BASE_Y, ZONE_W, ZONE_H, 2))
            get_dashboard_rgb = 12'h05F;

        if (rect_border(px, py, ALERT_X, ALERT_Y, ZONE_W, ZONE_H, 2))
            get_dashboard_rgb = 12'hF00;

        if (rect_border(px, py, SAFE_X, SAFE_Y, ZONE_W, ZONE_H, 2))
            get_dashboard_rgb = 12'h0F0;

        if (rect_border(px, py, CHECK_X, CHECK_Y, ZONE_W, ZONE_H, 2))
            get_dashboard_rgb = 12'hFF0;
    endfunction

    function automatic logic [4:0] font_row(
        input logic [7:0] ch,
        input int row
    );
        font_row = 5'b00000;

        case (ch)

            8'h20: font_row = 5'b00000; // space

            8'h3A: begin // :
                case (row)
                    1: font_row = 5'b00100;
                    2: font_row = 5'b00100;
                    4: font_row = 5'b00100;
                    5: font_row = 5'b00100;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h41: begin // A
                case (row)
                    0: font_row = 5'b01110;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b10001;
                    3: font_row = 5'b11111;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b10001;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h42: begin // B
                case (row)
                    0: font_row = 5'b11110;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b10001;
                    3: font_row = 5'b11110;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b11110;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h43: begin // C
                case (row)
                    0: font_row = 5'b01111;
                    1: font_row = 5'b10000;
                    2: font_row = 5'b10000;
                    3: font_row = 5'b10000;
                    4: font_row = 5'b10000;
                    5: font_row = 5'b10000;
                    6: font_row = 5'b01111;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h44: begin // D
                case (row)
                    0: font_row = 5'b11110;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b10001;
                    3: font_row = 5'b10001;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b11110;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h45: begin // E
                case (row)
                    0: font_row = 5'b11111;
                    1: font_row = 5'b10000;
                    2: font_row = 5'b10000;
                    3: font_row = 5'b11110;
                    4: font_row = 5'b10000;
                    5: font_row = 5'b10000;
                    6: font_row = 5'b11111;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h46: begin // F
                case (row)
                    0: font_row = 5'b11111;
                    1: font_row = 5'b10000;
                    2: font_row = 5'b10000;
                    3: font_row = 5'b11110;
                    4: font_row = 5'b10000;
                    5: font_row = 5'b10000;
                    6: font_row = 5'b10000;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h47: begin // G
                case (row)
                    0: font_row = 5'b01111;
                    1: font_row = 5'b10000;
                    2: font_row = 5'b10000;
                    3: font_row = 5'b10111;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b01111;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h48: begin // H
                case (row)
                    0: font_row = 5'b10001;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b10001;
                    3: font_row = 5'b11111;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b10001;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h49: begin // I
                case (row)
                    0: font_row = 5'b11111;
                    1: font_row = 5'b00100;
                    2: font_row = 5'b00100;
                    3: font_row = 5'b00100;
                    4: font_row = 5'b00100;
                    5: font_row = 5'b00100;
                    6: font_row = 5'b11111;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h4B: begin // K
                case (row)
                    0: font_row = 5'b10001;
                    1: font_row = 5'b10010;
                    2: font_row = 5'b10100;
                    3: font_row = 5'b11000;
                    4: font_row = 5'b10100;
                    5: font_row = 5'b10010;
                    6: font_row = 5'b10001;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h4C: begin // L
                case (row)
                    0: font_row = 5'b10000;
                    1: font_row = 5'b10000;
                    2: font_row = 5'b10000;
                    3: font_row = 5'b10000;
                    4: font_row = 5'b10000;
                    5: font_row = 5'b10000;
                    6: font_row = 5'b11111;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h4E: begin // N
                case (row)
                    0: font_row = 5'b10001;
                    1: font_row = 5'b11001;
                    2: font_row = 5'b10101;
                    3: font_row = 5'b10011;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b10001;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h4F: begin // O
                case (row)
                    0: font_row = 5'b01110;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b10001;
                    3: font_row = 5'b10001;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b01110;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h52: begin // R
                case (row)
                    0: font_row = 5'b11110;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b10001;
                    3: font_row = 5'b11110;
                    4: font_row = 5'b10100;
                    5: font_row = 5'b10010;
                    6: font_row = 5'b10001;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h53: begin // S
                case (row)
                    0: font_row = 5'b01111;
                    1: font_row = 5'b10000;
                    2: font_row = 5'b10000;
                    3: font_row = 5'b01110;
                    4: font_row = 5'b00001;
                    5: font_row = 5'b00001;
                    6: font_row = 5'b11110;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h54: begin // T
                case (row)
                    0: font_row = 5'b11111;
                    1: font_row = 5'b00100;
                    2: font_row = 5'b00100;
                    3: font_row = 5'b00100;
                    4: font_row = 5'b00100;
                    5: font_row = 5'b00100;
                    6: font_row = 5'b00100;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h55: begin // U
                case (row)
                    0: font_row = 5'b10001;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b10001;
                    3: font_row = 5'b10001;
                    4: font_row = 5'b10001;
                    5: font_row = 5'b10001;
                    6: font_row = 5'b01110;
                    default: font_row = 5'b00000;
                endcase
            end

            8'h59: begin // Y
                case (row)
                    0: font_row = 5'b10001;
                    1: font_row = 5'b10001;
                    2: font_row = 5'b01010;
                    3: font_row = 5'b00100;
                    4: font_row = 5'b00100;
                    5: font_row = 5'b00100;
                    6: font_row = 5'b00100;
                    default: font_row = 5'b00000;
                endcase
            end

            default: font_row = 5'b00000;
        endcase
    endfunction

    function automatic logic [7:0] get_text_char(
        input int text_id,
        input int idx
    );
        get_text_char = 8'h20;

        case (text_id)

            // SECURITY DASHBOARD
            0: begin
                case (idx)
                    0: get_text_char = "S";
                    1: get_text_char = "E";
                    2: get_text_char = "C";
                    3: get_text_char = "U";
                    4: get_text_char = "R";
                    5: get_text_char = "I";
                    6: get_text_char = "T";
                    7: get_text_char = "Y";
                    8: get_text_char = " ";
                    9: get_text_char = "D";
                    10: get_text_char = "A";
                    11: get_text_char = "S";
                    12: get_text_char = "H";
                    13: get_text_char = "B";
                    14: get_text_char = "O";
                    15: get_text_char = "A";
                    16: get_text_char = "R";
                    17: get_text_char = "D";
                    default: get_text_char = " ";
                endcase
            end

            // STATUS: SAFE
            1: begin
                case (idx)
                    0: get_text_char = "S";
                    1: get_text_char = "T";
                    2: get_text_char = "A";
                    3: get_text_char = "T";
                    4: get_text_char = "U";
                    5: get_text_char = "S";
                    6: get_text_char = ":";
                    7: get_text_char = " ";
                    8: get_text_char = "S";
                    9: get_text_char = "A";
                    10: get_text_char = "F";
                    11: get_text_char = "E";
                    default: get_text_char = " ";
                endcase
            end

            // STATUS: CHECKING
            2: begin
                case (idx)
                    0: get_text_char = "S";
                    1: get_text_char = "T";
                    2: get_text_char = "A";
                    3: get_text_char = "T";
                    4: get_text_char = "U";
                    5: get_text_char = "S";
                    6: get_text_char = ":";
                    7: get_text_char = " ";
                    8: get_text_char = "C";
                    9: get_text_char = "H";
                    10: get_text_char = "E";
                    11: get_text_char = "C";
                    12: get_text_char = "K";
                    13: get_text_char = "I";
                    14: get_text_char = "N";
                    15: get_text_char = "G";
                    default: get_text_char = " ";
                endcase
            end

            // STATUS: ALERT
            3: begin
                case (idx)
                    0: get_text_char = "S";
                    1: get_text_char = "T";
                    2: get_text_char = "A";
                    3: get_text_char = "T";
                    4: get_text_char = "U";
                    5: get_text_char = "S";
                    6: get_text_char = ":";
                    7: get_text_char = " ";
                    8: get_text_char = "A";
                    9: get_text_char = "L";
                    10: get_text_char = "E";
                    11: get_text_char = "R";
                    12: get_text_char = "T";
                    default: get_text_char = " ";
                endcase
            end

            // BASE
            4: begin
                case (idx)
                    0: get_text_char = "B";
                    1: get_text_char = "A";
                    2: get_text_char = "S";
                    3: get_text_char = "E";
                    default: get_text_char = " ";
                endcase
            end

            // ALERT
            5: begin
                case (idx)
                    0: get_text_char = "A";
                    1: get_text_char = "L";
                    2: get_text_char = "E";
                    3: get_text_char = "R";
                    4: get_text_char = "T";
                    default: get_text_char = " ";
                endcase
            end

            // SAFE
            6: begin
                case (idx)
                    0: get_text_char = "S";
                    1: get_text_char = "A";
                    2: get_text_char = "F";
                    3: get_text_char = "E";
                    default: get_text_char = " ";
                endcase
            end

            // CHECK
            7: begin
                case (idx)
                    0: get_text_char = "C";
                    1: get_text_char = "H";
                    2: get_text_char = "E";
                    3: get_text_char = "C";
                    4: get_text_char = "K";
                    default: get_text_char = " ";
                endcase
            end

            default: get_text_char = " ";
        endcase
    endfunction

    function automatic logic draw_text_pixel(
        input int px,
        input int py,
        input int start_x,
        input int start_y,
        input int text_id,
        input int max_chars,
        input int scale
    );
        int rel_x;
        int rel_y;
        int char_index;
        int char_col;
        int char_row;
        int bit_index;

        logic [7:0] ch;
        logic [4:0] row_bits;

        draw_text_pixel = 1'b0;

        if ((px >= start_x) &&
            (px < start_x + max_chars * 6 * scale) &&
            (py >= start_y) &&
            (py < start_y + 7 * scale)) begin

            rel_x = px - start_x;
            rel_y = py - start_y;

            char_index = rel_x / (6 * scale);
            char_col   = (rel_x / scale) % 6;
            char_row   = rel_y / scale;

            if ((char_col < 5) && (char_row < 7)) begin
                ch = get_text_char(text_id, char_index);
                row_bits = font_row(ch, char_row);
                bit_index = 4 - char_col;
                draw_text_pixel = row_bits[bit_index];
            end
        end
    endfunction

    always_comb begin
        if (status == STATUS_ALERT)
            status_text_id = 3;
        else if (status == STATUS_CHECK)
            status_text_id = 2;
        else
            status_text_id = 1;
    end

    always_comb begin
        text_pixel = 1'b0;
        text_rgb   = 12'hFFF;

        // Main title
        if (draw_text_pixel(h_count, v_count, 212, 14, 0, 18, 2)) begin
            text_pixel = 1'b1;
            text_rgb   = 12'hFFF;
        end

        // Status text
        if (draw_text_pixel(h_count, v_count, 30, 34, status_text_id, 16, 1)) begin
            text_pixel = 1'b1;

            if (status == STATUS_ALERT)
                text_rgb = 12'hF00;
            else if (status == STATUS_CHECK)
                text_rgb = 12'hFF0;
            else
                text_rgb = 12'h0F0;
        end

        // Zone labels
        if (draw_text_pixel(h_count, v_count, BASE_X + 38, BASE_Y + 38, 4, 4, 2)) begin
            text_pixel = 1'b1;
            text_rgb   = 12'hFFF;
        end

        if (draw_text_pixel(h_count, v_count, ALERT_X + 32, ALERT_Y + 38, 5, 5, 2)) begin
            text_pixel = 1'b1;
            text_rgb   = 12'hFFF;
        end

        if (draw_text_pixel(h_count, v_count, SAFE_X + 38, SAFE_Y + 38, 6, 4, 2)) begin
            text_pixel = 1'b1;
            text_rgb   = 12'hFFF;
        end

        if (draw_text_pixel(h_count, v_count, CHECK_X + 35, CHECK_Y + 38, 7, 5, 2)) begin
            text_pixel = 1'b1;
            text_rgb   = 12'hFFF;
        end
    end

    always_comb begin
        background_rgb = get_dashboard_rgb(h_count, v_count, status);

        if (status == STATUS_ALERT)
            drone_rgb = 12'hF0F;
        else if (status == STATUS_CHECK)
            drone_rgb = 12'hFF0;
        else
            drone_rgb = 12'h0FF;

        final_rgb = 12'h000;

        if (active_area) begin
            final_rgb = background_rgb;

            if (drone_area)
                final_rgb = drone_rgb;

            if (drone_border)
                final_rgb = 12'hFFF;

            if (text_pixel)
                final_rgb = text_rgb;
        end
    end

    assign hsync = (!rst_n) ? ~H_POL : (hsync_area ? H_POL : ~H_POL);
    assign vsync = (!rst_n) ? ~V_POL : (vsync_area ? V_POL : ~V_POL);

    assign vga_red   = final_rgb[11:8];
    assign vga_green = final_rgb[7:4];
    assign vga_blue  = final_rgb[3:0];

endmodule