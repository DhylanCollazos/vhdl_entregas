onerror {quit -f -code 1}
onbreak {quit -f -code 1}
# Ejecutar desde esta carpeta: do simular_sensores.do
if {![file isdirectory work]} {vlib work}
vmap work work
vcom -93 ../Hardware_Sensores/entrada_presencia_v183.vhd
vcom -93 ../Hardware_Sensores/lector_hcsr04.vhd
vcom -93 ../Hardware_Sensores/lector_tcs3200.vhd
vcom -93 entrada_presencia_v183_TB.vhd
vcom -93 lector_hcsr04_TB.vhd
vcom -93 lector_tcs3200_TB.vhd
foreach bajo {true false} {
    foreach filtro {1 5} {
        vsim work.entrada_presencia_v183_TB -gBAJO=$bajo -gFILTRO=$filtro
        run -all
        quit -sim
    }
}
vsim work.lector_hcsr04_TB
run -all
quit -sim
vsim work.lector_tcs3200_TB
run -all
quit -sim
echo "Pruebas terminadas: revisar los mensajes OK y cualquier asercion."
