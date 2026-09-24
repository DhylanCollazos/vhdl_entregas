\# System Alfa - Clasificador Inteligente de Piezas



Proyecto desarrollado en VHDL para FPGA Cyclone III EP3C16F484C6 utilizando Quartus II.



\## Descripción



El sistema simula una cinta transportadora inteligente capaz de:



\- controlar marcha y velocidad,

\- detectar piezas,

\- clasificar color y tamaño,

\- direccionar piezas según reglas,

\- manejar rechazo y alarmas,

\- registrar historial,

\- contar piezas válidas,

\- mostrar información en displays y LEDs.



\## Estructura



\- `comunes/`: módulos reutilizables.

\- `RF1\_Transporte/`: transporte y velocidad.

\- `RF2\_Inspeccion/`: detección de presencia, color y tamaño.

\- `RF3\_Clasificacion/`: clasificación y rutas.

\- `RF4\_Historial/`: memoria e historial.

\- `RF5\_Conteo/`: conteo y monitoreo.

\- `SystemAlfa\_Final/`: integración completa del sistema.



\## FPGA



\- Placa: DE0

\- FPGA: Cyclone III

\- Dispositivo: EP3C16F484C6

\- Reloj: 50 MHz



\## Proyecto principal



Abrir en Quartus:



`SystemAlfa\_Final/SystemAlfa\_Final.qpf`



Top-Level Entity:



`SystemAlfa\_Placa`



\## Controles principales



\- `BUTTON0`: presencia de pieza

\- `BUTTON1`: reinicio

\- `BUTTON2`: cambio de velocidad

\- `SW0-SW1`: color

\- `SW2`: tamaño

\- `SW3`: marcha/parada

\- `SW4`: modo historial

\- `SW5`: siguiente registro



\## Licencia



Proyecto académico.

