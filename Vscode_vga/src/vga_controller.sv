module vga_controller #(
    parameter int color_w = 4,

    parameter logic [color_w-1:0] image_red   = 4'h0,
    parameter logic [color_w-1:0] image_green = 4'h0,
    parameter logic [color_w-1:0] image_blue  = 4'hf
)(
    input  logic pix_clk,
    input  logic rst_n,

    output logic hsync,
    output logic vsync,

    output logic [color_w-1:0] vga_red,
    output logic [color_w-1:0] vga_green,
    output logic [color_w-1:0] vga_blue
);

    // VGA 640x480 timing parameters
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

    localparam logic H_POL = 1'b0;   // adaptarea VGA 1 strict sau 0 strict 
    localparam logic V_POL = 1'b0;

    // Parametrii pentru dreptunghiul negru care se misca pe ecran.
    // Moving box parameters
    localparam int BOX_W     = 260;
    localparam int BOX_H     = 100;
    localparam int MOVE_STEP = 2; // 120 de pixeli pe s   

    // Parametrii pentru textul afisat in interiorul dreptunghiului.
    // Text parameters
    localparam int TEXT_SCALE = 4;
    localparam int CHAR_W     = 5;
    localparam int CHAR_H     = 7;
    localparam int CHAR_CELL  = 6;
    localparam int TEXT_CHARS = 9;

    localparam int TEXT_W = TEXT_CHARS * CHAR_CELL * TEXT_SCALE;
    localparam int TEXT_H = CHAR_H * TEXT_SCALE;

    localparam int TEXT_X = (BOX_W - TEXT_W) / 2;
    localparam int TEXT_Y = (BOX_H - TEXT_H) / 2;

    // Fiecare litera are un ID intern.
    // Aceste ID-uri sunt folosite pentru a selecta desenul literei din font.
    localparam logic [3:0] CHAR_N     = 4'd0;
    localparam logic [3:0] CHAR_O     = 4'd1;
    localparam logic [3:0] CHAR_S     = 4'd2;
    localparam logic [3:0] CHAR_I     = 4'd3;
    localparam logic [3:0] CHAR_G     = 4'd4;
    localparam logic [3:0] CHAR_A     = 4'd5;
    localparam logic [3:0] CHAR_L     = 4'd6;
    localparam logic [3:0] CHAR_SPACE = 4'd7;

    // VGA counters
    logic [9:0] h_count;
    logic [9:0] v_count;
    
    // Semnale care marcheaza zonele importante dintr-un cadru VGA
    // VGA area signals
    logic active_area;
    logic hsync_area;
    logic vsync_area;
    logic frame_tick;

    // Moving box state
    logic [9:0] box_x;
    logic [9:0] box_y;
    logic       dir_x;
    logic       dir_y;

    // Collision signals
    logic hit_right;
    logic hit_left;
    logic hit_bottom;
    logic hit_top;

    // Text drawing signals
    logic       box_area;
    logic       text_area;
    logic       text_pixel;

    // Coordonatele locale sunt calculate fata de coltul dreptunghiului.
    // Sunt utile pentru a sti unde se afla textul in interiorul dreptunghiului.
    logic [9:0] local_x;
    logic [9:0] local_y;
    logic [9:0] tx; 
    logic [9:0] ty; 

    //coord in interiorul textului dupa scalare 
    logic [7:0] text_col;
    logic [7:0] text_row;

     // char_index spune al catelea caracter din text este desenat.
    logic [3:0] char_index;
    logic [3:0] char_id;

     // Pozitia pixelului in interiorul unei litere bitmap.
    logic [2:0] glyph_col;
    logic [2:0] glyph_row;

     // Un rand din litera curenta, reprezentat pe 5 biti.
    logic [4:0] glyph_bits;

    // RGB buses
    logic [11:0] background_rgb;
    logic [11:0] box_rgb;
    logic [11:0] final_rgb;

    // Aceasta functie intoarce un rand din litera selectata.
    // Fiecare litera este desenata ca o matrice de 5x7 biti.
    // Font data for the NO SIGNAL text
    function automatic logic [4:0] get_glyph_row(
        input logic [3:0] char_id_in,
        input logic [2:0] row_in
    );
        begin
            get_glyph_row = 5'b00000;

            case (char_id_in)

                CHAR_N: begin
                    case (row_in)
                        3'd0: get_glyph_row = 5'b10001;
                        3'd1: get_glyph_row = 5'b11001;
                        3'd2: get_glyph_row = 5'b10101;
                        3'd3: get_glyph_row = 5'b10011;
                        3'd4: get_glyph_row = 5'b10001;
                        3'd5: get_glyph_row = 5'b10001;
                        3'd6: get_glyph_row = 5'b10001;
                        default: get_glyph_row = 5'b00000;
                    endcase
                end

                CHAR_O: begin
                    case (row_in)
                        3'd0: get_glyph_row = 5'b01110;
                        3'd1: get_glyph_row = 5'b10001;
                        3'd2: get_glyph_row = 5'b10001;
                        3'd3: get_glyph_row = 5'b10001;
                        3'd4: get_glyph_row = 5'b10001;
                        3'd5: get_glyph_row = 5'b10001;
                        3'd6: get_glyph_row = 5'b01110;
                        default: get_glyph_row = 5'b00000;
                    endcase
                end

                CHAR_S: begin
                    case (row_in)
                        3'd0: get_glyph_row = 5'b01111;
                        3'd1: get_glyph_row = 5'b10000;
                        3'd2: get_glyph_row = 5'b10000;
                        3'd3: get_glyph_row = 5'b01110;
                        3'd4: get_glyph_row = 5'b00001;
                        3'd5: get_glyph_row = 5'b00001;
                        3'd6: get_glyph_row = 5'b11110;
                        default: get_glyph_row = 5'b00000;
                    endcase
                end

                CHAR_I: begin
                    case (row_in)
                        3'd0: get_glyph_row = 5'b11111;
                        3'd1: get_glyph_row = 5'b00100;
                        3'd2: get_glyph_row = 5'b00100;
                        3'd3: get_glyph_row = 5'b00100;
                        3'd4: get_glyph_row = 5'b00100;
                        3'd5: get_glyph_row = 5'b00100;
                        3'd6: get_glyph_row = 5'b11111;
                        default: get_glyph_row = 5'b00000;
                    endcase
                end

                CHAR_G: begin
                    case (row_in)
                        3'd0: get_glyph_row = 5'b01110;
                        3'd1: get_glyph_row = 5'b10001;
                        3'd2: get_glyph_row = 5'b10000;
                        3'd3: get_glyph_row = 5'b10111;
                        3'd4: get_glyph_row = 5'b10001;
                        3'd5: get_glyph_row = 5'b10001;
                        3'd6: get_glyph_row = 5'b01110;
                        default: get_glyph_row = 5'b00000;
                    endcase
                end

                CHAR_A: begin
                    case (row_in)
                        3'd0: get_glyph_row = 5'b01110;
                        3'd1: get_glyph_row = 5'b10001;
                        3'd2: get_glyph_row = 5'b10001;
                        3'd3: get_glyph_row = 5'b11111;
                        3'd4: get_glyph_row = 5'b10001;
                        3'd5: get_glyph_row = 5'b10001;
                        3'd6: get_glyph_row = 5'b10001;
                        default: get_glyph_row = 5'b00000;
                    endcase
                end

                CHAR_L: begin
                    case (row_in)
                        3'd0: get_glyph_row = 5'b10000;
                        3'd1: get_glyph_row = 5'b10000;
                        3'd2: get_glyph_row = 5'b10000;
                        3'd3: get_glyph_row = 5'b10000;
                        3'd4: get_glyph_row = 5'b10000;
                        3'd5: get_glyph_row = 5'b10000;
                        3'd6: get_glyph_row = 5'b11111;
                        default: get_glyph_row = 5'b00000;
                    endcase
                end

                default: begin
                    get_glyph_row = 5'b00000;
                end

            endcase
        end
    endfunction

      // Aceasta functie stabileste in ce caracter din text ne aflam.
    // Textul are 9 pozitii: N O spatiu S I G N A L
    // Character index for the NO SIGNAL string
    function automatic logic [3:0] get_char_index(
        input logic [7:0] col_in
    );
        begin
            if      (col_in < 8'd6)  get_char_index = 4'd0;
            else if (col_in < 8'd12) get_char_index = 4'd1;
            else if (col_in < 8'd18) get_char_index = 4'd2;
            else if (col_in < 8'd24) get_char_index = 4'd3;
            else if (col_in < 8'd30) get_char_index = 4'd4;
            else if (col_in < 8'd36) get_char_index = 4'd5;
            else if (col_in < 8'd42) get_char_index = 4'd6;
            else if (col_in < 8'd48) get_char_index = 4'd7;
            else if (col_in < 8'd54) get_char_index = 4'd8;
            else                     get_char_index = 4'd15;
        end
    endfunction

    // Character selector for the text "NO SIGNAL"
    function automatic logic [3:0] get_char_id(
        input logic [3:0] index_in
    );
        begin
            case (index_in)
                4'd0: get_char_id = CHAR_N;
                4'd1: get_char_id = CHAR_O;
                4'd2: get_char_id = CHAR_SPACE;
                4'd3: get_char_id = CHAR_S;
                4'd4: get_char_id = CHAR_I;
                4'd5: get_char_id = CHAR_G;
                4'd6: get_char_id = CHAR_N;
                4'd7: get_char_id = CHAR_A;
                4'd8: get_char_id = CHAR_L;
                default: get_char_id = CHAR_SPACE;
            endcase
        end
    endfunction

    // Aceasta functie calculeaza coloana pixelului in interiorul literei curente.
    // CHAR_CELL este 6 deoarece litera are 5 pixeli, iar unul este spatiu intre caractere.
    // Column position inside one 5x7 character cell
    function automatic logic [2:0] get_glyph_col(
        input logic [7:0] col_in
    );
        begin
            if      (col_in < 8'd6)  get_glyph_col = col_in[2:0];
            else if (col_in < 8'd12) get_glyph_col = col_in - 8'd6;
            else if (col_in < 8'd18) get_glyph_col = col_in - 8'd12;
            else if (col_in < 8'd24) get_glyph_col = col_in - 8'd18;
            else if (col_in < 8'd30) get_glyph_col = col_in - 8'd24;
            else if (col_in < 8'd36) get_glyph_col = col_in - 8'd30;
            else if (col_in < 8'd42) get_glyph_col = col_in - 8'd36;
            else if (col_in < 8'd48) get_glyph_col = col_in - 8'd42;
            else if (col_in < 8'd54) get_glyph_col = col_in - 8'd48;
            else                     get_glyph_col = 3'd7;
        end
    endfunction

    // Pixel selector from one glyph row
    function automatic logic get_glyph_pixel(
        input logic [4:0] row_bits,
        input logic [2:0] col_in
    );
        begin
            case (col_in)
                3'd0: get_glyph_pixel = row_bits[4];
                3'd1: get_glyph_pixel = row_bits[3];
                3'd2: get_glyph_pixel = row_bits[2];
                3'd3: get_glyph_pixel = row_bits[1];
                3'd4: get_glyph_pixel = row_bits[0];
                default: get_glyph_pixel = 1'b0;
            endcase
        end
    endfunction

    // Background color bar generator
    function automatic logic [11:0] get_background_rgb(
        input logic [9:0] x,
        input logic [9:0] y
    );
        begin
            if (y < 10'd360) begin
                if      (x < 10'd91)  get_background_rgb = 12'hFFF;
                else if (x < 10'd182) get_background_rgb = 12'hFF0;
                else if (x < 10'd273) get_background_rgb = 12'h0FF;
                else if (x < 10'd365) get_background_rgb = 12'h0F0;
                else if (x < 10'd456) get_background_rgb = 12'hF0F;
                else if (x < 10'd548) get_background_rgb = 12'hF00;
                else                  get_background_rgb = 12'h00F;
            end else if (y < 10'd400) begin
                if      (x < 10'd91)  get_background_rgb = 12'h00F;
                else if (x < 10'd182) get_background_rgb = 12'h000;
                else if (x < 10'd273) get_background_rgb = 12'hF0F;
                else if (x < 10'd365) get_background_rgb = 12'h000;
                else if (x < 10'd456) get_background_rgb = 12'h0FF;
                else if (x < 10'd548) get_background_rgb = 12'h000;
                else                  get_background_rgb = 12'hFFF;
            end else begin
                if      (x < 10'd112) get_background_rgb = 12'h004;
                else if (x < 10'd228) get_background_rgb = 12'hFFF;
                else if (x < 10'd340) get_background_rgb = 12'h408;
                else                  get_background_rgb = 12'h000;
            end
        end
    endfunction

    // Horizontal and vertical pixel counters
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

    // Horizontal box position
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            box_x <= 10'd180;
        end else if (frame_tick) begin
            if (hit_right)
                box_x <= H_ACTIVE - BOX_W;
            else if (hit_left)
                box_x <= 10'd0;
            else if (dir_x)
                box_x <= box_x + MOVE_STEP;
            else
                box_x <= box_x - MOVE_STEP;
        end
    end

    //BOX pozitia 
    // Vertical box position
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            box_y <= 10'd160;
        end else if (frame_tick) begin
            if (hit_bottom)
                box_y <= V_ACTIVE - BOX_H;
            else if (hit_top)
                box_y <= 10'd0;
            else if (dir_y)
                box_y <= box_y + MOVE_STEP;
            else
                box_y <= box_y - MOVE_STEP;
        end
    end

    // Horizontal movement direction
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            dir_x <= 1'b1;
        end else if (frame_tick) begin
            if (hit_right)
                dir_x <= 1'b0;
            else if (hit_left)
                dir_x <= 1'b1;
        end
    end

    // Vertical movement direction
    always_ff @(posedge pix_clk) begin
        if (!rst_n) begin
            dir_y <= 1'b1;
        end else if (frame_tick) begin
            if (hit_bottom)
                dir_y <= 1'b0;
            else if (hit_top)
                dir_y <= 1'b1;
            else if (hit_right)
                dir_y <= ~dir_y;
        end
    end

    // VGA visible area and synchronization zones
    assign active_area = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

    assign hsync_area = (h_count >= H_ACTIVE + H_FP) &&
                        (h_count <  H_ACTIVE + H_FP + H_SYNC);

    assign vsync_area = (v_count >= V_ACTIVE + V_FP) &&
                        (v_count <  V_ACTIVE + V_FP + V_SYNC);

    assign frame_tick = (h_count == H_TOTAL - 1) &&
                        (v_count == V_TOTAL - 1);

    // VGA synchronization outputs
    assign hsync = (!rst_n) ? ~H_POL :
                   (hsync_area ? H_POL : ~H_POL);

    assign vsync = (!rst_n) ? ~V_POL :
                   (vsync_area ? V_POL : ~V_POL);

    // Collision detection for the moving box  (cand ajunge in capete)
    assign hit_right  = dir_x  && (box_x >= H_ACTIVE - BOX_W - MOVE_STEP);
    assign hit_left   = !dir_x && (box_x <= MOVE_STEP);

    assign hit_bottom = dir_y  && (box_y >= V_ACTIVE - BOX_H - MOVE_STEP);
    assign hit_top    = !dir_y && (box_y <= MOVE_STEP);

    // Local coordinates inside the moving box
    assign box_area = active_area &&
                      (h_count >= box_x) &&
                      (h_count <  box_x + BOX_W) &&
                      (v_count >= box_y) &&
                      (v_count <  box_y + BOX_H);

    assign local_x = (h_count >= box_x) ? (h_count - box_x) : 10'd0;
    assign local_y = (v_count >= box_y) ? (v_count - box_y) : 10'd0;

    // Text area inside the black box
    assign text_area = box_area &&
                       (local_x >= TEXT_X) &&
                       (local_x <  TEXT_X + TEXT_W) &&
                       (local_y >= TEXT_Y) &&
                       (local_y <  TEXT_Y + TEXT_H);

    assign tx = text_area ? (local_x - TEXT_X) : 10'd0;
    assign ty = text_area ? (local_y - TEXT_Y) : 10'd0;

    assign text_col = tx[9:2];
    assign text_row = ty[9:2];

    assign char_index = get_char_index(text_col);
    assign char_id    = get_char_id(char_index);

    assign glyph_col  = get_glyph_col(text_col);
    assign glyph_row  = text_row[2:0];
    assign glyph_bits = get_glyph_row(char_id, glyph_row);

    assign text_pixel = text_area &&
                        (glyph_col < CHAR_W) &&
                        get_glyph_pixel(glyph_bits, glyph_col);

    // Final RGB composition 
    assign background_rgb = get_background_rgb(h_count, v_count);
    assign box_rgb        = text_pixel ? 12'hFFF : 12'h000;

    assign final_rgb = (!rst_n || !active_area) ? 12'h000 :
                       (box_area ? box_rgb : background_rgb);

    assign vga_red   = final_rgb[11:8];
    assign vga_green = final_rgb[7:4];
    assign vga_blue  = final_rgb[3:0];

endmodule