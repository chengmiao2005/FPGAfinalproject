module DevelopmentBoard(
    input wire clk, //50MHz
    input wire reset, B2, B3, B4, B5,
	 // reset is "a"
	 // B2 is "s"
	 // B3 is "d"
	 // B4 is "f"
	 // B5 is "g"
    output wire h_sync, v_sync,
    output wire [15:0] rgb,
	
	output wire led1,
	output wire led2,
	output wire led3,
	output wire led4,
	output wire led5
);

reg [3:0] btn;
reg [3:0] btn_d1;
reg [3:0] btn_d2;
always@(posedge clk or negedge reset) begin
    if(~reset) begin
        btn <= 4'b1111;
        btn_d1 <= 4'b1111;
        btn_d2 <= 4'b1111;
    end else begin
        btn <= {B5,B4,B3,B2};
        btn_d1 <= btn;
        btn_d2 <= btn_d1;
    end
end

wire b2_fall = ~btn_d1[0] & btn_d2[0];
wire b3_fall = ~btn_d1[1] & btn_d2[1];
wire b4_fall = ~btn_d1[2] & btn_d2[2];
wire b5_fall = ~btn_d1[3] & btn_d2[3];

wire [2:0] vgaRgb;
wire [9:0] pix_x;
wire [9:0] pix_y;
wire [15:0] start_rgb;
wire lose;
reg [2:0] mode;
assign rgb = (mode == 0 || mode == 3) ? start_rgb : {{5{vgaRgb[2]}},{6{vgaRgb[1]}},{5{vgaRgb[0]}}};

reg clk25m;
always@(posedge clk or negedge reset) begin
    if(~reset) begin
        clk25m <= 0;
    end else begin
        clk25m <= ~clk25m;
    end
end

always@(posedge clk or negedge reset) begin
    if(~reset) begin
        mode <= 0;
    end else if(b2_fall & (mode==0)) begin
        mode <= 2'd1;
    end else if(b5_fall & (mode==0)) begin
        mode <= 2'd2;
    end else if(b3_fall & (mode==0)) begin
        mode <= 3'd4;
	end else if(lose & (mode==1 | mode==2)) begin
        mode <= 2'd3;
	end else if(b2_fall & (mode==3)) begin
        mode <= 2'd0;		
    end
end

start_end start_end(
    .clk(clk25m),
    .rst(~reset),
    .video_hs	(h_sync),     
    .video_vs	(v_sync),    
	.mode(mode) ,
    .pixel_xpos	(pix_x),
    .pixel_ypos (pix_y) ,
    .rgb565(start_rgb)
);

breakout_top breakout_top(  
	.clk(clk),
    .reset_n(reset),
	.btn_start(B2|B5),
    .btn_l(B3),
    .btn_r(B4),
    .mode(mode[2:1]),
	.hcount(pix_x),
    .vcount(pix_y),
    .rgb(vgaRgb),
	.lose(lose),
    .hsync(h_sync),
    .vsync(v_sync)
);


	// Instantiate your model
	// Simple_VGA Simple_VGA_inst(
	// 	.sys_clk(clk),
	// 	.sys_rst_n(reset),
	// 	.hsync(h_sync),
	// 	.vsync(v_sync),
	// 	.rgb(rgb),
	// 	.up(B2),
	// 	.down(B3),
	// 	.left(B4),
	// 	.right(B5),
	// 	.led1(led1),
	// 	.led2(led2),
	// 	.led3(led3),
	// 	.led4(led4),
	// 	.led5(led5)
	// );
    


endmodule
