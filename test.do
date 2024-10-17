onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PADDR
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PCLK
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PENABLE
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PRDATA
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PREADY
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PRESETn
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PSEL
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PWDATA
add wave -noupdate -expand -group {APB interface} /top/u_apb_if/PWRITE
add wave -noupdate -expand -group reg /top/DUT/pmd901_reg/i_addr
add wave -noupdate -expand -group reg /top/DUT/pmd901_reg/i_wr
add wave -noupdate -expand -group reg /top/DUT/pmd901_reg/ready
add wave -noupdate -expand -group reg /top/DUT/pmd901_reg/fault
add wave -noupdate -expand -group reg /top/DUT/pmd901_reg/ready
add wave -noupdate -expand -group reg /top/DUT/pmd901_reg/i_ready
add wave -noupdate -expand -group reg /top/DUT/pmd901_reg/o_rdata
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/bend
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/clk
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/csn
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/park
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/mosi
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/fan
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/fault
add wave -noupdate -expand -group {PMD901 interface} /top/u_pmd901_if/ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {449650100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 291
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1050682500 ps}
