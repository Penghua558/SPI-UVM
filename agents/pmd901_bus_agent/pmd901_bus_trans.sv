class pmd901_bus_trans extends uvm_sequence_item;
`uvm_object_utils(pmd901_bus_trans)

rand bit signed [15:0] speed;
rand bit we;
rand bit enable;
rand bit bending;

// Standard UVM Methods:
extern function new(string name = "pmd901_bus_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
// extern function void do_record(uvm_recorder recorder);

extern constraint speed_cons;
endclass: pmd901_bus_trans

function pmd901_bus_trans::new(string name = "pmd901_bus_trans");
    super.new(name);
    speed = 16'd0;
    we = 1'b0;
    enable = 1'b0;
    bending = 1'b0;
endfunction

constraint pmd901_bus_trans::speed_cons{
    speed dist {
        16'd0:/ 2,
        [16'h0: 16'hffff]:/ 8
    };
}

function void pmd901_bus_trans::do_copy(uvm_object rhs);
  pmd901_bus_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  speed = rhs_.speed;
  we = rhs_.we;
  enable = rhs_.enable;
  bending = rhs_.bending;
endfunction:do_copy

function void pmd901_bus_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("speed", speed, $bits(speed), UVM_DEC);
    printer.print_field_int("write enable", we, $bits(we), UVM_BIN);
    printer.print_field_int("PMD901 enable", enable, $bits(enable), UVM_BIN);
    printer.print_field_int("PMD901 bending", bending, $bits(bending), UVM_BIN);
endfunction

function bit pmd901_bus_trans::do_compare(uvm_object rhs, uvm_comparer comparer);
  pmd901_bus_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         speed == rhs_.speed &&
         we == rhs_.we &&
         enable == rhs_.enable &&
         bending == rhs_.bending;
endfunction:do_compare
