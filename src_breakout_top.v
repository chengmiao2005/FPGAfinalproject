module breakout_top(  input wire clk,
                    input wire reset_n,
                    input wire btn_start,
                    input wire btn_l,
                    input wire btn_r,
                    input wire [1:0] mode,

                    output wire [9:0] hcount,
                    output wire [9:0] vcount,
                    output wire [2:0] rgb,
                    output wire lose,
                    output wire hsync,
                    output wire vsync
                    );
                    
    `include "defines.v"                 
                    
    wire [5:0] paddle_position;
    wire pxl_clk;       //25 MHz clock from PLL    
    wire win;
    wire [9:0] ball_x;
    wire [9:0] ball_y;
    wire [3:0] block_num;
    wire v_collision;
    wire h_collision;

    wire drawing_player;
    wire [2:0] drawing_block;  
    wire [7:0] block_status1;
    wire [7:0] block_status2;
    wire [7:0] block_status3;
    
    wire start;
                    
    reg clk25m;
    always@(posedge clk) begin
        if(~reset_n)
            clk25m <= 0;
        else 
            clk25m <= ~clk25m;
    end                    
    assign pxl_clk = clk25m;
    
    btn_ctrl btn_ctrl (.clk(pxl_clk),
                            .reset_n(reset_n),
                            .a(btn_l),
                            .b(btn_r),
                            .c(btn_start),
                            .start(start),
                            .ctrl(paddle_position) );
                            


    vga vga_inst(   .pxl_clk(pxl_clk),
                    .reset_n(reset_n),
                    .hcount(hcount),
                    .vcount(vcount),
                    .vsync(vsync),
                    .hsync(hsync)   );


    ball_logic ball_inst(   .pxl_clk(pxl_clk),
                            .reset_n(reset_n),
                            .vsync(vsync),
                            .h_collision(h_collision),
                            .v_collision(v_collision),
                            .start(start),
                            .ball_x(ball_x),
                            .ball_y(ball_y) );
                            
    display_logic display_logic_inst(   .pxl_clk(pxl_clk),
                                        .reset_n(reset_n),
                                        .hcount(hcount),
                                        .vcount(vcount),
                                        .ball_y(ball_y),
                                        .ball_x(ball_x),
                                        .paddle_position(paddle_position),
                                        .block_num(block_num),
                                        .lose(lose),
                                        .win(win),
                                        .vsync(vsync),
                                        .block_status1(block_status1),
                                        .block_status2(block_status2),
                                        .block_status3(block_status3),
                                        .drawing_player(drawing_player),
                                        .drawing_block(drawing_block),
                                        .rgb(rgb)    );
                                        

    collision_logic collision_inst( .pxl_clk(pxl_clk),
                                    .reset_n(reset_n),
                                    .start(start),
                                    .mode(mode),
                                    .vcount(vcount),
                                    .hcount(hcount),
                                    .ball_x(ball_x),
                                    .ball_y(ball_y),
                                    .vsync(vsync),
                                    .drawing_player(drawing_player),
                                    .drawing_block(drawing_block),
                                    .win(win),
                                    .lose(lose),
                                    .block_num(block_num),
                                    .block_status1(block_status1),
                                    .block_status2(block_status2),
                                    .block_status3(block_status3),
                                    .h_collision(h_collision),
                                    .v_collision(v_collision)    );
    

endmodule
