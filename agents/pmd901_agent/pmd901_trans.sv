import pmd901_agent_dec::*;

class pmd901_trans extends uvm_sequence_item;
`uvm_object_utils(pmd901_trans)

pmd901_agent_dec::work_status_e work_status;
bit signed[15:0] speed;

rand bit spi_violated;
rand bit overheat;
rand bit close2overheat;

// Standard UVM Methods:
extern function new(string name = "pmd901_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
// extern function void do_record(uvm_recorder recorder);

extern constraint overheat_cons;
extern constraint close2overheat_cons;
extern constraint spi_violated_cons;
endclass: pmd901_trans

function pmd901_trans::new(string name = "pmd901_trans");
    super.new(name);
    work_status = pmd901_agent_dec::POWER_DOWN;
    speed = 16'd0;
endfunction

constraint pmd901_trans::overheat_cons{
    if (work_status != POWER_DOWN) {
        overheat dist {
            1'b0:/ 97,
            1'b1:/ 3
        };
    } else {
        overheat == 1'b0;
    }
}

constraint pmd901_trans::close2overheat_cons{
    if (work_status != POWER_DOWN) {
        close2overheat dist {
            1'b0:/ 97,
            1'b1:/ 3
        };
    } else {
        close2overheat == 1'b0;
    }
}

constraint pmd901_trans::spi_violated_cons{
    if (work_status != POWER_DOWN) {
        spi_violated dist {
            1'b0:/ 97,
            1'b1:/ 3
        };
    } else {
        spi_violated == 1'b0;
    }
}

function void pmd901_trans::do_copy(uvm_object rhs);
  pmd901_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  work_status = rhs_.work_status;
  spi_violated = rhs_.spi_violated;
  overheat = rhs_.overheat;
  close2overheat = rhs_.close2overheat;
  speed = rhs_.speed;
endfunction:do_copy


function void pmd901_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_string("Work status", work_status.name());
    printer.print_field_int("speed", speed, $bits(speed), UVM_DEC);
    printer.print_string("SPI violated?", spi_violated? "Yes":"No");
    printer.print_string("Overheat?", overheat? "Yes":"No");
    printer.print_string("Close to overheat?", close2overheat? "Yes":"No");
endfunction

function bit pmd901_trans::do_compare(uvm_object rhs, uvm_comparer comparer);
  pmd901_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         work_status == rhs_.work_status &&
         speed == rhs_.speed;
endfunction:do_compare
