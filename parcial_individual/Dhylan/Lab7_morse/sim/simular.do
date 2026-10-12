# Ejecutar desde la consola de ModelSim o Questa.
# Ejemplo:
# do C:/VHDL/Lab7_Morse/sim/simular.do

# Ubicar el directorio donde esta guardado este script.
set carpeta_script [file dirname [file normalize [info script]]]
cd $carpeta_script

# Cerrar una simulacion anterior, si existe.
catch {quit -sim}

# Detener el script si ocurre un error.
onerror {abort all}

# Crear la carpeta para las evidencias.
file mkdir ../evidencias

# Guardar los mensajes de la simulacion.
transcript file ../evidencias/simulacion_modelsim.log
transcript on

# Crear y mapear la biblioteca de trabajo.
if {![file isdirectory work]} {
    vlib work
}
vmap work work

# Compilar primero el circuito y despues el testbench.
vcom -93 ../rtl/morse_fsm.vhd
vcom -93 tb_morse_fsm.vhd

# Cargar el testbench conservando las senales internas.
vsim -voptargs=+acc work.tb_morse_fsm

# Detenerse ante errores de las comprobaciones.
set BreakOnAssertion 2

# Registrar las senales.
log -r /*
view wave

# Entradas y salida.
add wave -divider Entradas_y_salida
add wave sim:/tb_morse_fsm/CLOCK_50
add wave sim:/tb_morse_fsm/SW
add wave sim:/tb_morse_fsm/KEY
add wave sim:/tb_morse_fsm/LEDR

# Estado y registros internos.
add wave -divider FSM_y_registros
add wave sim:/tb_morse_fsm/dut/estado_actual
add wave sim:/tb_morse_fsm/dut/estado_siguiente
add wave sim:/tb_morse_fsm/dut/registro
add wave -radix unsigned sim:/tb_morse_fsm/dut/pendientes
add wave -radix unsigned sim:/tb_morse_fsm/dut/contador
add wave sim:/tb_morse_fsm/dut/key1_sync

# Ejecutar todas las pruebas.
run -all

# Mostrar toda la simulacion.
wave zoom full