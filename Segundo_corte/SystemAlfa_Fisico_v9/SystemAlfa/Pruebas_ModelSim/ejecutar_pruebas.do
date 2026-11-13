# Ejecutar desde ModelSim: do ejecutar_pruebas.do
# No se ejecutó ModelSim en la validación entregada; sí GHDL y Quartus.
onerror {quit -code 1 -force}
onbreak {quit -code 1 -force}
set raiz [file normalize [file join [file dirname [info script]] ../..]]
set carpeta [file join $raiz simulacion_modelsim]
file mkdir $carpeta
cd $carpeta
set quartus "C:/altera/13.1/quartus"
if {[info exists env(QUARTUS_ROOTDIR)]} {set quartus $env(QUARTUS_ROOTDIR)}
if {![file exists work]} {vlib work}
if {![file exists lpm]} {vlib lpm}
vmap work work
vmap lpm lpm
vcom -93 -work lpm [file join $quartus eda sim_lib 220pack.vhd]
vcom -93 -work lpm [file join $quartus eda sim_lib 220model.vhd]
vcom -93 -work work [file join $raiz {SystemAlfa/Adaptacion_GPIO/SystemAlfa_Sensores.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/ajuste_fisico.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/base_tiempo_fisica.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/control_clasificacion_fisica.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/control_lectura_sensores.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/control_motor_l298n.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/entrada_presencia_v183.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/lector_hcsr04.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/lector_tcs3200.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/medicion_coordinada.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/pwm_servo.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/RF1_Transporte_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/RF2_Inspeccion_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/RF3_Clasificacion_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/RF4_Historial_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/RF5_Conteo_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/SystemAlfa_Limites_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/maquina_estados_control_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/memoria_ram_historial_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/rom_categorias_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF1_Transporte/RF1_Placa.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF1_Transporte/RF1_Transporte.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF2_Inspeccion/RF2_Inspeccion.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF2_Inspeccion/RF2_Placa.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF3_Clasificacion/RF3_Clasificacion.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF3_Clasificacion/RF3_Placa.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF4_Historial/RF4_Historial.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF4_Historial/RF4_Placa.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF5_Conteo/RF5_Conteo.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/RF5_Conteo/RF5_Placa.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/SystemAlfa_Final/SystemAlfa_Placa.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/captura_pieza.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/clasificador_ruta.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/contador_ascendente.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/contador_segundos.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/conteo_categorias.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/control_linea.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/conversor_binario_decimal.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/conversor_decimal_reloj.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/decodificador_7segmentos.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/divisor_frecuencia.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/filtro_boton.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/historial.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/historial_sesion.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/maquina_estados_control.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/memoria_ram_historial.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/paquete_funciones.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/registro_color.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/registro_tamano.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/reinicio_seguro.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/rom_categorias.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/selector_velocidad.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/sincronizador.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/supervisor_error.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/tabla_reglas.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/visor_ajuste.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/entrada_presencia_v183_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/lector_hcsr04_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/lector_hcsr04_montaje_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/lector_tcs3200_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/pwm_fisico_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/SystemAlfa_Final/SystemAlfa_Final.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/comunes/codificador_direccion.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/SystemAlfa_Final_TB.vhd}]
vcom -93 -work work [file join $raiz {SystemAlfa/Pruebas_ModelSim/SystemAlfa_Hardware_TB.vhd}]
vsim -t 1ps -L lpm work.RF1_Transporte_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.RF2_Inspeccion_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.RF3_Clasificacion_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.RF4_Historial_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.RF5_Conteo_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.SystemAlfa_Limites_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.maquina_estados_control_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.memoria_ram_historial_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.rom_categorias_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.entrada_presencia_v183_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.lector_hcsr04_TB
run 3 sec
quit -sim
vsim -t 1ps -L lpm work.lector_hcsr04_montaje_TB
run 3 sec
quit -sim
vsim -t 1ps -L lpm work.lector_tcs3200_TB
run 3 sec
quit -sim
vsim -t 1ps -L lpm work.pwm_fisico_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.SystemAlfa_Final_TB
run 500 ms
quit -sim
vsim -t 1ps -L lpm work.SystemAlfa_Hardware_TB
run 21 sec
quit -sim
puts "Finalizaron los testbench; comprobar los 16 mensajes OK en Transcript."
