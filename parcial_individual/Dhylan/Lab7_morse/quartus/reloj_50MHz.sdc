# Reloj de entrada de 50 MHz.
# Periodo: 20 ns.
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_clock_uncertainty
# Si cambia la frecuencia de la tarjeta, deben ajustarse:
# 1. El periodo indicado en este archivo.
# 2. El parametro G_TICKS_05S del circuito.
#
# Esta restriccion del reloj no sustituye la revision completa
# de temporizacion y conexiones de la tarjeta.
