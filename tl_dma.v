module tl_dma(
  input clk,rst,
  // tb to tl
  input [31:0] tb_tl,
  input tb_tl_valid,
  output reg tb_tl_ready,

  //tl to dma
  input tl_dma_tready,
  output reg tl_dma_tvalid,
  output reg tl_dma_tlast,
  output reg [95:0] tl_dma_tuser,
  output reg [127:0] tl_dma_tdata,

  //dma to tl
  output reg dma_tl_tready,
  input dma_tl_tvalid,
  input dma_tl_tlast,
  input [95:0] dma_tl_tuser,
  input [31:0] dma_tl_tdata,

  //tl to tb
  output reg [31:0] tl_tb,
  output reg tl_tb_valid,
  input tl_tb_ready);

  typedef struct packed{
    reg [31:0] dw0;
    reg [31:0] dw1;
    reg [31:0] dw2;
  }header;

  typedef struct packed{
    reg [31:0] dw0;
    reg [31:0] dw1;
    reg [31:0] dw2;
    reg [31:0] dw3;
  }payload;

 
  typedef struct packed{
    header tlp_header;
    payload tlp_payload;
    reg [31:0] data;
  }tlp;
  tlp tlp_doorbell, tlp_read_req,tlp_descriptor;

  reg [7:0] count;
  reg doorbell_done;
  reg [31:0] tdata_reg;
  reg [63:0] tuser_reg;
  reg [31:0] tlp_header[2:0];
  reg [7:0] tlp_header_counter;
  reg [31:0] tlp_data[2 ** 8-1:0];
  reg [7:0] tlp_data_counter;
  reg [7:0] h_wptr=0, h_rptr =0, d_wptr=0, d_rptr=0;
  reg read_req_to_mem_done, header_done, descriptor_done, data_done;
  reg header_tlp_sent;

  typedef enum logic[2:0] {DOOR_BELL,DOOR_BELL_TO_DMA, READ_REQ, READ_REQ_TO_MEM, DESCRIPTOR, DESCRIPTOR_TO_DMA, DATA} tl_state;
  tl_state state;

  assign tb_tl_ready = (state == DOOR_BELL || state == DESCRIPTOR ) ?1:0;
  assign dma_tl_tready = (state == READ_REQ || state == DATA) ?1:0;
  assign tl_dma_tlast = (state == DOOR_BELL_TO_DMA && tl_dma_tready && tl_dma_tvalid) ?1:0;

  always@(posedge clk)begin
    if(rst)
      tl_dma_tvalid <= 0;
    else begin
      if(tl_dma_tvalid)
        tl_dma_tvalid <= 0;
      else
        tl_dma_tvalid <= tl_dma_tvalid;
    end
  end
  
  always@(posedge clk) begin
    if(rst) begin
      tl_tb_valid <= 0;
      count <= 0;
      tuser_reg <= 0;
      tdata_reg <= 0;
      tl_dma_tuser <= 0;
      state <= DOOR_BELL;
    end
    else begin
      case (state)
        
        DOOR_BELL:begin
          if(doorbell_done) begin
            state <= DOOR_BELL_TO_DMA;
            doorbell_done <= 0;
            count <= 0;
          end
          else begin
            state <= state;
          end
        end
        
        DOOR_BELL_TO_DMA: begin
          if(tl_dma_tready)begin
            tl_dma_tuser <= {tlp_descriptor.tlp_header.dw1 , tlp_doorbell.tlp_header.dw0};
            tl_dma_tdata <= {96'b0, tlp_doorbell.data};
            tl_dma_tvalid <= 1;
            state <= READ_REQ;
          end
          else begin
            state <= state;
          end
        end
        
        READ_REQ:begin
          if(dma_tl_tvalid && dma_tl_tready)begin
          tuser_reg <= dma_tl_tuser;
          tdata_reg <= dma_tl_tdata;
          state <= READ_REQ_TO_MEM;
          end
        end
        
        READ_REQ_TO_MEM:begin
          if(read_req_to_mem_done) begin
            state <= DESCRIPTOR;
            tl_tb_valid <= 1'b0;
            count <= 0;
            read_req_to_mem_done <= 0;
          end
          else begin
            state <= state;
          end
        end
        
        DESCRIPTOR:begin
          if(descriptor_done)begin
            state <= DESCRIPTOR_TO_DMA;
            count <= 0;
            descriptor_done <= 0;
          end
          else begin
            state <= state;
          end
        end
        
        DESCRIPTOR_TO_DMA:begin
          if(tl_dma_tready)begin
            tl_dma_tvalid <= 1;
            tl_dma_tuser <= {tlp_descriptor.tlp_header.dw1 , tlp_descriptor.tlp_header.dw0};
            tl_dma_tdata <= {tlp_descriptor.tlp_payload.dw3, tlp_descriptor.tlp_payload.dw2, tlp_descriptor.tlp_payload.dw1,tlp_descriptor.tlp_payload.dw0};
            state <= DATA;
          end
          else begin
            state <= state;
          end
        end
        
        DATA: begin
          if(dma_tl_tready && dma_tl_tvalid && !header_done )begin
            tlp_header[h_wptr] <= dma_tl_tuser[31:0];
            tlp_header[h_wptr+1] <= dma_tl_tuser[63:32] ;
            tlp_header[h_wptr+2] <= tlp_descriptor.tlp_payload.dw1;
            header_done <= 1;
            tlp_header_counter <= tlp_header_counter +3;
            h_wptr <= h_wptr+3;
          end
          else begin
            header_done <= header_done;
          end
          if(dma_tl_tready && dma_tl_tvalid && !data_done)begin
            tlp_data[d_wptr] <= dma_tl_tdata;
            tlp_data_counter <= tlp_data_counter +1;
            d_wptr <= d_wptr+1;
          end
          else begin
            tlp_data_counter <= tlp_data_counter;
          end
          if(data_done)begin
            doorbell_done <= 0;
            data_done <= 0;
            header_done <= 0;
            header_tlp_sent <= 0;
            h_rptr <= 0;
            h_wptr <= 0;
            d_wptr <= 0;
            d_rptr <= 0;
            tl_tb_valid <= 1'b0;
            state <= DOOR_BELL;
          end
          else begin
            state <= state;
          end
        end
      endcase
    end
  end
  
  //tl to tb header during data
  always@(posedge clk)begin
    if(rst) begin
      tlp_header_counter <= 0;
      header_tlp_sent <= 0;
      header_done <= 0;
    end
    else begin
      if((tlp_header_counter>1) && (header_tlp_sent == 0) && (tl_tb_ready == 1))begin
          tl_tb_valid <= 1;
          tl_tb <= tlp_header[h_rptr];
          h_rptr <= h_rptr+1;
          tlp_header_counter = tlp_header_counter -1 ;
        if(tlp_header_counter -1 == 0)begin
          header_tlp_sent <= 1;
        end
        else begin
          header_tlp_sent <= header_tlp_sent;
        end
      end
      else begin
        header_tlp_sent <= header_tlp_sent;
      end
    end
  end

  //tl to tb data
  always@(posedge clk) begin
    if(rst) begin
      tlp_data_counter <= 1;
    end
    else begin
      if(tlp_data_counter > 0 && header_tlp_sent && tl_tb_ready && state == DATA) begin
    tl_tb <= tlp_data[d_rptr];
    d_rptr <= d_rptr+1;
    tlp_data_counter = tlp_data_counter -1 ;
        if(tlp_data_counter-1 == 0)begin
          header_tlp_sent <= 0;
          d_rptr <= 0;
          data_done <= 1;
        end
    end
      else begin
        d_rptr <= d_rptr;
      end
    end
  end

//tb to tl descriptor
  always@(posedge clk)begin
    if(rst) begin
      descriptor_done <= 0;
      data_done <= 0;
    end
    else begin
      if(tb_tl_valid && tb_tl_ready && !descriptor_done) begin
        case(count)
          3'd0: begin
            tlp_descriptor.tlp_header.dw0 <= tb_tl;
          end
          3'd1: begin
            tlp_descriptor.tlp_header.dw1 <= tb_tl;
          end
          3'd2:begin
            tlp_descriptor.tlp_header.dw2 <= tb_tl;
          end
          3'd3: begin
            tlp_descriptor.tlp_payload.dw0 <= tb_tl;
          end
          3'd4: begin
            tlp_descriptor.tlp_payload.dw1 <= tb_tl;
          end
          3'd5: begin
            tlp_descriptor.tlp_payload.dw2 <= tb_tl;
          end
          3'd6: begin
            tlp_descriptor.tlp_payload.dw3 <= tb_tl;
            descriptor_done <= 1;
          end
        endcase
        count <= count+1;
      end
      else begin
        descriptor_done <= descriptor_done;
      end
    end
  end

//tl to tb read req
  always@(posedge clk)begin
    if(rst)begin
      read_req_to_mem_done <= 0;
    end
    else begin
      if(tl_tb_ready&& !read_req_to_mem_done && state == READ_REQ_TO_MEM) begin
      case (count)
        2'd0: begin
          tl_tb_valid <= 1;
          tl_tb <= tuser_reg[31:0];
        end
        2'd1:begin
          tl_tb <= tuser_reg[63:32] ;
        end
        2'd2: begin
          tl_tb <= tlp_doorbell.data;
          read_req_to_mem_done <= 1;
        end
      endcase
      count <= count+1;
      end
    end
  end

//input doorbell
  always@(posedge clk) begin
    if(rst) begin
      doorbell_done <= 0;
    end
    else begin
      if(tb_tl_valid && tb_tl_ready && !doorbell_done) begin
        case(count)
          2'd0: begin
            tlp_doorbell.tlp_header.dw0 <= tb_tl;
          end
          2'd1: begin
            tlp_doorbell.tlp_header.dw1 <= tb_tl;
          end
          2'd2: begin
            tlp_doorbell.tlp_header.dw2 <= tb_tl;
          end
          2'd3: begin
            tlp_doorbell.data <= tb_tl;
            doorbell_done <= 1;
          end
        endcase
        count <= count+1;
      end
      else begin
      doorbell_done <= doorbell_done;
      end
    end
  end

endmodule
