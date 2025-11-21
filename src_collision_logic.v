module collision_logic( input pxl_clk,
                        input reset_n,
                        input [9:0] vcount,
                        input [9:0] hcount,
                        input [9:0] ball_x,
                        input [9:0] ball_y,
                        input vsync,
                        input start,
                        input [1:0] mode,
                        input drawing_player,
                        input [2:0] drawing_block,
                        output reg win,
                        output reg lose,
                        output wire [3:0] block_num,
                        output reg [7:0] block_status1,
                        output reg [7:0] block_status2,
                        output reg [7:0] block_status3,
                        output reg h_collision,
                        output reg v_collision );

  `include "defines.v"                        

    reg block_clr;
    wire [9:0] block_addr_r;
    reg [9:0] block_addr_wr;
    reg [3:0] block_to_delete;
    
    reg [4:0] num_blocks;
    reg [9:0] block_addr;
    
    reg checked;
    reg [1:0] hold;

    
    wire [9:0] block_hcount = hcount - `blocks_hstart;;
    
    always @ (posedge pxl_clk or negedge reset_n)
    begin : delete_objects
    
        if (!reset_n)
        begin
            block_addr_wr <= 0;
            checked <= 1;
            block_clr <= 0;
            block_to_delete <= 0;
            v_collision <= 0;
            h_collision <= 0;
            hold <= 0;
            win <= 0;
            lose <= 0;
            num_blocks <= 0;
            block_status1 <= 0;
            block_status2 <= 0;
            block_status3 <= 0;
        end

        else if(start)
        begin
            if(mode[0]) begin
                num_blocks <= 16;
                block_status1 <= 8'hFF;
                block_status2 <= 0;
                block_status3 <= 8'hFF;
            end else if(mode[1])begin
                num_blocks <= 1;
                block_status1 <= 8'h01;
                block_status2 <= 8'h00;
                block_status3 <= 8'h00;
            end else begin
                num_blocks <= 24;
                block_status1 <= 8'hff;
                block_status2 <= 8'hff;
                block_status3 <= 8'hff;
            end
        end
        
        else if (~vsync)
        begin
            block_clr <= 0;
        
            if (drawing_player) 
            begin
                
                if (ball_x == hcount && ball_y-3 <= vcount && ball_y + 3 >= vcount) v_collision <= 1;
                else v_collision <= 0;
                
            end 
                        
            else if (drawing_block[0])
            begin
                if (ball_x == hcount && ball_y - 10 <= vcount && ball_y + 10 >= vcount & block_status1[block_hcount[8:6]])
                begin
                    v_collision <= 1;
                    block_status1[block_hcount[8:6]] <= 0;
                    num_blocks <= num_blocks - 1;
                    if (num_blocks == 1) win <= 1;
                    
                end
                
                else if (ball_y == vcount && ball_x - 5 <= hcount && ball_x + 5 >= hcount & block_status1[block_hcount[8:6]]) 
                begin
                    h_collision <= 1;
                    block_status1[block_hcount[8:6]] <= 0;
                    num_blocks <= num_blocks - 1;
                    if (num_blocks == 1) win <= 1;
                end
                
                else
                begin
                    v_collision <= 0;
                    h_collision <= 0;
                end
            end

            else if (drawing_block[1])
            begin
                if (ball_x == hcount && ball_y - 1 <= vcount && ball_y + 10 >= vcount & block_status2[block_hcount[8:6]])
                begin
                    v_collision <= 1;
                    block_status2[block_hcount[8:6]]  <= 0;
                    num_blocks <= num_blocks - 1;
                    if (num_blocks == 1) win <= 1;
                    
                end
                
                else if (ball_y == vcount && ball_x - 5 <= hcount && ball_x + 5 >= hcount & block_status2[block_hcount[8:6]]) 
                begin
                    h_collision <= 1;
                    block_status2[block_hcount[8:6]]  <= 0;
                    num_blocks <= num_blocks - 1;
                    if (num_blocks == 1) win <= 1;
                end
                
                else
                begin
                    v_collision <= 0;
                    h_collision <= 0;
                end
            end

            else if (drawing_block[2])
            begin
                if (ball_x == hcount && ball_y - 1 <= vcount && ball_y + 10 >= vcount & block_status3[block_hcount[8:6]])
                begin
                    v_collision <= 1;
                    block_status3[block_hcount[8:6]]  <= 0;
                    num_blocks <= num_blocks - 1;
                    if (num_blocks == 1) win <= 1;
                    
                end
                
                else if (ball_y == vcount && ball_x - 5 <= hcount && ball_x + 5 >= hcount & block_status3[block_hcount[8:6]]) 
                begin
                    h_collision <= 1;
                    block_status3[block_hcount[8:6]]  <= 0;
                    num_blocks <= num_blocks - 1;
                    if (num_blocks == 1) win <= 1;
                end
                
                else
                begin
                    v_collision <= 0;
                    h_collision <= 0;
                end
            end
            
            else if (ball_y >= `bottom_edge) lose <= 1;
        end
            
        else if (vsync && checked) //initialize addresses
        begin
            block_addr_wr <= 0;
            checked <= 0;
            block_clr <= 0;
            hold <= 0;
        end
        
        
        else if (vsync && !checked)
        begin
            if (block_num != 0 && block_num == block_to_delete) 
            begin
                block_clr <= 1;
            end

            else 
            begin
                block_clr <= 0;
                //hold <= 0;
                //block_addr_wr <= block_addr_wr + 1;
            end
            
            if (hold != 2 ) block_addr_wr <= block_addr_wr;
            else block_addr_wr <= block_addr_wr + 1;
            
            hold <= hold + 1;
            
            if (block_addr_wr >= 256) 
            begin
                block_addr_wr <= 0;
                checked <= 1;
            end
        end
    
    end
endmodule
