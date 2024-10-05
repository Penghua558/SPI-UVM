############
## agents ##
############
-F ./agents/pmd901_agent/pmd901_agent_filelist.f
-F ./agents/apb_agent/apb_agent_filelist.f

#################
## environment ##
#################
./tb/register_model/spi_reg_pkg.sv
./tb/env_pkg.sv
./tb/top.sv
