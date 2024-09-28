interface pmd901_bus_if(input i_clk, input i_rstn);
    logic [15:0] wdata;
    logic we;
    logic dev_enable;
    logic dev_bending;
endinterface: pmd901_bus_if
