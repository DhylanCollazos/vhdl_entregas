# System Alfa físico v9

1. Abrir **Documentacion/Guia_SystemAlfa_Fisico_v9.pdf**. Incluye esquema, pines, alimentación, switches, calibración y resultados esperados.
2. Abrir **SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.qpf** en Quartus II 13.1. Es el proyecto integrado; entidad SystemAlfa_Hardware.
3. Con actuadores desconectados, cargar **Programacion/SystemAlfa_Hardware.sof** mediante USB-Blaster. Fue generado con Quartus II 13.1 para EP3C16F484C6, sin errores y cumpliendo 50 MHz.
4. Conectar según la guía. SW0=1 habilita ajuste; SW3 debe estar abajo al cambiar modo/página. Configurar primero servos y PWM, después medir tiempos de cada velocidad en página 7.
5. Volver a SW0=0 con SW3 abajo. Estación vacía, subir SW3 y probar una pieza por ciclo.

Los porcentajes y tiempos parten sin configurar: el automático no arranca hasta calibrarlos. BUTTON1 conserva sesión y ajustes, pero exige SW3 0 -> 1. Apagar o reprogramar borra los datos volátiles. El verde y la medición a 2 cm deben verificarse físicamente; no se presentan como problemas resueltos por simulación.

## Para copiar y pegar

- CODIGOS_NUEVOS_Y_MODIFICADOS.md: bloques completos de los archivos que se agregan o reemplazan, incluidos QSF.
- TODOS_LOS_VHDL.md: los 69 archivos VHDL completos, uno por ruta.
- CAMBIOS_Y_ARCHIVOS.md: lista y explicación de cambios respecto a octava_version.rar.
- ORDEN_COMPILACION.txt: dependencias de fuentes y bancos de prueba. El QSF ya resuelve las de síntesis.

La carpeta SystemAlfa contiene los archivos editables reales. No se modificaron los RAR originales ni las referencias de sources/. Se incluyen las tres pruebas individuales de sensores. Para motores y servos se usa el modo de ajuste del TOP completo, que prueba cada actuador sin registrar piezas.

Validación: 16 bancos pasaron en GHDL; Quartus físico: 0 errores, 14 advertencias, setup +4.707 ns. ModelSim y la placa física no fueron ejecutados desde aquí. Informes en validacion/.
