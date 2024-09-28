class pmd901_bus_agent_config extends uvm_object;

localparam string s_my_config_id = "pmd901_bus_agent_config";

`uvm_object_utils(pmd901_bus_agent_config)

virtual pmd901_bus_monitor_bfm mon_bfm;
virtual pmd901_bus_driver_bfm drv_bfm;
//------------------------------------------
// Data Members
//------------------------------------------
uvm_active_passive_enum active = UVM_ACTIVE;
bit has_functional_coverage = 1'b0;

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "pmd901_bus_agent_config");
extern static function pmd901_bus_agent_config get_config( uvm_component c);
extern task wait_for_reset();
endclass: pmd901_bus_agent_config

task pmd901_bus_agent_config::wait_for_reset();
    mon_bfm.wait_for_reset();
endtask

function pmd901_bus_agent_config::new(string name = "pmd901_bus_agent_config");
  super.new(name);
endfunction

function pmd901_bus_agent_config pmd901_bus_agent_config::get_config(
    uvm_component c);
    pmd901_bus_agent_config t;
    if (!uvm_config_db#(pmd901_bus_agent_config)::get(c, "", s_my_config_id, t))
        `uvm_fatal(s_my_config_id, $sformatf("Failed to get config %s", 
                    s_my_config_id))
    return t;
endfunction
