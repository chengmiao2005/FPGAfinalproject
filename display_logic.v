module display_logic(   input pxl_clk,
                        input reset_n,
                        input [9:0] hcount,
                        input [9:0] vcount,
                        input [9:0] ball_y,
                        input [9:0] ball_x,
                        input [5:0] paddle_position,
                        input [3:0] block_num,
                        input vsync,
                        input lose,
                        input win,
                        input [7:0] block_status1,
                        input [7:0] block_status2,
                        input [7:0] block_status3,
                        output reg drawing_player,
                        output reg [2:0] drawing_block,
                        output reg [2:0] rgb    );
    
    `include "defines.v"
    
    reg [2:0] flash;
    reg [3:0] flash_time;
    reg flash_hold;

    reg [9:0] block_vcount;
    reg [9:0] block_hcount;
    reg [2:0] rgb_block;

    always@(*) begin
        block_vcount[9:0] = vcount - `blocks_vstart;
        block_hcount[9:0] = hcount - `blocks_hstart;

        rgb_block = 0;
        if (vcount > `blocks_vstart && vcount <= `blocks_vend && hcount > `blocks_hstart && hcount <= `blocks_hend)
        begin
            rgb_block = block_status1[block_hcount[8:6]] ? block_hcount[8:6] : 0;
        end                    
        else if (vcount > `blocks_vstart2 && vcount <= `blocks_vend2 && hcount > `blocks_hstart && hcount <= `blocks_hend)
        begin
            rgb_block = block_status2[block_hcount[8:6]] ? block_hcount[8:6] : 0;
        end                    
        else if (vcount > `blocks_vstart4 && vcount <= `blocks_vend4 && hcount > `blocks_hstart && hcount <= `blocks_hend)
        begin
            rgb_block = block_status3[block_hcount[8:6]] ? block_hcount[8:6] : 0;
        end
    end

    always@(posedge pxl_clk or negedge reset_n) begin
        if(~reset_n)
            drawing_player <= 0;
        else if(   vcount > `player_vstart && vcount < (`player_vstart + `player_width ) && 
                    hcount > (paddle_position << 5) - `player_hlength + `left_edge && 
                    hcount < ((paddle_position << 5) + `player_hlength + `left_edge) )
            drawing_player <= 1;
        else
            drawing_player <= 0;
    end


    always@(posedge pxl_clk or negedge reset_n) begin
        if(~reset_n)
            drawing_block <= 0;
        else if(vcount > `blocks_vstart && vcount <= `blocks_vend && hcount > `blocks_hstart && hcount <= `blocks_hend)
            drawing_block <= 3'd1;
        else if(vcount > `blocks_vstart2 && vcount <= `blocks_vend2 && hcount > `blocks_hstart && hcount <= `blocks_hend)
            drawing_block <= 3'd2;
        else if(vcount > `blocks_vstart4 && vcount <= `blocks_vend4 && hcount > `blocks_hstart && hcount <= `blocks_hend)
            drawing_block <= 3'd4;
        else
            drawing_block <= 0;
    end

    always@(posedge pxl_clk or negedge reset_n)
    begin
        if(~reset_n)
            rgb <= 3'd0;
        else if (hcount > `screen_right || vcount > `screen_bottom) rgb <= 3'b000;
        
        else if (win) rgb <= flash;
        
        else if (lose) rgb <= `red;
        
        else if (vcount < `bottom_edge && hcount < `left_edge) rgb <= `green;
        
        else if (vcount < `bottom_edge && hcount > `right_edge) rgb <= `green;
        
        else if (vcount < `top_edge ) rgb <= `green;
        
        else if (vcount > `bottom_edge) rgb <= `red;
     
        else if (vcount < ball_y + 3 && vcount > ball_y - 3 && 
                    hcount < ball_x + 3 && hcount > ball_x - 3) rgb <= `white;
        
        else if (   vcount > `player_vstart && vcount < (`player_vstart + `player_width ) && 
                    hcount > (paddle_position << 5) - `player_hlength + `left_edge && 
                    hcount < ((paddle_position << 5) + `player_hlength + `left_edge) ) 
        begin
            rgb <= `white;
        end 

        else if (vcount > `blocks_vstart && vcount <= `blocks_vend && hcount > `blocks_hstart && hcount <= `blocks_hend)
        begin
            rgb <= block_status1[block_hcount[8:6]] ? (|rgb_block ? rgb_block : rgb_block + 3) : 0;
        end                    
        else if (vcount > `blocks_vstart2 && vcount <= `blocks_vend2 && hcount > `blocks_hstart && hcount <= `blocks_hend)
        begin
            rgb <= block_status2[block_hcount[8:6]] ? (|rgb_block ? rgb_block : rgb_block + 3) : 0;
        end
        else if (vcount > `blocks_vstart4 && vcount <= `blocks_vend4 && hcount > `blocks_hstart && hcount <= `blocks_hend)
        begin
            rgb <= block_status3[block_hcount[8:6]] ? (|rgb_block ? rgb_block : rgb_block + 3) : 0;
        end
        
        else rgb <= `black;
    end
    
    always @ (posedge pxl_clk)
    begin
        if (vsync)
        begin
            if (!flash_hold) flash_time <= flash_time + 1;
        
            flash_hold <= 1;
        end
            
        else
        begin
            flash_hold <= 0;
        end
        
        if (flash_time == 0)
        begin
            flash <= `black;
        end
        
        
        else if (flash_time == 3)
        begin
            if (win) flash <=  `white;
            else if (lose) flash <= `red;
        end
        
        else if (flash_time >= 6)
        begin
            flash_time <= 0;
        end
        
    end

endmodule
