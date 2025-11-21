module btn_ctrl(	input clk,
				input reset_n,
				input a,
				input b,
				input c,
				output start,
				output reg [WIDTH-1:0] ctrl);
	
	parameter WIDTH = 6;
	parameter LIMIT = 19;
	parameter DEBOUNCE = 15000;
	//parameter INITIAL = 9;
	
reg [2:0] btn;
reg [2:0] btn_d1;
reg [2:0] btn_d2;
always@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        btn <= 3'b111;
        btn_d1 <= 3'b111;
        btn_d2 <= 3'b111;
    end else begin
        btn <= {c,b,a};
        btn_d1 <= btn;
        btn_d2 <= btn_d1;
    end
end

wire b2_fall = ~btn_d1[0] & btn_d2[0];
wire b3_fall = ~btn_d1[1] & btn_d2[1];
assign start = ~btn_d1[2] & btn_d2[2];
		
	always @ (posedge clk or negedge reset_n)
	begin : encoder_logic
		if (!reset_n)
		begin
			ctrl <= 9;
		end
		
		else if (b3_fall) 
		begin
			if (ctrl < LIMIT) 
				ctrl <= ctrl + 1'b1; 
			else
				ctrl <= ctrl; 
			
		end
		
		else if (b2_fall) 
		begin
			if (ctrl > 1) 
				ctrl <= ctrl - 1'b1; 
			else
				ctrl <= ctrl;
		end
	end
	
endmodule
