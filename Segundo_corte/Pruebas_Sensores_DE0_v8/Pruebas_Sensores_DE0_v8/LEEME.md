# Pruebas individuales de sensores — System Alfa / DE0

Base inspeccionada: `octava_version.rar`. Entrega: 8 de noviembre de 2026.

Esta carpeta es independiente. Conserva tu octava versión y abre estos proyectos en una carpeta nueva. El V183 y el HC-SR04 ya se probaron en placa. El TCS3200 todavía no caracteriza bien el verde; la calibración sigue pendiente. No copies sus parámetros al TOP integrado.

## Comenzar

1. Extrae el ZIP completo, manteniendo las carpetas. No copies únicamente un QPF.
2. Lee `Guia_conexion_y_pruebas.pdf`, especialmente la medición previa del V183.
3. Abre `Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.qpf` en Quartus II 13.1.
4. Mide alimentación admitida, OUT sin pieza y OUT con pieza antes de conectar OUT a la DE0. Todavía no se conoce la polaridad de tu unidad.
5. Si con pieza OUT baja, usa la revisión `Prueba_V183`; si sube, selecciona `Prueba_V183_Activo_Alto` en Project > Revisions. Ambas tienen TOP `Prueba_V183`.
6. Ejecuta Processing > Start Compilation. En Tools > Programmer elige USB-Blaster, modo JTAG y el `.sof` de la revisión seleccionada; marca Program/Configure y pulsa Start. Una programación `.sof` es temporal y se pierde al apagar.
7. Valida la tabla del V183 antes de conectar/probar el HC-SR04. El TCS3200 se prueba después del HC-SR04.

También se incluyen cuatro `.sof` generados realmente por Quartus 13.1 en `Programacion/`: `V183_bajo.sof`, `V183_alto.sof`, `HCSR04.sof`, `TCS3200.sof`. Elige solo el que corresponde al cableado y prueba actuales. No existe un `.sof` de integración corregida en esta entrega.

**Actualización de calibración TCS3200:** se modificaron `Hardware_Sensores/lector_tcs3200.vhd`, `Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.vhd` y el testbench. El `.sof` TCS3200 anterior no contiene esta calibración; no lo uses después de sustituir los archivos. Abre y compila otra vez `Prueba_TCS3200.qpf` para generar un `.sof` actualizado. Esta última revisión de calibración no se ha compilado en Quartus ni probado en la DE0.

## Contenido

- `Auditoria_octava.md`: qué hace realmente la octava versión y qué falta en su integración.
- `Guia_conexion_y_pruebas.pdf`: planos, pasos y tablas de pruebas individuales.
- `Guia_integracion_cinta_y_actuadores.md`: mapa de sensores, motor, puente H, servos, LEDs, diagrama cableado y trabajo pendiente para el futuro TOP físico.
- `Guia_pruebas.md`: instrucciones completas en texto, incluidos todos los switches del núcleo.
- `Calibracion_TCS3200.md`: muestras, referencias y recordatorio de que el verde aún no está resuelto.
- `CODIGO_TCS3200_CALIBRADO.md`: lector, TOP individual y testbench completos de esta modificación.
- `CODIGOS_MODIFICADOS.md`: únicamente los seis VHDL modificados, completos por ruta.
- `TODOS_LOS_CODIGOS.md` y `.txt`: todos los VHDL de esta carpeta, QSF, QPF, SDC y testbench, completos.
- `validacion/`: informes reales de Quartus, simulaciones GHDL y manifiesto de la base.
- `Pruebas_ModelSim/`: tres testbench y script `.do` preparado; ModelSim no se ejecutó para esta entrega.

## Archivos y orden de compilación

Todos los caminos de esta tabla son relativos a esta carpeta nueva. **MODIFICADO** significa derivado del archivo del mismo nombre de la octava versión; no se modificó el RAR original.

| Carpeta / archivo | Estado | Función |
|---|---|---|
| `comunes/reinicio_seguro.vhd` | Copia sin cambios | Reset de las pruebas |
| `comunes/filtro_boton.vhd` | Copia sin cambios | Un pulso por pulsación estable |
| `comunes/conversor_binario_decimal.vhd` | Copia sin cambios | Centenas, decenas y unidades |
| `comunes/decodificador_7segmentos.vhd` | Copia sin cambios | Dígitos activos en bajo |
| `comunes/reloj.sdc` | Copia sin cambios | Reloj de 20 ns |
| `Hardware_Sensores/entrada_presencia_v183.vhd` | MODIFICADO | Inicialización y evento único |
| `Hardware_Sensores/lector_hcsr04.vhd` | MODIFICADO | Medición, límites y separación de disparos |
| `Hardware_Sensores/lector_tcs3200.vhd` | MODIFICADO | Conteo RGB y calibración preliminar con referencia negra/blanca |
| `Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.vhd` | MODIFICADO | Polaridad configurable, nivel y contador de eventos |
| `Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.vhd` | MODIFICADO | Tamaño en blanco si la lectura no es válida |
| `Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.vhd` | MODIFICADO | Calibración y selector sincronizado |
| QSF de las tres pruebas | MODIFICADOS | Pines explícitos, VHDL-93 y GPIO restantes en alta impedancia |
| `Prueba_V183_Activo_Alto.qsf` | NUEVO | Segunda revisión de polaridad |
| `Prueba_V183.qpf` | MODIFICADO | Lista las dos revisiones |
| QPF de HC-SR04 y TCS3200 | Copias sin cambios | Proyectos independientes |
| `Pruebas_ModelSim/*_TB.vhd`, `simular_sensores.do` | NUEVOS | Comprobaciones automáticas |

Los QSF ya incluyen los archivos necesarios. No es necesario agregarlos manualmente. Si recreas un proyecto:

- V183: `reinicio_seguro` → `entrada_presencia_v183` → `Prueba_V183`.
- HC-SR04: `reinicio_seguro`, `filtro_boton`, `conversor_binario_decimal`, `decodificador_7segmentos` → `lector_hcsr04` → `Prueba_HCSR04`.
- TCS3200: `reinicio_seguro`, `filtro_boton`, `decodificador_7segmentos` → `lector_tcs3200` → `Prueba_TCS3200`.
- Agrega `comunes/reloj.sdc` en los tres casos. Dispositivo: EP3C16F484C6. Todos los puertos usados: 3.3-V LVTTL. No agregues testbench a la síntesis.

Para repetir simulación con ModelSim: abre la consola en `Pruebas_ModelSim` y ejecuta `do simular_sensores.do`. El script está preparado para VHDL-93, pero las pruebas documentadas se ejecutaron con GHDL 6.0.0. No se programó una FPGA desde este trabajo.

## Alcance de las verificaciones

Se ejecutaron seis simulaciones de sensores y diez testbench originales del núcleo: todas pasaron. Se compilaron las cuatro revisiones individuales con Quartus II 13.1: 0 errores y sin advertencias críticas. Los caminos internos restringidos a CLOCK_50 cumplen temporización; el SDC heredado no define retardos externos de sensores/displays. Esto no sustituye verificar tensión, cableado, señales reales y calibración.

El TOP físico **original** también se compiló para auditarlo: genera salida, pero falla temporización (setup -8.901 ns en el lector HC-SR04). No debe interpretarse como integración validada. Consulta la auditoría.
