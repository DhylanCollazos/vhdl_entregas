# Calibración preliminar del TCS3200

Las lecturas se anotaron en hexadecimal y se convierten a decimal aquí, en orden R, G, B.

| Pantalla | Muestra 1 | Muestra 2 | Muestra 3 |
|---|---|---|---|
| Rojo intenso | 64, 29, 39 | 64, 30, 39 | 63, 29, 39 |
| Verde intenso | 36, 55, 44 | 35, 56, 44 | 35, 55, 43 |
| Azul intenso | 28, 33, 58 | 29, 34, 58 | 29, 33, 57 |
| Verde oscuro | 29, 34, 37 | 28, 33, 36 | 28, 33, 36 |
| Blanco | 123, 102, 106 | 121, 101, 105 | 121, 101, 105 |
| Negro | 25, 26, 34 | 26, 27, 34 | 26, 26, 35 |

## Valores puestos en el lector

- Base negra redondeada: R=26, G=26, B=34.
- Diferencias blanco-negro: R=96, G=75, B=71.
- Ganancias aproximadas en Q5: R=85, G=109, B=115. Q5 indica que el producto se divide entre 32.
- Puntaje mínimo: 10.
- Separación: el mayor puntaje supera al segundo por más de 20 %.
- Captura: ventana 30 ms, asentamiento 0.5 ms, escala 20 %.

El lector resta el fondo negro y compensa la sensibilidad desigual de los canales. Compara los puntajes corregidos; los cuatro HEX siguen presentando los conteos crudos.

## Resultado aritmético sobre estas mismas capturas

| Muestras | Resultado calculado |
|---|---|
| Rojo intenso | Rojo, 3/3 |
| Verde intenso | Verde, 3/3 |
| Azul intenso | Azul, 3/3 |
| Verde oscuro | Verde, 3/3 |
| Blanco | Inválido, 3/3 |
| Negro | Inválido, 3/3 |

Es una calibración preliminar con la pantalla del teléfono: se ajustó usando estas mismas muestras. Falta validar con muestras nuevas, cinta y piezas reales. El lector individual está calibrado; el TOP integrado `SystemAlfa_Hardware` todavía no lo está.

## Recordatorio de la prueba física

En las pruebas posteriores el verde todavía no se caracteriza como se espera. Por ahora se deja el código con estos parámetros preliminares, pero no se considera resuelto ni debe copiarse al TOP integrado. Volver a calibrar cuando se tengan nuevas muestras R/G/B del verde real, repetidas con la misma distancia, iluminación, orientación y fondo que se usarán en la cinta.
