# Archivos nuevos y modificados respecto a octava_version.rar

Usar la carpeta completa evita mezclar interfaces antiguas. No se modificó el archivo RAR original.

Los archivos nuevos se agregan al QSF que corresponda; los modificados reemplazan el archivo de la misma ruta. El QSF físico entregado ya contiene todas sus dependencias. Los tres proyectos individuales usan sus propios QSF.

| Estado | Ruta desde la carpeta del paquete |
|---|---|
| MODIFICADO | `SystemAlfa/Adaptacion_GPIO/SystemAlfa_Sensores.qsf` |
| MODIFICADO | `SystemAlfa/Adaptacion_GPIO/SystemAlfa_Sensores.vhd` |
| NUEVO | `SystemAlfa/comunes/conversor_decimal_reloj.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/ajuste_fisico.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/base_tiempo_fisica.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/control_clasificacion_fisica.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/control_motor_l298n.vhd` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/entrada_presencia_v183.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/hardware.sdc` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/lector_hcsr04.vhd` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/lector_tcs3200.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/medicion_coordinada.vhd` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.qsf` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.vhd` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.qsf` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.vhd` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.qpf` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.qsf` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183_Activo_Alto.qsf` |
| NUEVO | `SystemAlfa/Hardware_Sensores/pwm_servo.vhd` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.qpf` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.qsf` |
| MODIFICADO | `SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.vhd` |
| NUEVO | `SystemAlfa/Hardware_Sensores/visor_ajuste.vhd` |
| NUEVO | `SystemAlfa/Pruebas_ModelSim/entrada_presencia_v183_TB.vhd` |
| NUEVO | `SystemAlfa/Pruebas_ModelSim/lector_hcsr04_montaje_TB.vhd` |
| NUEVO | `SystemAlfa/Pruebas_ModelSim/lector_hcsr04_TB.vhd` |
| NUEVO | `SystemAlfa/Pruebas_ModelSim/lector_tcs3200_TB.vhd` |
| NUEVO | `SystemAlfa/Pruebas_ModelSim/pwm_fisico_TB.vhd` |
| MODIFICADO | `SystemAlfa/Pruebas_ModelSim/SystemAlfa_Final_TB.vhd` |
| NUEVO | `SystemAlfa/Pruebas_ModelSim/SystemAlfa_Hardware_TB.vhd` |
| MODIFICADO | `SystemAlfa/Pruebas_ModelSim/SystemAlfa_Limites_TB.vhd` |
| MODIFICADO | `SystemAlfa/SystemAlfa_Final/SystemAlfa_Final.qsf` |
| MODIFICADO | `SystemAlfa/SystemAlfa_Final/SystemAlfa_Final.vhd` |
| MODIFICADO | `SystemAlfa/SystemAlfa_Final/SystemAlfa_Placa.vhd` |

## Cambios mínimos en el núcleo

Se mantienen ROM, RAM, contador de sesión, conteos y las condiciones que excluyen rechazos del historial. SystemAlfa_Final exporta cuatro señales para la adaptación física y usa dos conversiones decimales registradas, porque la conversión combinacional anterior incumplía 50 MHz en esta integración. Se actualizaron los port maps en sus instancias. Los testbench esperan la latencia de conversión y conservan los valores esperados.

El rearme físico, la captura coordinada y los actuadores se implementan en módulos de Hardware_Sensores. El antiguo control_lectura_sensores queda como referencia y no es instanciado por el TOP v9.

## Orden de compilación

Quartus toma el orden y las dependencias del QSF. ORDEN_COMPILACION.txt enumera todas las fuentes y testbench; para síntesis usar exclusivamente las fuentes listadas por SystemAlfa_Hardware.qsf. Primero paquete_funciones, después componentes, RF1..RF5, SystemAlfa_Final y el TOP físico. Los testbench se compilan solamente en el simulador.

## Pruebas

Pruebas_ModelSim/SystemAlfa_Hardware_TB.vhd prueba la integración completa con sensores simulados y calibración desde switches/botones. pwm_fisico_TB comprueba porcentajes y pulsos de servo. lector_hcsr04_montaje_TB verifica las ventanas físicas actuales. Los testbench originales se conservan y se ejecutaron también. Ver validacion/RESUMEN_VALIDACION.md.
