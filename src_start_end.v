module start_end(
    input   clk,
    input   rst,
    
    input  video_hs	,     
    input  video_vs	, 
    input  [1:0] mode,    
    input  	[9:0]  pixel_xpos	,
    input  	[9:0]  pixel_ypos  ,

    output reg [15:0] rgb565
);

reg [127:0] char_0 [0:31];
reg [127:0] char_1 [0:10];

integer i;
always@(posedge clk) begin
    if(rst) begin
        for(i=0; i<=31;i=i+1)
            char_0[i] <= 0;
    end else begin
        char_0[ 0] <= 128'h00000000000000000000000000000000;
        char_0[ 1] <= 128'h00000000000000000000000000000000;
        char_0[ 2] <= 128'h00000000000000000000000000000000;
        char_0[ 3] <= 128'h00000000000000000000000000000000;
        char_0[ 4] <= 128'h00000000000000000000000000000000;
        char_0[ 5] <= 128'h00000000000000000000000000000000;
        char_0[ 6] <= 128'h7FE07FE07FFC03807E7C03C0FC3E3FFC;
        char_0[ 7] <= 128'h18381838180C038018300C3030083184;
        char_0[ 8] <= 128'h18181818180403801820181830082186;
        char_0[ 9] <= 128'h180C180C180203801860100830084182;
        char_0[10] <= 128'h180C180C180204C01840300C30084182;
        char_0[11] <= 128'h180C180C180004C01880300C30080180;
        char_0[12] <= 128'h180C180C180004C01880600430080180;
        char_0[13] <= 128'h180C180C181004C01900600630080180;
        char_0[14] <= 128'h1818181818100C401900600630080180;
        char_0[15] <= 128'h18301830183008601B00600630080180;
        char_0[16] <= 128'h1FE01FE01FF008601D80600630080180;
        char_0[17] <= 128'h181818C0183008601D80600630080180;
        char_0[18] <= 128'h180C18C01810182018C0600630080180;
        char_0[19] <= 128'h1804186018101FF018C0600630080180;
        char_0[20] <= 128'h18061860180010301860600630080180;
        char_0[21] <= 128'h18061860180010301860200630080180;
        char_0[22] <= 128'h18061830180010301830300C30080180;
        char_0[23] <= 128'h18061830180220181830300C30080180;
        char_0[24] <= 128'h18061830180220181830100830080180;
        char_0[25] <= 128'h180C1818180420181818181818100180;
        char_0[26] <= 128'h18181818180C601C18180C301C200180;
        char_0[27] <= 128'h7FF07E1E7FFCF83E7E3E03C007C007E0;
        char_0[28] <= 128'h00000000000000000000000000000000;
        char_0[29] <= 128'h00000000000000000000000000000000;
        char_0[30] <= 128'h00000000000000000000000000000000;
        char_0[31] <= 128'h00000000000000000000000000000000;
    end
end

always@(posedge clk) begin
    if(rst) begin
        for(i=0; i<=31;i=i+1)
            char_1[i] <= 0;
    end else begin
        char_1[ 0] <= 128'h07F80380F00F7FFC00007FFCF01F7FC0;
        char_1[ 1] <= 128'h1C3C0380381C18040000180438041818;
        char_1[ 2] <= 128'h381C04C0381C1802000018022C04180C;
        char_1[ 3] <= 128'h700004C02C2C18000000180026041806;
        char_1[ 4] <= 128'hF0000C402C2C18100000181023041806;
        char_1[ 5] <= 128'hF00008602C4C1FF000001FF021841806;
        char_1[ 6] <= 128'hF0FF1820264C18100000181020C41806;
        char_1[ 7] <= 128'hF01C1030268C18000000180020641806;
        char_1[ 8] <= 128'h781C1030238C1800000018002034180C;
        char_1[ 9] <= 128'h381C2018230C180200001802201C1818;
        char_1[10] <= 128'h1E7C601C210C180C0000180C200C1860;
    end
end

reg video_vs_d;
reg content_sel;
wire vs_fall = ~video_vs & video_vs_d;
always@(posedge clk) begin
    if(rst) video_vs_d <= 0;
    else    video_vs_d <= video_vs;
end

always@(posedge clk) begin
    if(rst) content_sel <= 0;
    else if(vs_fall) begin
        content_sel <= ~content_sel;
    end
end

always@(posedge clk) begin
    if(rst) begin
        rgb565 <= 'h0;
    end else if(mode == 3)begin
        case(content_sel)
            1'b1: begin
                if(pixel_xpos >= 'd256 & pixel_xpos < 'd384 & pixel_ypos >=210 & pixel_ypos < 221) begin
                    rgb565 <= {16{char_1[pixel_ypos-210][384-pixel_xpos]}};
                end else begin
                    rgb565 <= 0;
                end
            end
            default: begin
                if(pixel_xpos >= 'd256 & pixel_xpos < 'd384 & pixel_ypos >=200 & pixel_ypos < 211) begin
                    rgb565 <= {16{char_1[pixel_ypos-200][384-pixel_xpos]}};
                end else begin
                    rgb565 <= 0;
                end
            end
        endcase
    end else begin
        case(content_sel)
            1'b1: begin
                if(pixel_xpos >= 'd256 & pixel_xpos < 'd384 & pixel_ypos >=210 & pixel_ypos < 242) begin
                    rgb565 <= {16{char_0[pixel_ypos-210][384-pixel_xpos]}};
                end else begin
                    rgb565 <= 0;
                end
            end
            default: begin
                if(pixel_xpos >= 'd256 & pixel_xpos < 'd384 & pixel_ypos >=200 & pixel_ypos < 232) begin
                    rgb565 <= {16{char_0[pixel_ypos-200][384-pixel_xpos]}};
                end else begin
                    rgb565 <= 0;
                end
            end
        endcase
    end
end

endmodule
