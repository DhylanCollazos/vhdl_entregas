# Auditoría de la octava versión real

Se inspeccionó `octava_version.rar`, extraído sin alterar el original. La referencia a «séptima» en el mensaje se interpretó como contexto; la base efectiva es la octava adjunta. `validacion/base_octava_sha256.json` identifica los archivos de referencia. No se recibieron diapositivas/manual de la placa en `sources/`; se consultó el manual oficial DE0 v1.1 para los pines. Las FSM nuevas conservan el patrón académico de tres procesos.

## Núcleo: se conserva sin cambios

La jerarquía real es `SystemAlfa_Placa` → `SystemAlfa_Final` → captura/filtros, reglas/ROM, FSM, conteos, RAM/historial, reloj de sesión y visualización. En la adaptación física, `SystemAlfa_Hardware` sustituye la captura manual con V183, HC-SR04, TCS3200 y `control_lectura_sensores`, y vuelve a instanciar el mismo núcleo.

| Elemento | Resultado de inspección |
|---|---|
| Paquete y función | `paquete_funciones` y `formar_direccion` conservados; dirección = color de 2 bits concatenado con tamaño |
| ROM | `rom_categorias`: 8 entradas de 5 bits; seis categorías válidas, color 00 da rechazo 8 y válida=0 |
| RAM | `memoria_ram_historial`: 8 palabras de 21 bits; escritura síncrona, lectura combinacional; tiempo 8, ID 10, color 2, tamaño 1 |
| RAM en FPGA | Existe como descripción de memoria; el ajuste original reportó 0 bits de memoria dedicada. Quartus la realiza con lógica/registros, no con un bloque M9K. No se cambió esa arquitectura |
| Historial | Circular, últimos ocho registros válidos. IDs desde 1 hasta 999. Entrar al historial selecciona el último; avanzar desde el último vuelve al más antiguo disponible |
| Rechazos | `guardar_sesion <= registrar_evento and pieza_valida and not reinicio_alto`. **No se guardan, no consumen ID y no incrementan total ni cantidades**. La indicación de rechazo/alarma sí puede activarse |
| Conteos | Seis contadores de categorías; consultas por color suman cada par pequeño/grande. Total limitado a 999 |
| Reset BUTTON1 | Limpia operación, FSM, alarma, última indicación y nivel de velocidad. Conserva total, conteos, RAM/IDs y tiempo de sesión |
| Marcha tras reset | **No exige SW3 0→1 en esta versión.** Al soltar BUTTON1 vuelve a leer SW3; si sigue en 1 y no hay bloqueo, la línea vuelve a marchar después del filtro. LEDG3 parpadea, no indica marcha con luz fija |
| Tiempo | Cuenta segundos desde configuración, incluso con línea parada; rango 0..179 y vuelve a 0. No es un reloj ilimitado ni tiempo por pieza; historial guarda el segundo de captura |
| Displays normales | HEX3 velocidad; HEX2 centenas; HEX1 decenas; HEX0 unidades. Velocidad 0 y total 21 → **0021** |
| FSM central | Tipo enumerado: ESPERA, DETECCION, LECTURA_COLOR, CLASIFICACION, REGISTRO, ERROR_ESTADO. Tres procesos: registro, transición y salidas |
| Drivers | La compilación original no produjo errores de drivers múltiples; las señales modificadas también tienen un único proceso controlador |

La sesión se reinicia al reconfigurar/apagar, no con BUTTON1. A total 999 el bloqueo por límite permanece incluso después del reset operativo.

## Adaptación física: aciertos y pendientes

Los cinco archivos físicos sí están presentes, además de los tres proyectos individuales. Las FSM tienen estados explícitos y entradas con sincronización. El coordinador almacena por separado el resultado de cada sensor; no necesita que ambos terminen en el mismo ciclo. Prepara color/tamaño antes de enviar un pulso activo bajo de 20 ms al núcleo, cuyo filtro nominal es de 10 ms.

| Archivo real | Hallazgo | Tratamiento en esta entrega |
|---|---|---|
| `entrada_presencia_v183.vhd` | Impide repetición y espera retiro tras reset. Con filtros muy cortos, podía armarse usando ceros iniciales del sincronizador | En la copia individual se espera a que las dos etapas tengan una muestra real |
| `Prueba_V183.vhd` | Polaridad fija y pocos indicadores | Genérico ACTIVO_BAJO, dos revisiones; LED de OUT crudo y contador binario de eventos |
| `lector_hcsr04.vhd` | Omite un ciclo alto; truncamiento mueve medidas exactas al centímetro anterior. Una división combinacional larga también incumple 50 MHz | Cuenta desde el primer ciclo; compara ancho completo para clasificar; muestra distancia redondeada calculada mediante restas por ciclo |
| `lector_hcsr04.vhd` | Sin intervalo mínimo; inicio mantenido puede repetir; ECHO alto previo no se descarta | Intervalo de 61 ms entre órdenes aceptadas, inicio por flanco y descarte si ECHO ya está alto. Conserva timeout |
| `Prueba_HCSR04.vhd` | Tamaño 0 parecía «pequeña» incluso si era inválida | HEX3 apagado cuando válida=0; LEDG0 sigue siendo la referencia de validez |
| `lector_tcs3200.vhd` | Secuencia RGB, escala 20 % y conservación de conteos correctas. Mínimo 5/margen 10 son provisionales, no calibración | Clasificación deshabilitada por defecto. Conteos crudos conservados; un inicio por flanco. Si se habilita después, exige umbrales positivos y rechaza saturación |
| `Prueba_TCS3200.vhd` | Mostraba conteos en hexadecimal (correcto, pero no explicado); selector asíncrono | Mantiene hexadecimal de 16 bits; sincroniza SW1/SW0; documenta modo de calibración |
| QSF individuales | Quartus interpretaba `{BUTTON[*]}`, etc., como nombres inválidos e ignoraba estándares por bus | Se asignó el estándar a cada puerto/pin por separado. Pines restantes en alta impedancia |
| `control_lectura_sensores.vhd` | No tiene plazo máximo propio, ni repetición de distancia dudosa, ni cola de piezas, ni conexión de marcha/listo con el núcleo | Solo auditado; pendiente antes de integración física. Una orden que un lector no acepte puede dejarlo esperando |
| `control_lectura_sensores.vhd` | Ignora pulsos nuevos mientras está ocupado; una pieza llegada durante liberación puede perderse | Exigir espaciamiento/una pieza por vez; acordar manejo de cola o bloqueo en la siguiente etapa |
| `SystemAlfa_Hardware.vhd` | Núcleo recibe presencia sintética de 20 ms, no presencia física mantenida | El atasco físico del V183 no activa el temporizador de 5 s del núcleo: falta supervisión en la capa física |
| `SystemAlfa_Hardware.vhd` | No expone R/G/B para calibrar y fija umbrales provisionales. El motor y servos aún no están conectados | Mantener como referencia; no programar integración hasta validar sensores y resolver los pendientes |

**No copies los tres lectores nuevos encima del TOP integrado antiguo todavía.** El TCS3200 nuevo está deliberadamente en calibración y el coordinador antiguo no gestiona el intervalo de aceptación del HC-SR04. La integración requiere su propia revisión posterior. No fue necesario modificar `SystemAlfa_Final` para los bancos individuales.

## GPIO y compatibilidad

Se verificaron las asignaciones contra la figura 4.13 y la tabla 4.8 del manual DE0 v1.1. AB16, AA16, AA15, AB15, AA14, AB14, AB13 y AA13 corresponden a GPIO0 D[0..7]. No hay colisiones dentro de los QSF originales inspeccionados ni de las pruebas nuevas.

`Adaptacion_GPIO/GPIO_entradas.qsf` es una adaptación anterior con señales ya codificadas y reutiliza los primeros cuatro pines. Es un proyecto alternativo. **No se puede mezclar ese QSF con `GPIO_hardware.qsf`**: son señales y direcciones distintas en los mismos contactos.

## Verificación ejecutada

Herramientas efectivamente ejecutadas: Quartus II 64-Bit 13.1.0 Build 162 Web Edition y GHDL 6.0.0, VHDL-93. No se ejecutó ModelSim en esta entrega ni se probó una DE0 real.

| Compilación | Errores / críticas | Peor margen setup interno | Resultado |
|---|---|---|---|
| Prueba V183 activo bajo | 0 / 0 | +15.540 ns | `.sof` generado |
| Prueba V183 activo alto | 0 / 0 | +15.299 ns | `.sof` generado |
| Prueba HC-SR04 corregida | 0 / 0 | +13.182 ns | `.sof` generado |
| Prueba TCS3200 calibración | 0 / 0 | +14.187 ns | `.sof` generado |
| SystemAlfa_Hardware ORIGINAL | 0 / advertencia de temporización | **−8.901 ns** | Compila, pero no cumple el periodo interno de 20 ns |

La ruta que falla en el original va de `U_HCSR04/echo_capturado` a `valida_reg`/`tamano_reg`. El lector nuevo evita el divisor combinacional; no se repitió la integración completa con ese lector por los pendientes de coordinación ya indicados.

El SDC heredado define CLOCK_50 y su incertidumbre; no define retardos de señales externas. Los márgenes anteriores corresponden a caminos internos restringidos, no a una certificación eléctrica de GPIO. Persisten advertencias sobre entradas no usadas, salidas constantes, licencia Web Edition y requisitos eléctricos Cyclone III de 3.3 V. La advertencia de asignaciones I/O incompletas corresponde a fuerza de salida no especificada (se usa el valor predeterminado); no a ubicaciones GPIO ausentes. Se conservan los informes completos.

Seis ejecuciones nuevas con aserciones: V183 en ambas polaridades con filtros 1 y 5; HC-SR04 con 23/25/25.5/26/27/29/30/32/2/1/256 cm, sin respuesta, ECHO previo alto, ECHO bloqueado, duración TRIG, intervalo y orden sostenida; TCS con secuencia RGB, conteos sintéticos, empates, ausencia de pulsos, reset y orden sostenida. Los umbrales del test de color son exclusivamente estímulos de simulación.

Diez testbench del archivo original pasaron: FSM, RAM, ROM, RF1, RF2, RF3, RF4, RF5, SystemAlfa_Final y SystemAlfa_Limites. Incluyen comportamiento de rechazo, 0021, reset con sesión conservada y límites. Esto comprueba lo que cubren esos testbench, no todas las situaciones físicas posibles.

## Fuentes de hardware

- [Terasic, DE0 User Manual v1.1](https://www.terasic.com.tw/attachment/archive/371/DE0_User_manual_v1.1.pdf), figura 4.13 y tabla 4.8.
- [ElecFreaks, HC-SR04, ficha alojada por SparkFun](https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf): alimentación, pulso TRIG y separación de mediciones.
- [ams OSRAM, TCS3200 DS000107](https://look.ams-osram.com/m/664723bdb31f55db/original/TCS3200-DS000107.pdf): alimentación del integrado, filtros, escala y OE.

El nombre V183 no ha permitido confirmar una ficha inequívoca de tu módulo. Su alimentación, orden físico de terminales, nivel de OUT y polaridad siguen pendientes de identificación/medición. El plano del V183 usa nombres de terminales, no presume el orden de pines de tu placa.
