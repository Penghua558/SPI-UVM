// randomly configures register motor_speed
class rand_speed_sequence extends apb_bus_sequence_base;

  `uvm_object_utils(rand_speed_sequence)

  function new(string name = "rand_speed_sequence");
    super.new(name);
  endfunction

  task body;
    super.body;

    assert(spi_rb.motor_speed.randomize());
    spi_rb.motor_speed.update(status, .path(UVM_FRONTDOOR), .parent(this));
    // Get the desired motor speed
    data = spi_rb.motor_speed.get();
  endtask: body

endclass: rand_speed_sequence
