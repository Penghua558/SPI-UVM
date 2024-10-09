onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/u_apb_if/PADDR
add wave -noupdate /top/u_apb_if/PCLK
add wave -noupdate /top/u_apb_if/PENABLE
add wave -noupdate /top/u_apb_if/PRDATA
add wave -noupdate /top/u_apb_if/PREADY
add wave -noupdate /top/u_apb_if/PRESETn
add wave -noupdate /top/u_apb_if/PSEL
add wave -noupdate /top/u_apb_if/PWDATA
add wave -noupdate /top/u_apb_if/PWRITE
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {62400 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {220500 ps}
