`timescale 1ns / 1ps
module first_order_dac(
  input wire i_clk,
  input wire i_res,
  input wire i_ce,
  input wire [15:0] i_func, 
  output wire o_DAC
);

  reg this_bit;
  reg [17:0] DAC_acc;
  reg  [17:0] i_func_extended;
   
  assign o_DAC = this_bit;
  
  always @(*)
     i_func_extended = {i_func[15],i_func[15],i_func};
    
  always @(posedge i_clk or posedge i_res)
  begin
    if (i_res==0)
        begin
          DAC_acc  <= 16'd0;
          this_bit <= 1'b0;
        end
    else if(i_ce == 1'b1) 
        begin
          if(this_bit == 1'b1)
            begin
              DAC_acc = DAC_acc + i_func_extended - (2**15);
            end
          else
            begin
              DAC_acc = DAC_acc + i_func_extended + (2**15);
            end
          // When the high bit is set (a negative value) we need to output a 0 and when it is clear we need to output a 1.
          this_bit = ~DAC_acc[17];
        end 
   end
endmodule