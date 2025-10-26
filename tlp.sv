class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  rand bit [31:0]tlp_doorbell_header[2:0];
  rand bit [31:0]tlp_doorbell_payload;
  rand bit [31:0]tlp_descriptor_header[2:0];
  rand bit [31:0]tlp_descriptor_payload[3:0];

  function new(string name="transaction");
  super.new(name);
  endfunction

  //DOORBELL
  constraint c1{
    tlp_doorbell_header[0][31:29] == 1;//fmt
    tlp_doorbell_header[0][28:24] == 0;//type
    tlp_doorbell_header[0][23:8] == 0;
    tlp_doorbell_header[0][7:0] == 1;//len
    tlp_doorbell_header[1][31:16] == 1;//req_id
    tlp_doorbell_header[1][15:8] == 1;//tag
    tlp_doorbell_header[1][7:0] == 1;//valid payload
    tlp_doorbell_header[2] == 1;//DMA_BAR
  }

  constraint c2{
  tlp_doorbell_payload == 1;//DESCR_ADDR
  }

  //DESCRIPTOR
  constraint c3{
    tlp_descriptor_header[0][31:29] == 1;//fmt
    tlp_descriptor_header[0][28:24] == 0;//type
    tlp_descriptor_header[0][23:8] == 0;
    tlp_descriptor_header[0][7:0] == 4;//length
    tlp_descriptor_header[1][31:16] == 1;
    tlp_descriptor_header[1][15:8] == 1;
    tlp_descriptor_header[1][7:0] == 1;
    tlp_descriptor_header[2] == 1; }//DMA_BAR
  
  constraint c4{
    tlp_descriptor_payload[0] == 3;//SRC ADDR
    tlp_descriptor_payload[1] == 10;//DEST ADDR
    tlp_descriptor_payload[2] == 3;//LENGTH OF PAYLOAD
    tlp_descriptor_payload[3] == 1;//control flags
  }
endclass
