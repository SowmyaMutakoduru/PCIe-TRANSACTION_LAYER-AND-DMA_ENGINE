module dma(
  input clk, rst,
  //tl to dma
  output reg tl_dma_tready,
  input tl_dma_tvalid,
  input tl_dma_tlast,
  input [95:0] tl_dma_tuser,
  input [127:0] tl_dma_tdata,

  //dma to tl
  input dma_tl_tready,
  output reg dma_tl_tvalid,
  output reg dma_tl_tlast,
  output reg [95:0] dma_tl_tuser,
  output reg [31:0] dma_tl_tdata
);
 

  typedef enum logic[1:0] {DOORBELL_RX, SEND_READ_REQ, DESCRIPTOR_RX, WRITE_DATA} dma_states;
  dma_states state;

  assign tl_dma_tready = (state == DOORBELL_RX || state == DESCRIPTOR_RX)?1:0;

  reg [127:0] tuser_reg;
  reg [127:0]tdata_reg;

  reg [95:0] send_req_tuser = {64'B0, 5'B1,3'B0, 24'B0};
  reg [95:0] send_data_tuser = {64'B0, 5'B0, 3'B1, 16'B0, 8'B0};
  reg [7:0] length;
  reg [7:0] count;

  reg [127:0] mem [7:0];
  int i=0;

  always @(posedge clk)begin
    if(rst) begin
      state <= DOORBELL_RX;
      count <= 0;
      dma_tl_tvalid <= 0;
      tdata_reg <= 0;
      tuser_reg <= 0;
      dma_tl_tuser <= 0;
      dma_tl_tdata <= 0;
      dma_tl_tlast <= 0;
      for( i = 0; i<8; i++) begin
        mem[i]=i+1;
      end
    end
    else begin
      case (state)

        DOORBELL_RX : begin
          if(tl_dma_tready && tl_dma_tvalid )begin
            tuser_reg <= tl_dma_tuser;
            tdata_reg <= tl_dma_tdata;
            state <= SEND_READ_REQ;
            dma_tl_tvalid <= 1;
          end
          else begin
            state <= state;
          end
        end

        SEND_READ_REQ: begin
          if(dma_tl_tready)begin
            dma_tl_tuser <= {tdata_reg, send_req_tuser};
            state <= DESCRIPTOR_RX;
            dma_tl_tvalid <= 0;
          end
          else begin
            state <= state;
          end
        end

        DESCRIPTOR_RX: begin
          if(tl_dma_tready && tl_dma_tvalid )begin
            tuser_reg <= tl_dma_tuser;
            length <= tl_dma_tdata [95:64];
            send_data_tuser[7:0] <= tl_dma_tdata[95:64];
            send_data_tuser[95:064] <= tl_dma_tdata [63:32];
            tdata_reg <= tl_dma_tdata;
            state <= WRITE_DATA;
          end
          else begin
            state <= state;
          end
       	end

        WRITE_DATA:begin
          if(dma_tl_tready)begin
            if(count < length) begin
              dma_tl_tvalid <= 1;
              dma_tl_tdata <= mem[tdata_reg[31:0]+count];
              dma_tl_tuser <= {send_data_tuser};
              count <= count+1;
            end
            else begin
              state <= state;
            end
            if(count == length)begin
              dma_tl_tvalid <= 0;
            end
            else begin
              state <= state;
            end
            if(count == length && !dma_tl_tvalid)begin
              state <= DOORBELL_RX;
            end
            else begin
              state <= state;
            end
          end
          else begin
            state<=state;
          end
        end
      endcase
    end
  end
endmodule
