import pmd901_agent_dec::*;

class pmd901_trans extends uvm_sequence_item;
`uvm_object_utils(pmd901_trans)

pmd901_agent_dec::work_status_e work_status;
bit spi_violated;
bit spi_ready;
signed bit[15:0] speed;

rand bit overheat;
rand bit close2overheat;

// Standard UVM Methods:
extern function new(string name = "pmd901_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function string convert2string();
extern function void do_print(uvm_printer printer);
// extern function void do_record(uvm_recorder recorder);
endclass: pmd901_trans

function pmd901_trans::new(string name = "pmd901_trans");
    super.new(name);
    work_status = pmd901_agent_dec::POWER_DOWN;
    spi_violated = 1'b0;
    spi_ready = 1'b1;
endfunction

function void pmd901_trans::do_copy(uvm_object rhs);
  spi_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  work_status = rhs_.work_status;
  spi_violated = rhs_.spi_violated;
  spi_ready = rhs_.spi_ready;
  overheat = rhs_.overheat;
  close2overheat = rhs_.close2overheat;
  speed = rhs_.speed;
endfunction:do_copy

function string convert2string();
    string s;
    s = super.convert2string();

    $sformat(s, "%s work status: %0s\n", s, work_status.name());
    $sformat(s, "%s SPI violated: %b\n", s, spi_violated);
    $sformat(s, "%s SPI ready: %b\n", s, spi_ready);
    $sformat(s, "%s speed: %0d\n", s, speed);
    $sformat(s, "%s overheat: %b\n", s, overheat);
    $sformat(s, "%s close to overheat: %b\n", s, close2overheat);

    return s;
endfunction

function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.m_string = convert2string();
endfunction

function bit pmd901_trans::do_compare(uvm_object rhs, uvm_comparer comparer);
  spi_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         work_status == rhs_.work_status &&
         speed == rhs_.speed &&
         spi_violated == rhs_.spi_violated &&
         spi_ready == rhs_.spi_ready;
endfunction:do_compare
