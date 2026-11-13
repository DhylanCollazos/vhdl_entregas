# Código completo de calibración TCS3200

Reemplaza estos archivos en las rutas indicadas y recompila el QPF. El lector calibrado se usa solo en el banco TCS3200 individual.

## Hardware_Sensores/lector_tcs3200.vhd

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

## Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.vhd

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

## Pruebas_ModelSim/lector_tcs3200_TB.vhd

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
