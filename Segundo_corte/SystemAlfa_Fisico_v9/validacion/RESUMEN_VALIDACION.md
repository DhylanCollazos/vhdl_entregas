# Validación ejecutada - System Alfa físico v9

Fecha: 10 de noviembre de 2026. Esta validación es digital; no se programó ni se probó el montaje físico desde este entorno.

## Compilación física principal

- Quartus II 64-Bit 13.1.0 Build 162 Web Edition: compilación completa, **0 errores y 14 advertencias**, sin advertencias críticas.
- Dispositivo EP3C16F484C6; entidad SystemAlfa_Hardware; reloj de 50 MHz (20 ns).
- TimeQuest: setup mínimo **+4.707 ns**, hold mínimo **+0.187 ns**. Todos los márgenes de setup/hold/recovery/removal/pulse width reportados son positivos.
- Requisitos de setup y hold completamente restringidos. Entradas externas asíncronas declaradas como tales y sincronizadas en los lectores; la parada cruda de SW3/BUTTON1 tiene además un corte directo de habilitación.
- 4005 / 15408 elementos lógicos (26 %); 1889 registros; 83 pines asignados, sin duplicados.
- La RAM de historial se conserva en VHDL como memoria 8 x 21 de lectura/escritura. En este tamaño Quartus la implementó en registros: el informe indica 0 bits de bloques de memoria. No se afirma utilización de M9K.
- Programacion/SystemAlfa_Hardware.sof corresponde a esta compilación. Los hashes del paquete permiten identificar sus fuentes.

Las advertencias son licencias de paralelismo/LogicLock, señales internas de diagnóstico no consumidas, salidas constantes intencionales (escala TCS, sentido de motor y segmento común a 0..3) y recordatorio eléctrico de interfaces Cyclone III a 3.3 V. No son pruebas de compatibilidad de cualquier conexión de 5 V; seguir el divisor y los drivers de la guía.

## Simulación

GHDL 6.0, VHDL-93, biblioteca LPM de Quartus 13.1. Se analizaron 69 archivos VHDL. Pasaron los 16 testbench listados abajo, con sus marcadores OK y sin aserciones fallidas.

La simulación integrada aplica pulsos eléctricos de ECHO/TCS y maneja los mismos botones/switches del TOP. Configura posiciones y cuatro niveles mediante el menú; comprueba seis categorías, total 0021, exclusión de rechazos de ID/RAM/total, rearme real, conservación del total, PWM de ambos servos por categoría, consulta sin accionamiento, cambio de velocidad diferido, segunda pieza, zona dudosa, timeout de eco, retiro prematuro y anulación de tiempos tras cambiar PWM.

Los testbench del núcleo verifican además conteos por categoría/color, RAM circular, tiempo conservado tras reset y límite de sesión. El banco de PWM mide anchos y ciclos de trabajo. El nuevo banco HC usa las ventanas del montaje 20..28 y 32..48 mm.

Se aceleraron reloj, filtros y temporizadores en simulación. No se simuló la mecánica, el par, el consumo, la luz real, la inercia o la calibración óptica. El test de color usa capturas sintéticas representativas; no resuelve la detección física del verde.

GHDL emite avisos de metavalores en el instante inicial y un puerto de salida opcional eq del modelo LPM no conectado. Los bancos terminan correctamente. ModelSim no fue ejecutado; se entrega un script de compilación y ejecución para usarlo localmente.

- RF1_Transporte_TB
- RF2_Inspeccion_TB
- RF3_Clasificacion_TB
- RF4_Historial_TB
- RF5_Conteo_TB
- SystemAlfa_Limites_TB
- maquina_estados_control_TB
- memoria_ram_historial_TB
- rom_categorias_TB
- entrada_presencia_v183_TB
- lector_hcsr04_TB
- lector_hcsr04_montaje_TB
- lector_tcs3200_TB
- pwm_fisico_TB
- SystemAlfa_Final_TB
- SystemAlfa_Hardware_TB

## Informes

Los archivos .log, .rpt, .summary y .pin de esta carpeta registran los resultados originales. `cambios_desde_octava.diff` identifica las modificaciones y `base_octava_sha256.json` conserva los hashes de referencia.

## Proyectos individuales

También se compiló con Quartus cada prueba de V183 (activo bajo), HC-SR04 y TCS3200. Sus SOF están en Programacion/Pruebas_Individuales. Sus resúmenes y advertencias están en los informes separados; estas pruebas no incluyen actuadores ni la sesión integrada.
