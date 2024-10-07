// randomly configures register motor_speed and bending
class rand_control_sequence extends apb_bus_sequence_base;

  `uvm_object_utils(rand_control_sequence)

  function new(string name = "rand_control_sequence");
    super.new(name);
  endfunction

  task body;
    super.body;

    assert(spi_rb.motor_speed.randomize());
    assert(spi_rb.bending.randomize());
    spi_rb.update(status, .path(UVM_FRONTDOOR), .parent(this));
  endtask: body

endclass: rand_control_sequence
