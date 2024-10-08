class pmd901_agent_config extends uvm_object;

localparam string s_my_config_id = "pmd901_agent_config";

`uvm_object_utils(pmd901_agent_config)

virtual pmd901_monitor_bfm mon_bfm;
virtual pmd901_driver_bfm drv_bfm;
//------------------------------------------
// Data Members
//------------------------------------------
uvm_active_passive_enum active = UVM_ACTIVE;
bit has_functional_coverage = 1'b0;

// 0 - allow pmd901 transaction to have a chance to generate exceptions
// 1 - no exceptions allowed for pmd901 transaction
rand bit disable_spi_violation;
rand bit disable_overheat;
rand bit disable_close2overheat;

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "pmd901_agent_config");
extern static function pmd901_agent_config get_config( uvm_component c);
extern task wait_inputs_isknown();
endclass: pmd901_agent_config

task pmd901_agent_config::wait_inputs_isknown();
    mon_bfm.wait_inputs_isknown();
endtask

function pmd901_agent_config::new(string name = "pmd901_agent_config");
  super.new(name);
  disable_spi_violation = 1'b0;
  disable_overheat = 1'b0;
  disable_close2overheat = 1'b0;
endfunction

function pmd901_agent_config pmd901_agent_config::get_config(uvm_component c);
    pmd901_agent_config t;
    if (!uvm_config_db#(pmd901_agent_config)::get(c, "", s_my_config_id, t))
        `uvm_fatal(s_my_config_id, $sformatf("Failed to get config %s", 
            s_my_config_id))
    return t;
endfunction
