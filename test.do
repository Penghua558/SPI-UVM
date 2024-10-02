onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/bend
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/clk
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/csn
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/fan
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/fault
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/mosi
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/park
add wave -noupdate -expand -group {pmd901 if} /top/u_pmd901_if/ready
add wave -noupdate -expand -group {pmd901 bus if} /top/u_pmd901_bus_if/dev_bending
add wave -noupdate -expand -group {pmd901 bus if} /top/u_pmd901_bus_if/dev_enable
add wave -noupdate -expand -group {pmd901 bus if} /top/u_pmd901_bus_if/i_clk
add wave -noupdate -expand -group {pmd901 bus if} /top/u_pmd901_bus_if/i_rstn
add wave -noupdate -expand -group {pmd901 bus if} /top/u_pmd901_bus_if/wdata
add wave -noupdate -expand -group {pmd901 bus if} /top/u_pmd901_bus_if/we
add wave -noupdate -expand -group DUT /top/DUT/bending
add wave -noupdate -expand -group DUT /top/DUT/clk
add wave -noupdate -expand -group DUT /top/DUT/cs_n
add wave -noupdate -expand -group DUT /top/DUT/dev_bending
add wave -noupdate -expand -group DUT /top/DUT/dev_enable
add wave -noupdate -expand -group DUT /top/DUT/fan
add wave -noupdate -expand -group DUT /top/DUT/fault
add wave -noupdate -expand -group DUT /top/DUT/mosi
add wave -noupdate -expand -group DUT /top/DUT/motor_speed
add wave -noupdate -expand -group DUT /top/DUT/neg_edge
add wave -noupdate -expand -group DUT /top/DUT/park
add wave -noupdate -expand -group DUT /top/DUT/pos_edge
add wave -noupdate -expand -group DUT /top/DUT/ready
add wave -noupdate -expand -group DUT /top/DUT/rstn
add wave -noupdate -expand -group DUT /top/DUT/sclk
add wave -noupdate -expand -group DUT /top/DUT/sclk_gen_o
add wave -noupdate -expand -group DUT /top/DUT/spi_ready
add wave -noupdate -expand -group DUT /top/DUT/spi_ready_crossed
add wave -noupdate -expand -group DUT /top/DUT/spi_start
add wave -noupdate -expand -group DUT /top/DUT/spi_start_crossed
add wave -noupdate -expand -group DUT /top/DUT/wdata
add wave -noupdate -expand -group DUT /top/DUT/we
add wave -noupdate -expand -group {spi shift} /top/DUT/shift/s_clk
add wave -noupdate -expand -group {spi shift} /top/DUT/shift/clk
add wave -noupdate -expand -group {spi shift} /top/DUT/shift/spi_ready
add wave -noupdate /top/DUT/shift/spi_transmit_cnt
add wave -noupdate /top/DUT/shift/current_state
add wave -noupdate /top/DUT/shift/spi_start
add wave -noupdate /top/DUT/spi_start_crossing/data_in
add wave -noupdate /top/DUT/spi_start_crossing/data_out
add wave -noupdate -expand -group {spi initiator} /top/DUT/transmit_initiator/cnt4spi_start
add wave -noupdate /top/DUT/transmit_initiator/spi_ready
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/busy
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/data_in
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/data_out
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/last_req
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/new_clk
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/new_req
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/new_req_pipe
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/old_ack
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/old_ack_pipe
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/old_clk
add wave -noupdate -group {spi_ready cdc} /top/DUT/spi_ready_crossing/req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {48831000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 332
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {47779100 ps} {50692700 ps}
