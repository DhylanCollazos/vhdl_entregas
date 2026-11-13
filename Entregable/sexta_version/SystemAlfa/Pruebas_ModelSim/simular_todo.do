# Ejecutar desde Pruebas_ModelSim: do simular_todo.do
onerror {quit -code 1 -f}
onbreak {quit -code 1 -f}
if {![file exists work]} {vlib work}
vmap work work
vcom -93 ../comunes/paquete_funciones.vhd
vcom -93 ../comunes/captura_pieza.vhd
vcom -93 ../comunes/clasificador_ruta.vhd
vcom -93 ../comunes/codificador_direccion.vhd
vcom -93 ../comunes/contador_ascendente.vhd
vcom -93 ../comunes/contador_segundos.vhd
vcom -93 ../comunes/conteo_categorias.vhd
vcom -93 ../comunes/control_linea.vhd
vcom -93 ../comunes/conversor_binario_decimal.vhd
vcom -93 ../comunes/decodificador_7segmentos.vhd
vcom -93 ../comunes/divisor_frecuencia.vhd
vcom -93 ../comunes/filtro_boton.vhd
vcom -93 ../comunes/historial.vhd
vcom -93 ../comunes/historial_sesion.vhd
vcom -93 ../comunes/maquina_estados_control.vhd
vcom -93 ../comunes/memoria_ram_historial.vhd
vcom -93 ../comunes/registro_color.vhd
vcom -93 ../comunes/registro_tamano.vhd
vcom -93 ../comunes/reinicio_seguro.vhd
vcom -93 ../comunes/rom_categorias.vhd
vcom -93 ../comunes/selector_velocidad.vhd
vcom -93 ../comunes/sincronizador.vhd
vcom -93 ../comunes/supervisor_error.vhd
vcom -93 ../comunes/tabla_reglas.vhd
vcom -93 ../RF1_Transporte/RF1_Placa.vhd
vcom -93 ../RF1_Transporte/RF1_Transporte.vhd
vcom -93 ../RF2_Inspeccion/RF2_Inspeccion.vhd
vcom -93 ../RF2_Inspeccion/RF2_Placa.vhd
vcom -93 ../RF3_Clasificacion/RF3_Clasificacion.vhd
vcom -93 ../RF3_Clasificacion/RF3_Placa.vhd
vcom -93 ../RF4_Historial/RF4_Historial.vhd
vcom -93 ../RF4_Historial/RF4_Placa.vhd
vcom -93 ../RF5_Conteo/RF5_Conteo.vhd
vcom -93 ../RF5_Conteo/RF5_Placa.vhd
vcom -93 ../SystemAlfa_Final/SystemAlfa_Final.vhd
vcom -93 ../SystemAlfa_Final/SystemAlfa_Placa.vhd
vcom -93 ../Pruebas_ModelSim/maquina_estados_control_TB.vhd
vcom -93 ../Pruebas_ModelSim/memoria_ram_historial_TB.vhd
vcom -93 ../Pruebas_ModelSim/RF1_Transporte_TB.vhd
vcom -93 ../Pruebas_ModelSim/RF2_Inspeccion_TB.vhd
vcom -93 ../Pruebas_ModelSim/RF3_Clasificacion_TB.vhd
vcom -93 ../Pruebas_ModelSim/RF4_Historial_TB.vhd
vcom -93 ../Pruebas_ModelSim/RF5_Conteo_TB.vhd
vcom -93 ../Pruebas_ModelSim/rom_categorias_TB.vhd
vcom -93 ../Pruebas_ModelSim/SystemAlfa_Final_TB.vhd
vsim work.maquina_estados_control_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.memoria_ram_historial_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.RF1_Transporte_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.RF2_Inspeccion_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.RF3_Clasificacion_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.RF4_Historial_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.RF5_Conteo_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.rom_categorias_TB
set BreakOnAssertion 2
run -all
quit -sim
vsim work.SystemAlfa_Final_TB
set BreakOnAssertion 2
run -all
quit -sim
vcom -93 ../Adaptacion_GPIO/SystemAlfa_Sensores.vhd
vcom -93 SystemAlfa_Limites_TB.vhd
vsim work.SystemAlfa_Limites_TB
set BreakOnAssertion 2
run -all
quit -sim
echo "OK: todos los testbench terminaron"