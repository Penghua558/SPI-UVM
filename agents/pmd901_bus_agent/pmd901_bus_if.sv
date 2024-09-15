interface pmd901_bus_if(input clk, input rstn);
    logic [15:0] wdata;
    logic we;
    logic dev_enbale;
    logic dev_bending;
endinterface: pmd901_bus_if
