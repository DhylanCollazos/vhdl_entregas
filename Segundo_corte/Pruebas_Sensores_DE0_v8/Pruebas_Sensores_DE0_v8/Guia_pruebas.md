# Conexión y comportamiento esperado

## 1. Qué se prueba ahora

Primero V183. HC-SR04 y TCS3200 quedan preparados en proyectos separados para utilizarlos después. Los switches de un proyecto individual no tienen las funciones del núcleo System Alfa: consulta la tabla del proyecto que hayas programado.

En ningún proyecto individual se mueve un motor ni un servo. No hay tiempos T0–T3 ni umbrales físicos de color inventados. Conserva separados los circuitos de potencia y los GPIO de señal.

## 2. Conector correcto: GPIO 0 / J4 de DE0

`PIN_AB16` es el nombre de una bola del FPGA para Quartus; **no** es el número del contacto del conector. El contacto físico de J4 debe localizarse por su pin 1 y el manual, sin asumir que el lado izquierdo de una foto coincide con el plano.

| Señal | Contacto físico J4 | GPIO0 | Pin Quartus | Dirección vista desde FPGA |
|---|---:|---|---|---|
| V183 OUT | 2 | D[0] | PIN_AB16 | Entrada |
| HC-SR04 TRIG | 4 | D[1] | PIN_AA16 | Salida |
| HC-SR04 ECHO protegido | 5 | D[2] | PIN_AA15 | Entrada |
| TCS3200 OUT | 6 | D[3] | PIN_AB15 | Entrada |
| TCS3200 S2 | 7 | D[4] | PIN_AA14 | Salida |
| TCS3200 S3 | 8 | D[5] | PIN_AB14 | Salida |
| TCS3200 S0 | 9 | D[6] | PIN_AB13 | Salida |
| TCS3200 S1 | 10 | D[7] | PIN_AA13 | Salida |
| Alimentación +5 V | 11 | Alimentación | No asignar en QSF | Alimentación |
| GND | 12 | Tierra | No asignar en QSF | Referencia común |
| Alimentación +3.3 V | 29 | Alimentación | No asignar en QSF | Alimentación |
| GND | 30 | Tierra | No asignar en QSF | Referencia común |

Confirmado contra [manual oficial DE0 v1.1](https://www.terasic.com.tw/attachment/archive/371/DE0_User_manual_v1.1.pdf), figura 4.13 y tabla 4.8. Los contactos 1 y 3 son GPIO0_CLKIN, no D[0]/D[1]. No mezclar J4 con GPIO1/J5. No usar esta asignación para DE0-Nano u otra placa.

Apaga las fuentes al cambiar cables. Los dibujos muestran terminales por nombre: verifica las etiquetas y el orden de pines de tu módulo concreto. Ninguna entrada del Cyclone III debe recibir directamente 5 V. Usa GND común y evita unir dos salidas de alimentación entre sí. Para probar sensores solos puede usarse el riel apropiado de la DE0 dentro de su capacidad; motor y servos tendrán fuente externa y driver propios.

## 3. V183: medición previa y elección de polaridad

Como aún no se ha medido tu sensor, este paso va antes de conectar OUT a la DE0:

1. Identifica VCC, GND y OUT por la ficha/serigrafía del módulo. «V183» por sí solo no confirma tensión ni orden de terminales.
2. Confirma qué alimentación admite. Utiliza 3.3 V únicamente si tu módulo funciona a esa tensión. Si requiere 5 V, no supongas que OUT es de 3.3 V.
3. Con OUT separado de la FPGA, alimenta el sensor correctamente. Pon el multímetro en voltaje DC: negro en GND, rojo en OUT.
4. Anota OUT sin pieza y con una pieza estable, además de VCC. El sensor debe producir dos niveles claros. Si entrega 5 V, usa adaptación de nivel apropiada para su salida antes de conectarlo; no se ha diseñado una adaptación universal sin conocer si es push-pull o colector abierto.
5. Si el nivel alto de OUT no supera el dominio de 3.3 V y los niveles son compatibles, apaga y conecta OUT a J4-2, GND a J4-12 o J4-30. VCC irá al riel confirmado (J4-29 solo si admite 3.3 V).

| Medición | Valor real pendiente |
|---|---|
| Alimentación admitida según ficha/etiqueta | __________ V |
| VCC medido | __________ V |
| OUT sin pieza | __________ V |
| OUT con pieza | __________ V |
| Polaridad elegida | activo bajo / activo alto |

| OUT sin pieza | OUT con pieza | Revisión de Quartus | Genérico |
|---|---|---|---|
| Alto compatible con 3.3 V | Cerca de 0 V | `Prueba_V183` | ACTIVO_BAJO=true |
| Cerca de 0 V | Alto compatible con 3.3 V | `Prueba_V183_Activo_Alto` | ACTIVO_BAJO=false |
| No cambia / nivel ambiguo | No cambia / nivel ambiguo | No conectar aún | Revisar alimentación, sensor y ajuste |

### Mandos e indicadores del proyecto V183

| Elemento | Función |
|---|---|
| BUTTON1 | Reset de esta prueba; borra contador y espera retiro de la pieza |
| BUTTON0, BUTTON2, SW0–SW9 | Sin función en esta prueba |
| LEDG0 | Presencia confirmada; retardo de filtro de aproximadamente 5 ms |
| LEDG1 | Cambia 0→1 o 1→0 una vez por nueva pieza; no es un destello breve |
| LEDG2 | Nivel eléctrico sincronizado de OUT, sin invertir |
| LEDG9…LEDG3 | Número de eventos en binario, saturado en 127; LEDG3 pesa 1, G4=2, G5=4, G6=8, G7=16, G8=32, G9=64 |
| HEX | No utilizados; no interpretar su apariencia en esta prueba |

Empieza con el sensor libre. Después de reset con una pieza ya presente, el sistema espera que la retires y la vuelvas a colocar; no cuenta esa pieza inicial y LEDG0 permanece apagado hasta una detección nueva. LEDG2 permite ver el nivel eléctrico mientras espera.

| Acción desde arranque libre | LEDG0 | LEDG1 | Contador G9…G3 |
|---|---:|---:|---|
| Sensor libre y reset terminado | 0 | 0 | 0000000 |
| Colocar primera pieza estable | 1 | 1 | 0000001 |
| Mantenerla 10 segundos | 1 | 1 | 0000001, sin incrementar |
| Retirar y esperar al menos 20 ms | 0 | 1 | 0000001 |
| Colocar segunda pieza | 1 | 0 | 0000010 |
| Tapar/destapar muy brevemente, menos del filtro | No debe aceptar una nueva pieza estable | Sin cambio | Sin cambio |
| BUTTON1 con una pieza presente | 0 después de reset | 0 | 0000000 |
| Retirar, esperar 20 ms y volver a colocar | 1 | 1 | 0000001 |

Validación mínima: repetir 10 colocaciones/retiros, mantener una pieza 10 s sin duplicaciones, reset con y sin pieza y confirmar la polaridad. El filtro no sustituye una correcta separación física entre objetos pegados: para reconocer dos piezas debe existir retiro estable entre ellas.

FSM: INICIALIZAR → SIN_PIEZA → CONFIRMAR_PRESENCIA → GENERAR_PULSO → CON_PIEZA → CONFIRMAR_RETIRO → SIN_PIEZA. Un rebote durante confirmación vuelve al estado previo; el pulso dura un ciclo de reloj.

## 4. HC-SR04: después de validar V183

Abre `Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.qpf`. Usa un objeto plano frente al sensor para verificar distancias antes de montarlo sobre la cinta.

Conexiones:

- VCC → +5 V (J4-11); GND → GND (J4-12).
- TRIG → J4-4 / PIN_AA16.
- ECHO → resistencia de 1 kΩ → nodo de señal → J4-5 / PIN_AA15.
- Desde ese mismo nodo: resistencia de 2 kΩ → GND.
- No conectar ECHO directamente a J4-5. El valor ideal con ECHO de 5 V es 5 × 2/(1+2) ≈ 3.33 V; verifica alimentación y nivel real, y usa adaptación adecuada si tu módulo no cumple. Un multímetro puede promediar el pulso: un valor bajo medido no demuestra que su pico sea seguro; compruébalo con osciloscopio si está disponible.

La ficha del [HC-SR04](https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf) especifica TRIG de al menos 10 µs y recomienda más de 60 ms entre mediciones. El código genera 10 µs y acepta inicios separados al menos 61 ms. Para la prueba manual, pulsa y suelta BUTTON0 dejando **al menos 100 ms entre pulsaciones**. Una orden demasiado próxima o recibida mientras mide se ignora; no queda en cola.

| Elemento | Función |
|---|---|
| BUTTON0 | Una medición por pulsación; mantenerlo no repite |
| BUTTON1 | Reset de la prueba; borra lectura y alternador |
| BUTTON2 y todos los SW | Sin función |
| HEX2 HEX1 HEX0 | Distancia decimal en cm, redondeada, limitada a 255 |
| HEX3 | 1=grande, 0=pequeña; apagado cuando inválida |
| LEDG0 | 1=medición y tamaño válidos |
| LEDG1 | Tamaño; solo interpretar cuando LEDG0=1 |
| LEDG2 | Ocupado durante la secuencia, no representa el tiempo restante de separación entre disparos |
| LEDG3 | Cambia cada vez que termina, incluso con lectura inválida |
| LEDG4–LEDG9 | Apagados |

En la tabla, «_» significa display apagado, no un guion encendido. Resultados ideales de ECHO; habrá tolerancia y variación física cerca de los límites.

| Distancia | HEX3 HEX2 HEX1 HEX0 | LEDG0 | LEDG1 | Interpretación |
|---:|---|---:|---:|---|
| 23 cm | 1023 | 1 | 1 | Grande |
| 25 cm exactos | 1025 | 1 | 1 | Grande, límite |
| 26 cm | _026 | 0 | 0 | Dudosa, repetir manualmente |
| 27 cm | _027 | 0 | 0 | Dudosa, repetir manualmente |
| 29 cm | _029 | 0 | 0 | Dudosa, repetir manualmente |
| 30 cm exactos | 0030 | 1 | 0 | Pequeña, límite |
| 32 cm | 0032 | 1 | 0 | Pequeña |
| Sin respuesta / ECHO atascado | _000 | 0 | 0 | Error; finaliza por descarte o timeout |
| Más de 255 cm | _255 | 0 | 0 | Fuera del rango representable de este lector |

El sensor está encima: a mayor altura de la pieza, menor distancia medida. El código admite grande desde 2 hasta 25 cm y pequeña desde 30 hasta 255 cm; distancia entre 25 y 30 cm, menor de 2 o mayor de 255 se rechaza. La clasificación usa el ancho medido, no el número redondeado del display: por ejemplo 25.2 cm puede mostrarse como 025 y seguir inválido.

FSM: ESPERA → DISPARO → ESPERAR_ECHO → MEDIR_ECHO → CALCULAR → FINALIZAR → ESPERA. CALCULAR realiza restas sucesivas (hasta 255 ciclos) para evitar un divisor largo a 50 MHz. Sin subida o sin bajada de ECHO termina inválida por timeout; ECHO alto antes de iniciar se descarta sin TRIG. La zona dudosa no se repite automáticamente en este banco.

## 5. TCS3200: calibración, después del HC-SR04

Abre `Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.qpf`.

| Terminal TCS3200/GY-31 | Conectar a |
|---|---|
| VCC | J4-29 / +3.3 V, comprobando que tu módulo completo lo admite |
| GND | J4-30 o J4-12 |
| OUT | J4-6 / PIN_AB15 |
| S2 | J4-7 / PIN_AA14 |
| S3 | J4-8 / PIN_AB14 |
| S0 | J4-9 / PIN_AB13 |
| S1 | J4-10 / PIN_AA13 |
| OE | GND; activo en bajo |

La [ficha del integrado TCS3200](https://look.ams-osram.com/m/664723bdb31f55db/original/TCS3200-DS000107.pdf) permite alimentación de 2.7 a 5.5 V. El módulo GY-31 incluye otros componentes: verifica su circuito/iluminación. Se propone 3.3 V para que OUT use el mismo dominio de la FPGA; no cambiar VCC a 5 V manteniendo OUT directo a la DE0.

Escala S0/S1=10 (20 %). La FSM mide sucesivamente rojo (S2/S3=00), verde (11), azul (01). Asienta 0.1 ms y mide 10 ms por filtro. Son conteos de flancos, no valores RGB de 0 a 255; el conjunto tarda aproximadamente 30.3 ms. Si los datos no son repetibles, revisar iluminación, distancia, cinta, frecuencia de OUT y tiempo de asentamiento.

| Mando | Función |
|---|---|
| BUTTON0 | Captura un conjunto nuevo R/G/B |
| BUTTON1 | Reset y borra las lecturas |
| BUTTON2 | Sin función |
| SW1 SW0=00 | Mostrar conteo rojo |
| SW1 SW0=01 | Mostrar conteo verde |
| SW1 SW0=10 | Mostrar conteo azul |
| SW1 SW0=11 | Mostrar 0000, selección reservada |
| SW2–SW9 | Sin función |

Puedes cambiar SW1/SW0 después de medir para leer los tres resultados de la misma muestra, sin pulsar BUTTON0 otra vez. Los cuatro HEX muestran **hexadecimal**: 000A=10, 0010=16, 0064=100. Con ventana de 30 ms, la frecuencia aproximada en Hz = conteo decimal × 33.3. FFFF indica saturación y exige revisar la ventana/escala/señal.

| LED | Comportamiento en este proyecto de calibración |
|---|---|
| LEDG1 LEDG0 | 01 rojo, 10 verde, 11 azul, 00 inválido |
| LEDG2 | 1 si los puntajes compensados pasan la señal mínima y separación; 0 inválido |
| LEDG3 | 1 mientras mide; es breve y puede no distinguirse a simple vista |
| LEDG4 | Cambia al terminar cada conjunto; este es el indicador visible de finalización |
| LEDG5–LEDG9 | 0 |

La clasificación de este banco ya utiliza la calibración preliminar de pantalla anotada en `Calibracion_TCS3200.md`: resta las referencias negras y equilibra las ganancias con blanco antes de comparar. Los HEX siguen mostrando conteos crudos. Valida la respuesta con piezas reales antes de trasladar estos parámetros al TOP integrado.

Toma al menos cinco muestras de cada pieza y de la cinta vacía, con distancia e iluminación reales y sin moverla durante una captura:

| Muestra / objeto | Distancia e iluminación | R (HEX/decimal) | G (HEX/decimal) | B (HEX/decimal) |
|---|---|---|---|---|
| Roja 1–5 | __________ | __________ | __________ | __________ |
| Verde 1–5 | __________ | __________ | __________ | __________ |
| Azul 1–5 | __________ | __________ | __________ | __________ |
| Cinta sin pieza 1–5 | __________ | __________ | __________ | __________ |

FSM: ESPERA → ASENTAR_ROJO → MEDIR_ROJO → ASENTAR_VERDE → MEDIR_VERDE → ASENTAR_AZUL → MEDIR_AZUL → CLASIFICAR → FINALIZAR → ESPERA. Los conteos R/G/B quedan disponibles después de terminar la secuencia.

## 6. Switches de SystemAlfa_Placa original, para comparación

Esta sección describe el **proyecto manual de la octava versión**, no los bancos de sensores anteriores.

| Mando | Función comprensible |
|---|---|
| SW1 y SW0 | Color de la siguiente pieza: 00 inválido, 01 rojo, 10 verde, 11 azul |
| SW2 | Tamaño: 0 pequeña, 1 grande |
| SW3 | 1 habilita la línea; 0 la detiene |
| SW4 | 0 pantalla normal; 1 abre consultas |
| SW5 | Pasar 0→1 avanza un registro o la selección de cantidad; volver a 0 antes del siguiente avance |
| SW6 | Dentro del historial: 0 muestra ID, 1 muestra segundo guardado |
| SW7 | Con SW4=1: 0 historial, 1 cantidades |
| SW8 | Pasar 0→1 vuelve al registro más reciente del historial |
| SW9 | En cantidades: 0 categorías 1–6, 1 colores 1–3 (rojo, verde, azul) |
| BUTTON0 | Simula una pieza al pulsar; soltar para poder detectar otra |
| BUTTON1 | Reset operativo; conserva la sesión. Con SW3=1 vuelve a marchar al soltarlo |
| BUTTON2 | Cambia nivel 0→1→2→3→0; no es todavía PWM de un motor |

LEDG1/G0 muestran color, LEDG2 tamaño, LEDG3 parpadeo de marcha, LEDG7…G4 categoría binaria, LEDG8 alarma, LEDG9 límite. Durante consultas, color/tamaño/categoría corresponden al dato consultado. El parpadeo cambia cada 0.5 s, 1 s, aproximadamente 0.333 s y 2 s según nivel 0,1,2,3: los números actuales no equivalen a velocidades físicas crecientes. El nivel 0 no significa motor apagado; SW3 controla marcha. Después de reset la velocidad vuelve a 0 y LEDG3 puede tardar aproximadamente 0.5 s en encender por primera vez.

En el TOP físico original, SW0–SW2 y BUTTON0 quedan sin función; los sensores suministran color/tamaño/presencia. SW3–SW9, BUTTON1 y BUTTON2 conservan su papel. Esto describe el código existente: no implica que la integración física esté validada.

### Tabla de clasificación manual

Prepara color y tamaño, espera al menos 20 ms, SW3=1, SW4=0, velocidad=0. Pulsa y suelta BUTTON0 durante al menos 20 ms por nivel, sin mantenerlo cinco segundos. Para esta secuencia se parte de una sesión recién configurada.

| Paso | SW1 SW0 | SW2 | Categoría | HEX3…HEX0 tras una pieza |
|---:|---|---:|---:|---|
| 1 | 01 | 0 | 1, rojo pequeño | 0001 |
| 2 | 01 | 1 | 2, rojo grande | 0002 |
| 3 | 10 | 0 | 3, verde pequeño | 0003 |
| 4 | 10 | 1 | 4, verde grande | 0004 |
| 5 | 11 | 0 | 5, azul pequeño | 0005 |
| 6 | 11 | 1 | 6, azul grande | 0006 |
| 7 | 00 | 0 o 1 | 8, rechazo | 0006: no suma ni guarda ID 7 |
| 8 | BUTTON1 y retirar presencia; luego 01 | 0 | 1 | 0007: siguiente válido recibe ID 7 |

Después de seis válidas, en cantidades cada categoría tiene 1 y cada color tiene 2. Con SW4=1, SW7=1, SW9=0, HEX3 identifica categoría y HEX2…HEX0 muestran cantidad (1001, 2001, …, 6001). Con SW9=1 muestra 1002, 2002, 3002.

Con total 21 y velocidad 0, modo normal muestra 0021. Un rechazo conserva 0021 y último ID 21; el siguiente válido será total/ID 22. BUTTON1 conserva ese total y el historial. Con velocidad 2 y total 21 se ve 2021. En historial HEX3 se apaga y HEX2…HEX0 muestran ID o tiempo: _021 si se consulta ID 21. La RAM retiene los ocho últimos válidos; con 21 válidos están IDs 14–21.

## 7. Cuándo continuar a la integración

Primero registrar resultados reales del V183; después HC-SR04; después las muestras RGB. Antes de integrar, resolver coordinación de mediciones, plazo máximo, tratamiento de distancia dudosa, pieza llegada mientras está ocupado y atasco físico. Compilar y simular nuevamente la integración con los parámetros medidos.

Después vendrán L298N/PWM, un MG90S, el segundo MG90S y displays externos de ánodo común con resistencias/driver adecuados. Los retardos T0–T3 deben medirse por velocidad, con varias repeticiones; no se asignaron valores en este paquete.
