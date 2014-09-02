  localparam NUM_CE = 11;
  
  wire [NUM_CE*64-1:0] ce_flat_o_tdata, ce_flat_i_tdata;
  wire [63:0]          ce_o_tdata[0:NUM_CE-1], ce_i_tdata[0:NUM_CE-1];
  wire [NUM_CE-1:0]    ce_o_tlast, ce_o_tvalid, ce_o_tready, ce_i_tlast, ce_i_tvalid, ce_i_tready;
  wire [63:0]          ce_debug[0:NUM_CE-1];
  wire [31:0]          set_data_ce[0:NUM_CE-1];
  wire [7:0]           set_addr_ce[0:NUM_CE-1];
  wire [NUM_CE-1:0]    set_stb_ce;
      
  // Flattern CE tdata arrays
  genvar k;
  generate
    for (k = 0; k < NUM_CE; k = k + 1) begin
      assign ce_o_tdata[k] = ce_flat_o_tdata[k*64+63:k*64];
      assign ce_flat_i_tdata[k*64+63:k*64] = ce_i_tdata[k];
    end
  endgenerate
  
  // Automatically instantiated CEs
  noc_block_schmidl_cox #(
    .NOC_ID(64'h5CC0_0000_0000_0000),
    .STR_SINK_FIFOSIZE(11))
  inst_noc_block_schmidl_cox (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .ce_clk(bus_clk), .ce_rst(bus_rst),
    .i_tdata(ce_o_tdata[0]), .i_tlast(ce_o_tlast[0]), .i_tvalid(ce_o_tvalid[0]), .i_tready(ce_o_tready[0]),
    .o_tdata(ce_i_tdata[0]), .o_tlast(ce_i_tlast[0]), .o_tvalid(ce_i_tvalid[0]), .o_tready(ce_i_tready[0]),
    .debug(ce_debug[0]));
  
  noc_block_fir_filter #(
    .NOC_ID(64'hF112_0000_0000_0000),
    .STR_SINK_FIFOSIZE(11))
  inst_noc_block_fir_filter (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .ce_clk(bus_clk), .ce_rst(bus_rst),
    .i_tdata(ce_o_tdata[1]), .i_tlast(ce_o_tlast[1]), .i_tvalid(ce_o_tvalid[1]), .i_tready(ce_o_tready[1]),
    .o_tdata(ce_i_tdata[1]), .o_tlast(ce_i_tlast[1]), .o_tvalid(ce_i_tvalid[1]), .o_tready(ce_i_tready[1]),
    .debug(ce_debug[1]));

  noc_block_fft #(
    .NOC_ID(64'hFF70_0000_0000_0000),
    .STR_SINK_FIFOSIZE(11))
  inst_noc_block_fft (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .ce_clk(bus_clk), .ce_rst(bus_rst),
    .i_tdata(ce_o_tdata[2]), .i_tlast(ce_o_tlast[2]), .i_tvalid(ce_o_tvalid[2]), .i_tready(ce_o_tready[2]),
    .o_tdata(ce_i_tdata[2]), .o_tlast(ce_i_tlast[2]), .o_tvalid(ce_i_tvalid[2]), .o_tready(ce_i_tready[2]),
    .debug(ce_debug[2]));
    
  noc_block_null_source_sink #(
    .NOC_ID(64'h0000_0000_0000_0000),
    .STR_SINK_FIFOSIZE(11))
  inst_noc_block_null_source_sink (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .ce_clk(bus_clk), .ce_rst(bus_rst),
    .i_tdata(ce_o_tdata[3]), .i_tlast(ce_o_tlast[3]), .i_tvalid(ce_o_tvalid[3]), .i_tready(ce_o_tready[3]),
    .o_tdata(ce_i_tdata[3]), .o_tlast(ce_i_tlast[3]), .o_tvalid(ce_i_tvalid[3]), .o_tready(ce_i_tready[3]),
    .debug(ce_debug[3]));
  
  genvar n;
  generate
    for (n = 4; n < NUM_CE; n = n + 1) begin
      noc_block_axi_fifo_loopback #(
        .NOC_ID(64'hF1F0_0000_0000_0000 + n),
        .STR_SINK_FIFOSIZE(11))
      inst_noc_block_axi_fifo_loopback (
        .bus_clk(bus_clk), .bus_rst(bus_rst),
        .ce_clk(bus_clk), .ce_rst(bus_rst),
        .i_tdata(ce_o_tdata[n]), .i_tlast(ce_o_tlast[n]), .i_tvalid(ce_o_tvalid[n]), .i_tready(ce_o_tready[n]),
        .o_tdata(ce_i_tdata[n]), .o_tlast(ce_i_tlast[n]), .o_tvalid(ce_i_tvalid[n]), .o_tready(ce_i_tready[n]),
        .debug(ce_debug[n]));
    end
  endgenerate