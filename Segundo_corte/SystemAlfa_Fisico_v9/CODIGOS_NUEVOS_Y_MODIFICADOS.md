# Códigos completos: nuevos y modificados

Cada bloque contiene el archivo completo. La ruta identifica dónde agregarlo o reemplazarlo. El proyecto y los QSF ya se entregan preparados en la carpeta SystemAlfa.

## SystemAlfa/Adaptacion_GPIO/SystemAlfa_Sensores.qsf - MODIFICADO

```tcl
set_global_assignment -name VHDL_FILE ../comunes/paquete_funciones.vhd
# -------------------------------------------------------------------------- #
#
# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.
#
# -------------------------------------------------------------------------- #
#
# Quartus II 64-Bit
# Version 13.1.0 Build 162 10/23/2013 SJ Web Edition
# Date created = 13:00:30  September 22, 2026
#
# -------------------------------------------------------------------------- #
#
# Notes:
#
# 1) The default values for assignments are stored in the file:
#		SystemAlfa_Final_assignment_defaults.qdf
#    If this file doesn't exist, see file:
#		assignment_defaults.qdf
#
# 2) Altera recommends that you do not modify this file. This
#    file is updated automatically by the Quartus II software
#    and any changes you make may be lost or overwritten.
#
# -------------------------------------------------------------------------- #


set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name TOP_LEVEL_ENTITY SystemAlfa_Sensores
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 13.1
set_global_assignment -name PROJECT_CREATION_TIME_DATE "13:00:30  SEPTEMBER 22, 2026"
set_global_assignment -name LAST_QUARTUS_VERSION 13.1
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 484
set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 6
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_location_assignment PIN_G21 -to CLOCK_50
set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]
set_location_assignment PIN_J6 -to SW[0]
set_location_assignment PIN_H5 -to SW[1]
set_location_assignment PIN_H6 -to SW[2]
set_location_assignment PIN_G4 -to SW[3]
set_location_assignment PIN_G5 -to SW[4]
set_location_assignment PIN_J7 -to SW[5]
set_location_assignment PIN_H7 -to SW[6]
set_location_assignment PIN_E3 -to SW[7]
set_location_assignment PIN_E4 -to SW[8]
set_location_assignment PIN_D2 -to SW[9]
set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_location_assignment PIN_E11 -to HEX0[0]
set_location_assignment PIN_F11 -to HEX0[1]
set_location_assignment PIN_H12 -to HEX0[2]
set_location_assignment PIN_H13 -to HEX0[3]
set_location_assignment PIN_G12 -to HEX0[4]
set_location_assignment PIN_F12 -to HEX0[5]
set_location_assignment PIN_F13 -to HEX0[6]
set_location_assignment PIN_A13 -to HEX1[0]
set_location_assignment PIN_B13 -to HEX1[1]
set_location_assignment PIN_C13 -to HEX1[2]
set_location_assignment PIN_A14 -to HEX1[3]
set_location_assignment PIN_B14 -to HEX1[4]
set_location_assignment PIN_E14 -to HEX1[5]
set_location_assignment PIN_A15 -to HEX1[6]
set_location_assignment PIN_D15 -to HEX2[0]
set_location_assignment PIN_A16 -to HEX2[1]
set_location_assignment PIN_B16 -to HEX2[2]
set_location_assignment PIN_E15 -to HEX2[3]
set_location_assignment PIN_A17 -to HEX2[4]
set_location_assignment PIN_B17 -to HEX2[5]
set_location_assignment PIN_F14 -to HEX2[6]
set_location_assignment PIN_B18 -to HEX3[0]
set_location_assignment PIN_F15 -to HEX3[1]
set_location_assignment PIN_A19 -to HEX3[2]
set_location_assignment PIN_B19 -to HEX3[3]
set_location_assignment PIN_C19 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_G15 -to HEX3[6]
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name VHDL_FILE ../comunes/rom_categorias.vhd
set_global_assignment -name VHDL_FILE ../comunes/memoria_ram_historial.vhd
set_global_assignment -name VHDL_FILE ../comunes/maquina_estados_control.vhd
set_global_assignment -name VHDL_FILE ../comunes/codificador_direccion.vhd
set_global_assignment -name VHDL_FILE ../comunes/historial_sesion.vhd
set_global_assignment -name VHDL_FILE ../comunes/conteo_categorias.vhd
set_global_assignment -name VHDL_FILE ../comunes/clasificador_ruta.vhd
set_global_assignment -name VHDL_FILE ../comunes/tabla_reglas.vhd
set_global_assignment -name VHDL_FILE ../comunes/supervisor_error.vhd
set_global_assignment -name VHDL_FILE ../comunes/sincronizador.vhd
set_global_assignment -name VHDL_FILE ../comunes/selector_velocidad.vhd
set_global_assignment -name VHDL_FILE ../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../comunes/registro_tamano.vhd
set_global_assignment -name VHDL_FILE ../comunes/registro_color.vhd
set_global_assignment -name VHDL_FILE ../comunes/historial.vhd
set_global_assignment -name VHDL_FILE ../comunes/filtro_boton.vhd
set_global_assignment -name VHDL_FILE ../comunes/divisor_frecuencia.vhd
set_global_assignment -name VHDL_FILE ../comunes/decodificador_7segmentos.vhd
set_global_assignment -name VHDL_FILE ../comunes/control_linea.vhd
set_global_assignment -name VHDL_FILE ../comunes/contador_segundos.vhd
set_global_assignment -name VHDL_FILE ../comunes/contador_ascendente.vhd
set_global_assignment -name VHDL_FILE ../comunes/captura_pieza.vhd
set_global_assignment -name VHDL_FILE ../SystemAlfa_Final/SystemAlfa_Final.vhd
set_global_assignment -name VHDL_FILE SystemAlfa_Sensores.vhd
set_global_assignment -name SDC_FILE ../comunes/reloj.sdc
set_global_assignment -name VHDL_FILE ../comunes/conversor_binario_decimal.vhd
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
source GPIO_entradas.qsf
set_global_assignment -name VHDL_FILE ../comunes/conversor_decimal_reloj.vhd
```

## SystemAlfa/Adaptacion_GPIO/SystemAlfa_Sensores.vhd - MODIFICADO

```vhdl
-- OPCIONAL: entradas GPIO digitales ya acondicionadas a 3.3 V.
-- No contiene lectores TCS3200/ultrasonido ni controladores de actuadores.
-- BUTTON0 y SW0..SW2 ya no se usan como sensores en esta variante.
library ieee;
use ieee.std_logic_1164.all;

entity SystemAlfa_Sensores is
    port (
        CLOCK_50 : in std_logic;
        SENSOR_PRESENCIA_N : in std_logic;
        SENSOR_COLOR : in std_logic_vector(1 downto 0);
        SENSOR_TAMANO : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0, HEX1, HEX2, HEX3 :
            out std_logic_vector(6 downto 0)
    );
end entity SystemAlfa_Sensores;

architecture estructural of SystemAlfa_Sensores is

    component SystemAlfa_Final is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO : positive := 500000;
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA, CAMBIO_VELOCIDAD :
                in std_logic;

            SELECTOR_COLOR : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO, LINEA_MARCHA : in std_logic;

            VER_HISTORIAL, SIGUIENTE_HISTORIAL : in std_logic;
            SELECCION_HISTORIAL, VER_CANTIDADES : in std_logic;
            IR_ULTIMO, CONTAR_POR_COLOR : in std_logic;

            LED_COLOR : out std_logic_vector(1 downto 0);
            LED_TAMANO, LINEA_ACTIVA : out std_logic;
            RUTA_PIEZA : out std_logic_vector(3 downto 0);
            ALARMA, LED_LIMITE : out std_logic;

            VISOR_0, VISOR_1, VISOR_2, VISOR_3 :
                out std_logic_vector(6 downto 0);
            MARCHA_FISICA, EVENTO_VALIDO : out std_logic;
            NIVEL_FISICO : out std_logic_vector(1 downto 0);
            CATEGORIA_FISICA : out std_logic_vector(3 downto 0)
        );
    end component;

    signal color : std_logic_vector(1 downto 0);
    signal tamano, linea, alarma, limite : std_logic;
    signal categoria : std_logic_vector(3 downto 0);

begin

    U_SISTEMA : SystemAlfa_Final
        port map (
            RELOJ => CLOCK_50,
            REINICIO_BAJO => BUTTON(1),
            PRESENCIA => SENSOR_PRESENCIA_N,
            CAMBIO_VELOCIDAD => BUTTON(2),

            SELECTOR_COLOR => SENSOR_COLOR,
            SELECTOR_TAMANO => SENSOR_TAMANO,
            LINEA_MARCHA => SW(3),

            VER_HISTORIAL => SW(4),
            SIGUIENTE_HISTORIAL => SW(5),
            SELECCION_HISTORIAL => SW(6),
            VER_CANTIDADES => SW(7),
            IR_ULTIMO => SW(8),
            CONTAR_POR_COLOR => SW(9),

            LED_COLOR => color,
            LED_TAMANO => tamano,
            LINEA_ACTIVA => linea,
            RUTA_PIEZA => categoria,
            ALARMA => alarma,
            LED_LIMITE => limite,

            VISOR_0 => HEX0,
            VISOR_1 => HEX1,
            VISOR_2 => HEX2,
            VISOR_3 => HEX3, MARCHA_FISICA => open, EVENTO_VALIDO => open, NIVEL_FISICO => open, CATEGORIA_FISICA => open
        );

    LEDG(1 downto 0) <= color;
    LEDG(2) <= tamano;
    LEDG(3) <= linea;
    LEDG(7 downto 4) <= categoria;
    LEDG(8) <= alarma;
    LEDG(9) <= limite;

end architecture estructural;
```

## SystemAlfa/comunes/conversor_decimal_reloj.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Misma conversion 000..999, con diez pasos registrados para cumplir 50 MHz.
entity conversor_decimal_reloj is
    port(reloj:in std_logic;numero_binario:in std_logic_vector(9 downto 0);
         centenas,decenas,unidades:out std_logic_vector(3 downto 0));
end;
architecture rtl of conversor_decimal_reloj is
    signal binario:unsigned(9 downto 0):=(others=>'0');
    signal bcd:unsigned(11 downto 0):=(others=>'0');
    signal resultado:std_logic_vector(11 downto 0):=(others=>'0');
    signal paso:integer range 0 to 10:=0;
begin
    process(reloj)
        variable ajuste:unsigned(11 downto 0);
    begin
        if rising_edge(reloj) then
            if paso=0 then
                if unsigned(numero_binario)>999 then binario<=to_unsigned(999,10);
                else binario<=unsigned(numero_binario);end if;
                bcd<=(others=>'0');paso<=1;
            else
                ajuste:=bcd;
                for i in 0 to 2 loop
                    if ajuste(i*4+3 downto i*4)>=5 then ajuste(i*4+3 downto i*4):=ajuste(i*4+3 downto i*4)+3;end if;
                end loop;
                ajuste:=ajuste(10 downto 0)&binario(9);bcd<=ajuste;binario<=binario(8 downto 0)&'0';
                if paso=10 then resultado<=std_logic_vector(ajuste);paso<=0;else paso<=paso+1;end if;
            end if;
        end if;
    end process;
    centenas<=resultado(11 downto 8);decenas<=resultado(7 downto 4);unidades<=resultado(3 downto 0);
end;
```

## SystemAlfa/Hardware_Sensores/ajuste_fisico.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Ajustes en registros: sobreviven a BUTTON1, se pierden al apagar/configurar.
-- Tiempo en centesimas (10 ms). NO hay tiempos de transporte inventados.
entity ajuste_fisico is
    port (reloj, reinicio_sesion, reinicio_operativo, tick : in std_logic;
          modo_ajuste, permiso, aumentar, disminuir : in std_logic;
          pagina : in integer range 0 to 63;
          velocidad : in integer range 0 to 3;
          porcentaje : out integer range 0 to 100;
          reposo1, desvio1, reposo2, desvio2 : out integer range 1000 to 2000;
          adelanto1, adelanto2 : out integer range 5 to 100;
          llegada1, llegada2, salida_cinta : out integer range 0 to 6000;
          listo, posiciones1, posiciones2, motor_prueba, error_ajuste : out std_logic;
          etapa : out std_logic_vector(3 downto 0);
          valor : out integer range 0 to 65535);
end;

architecture fsm_tres_procesos of ajuste_fisico is
    type tabla_duty is array(0 to 3) of integer range 0 to 100;
    type tabla_tiempo is array(0 to 3) of integer range 0 to 6000;
    type tabla_posicion is array(0 to 3) of integer range 1000 to 2000;
    type tabla_adelanto is array(0 to 1) of integer range 5 to 100;
    type tipo_estado is (ESPERA, MIDE_SERVO1, MIDE_SERVO2, MIDE_SALIDA, FALLO_AJUSTE);
    signal estado, siguiente : tipo_estado := ESPERA;
    signal duty : tabla_duty := (others=>0);
    signal t1,t2,fin : tabla_tiempo := (others=>0);
    signal pos : tabla_posicion := (others=>1500);
    signal avance : tabla_adelanto := (others=>30);
    signal tiempos_validos, posiciones_validas : std_logic_vector(3 downto 0) := "0000";
    signal cuenta, marca1, marca2 : integer range 0 to 6000 := 0;
    signal iniciar, cancelar : std_logic;
begin
    iniciar <= '1' when modo_ajuste='1' and permiso='1' and pagina=7 and
                        aumentar='1' and duty(velocidad)>0 else '0';
    cancelar <= '1' when modo_ajuste='0' or permiso='0' or pagina/=7 or
                         disminuir='1' or reinicio_operativo='1' else '0';
    -- PROCESO 1: estado y datos. Un solo escritor por tabla.
    process(reloj)
        variable idx : integer;
    begin
        if rising_edge(reloj) then
            if reinicio_sesion='1' then
                estado<=ESPERA; duty<=(others=>0); t1<=(others=>0); t2<=(others=>0);
                fin<=(others=>0); pos<=(others=>1500); avance<=(others=>30);
                tiempos_validos<="0000"; posiciones_validas<="0000";
                cuenta<=0; marca1<=0; marca2<=0;
            else
                estado<=siguiente;
                if estado=ESPERA and iniciar='1' and cancelar='0' then
                    cuenta<=0; marca1<=0; marca2<=0; tiempos_validos(velocidad)<='0';
                elsif estado=MIDE_SERVO1 or estado=MIDE_SERVO2 or estado=MIDE_SALIDA then
                    if tick='1' and cuenta<6000 then cuenta<=cuenta+1; end if;
                    if aumentar='1' and cancelar='0' then
                        if estado=MIDE_SERVO1 then marca1<=cuenta;
                        elsif estado=MIDE_SERVO2 then marca2<=cuenta;
                        elsif cuenta>marca2 and marca2>marca1 and
                              marca1>avance(0) and marca2>avance(1) and cuenta<6000 then
                            t1(velocidad)<=marca1; t2(velocidad)<=marca2;
                            fin(velocidad)<=cuenta; tiempos_validos(velocidad)<='1';
                        end if;
                    end if;
                end if;
                if modo_ajuste='1' and reinicio_operativo='0' and estado=ESPERA then
                    if pagina=0 and (aumentar='1' or disminuir='1') then
                        tiempos_validos(velocidad)<='0';
                        if aumentar='1' and duty(velocidad)<=95 then duty(velocidad)<=duty(velocidad)+5;
                        elsif disminuir='1' and duty(velocidad)>=5 then duty(velocidad)<=duty(velocidad)-5; end if;
                    elsif pagina>=1 and pagina<=4 and (aumentar='1' or disminuir='1') then
                        idx:=pagina-1; posiciones_validas(idx)<='1'; tiempos_validos<="0000";
                        if aumentar='1' and pos(idx)<=1975 then pos(idx)<=pos(idx)+25;
                        elsif disminuir='1' and pos(idx)>=1025 then pos(idx)<=pos(idx)-25; end if;
                    elsif (pagina=5 or pagina=6) and (aumentar='1' or disminuir='1') then
                        idx:=pagina-5; tiempos_validos<="0000";
                        if aumentar='1' and avance(idx)<=95 then avance(idx)<=avance(idx)+5;
                        elsif disminuir='1' and avance(idx)>=10 then avance(idx)<=avance(idx)-5; end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    -- PROCESO 2: transiciones del cronometro de calibracion.
    process(estado,iniciar,cancelar,cuenta,aumentar,marca1,marca2,avance)
    begin
        siguiente<=estado;
        if cancelar='1' then siguiente<=ESPERA;
        else
            case estado is
                when ESPERA => if iniciar='1' then siguiente<=MIDE_SERVO1; end if;
                when MIDE_SERVO1 =>
                    if cuenta=6000 then siguiente<=FALLO_AJUSTE;
                    elsif aumentar='1' then
                        if cuenta>avance(0) then siguiente<=MIDE_SERVO2;
                        else siguiente<=FALLO_AJUSTE; end if;
                    end if;
                when MIDE_SERVO2 =>
                    if cuenta=6000 then siguiente<=FALLO_AJUSTE;
                    elsif aumentar='1' then
                        if cuenta>marca1 and cuenta>avance(1) then siguiente<=MIDE_SALIDA;
                        else siguiente<=FALLO_AJUSTE; end if;
                    end if;
                when MIDE_SALIDA =>
                    if cuenta=6000 then siguiente<=FALLO_AJUSTE;
                    elsif aumentar='1' then
                        if cuenta>marca2 then siguiente<=ESPERA; else siguiente<=FALLO_AJUSTE; end if;
                    end if;
                when FALLO_AJUSTE => null;
            end case;
        end if;
    end process;
    -- PROCESO 3: salidas de prueba; ninguna escribe conteos ni historial.
    process(estado,modo_ajuste,permiso,pagina,cuenta,duty,velocidad,pos,avance,t1,t2,fin)
    begin
        motor_prueba<='0'; error_ajuste<='0'; etapa<="0000"; valor<=0;
        if modo_ajuste='1' and permiso='1' then
            if pagina=0 or estado=MIDE_SERVO1 or estado=MIDE_SERVO2 or estado=MIDE_SALIDA then motor_prueba<='1'; end if;
        end if;
        case estado is
            when MIDE_SERVO1=>etapa<="0001";
            when MIDE_SERVO2=>etapa<="0010";
            when MIDE_SALIDA=>etapa<="0011";
            when FALLO_AJUSTE=>etapa<="1111"; error_ajuste<='1';
            when others=>null;
        end case;
        case pagina is
            when 0=>valor<=duty(velocidad);
            when 1 to 4=>valor<=pos(pagina-1);
            when 5 to 6=>valor<=avance(pagina-5)*10; -- ms
            when 7=>valor<=cuenta; -- centesimas
            when 12=>valor<=t1(velocidad);
            when 13=>valor<=t2(velocidad);
            when 14=>valor<=fin(velocidad);
            when others=>null;
        end case;
    end process;
    porcentaje<=duty(velocidad);
    reposo1<=pos(0); desvio1<=pos(1); reposo2<=pos(2); desvio2<=pos(3);
    adelanto1<=avance(0); adelanto2<=avance(1);
    llegada1<=t1(velocidad); llegada2<=t2(velocidad); salida_cinta<=fin(velocidad);
    posiciones1<=posiciones_validas(0); posiciones2<=posiciones_validas(2);
    listo<='1' when tiempos_validos(velocidad)='1' and posiciones_validas="1111" and
                   pos(0)/=pos(1) and pos(2)/=pos(3) and duty(velocidad)>0 else '0';
end;
```

## SystemAlfa/Hardware_Sensores/base_tiempo_fisica.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
-- Un pulso de reloj cada 10 ms. Todas las FSM usan CLOCK_50, sin relojes nuevos.
entity base_tiempo_fisica is
    generic (CICLOS_TICK : positive := 500000);
    port (reloj, reinicio : in std_logic; tick : out std_logic);
end;
architecture rtl of base_tiempo_fisica is
    signal cuenta : integer range 0 to CICLOS_TICK-1 := 0;
begin
    process(reloj, reinicio)
    begin
        if reinicio='1' then cuenta<=0; tick<='0';
        elsif rising_edge(reloj) then
            tick<='0';
            if cuenta=CICLOS_TICK-1 then cuenta<=0; tick<='1';
            else cuenta<=cuenta+1; end if;
        end if;
    end process;
end;
```

## SystemAlfa/Hardware_Sensores/control_clasificacion_fisica.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity control_clasificacion_fisica is
    generic (PULSO_CORE_TICKS:positive:=3; RETORNO_TICKS:positive:=50;
             ATASCO_TICKS:positive:=500; CATEGORIA_SERVO1:positive:=1; CATEGORIA_SERVO2:positive:=2);
    port (reloj,reinicio,tick,marcha,calibrado:in std_logic;
          pulso_pieza,presencia:in std_logic;
          lectura_lista,lectura_valida,lectura_tamano:in std_logic;
          lectura_color:in std_logic_vector(1 downto 0);
          evento_core:in std_logic; categoria_core:in std_logic_vector(3 downto 0);
          llegada1,llegada2,salida_cinta:in integer range 0 to 6000;
          adelanto1,adelanto2:in integer range 5 to 100;
          iniciar_lectura,presencia_core_n:out std_logic;
          color_core:out std_logic_vector(1 downto 0);tamano_core:out std_logic;
          motor,abrir1,abrir2,ocupado,alarma:out std_logic;
          categoria:out std_logic_vector(3 downto 0); codigo_error:out std_logic_vector(3 downto 0));
end;
architecture fsm_tres_procesos of control_clasificacion_fisica is
    type tipo_estado is (DESARMADO,ESPERA_PIEZA,ORDENAR_LECTURA,LEER,PREPARAR_EVENTO,
                         ENVIAR_EVENTO,CONFIRMAR_REGISTRO,RECORRIDO,RETORNO,LIBERAR,FALLO);
    signal estado,siguiente:tipo_estado:=DESARMADO;
    signal cuenta:integer range 0 to 6000:=0;
    signal color_reg:std_logic_vector(1 downto 0):="00";
    signal tamano_reg,valida_reg,confirmada:std_logic:='0';
    signal categoria_reg:std_logic_vector(3 downto 0):="0000";
    signal error_reg,error_siguiente:std_logic_vector(3 downto 0):="0000";
begin
    -- PROCESO 1: estado y captura de datos. La categoria no procede del menu.
    process(reloj,reinicio)
    begin
        if reinicio='1' then
            estado<=DESARMADO;cuenta<=0;color_reg<="00";tamano_reg<='0';
            valida_reg<='0';confirmada<='0';categoria_reg<="0000";error_reg<="0000";
        elsif rising_edge(reloj) then
            estado<=siguiente;error_reg<=error_siguiente;
            if estado/=siguiente then cuenta<=0;
            elsif tick='1' and cuenta<6000 then cuenta<=cuenta+1;end if;
            if estado=ESPERA_PIEZA then confirmada<='0';
            elsif estado=LEER and lectura_lista='1' then
                valida_reg<=lectura_valida;tamano_reg<=lectura_tamano;
                if lectura_valida='1' then color_reg<=lectura_color;else color_reg<="00";end if;
            end if;
            if estado=ENVIAR_EVENTO or estado=CONFIRMAR_REGISTRO then
                if evento_core='1' then confirmada<='1';categoria_reg<=categoria_core;end if;
            end if;
        end if;
    end process;
    -- PROCESO 2: una pieza por recorrido; una parada cancela el recorrido.
    process(estado,marcha,calibrado,pulso_pieza,presencia,lectura_lista,cuenta,
            valida_reg,confirmada,evento_core,salida_cinta,error_reg)
    begin
        siguiente<=estado;error_siguiente<=error_reg;
        case estado is
            when DESARMADO=>
                if marcha='1' and calibrado='1' and presencia='0' then siguiente<=ESPERA_PIEZA;end if;
            when ESPERA_PIEZA=>
                if marcha='0' or calibrado='0' then siguiente<=DESARMADO;
                elsif pulso_pieza='1' then siguiente<=ORDENAR_LECTURA;end if;
            when ORDENAR_LECTURA=>siguiente<=LEER;
            when LEER=>
                if presencia='0' then siguiente<=FALLO;error_siguiente<="0101";
                elsif lectura_lista='1' then siguiente<=PREPARAR_EVENTO;
                elsif cuenta>=200 then siguiente<=FALLO;error_siguiente<="0001";end if;
            when PREPARAR_EVENTO=>siguiente<=ENVIAR_EVENTO;
            when ENVIAR_EVENTO=>
                if cuenta>=PULSO_CORE_TICKS then
                    if valida_reg='0' then siguiente<=FALLO;error_siguiente<="0001";
                    else siguiente<=CONFIRMAR_REGISTRO;end if;
                end if;
            when CONFIRMAR_REGISTRO=>
                if confirmada='1' or evento_core='1' then siguiente<=RECORRIDO;
                elsif cuenta>=10 then siguiente<=FALLO;error_siguiente<="0100";end if;
            when RECORRIDO=>
                if presencia='1' and cuenta>=ATASCO_TICKS then siguiente<=FALLO;error_siguiente<="0011";
                elsif cuenta>=salida_cinta then siguiente<=RETORNO;end if;
            when RETORNO=>if cuenta>=RETORNO_TICKS then siguiente<=LIBERAR;end if;
            when LIBERAR=>
                if presencia='1' then siguiente<=FALLO;error_siguiente<="0011";
                elsif cuenta>=2 then siguiente<=ESPERA_PIEZA;end if;
            when FALLO=>null;
        end case;
        if estado/=DESARMADO and estado/=ESPERA_PIEZA and estado/=FALLO then
            if marcha='0' and not (estado=ENVIAR_EVENTO and valida_reg='0') then
                siguiente<=FALLO;error_siguiente<="0110";
            end if;
            if pulso_pieza='1' then siguiente<=FALLO;error_siguiente<="0010";end if;
        end if;
    end process;
    -- PROCESO 3: detener durante la captura y durante el retorno del servo.
    process(estado,cuenta,categoria_reg,llegada1,llegada2,adelanto1,adelanto2,marcha,calibrado)
    begin
        iniciar_lectura<='0';presencia_core_n<='1';motor<='0';abrir1<='0';abrir2<='0';
        ocupado<='1';alarma<='0';
        case estado is
            when DESARMADO=>ocupado<='0';
            when ESPERA_PIEZA=>ocupado<='0';motor<=marcha and calibrado;
            when ORDENAR_LECTURA=>iniciar_lectura<='1';
            when ENVIAR_EVENTO=>presencia_core_n<='0';
            when RECORRIDO=>
                motor<=marcha and calibrado;
                if to_integer(unsigned(categoria_reg))=CATEGORIA_SERVO1 and cuenta>=llegada1-adelanto1 then abrir1<='1';end if;
                if to_integer(unsigned(categoria_reg))=CATEGORIA_SERVO2 and cuenta>=llegada2-adelanto2 then abrir2<='1';end if;
            when FALLO=>alarma<='1';
            when others=>null;
        end case;
    end process;
    color_core<=color_reg;tamano_core<=tamano_reg;categoria<=categoria_reg;codigo_error<=error_reg;
end;
```

## SystemAlfa/Hardware_Sensores/control_motor_l298n.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
-- EN se conecta a ENA y ENB; IN1 a IN1/IN3; IN2 a IN2/IN4.
-- Un motor por canal. El PWM controla tension media, no mide RPM.
entity control_motor_l298n is
    generic (CICLOS_PERIODO : positive := 5000); -- 10 kHz con 50 MHz
    port (reloj, reinicio, habilitar : in std_logic;
          porcentaje : in integer range 0 to 100;
          en_pwm, in1, in2 : out std_logic);
end;
architecture rtl of control_motor_l298n is
    signal cuenta : integer range 0 to CICLOS_PERIODO-1 := 0;
    signal limite : integer range 0 to CICLOS_PERIODO := 0;
begin
    assert CICLOS_PERIODO mod 100=0 report "Periodo PWM debe ser multiplo de 100" severity failure;
    process(reloj, reinicio)
    begin
        if reinicio='1' then cuenta<=0; limite<=0;
        elsif rising_edge(reloj) then
            if habilitar='0' then cuenta<=0; limite<=0;
            elsif cuenta=CICLOS_PERIODO-1 then cuenta<=0;
            else cuenta<=cuenta+1; end if;
            if habilitar='1' and cuenta=0 then limite<=porcentaje*(CICLOS_PERIODO/100); end if;
        end if;
    end process;
    en_pwm <= '1' when habilitar='1' and reinicio='0' and cuenta<limite else '0';
    in1 <= habilitar and not reinicio;
    in2 <= '0';
end;
```

## SystemAlfa/Hardware_Sensores/entrada_presencia_v183.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

-- Adaptador del sensor infrarrojo V183 implementado como FSM Moore.
--
-- Estados:
--   INICIALIZAR          : espera que el sensor quede libre despues del reset.
--   SIN_PIEZA            : espera una nueva deteccion.
--   CONFIRMAR_PRESENCIA  : filtra la aparicion de una pieza.
--   GENERAR_PULSO        : genera un pulso de un ciclo por pieza.
--   CON_PIEZA            : mantiene presencia_activa mientras la pieza esta presente.
--   CONFIRMAR_RETIRO     : filtra la retirada de la pieza.
--
-- La salida presencia_activa usa logica positiva:
--   1 = hay pieza
--   0 = no hay pieza
entity entrada_presencia_v183 is
    generic (
        CICLOS_ESTABLES : positive := 250000;
        ACTIVO_BAJO     : boolean  := true
    );
    port (
        reloj            : in  std_logic;
        reinicio         : in  std_logic;
        sensor_entrada   : in  std_logic;
        presencia_activa : out std_logic;
        pulso_pieza      : out std_logic
    );
end entity entrada_presencia_v183;

architecture fsm_tres_procesos of entrada_presencia_v183 is

    type tipo_estado is (
        INICIALIZAR,
        SIN_PIEZA,
        CONFIRMAR_PRESENCIA,
        GENERAR_PULSO,
        CON_PIEZA,
        CONFIRMAR_RETIRO
    );

    signal estado_actual    : tipo_estado := INICIALIZAR;
    signal estado_siguiente : tipo_estado := INICIALIZAR;

    signal sensor_normalizado : std_logic;
    signal etapa_1            : std_logic := '0';
    signal etapa_2            : std_logic := '0';
    signal sincronizacion_valida : std_logic_vector(1 downto 0) := "00";

    signal cuenta_estabilidad : integer range 0 to CICLOS_ESTABLES-1 := 0;

begin

    sensor_normalizado <= not sensor_entrada
        when ACTIVO_BAJO
        else sensor_entrada;

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, sincronizacion y contador de filtro
    ------------------------------------------------------------------------
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            estado_actual      <= INICIALIZAR;
            etapa_1            <= '0';
            etapa_2            <= '0';
            sincronizacion_valida <= "00";
            cuenta_estabilidad <= 0;

        elsif rising_edge(reloj) then
            etapa_1 <= sensor_normalizado;
            etapa_2 <= etapa_1;
            sincronizacion_valida <= sincronizacion_valida(0) & '1';

            estado_actual <= estado_siguiente;

            case estado_actual is

                when INICIALIZAR =>
                    -- Tras el reset se exige observar el sensor libre.
                    if sincronizacion_valida(1) = '1' and etapa_2 = '0' then
                        if cuenta_estabilidad < CICLOS_ESTABLES-1 then
                            cuenta_estabilidad <= cuenta_estabilidad + 1;
                        end if;
                    else
                        cuenta_estabilidad <= 0;
                    end if;

                when CONFIRMAR_PRESENCIA =>
                    if etapa_2 = '1' then
                        if cuenta_estabilidad < CICLOS_ESTABLES-1 then
                            cuenta_estabilidad <= cuenta_estabilidad + 1;
                        end if;
                    else
                        cuenta_estabilidad <= 0;
                    end if;

                when CONFIRMAR_RETIRO =>
                    if etapa_2 = '0' then
                        if cuenta_estabilidad < CICLOS_ESTABLES-1 then
                            cuenta_estabilidad <= cuenta_estabilidad + 1;
                        end if;
                    else
                        cuenta_estabilidad <= 0;
                    end if;

                when others =>
                    cuenta_estabilidad <= 0;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(estado_actual, etapa_2, cuenta_estabilidad, sincronizacion_valida)
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when INICIALIZAR =>
                if sincronizacion_valida(1) = '1' and etapa_2 = '0' and
                   cuenta_estabilidad = CICLOS_ESTABLES-1 then
                    estado_siguiente <= SIN_PIEZA;
                end if;

            when SIN_PIEZA =>
                if etapa_2 = '1' then
                    estado_siguiente <= CONFIRMAR_PRESENCIA;
                end if;

            when CONFIRMAR_PRESENCIA =>
                if etapa_2 = '0' then
                    estado_siguiente <= SIN_PIEZA;
                elsif cuenta_estabilidad = CICLOS_ESTABLES-1 then
                    estado_siguiente <= GENERAR_PULSO;
                end if;

            when GENERAR_PULSO =>
                estado_siguiente <= CON_PIEZA;

            when CON_PIEZA =>
                if etapa_2 = '0' then
                    estado_siguiente <= CONFIRMAR_RETIRO;
                end if;

            when CONFIRMAR_RETIRO =>
                if etapa_2 = '1' then
                    estado_siguiente <= CON_PIEZA;
                elsif cuenta_estabilidad = CICLOS_ESTABLES-1 then
                    estado_siguiente <= SIN_PIEZA;
                end if;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        presencia_activa <= '0';
        pulso_pieza      <= '0';

        case estado_actual is

            when GENERAR_PULSO =>
                presencia_activa <= '1';
                pulso_pieza      <= '1';

            when CON_PIEZA | CONFIRMAR_RETIRO =>
                presencia_activa <= '1';

            when others =>
                null;

        end case;
    end process;

end architecture fsm_tres_procesos;
```

## SystemAlfa/Hardware_Sensores/hardware.sdc - NUEVO

```tcl
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_clock_uncertainty
# Entradas asincronas, sincronizadas en sus lectores.
set_false_path -from [get_ports {V183_OUT HCSR04_ECHO TCS_OUT BUTTON[*] SW[*]}]
set_output_delay -clock CLOCK_50 -max 0 [all_outputs]
set_output_delay -clock CLOCK_50 -min 0 [all_outputs]
```

## SystemAlfa/Hardware_Sensores/lector_hcsr04.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Lector del HC-SR04 implementado como FSM Moore de tres procesos.
--
-- Estados:
--   ESPERA        : espera la orden iniciar.
--   DISPARO       : mantiene TRIG en alto durante 10 us.
--   ESPERAR_ECHO  : espera el flanco de subida de ECHO.
--   MEDIR_ECHO    : cuenta el tiempo que ECHO permanece en alto.
--   CALCULAR      : convierte el tiempo a distancia y clasifica el tamano.
--   FINALIZAR     : genera medicion_lista durante un ciclo.
entity lector_hcsr04 is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        UMBRAL_GRANDE_CM    : positive := 25;
        UMBRAL_PEQUENA_CM   : positive := 30;
        TIEMPO_MAXIMO_US    : positive := 40000;
        INTERVALO_MINIMO_US : positive := 61000;
        USAR_VENTANAS_MM : boolean := false;
        GRANDE_MIN_MM : positive := 20;
        GRANDE_MAX_MM : positive := 28;
        PEQUENA_MIN_MM : positive := 32;
        PEQUENA_MAX_MM : positive := 48
    );
    port (
        reloj           : in  std_logic;
        reinicio        : in  std_logic;
        iniciar         : in  std_logic;
        echo_entrada    : in  std_logic;

        trigger_salida  : out std_logic;
        distancia_cm    : out std_logic_vector(7 downto 0);
        tamano          : out std_logic;
        medicion_lista  : out std_logic;
        medicion_valida : out std_logic;
        ocupado         : out std_logic
    );
end entity lector_hcsr04;

architecture fsm_tres_procesos of lector_hcsr04 is

    constant CICLOS_POR_US : positive := FRECUENCIA_RELOJ_HZ / 1000000;
    constant CICLOS_TRIGGER : positive := 10 * CICLOS_POR_US;
    constant CICLOS_TIMEOUT : positive := TIEMPO_MAXIMO_US * CICLOS_POR_US;
    constant CICLOS_POR_CM  : positive := 58 * CICLOS_POR_US;

    constant CICLOS_INTERVALO : positive := INTERVALO_MINIMO_US * CICLOS_POR_US;

    type tipo_estado is (
        ESPERA,
        DISPARO,
        ESPERAR_ECHO,
        MEDIR_ECHO,
        CALCULAR,
        FINALIZAR
    );

    signal estado_actual    : tipo_estado := ESPERA;
    signal estado_siguiente : tipo_estado := ESPERA;

    signal inicio_anterior : std_logic := '0';
    signal cuenta_intervalo : integer range 0 to CICLOS_INTERVALO := CICLOS_INTERVALO;
    signal echo_1 : std_logic := '0';
    signal echo_2 : std_logic := '0';

    signal cuenta_trigger : integer range 0 to CICLOS_TRIGGER-1 := 0;
    signal cuenta_timeout : integer range 0 to CICLOS_TIMEOUT-1 := 0;
    signal cuenta_echo    : integer range 0 to CICLOS_TIMEOUT-1 := 0;
    signal echo_capturado : integer range 0 to CICLOS_TIMEOUT-1 := 0;
    -- Division por restas: un centimetro por ciclo, sin un divisor grande.
    signal resto_echo : integer range 0 to CICLOS_TIMEOUT+CICLOS_POR_CM := 0;
    signal distancia_calculo : integer range 0 to 255 := 0;

    signal distancia_reg : integer range 0 to 255 := 0;
    signal tamano_reg    : std_logic := '0';
    signal valida_reg    : std_logic := '0';

begin
    assert FRECUENCIA_RELOJ_HZ >= 1000000 and FRECUENCIA_RELOJ_HZ mod 1000000 = 0
        report "Usar un reloj multiplo entero de 1 MHz" severity failure;
    assert UMBRAL_GRANDE_CM < UMBRAL_PEQUENA_CM and UMBRAL_PEQUENA_CM <= 255
        report "Umbrales de tamano incorrectos" severity failure;

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, sincronizacion y registros de datos
    ------------------------------------------------------------------------
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            estado_actual    <= ESPERA;
            inicio_anterior <= '0';
            cuenta_intervalo <= CICLOS_INTERVALO;
            echo_1           <= '0';
            echo_2           <= '0';
            cuenta_trigger   <= 0;
            cuenta_timeout   <= 0;
            cuenta_echo      <= 0;
            echo_capturado   <= 0;
            resto_echo <= 0;
            distancia_calculo <= 0;
            distancia_reg    <= 0;
            tamano_reg       <= '0';
            valida_reg       <= '0';

        elsif rising_edge(reloj) then
            inicio_anterior <= iniciar;
            if cuenta_intervalo < CICLOS_INTERVALO then
                cuenta_intervalo <= cuenta_intervalo + 1;
            end if;
            echo_1 <= echo_entrada;
            echo_2 <= echo_1;

            estado_actual <= estado_siguiente;

            case estado_actual is

                when ESPERA =>
                    cuenta_trigger <= 0;
                    cuenta_timeout <= 0;
                    cuenta_echo    <= 0;

                    if iniciar = '1' and inicio_anterior = '0' and
                       cuenta_intervalo = CICLOS_INTERVALO then
                        cuenta_intervalo <= 0;
                        distancia_reg  <= 0;
                        tamano_reg     <= '0';
                        valida_reg     <= '0';
                        echo_capturado <= 0;
                        resto_echo <= 0;
                        distancia_calculo <= 0;
                    end if;

                when DISPARO =>
                    if cuenta_trigger = CICLOS_TRIGGER-1 then
                        cuenta_trigger <= 0;
                    else
                        cuenta_trigger <= cuenta_trigger + 1;
                    end if;

                when ESPERAR_ECHO =>
                    if echo_2 = '1' then
                        cuenta_timeout <= 0;
                        cuenta_echo    <= 1; -- Incluye el primer ciclo alto observado.

                    elsif cuenta_timeout = CICLOS_TIMEOUT-1 then
                        cuenta_timeout <= 0;
                        distancia_reg  <= 0;
                        tamano_reg     <= '0';
                        valida_reg     <= '0';

                    else
                        cuenta_timeout <= cuenta_timeout + 1;
                    end if;

                when MEDIR_ECHO =>
                    if echo_2 = '1' then
                        if cuenta_echo = CICLOS_TIMEOUT-1 then
                            cuenta_echo   <= 0;
                            distancia_reg <= 0;
                            tamano_reg    <= '0';
                            valida_reg    <= '0';
                        else
                            cuenta_echo <= cuenta_echo + 1;
                        end if;
                    else
                        echo_capturado <= cuenta_echo;
                        resto_echo <= cuenta_echo + CICLOS_POR_CM/2;
                        cuenta_echo    <= 0;
                    end if;

                when CALCULAR =>
                    if resto_echo >= CICLOS_POR_CM and distancia_calculo < 255 then
                        resto_echo <= resto_echo - CICLOS_POR_CM;
                        distancia_calculo <= distancia_calculo + 1;
                    else
                        distancia_reg <= distancia_calculo;

                    if USAR_VENTANAS_MM then
                        valida_reg <= '0'; tamano_reg <= '0';
                        if echo_capturado >= (GRANDE_MIN_MM*CICLOS_POR_CM+9)/10 and
                           echo_capturado <= (GRANDE_MAX_MM*CICLOS_POR_CM)/10 then
                            valida_reg <= '1'; tamano_reg <= '1';
                        elsif echo_capturado >= (PEQUENA_MIN_MM*CICLOS_POR_CM+9)/10 and
                              echo_capturado <= (PEQUENA_MAX_MM*CICLOS_POR_CM)/10 then
                            valida_reg <= '1';
                        end if;
                    elsif echo_capturado >= 2*CICLOS_POR_CM and
                       echo_capturado <= UMBRAL_GRANDE_CM*CICLOS_POR_CM then
                        tamano_reg <= '1';
                        valida_reg <= '1';

                    elsif echo_capturado >= UMBRAL_PEQUENA_CM*CICLOS_POR_CM and
                          echo_capturado <= 255*CICLOS_POR_CM then
                        tamano_reg <= '0';
                        valida_reg <= '1';

                    else
                        tamano_reg <= '0';
                        valida_reg <= '0';
                    end if;
                    end if;

                when FINALIZAR =>
                    null;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(
        estado_actual,
        iniciar,
        echo_2,
        cuenta_trigger,
        cuenta_timeout,
        cuenta_echo, inicio_anterior, cuenta_intervalo,
        resto_echo, distancia_calculo
    )
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when ESPERA =>
                if iniciar = '1' and inicio_anterior = '0' and
                   cuenta_intervalo = CICLOS_INTERVALO then
                    if echo_2 = '1' then
                        estado_siguiente <= FINALIZAR; -- ECHO atascado antes del disparo.
                    else
                        estado_siguiente <= DISPARO;
                    end if;
                end if;

            when DISPARO =>
                if cuenta_trigger = CICLOS_TRIGGER-1 then
                    estado_siguiente <= ESPERAR_ECHO;
                end if;

            when ESPERAR_ECHO =>
                if echo_2 = '1' then
                    estado_siguiente <= MEDIR_ECHO;
                elsif cuenta_timeout = CICLOS_TIMEOUT-1 then
                    estado_siguiente <= FINALIZAR;
                end if;

            when MEDIR_ECHO =>
                if echo_2 = '0' then
                    estado_siguiente <= CALCULAR;
                elsif cuenta_echo = CICLOS_TIMEOUT-1 then
                    estado_siguiente <= FINALIZAR;
                end if;

            when CALCULAR =>
                if resto_echo < CICLOS_POR_CM or distancia_calculo = 255 then
                    estado_siguiente <= FINALIZAR;
                end if;

            when FINALIZAR =>
                estado_siguiente <= ESPERA;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        trigger_salida <= '0';
        medicion_lista <= '0';
        ocupado        <= '1';

        case estado_actual is

            when ESPERA =>
                ocupado <= '0';

            when DISPARO =>
                trigger_salida <= '1';

            when FINALIZAR =>
                ocupado        <= '0';
                medicion_lista <= '1';

            when others =>
                null;

        end case;
    end process;

    distancia_cm    <= std_logic_vector(to_unsigned(distancia_reg, 8));
    tamano          <= tamano_reg;
    medicion_valida <= valida_reg;

end architecture fsm_tres_procesos;
```

## SystemAlfa/Hardware_Sensores/lector_tcs3200.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Lector del TCS3200/GY-31 implementado como FSM Moore de tres procesos.
--
-- S0=1 y S1=0 seleccionan escala de frecuencia del 20 %.
-- La FSM asienta y mide los filtros rojo, verde y azul; despues clasifica.
-- La referencia negra quita el fondo; las ganancias compensan cada canal
-- usando la diferencia medida entre blanco y negro.
entity lector_tcs3200 is
    generic (
        VENTANA_CICLOS      : positive := 500000;
        ASENTAMIENTO_CICLOS : positive := 5000;
        CLASIFICACION_HABILITADA : boolean := false;
        BASE_NEGRA_ROJO     : natural  := 26;
        BASE_NEGRA_VERDE    : natural  := 26;
        BASE_NEGRA_AZUL     : natural  := 34;
        GANANCIA_ROJO_Q5    : positive := 85;
        GANANCIA_VERDE_Q5   : positive := 109;
        GANANCIA_AZUL_Q5    : positive := 115;
        SENAL_MINIMA        : positive := 10
    );
    port (
        reloj           : in  std_logic;
        reinicio        : in  std_logic;
        iniciar         : in  std_logic;
        tcs_out         : in  std_logic;

        tcs_s0          : out std_logic;
        tcs_s1          : out std_logic;
        tcs_s2          : out std_logic;
        tcs_s3          : out std_logic;

        color           : out std_logic_vector(1 downto 0);
        valor_rojo      : out std_logic_vector(15 downto 0);
        valor_verde     : out std_logic_vector(15 downto 0);
        valor_azul      : out std_logic_vector(15 downto 0);
        medicion_lista  : out std_logic;
        medicion_valida : out std_logic;
        ocupado         : out std_logic
    );
end entity lector_tcs3200;

architecture fsm_tres_procesos of lector_tcs3200 is

    type tipo_estado is (
        ESPERA,
        ASENTAR_ROJO,
        MEDIR_ROJO,
        ASENTAR_VERDE,
        MEDIR_VERDE,
        ASENTAR_AZUL,
        MEDIR_AZUL,
        CLASIFICAR,
        FINALIZAR
    );

    signal estado_actual    : tipo_estado := ESPERA;
    signal estado_siguiente : tipo_estado := ESPERA;

    signal inicio_anterior : std_logic := '0';
    signal out_1        : std_logic := '0';
    signal out_2        : std_logic := '0';
    signal out_anterior : std_logic := '0';
    signal flanco_subida: std_logic;

    signal cuenta_ventana      : integer range 0 to VENTANA_CICLOS-1 := 0;
    signal cuenta_asentamiento : integer range 0 to ASENTAMIENTO_CICLOS-1 := 0;
    signal cuenta_pulsos       : integer range 0 to 65535 := 0;

    signal rojo_reg  : integer range 0 to 65535 := 0;
    signal verde_reg : integer range 0 to 65535 := 0;
    signal azul_reg  : integer range 0 to 65535 := 0;

    signal color_reg  : std_logic_vector(1 downto 0) := "00";
    signal valida_reg : std_logic := '0';

begin
    flanco_subida <= out_2 and not out_anterior;

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, sincronizacion, contadores y datos
    ------------------------------------------------------------------------
    process(reloj, reinicio)
        variable pulsos_finales : integer;
        variable diferencia : integer range 0 to 65535;
        variable producto : integer range 0 to 8000000;
        variable puntaje_rojo : integer range 0 to 300000;
        variable puntaje_verde : integer range 0 to 300000;
        variable puntaje_azul : integer range 0 to 300000;
    begin
        if reinicio = '1' then
            estado_actual        <= ESPERA;
            inicio_anterior <= '0';
            out_1                <= '0';
            out_2                <= '0';
            out_anterior         <= '0';
            cuenta_ventana       <= 0;
            cuenta_asentamiento  <= 0;
            cuenta_pulsos        <= 0;
            rojo_reg             <= 0;
            verde_reg            <= 0;
            azul_reg             <= 0;
            color_reg            <= "00";
            valida_reg           <= '0';

        elsif rising_edge(reloj) then
            inicio_anterior <= iniciar;
            out_1        <= tcs_out;
            out_2        <= out_1;
            out_anterior <= out_2;

            estado_actual <= estado_siguiente;

            case estado_actual is

                when ESPERA =>
                    cuenta_ventana      <= 0;
                    cuenta_asentamiento <= 0;
                    cuenta_pulsos       <= 0;

                    if iniciar = '1' and inicio_anterior = '0' then
                        rojo_reg   <= 0;
                        verde_reg  <= 0;
                        azul_reg   <= 0;
                        color_reg  <= "00";
                        valida_reg <= '0';
                    end if;

                when ASENTAR_ROJO | ASENTAR_VERDE | ASENTAR_AZUL =>
                    cuenta_pulsos  <= 0;
                    cuenta_ventana <= 0;

                    if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                        cuenta_asentamiento <= 0;
                    else
                        cuenta_asentamiento <= cuenta_asentamiento + 1;
                    end if;

                when MEDIR_ROJO =>
                    pulsos_finales := cuenta_pulsos;

                    if flanco_subida = '1' and pulsos_finales < 65535 then
                        pulsos_finales := pulsos_finales + 1;
                    end if;

                    if cuenta_ventana = VENTANA_CICLOS-1 then
                        rojo_reg       <= pulsos_finales;
                        cuenta_pulsos  <= 0;
                        cuenta_ventana <= 0;
                    else
                        cuenta_pulsos  <= pulsos_finales;
                        cuenta_ventana <= cuenta_ventana + 1;
                    end if;

                when MEDIR_VERDE =>
                    pulsos_finales := cuenta_pulsos;

                    if flanco_subida = '1' and pulsos_finales < 65535 then
                        pulsos_finales := pulsos_finales + 1;
                    end if;

                    if cuenta_ventana = VENTANA_CICLOS-1 then
                        verde_reg      <= pulsos_finales;
                        cuenta_pulsos  <= 0;
                        cuenta_ventana <= 0;
                    else
                        cuenta_pulsos  <= pulsos_finales;
                        cuenta_ventana <= cuenta_ventana + 1;
                    end if;

                when MEDIR_AZUL =>
                    pulsos_finales := cuenta_pulsos;

                    if flanco_subida = '1' and pulsos_finales < 65535 then
                        pulsos_finales := pulsos_finales + 1;
                    end if;

                    if cuenta_ventana = VENTANA_CICLOS-1 then
                        azul_reg       <= pulsos_finales;
                        cuenta_pulsos  <= 0;
                        cuenta_ventana <= 0;
                    else
                        cuenta_pulsos  <= pulsos_finales;
                        cuenta_ventana <= cuenta_ventana + 1;
                    end if;

                when CLASIFICAR =>
                    color_reg  <= "00";
                    valida_reg <= '0';

                    if CLASIFICACION_HABILITADA and
                       rojo_reg < 65535 and verde_reg < 65535 and azul_reg < 65535 then
                        -- Resta el nivel negro y compensa la sensibilidad
                        -- distinta de cada canal con la referencia blanca.
                        if rojo_reg > BASE_NEGRA_ROJO then
                            diferencia := rojo_reg - BASE_NEGRA_ROJO;
                        else
                            diferencia := 0;
                        end if;
                        producto := diferencia * GANANCIA_ROJO_Q5 + 16;
                        puntaje_rojo := producto / 32;

                        if verde_reg > BASE_NEGRA_VERDE then
                            diferencia := verde_reg - BASE_NEGRA_VERDE;
                        else
                            diferencia := 0;
                        end if;
                        producto := diferencia * GANANCIA_VERDE_Q5 + 16;
                        puntaje_verde := producto / 32;

                        if azul_reg > BASE_NEGRA_AZUL then
                            diferencia := azul_reg - BASE_NEGRA_AZUL;
                        else
                            diferencia := 0;
                        end if;
                        producto := diferencia * GANANCIA_AZUL_Q5 + 16;
                        puntaje_azul := producto / 32;

                        -- El canal ganador debe superar al segundo por >20 %.
                        -- El blanco queda equilibrado y se rechaza.
                        if puntaje_rojo >= SENAL_MINIMA and
                           puntaje_rojo * 5 > puntaje_verde * 6 and
                           puntaje_rojo * 5 > puntaje_azul * 6 then
                            color_reg  <= "01";
                            valida_reg <= '1';

                        elsif puntaje_verde >= SENAL_MINIMA and
                              puntaje_verde * 5 > puntaje_rojo * 6 and
                              puntaje_verde * 5 > puntaje_azul * 6 then
                            color_reg  <= "10";
                            valida_reg <= '1';

                        elsif puntaje_azul >= SENAL_MINIMA and
                              puntaje_azul * 5 > puntaje_rojo * 6 and
                              puntaje_azul * 5 > puntaje_verde * 6 then
                            color_reg  <= "11";
                            valida_reg <= '1';
                        end if;

                    end if;

                when FINALIZAR =>
                    null;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(
        estado_actual,
        iniciar,
        cuenta_asentamiento,
        cuenta_ventana, inicio_anterior
    )
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when ESPERA =>
                if iniciar = '1' and inicio_anterior = '0' then
                    estado_siguiente <= ASENTAR_ROJO;
                end if;

            when ASENTAR_ROJO =>
                if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                    estado_siguiente <= MEDIR_ROJO;
                end if;

            when MEDIR_ROJO =>
                if cuenta_ventana = VENTANA_CICLOS-1 then
                    estado_siguiente <= ASENTAR_VERDE;
                end if;

            when ASENTAR_VERDE =>
                if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                    estado_siguiente <= MEDIR_VERDE;
                end if;

            when MEDIR_VERDE =>
                if cuenta_ventana = VENTANA_CICLOS-1 then
                    estado_siguiente <= ASENTAR_AZUL;
                end if;

            when ASENTAR_AZUL =>
                if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                    estado_siguiente <= MEDIR_AZUL;
                end if;

            when MEDIR_AZUL =>
                if cuenta_ventana = VENTANA_CICLOS-1 then
                    estado_siguiente <= CLASIFICAR;
                end if;

            when CLASIFICAR =>
                estado_siguiente <= FINALIZAR;

            when FINALIZAR =>
                estado_siguiente <= ESPERA;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        -- Escala de frecuencia del 20 %.
        tcs_s0 <= '1';
        tcs_s1 <= '0';

        -- Filtro rojo por defecto.
        tcs_s2 <= '0';
        tcs_s3 <= '0';

        medicion_lista <= '0';
        ocupado        <= '1';

        case estado_actual is

            when ESPERA =>
                ocupado <= '0';

            when ASENTAR_VERDE | MEDIR_VERDE =>
                tcs_s2 <= '1';
                tcs_s3 <= '1';

            when ASENTAR_AZUL | MEDIR_AZUL =>
                tcs_s2 <= '0';
                tcs_s3 <= '1';

            when FINALIZAR =>
                ocupado        <= '0';
                medicion_lista <= '1';

            when others =>
                null;

        end case;
    end process;

    color           <= color_reg;
    medicion_valida <= valida_reg;
    valor_rojo      <= std_logic_vector(to_unsigned(rojo_reg, 16));
    valor_verde     <= std_logic_vector(to_unsigned(verde_reg, 16));
    valor_azul      <= std_logic_vector(to_unsigned(azul_reg, 16));

end architecture fsm_tres_procesos;
```

## SystemAlfa/Hardware_Sensores/medicion_coordinada.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
-- Tres intentos como maximo, dos resultados consecutivos iguales.
entity medicion_coordinada is
    generic (ASENTAR_TICKS:positive:=30; PLAZO_TICKS:positive:=40; REINTENTO_TICKS:positive:=10);
    port (reloj, reinicio, tick, iniciar : in std_logic;
          hc_lista,hc_valida,hc_tamano,hc_ocupado : in std_logic;
          tcs_lista,tcs_valida,tcs_ocupado : in std_logic;
          tcs_color : in std_logic_vector(1 downto 0);
          iniciar_hc,iniciar_tcs,lista,valida,ocupado : out std_logic;
          color : out std_logic_vector(1 downto 0); tamano : out std_logic);
end;
architecture fsm_tres_procesos of medicion_coordinada is
    type tipo_estado is (ESPERA,ASENTAR,DISPARAR,ESPERAR_DATOS,EVALUAR,REINTENTAR,FINALIZAR);
    signal estado,siguiente : tipo_estado:=ESPERA;
    signal cuenta:integer range 0 to 1000:=0;
    signal intentos:integer range 0 to 2:=0;
    signal hc_fin,tcs_fin,hv,tv,ht,prev_val,val_reg:std_logic:='0';
    signal tc:std_logic_vector(1 downto 0):="00";
    signal previa,actual,resultado:std_logic_vector(2 downto 0):="000";
    signal coincide:std_logic;
begin
    actual<=tc & ht;
    coincide<='1' when hv='1' and tv='1' and tc/="00" and prev_val='1' and actual=previa else '0';
    -- PROCESO 1.
    process(reloj,reinicio)
    begin
        if reinicio='1' then
            estado<=ESPERA; cuenta<=0; intentos<=0; hc_fin<='0'; tcs_fin<='0';
            hv<='0';tv<='0';ht<='0';tc<="00";prev_val<='0';previa<="000";
            resultado<="000";val_reg<='0';
        elsif rising_edge(reloj) then
            estado<=siguiente;
            if estado/=siguiente then cuenta<=0;
            elsif tick='1' and cuenta<1000 then cuenta<=cuenta+1; end if;
            if estado=ESPERA then
                intentos<=0;prev_val<='0';hc_fin<='0';tcs_fin<='0';
                if iniciar='1' then val_reg<='0';resultado<="000"; end if;
            elsif estado=DISPARAR then hc_fin<='0';tcs_fin<='0';hv<='0';tv<='0';
            elsif estado=ESPERAR_DATOS then
                if hc_lista='1' then hc_fin<='1';hv<=hc_valida;ht<=hc_tamano;end if;
                if tcs_lista='1' then tcs_fin<='1';tv<=tcs_valida;tc<=tcs_color;end if;
            elsif estado=EVALUAR then
                if coincide='1' then resultado<=actual;val_reg<='1';
                else
                    previa<=actual;prev_val<=hv and tv;
                    if intentos<2 then intentos<=intentos+1;end if;
                end if;
            end if;
        end if;
    end process;
    -- PROCESO 2.
    process(estado,iniciar,cuenta,hc_ocupado,tcs_ocupado,hc_fin,tcs_fin,coincide,intentos)
    begin
        siguiente<=estado;
        case estado is
            when ESPERA=>if iniciar='1' then siguiente<=ASENTAR;end if;
            when ASENTAR=>
                if cuenta>=ASENTAR_TICKS and hc_ocupado='0' and tcs_ocupado='0' then siguiente<=DISPARAR;
                elsif cuenta>=ASENTAR_TICKS+PLAZO_TICKS then siguiente<=FINALIZAR;end if;
            when DISPARAR=>siguiente<=ESPERAR_DATOS;
            when ESPERAR_DATOS=>
                if hc_fin='1' and tcs_fin='1' then siguiente<=EVALUAR;
                elsif cuenta>=PLAZO_TICKS then siguiente<=FINALIZAR;end if;
            when EVALUAR=>
                if coincide='1' or intentos=2 then siguiente<=FINALIZAR;
                else siguiente<=REINTENTAR;end if;
            when REINTENTAR=>
                if cuenta>=REINTENTO_TICKS and hc_ocupado='0' and tcs_ocupado='0' then siguiente<=DISPARAR;
                elsif cuenta>=REINTENTO_TICKS+PLAZO_TICKS then siguiente<=FINALIZAR;end if;
            when FINALIZAR=>siguiente<=ESPERA;
        end case;
    end process;
    -- PROCESO 3.
    process(estado)
    begin
        iniciar_hc<='0';iniciar_tcs<='0';lista<='0';ocupado<='1';
        case estado is
            when ESPERA=>ocupado<='0';
            when DISPARAR=>iniciar_hc<='1';iniciar_tcs<='1';
            when FINALIZAR=>lista<='1';
            when others=>null;
        end case;
    end process;
    color<=resultado(2 downto 1);tamano<=resultado(0);valida<=val_reg;
end;
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.qsf - MODIFICADO

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_location_assignment PIN_E11 -to HEX0[0]
set_location_assignment PIN_F11 -to HEX0[1]
set_location_assignment PIN_H12 -to HEX0[2]
set_location_assignment PIN_H13 -to HEX0[3]
set_location_assignment PIN_G12 -to HEX0[4]
set_location_assignment PIN_F12 -to HEX0[5]
set_location_assignment PIN_F13 -to HEX0[6]
set_location_assignment PIN_A13 -to HEX1[0]
set_location_assignment PIN_B13 -to HEX1[1]
set_location_assignment PIN_C13 -to HEX1[2]
set_location_assignment PIN_A14 -to HEX1[3]
set_location_assignment PIN_B14 -to HEX1[4]
set_location_assignment PIN_E14 -to HEX1[5]
set_location_assignment PIN_A15 -to HEX1[6]
set_location_assignment PIN_D15 -to HEX2[0]
set_location_assignment PIN_A16 -to HEX2[1]
set_location_assignment PIN_B16 -to HEX2[2]
set_location_assignment PIN_E15 -to HEX2[3]
set_location_assignment PIN_A17 -to HEX2[4]
set_location_assignment PIN_B17 -to HEX2[5]
set_location_assignment PIN_F14 -to HEX2[6]
set_location_assignment PIN_B18 -to HEX3[0]
set_location_assignment PIN_F15 -to HEX3[1]
set_location_assignment PIN_A19 -to HEX3[2]
set_location_assignment PIN_B19 -to HEX3[3]
set_location_assignment PIN_C19 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_G15 -to HEX3[6]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_HCSR04
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/filtro_boton.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/conversor_decimal_reloj.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/decodificador_7segmentos.vhd
set_global_assignment -name VHDL_FILE ../../lector_hcsr04.vhd
set_global_assignment -name VHDL_FILE Prueba_HCSR04.vhd
set_location_assignment PIN_AA16 -to HCSR04_TRIG
set_location_assignment PIN_AA15 -to HCSR04_ECHO

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HCSR04_TRIG
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HCSR04_ECHO

set_global_assignment -name LAST_QUARTUS_VERSION 13.1
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity Prueba_HCSR04 is
    port (
        CLOCK_50   : in  std_logic;
        BUTTON     : in  std_logic_vector(2 downto 0);
        HCSR04_ECHO: in  std_logic;
        HCSR04_TRIG: out std_logic;
        LEDG       : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0)
    );
end entity Prueba_HCSR04;

architecture estructural of Prueba_HCSR04 is

    signal reinicio       : std_logic;
    signal boton_inicio   : std_logic;
    signal pulso_inicio   : std_logic;

    signal distancia      : std_logic_vector(7 downto 0);
    signal distancia_10   : std_logic_vector(9 downto 0);
    signal tamano         : std_logic;
    signal lista          : std_logic;
    signal valida         : std_logic;
    signal ocupado        : std_logic;
    signal alternador_fin : std_logic := '0';

    signal centenas, decenas, unidades : std_logic_vector(3 downto 0);
    signal segmentos_tamano : std_logic_vector(6 downto 0);
    signal digito_tamano : std_logic_vector(3 downto 0);

begin

    boton_inicio <= not BUTTON(0);
    distancia_10 <= "00" & distancia;
    digito_tamano <= "000" & tamano;

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => CLOCK_50,
            reinicio_bajo => BUTTON(1),
            reinicio_salida => reinicio
        );

    U_BOTON : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => 250000
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            boton_entrada => boton_inicio,
            pulso_salida => pulso_inicio,
            estado_salida => open
        );

    U_HCSR04 : entity work.lector_hcsr04
        generic map (
            FRECUENCIA_RELOJ_HZ => 50000000,
            USAR_VENTANAS_MM => true,
            GRANDE_MIN_MM => 20, GRANDE_MAX_MM => 28,
            PEQUENA_MIN_MM => 32, PEQUENA_MAX_MM => 48,
            TIEMPO_MAXIMO_US => 40000
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            iniciar => pulso_inicio,
            echo_entrada => HCSR04_ECHO,
            trigger_salida => HCSR04_TRIG,
            distancia_cm => distancia,
            tamano => tamano,
            medicion_lista => lista,
            medicion_valida => valida,
            ocupado => ocupado
        );

    process(CLOCK_50, reinicio)
    begin
        if reinicio = '1' then
            alternador_fin <= '0';
        elsif rising_edge(CLOCK_50) then
            if lista = '1' then
                alternador_fin <= not alternador_fin;
            end if;
        end if;
    end process;

    U_DECIMAL : entity work.conversor_decimal_reloj
        port map (
            reloj => CLOCK_50,
            numero_binario => distancia_10,
            centenas => centenas,
            decenas => decenas,
            unidades => unidades
        );

    U_HEX0 : entity work.decodificador_7segmentos
        port map (numero => unidades, segmentos => HEX0);

    U_HEX1 : entity work.decodificador_7segmentos
        port map (numero => decenas, segmentos => HEX1);

    U_HEX2 : entity work.decodificador_7segmentos
        port map (numero => centenas, segmentos => HEX2);

    U_HEX3 : entity work.decodificador_7segmentos
        port map (numero => digito_tamano, segmentos => segmentos_tamano);

    -- Un dato no valido no debe parecer una pieza pequena.
    HEX3 <= segmentos_tamano when valida = '1' else "1111111";

    LEDG(0) <= valida;
    LEDG(1) <= tamano;
    LEDG(2) <= ocupado;
    LEDG(3) <= alternador_fin;
    LEDG(9 downto 4) <= (others => '0');

end architecture estructural;
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.qsf - MODIFICADO

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_location_assignment PIN_E11 -to HEX0[0]
set_location_assignment PIN_F11 -to HEX0[1]
set_location_assignment PIN_H12 -to HEX0[2]
set_location_assignment PIN_H13 -to HEX0[3]
set_location_assignment PIN_G12 -to HEX0[4]
set_location_assignment PIN_F12 -to HEX0[5]
set_location_assignment PIN_F13 -to HEX0[6]
set_location_assignment PIN_A13 -to HEX1[0]
set_location_assignment PIN_B13 -to HEX1[1]
set_location_assignment PIN_C13 -to HEX1[2]
set_location_assignment PIN_A14 -to HEX1[3]
set_location_assignment PIN_B14 -to HEX1[4]
set_location_assignment PIN_E14 -to HEX1[5]
set_location_assignment PIN_A15 -to HEX1[6]
set_location_assignment PIN_D15 -to HEX2[0]
set_location_assignment PIN_A16 -to HEX2[1]
set_location_assignment PIN_B16 -to HEX2[2]
set_location_assignment PIN_E15 -to HEX2[3]
set_location_assignment PIN_A17 -to HEX2[4]
set_location_assignment PIN_B17 -to HEX2[5]
set_location_assignment PIN_F14 -to HEX2[6]
set_location_assignment PIN_B18 -to HEX3[0]
set_location_assignment PIN_F15 -to HEX3[1]
set_location_assignment PIN_A19 -to HEX3[2]
set_location_assignment PIN_B19 -to HEX3[3]
set_location_assignment PIN_C19 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_G15 -to HEX3[6]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_TCS3200
set_location_assignment PIN_J6 -to SW[0]
set_location_assignment PIN_H5 -to SW[1]
set_location_assignment PIN_H6 -to SW[2]
set_location_assignment PIN_G4 -to SW[3]
set_location_assignment PIN_G5 -to SW[4]
set_location_assignment PIN_J7 -to SW[5]
set_location_assignment PIN_H7 -to SW[6]
set_location_assignment PIN_E3 -to SW[7]
set_location_assignment PIN_E4 -to SW[8]
set_location_assignment PIN_D2 -to SW[9]
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/filtro_boton.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/decodificador_7segmentos.vhd
set_global_assignment -name VHDL_FILE ../../lector_tcs3200.vhd
set_global_assignment -name VHDL_FILE Prueba_TCS3200.vhd
set_location_assignment PIN_AB15 -to TCS_OUT
set_location_assignment PIN_AA14 -to TCS_S2
set_location_assignment PIN_AB14 -to TCS_S3
set_location_assignment PIN_AB13 -to TCS_S0
set_location_assignment PIN_AA13 -to TCS_S1

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_OUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S3
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S0
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S1

set_global_assignment -name LAST_QUARTUS_VERSION 13.1
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity Prueba_TCS3200 is
    port (
        CLOCK_50 : in  std_logic;
        BUTTON   : in  std_logic_vector(2 downto 0);
        SW       : in  std_logic_vector(9 downto 0);

        TCS_OUT : in  std_logic;
        TCS_S0  : out std_logic;
        TCS_S1  : out std_logic;
        TCS_S2  : out std_logic;
        TCS_S3  : out std_logic;

        LEDG : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0)
    );
end entity Prueba_TCS3200;

architecture estructural of Prueba_TCS3200 is

    signal reinicio       : std_logic;
    signal boton_inicio   : std_logic;
    signal pulso_inicio   : std_logic;

    signal color          : std_logic_vector(1 downto 0);
    signal rojo           : std_logic_vector(15 downto 0);
    signal verde          : std_logic_vector(15 downto 0);
    signal azul           : std_logic_vector(15 downto 0);
    signal valor_mostrado : std_logic_vector(15 downto 0);

    signal seleccion_1, seleccion_2 : std_logic_vector(1 downto 0) := "00";
    signal lista          : std_logic;
    signal valida         : std_logic;
    signal ocupado        : std_logic;
    signal alternador_fin : std_logic := '0';

begin

    boton_inicio <= not BUTTON(0);

    with seleccion_2 select
        valor_mostrado <=
            rojo  when "00",
            verde when "01",
            azul  when "10",
            (others => '0') when others;

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => CLOCK_50,
            reinicio_bajo => BUTTON(1),
            reinicio_salida => reinicio
        );

    U_BOTON : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => 250000
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            boton_entrada => boton_inicio,
            pulso_salida => pulso_inicio,
            estado_salida => open
        );

    U_TCS3200 : entity work.lector_tcs3200
        generic map (
            VENTANA_CICLOS => 1500000,       -- 30 ms a 50 MHz
            ASENTAMIENTO_CICLOS => 25000,    -- 0.5 ms a 50 MHz
            CLASIFICACION_HABILITADA => true,
            BASE_NEGRA_ROJO => 26,
            BASE_NEGRA_VERDE => 26,
            BASE_NEGRA_AZUL => 34,
            GANANCIA_ROJO_Q5 => 85,
            GANANCIA_VERDE_Q5 => 109,
            GANANCIA_AZUL_Q5 => 115,
            SENAL_MINIMA => 10
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            iniciar => pulso_inicio,
            tcs_out => TCS_OUT,
            tcs_s0 => TCS_S0,
            tcs_s1 => TCS_S1,
            tcs_s2 => TCS_S2,
            tcs_s3 => TCS_S3,
            color => color,
            valor_rojo => rojo,
            valor_verde => verde,
            valor_azul => azul,
            medicion_lista => lista,
            medicion_valida => valida,
            ocupado => ocupado
        );

    process(CLOCK_50, reinicio)
    begin
        if reinicio = '1' then
            alternador_fin <= '0';
            seleccion_1 <= "00"; seleccion_2 <= "00";
        elsif rising_edge(CLOCK_50) then
            seleccion_1 <= SW(1 downto 0); seleccion_2 <= seleccion_1;
            if lista = '1' then
                alternador_fin <= not alternador_fin;
            end if;
        end if;
    end process;

    U_HEX0 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(3 downto 0), segmentos => HEX0);

    U_HEX1 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(7 downto 4), segmentos => HEX1);

    U_HEX2 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(11 downto 8), segmentos => HEX2);

    U_HEX3 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(15 downto 12), segmentos => HEX3);

    LEDG(1 downto 0) <= color;
    LEDG(2) <= valida;
    LEDG(3) <= ocupado;
    LEDG(4) <= alternador_fin;
    LEDG(9 downto 5) <= (others => '0');

end architecture estructural;
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.qpf - MODIFICADO

```tcl
PROJECT_REVISION = "Prueba_V183"
PROJECT_REVISION = "Prueba_V183_Activo_Alto"
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.qsf - MODIFICADO

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_V183
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../entrada_presencia_v183.vhd
set_global_assignment -name VHDL_FILE Prueba_V183.vhd
set_location_assignment PIN_AB16 -to V183_OUT

set_parameter -name ACTIVO_BAJO true

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to V183_OUT

set_global_assignment -name LAST_QUARTUS_VERSION 13.1
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Prueba_V183 is
    generic (ACTIVO_BAJO : boolean := true);
    port (
        CLOCK_50 : in  std_logic;
        BUTTON   : in  std_logic_vector(2 downto 0);
        V183_OUT : in  std_logic;
        LEDG     : out std_logic_vector(9 downto 0)
    );
end entity Prueba_V183;

architecture estructural of Prueba_V183 is

    signal reinicio          : std_logic;
    signal presencia_activa  : std_logic;
    signal pulso_pieza       : std_logic;
    signal alternador_evento : std_logic := '0';
    signal cuenta_eventos : unsigned(6 downto 0) := (others => '0');
    signal nivel_1, nivel_2 : std_logic := '0';

begin

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => CLOCK_50,
            reinicio_bajo => BUTTON(1),
            reinicio_salida => reinicio
        );

    U_SENSOR : entity work.entrada_presencia_v183
        generic map (
            CICLOS_ESTABLES => 250000,
            ACTIVO_BAJO => ACTIVO_BAJO
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            sensor_entrada => V183_OUT,
            presencia_activa => presencia_activa,
            pulso_pieza => pulso_pieza
        );

    process(CLOCK_50, reinicio)
    begin
        if reinicio = '1' then
            alternador_evento <= '0';
            cuenta_eventos <= (others => '0');
            nivel_1 <= '0'; nivel_2 <= '0';
        elsif rising_edge(CLOCK_50) then
            nivel_1 <= V183_OUT; nivel_2 <= nivel_1;
            if pulso_pieza = '1' then
                alternador_evento <= not alternador_evento;
                if cuenta_eventos < 127 then cuenta_eventos <= cuenta_eventos + 1; end if;
            end if;
        end if;
    end process;

    LEDG(0) <= presencia_activa;
    LEDG(1) <= alternador_evento;
    LEDG(2) <= nivel_2; -- Nivel electrico de OUT, sin invertir.
    LEDG(9 downto 3) <= std_logic_vector(cuenta_eventos);

end architecture estructural;
```

## SystemAlfa/Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183_Activo_Alto.qsf - NUEVO

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_V183
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../entrada_presencia_v183.vhd
set_global_assignment -name VHDL_FILE Prueba_V183.vhd
set_location_assignment PIN_AB16 -to V183_OUT

set_parameter -name ACTIVO_BAJO false

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to V183_OUT
```

## SystemAlfa/Hardware_Sensores/pwm_servo.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
-- 50 Hz; ancho configurado en microsegundos y tomado al inicio de cada trama.
entity pwm_servo is
    generic (CICLOS_US : positive := 50);
    port (reloj, reinicio, habilitar : in std_logic;
          ancho_us : in integer range 1000 to 2000;
          salida : out std_logic);
end;
architecture rtl of pwm_servo is
    signal subcuenta : integer range 0 to CICLOS_US-1 := 0;
    signal microsegundos : integer range 0 to 19999 := 0;
    signal ancho_guardado : integer range 1000 to 2000 := 1500;
begin
    process(reloj, reinicio)
    begin
        if reinicio='1' then subcuenta<=0; microsegundos<=0; ancho_guardado<=1500;
        elsif rising_edge(reloj) then
            if habilitar='0' then subcuenta<=0; microsegundos<=0;
            elsif subcuenta=CICLOS_US-1 then
                subcuenta<=0;
                if microsegundos=19999 then microsegundos<=0;
                else microsegundos<=microsegundos+1; end if;
            else subcuenta<=subcuenta+1; end if;
            if microsegundos=0 and subcuenta=0 then ancho_guardado<=ancho_us; end if;
        end if;
    end process;
    salida <= '1' when habilitar='1' and reinicio='0' and microsegundos<ancho_guardado else '0';
end;
```

## SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.qpf - MODIFICADO

```tcl
QUARTUS_VERSION = "13.1"
PROJECT_REVISION = "SystemAlfa_Hardware"
```

## SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.qsf - MODIFICADO

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name TOP_LEVEL_ENTITY SystemAlfa_Hardware
set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name SDC_FILE hardware.sdc
set_global_assignment -name VHDL_FILE ajuste_fisico.vhd
set_global_assignment -name VHDL_FILE base_tiempo_fisica.vhd
set_global_assignment -name VHDL_FILE control_clasificacion_fisica.vhd
set_global_assignment -name VHDL_FILE control_motor_l298n.vhd
set_global_assignment -name VHDL_FILE entrada_presencia_v183.vhd
set_global_assignment -name VHDL_FILE lector_hcsr04.vhd
set_global_assignment -name VHDL_FILE lector_tcs3200.vhd
set_global_assignment -name VHDL_FILE medicion_coordinada.vhd
set_global_assignment -name VHDL_FILE pwm_servo.vhd
set_global_assignment -name VHDL_FILE ../comunes/captura_pieza.vhd
set_global_assignment -name VHDL_FILE ../comunes/contador_ascendente.vhd
set_global_assignment -name VHDL_FILE ../comunes/contador_segundos.vhd
set_global_assignment -name VHDL_FILE ../comunes/conteo_categorias.vhd
set_global_assignment -name VHDL_FILE ../comunes/control_linea.vhd
set_global_assignment -name VHDL_FILE ../comunes/conversor_decimal_reloj.vhd
set_global_assignment -name VHDL_FILE ../comunes/decodificador_7segmentos.vhd
set_global_assignment -name VHDL_FILE ../comunes/divisor_frecuencia.vhd
set_global_assignment -name VHDL_FILE ../comunes/filtro_boton.vhd
set_global_assignment -name VHDL_FILE ../comunes/historial_sesion.vhd
set_global_assignment -name VHDL_FILE ../comunes/maquina_estados_control.vhd
set_global_assignment -name VHDL_FILE ../comunes/memoria_ram_historial.vhd
set_global_assignment -name VHDL_FILE ../comunes/paquete_funciones.vhd
set_global_assignment -name VHDL_FILE ../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../comunes/rom_categorias.vhd
set_global_assignment -name VHDL_FILE ../comunes/selector_velocidad.vhd
set_global_assignment -name VHDL_FILE ../comunes/sincronizador.vhd
set_global_assignment -name VHDL_FILE ../comunes/supervisor_error.vhd
set_global_assignment -name VHDL_FILE ../comunes/tabla_reglas.vhd
set_global_assignment -name VHDL_FILE visor_ajuste.vhd
set_global_assignment -name VHDL_FILE ../SystemAlfa_Final/SystemAlfa_Final.vhd
set_global_assignment -name VHDL_FILE ../comunes/codificador_direccion.vhd
set_global_assignment -name VHDL_FILE SystemAlfa_Hardware.vhd
set_location_assignment PIN_G21 -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_location_assignment PIN_H2 -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_location_assignment PIN_J6 -to SW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]
set_location_assignment PIN_H5 -to SW[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]
set_location_assignment PIN_H6 -to SW[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]
set_location_assignment PIN_G4 -to SW[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[3]
set_location_assignment PIN_G5 -to SW[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[4]
set_location_assignment PIN_J7 -to SW[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[5]
set_location_assignment PIN_H7 -to SW[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[6]
set_location_assignment PIN_E3 -to SW[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[7]
set_location_assignment PIN_E4 -to SW[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[8]
set_location_assignment PIN_D2 -to SW[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[9]
set_location_assignment PIN_J1 -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to LEDG[9]
set_location_assignment PIN_E11 -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX0[0]
set_location_assignment PIN_F11 -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX0[1]
set_location_assignment PIN_H12 -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX0[2]
set_location_assignment PIN_H13 -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX0[3]
set_location_assignment PIN_G12 -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX0[4]
set_location_assignment PIN_F12 -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX0[5]
set_location_assignment PIN_F13 -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX0[6]
set_location_assignment PIN_A13 -to HEX1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX1[0]
set_location_assignment PIN_B13 -to HEX1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX1[1]
set_location_assignment PIN_C13 -to HEX1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX1[2]
set_location_assignment PIN_A14 -to HEX1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX1[3]
set_location_assignment PIN_B14 -to HEX1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX1[4]
set_location_assignment PIN_E14 -to HEX1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX1[5]
set_location_assignment PIN_A15 -to HEX1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX1[6]
set_location_assignment PIN_D15 -to HEX2[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX2[0]
set_location_assignment PIN_A16 -to HEX2[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX2[1]
set_location_assignment PIN_B16 -to HEX2[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX2[2]
set_location_assignment PIN_E15 -to HEX2[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX2[3]
set_location_assignment PIN_A17 -to HEX2[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX2[4]
set_location_assignment PIN_B17 -to HEX2[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX2[5]
set_location_assignment PIN_F14 -to HEX2[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX2[6]
set_location_assignment PIN_B18 -to HEX3[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX3[0]
set_location_assignment PIN_F15 -to HEX3[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX3[1]
set_location_assignment PIN_A19 -to HEX3[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX3[2]
set_location_assignment PIN_B19 -to HEX3[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX3[3]
set_location_assignment PIN_C19 -to HEX3[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX3[5]
set_location_assignment PIN_G15 -to HEX3[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to HEX3[6]
set_location_assignment PIN_AB16 -to V183_OUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to V183_OUT
set_location_assignment PIN_AA16 -to HCSR04_TRIG
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HCSR04_TRIG
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HCSR04_TRIG
set_location_assignment PIN_AA15 -to HCSR04_ECHO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HCSR04_ECHO
set_location_assignment PIN_AB15 -to TCS_OUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_OUT
set_location_assignment PIN_AA14 -to TCS_S2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S2
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to TCS_S2
set_location_assignment PIN_AB14 -to TCS_S3
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S3
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to TCS_S3
set_location_assignment PIN_AB13 -to TCS_S0
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S0
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to TCS_S0
set_location_assignment PIN_AA13 -to TCS_S1
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S1
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to TCS_S1
set_location_assignment PIN_AB10 -to MOTOR_PWM
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to MOTOR_PWM
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to MOTOR_PWM
set_location_assignment PIN_AA10 -to MOTOR_IN1
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to MOTOR_IN1
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to MOTOR_IN1
set_location_assignment PIN_AB8 -to MOTOR_IN2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to MOTOR_IN2
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to MOTOR_IN2
set_location_assignment PIN_AA8 -to SERVO1
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SERVO1
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to SERVO1
set_location_assignment PIN_AB5 -to SERVO2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SERVO2
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to SERVO2
set_location_assignment PIN_AA5 -to LED_CATEGORIAS[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED_CATEGORIAS[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to LED_CATEGORIAS[0]
set_location_assignment PIN_AB4 -to LED_CATEGORIAS[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED_CATEGORIAS[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to LED_CATEGORIAS[1]
set_location_assignment PIN_AA4 -to LED_CATEGORIAS[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED_CATEGORIAS[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to LED_CATEGORIAS[2]
set_location_assignment PIN_V14 -to LED_CATEGORIAS[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED_CATEGORIAS[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to LED_CATEGORIAS[3]
set_location_assignment PIN_AA20 -to HEX_VEL_EXT[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_VEL_EXT[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_VEL_EXT[0]
set_location_assignment PIN_AB20 -to HEX_VEL_EXT[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_VEL_EXT[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_VEL_EXT[1]
set_location_assignment PIN_AA19 -to HEX_VEL_EXT[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_VEL_EXT[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_VEL_EXT[2]
set_location_assignment PIN_AB19 -to HEX_VEL_EXT[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_VEL_EXT[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_VEL_EXT[3]
set_location_assignment PIN_AB18 -to HEX_VEL_EXT[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_VEL_EXT[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_VEL_EXT[4]
set_location_assignment PIN_AA18 -to HEX_VEL_EXT[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_VEL_EXT[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_VEL_EXT[5]
set_location_assignment PIN_AA17 -to HEX_VEL_EXT[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_VEL_EXT[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_VEL_EXT[6]
set_location_assignment PIN_Y17 -to HEX_CAT_EXT[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_CAT_EXT[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_CAT_EXT[0]
set_location_assignment PIN_W17 -to HEX_CAT_EXT[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_CAT_EXT[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_CAT_EXT[1]
set_location_assignment PIN_U15 -to HEX_CAT_EXT[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_CAT_EXT[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_CAT_EXT[2]
set_location_assignment PIN_T15 -to HEX_CAT_EXT[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_CAT_EXT[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_CAT_EXT[3]
set_location_assignment PIN_W15 -to HEX_CAT_EXT[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_CAT_EXT[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_CAT_EXT[4]
set_location_assignment PIN_V15 -to HEX_CAT_EXT[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_CAT_EXT[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_CAT_EXT[5]
set_location_assignment PIN_AB9 -to HEX_CAT_EXT[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX_CAT_EXT[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to HEX_CAT_EXT[6]

set_global_assignment -name LAST_QUARTUS_VERSION 13.1
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
```

## SystemAlfa/Hardware_Sensores/SystemAlfa_Hardware.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SystemAlfa_Hardware is
    generic (
        PRESENCIA_ACTIVA_BAJO:boolean:=true;
        FRECUENCIA_RELOJ_HZ:positive:=50000000;
        CICLOS_FILTRO:positive:=500000;
        CICLOS_PRESENCIA:positive:=250000;
        CICLOS_TICK:positive:=500000;
        VENTANA_COLOR:positive:=1500000;
        ASENTAR_COLOR:positive:=25000;
        CICLOS_PWM_MOTOR:positive:=5000;
        CICLOS_US_SERVO:positive:=50;
        INTERVALO_HC_US:positive:=61000;
        EXT_DRIVER_INVERSOR:boolean:=true
    );
    port (
        CLOCK_50,V183_OUT,HCSR04_ECHO,TCS_OUT:in std_logic;
        HCSR04_TRIG,TCS_S0,TCS_S1,TCS_S2,TCS_S3:out std_logic;
        BUTTON:in std_logic_vector(2 downto 0);
        SW:in std_logic_vector(9 downto 0);
        LEDG:out std_logic_vector(9 downto 0);
        HEX0,HEX1,HEX2,HEX3:out std_logic_vector(6 downto 0);
        MOTOR_PWM,MOTOR_IN1,MOTOR_IN2,SERVO1,SERVO2:out std_logic;
        LED_CATEGORIAS:out std_logic_vector(3 downto 0);
        HEX_VEL_EXT,HEX_CAT_EXT:out std_logic_vector(6 downto 0)
    );
end;

architecture estructural of SystemAlfa_Hardware is
    signal arranque:std_logic_vector(3 downto 0):="1111";
    signal reset_sesion,reset_boton,reinicio,reset_lectores,tick:std_logic;
    signal switches:std_logic_vector(9 downto 0);
    signal boton0,boton2,subir,bajar,paro_crudo,paro_confirmado:std_logic;
    signal armado,permiso,error_mando,modo_ajuste,cambio_modo:std_logic:='0';
    signal pagina:integer range 0 to 63:=0;
    signal nivel_ajuste:integer range 0 to 3:=0;
    signal nivel_seleccionado:integer range 0 to 3;
    signal pres_1,pres_2:std_logic:='1';
    signal presencia,pulso_pieza:std_logic;
    signal hc_iniciar,tcs_iniciar,hc_fin,hc_val,hc_tam,hc_busy,tcs_fin,tcs_val,tcs_busy:std_logic;
    signal inicio_hc_auto,inicio_tcs_auto,inicio_diag:std_logic;
    signal distancia:std_logic_vector(7 downto 0);
    signal color_tcs:std_logic_vector(1 downto 0);
    signal rojo,verde,azul:std_logic_vector(15 downto 0);
    signal iniciar_medicion,med_lista,med_val,med_tam,med_busy:std_logic;
    signal med_color:std_logic_vector(1 downto 0);
    signal presencia_core,color_tamano_core,marcha_core,evento_core,linea_core,alarma_core,limite_core:std_logic;
    signal color_core,color_led,nivel_core:std_logic_vector(1 downto 0);
    signal categoria_core,categoria_led,categoria_fisica,error_fisico:std_logic_vector(3 downto 0);
    signal tamano_led,marcha_entrada,marcha_control,motor_auto,abrir1,abrir2,ocupado,alarma_fisica:std_logic;
    signal configurado,pos_ok1,pos_ok2,motor_prueba,error_ajuste,motor_habilitado:std_logic;
    signal duty:integer range 0 to 100;
    signal reposo1,desvio1,reposo2,desvio2,pulso1,pulso2:integer range 1000 to 2000;
    signal adelanto1,adelanto2:integer range 5 to 100;
    signal llegada1,llegada2,salida_cinta:integer range 0 to 6000;
    signal etapa:std_logic_vector(3 downto 0);
    signal valor_ajuste,valor_visor:integer range 0 to 65535;
    signal ver_hex,activar_servo1,activar_servo2,alarma_total:std_logic;
    signal c0,c1,c2,c3,a0,a1,a2,a3,seg_vel_ext,seg_cat_ext:std_logic_vector(6 downto 0);
    signal n_vel:std_logic_vector(3 downto 0);
    signal cambio_vel_n,cambio_en_curso:std_logic;
    signal pendientes:integer range 0 to 3:=0;
    signal fase_vel:integer range 0 to 2:=0;
    signal cuenta_vel:integer range 0 to 3:=0;
begin
    -- Inicializacion de sesion, independiente del boton de reset.
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then arranque<=arranque(2 downto 0)&'0'; end if;
    end process;
    reset_sesion<=arranque(3);
    U_RESET:entity work.reinicio_seguro port map(CLOCK_50,BUTTON(1),reset_boton);
    reinicio<=reset_boton or reset_sesion;
    U_TICK:entity work.base_tiempo_fisica generic map(CICLOS_TICK) port map(CLOCK_50,reinicio,tick);
    G_SW:for i in 0 to 9 generate
        U_SW:entity work.filtro_boton generic map(CICLOS_FILTRO)
            port map(CLOCK_50,reinicio,SW(i),open,switches(i));
    end generate;
    boton0<=not BUTTON(0);boton2<=not BUTTON(2);paro_crudo<=not SW(3);
    U_B0:entity work.filtro_boton generic map(CICLOS_FILTRO) port map(CLOCK_50,reinicio,boton0,subir,open);
    U_B2:entity work.filtro_boton generic map(CICLOS_FILTRO) port map(CLOCK_50,reinicio,boton2,bajar,open);
    U_PARO:entity work.filtro_boton generic map(CICLOS_FILTRO) port map(CLOCK_50,reinicio,paro_crudo,open,paro_confirmado);
    -- Rearme exige un cero fisico de SW3. La pagina y el modo se eligen parado.
    process(CLOCK_50,reinicio)
    begin
        if reinicio='1' then
            armado<='0';error_mando<='0';modo_ajuste<='0';pagina<=0;nivel_ajuste<=0;cambio_modo<='0';
        elsif rising_edge(CLOCK_50) then
            cambio_modo<='0';
            if paro_confirmado='1' then
                armado<='1';
                if modo_ajuste/=switches(0) then cambio_modo<='1';end if;
                modo_ajuste<=switches(0);pagina<=to_integer(unsigned(switches(9 downto 4)));
                nivel_ajuste<=to_integer(unsigned(switches(2 downto 1)));
            elsif switches(3)='1' and armado='1' then
                if switches(0)/=modo_ajuste then error_mando<='1';
                elsif modo_ajuste='1' and (to_integer(unsigned(switches(9 downto 4)))/=pagina or
                      to_integer(unsigned(switches(2 downto 1)))/=nivel_ajuste) then error_mando<='1';end if;
            end if;
        end if;
    end process;
    permiso<=armado and switches(3) and SW(3) and BUTTON(1) and not reinicio and not error_mando;
    reset_lectores<=reinicio or cambio_modo;
    -- Presencia electrica real, tambien visible durante la inicializacion del V183.
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then pres_1<=V183_OUT;pres_2<=pres_1;end if;
    end process;
    presencia<=not pres_2 when PRESENCIA_ACTIVA_BAJO else pres_2;
    U_V183:entity work.entrada_presencia_v183 generic map(CICLOS_PRESENCIA,PRESENCIA_ACTIVA_BAJO)
        port map(CLOCK_50,reset_lectores,V183_OUT,open,pulso_pieza);
    U_HC:entity work.lector_hcsr04
        generic map(FRECUENCIA_RELOJ_HZ=>FRECUENCIA_RELOJ_HZ,USAR_VENTANAS_MM=>true,INTERVALO_MINIMO_US=>INTERVALO_HC_US)
        port map(CLOCK_50,reset_lectores,hc_iniciar,HCSR04_ECHO,HCSR04_TRIG,distancia,hc_tam,hc_fin,hc_val,hc_busy);
    U_TCS:entity work.lector_tcs3200
        generic map(VENTANA_CICLOS=>VENTANA_COLOR,ASENTAMIENTO_CICLOS=>ASENTAR_COLOR,CLASIFICACION_HABILITADA=>true)
        port map(CLOCK_50,reset_lectores,tcs_iniciar,TCS_OUT,TCS_S0,TCS_S1,TCS_S2,TCS_S3,
                 color_tcs,rojo,verde,azul,tcs_fin,tcs_val,tcs_busy);
    inicio_diag<=subir when modo_ajuste='1' and pagina>=8 and pagina<=11 and hc_busy='0' and tcs_busy='0' else '0';
    hc_iniciar<=inicio_diag when modo_ajuste='1' else inicio_hc_auto;
    tcs_iniciar<=inicio_diag when modo_ajuste='1' else inicio_tcs_auto;
    U_MEDIR:entity work.medicion_coordinada
        port map(CLOCK_50,reset_lectores,tick,iniciar_medicion,hc_fin,hc_val,hc_tam,hc_busy,
                 tcs_fin,tcs_val,tcs_busy,color_tcs,inicio_hc_auto,inicio_tcs_auto,med_lista,med_val,med_busy,med_color,med_tam);
    nivel_seleccionado<=nivel_ajuste when modo_ajuste='1' else to_integer(unsigned(nivel_core));
    U_AJUSTE:entity work.ajuste_fisico
        port map(CLOCK_50,reset_sesion,reinicio,tick,modo_ajuste,permiso,subir,bajar,pagina,nivel_seleccionado,
                 duty,reposo1,desvio1,reposo2,desvio2,adelanto1,adelanto2,llegada1,llegada2,salida_cinta,
                 configurado,pos_ok1,pos_ok2,motor_prueba,error_ajuste,etapa,valor_ajuste);
    marcha_entrada<=permiso and not modo_ajuste;
    marcha_control<=marcha_core and marcha_entrada and not cambio_en_curso;
    U_FISICO:entity work.control_clasificacion_fisica
        port map(CLOCK_50,reset_lectores,tick,marcha_control,configurado,pulso_pieza,presencia,
                 med_lista,med_val,med_tam,med_color,evento_core,categoria_core,
                 llegada1,llegada2,salida_cinta,adelanto1,adelanto2,
                 iniciar_medicion,presencia_core,color_core,color_tamano_core,
                 motor_auto,abrir1,abrir2,ocupado,alarma_fisica,categoria_fisica,error_fisico);
    -- Guarda solicitudes de BUTTON2 y las aplica al terminar la pieza.
    process(CLOCK_50,reinicio)
        variable solicitudes:integer range 0 to 3;
    begin
        if reinicio='1' then pendientes<=0;fase_vel<=0;cuenta_vel<=0;
        elsif rising_edge(CLOCK_50) then
            solicitudes:=pendientes;
            if modo_ajuste='1' then solicitudes:=0;fase_vel<=0;cuenta_vel<=0;
            else
                if bajar='1' then solicitudes:=(solicitudes+1) mod 4;end if;
                if fase_vel=0 then
                    if solicitudes>0 and ocupado='0' and presencia='0' then
                        solicitudes:=solicitudes-1;fase_vel<=1;cuenta_vel<=0;
                    end if;
                elsif tick='1' then
                    if cuenta_vel=3 then
                        cuenta_vel<=0;
                        if fase_vel=1 then fase_vel<=2;else fase_vel<=0;end if;
                    else cuenta_vel<=cuenta_vel+1;end if;
                end if;
            end if;
            pendientes<=solicitudes;
        end if;
    end process;
    cambio_vel_n<='0' when fase_vel=1 else '1';
    cambio_en_curso<='1' when fase_vel/=0 else '0';
    U_CORE:entity work.SystemAlfa_Final
        generic map(FRECUENCIA_RELOJ_HZ=>FRECUENCIA_RELOJ_HZ,CICLOS_FILTRO=>CICLOS_FILTRO)
        port map(RELOJ=>CLOCK_50,REINICIO_BAJO=>BUTTON(1),PRESENCIA=>presencia_core,CAMBIO_VELOCIDAD=>cambio_vel_n,
            SELECTOR_COLOR=>color_core,SELECTOR_TAMANO=>color_tamano_core,LINEA_MARCHA=>marcha_entrada,
            VER_HISTORIAL=>SW(4),SIGUIENTE_HISTORIAL=>SW(5),SELECCION_HISTORIAL=>SW(6),VER_CANTIDADES=>SW(7),
            IR_ULTIMO=>SW(8),CONTAR_POR_COLOR=>SW(9),LED_COLOR=>color_led,LED_TAMANO=>tamano_led,
            LINEA_ACTIVA=>linea_core,RUTA_PIEZA=>categoria_led,ALARMA=>alarma_core,LED_LIMITE=>limite_core,
            VISOR_0=>c0,VISOR_1=>c1,VISOR_2=>c2,VISOR_3=>c3,
            MARCHA_FISICA=>marcha_core,EVENTO_VALIDO=>evento_core,NIVEL_FISICO=>nivel_core,CATEGORIA_FISICA=>categoria_core);
    motor_habilitado<=permiso and motor_prueba when modo_ajuste='1' else permiso and motor_auto and not alarma_core and not limite_core;
    U_MOTOR:entity work.control_motor_l298n generic map(CICLOS_PWM_MOTOR)
        port map(CLOCK_50,reinicio,motor_habilitado,duty,MOTOR_PWM,MOTOR_IN1,MOTOR_IN2);
    -- En ajuste solo se mueve el servo elegido, habilitado por SW3.
    process(modo_ajuste,pagina,permiso,pos_ok1,pos_ok2,reposo1,reposo2,desvio1,desvio2,abrir1,abrir2)
    begin
        pulso1<=reposo1;pulso2<=reposo2;activar_servo1<=pos_ok1;activar_servo2<=pos_ok2;
        if modo_ajuste='1' then
            if (pagina=1 or pagina=2) and permiso='1' then
                activar_servo1<='1';if pagina=2 then pulso1<=desvio1;end if;
            elsif (pagina=3 or pagina=4) and permiso='1' then
                activar_servo2<='1';if pagina=4 then pulso2<=desvio2;end if;
            end if;
        else
            if abrir1='1' and permiso='1' then pulso1<=desvio1;end if;
            if abrir2='1' and permiso='1' then pulso2<=desvio2;end if;
        end if;
    end process;
    U_SERVO1:entity work.pwm_servo generic map(CICLOS_US_SERVO) port map(CLOCK_50,reinicio,activar_servo1,pulso1,SERVO1);
    U_SERVO2:entity work.pwm_servo generic map(CICLOS_US_SERVO) port map(CLOCK_50,reinicio,activar_servo2,pulso2,SERVO2);
    process(pagina,valor_ajuste,distancia,rojo,verde,azul)
    begin
        valor_visor<=valor_ajuste;ver_hex<='0';
        case pagina is
            when 8=>valor_visor<=to_integer(unsigned(distancia));
            when 9=>valor_visor<=to_integer(unsigned(rojo));ver_hex<='1';
            when 10=>valor_visor<=to_integer(unsigned(verde));ver_hex<='1';
            when 11=>valor_visor<=to_integer(unsigned(azul));ver_hex<='1';
            when others=>null;
        end case;
    end process;
    U_VISOR:entity work.visor_ajuste port map(CLOCK_50,valor_visor,ver_hex,a0,a1,a2,a3);
    HEX0<=a0 when modo_ajuste='1' else c0; HEX1<=a1 when modo_ajuste='1' else c1;
    HEX2<=a2 when modo_ajuste='1' else c2; HEX3<=a3 when modo_ajuste='1' else c3;
    alarma_total<=alarma_fisica or alarma_core or error_mando;
    process(modo_ajuste,etapa,pagina,configurado,error_ajuste,error_mando,motor_habilitado,
            color_led,tamano_led,categoria_led,alarma_total,alarma_fisica,error_fisico,limite_core,hc_val,tcs_val)
    begin
        LEDG<=(others=>'0'); LEDG(3)<=motor_habilitado;
        if modo_ajuste='1' then
            LEDG(1 downto 0)<=etapa(1 downto 0);LEDG(2)<=hc_val and tcs_val;
            LEDG(7 downto 4)<=std_logic_vector(to_unsigned(pagina mod 16,4));
            LEDG(8)<=error_ajuste or error_mando;LEDG(9)<=configurado;
        else
            LEDG(1 downto 0)<=color_led;LEDG(2)<=tamano_led;LEDG(7 downto 4)<=categoria_led;
            if alarma_fisica='1' then LEDG(7 downto 4)<=error_fisico;end if;
            LEDG(8)<=alarma_total;LEDG(9)<=limite_core or not configurado;
        end if;
    end process;
    G_LED:for i in 0 to 3 generate
        LED_CATEGORIAS(i)<='1' when modo_ajuste='0' and to_integer(unsigned(categoria_fisica))=i+3 and alarma_total='0' else '0';
    end generate;
    n_vel<=std_logic_vector(to_unsigned(nivel_seleccionado,4));
    U_EXT_V:entity work.decodificador_7segmentos port map(n_vel,seg_vel_ext);
    U_EXT_C:entity work.decodificador_7segmentos port map(categoria_fisica,seg_cat_ext);
    -- ULN2803A invierte: GPIO=1 enciende el segmento de anodo comun.
    HEX_VEL_EXT<=not seg_vel_ext when EXT_DRIVER_INVERSOR else seg_vel_ext;
    HEX_CAT_EXT<=not seg_cat_ext when EXT_DRIVER_INVERSOR else seg_cat_ext;
end;
```

## SystemAlfa/Hardware_Sensores/visor_ajuste.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Conversion decimal desplazando un bit por ciclo (doble desplazamiento BCD).
entity visor_ajuste is
    port (reloj : in std_logic; valor : in integer range 0 to 65535;
          hexadecimal : in std_logic; hex0,hex1,hex2,hex3 : out std_logic_vector(6 downto 0));
end;
architecture rtl of visor_ajuste is
    signal binario : unsigned(15 downto 0) := (others=>'0');
    signal bcd : unsigned(19 downto 0) := (others=>'0');
    signal paso : integer range 0 to 16 := 0;
    signal decimal_guardado,hex_guardado : std_logic_vector(15 downto 0) := (others=>'0');
    signal n : std_logic_vector(15 downto 0);
begin
    process(reloj)
        variable ajuste : unsigned(19 downto 0);
    begin
        if rising_edge(reloj) then
            hex_guardado<=std_logic_vector(to_unsigned(valor,16));
            if paso=0 then
                binario<=to_unsigned(valor,16);bcd<=(others=>'0');paso<=1;
            else
                ajuste:=bcd;
                for i in 0 to 4 loop
                    if ajuste(i*4+3 downto i*4)>=5 then
                        ajuste(i*4+3 downto i*4):=ajuste(i*4+3 downto i*4)+3;
                    end if;
                end loop;
                ajuste:=ajuste(18 downto 0)&binario(15);
                bcd<=ajuste;binario<=binario(14 downto 0)&'0';
                if paso=16 then decimal_guardado<=std_logic_vector(ajuste(15 downto 0));paso<=0;
                else paso<=paso+1;end if;
            end if;
        end if;
    end process;
    n <= hex_guardado when hexadecimal='1' else decimal_guardado;
    U0: entity work.decodificador_7segmentos port map(n(3 downto 0),hex0);
    U1: entity work.decodificador_7segmentos port map(n(7 downto 4),hex1);
    U2: entity work.decodificador_7segmentos port map(n(11 downto 8),hex2);
    U3: entity work.decodificador_7segmentos port map(n(15 downto 12),hex3);
end;
```

## SystemAlfa/Pruebas_ModelSim/entrada_presencia_v183_TB.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity entrada_presencia_v183_TB is
    generic (BAJO : boolean := true; FILTRO : positive := 5);
end entity;

architecture prueba of entrada_presencia_v183_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal pieza : std_logic := '1';
    signal entrada, presencia, pulso : std_logic;
    signal eventos : natural := 0;
    signal terminar : boolean := false;
begin
    reloj <= not reloj after 10 ns when not terminar else '0';
    entrada <= not pieza when BAJO else pieza;
    DUT: entity work.entrada_presencia_v183
        generic map (CICLOS_ESTABLES => FILTRO, ACTIVO_BAJO => BAJO)
        port map (reloj, reinicio, entrada, presencia, pulso);

    process(reloj, reinicio)
        variable anterior : std_logic := '0';
    begin
        if reinicio = '1' then
            eventos <= 0; anterior := '0';
        elsif rising_edge(reloj) then
            assert not (pulso = '1' and anterior = '1')
                report "El evento dura mas de un ciclo" severity failure;
            if pulso = '1' then eventos <= eventos + 1; end if;
            anterior := pulso;
        end if;
    end process;

    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until falling_edge(reloj); end loop;
        end procedure;
    begin
        ciclos(4); reinicio <= '0'; ciclos(30);
        assert eventos = 0 report "Pieza al arrancar genero un evento falso" severity failure;
        pieza <= '0'; ciclos(30);
        assert presencia = '0' severity failure;
        if FILTRO > 1 then
            pieza <= '1'; ciclos(1); pieza <= '0'; ciclos(30);
            assert eventos = 0 report "No filtro una perturbacion corta" severity failure;
        end if;
        pieza <= '1'; ciclos(30);
        assert presencia = '1' and eventos = 1 report "Primera pieza incorrecta" severity failure;
        ciclos(80);
        assert eventos = 1 report "Repite eventos con la pieza sostenida" severity failure;
        if FILTRO > 1 then
            pieza <= '0'; ciclos(1); pieza <= '1'; ciclos(30);
            assert eventos = 1 and presencia = '1' report "Retiro breve rearma el sensor" severity failure;
        end if;
        pieza <= '0'; ciclos(30); pieza <= '1'; ciclos(30);
        assert eventos = 2 report "No reconocio la segunda pieza" severity failure;
        reinicio <= '1'; ciclos(4); reinicio <= '0'; ciclos(30);
        assert eventos = 0 report "Reset con pieza produjo evento" severity failure;
        pieza <= '0'; ciclos(30); pieza <= '1'; ciclos(30);
        assert eventos = 1 report "No rearmo despues del reset y retiro" severity failure;
        report "OK: V183, polaridad, arranque ocupado, rebotes, retencion y reset" severity note;
        terminar <= true; wait;
    end process;
end architecture;
```

## SystemAlfa/Pruebas_ModelSim/lector_hcsr04_montaje_TB.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
entity lector_hcsr04_montaje_TB is end;
architecture prueba of lector_hcsr04_montaje_TB is
    signal clk:std_logic:='0';signal fin:boolean:=false;
    signal rst,inicio,echo,trig,tamano,lista,valida,ocupado:std_logic:='0';
    signal cm:std_logic_vector(7 downto 0);
begin
    clk<=not clk after 500 ns when not fin else '0';
    U:entity work.lector_hcsr04
        generic map(FRECUENCIA_RELOJ_HZ=>1000000,USAR_VENTANAS_MM=>true,
                    INTERVALO_MINIMO_US=>1000,TIEMPO_MAXIMO_US=>1000)
        port map(clk,rst,inicio,echo,trig,cm,tamano,lista,valida,ocupado);
    process
        procedure medir(ancho:time;v,t:std_logic) is
        begin
            wait for 2 ms;inicio<='1';wait for 1 us;inicio<='0';
            wait until falling_edge(trig);wait for 20 us;
            if ancho>0 us then echo<='1';wait for ancho;echo<='0';end if;
            wait until lista='1' for 2 ms;wait for 1 ns;
            assert lista='1' and valida=v report "Validez incorrecta de ventana fisica" severity failure;
            if v='1' then assert tamano=t report "Tamano fisico incorrecto" severity failure;end if;
            wait until rising_edge(clk);wait until rising_edge(clk);wait for 1 ns;
            assert lista='0' report "Lista dura mas de un ciclo" severity failure;
        end;
    begin
        rst<='1';wait for 10 us;rst<='0';
        medir(110 us,'0','0'); -- Menos de 20 mm.
        medir(116 us,'1','1'); -- 20 mm, grande.
        medir(139 us,'1','1'); -- 24 mm, grande.
        medir(162 us,'1','1'); -- Un poco menos de 28 mm.
        medir(174 us,'0','0'); -- 30 mm, zona dudosa.
        medir(186 us,'1','0'); -- Un poco mas de 32 mm.
        medir(232 us,'1','0'); -- 40 mm, pequena.
        medir(278 us,'1','0'); -- Un poco menos de 48 mm.
        medir(300 us,'0','0'); -- Fuera de ventana pequena.
        medir(348 us,'0','0'); -- Cinta vacia a 60 mm.
        medir(0 us,'0','0');   -- Sin eco, no aceptar cero como grande.
        report "OK: ventanas del montaje, zona dudosa, cinta vacia y timeout" severity note;
        fin<=true;wait;
    end process;
end;
```

## SystemAlfa/Pruebas_ModelSim/lector_hcsr04_TB.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lector_hcsr04_TB is end entity;
architecture prueba of lector_hcsr04_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal iniciar, echo, trig, tamano, lista, valida, ocupado : std_logic := '0';
    signal distancia : std_logic_vector(7 downto 0);
    signal terminar : boolean := false;
    signal disparos, resultados : natural := 0;
begin
    -- 1 MHz solo para acelerar simulacion; la placa usa 50 MHz.
    reloj <= not reloj after 500 ns when not terminar else '0';
    DUT: entity work.lector_hcsr04
        generic map (FRECUENCIA_RELOJ_HZ => 1000000)
        port map (reloj, reinicio, iniciar, echo, trig, distancia, tamano, lista, valida, ocupado);
    process(trig)
    begin
        if rising_edge(trig) then disparos <= disparos + 1; end if;
    end process;
    process(reloj)
        variable anterior : std_logic := '0';
    begin
        if rising_edge(reloj) then
            assert not (lista = '1' and anterior = '1') report "Lista dura mas de un ciclo" severity failure;
            if lista = '1' then resultados <= resultados + 1; end if;
            anterior := lista;
        end if;
    end process;
    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until falling_edge(reloj); end loop;
        end procedure;
        procedure orden is
        begin
            iniciar <= '1'; ciclos(1); iniciar <= '0';
        end procedure;
        procedure medir(ancho_us, esperado_cm : natural; valido, grande : std_logic) is
            variable t : time;
            variable prev : natural;
        begin
            ciclos(62000);
            iniciar <= '1';
            wait until trig = '1' for 20 us;
            assert trig = '1' report "No genera TRIG" severity failure;
            t := now;
            wait until trig = '0' for 20 us;
            assert now-t = 10 us report "TRIG no dura 10 us" severity failure;
            iniciar <= '0';
            wait until falling_edge(reloj); ciclos(20);
            if ancho_us > 0 then
                echo <= '1'; wait for ancho_us*1 us; echo <= '0';
            end if;
            wait until lista = '1' for 81000 us;
            assert lista = '1' report "Medicion nunca termina" severity failure;
            wait for 1 ns;
            assert to_integer(unsigned(distancia)) = esperado_cm report "Distancia incorrecta" severity failure;
            assert valida = valido report "Validez incorrecta en limite de distancia" severity failure;
            if valido = '1' then assert tamano = grande report "Tamano incorrecto" severity failure; end if;
            ciclos(3);
            prev := disparos;
            orden; ciclos(100);
            assert disparos = prev report "Acepto disparo antes de 61 ms" severity failure;
        end procedure;
        variable prev : natural;
    begin
        ciclos(4); reinicio <= '0'; ciclos(4);
        medir(23*58,23,'1','1'); medir(25*58,25,'1','1');
        medir(1479,26,'0','0'); -- 25.5 cm: no redondear hacia una clase valida.
        medir(26*58,26,'0','0'); medir(27*58,27,'0','0'); medir(29*58,29,'0','0');
        medir(30*58,30,'1','0'); medir(32*58,32,'1','0');
        medir(2*58,2,'1','1'); medir(58,1,'0','0');
        medir(256*58,255,'0','0'); medir(0,0,'0','0');
        ciclos(62000); echo <= '1'; ciclos(5); prev := disparos;
        iniciar <= '1';
        wait until lista = '1' for 20 us;
        assert lista = '1' and valida = '0' report "No detecto ECHO alto inicial" severity failure;
        ciclos(70000);
        assert disparos = prev report "Repitio la orden sostenida" severity failure;
        iniciar <= '0'; echo <= '0'; ciclos(62000);
        orden;
        wait until trig = '0' for 30 us; ciclos(20); echo <= '1';
        wait until lista = '1' for 41000 us;
        assert lista = '1' and valida = '0' report "Falta timeout de ECHO sostenido" severity failure;
        echo <= '0'; ciclos(4);
        reinicio <= '1'; ciclos(4); reinicio <= '0'; ciclos(4);
        assert ocupado = '0' and valida = '0' and trig = '0' severity failure;
        report "OK: HCSR04, limites, TRIG, intervalo, orden sostenida y timeouts" severity note;
        terminar <= true; wait;
    end process;
end architecture;
```

## SystemAlfa/Pruebas_ModelSim/lector_tcs3200_TB.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity lector_tcs3200_TB is end entity;
architecture prueba of lector_tcs3200_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal iniciar, entrada, s0, s1, s2, s3, lista, valida, ocupado : std_logic := '0';
    signal color, color_prueba : std_logic_vector(1 downto 0);
    signal rojo, verde, azul : std_logic_vector(15 downto 0);
    signal valida_prueba : std_logic;
    signal caso : natural range 0 to 4 := 0;
    signal terminar : boolean := false;
begin
    reloj <= not reloj after 10 ns when not terminar else '0';
    DUT: entity work.lector_tcs3200
        generic map (VENTANA_CICLOS => 100, ASENTAMIENTO_CICLOS => 10)
        port map (reloj,reinicio,iniciar,entrada,s0,s1,s2,s3,color,rojo,verde,azul,lista,valida,ocupado);
    -- Umbrales SINTETICOS solo para probar el algoritmo; NO son calibracion fisica.
    DUT_ALGORITMO: entity work.lector_tcs3200
        generic map (VENTANA_CICLOS => 100, ASENTAMIENTO_CICLOS => 10,
                     CLASIFICACION_HABILITADA => true,
                     BASE_NEGRA_ROJO => 0, BASE_NEGRA_VERDE => 0, BASE_NEGRA_AZUL => 0,
                     GANANCIA_ROJO_Q5 => 32, GANANCIA_VERDE_Q5 => 32, GANANCIA_AZUL_Q5 => 32,
                     SENAL_MINIMA => 3)
        port map (reloj,reinicio,iniciar,entrada,open,open,open,open,color_prueba,
                  open,open,open,open,valida_prueba,open);
    process(reloj)
        variable fase : natural := 0;
        variable periodo : positive := 10;
        variable anterior : std_logic_vector(1 downto 0) := "00";
        variable filtro : std_logic_vector(1 downto 0);
    begin
        if falling_edge(reloj) then
            filtro := s2 & s3;
            periodo := 20;
            if filtro = "01" then periodo := 25; end if;
            if (caso=0 and filtro="00") or (caso=1 and filtro="11") or
               (caso=2 and filtro="01") or caso=3 then periodo := 10; end if;
            if filtro /= anterior or fase >= periodo-1 then fase := 0;
            else fase := fase+1; end if;
            anterior := filtro;
            if caso=4 then entrada <= '0';
            elsif fase < periodo/2 then entrada <= '1'; else entrada <= '0'; end if;
        end if;
    end process;
    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until rising_edge(reloj); wait for 1 ns; end loop;
        end procedure;
        procedure muestra(c : natural; r,g,b : natural; codigo : std_logic_vector(1 downto 0)) is
        begin
            caso <= c; ciclos(30); iniciar <= '1';
            wait until ocupado = '1' for 1 us;
            assert ocupado = '1' and s2='0' and s3='0' severity failure;
            wait until s2='1' and s3='1' for 3 us;
            assert s2='1' and s3='1' report "Falta filtro verde" severity failure;
            wait until s2='0' and s3='1' for 3 us;
            assert s2='0' and s3='1' report "Falta filtro azul" severity failure;
            wait until lista='1' for 3 us; wait for 1 ns;
            assert lista='1' report "Falta pulso final TCS" severity failure;
            assert to_integer(unsigned(rojo))=r and to_integer(unsigned(verde))=g and
                   to_integer(unsigned(azul))=b report "Conteos RGB incorrectos" severity failure;
            assert color="00" and valida='0' report "Clasifica sin calibracion" severity failure;
            assert color_prueba=codigo report "Algoritmo sintetico incorrecto" severity failure;
            if codigo="00" then assert valida_prueba='0' severity failure;
            else assert valida_prueba='1' severity failure; end if;
            assert s0='1' and s1='0' report "Escala no es 20 por ciento" severity failure;
            ciclos(1); assert lista='0' report "Pulso lista demasiado largo" severity failure;
            ciclos(400); assert ocupado='0' and lista='0' report "Orden sostenida repite medicion" severity failure;
            iniciar <= '0'; ciclos(5);
        end procedure;
    begin
        ciclos(5); reinicio <= '0'; ciclos(5);
        muestra(0,10,5,4,"01"); muestra(1,5,10,4,"10");
        muestra(2,5,5,10,"11"); muestra(3,10,10,10,"00");
        muestra(4,0,0,0,"00");
        iniciar <= '1'; ciclos(40); reinicio <= '1'; ciclos(5);
        iniciar <= '0'; reinicio <= '0'; ciclos(5);
        assert ocupado='0' and lista='0' and rojo=x"0000" and verde=x"0000" and azul=x"0000"
            report "Reset durante medicion incorrecto" severity failure;
        report "OK: TCS3200, filtros RGB, conteos, calibracion, empates, reset y orden sostenida" severity note;
        terminar <= true; wait;
    end process;
end architecture;
```

## SystemAlfa/Pruebas_ModelSim/pwm_fisico_TB.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
entity pwm_fisico_TB is end;
architecture prueba of pwm_fisico_TB is
    signal clk:std_logic:='0';signal fin:boolean:=false;
    signal reset,habilitar:std_logic:='0';signal m,a,b,s:std_logic;
    signal duty:integer range 0 to 100:=0;signal ancho:integer range 1000 to 2000:=1500;
begin
    clk<=not clk after 500 ns when not fin else '0';
    U_M:entity work.control_motor_l298n generic map(100) port map(clk,reset,habilitar,duty,m,a,b);
    U_S:entity work.pwm_servo generic map(1) port map(clk,reset,habilitar,ancho,s);
    process
        variable altos:integer;variable t:time;
    begin
        reset<='1';wait for 10 us;reset<='0';habilitar<='1';
        for valor in 0 to 4 loop
            duty<=valor*25;wait for 300 us;altos:=0;
            for i in 1 to 100 loop wait until falling_edge(clk);if m='1' then altos:=altos+1;end if;end loop;
            assert altos=valor*25 report "Duty PWM incorrecto" severity failure;
        end loop;
        for valor in 0 to 2 loop
            ancho<=1000+valor*500;wait for 40 ms;
            wait until rising_edge(s);t:=now;wait until falling_edge(s);
            assert now-t=(1000+valor*500)*1 us report "Ancho servo incorrecto" severity failure;
        end loop;
        habilitar<='0';wait for 1 ns;assert m='0' and s='0' report "No deshabilita salidas" severity failure;
        habilitar<='1';wait for 1 ms;reset<='1';wait for 1 ns;
        assert m='0' and s='0' report "Reset no corta pulsos" severity failure;
        report "OK: PWM motor 0/25/50/75/100 y servo 1000/1500/2000 us" severity note;fin<=true;wait;
    end process;
end;
```

## SystemAlfa/Pruebas_ModelSim/SystemAlfa_Final_TB.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SystemAlfa_Final_TB is
end entity;

architecture prueba of SystemAlfa_Final_TB is
    signal reloj : std_logic := '0';
    signal reinicio_bajo : std_logic := '0';
    signal presencia, velocidad : std_logic := '1';
    signal color : std_logic_vector(1 downto 0) := "00";
    signal tamano : std_logic := '0';
    signal marcha : std_logic := '1';
    signal menu, siguiente, ver_tiempo, cantidades : std_logic := '0';
    signal ultimo, por_color : std_logic := '0';
    signal led_color : std_logic_vector(1 downto 0);
    signal led_tamano, linea, alarma, limite : std_logic;
    signal ruta : std_logic_vector(3 downto 0);
    signal h0, h1, h2, h3 : std_logic_vector(6 downto 0);
    signal fin : boolean := false;

    type tabla is array(0 to 9) of std_logic_vector(6 downto 0);

    constant patrones : tabla := (
        "1000000", "1111001", "0100100", "0110000", "0011001",
        "0010010", "0000010", "1111000", "0000000", "0010000"
    );

    function digito(s : std_logic_vector(6 downto 0))
        return integer is
    begin
        for i in 0 to 9 loop
            if s = patrones(i) then
                return i;
            end if;
        end loop;
        return -1;
    end function;

    function decimal(c, d, u : std_logic_vector(6 downto 0))
        return integer is
    begin
        if digito(c) < 0 or digito(d) < 0 or digito(u) < 0 then
            return -1;
        end if;
        return 100*digito(c) + 10*digito(d) + digito(u);
    end function;

begin

    reloj <= not reloj after 10 ns when not fin else '0';

    DUT : entity work.SystemAlfa_Final
        generic map (
            FRECUENCIA_RELOJ_HZ => 1000,
            CICLOS_FILTRO => 3,
            CICLOS_ATASCO => 10000
        )
        port map (
            RELOJ => reloj,
            REINICIO_BAJO => reinicio_bajo,
            PRESENCIA => presencia,
            CAMBIO_VELOCIDAD => velocidad,
            SELECTOR_COLOR => color,
            SELECTOR_TAMANO => tamano,
            LINEA_MARCHA => marcha,
            VER_HISTORIAL => menu,
            SIGUIENTE_HISTORIAL => siguiente,
            SELECCION_HISTORIAL => ver_tiempo,
            VER_CANTIDADES => cantidades,
            IR_ULTIMO => ultimo,
            CONTAR_POR_COLOR => por_color,
            LED_COLOR => led_color,
            LED_TAMANO => led_tamano,
            LINEA_ACTIVA => linea,
            RUTA_PIEZA => ruta,
            ALARMA => alarma,
            LED_LIMITE => limite,
            VISOR_0 => h0,
            VISOR_1 => h1,
            VISOR_2 => h2,
            VISOR_3 => h3, MARCHA_FISICA => open, EVENTO_VALIDO => open, NIVEL_FISICO => open, CATEGORIA_FISICA => open
        );

    estimulos : process
        variable tiempo_antes : integer;

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(reloj);
                wait for 1 ns;
            end loop;
        end procedure;

        procedure comprobar(n : natural) is
        begin
            -- Esperar la conversion decimal registrada (maximo 22 ciclos).
            esperar(24);
            assert decimal(h2, h1, h0) = n
                report "Valor decimal incorrecto: " & integer'image(n)
                severity failure;
        end procedure;

        procedure pulsar(signal mando : out std_logic) is
        begin
            mando <= '1';
            esperar(15);
            mando <= '0';
            esperar(15);
        end procedure;

        procedure ingresar(c : natural; t : std_logic) is
        begin
            color <= std_logic_vector(to_unsigned(c, 2));
            tamano <= t;
            esperar(15);

            presencia <= '0';
            esperar(20);

            presencia <= '1';
            esperar(20);
        end procedure;

        procedure reset_operativo(ciclos : positive := 5) is
        begin
            reinicio_bajo <= '0';
            esperar(ciclos);

            assert linea = '0' and alarma = '0'
                report "Reset no limpia linea/alarma"
                severity failure;

            reinicio_bajo <= '1';
            esperar(20);
        end procedure;

        procedure comprobar_marcha is
            variable encendido : boolean := false;
            variable apagado : boolean := false;
        begin
            -- Observar varios instantes: el LED parpadea.
            for i in 1 to 1100 loop
                esperar;

                if linea = '1' then
                    encendido := true;
                end if;

                if linea = '0' then
                    apagado := true;
                end if;
            end loop;

            assert encendido and apagado
                report "La cinta no parpadea con SW3 alto"
                severity failure;
        end procedure;

        procedure comprobar_cantidades(extra_rojo : natural := 0) is
        begin
            menu <= '1';
            cantidades <= '1';
            por_color <= '0';
            esperar(20);

            for i in 1 to 6 loop
                assert digito(h3) = i
                    report "Seleccion de categoria incorrecta"
                    severity failure;

                if i = 1 then
                    comprobar(i + extra_rojo);
                else
                    comprobar(i);
                end if;

                pulsar(siguiente);
            end loop;

            por_color <= '1';
            esperar(20);

            comprobar(3 + extra_rojo);
            pulsar(siguiente);
            comprobar(7);
            pulsar(siguiente);
            comprobar(11);

            cantidades <= '0';
            por_color <= '0';
            esperar(20);
        end procedure;

    begin

        reset_operativo;
        comprobar(0);
        comprobar_marcha;

        -- Rechazo con historial vacio: no debe crear el ID 1.
        ingresar(0, '0');
        comprobar(0);

        assert alarma = '1' and ruta = "1000"
            report "No indica el rechazo"
            severity failure;

        menu <= '1';
        esperar(20);

        assert h0 = "1111111" and h1 = "1111111" and
               h2 = "1111111" and h3 = "1111111"
            report "Se guardo una pieza invalida en historial vacio"
            severity failure;

        menu <= '0';
        reset_operativo;

        -- 1+2+3+4+5+6 = 21 piezas validas.
        for categoria in 1 to 6 loop
            for i in 1 to categoria loop
                if categoria mod 2 = 0 then
                    ingresar((categoria+1)/2, '1');
                else
                    ingresar((categoria+1)/2, '0');
                end if;
            end loop;
        end loop;

        comprobar(21);

        assert h3 = patrones(0)
            report "Se esperaba 0021"
            severity failure;

        comprobar_cantidades;

        comprobar(21);
        pulsar(siguiente);
        comprobar(14);
        pulsar(ultimo);
        comprobar(21);

        ver_tiempo <= '1';
        esperar(40);
        tiempo_antes := decimal(h2, h1, h0);

        ver_tiempo <= '0';
        menu <= '0';
        esperar(20);

        -- Ninguno de los dos rechazos ocupa ID ni RAM.
        for t in 0 to 1 loop

            if t = 0 then
                ingresar(0, '0');
            else
                ingresar(0, '1');
            end if;

            comprobar(21);

            assert alarma = '1' and linea = '0'
                report "Rechazo no detiene la cinta"
                severity failure;

            menu <= '1';
            esperar(20);
            comprobar(21);

            assert led_color = "11" and led_tamano = '1'
                report "El rechazo sobrescribio la ultima pieza valida"
                severity failure;

            pulsar(siguiente);
            comprobar(14);

            pulsar(ultimo);
            comprobar(21);

            comprobar_cantidades;

            ver_tiempo <= '1';
            esperar(40);

            assert decimal(h2, h1, h0) = tiempo_antes
                report "El rechazo altero el tiempo guardado"
                severity failure;

            ver_tiempo <= '0';
            menu <= '0';

            reset_operativo;
            comprobar(21);

            -- Debe funcionar sin mover SW3.
            comprobar_marcha;

        end loop;

        -- Reset largo: conservar datos y seguir contando tiempo.
        reset_operativo(2200);
        comprobar(21);
        comprobar_marcha;

        ingresar(1, '0');
        comprobar(22);

        menu <= '1';
        esperar(20);

        -- La siguiente pieza valida recibe ID 22, sin saltos.
        comprobar(22);

        ver_tiempo <= '1';
        esperar(40);

        assert decimal(h2, h1, h0) >= tiempo_antes + 2
            report "Reset borro o detuvo el tiempo"
            severity failure;

        ver_tiempo <= '0';
        comprobar_cantidades(1);

        menu <= '0';
        esperar(20);

        -- SW3 bajo debe mantener la cinta detenida tras reset.
        marcha <= '0';
        esperar(20);
        reset_operativo;

        for i in 1 to 600 loop
            esperar;

            assert linea = '0'
                report "Marcha con SW3 bajo"
                severity failure;
        end loop;

        ingresar(2, '0');
        comprobar(22);

        menu <= '1';
        esperar(20);
        comprobar(22);

        report "OK: SystemAlfa_Final_TB" severity note;

        fin <= true;
        wait;

    end process;

end architecture;
```

## SystemAlfa/Pruebas_ModelSim/SystemAlfa_Hardware_TB.vhd - NUEVO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity SystemAlfa_Hardware_TB is end;
architecture prueba of SystemAlfa_Hardware_TB is
    signal reloj:std_logic:='0';signal terminado:boolean:=false;
    signal presencia:std_logic:='1';signal echo,trig,tcs_out,s0,s1,s2,s3:std_logic:='0';
    signal botones:std_logic_vector(2 downto 0):="111";
    signal sw:std_logic_vector(9 downto 0):=(others=>'0');
    signal leds:std_logic_vector(9 downto 0);
    signal h0,h1,h2,h3,extv,extc:std_logic_vector(6 downto 0);
    signal pwm,in1,in2,servo1,servo2:std_logic;
    signal cats:std_logic_vector(3 downto 0);
    signal muestra:integer range 0 to 3:=1;
    signal ancho_echo:time:=232 us;
    signal responder:boolean:=true;
    function segmento(n:integer) return std_logic_vector is
    begin
        case n is
            when 0=>return "1000000";when 1=>return "1111001";when 2=>return "0100100";
            when 3=>return "0110000";when 4=>return "0011001";when 5=>return "0010010";
            when 6=>return "0000010";when 7=>return "1111000";when 8=>return "0000000";
            when 9=>return "0010000";when others=>return "1111111";
        end case;
    end;
begin
    reloj<=not reloj after 500 ns when not terminado else '0';
    U:entity work.SystemAlfa_Hardware
        generic map(FRECUENCIA_RELOJ_HZ=>1000000,CICLOS_FILTRO=>3,CICLOS_PRESENCIA=>3,CICLOS_TICK=>1000,
                    VENTANA_COLOR=>3000,ASENTAR_COLOR=>50,CICLOS_PWM_MOTOR=>100,CICLOS_US_SERVO=>1,INTERVALO_HC_US=>6100)
        port map(reloj,presencia,echo,tcs_out,trig,s0,s1,s2,s3,botones,sw,leds,h0,h1,h2,h3,
                 pwm,in1,in2,servo1,servo2,cats,extv,extc);
    -- Modelo electrico HC: eco proporcional a distancia, independiente del VHDL.
    process
    begin
        wait until falling_edge(trig);
        if responder then wait for 100 us;echo<='1';wait for ancho_echo;echo<='0';end if;
    end process;
    -- Emite los conteos aproximados de calibracion en ventanas de 3 ms.
    process
        variable pulsos:positive;variable filtro:std_logic_vector(1 downto 0);
    begin
        filtro:=s2&s3;
        case muestra is
            when 1=>case filtro is when "00"=>pulsos:=64;when "11"=>pulsos:=29;when others=>pulsos:=39;end case;
            when 2=>case filtro is when "00"=>pulsos:=35;when "11"=>pulsos:=55;when others=>pulsos:=44;end case;
            when 3=>case filtro is when "00"=>pulsos:=29;when "11"=>pulsos:=33;when others=>pulsos:=58;end case;
            when others=>case filtro is when "00"=>pulsos:=121;when "11"=>pulsos:=101;when others=>pulsos:=105;end case;
        end case;
        tcs_out<='0';wait for 1500 us/pulsos;tcs_out<='1';wait for 1500 us/pulsos;
    end process;
    process
        procedure pulsar(n:integer) is
        begin botones(n)<='0';wait for 25 us;botones(n)<='1';wait for 25 us;end;
        procedure pagina(p:integer;v:integer:=0) is
        begin
            sw(3)<='0';wait for 60 us;
            sw(0)<='1';sw(9 downto 4)<=std_logic_vector(to_unsigned(p,6));
            sw(2 downto 1)<=std_logic_vector(to_unsigned(v,2));wait for 60 us;
        end;
        procedure numero(n:integer) is
        begin
            assert h0=segmento(n mod 10) and h1=segmento((n/10) mod 10) and h2=segmento((n/100) mod 10)
                report "Total inesperado, esperado " & integer'image(n) severity failure;
        end;
        procedure reiniciar is
        begin
            botones(1)<='0';wait for 40 us;
            assert pwm='0' and in1='0' report "Motor activo durante reset" severity failure;
            botones(1)<='1';wait for 100 us;
            assert in1='0' report "Rearranque sin rearme SW3" severity failure;
            sw(3)<='0';wait for 100 us;sw(3)<='1';wait for 100 us;
        end;
        procedure pieza(c:integer;t:time;esperado:integer) is
        begin
            muestra<=c;ancho_echo<=t;presencia<='0';wait for 30 us;
            assert in1='0' report "No se detuvo para medir" severity failure;
            wait until in1='1' for 400 ms;
            assert in1='1' and leds(8)='0' report "No reanudo pieza valida" severity failure;
            numero(esperado);presencia<='1';wait for 260 ms;
            assert in1='1' and leds(8)='0' report "No termino recorrido" severity failure;
        end;
        variable inicio:time;
    begin
        wait for 100 us;
        sw(3)<='1';wait for 200 us;
        assert in1='0' and leds(9)='1' report "Arranca sin calibracion" severity failure;
        -- Posiciones de reposo 1500 us y desvio 1700 us, confirmadas por usuario.
        for p in 1 to 4 loop
            pagina(p);
            if p=1 or p=3 then pulsar(0);pulsar(2);
            else for j in 1 to 8 loop pulsar(0);end loop;end if;
        end loop;
        for v in 0 to 3 loop
            pagina(0,v);for j in 1 to 10+v loop pulsar(0);end loop;
            pagina(7,v);sw(3)<='1';wait for 60 us;pulsar(0);
            assert in1='1' report "No inicia cronometro" severity failure;
            wait for 80 ms;pulsar(0);wait for 40 ms;pulsar(0);wait for 80 ms;pulsar(0);
            wait for 100 us;
            assert in1='0' and leds(9)='1' report "No guarda calibracion" severity failure;
        end loop;
        -- Regreso al automatico, conservando configuracion en los cuatro niveles.
        sw(3)<='0';wait for 100 us;sw<=(others=>'0');wait for 100 us;sw(3)<='1';wait for 100 us;
        assert in1='1' and leds(9)='0' report "Automatico no preparado" severity failure;
        -- 21 validas: las seis combinaciones, no solo un color.
        for i in 1 to 21 loop
            if i mod 2=0 then pieza(((i-1)/2) mod 3+1,139 us,i);
            else pieza(((i-1)/2) mod 3+1,232 us,i);end if;
        end loop;
        assert h3=segmento(0) and h2=segmento(0) and h1=segmento(2) and h0=segmento(1)
            report "21 no se muestra como 0021" severity failure;
        -- Rechazo blanco: no consume total ni ID.
        muestra<=0;presencia<='0';wait for 200 ms;
        assert leds(8)='1' and in1='0' report "Falta rechazo/paro" severity failure;
        numero(21);presencia<='1';reiniciar;numero(21);
        sw(4)<='1';wait for 100 us;numero(21);
        assert h3="1111111" report "Historial debe apagar HEX3" severity failure;
        sw(4)<='0';wait for 100 us;
        -- Verde pendiente no se oculta: esta prueba solo comprueba muestras sinteticas.
        pieza(1,232 us,22);
        -- Servo 1 se abre una sola vez y no sigue el menu.
        muestra<=1;ancho_echo<=232 us;presencia<='0';wait until in1='0';wait until in1='1' for 400 ms;
        numero(23);presencia<='1';wait for 85 ms;
        wait until rising_edge(servo1);inicio:=now;wait until falling_edge(servo1);
        assert now-inicio=1700 us report "Servo1 no alcanza ancho de desvio" severity failure;
        wait until rising_edge(servo2);inicio:=now;wait until falling_edge(servo2);
        assert now-inicio=1500 us report "Servo2 se mueve para categoria1" severity failure;
        wait for 200 ms;sw(4)<='1';wait for 100 us;
        wait until rising_edge(servo1);inicio:=now;wait until falling_edge(servo1);
        assert now-inicio=1500 us report "Consulta de historial mueve servo" severity failure;
        sw(4)<='0';wait for 100 us;
        -- Cambio de velocidad durante captura queda pendiente, no cancela pieza.
        muestra<=1;ancho_echo<=139 us;presencia<='0';wait for 2 ms;pulsar(2);
        wait until in1='1' for 400 ms;assert leds(8)='0' report "Cambio pendiente cancela pieza" severity failure;
        assert h3=segmento(0) report "Velocidad cambio durante pieza" severity failure;
        numero(24);presencia<='1';wait for 125 ms;
        wait until rising_edge(servo2);inicio:=now;wait until falling_edge(servo2);
        assert now-inicio=1700 us report "Servo2 no abre para categoria2" severity failure;
        wait until rising_edge(servo1);inicio:=now;wait until falling_edge(servo1);
        assert now-inicio=1500 us report "Servo1 se mueve para categoria2" severity failure;
        wait for 260 ms;
        assert h3=segmento(1) report "Cambio pendiente no aplicado" severity failure;
        -- Reset con SW3 arriba debe exigir el paso por 0; la sesion permanece.
        reiniciar;numero(24);assert h3=segmento(0) report "Reset no devuelve nivel0" severity failure;
        -- Nueva pieza durante transporte: incidencia sin segundo conteo.
        muestra<=3;ancho_echo<=232 us;presencia<='0';wait until in1='0';wait until in1='1' for 400 ms;
        numero(25);presencia<='1';wait for 2 ms;presencia<='0';wait for 100 us;
        assert in1='0' and leds(8)='1' report "No detecta segunda pieza" severity failure;
        numero(25);presencia<='1';reiniciar;
        -- Distancia dudosa 3 cm: reintenta y rechaza.
        ancho_echo<=174 us;presencia<='0';wait for 200 ms;
        assert leds(8)='1' and in1='0' report "Zona dudosa aceptada" severity failure;
        numero(25);presencia<='1';reiniciar;
        -- Sin eco tampoco genera una pieza grande por distancia cero.
        responder<=false;presencia<='0';wait for 200 ms;
        assert leds(8)='1' and in1='0' report "Sin eco no detiene" severity failure;
        numero(25);presencia<='1';responder<=true;reiniciar;
        -- Retirar pieza antes de terminar la medicion cancela captura.
        presencia<='0';wait for 5 ms;presencia<='1';wait for 100 us;
        assert leds(8)='1' and in1='0' report "Retiro prematuro no detectado" severity failure;
        numero(25);
        presencia<='1';reiniciar;
        -- Cambiar el porcentaje invalida solo los tiempos de ese nivel.
        pagina(0,0);pulsar(0);
        sw(3)<='0';wait for 100 us;sw<=(others=>'0');wait for 100 us;sw(3)<='1';wait for 100 us;
        assert in1='0' and leds(9)='1' report "Usa tiempos viejos despues de cambiar PWM" severity failure;
        numero(25);
        report "OK: integracion completa, 6 categorias, 0021, rechazo/ID, PWM/servos, rearme, calibracion, consultas, incidencias" severity note;
        terminado<=true;wait;
    end process;
    process
    begin wait for 20 sec;assert terminado report "Timeout del testbench de integracion" severity failure;wait;end process;
end;
```

## SystemAlfa/Pruebas_ModelSim/SystemAlfa_Limites_TB.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TEST BENCH DEL SISTEMA COMPLETO
-- Seis categorias, conteo por categoria y color,
-- historial decimal, reinicio, alarmas y limite.
-- SOLO PARA SIMULACION.

entity SystemAlfa_Limites_TB is
end entity SystemAlfa_Limites_TB;

architecture SystemAlfa_Limites_TB_arch
of SystemAlfa_Limites_TB is

    ------------------------------------------------------------
    -- COMPONENTE QUE SE VA A PROBAR
    ------------------------------------------------------------

    component SystemAlfa_Final is

        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000;
            CICLOS_ATASCO       : positive := 250000000
        );

        port (
            RELOJ,
            REINICIO_BAJO,
            PRESENCIA,
            CAMBIO_VELOCIDAD :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO,
            LINEA_MARCHA :
                in std_logic;

            VER_HISTORIAL,
            SIGUIENTE_HISTORIAL :
                in std_logic;

            SELECCION_HISTORIAL,
            VER_CANTIDADES :
                in std_logic;

            IR_ULTIMO,
            CONTAR_POR_COLOR :
                in std_logic;

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO,
            LINEA_ACTIVA :
                out std_logic;

            RUTA_PIEZA :
                out std_logic_vector(3 downto 0);

            ALARMA,
            LED_LIMITE :
                out std_logic;

            VISOR_0,
            VISOR_1,
            VISOR_2,
            VISOR_3 :
                out std_logic_vector(6 downto 0);
            MARCHA_FISICA, EVENTO_VALIDO : out std_logic;
            NIVEL_FISICO : out std_logic_vector(1 downto 0);
            CATEGORIA_FISICA : out std_logic_vector(3 downto 0)
        );

    end component;

    ------------------------------------------------------------
    -- SENALES DEL TEST BENCH
    ------------------------------------------------------------

    signal RELOJ_TB :
        std_logic := '0';

    signal REINICIO_BAJO_TB :
        std_logic := '0';

    signal PRESENCIA_TB :
        std_logic := '1';

    signal CAMBIO_VELOCIDAD_TB :
        std_logic := '1';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal LINEA_MARCHA_TB :
        std_logic := '0';

    signal VER_HISTORIAL_TB :
        std_logic := '0';

    signal SIGUIENTE_HISTORIAL_TB :
        std_logic := '0';

    signal SELECCION_HISTORIAL_TB :
        std_logic := '0';

    signal VER_CANTIDADES_TB :
        std_logic := '0';

    signal IR_ULTIMO_TB :
        std_logic := '0';

    signal CONTAR_POR_COLOR_TB :
        std_logic := '0';

    ------------------------------------------------------------
    -- SALIDAS
    ------------------------------------------------------------

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal LINEA_ACTIVA_TB :
        std_logic;

    signal RUTA_PIEZA_TB :
        std_logic_vector(3 downto 0);

    signal ALARMA_TB :
        std_logic;

    signal LED_LIMITE_TB :
        std_logic;

    signal VISOR_0_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_1_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_2_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_3_TB :
        std_logic_vector(6 downto 0);

    signal FIN_TB :
        boolean := false;

    ------------------------------------------------------------
    -- TABLA PARA LEER LOS DISPLAYS
    ------------------------------------------------------------

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", -- 0
        "1111001", -- 1
        "0100100", -- 2
        "0110000", -- 3
        "0011001", -- 4
        "0010010", -- 5
        "0000010", -- 6
        "1111000", -- 7
        "0000000", -- 8
        "0010000", -- 9
        "0001000", -- A
        "0000011", -- b
        "1000110", -- C
        "0100001", -- d
        "0000110", -- E
        "0001110"  -- F
    );

    ------------------------------------------------------------
    -- FUNCION PARA LEER UN DISPLAY
    ------------------------------------------------------------

    function leer_hex(
        s : std_logic_vector(6 downto 0)
    ) return integer is
    begin

        for i in 0 to 15 loop

            if s = PATRONES(i) then
                return i;
            end if;

        end loop;

        return -1;

    end function;

    ------------------------------------------------------------
    -- FUNCION PARA LEER TRES DISPLAYS DECIMALES
    ------------------------------------------------------------

    function leer_decimal(
        centenas,
        decenas,
        unidades :
            std_logic_vector(6 downto 0)
    ) return integer is

        variable c, d, u : integer;

    begin

        c := leer_hex(centenas);
        d := leer_hex(decenas);
        u := leer_hex(unidades);

        if
            c < 0 or c > 9 or
            d < 0 or d > 9 or
            u < 0 or u > 9
        then
            return -1;
        end if;

        return 100*c + 10*d + u;

    end function;

begin

    ------------------------------------------------------------
    -- RELOJ
    -- 20 ns = 50 MHz
    ------------------------------------------------------------

    RELOJ_TB <=
        not RELOJ_TB after 10 ns
        when not FIN_TB
        else '0';

    ------------------------------------------------------------
    -- DUT1 = SYSTEM ALFA COMPLETO
    ------------------------------------------------------------

    DUT1 : SystemAlfa_Final

        generic map (
            -- Valores reducidos solamente para simulacion.
            FRECUENCIA_RELOJ_HZ => 1000,
            CICLOS_FILTRO       => 3,
            CICLOS_ATASCO       => 10000
        )

        port map (

            RELOJ =>
                RELOJ_TB,

            REINICIO_BAJO =>
                REINICIO_BAJO_TB,

            PRESENCIA =>
                PRESENCIA_TB,

            CAMBIO_VELOCIDAD =>
                CAMBIO_VELOCIDAD_TB,

            SELECTOR_COLOR =>
                SELECTOR_COLOR_TB,

            SELECTOR_TAMANO =>
                SELECTOR_TAMANO_TB,

            LINEA_MARCHA =>
                LINEA_MARCHA_TB,

            VER_HISTORIAL =>
                VER_HISTORIAL_TB,

            SIGUIENTE_HISTORIAL =>
                SIGUIENTE_HISTORIAL_TB,

            SELECCION_HISTORIAL =>
                SELECCION_HISTORIAL_TB,

            VER_CANTIDADES =>
                VER_CANTIDADES_TB,

            IR_ULTIMO =>
                IR_ULTIMO_TB,

            CONTAR_POR_COLOR =>
                CONTAR_POR_COLOR_TB,

            LED_COLOR =>
                LED_COLOR_TB,

            LED_TAMANO =>
                LED_TAMANO_TB,

            LINEA_ACTIVA =>
                LINEA_ACTIVA_TB,

            RUTA_PIEZA =>
                RUTA_PIEZA_TB,

            ALARMA =>
                ALARMA_TB,

            LED_LIMITE =>
                LED_LIMITE_TB,

            VISOR_0 =>
                VISOR_0_TB,

            VISOR_1 =>
                VISOR_1_TB,

            VISOR_2 =>
                VISOR_2_TB,

            VISOR_3 =>
                VISOR_3_TB, MARCHA_FISICA => open, EVENTO_VALIDO => open, NIVEL_FISICO => open, CATEGORIA_FISICA => open
        );

    ------------------------------------------------------------
    -- GENERACION DE ESTIMULOS
    ------------------------------------------------------------

    STIMULUS : process
        variable tiempo_antes, tiempo_despues : integer;

        --------------------------------------------------------
        -- ESPERAR CICLOS DE RELOJ
        --------------------------------------------------------

        procedure esperar(
            n : positive := 1
        ) is

        begin

            for i in 1 to n loop

                wait until rising_edge(RELOJ_TB);

                -- Se espera un poco para que las senales
                -- terminen de actualizarse.
                wait for 1 ns;

            end loop;

        end procedure;

        --------------------------------------------------------
        -- PULSO PARA SWITCHES DE MENU
        --------------------------------------------------------

        procedure pulsar_alto(
            signal mando : out std_logic
        ) is

        begin

            mando <= '1';
            esperar(10);

            mando <= '0';
            esperar(10);

        end procedure;

        --------------------------------------------------------
        -- INGRESAR UNA CATEGORIA
        --------------------------------------------------------

        procedure ingresar(
            categoria : positive
        ) is

        begin

            -- Categorias:
            -- 1 rojo pequeno
            -- 2 rojo grande
            -- 3 verde pequeno
            -- 4 verde grande
            -- 5 azul pequeno
            -- 6 azul grande

            SELECTOR_COLOR_TB <=
                std_logic_vector(
                    to_unsigned(
                        (categoria + 1) / 2,
                        2
                    )
                );

            if categoria mod 2 = 0 then

                SELECTOR_TAMANO_TB <= '1';

            else

                SELECTOR_TAMANO_TB <= '0';

            end if;

            -- Esperar que los atributos se estabilicen.
            esperar(8);

            -- BUTTON0 presionado.
            PRESENCIA_TB <= '0';

            esperar(10);

            -- BUTTON0 liberado.
            PRESENCIA_TB <= '1';

            esperar(10);

        end procedure;

        --------------------------------------------------------
        -- COMPROBAR TOTAL NORMAL
        --------------------------------------------------------

        procedure comprobar_total(
            n : natural
        ) is

        begin
            -- Dos conversiones completas como maximo tras cambiar la entrada.
            esperar(24);


            assert
                leer_decimal(
                    VISOR_2_TB,
                    VISOR_1_TB,
                    VISOR_0_TB
                ) = n

                report
                    "Total incorrecto. Esperado: "
                    & integer'image(n)

                severity failure;

        end procedure;

        --------------------------------------------------------
        -- COMPROBAR VALOR DE CONSULTA
        --------------------------------------------------------

        procedure comprobar_consulta(
            n : natural
        ) is

        begin
            -- Dos conversiones completas como maximo tras cambiar la entrada.
            esperar(24);


            assert
                leer_decimal(
                    VISOR_2_TB,
                    VISOR_1_TB,
                    VISOR_0_TB
                ) = n

                report
                    "Consulta incorrecta. Esperado: "
                    & integer'image(n)

                severity failure;

        end procedure;

        --------------------------------------------------------
        -- REINICIAR EL SISTEMA
        --------------------------------------------------------

        procedure reiniciar is

        begin

            LINEA_MARCHA_TB <= '0';
            PRESENCIA_TB <= '1';

            CAMBIO_VELOCIDAD_TB <= '1';

            VER_HISTORIAL_TB <= '0';
            VER_CANTIDADES_TB <= '0';
            CONTAR_POR_COLOR_TB <= '0';

            SELECCION_HISTORIAL_TB <= '0';
            SIGUIENTE_HISTORIAL_TB <= '0';
            IR_ULTIMO_TB <= '0';

            REINICIO_BAJO_TB <= '0';

            esperar(5);

            REINICIO_BAJO_TB <= '1';

            esperar(12);

            -- Rearmar la linea.
            LINEA_MARCHA_TB <= '1';

            esperar(8);

        end procedure;

    begin
        reiniciar;
        for i in 1 to 999 loop
            ingresar(1);
            comprobar_total(i);
        end loop;
        assert LED_LIMITE_TB = '1' and LINEA_ACTIVA_TB = '0'
            report "No se detuvo al llegar a 999" severity failure;
        ingresar(2);
        comprobar_total(999);
        VER_HISTORIAL_TB <= '1';
        esperar(15);
        comprobar_consulta(999);
        pulsar_alto(SIGUIENTE_HISTORIAL_TB);
        comprobar_consulta(992);
        reiniciar;
        comprobar_total(999);
        assert LED_LIMITE_TB = '1'
            report "Reset borro el limite de sesion" severity failure;
        ingresar(3);
        comprobar_total(999);
        report "OK: SystemAlfa_Limites_TB" severity note;
        FIN_TB <= true;
        wait;
    end process STIMULUS;
end architecture SystemAlfa_Limites_TB_arch;
```

## SystemAlfa/SystemAlfa_Final/SystemAlfa_Final.qsf - MODIFICADO

```tcl
set_global_assignment -name VHDL_FILE ../comunes/paquete_funciones.vhd
# -------------------------------------------------------------------------- #
#
# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.
#
# -------------------------------------------------------------------------- #
#
# Quartus II 64-Bit
# Version 13.1.0 Build 162 10/23/2013 SJ Web Edition
# Date created = 13:00:30  September 22, 2026
#
# -------------------------------------------------------------------------- #
#
# Notes:
#
# 1) The default values for assignments are stored in the file:
#		SystemAlfa_Final_assignment_defaults.qdf
#    If this file doesn't exist, see file:
#		assignment_defaults.qdf
#
# 2) Altera recommends that you do not modify this file. This
#    file is updated automatically by the Quartus II software
#    and any changes you make may be lost or overwritten.
#
# -------------------------------------------------------------------------- #


set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name TOP_LEVEL_ENTITY SystemAlfa_Placa
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 13.1
set_global_assignment -name PROJECT_CREATION_TIME_DATE "13:00:30  SEPTEMBER 22, 2026"
set_global_assignment -name LAST_QUARTUS_VERSION 13.1
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 484
set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 6
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_location_assignment PIN_G21 -to CLOCK_50
set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]
set_location_assignment PIN_J6 -to SW[0]
set_location_assignment PIN_H5 -to SW[1]
set_location_assignment PIN_H6 -to SW[2]
set_location_assignment PIN_G4 -to SW[3]
set_location_assignment PIN_G5 -to SW[4]
set_location_assignment PIN_J7 -to SW[5]
set_location_assignment PIN_H7 -to SW[6]
set_location_assignment PIN_E3 -to SW[7]
set_location_assignment PIN_E4 -to SW[8]
set_location_assignment PIN_D2 -to SW[9]
set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_location_assignment PIN_E11 -to HEX0[0]
set_location_assignment PIN_F11 -to HEX0[1]
set_location_assignment PIN_H12 -to HEX0[2]
set_location_assignment PIN_H13 -to HEX0[3]
set_location_assignment PIN_G12 -to HEX0[4]
set_location_assignment PIN_F12 -to HEX0[5]
set_location_assignment PIN_F13 -to HEX0[6]
set_location_assignment PIN_A13 -to HEX1[0]
set_location_assignment PIN_B13 -to HEX1[1]
set_location_assignment PIN_C13 -to HEX1[2]
set_location_assignment PIN_A14 -to HEX1[3]
set_location_assignment PIN_B14 -to HEX1[4]
set_location_assignment PIN_E14 -to HEX1[5]
set_location_assignment PIN_A15 -to HEX1[6]
set_location_assignment PIN_D15 -to HEX2[0]
set_location_assignment PIN_A16 -to HEX2[1]
set_location_assignment PIN_B16 -to HEX2[2]
set_location_assignment PIN_E15 -to HEX2[3]
set_location_assignment PIN_A17 -to HEX2[4]
set_location_assignment PIN_B17 -to HEX2[5]
set_location_assignment PIN_F14 -to HEX2[6]
set_location_assignment PIN_B18 -to HEX3[0]
set_location_assignment PIN_F15 -to HEX3[1]
set_location_assignment PIN_A19 -to HEX3[2]
set_location_assignment PIN_B19 -to HEX3[3]
set_location_assignment PIN_C19 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_G15 -to HEX3[6]
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name VHDL_FILE ../comunes/rom_categorias.vhd
set_global_assignment -name VHDL_FILE ../comunes/memoria_ram_historial.vhd
set_global_assignment -name VHDL_FILE ../comunes/maquina_estados_control.vhd
set_global_assignment -name VHDL_FILE ../comunes/codificador_direccion.vhd
set_global_assignment -name VHDL_FILE ../comunes/historial_sesion.vhd
set_global_assignment -name VHDL_FILE ../comunes/conteo_categorias.vhd
set_global_assignment -name VHDL_FILE ../comunes/clasificador_ruta.vhd
set_global_assignment -name VHDL_FILE ../comunes/tabla_reglas.vhd
set_global_assignment -name VHDL_FILE ../comunes/supervisor_error.vhd
set_global_assignment -name VHDL_FILE ../comunes/sincronizador.vhd
set_global_assignment -name VHDL_FILE ../comunes/selector_velocidad.vhd
set_global_assignment -name VHDL_FILE ../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../comunes/registro_tamano.vhd
set_global_assignment -name VHDL_FILE ../comunes/registro_color.vhd
set_global_assignment -name VHDL_FILE ../comunes/historial.vhd
set_global_assignment -name VHDL_FILE ../comunes/filtro_boton.vhd
set_global_assignment -name VHDL_FILE ../comunes/divisor_frecuencia.vhd
set_global_assignment -name VHDL_FILE ../comunes/decodificador_7segmentos.vhd
set_global_assignment -name VHDL_FILE ../comunes/control_linea.vhd
set_global_assignment -name VHDL_FILE ../comunes/contador_segundos.vhd
set_global_assignment -name VHDL_FILE ../comunes/contador_ascendente.vhd
set_global_assignment -name VHDL_FILE ../comunes/captura_pieza.vhd
set_global_assignment -name VHDL_FILE SystemAlfa_Final.vhd
set_global_assignment -name VHDL_FILE SystemAlfa_Placa.vhd
set_global_assignment -name SDC_FILE ../comunes/reloj.sdc
set_global_assignment -name VHDL_FILE ../comunes/conversor_binario_decimal.vhd
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
set_global_assignment -name VHDL_FILE ../comunes/conversor_decimal_reloj.vhd
```

## SystemAlfa/SystemAlfa_Final/SystemAlfa_Final.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SystemAlfa_Final is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000;
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA, CAMBIO_VELOCIDAD : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);
        SELECTOR_TAMANO, LINEA_MARCHA : in std_logic;
        VER_HISTORIAL, SIGUIENTE_HISTORIAL : in std_logic;
        SELECCION_HISTORIAL, VER_CANTIDADES : in std_logic;
        IR_ULTIMO, CONTAR_POR_COLOR : in std_logic;
        LED_COLOR : out std_logic_vector(1 downto 0);
        LED_TAMANO, LINEA_ACTIVA : out std_logic;
        RUTA_PIEZA : out std_logic_vector(3 downto 0);
        ALARMA, LED_LIMITE : out std_logic;
        VISOR_0, VISOR_1, VISOR_2, VISOR_3 :
            out std_logic_vector(6 downto 0);
        MARCHA_FISICA, EVENTO_VALIDO : out std_logic;
        NIVEL_FISICO : out std_logic_vector(1 downto 0);
        CATEGORIA_FISICA : out std_logic_vector(3 downto 0)
    );
end entity SystemAlfa_Final;

architecture estructural of SystemAlfa_Final is

    -- Captura y clasificacion.
    signal reinicio_alto, reinicio_operacion, nueva, presente : std_logic;

    -- Solo se activa al configurar la FPGA.
    -- BUTTON(1) nunca borra la sesion.
    signal arranque_sesion : std_logic_vector(3 downto 0) := "1111";
    signal reinicio_sesion : std_logic;
    signal marcha_filtrada : std_logic;
    signal guardar_sesion, contar_sesion : std_logic;

    signal tamano_actual, pieza_valida : std_logic;
    signal color_actual : std_logic_vector(1 downto 0);
    signal categoria_actual : std_logic_vector(3 downto 0);

    -- Transporte y conteo.
    signal pulso_linea, marcha_real, bloqueo : std_logic;
    signal registrar_evento, limite_total, limite_historial : std_logic;
    signal total, cantidad_consultada : std_logic_vector(9 downto 0);

    -- Maquina de estados.
    signal contar_pieza_fsm : std_logic;
    signal alarma_fsm : std_logic;
    signal ocupado_fsm : std_logic;
    signal estado_fsm : std_logic_vector(2 downto 0);
    signal error_supervisor : std_logic;
    signal error_total : std_logic;

    -- Tiempo e historial.
    signal pulso_segundo : std_logic;
    signal segundos, tiempo_guardado : std_logic_vector(7 downto 0);
    signal id_guardado : std_logic_vector(9 downto 0);
    signal color_guardado : std_logic_vector(1 downto 0);
    signal tamano_guardado, registro_valido : std_logic;

    -- Ultimo evento procesado.
    signal ultimo_color : std_logic_vector(1 downto 0);
    signal ultimo_tamano, hay_pieza : std_logic;

    -- Menu.
    signal modo_entrada, modo : std_logic_vector(3 downto 0);
    signal consulta_registros, consulta_cantidades : std_logic;
    signal siguiente, ultimo : std_logic;
    signal seleccion : unsigned(2 downto 0) := "001";
    signal cantidades_antes, por_color_antes : std_logic;

    -- Datos visibles.
    signal color_vista : std_logic_vector(1 downto 0);
    signal tamano_vista, hay_dato_visible : std_logic;
    signal categoria_vista : std_logic_vector(3 downto 0);

    -- Conversion decimal.
    signal numero_consulta : std_logic_vector(9 downto 0);
    signal total_c, total_d, total_u : std_logic_vector(3 downto 0);
    signal consulta_c, consulta_d, consulta_u :
        std_logic_vector(3 downto 0);

    signal visor_total_c, visor_total_d, visor_total_u :
        std_logic_vector(6 downto 0);

    signal visor_consulta_c, visor_consulta_d, visor_consulta_u :
        std_logic_vector(6 downto 0);

    signal visor_velocidad, visor_seleccion :
        std_logic_vector(6 downto 0);

    signal digito_seleccion : std_logic_vector(3 downto 0);

begin
    -- Ordenes de operacion, independientes del menu de consultas.
    MARCHA_FISICA <= marcha_real;
    EVENTO_VALIDO <= contar_sesion;
    CATEGORIA_FISICA <= categoria_actual;

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => RELOJ,
            reinicio_bajo => REINICIO_BAJO,
            reinicio_salida => reinicio_operacion
        );

    -- Reinicio de sesion solamente al configurar la FPGA.
    process(RELOJ)
    begin
        if rising_edge(RELOJ) then
            arranque_sesion <= arranque_sesion(2 downto 0) & '0';
        end if;
    end process;

    reinicio_sesion <= arranque_sesion(3);
    reinicio_alto <= reinicio_operacion or reinicio_sesion;

    -- Al soltar reset, se vuelve a leer el nivel actual de SW3.
    U_MARCHA_FILTRADA : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_entrada => LINEA_MARCHA,
            pulso_salida => open,
            estado_salida => marcha_filtrada
        );

    -- La FSM avisa tambien de los rechazos para encender su indicacion.
    -- La RAM solo guarda piezas validas: un rechazo NO consume ID.
    guardar_sesion <=
        registrar_evento and pieza_valida and not reinicio_alto;

    contar_sesion <=
        contar_pieza_fsm and not reinicio_alto;

    U_CAPTURA : entity work.captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            presencia_baja => PRESENCIA,
            color_selector => SELECTOR_COLOR,
            tamano_selector => SELECTOR_TAMANO,
            nueva_pieza => nueva,
            presencia_activa => presente,
            color => color_actual,
            tamano => tamano_actual
        );

    U_REGLAS : entity work.tabla_reglas
        port map (
            color => color_actual,
            tamano => tamano_actual,
            ruta => categoria_actual,
            valida => pieza_valida
        );

    U_VELOCIDAD : entity work.selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_bajo => CAMBIO_VELOCIDAD,
            nivel_salida => NIVEL_FISICO,
            pulso_linea => pulso_linea,
            segmentos => visor_velocidad
        );

    U_ERRORES : entity work.supervisor_error
        generic map (
            CICLOS_ATASCO => CICLOS_ATASCO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            marcha => marcha_real,
            presencia_activa => presente,
            nueva_pieza => nueva,
            pieza_valida => pieza_valida,
            alarma => error_supervisor
        );

    U_FSM : entity work.maquina_estados_control
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            marcha => marcha_real,
            nueva_pieza => nueva,
            pieza_valida => pieza_valida,
            registrar_evento => registrar_evento,
            contar_pieza => contar_pieza_fsm,
            alarma_estado => alarma_fsm,
            ocupado => ocupado_fsm,
            estado_codigo => estado_fsm
        );

    error_total <= error_supervisor or alarma_fsm;
    bloqueo <= error_total or limite_total or limite_historial;

    U_LINEA : entity work.control_linea
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            marcha => marcha_filtrada,
            bloqueo => bloqueo,
            pulso_linea_entrada => pulso_linea,
            pulso_motor => open,
            led_linea => LINEA_ACTIVA,
            en_marcha => marcha_real
        );

    -- Estos contadores no se borran con BUTTON1.
    U_CONTEOS : entity work.conteo_categorias
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            registrar => contar_sesion,
            categoria => categoria_actual,
            seleccion => std_logic_vector(seleccion),
            por_color => modo(3),
            total => total,
            cantidad_seleccionada => cantidad_consultada,
            limite => limite_total
        );

    -- Indicacion operativa: permite mostrar tambien el rechazo,
    -- aunque ese rechazo no se escriba en el historial.
    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            ultimo_color <= "00";
            ultimo_tamano <= '0';
            hay_pieza <= '0';

        elsif rising_edge(RELOJ) then
            if registrar_evento = '1' then
                ultimo_color <= color_actual;
                ultimo_tamano <= tamano_actual;
                hay_pieza <= '1';
            end if;
        end if;
    end process;

    U_SEGUNDO : entity work.divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            nivel => "01",
            pulso_linea => pulso_segundo
        );

    U_TIEMPO : entity work.contador_segundos
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            pulso_segundo => pulso_segundo,
            segundos => segundos
        );

    -- modo(0): menu activo.
    -- modo(1): identificador o tiempo.
    -- modo(2): registros o cantidades.
    -- modo(3): categorias o colores.
    modo_entrada <=
        CONTAR_POR_COLOR &
        VER_CANTIDADES &
        SELECCION_HISTORIAL &
        VER_HISTORIAL;

    G_MODO : for i in 0 to 3 generate
        U_FILTRO_MODO : entity work.filtro_boton
            generic map (
                CICLOS_ESTABLES => CICLOS_FILTRO
            )
            port map (
                reloj => RELOJ,
                reinicio => reinicio_alto,
                boton_entrada => modo_entrada(i),
                pulso_salida => open,
                estado_salida => modo(i)
            );
    end generate G_MODO;

    consulta_registros <= modo(0) and not modo(2);
    consulta_cantidades <= modo(0) and modo(2);

    U_SIGUIENTE : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_entrada => SIGUIENTE_HISTORIAL,
            pulso_salida => siguiente,
            estado_salida => open
        );

    U_ULTIMO : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_entrada => IR_ULTIMO,
            pulso_salida => ultimo,
            estado_salida => open
        );

    -- SW5 selecciona categorias 1..6 o colores 1..3.
    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            seleccion <= "001";
            cantidades_antes <= '0';
            por_color_antes <= '0';

        elsif rising_edge(RELOJ) then
            cantidades_antes <= consulta_cantidades;
            por_color_antes <= modo(3);

            if (consulta_cantidades = '1' and cantidades_antes = '0')
               or modo(3) /= por_color_antes then
                seleccion <= "001";

            elsif consulta_cantidades = '1' and siguiente = '1' then
                if (modo(3) = '1' and seleccion >= 3)
                   or seleccion >= 6 then
                    seleccion <= "001";
                else
                    seleccion <= seleccion + 1;
                end if;
            end if;
        end if;
    end process;

    U_HISTORIAL : entity work.historial_sesion
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            guardar => guardar_sesion,
            consulta => consulta_registros,
            siguiente => siguiente,
            ir_ultimo => ultimo,
            tiempo_entrada => segundos,
            color_entrada => color_actual,
            tamano_entrada => tamano_actual,
            identificador_salida => id_guardado,
            tiempo_salida => tiempo_guardado,
            color_salida => color_guardado,
            tamano_salida => tamano_guardado,
            registro_valido => registro_valido,
            limite => limite_historial
        );

    -- Selecciona los atributos visibles en los LEDs.
    process(
        modo, seleccion, ultimo_color, ultimo_tamano, hay_pieza,
        color_guardado, tamano_guardado, registro_valido
    )
    begin
        color_vista <= "00";
        tamano_vista <= '0';
        hay_dato_visible <= '0';

        if modo(0) = '0' then
            color_vista <= ultimo_color;
            tamano_vista <= ultimo_tamano;
            hay_dato_visible <= hay_pieza;

        elsif modo(2) = '0' then
            if registro_valido = '1' then
                color_vista <= color_guardado;
                tamano_vista <= tamano_guardado;
                hay_dato_visible <= '1';
            end if;

        else
            hay_dato_visible <= '1';

            if modo(3) = '1' then
                -- Al consultar por color no se indica un tamano.
                color_vista <= std_logic_vector(seleccion(1 downto 0));

            else
                case seleccion is
                    when "001" =>
                        color_vista <= "01";
                        tamano_vista <= '0';

                    when "010" =>
                        color_vista <= "01";
                        tamano_vista <= '1';

                    when "011" =>
                        color_vista <= "10";
                        tamano_vista <= '0';

                    when "100" =>
                        color_vista <= "10";
                        tamano_vista <= '1';

                    when "101" =>
                        color_vista <= "11";
                        tamano_vista <= '0';

                    when "110" =>
                        color_vista <= "11";
                        tamano_vista <= '1';

                    when others =>
                        hay_dato_visible <= '0';
                end case;
            end if;
        end if;
    end process;

    U_REGLA_VISTA : entity work.tabla_reglas
        port map (
            color => color_vista,
            tamano => tamano_vista,
            ruta => categoria_vista,
            valida => open
        );

    LED_COLOR <= color_vista;
    LED_TAMANO <= tamano_vista;

    RUTA_PIEZA <= categoria_vista
        when hay_dato_visible = '1' and
             not (consulta_cantidades = '1' and modo(3) = '1')
        else "0000";

    ALARMA <= error_total;
    LED_LIMITE <= limite_total or limite_historial;

    numero_consulta <=
        cantidad_consultada when consulta_cantidades = '1'
        else id_guardado when modo(1) = '0'
        else "00" & tiempo_guardado;

    U_DECIMAL_TOTAL : entity work.conversor_decimal_reloj
        port map (
            reloj => RELOJ,
            numero_binario => total,
            centenas => total_c,
            decenas => total_d,
            unidades => total_u
        );

    U_DECIMAL_CONSULTA : entity work.conversor_decimal_reloj
        port map (
            reloj => RELOJ,
            numero_binario => numero_consulta,
            centenas => consulta_c,
            decenas => consulta_d,
            unidades => consulta_u
        );

    U_TOTAL_C : entity work.decodificador_7segmentos
        port map (
            numero => total_c,
            segmentos => visor_total_c
        );

    U_TOTAL_D : entity work.decodificador_7segmentos
        port map (
            numero => total_d,
            segmentos => visor_total_d
        );

    U_TOTAL_U : entity work.decodificador_7segmentos
        port map (
            numero => total_u,
            segmentos => visor_total_u
        );

    U_CONSULTA_C : entity work.decodificador_7segmentos
        port map (
            numero => consulta_c,
            segmentos => visor_consulta_c
        );

    U_CONSULTA_D : entity work.decodificador_7segmentos
        port map (
            numero => consulta_d,
            segmentos => visor_consulta_d
        );

    U_CONSULTA_U : entity work.decodificador_7segmentos
        port map (
            numero => consulta_u,
            segmentos => visor_consulta_u
        );

    digito_seleccion <= '0' & std_logic_vector(seleccion);

    U_SELECCION : entity work.decodificador_7segmentos
        port map (
            numero => digito_seleccion,
            segmentos => visor_seleccion
        );

    process(
        modo, registro_valido,
        visor_total_u, visor_total_d, visor_total_c,
        visor_velocidad,
        visor_consulta_u, visor_consulta_d, visor_consulta_c,
        visor_seleccion
    )
    begin
        VISOR_0 <= "1111111";
        VISOR_1 <= "1111111";
        VISOR_2 <= "1111111";
        VISOR_3 <= "1111111";

        if modo(0) = '0' then
            -- HEX3: velocidad. HEX2..HEX0: total decimal.
            VISOR_0 <= visor_total_u;
            VISOR_1 <= visor_total_d;
            VISOR_2 <= visor_total_c;
            VISOR_3 <= visor_velocidad;

        elsif modo(2) = '1' then
            -- HEX3: seleccion. HEX2..HEX0: cantidad.
            VISOR_0 <= visor_consulta_u;
            VISOR_1 <= visor_consulta_d;
            VISOR_2 <= visor_consulta_c;
            VISOR_3 <= visor_seleccion;

        elsif registro_valido = '1' then
            -- Historial: ID o tiempo. HEX3 apagado.
            VISOR_0 <= visor_consulta_u;
            VISOR_1 <= visor_consulta_d;
            VISOR_2 <= visor_consulta_c;
        end if;
    end process;

end architecture estructural;
```

## SystemAlfa/SystemAlfa_Final/SystemAlfa_Placa.vhd - MODIFICADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity SystemAlfa_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0, HEX1, HEX2, HEX3 :
            out std_logic_vector(6 downto 0)
    );
end entity SystemAlfa_Placa;

architecture estructural of SystemAlfa_Placa is

    component SystemAlfa_Final is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO : positive := 500000;
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA, CAMBIO_VELOCIDAD :
                in std_logic;

            SELECTOR_COLOR : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO, LINEA_MARCHA : in std_logic;

            VER_HISTORIAL, SIGUIENTE_HISTORIAL : in std_logic;
            SELECCION_HISTORIAL, VER_CANTIDADES : in std_logic;
            IR_ULTIMO, CONTAR_POR_COLOR : in std_logic;

            LED_COLOR : out std_logic_vector(1 downto 0);
            LED_TAMANO, LINEA_ACTIVA : out std_logic;
            RUTA_PIEZA : out std_logic_vector(3 downto 0);
            ALARMA, LED_LIMITE : out std_logic;

            VISOR_0, VISOR_1, VISOR_2, VISOR_3 :
                out std_logic_vector(6 downto 0);
            MARCHA_FISICA, EVENTO_VALIDO : out std_logic;
            NIVEL_FISICO : out std_logic_vector(1 downto 0);
            CATEGORIA_FISICA : out std_logic_vector(3 downto 0)
        );
    end component;

    signal color : std_logic_vector(1 downto 0);
    signal tamano, linea, alarma, limite : std_logic;
    signal categoria : std_logic_vector(3 downto 0);

begin

    U_SISTEMA : SystemAlfa_Final
        port map (
            RELOJ => CLOCK_50,
            REINICIO_BAJO => BUTTON(1),
            PRESENCIA => BUTTON(0),
            CAMBIO_VELOCIDAD => BUTTON(2),

            SELECTOR_COLOR => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),
            LINEA_MARCHA => SW(3),

            VER_HISTORIAL => SW(4),
            SIGUIENTE_HISTORIAL => SW(5),
            SELECCION_HISTORIAL => SW(6),
            VER_CANTIDADES => SW(7),
            IR_ULTIMO => SW(8),
            CONTAR_POR_COLOR => SW(9),

            LED_COLOR => color,
            LED_TAMANO => tamano,
            LINEA_ACTIVA => linea,
            RUTA_PIEZA => categoria,
            ALARMA => alarma,
            LED_LIMITE => limite,

            VISOR_0 => HEX0,
            VISOR_1 => HEX1,
            VISOR_2 => HEX2,
            VISOR_3 => HEX3, MARCHA_FISICA => open, EVENTO_VALIDO => open, NIVEL_FISICO => open, CATEGORIA_FISICA => open
        );

    LEDG(1 downto 0) <= color;
    LEDG(2) <= tamano;
    LEDG(3) <= linea;
    LEDG(7 downto 4) <= categoria;
    LEDG(8) <= alarma;
    LEDG(9) <= limite;

end architecture estructural;
```
