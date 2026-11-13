# Todos los archivos VHDL completos

Cada bloque contiene el archivo completo. La ruta identifica dónde agregarlo o reemplazarlo. El proyecto y los QSF ya se entregan preparados en la carpeta SystemAlfa.

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

## SystemAlfa/comunes/captura_pieza.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity captura_pieza is
    generic (
        CICLOS_FILTRO : positive := 500000
    );
    port (
        reloj, reinicio, presencia_baja : in std_logic;

        color_selector : in std_logic_vector(1 downto 0);
        tamano_selector : in std_logic;

        nueva_pieza, presencia_activa : out std_logic;

        color : out std_logic_vector(1 downto 0);
        tamano : out std_logic
    );
end entity captura_pieza;

architecture estructural of captura_pieza is

    component sincronizador is
        generic (
            ANCHO_BITS : positive := 1
        );
        port (
            reloj, reinicio : in std_logic;
            entrada : in std_logic_vector(ANCHO_BITS-1 downto 0);
            salida : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj, reinicio, boton_entrada : in std_logic;
            pulso_salida, estado_salida : out std_logic
        );
    end component;

    signal boton, pulso_presencia, presente, libre_estable :
        std_logic;

    signal preparado, pendiente : std_logic := '0';

    signal entradas, estables, candidato :
        std_logic_vector(2 downto 0);

    signal cuenta_atributos :
        integer range 0 to CICLOS_FILTRO := 0;

begin

    boton <= not presencia_baja;
    entradas <= color_selector & tamano_selector;
    presencia_activa <= presente;

    U_SENSORES : sincronizador
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj,
            reinicio,
            entradas,
            estables
        );

    U_PRESENCIA : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj,
            reinicio,
            boton,
            pulso_presencia,
            presente
        );

    U_LIBERACION : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj,
            reinicio,
            presencia_baja,
            open,
            libre_estable
        );

    -- Estabiliza color y tamano como una sola palabra,
    -- no bit por bit.
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            candidato <= (others => '0');
            cuenta_atributos <= 0;

        elsif rising_edge(reloj) then

            if estables /= candidato then
                candidato <= estables;
                cuenta_atributos <= 0;

            elsif cuenta_atributos < CICLOS_FILTRO then
                cuenta_atributos <= cuenta_atributos + 1;
            end if;

        end if;
    end process;

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            preparado <= '0';
            pendiente <= '0';
            nueva_pieza <= '0';
            color <= "00";
            tamano <= '0';

        elsif rising_edge(reloj) then

            nueva_pieza <= '0';

            -- Tras un reinicio o una pieza, primero debe verse libre.
            if libre_estable = '1' then
                preparado <= '1';
                pendiente <= '0';

            elsif pulso_presencia = '1' and preparado = '1' then
                preparado <= '0';
                pendiente <= '1';

            elsif pendiente = '1' and presente = '1'
                  and cuenta_atributos = CICLOS_FILTRO
                  and estables = candidato then

                color <= candidato(2 downto 1);
                tamano <= candidato(0);
                nueva_pieza <= '1';
                pendiente <= '0';

            end if;

        end if;
    end process;

end architecture estructural;
```

## SystemAlfa/comunes/clasificador_ruta.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity clasificador_ruta is
    port (
        color : in std_logic_vector(1 downto 0);
        tamano : in std_logic;

        ruta : out std_logic_vector(3 downto 0);
        aceptada : out std_logic
    );
end entity clasificador_ruta;

architecture estructural of clasificador_ruta is

    component tabla_reglas is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            valida : out std_logic
        );
    end component;

begin

    U_REGLAS : tabla_reglas
        port map (
            color  => color,
            tamano => tamano,
            ruta   => ruta,
            valida => aceptada
        );

end architecture estructural;
```

## SystemAlfa/comunes/codificador_direccion.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use work.paquete_funciones.all;

-- Componente independiente que contiene la funcion solicitada.
-- Convierte color + tamano en una direccion de tres bits para la ROM.

entity codificador_direccion is
    port (
        color     : in  std_logic_vector(1 downto 0);
        tamano    : in  std_logic;
        direccion : out std_logic_vector(2 downto 0)
    );
end entity codificador_direccion;

architecture comportamiento of codificador_direccion is

begin

    direccion <=
        formar_direccion(
            color,
            tamano
        );

end architecture comportamiento;
```

## SystemAlfa/comunes/contador_ascendente.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity contador_ascendente is
    generic (
        ANCHO_BITS : positive := 4
    );
    port (
        reloj, reinicio, habilitar : in std_logic;
        CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
    );
end entity contador_ascendente;

architecture estructural of contador_ascendente is
begin

    U_CONTADOR : lpm_counter
        generic map (
            lpm_width     => ANCHO_BITS,
            lpm_direction => "UP",
            lpm_type      => "LPM_COUNTER"
        )
        port map (
            clock  => reloj,
            aclr   => reinicio,
            cnt_en => habilitar,
            q      => CUENTA
        );

end architecture estructural;
```

## SystemAlfa/comunes/contador_segundos.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_segundos is
    port (
        reloj, reinicio, pulso_segundo : in std_logic;
        segundos : out std_logic_vector(7 downto 0)
    );
end entity contador_segundos;

architecture comportamiento of contador_segundos is

    signal cuenta : unsigned(7 downto 0);

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            cuenta <= (others => '0');

        elsif rising_edge(reloj) then
            if pulso_segundo = '1' then

                if cuenta = 179 then
                    cuenta <= (others => '0');

                else
                    cuenta <= cuenta + 1;
                end if;
            end if;
        end if;
    end process;

    segundos <= std_logic_vector(cuenta);

end architecture comportamiento;
```

## SystemAlfa/comunes/conteo_categorias.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conteo_categorias is
    port (
        reloj, reinicio, registrar : in std_logic;

        categoria : in std_logic_vector(3 downto 0);
        seleccion : in std_logic_vector(2 downto 0);

        por_color : in std_logic;

        total, cantidad_seleccionada :
            out std_logic_vector(9 downto 0);

        limite : out std_logic
    );
end entity conteo_categorias;

architecture estructural of conteo_categorias is

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    type seis_contadores is array (1 to 6)
        of std_logic_vector(9 downto 0);

    type tres_contadores is array (1 to 3)
        of std_logic_vector(9 downto 0);

    signal cantidades : seis_contadores;
    signal colores : tres_contadores;

    signal habilitar_categoria : std_logic_vector(6 downto 1);
    signal habilitar_color : std_logic_vector(3 downto 1);

    signal cuenta_total : std_logic_vector(9 downto 0);
    signal aceptar, completa : std_logic;

begin

    completa <= '1'
        when unsigned(cuenta_total) >= 999
        else '0';

    -- Solo se aceptan las categorias 1 a 6.
    aceptar <= registrar and not completa
        when categoria = "0001" or
             categoria = "0010" or
             categoria = "0011" or
             categoria = "0100" or
             categoria = "0101" or
             categoria = "0110"
        else '0';

    U_TOTAL : contador_ascendente
        generic map (
            ANCHO_BITS => 10
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => aceptar,
            CUENTA    => cuenta_total
        );

    -- Se crean seis contadores, uno para cada categoria.
    G_CATEGORIAS : for indice in 1 to 6 generate

        habilitar_categoria(indice) <= aceptar
            when categoria = std_logic_vector(to_unsigned(indice, 4))
            else '0';

        U_CATEGORIA : contador_ascendente
            generic map (
                ANCHO_BITS => 10
            )
            port map (
                reloj     => reloj,
                reinicio  => reinicio,
                habilitar => habilitar_categoria(indice),
                CUENTA    => cantidades(indice)
            );

    end generate G_CATEGORIAS;

    -- Rojo: categorias 1 y 2.
    habilitar_color(1) <=
        habilitar_categoria(1) or habilitar_categoria(2);

    -- Verde: categorias 3 y 4.
    habilitar_color(2) <=
        habilitar_categoria(3) or habilitar_categoria(4);

    -- Azul: categorias 5 y 6.
    habilitar_color(3) <=
        habilitar_categoria(5) or habilitar_categoria(6);

    G_COLORES : for indice in 1 to 3 generate

        U_COLOR : contador_ascendente
            generic map (
                ANCHO_BITS => 10
            )
            port map (
                reloj     => reloj,
                reinicio  => reinicio,
                habilitar => habilitar_color(indice),
                CUENTA    => colores(indice)
            );

    end generate G_COLORES;

    -- Selecciona el contador que se mostrara en el menu.
    process(seleccion, por_color, cantidades, colores)
    begin

        cantidad_seleccionada <= (others => '0');

        if por_color = '0' then

            case seleccion is
                when "001" =>
                    cantidad_seleccionada <= cantidades(1);

                when "010" =>
                    cantidad_seleccionada <= cantidades(2);

                when "011" =>
                    cantidad_seleccionada <= cantidades(3);

                when "100" =>
                    cantidad_seleccionada <= cantidades(4);

                when "101" =>
                    cantidad_seleccionada <= cantidades(5);

                when "110" =>
                    cantidad_seleccionada <= cantidades(6);

                when others =>
                    null;
            end case;

        else

            case seleccion is
                when "001" =>
                    cantidad_seleccionada <= colores(1);

                when "010" =>
                    cantidad_seleccionada <= colores(2);

                when "011" =>
                    cantidad_seleccionada <= colores(3);

                when others =>
                    null;
            end case;

        end if;

    end process;

    total <= cuenta_total;
    limite <= completa;

end architecture estructural;
```

## SystemAlfa/comunes/control_linea.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity control_linea is
    port (
        reloj, reinicio, marcha, bloqueo, pulso_linea_entrada :
            in std_logic;

        pulso_motor, led_linea, en_marcha :
            out std_logic
    );
end entity control_linea;

architecture comportamiento of control_linea is

    -- SW3 determina la marcha. Al soltar reset, se respeta su nivel.
    signal etapa1, etapa2 : std_logic := '0';
    signal estado_led : std_logic := '0';
    signal habilitada : std_logic;

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            etapa1 <= '0';
            etapa2 <= '0';
            estado_led <= '0';

        elsif rising_edge(reloj) then

            etapa1 <= marcha;
            etapa2 <= etapa1;

            if habilitada = '0' then
                estado_led <= '0';

            elsif pulso_linea_entrada = '1' then
                estado_led <= not estado_led;
            end if;

        end if;
    end process;

    habilitada <=
        etapa2 and not bloqueo and not reinicio;

    pulso_motor <= pulso_linea_entrada and habilitada;
    led_linea <= estado_led and habilitada;
    en_marcha <= habilitada;

end architecture comportamiento;
```

## SystemAlfa/comunes/conversor_binario_decimal.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conversor_binario_decimal is
    port (
        numero_binario : in std_logic_vector(9 downto 0);

        centenas : out std_logic_vector(3 downto 0);
        decenas  : out std_logic_vector(3 downto 0);
        unidades : out std_logic_vector(3 downto 0)
    );
end entity conversor_binario_decimal;

architecture comportamiento of conversor_binario_decimal is
begin

    process(numero_binario)

        variable numero : integer range 0 to 1023;
        variable valor_centenas : integer range 0 to 9;
        variable valor_decenas : integer range 0 to 9;
        variable valor_unidades : integer range 0 to 9;

    begin

        numero := to_integer(unsigned(numero_binario));

        if numero > 999 then
            numero := 999;
        end if;

        valor_centenas := numero / 100;
        valor_decenas := (numero / 10) mod 10;
        valor_unidades := numero mod 10;

        centenas <= std_logic_vector(
            to_unsigned(valor_centenas, 4)
        );

        decenas <= std_logic_vector(
            to_unsigned(valor_decenas, 4)
        );

        unidades <= std_logic_vector(
            to_unsigned(valor_unidades, 4)
        );

    end process;

end architecture comportamiento;
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

## SystemAlfa/comunes/decodificador_7segmentos.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity decodificador_7segmentos is
    port (
        numero : in std_logic_vector(3 downto 0);
        segmentos : out std_logic_vector(6 downto 0)
    );
end entity decodificador_7segmentos;

architecture combinacional of decodificador_7segmentos is
begin

    process(numero)
    begin
        case numero is
            when "0000" => segmentos <= "1000000"; -- 0
            when "0001" => segmentos <= "1111001"; -- 1
            when "0010" => segmentos <= "0100100"; -- 2
            when "0011" => segmentos <= "0110000"; -- 3
            when "0100" => segmentos <= "0011001"; -- 4
            when "0101" => segmentos <= "0010010"; -- 5
            when "0110" => segmentos <= "0000010"; -- 6
            when "0111" => segmentos <= "1111000"; -- 7
            when "1000" => segmentos <= "0000000"; -- 8
            when "1001" => segmentos <= "0010000"; -- 9
            when "1010" => segmentos <= "0001000"; -- A
            when "1011" => segmentos <= "0000011"; -- b
            when "1100" => segmentos <= "1000110"; -- C
            when "1101" => segmentos <= "0100001"; -- d
            when "1110" => segmentos <= "0000110"; -- E
            when "1111" => segmentos <= "0001110"; -- F

            when others =>
                segmentos <= "1111111"; -- Apagado
        end case;
    end process;

end architecture combinacional;
```

## SystemAlfa/comunes/divisor_frecuencia.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity divisor_frecuencia is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000
    );
    port (
        reloj, reinicio : in std_logic;
        nivel : in std_logic_vector(1 downto 0);
        pulso_linea : out std_logic
    );
end entity divisor_frecuencia;

architecture comportamiento of divisor_frecuencia is

    signal cuenta :
        integer range 0 to 2*FRECUENCIA_RELOJ_HZ-1 := 0;

    signal periodo :
        integer range 1 to 2*FRECUENCIA_RELOJ_HZ;

    signal anterior :
        std_logic_vector(1 downto 0) := "00";

begin

    process(nivel)
    begin
        case nivel is
            when "00" =>
                periodo <= FRECUENCIA_RELOJ_HZ/2;

            when "01" =>
                periodo <= FRECUENCIA_RELOJ_HZ;

            when "10" =>
                periodo <= (FRECUENCIA_RELOJ_HZ+1)/3;

            when others =>
                periodo <= 2*FRECUENCIA_RELOJ_HZ;
        end case;
    end process;

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            cuenta <= 0;
            anterior <= "00";
            pulso_linea <= '0';

        elsif rising_edge(reloj) then
            pulso_linea <= '0';
            anterior <= nivel;

            if nivel /= anterior then
                cuenta <= 0;

            elsif cuenta = periodo-1 then
                cuenta <= 0;
                pulso_linea <= '1';

            else
                cuenta <= cuenta + 1;
            end if;
        end if;
    end process;

end architecture comportamiento;
```

## SystemAlfa/comunes/filtro_boton.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity filtro_boton is
    generic (
        CICLOS_ESTABLES : positive := 500000
    );
    port (
        reloj, reinicio, boton_entrada : in std_logic;
        pulso_salida, estado_salida : out std_logic
    );
end entity filtro_boton;

architecture comportamiento of filtro_boton is

    signal etapa_sincronizada_1 : std_logic := '0';
    signal etapa_sincronizada_2 : std_logic := '0';

    signal sincronizacion_valida : std_logic_vector(1 downto 0)
        := "00";

    signal candidato, estable, inicializado : std_logic := '0';

    signal cuenta :
        integer range 0 to CICLOS_ESTABLES-1 := 0;

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            etapa_sincronizada_1 <= '0';
            etapa_sincronizada_2 <= '0';
            sincronizacion_valida <= "00";

            candidato <= '0';
            inicializado <= '0';
            estable <= '0';
            cuenta <= 0;
            pulso_salida <= '0';

        elsif rising_edge(reloj) then

            -- Sincronizacion de la entrada con el reloj.
            etapa_sincronizada_1 <= boton_entrada;
            etapa_sincronizada_2 <= etapa_sincronizada_1;

            sincronizacion_valida <=
                sincronizacion_valida(0) & '1';

            -- El pulso dura solamente un ciclo de reloj.
            pulso_salida <= '0';

            -- No usar los ceros artificiales del sincronizador
            -- inmediatamente despues del reinicio.
            if sincronizacion_valida(1) = '1' then

                if etapa_sincronizada_2 /= candidato then
                    candidato <= etapa_sincronizada_2;
                    cuenta <= 0;

                elsif cuenta < CICLOS_ESTABLES-1 then
                    cuenta <= cuenta + 1;

                else
                    if inicializado = '0' then
                        -- El primer nivel estable establece la
                        -- referencia, sin generar una pulsacion.
                        estable <= candidato;
                        inicializado <= '1';

                    elsif candidato /= estable then
                        estable <= candidato;

                        -- Generar pulso solo al pasar de 0 a 1.
                        if candidato = '1' then
                            pulso_salida <= '1';
                        end if;

                    end if;
                end if;
            end if;
        end if;
    end process;

    estado_salida <= estable;

end architecture comportamiento;
```

## SystemAlfa/comunes/historial.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity historial is
    port (
        reloj, reinicio, escribir : in std_logic;

        posicion_escritura, posicion_lectura :
            in std_logic_vector(2 downto 0);

        tiempo_entrada, identificador_entrada :
            in std_logic_vector(7 downto 0);

        color_entrada : in std_logic_vector(1 downto 0);
        tamano_entrada : in std_logic;

        tiempo_salida, identificador_salida :
            out std_logic_vector(7 downto 0);

        color_salida : out std_logic_vector(1 downto 0);
        tamano_salida, registro_valido : out std_logic
    );
end entity historial;

architecture comportamiento of historial is

    type tipo_memoria is array (0 to 7)
        of std_logic_vector(18 downto 0);

    signal memoria : tipo_memoria;
    signal validos : std_logic_vector(7 downto 0);
    signal dato : std_logic_vector(18 downto 0);

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            memoria <= (others => (others => '0'));
            validos <= (others => '0');

        elsif rising_edge(reloj) then
            if escribir = '1' then

                memoria(to_integer(unsigned(posicion_escritura))) <=
                    tiempo_entrada &
                    identificador_entrada &
                    color_entrada &
                    tamano_entrada;

                validos(to_integer(unsigned(posicion_escritura))) <= '1';

            end if;
        end if;
    end process;

    dato <= memoria(to_integer(unsigned(posicion_lectura)));

    tiempo_salida <= dato(18 downto 11);
    identificador_salida <= dato(10 downto 3);
    color_salida <= dato(2 downto 1);
    tamano_salida <= dato(0);

    registro_valido <= validos(to_integer(unsigned(posicion_lectura)));

end architecture comportamiento;
```

## SystemAlfa/comunes/historial_sesion.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Control del historial.
--
-- Este modulo ya NO contiene la memoria internamente.
-- La memoria RAM se encuentra en memoria_ram_historial.vhd.

entity historial_sesion is
    port (
        reloj, reinicio, guardar :
            in std_logic;

        consulta, siguiente, ir_ultimo :
            in std_logic;

        tiempo_entrada :
            in std_logic_vector(7 downto 0);

        color_entrada :
            in std_logic_vector(1 downto 0);

        tamano_entrada :
            in std_logic;

        identificador_salida :
            out std_logic_vector(9 downto 0);

        tiempo_salida :
            out std_logic_vector(7 downto 0);

        color_salida :
            out std_logic_vector(1 downto 0);

        tamano_salida,
        registro_valido,
        limite :
            out std_logic
    );
end entity historial_sesion;

architecture estructural of historial_sesion is

    ------------------------------------------------------------
    -- CONTADOR
    ------------------------------------------------------------

    component contador_ascendente is
        generic (
            ANCHO_BITS :
                positive := 4
        );

        port (
            reloj,
            reinicio,
            habilitar :
                in std_logic;

            CUENTA :
                out std_logic_vector(
                    ANCHO_BITS-1 downto 0
                )
        );
    end component;

    ------------------------------------------------------------
    -- RAM EXTERNA
    ------------------------------------------------------------

    component memoria_ram_historial is
        port (
            reloj :
                in std_logic;

            habilitar_escritura :
                in std_logic;

            direccion_escritura :
                in std_logic_vector(2 downto 0);

            direccion_lectura :
                in std_logic_vector(2 downto 0);

            dato_entrada :
                in std_logic_vector(20 downto 0);

            dato_salida :
                out std_logic_vector(20 downto 0)
        );
    end component;

    ------------------------------------------------------------
    -- VALIDEZ DE LAS OCHO POSICIONES
    ------------------------------------------------------------

    signal validos :
        std_logic_vector(7 downto 0) :=
        (others => '0');

    ------------------------------------------------------------
    -- DIRECCIONES
    ------------------------------------------------------------

    signal posicion_escritura :
        std_logic_vector(2 downto 0);

    signal posicion_lectura :
        unsigned(2 downto 0) :=
        (others => '0');

    signal ultima_posicion :
        unsigned(2 downto 0) :=
        (others => '0');

    ------------------------------------------------------------
    -- IDENTIFICADOR
    ------------------------------------------------------------

    signal cantidad_guardada :
        std_logic_vector(9 downto 0);

    signal nuevo_id :
        std_logic_vector(9 downto 0);

    ------------------------------------------------------------
    -- DATOS RAM
    ------------------------------------------------------------

    signal dato_entrada_ram :
        std_logic_vector(20 downto 0);

    signal dato_salida_ram :
        std_logic_vector(20 downto 0);

    signal ocupadas :
        integer range 0 to 8 := 0;

    signal escribir :
        std_logic;

    signal completa :
        std_logic;

    signal consulta_anterior :
        std_logic := '0';

begin

    ------------------------------------------------------------
    -- LIMITE DE SESION
    ------------------------------------------------------------

    completa <= '1'
        when unsigned(cantidad_guardada) >= 999
        else '0';

    escribir <=
        guardar and not completa and not reinicio;

    ------------------------------------------------------------
    -- NUEVO IDENTIFICADOR
    ------------------------------------------------------------

    nuevo_id <=
        std_logic_vector(
            unsigned(cantidad_guardada) + 1
        );

    ------------------------------------------------------------
    -- EMPAQUETAR LOS DATOS PARA LA RAM
    ------------------------------------------------------------

    dato_entrada_ram <=
        tiempo_entrada &
        nuevo_id &
        color_entrada &
        tamano_entrada;

    ------------------------------------------------------------
    -- CONTADOR DE IDENTIFICADORES
    ------------------------------------------------------------

    U_IDENTIFICADOR : contador_ascendente
        generic map (
            ANCHO_BITS => 10
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => escribir,
            CUENTA    => cantidad_guardada
        );

    ------------------------------------------------------------
    -- CONTADOR DE DIRECCION DE ESCRITURA
    ------------------------------------------------------------

    U_POSICION_ESCRITURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => escribir,
            CUENTA    => posicion_escritura
        );

    ------------------------------------------------------------
    -- INSTANCIA DE LA RAM
    ------------------------------------------------------------

    U_RAM : memoria_ram_historial
        port map (
            reloj =>
                reloj,

            habilitar_escritura =>
                escribir,

            direccion_escritura =>
                posicion_escritura,

            direccion_lectura =>
                std_logic_vector(
                    posicion_lectura
                ),

            dato_entrada =>
                dato_entrada_ram,

            dato_salida =>
                dato_salida_ram
        );

    ------------------------------------------------------------
    -- CONTROL DEL HISTORIAL
    ------------------------------------------------------------

    process(reloj, reinicio)
    begin

        if reinicio = '1' then

            validos <=
                (others => '0');

            posicion_lectura <=
                (others => '0');

            ultima_posicion <=
                (others => '0');

            ocupadas <= 0;

            consulta_anterior <= '0';

        elsif rising_edge(reloj) then

            consulta_anterior <= consulta;

            ----------------------------------------------------
            -- NUEVA ESCRITURA
            ----------------------------------------------------

            if escribir = '1' then

                validos(
                    to_integer(
                        unsigned(posicion_escritura)
                    )
                ) <= '1';

                ultima_posicion <=
                    unsigned(posicion_escritura);

                if ocupadas < 8 then

                    ocupadas <=
                        ocupadas + 1;

                end if;

            end if;

            ----------------------------------------------------
            -- CONSULTA
            ----------------------------------------------------

            if consulta = '1' then

                ------------------------------------------------
                -- ENTRAR AL HISTORIAL O VOLVER AL ULTIMO
                ------------------------------------------------

                if
                    consulta_anterior = '0'
                    or
                    ir_ultimo = '1'
                then

                    if escribir = '1' then

                        posicion_lectura <=
                            unsigned(posicion_escritura);

                    elsif ocupadas > 0 then

                        posicion_lectura <=
                            ultima_posicion;

                    end if;

                ------------------------------------------------
                -- SIGUIENTE REGISTRO
                ------------------------------------------------

                elsif
                    siguiente = '1'
                    and
                    ocupadas > 0
                then

                    if escribir = '1' then

                        posicion_lectura <=
                            unsigned(posicion_escritura);

                    elsif posicion_lectura =
                          ultima_posicion
                    then

                        if ocupadas = 8 then

                            posicion_lectura <=
                                unsigned(
                                    posicion_escritura
                                );

                        else

                            posicion_lectura <=
                                (others => '0');

                        end if;

                    else

                        posicion_lectura <=
                            posicion_lectura + 1;

                    end if;

                end if;

            end if;

        end if;

    end process;

    ------------------------------------------------------------
    -- DESEMPAQUETAR LA SALIDA DE LA RAM
    ------------------------------------------------------------

    tiempo_salida <=
        dato_salida_ram(20 downto 13);

    identificador_salida <=
        dato_salida_ram(12 downto 3);

    color_salida <=
        dato_salida_ram(2 downto 1);

    tamano_salida <=
        dato_salida_ram(0);

    ------------------------------------------------------------
    -- SALIDAS DE CONTROL
    ------------------------------------------------------------

    registro_valido <=
        validos(
            to_integer(
                posicion_lectura
            )
        );

    limite <= completa;

end architecture estructural;
```

## SystemAlfa/comunes/maquina_estados_control.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

-- Maquina de estados principal.
--
-- Modelo clasico de tres procesos:
--
-- 1. Registro del estado
-- 2. Logica de transicion
-- 3. Logica de salidas

entity maquina_estados_control is
    port (
        reloj,
        reinicio :
            in std_logic;

        marcha :
            in std_logic;

        nueva_pieza :
            in std_logic;

        pieza_valida :
            in std_logic;

        registrar_evento :
            out std_logic;

        contar_pieza :
            out std_logic;

        alarma_estado :
            out std_logic;

        ocupado :
            out std_logic;

        estado_codigo :
            out std_logic_vector(2 downto 0)
    );
end entity maquina_estados_control;

architecture fsm_tres_procesos
of maquina_estados_control is

    ------------------------------------------------------------
    -- ESTADOS
    ------------------------------------------------------------

    type tipo_estado is (

        ESPERA,
        DETECCION,
        LECTURA_COLOR,
        CLASIFICACION,
        REGISTRO,
        ERROR_ESTADO

    );

    signal estado_actual :
        tipo_estado := ESPERA;

    signal estado_siguiente :
        tipo_estado := ESPERA;

begin

    -- PROCESO 1
    -- REGISTRO DE ESTADO

    process(reloj, reinicio)
    begin

        if reinicio = '1' then

            estado_actual <= ESPERA;

        elsif rising_edge(reloj) then

            estado_actual <=
                estado_siguiente;

        end if;

    end process;

    -- PROCESO 2
    -- LOGICA DE TRANSICION

    process(
        estado_actual,
        marcha,
        nueva_pieza,
        pieza_valida
    )
    begin

        estado_siguiente <=
            estado_actual;

        case estado_actual is

            ----------------------------------------------------
            -- ESPERA
            ----------------------------------------------------

            when ESPERA =>

                if
                    marcha = '1'
                    and
                    nueva_pieza = '1'
                then

                    estado_siguiente <=
                        DETECCION;

                end if;

            ----------------------------------------------------
            -- DETECCION
            ----------------------------------------------------

            when DETECCION =>

                estado_siguiente <=
                    LECTURA_COLOR;

            ----------------------------------------------------
            -- LECTURA COLOR Y TAMANO
            ----------------------------------------------------

            when LECTURA_COLOR =>

                estado_siguiente <=
                    CLASIFICACION;

            ----------------------------------------------------
            -- CLASIFICACION
            ----------------------------------------------------

            when CLASIFICACION =>

                if pieza_valida = '1' then

                    estado_siguiente <=
                        REGISTRO;

                else

                    estado_siguiente <=
                        ERROR_ESTADO;

                end if;

            ----------------------------------------------------
            -- REGISTRO
            ----------------------------------------------------

            when REGISTRO =>

                estado_siguiente <=
                    ESPERA;

            ----------------------------------------------------
            -- ERROR
            ----------------------------------------------------

            when ERROR_ESTADO =>

                -- Permanece aqui hasta reinicio.
                estado_siguiente <=
                    ERROR_ESTADO;

        end case;

    end process;

    -- PROCESO 3
    -- LOGICA DE SALIDAS

    process(
        estado_actual,
        pieza_valida
    )
    begin

        --------------------------------------------------------
        -- VALORES POR DEFECTO
        --------------------------------------------------------

        registrar_evento <= '0';
        contar_pieza      <= '0';
        alarma_estado     <= '0';

        ocupado <= '1';

        estado_codigo <= "000";

        case estado_actual is

            ----------------------------------------------------
            -- ESPERA
            ----------------------------------------------------

            when ESPERA =>

                ocupado <= '0';

                estado_codigo <=
                    "000";

            ----------------------------------------------------
            -- DETECCION
            ----------------------------------------------------

            when DETECCION =>

                estado_codigo <=
                    "001";

            ----------------------------------------------------
            -- LECTURA
            ----------------------------------------------------

            when LECTURA_COLOR =>

                estado_codigo <=
                    "010";

            ----------------------------------------------------
            -- CLASIFICACION
            ----------------------------------------------------

            when CLASIFICACION =>

                estado_codigo <=
                    "011";

                -- Una pieza invalida se registra,
                -- pero NO se suma como valida.

                if pieza_valida = '0' then

                    registrar_evento <= '1';

                    alarma_estado <= '1';

                end if;

            ----------------------------------------------------
            -- REGISTRO VALIDO
            ----------------------------------------------------

            when REGISTRO =>

                estado_codigo <=
                    "100";

                registrar_evento <=
                    '1';

                contar_pieza <=
                    '1';

            ----------------------------------------------------
            -- ERROR
            ----------------------------------------------------

            when ERROR_ESTADO =>

                estado_codigo <=
                    "101";

                alarma_estado <=
                    '1';

        end case;

    end process;

end architecture fsm_tres_procesos;
```

## SystemAlfa/comunes/memoria_ram_historial.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- RAM de ocho posiciones por 21 bits.
--
-- Cada palabra contiene:
--
-- 8 bits  -> tiempo
-- 10 bits -> identificador
-- 2 bits  -> color
-- 1 bit   -> tamano
--
-- Total = 21 bits

entity memoria_ram_historial is
    port (
        reloj :
            in std_logic;

        habilitar_escritura :
            in std_logic;

        direccion_escritura :
            in std_logic_vector(2 downto 0);

        direccion_lectura :
            in std_logic_vector(2 downto 0);

        dato_entrada :
            in std_logic_vector(20 downto 0);

        dato_salida :
            out std_logic_vector(20 downto 0)
    );
end entity memoria_ram_historial;

architecture memoria of memoria_ram_historial is

    ------------------------------------------------------------
    -- DEFINICION DE LA RAM
    ------------------------------------------------------------

    type tipo_ram is
        array (0 to 7)
        of std_logic_vector(20 downto 0);

    signal RAM :
        tipo_ram := (
            others => (
                others => '0'
            )
        );

begin

    ------------------------------------------------------------
    -- ESCRITURA SINCRONA
    ------------------------------------------------------------

    process(reloj)
    begin

        if rising_edge(reloj) then

            if habilitar_escritura = '1' then

                RAM(
                    to_integer(
                        unsigned(direccion_escritura)
                    )
                ) <= dato_entrada;

            end if;

        end if;

    end process;

    ------------------------------------------------------------
    -- LECTURA
    ------------------------------------------------------------

    dato_salida <=
        RAM(
            to_integer(
                unsigned(direccion_lectura)
            )
        );

end architecture memoria;
```

## SystemAlfa/comunes/paquete_funciones.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

package paquete_funciones is
    subtype tipo_direccion_rom is std_logic_vector(2 downto 0);
    function formar_direccion(
        color_funcion : std_logic_vector(1 downto 0);
        tamano_funcion : std_logic
    ) return tipo_direccion_rom;
end package paquete_funciones;

package body paquete_funciones is
    function formar_direccion(
        color_funcion : std_logic_vector(1 downto 0);
        tamano_funcion : std_logic
    ) return tipo_direccion_rom is
        variable resultado : tipo_direccion_rom;
    begin
        resultado := color_funcion & tamano_funcion;
        return resultado;
    end function formar_direccion;
end package body paquete_funciones;
```

## SystemAlfa/comunes/registro_color.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity registro_color is
    port (
        reloj, reinicio, HABILITAR : in std_logic;
        color_entrada : in std_logic_vector(1 downto 0);
        color_salida : out std_logic_vector(1 downto 0)
    );
end entity registro_color;

architecture estructural of registro_color is
begin

    U_REGISTRO : lpm_ff
        generic map (
            lpm_width  => 2,
            lpm_fftype => "DFF",
            lpm_type   => "LPM_FF"
        )
        port map (
            clock  => reloj,
            aclr   => reinicio,
            enable => HABILITAR,
            data   => color_entrada,
            q      => color_salida
        );

end architecture estructural;
```

## SystemAlfa/comunes/registro_tamano.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity registro_tamano is
    port (
        reloj, reinicio, HABILITAR, tamano_entrada : in std_logic;
        tamano_salida : out std_logic
    );
end entity registro_tamano;

architecture estructural of registro_tamano is

    signal dato, valor : std_logic_vector(0 downto 0);

begin

    dato(0) <= tamano_entrada;

    U_REGISTRO : lpm_ff
        generic map (
            lpm_width  => 1,
            lpm_fftype => "DFF",
            lpm_type   => "LPM_FF"
        )
        port map (
            clock  => reloj,
            aclr   => reinicio,
            enable => HABILITAR,
            data   => dato,
            q      => valor
        );

    tamano_salida <= valor(0);

end architecture estructural;
```

## SystemAlfa/comunes/reinicio_seguro.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity reinicio_seguro is
    port (
        reloj           : in std_logic;
        reinicio_bajo   : in std_logic;
        reinicio_salida : out std_logic
    );
end entity reinicio_seguro;

architecture comportamiento of reinicio_seguro is

    signal paso1 : std_logic := '1';
    signal paso2 : std_logic := '1';

begin

    process(reloj, reinicio_bajo)
    begin

        -- El pulsador activa el reinicio cuando vale cero
        if reinicio_bajo = '0' then

            paso1 <= '1';
            paso2 <= '1';

        -- La liberacion del reinicio sigue el reloj
        elsif rising_edge(reloj) then

            paso1 <= '0';
            paso2 <= paso1;

        end if;

    end process;

    -- La segunda etapa entrega el reinicio al resto del circuito
    reinicio_salida <= paso2;

end architecture comportamiento;
```

## SystemAlfa/comunes/rom_categorias.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM de clasificacion.
--
-- direccion = color(1 downto 0) & tamano
--
-- dato(4) = categoria valida
-- dato(3 downto 0) = codigo de categoria o rechazo

entity rom_categorias is
    port (
        direccion :
            in std_logic_vector(2 downto 0);

        dato :
            out std_logic_vector(4 downto 0)
    );
end entity rom_categorias;

architecture memoria of rom_categorias is

    type tipo_rom is
        array (0 to 7)
        of std_logic_vector(4 downto 0);

    constant CONTENIDO_ROM :
        tipo_rom := (

        -- Color 00: no valido
        0 => "01000", -- 000 -> rechazo pequena
        1 => "01000", -- 001 -> rechazo grande

        -- Color 01: rojo
        2 => "10001", -- 010 -> rojo pequeno -> categoria 1
        3 => "10010", -- 011 -> rojo grande  -> categoria 2

        -- Color 10: verde
        4 => "10011", -- 100 -> verde pequeno -> categoria 3
        5 => "10100", -- 101 -> verde grande  -> categoria 4

        -- Color 11: azul
        6 => "10101", -- 110 -> azul pequeno -> categoria 5
        7 => "10110"  -- 111 -> azul grande  -> categoria 6

    );

begin

    ------------------------------------------------------------
    -- LECTURA DE ROM
    ------------------------------------------------------------

    dato <=
        CONTENIDO_ROM(
            to_integer(
                unsigned(direccion)
            )
        );

end architecture memoria;
```

## SystemAlfa/comunes/selector_velocidad.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity selector_velocidad is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000
    );
    port (
        reloj, reinicio, boton_bajo : in std_logic;
        nivel_salida : out std_logic_vector(1 downto 0);
        pulso_linea : out std_logic;
        segmentos : out std_logic_vector(6 downto 0)
    );
end entity selector_velocidad;

architecture estructural of selector_velocidad is

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj, reinicio, boton_entrada : in std_logic;
            pulso_salida, estado_salida : out std_logic
        );
    end component;

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component divisor_frecuencia is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000
        );
        port (
            reloj, reinicio : in std_logic;
            nivel : in std_logic_vector(1 downto 0);
            pulso_linea : out std_logic
        );
    end component;

    component decodificador_7segmentos is
        port (
            numero : in std_logic_vector(3 downto 0);
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    signal boton, cambio : std_logic;
    signal nivel : std_logic_vector(1 downto 0);
    signal numero : std_logic_vector(3 downto 0);

begin

    boton <= not boton_bajo;

    U_BOTON : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj         => reloj,
            reinicio      => reinicio,
            boton_entrada => boton,
            pulso_salida  => cambio,
            estado_salida => open
        );

    U_NIVEL : contador_ascendente
        generic map (
            ANCHO_BITS => 2
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => cambio,
            CUENTA    => nivel
        );

    U_DIVISOR : divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj       => reloj,
            reinicio    => reinicio,
            nivel       => nivel,
            pulso_linea => pulso_linea
        );

    numero <= "00" & nivel;

    U_VISOR : decodificador_7segmentos
        port map (
            numero    => numero,
            segmentos => segmentos
        );

    nivel_salida <= nivel;

end architecture estructural;
```

## SystemAlfa/comunes/sincronizador.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity sincronizador is
    generic (
        ANCHO_BITS : positive := 1
    );
    port (
        reloj, reinicio : in std_logic;
        entrada : in std_logic_vector(ANCHO_BITS-1 downto 0);
        salida : out std_logic_vector(ANCHO_BITS-1 downto 0)
    );
end entity sincronizador;

architecture comportamiento of sincronizador is

    signal etapa1, etapa2 :
        std_logic_vector(ANCHO_BITS-1 downto 0);

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            etapa1 <= (others => '0');
            etapa2 <= (others => '0');

        elsif rising_edge(reloj) then
            etapa1 <= entrada;
            etapa2 <= etapa1;
        end if;
    end process;

    salida <= etapa2;

end architecture comportamiento;
```

## SystemAlfa/comunes/supervisor_error.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity supervisor_error is
    generic (
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        reloj, reinicio, marcha, presencia_activa : in std_logic;
        nueva_pieza, pieza_valida : in std_logic;
        alarma : out std_logic
    );
end entity supervisor_error;

architecture comportamiento of supervisor_error is

    signal cuenta :
        integer range 0 to CICLOS_ATASCO-1 := 0;

    signal error : std_logic := '0';

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            cuenta <= 0;
            error <= '0';

        elsif rising_edge(reloj) then

            if marcha = '1' and
               nueva_pieza = '1' and
               pieza_valida = '0' then

                error <= '1';
            end if;

            if marcha = '0' or presencia_activa = '0' then
                cuenta <= 0;

            elsif cuenta = CICLOS_ATASCO-1 then
                error <= '1';

            else
                cuenta <= cuenta + 1;
            end if;
        end if;
    end process;

    alarma <= error;

end architecture comportamiento;
```

## SystemAlfa/comunes/tabla_reglas.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

-- Adaptador entre el resto del proyecto y la ROM.
--
-- Las reglas ya no se encuentran escritas en este archivo.
-- Se genera una direccion y se consulta rom_categorias.

entity tabla_reglas is
    port (
        color  :
            in std_logic_vector(1 downto 0);

        tamano :
            in std_logic;

        ruta :
            out std_logic_vector(3 downto 0);

        valida :
            out std_logic
    );
end entity tabla_reglas;

architecture estructural of tabla_reglas is

    ------------------------------------------------------------
    -- COMPONENTE QUE FORMA LA DIRECCION
    ------------------------------------------------------------

    component codificador_direccion is
        port (
            color :
                in std_logic_vector(1 downto 0);

            tamano :
                in std_logic;

            direccion :
                out std_logic_vector(2 downto 0)
        );
    end component;

    ------------------------------------------------------------
    -- MEMORIA ROM
    ------------------------------------------------------------

    component rom_categorias is
        port (
            direccion :
                in std_logic_vector(2 downto 0);

            dato :
                out std_logic_vector(4 downto 0)
        );
    end component;

    ------------------------------------------------------------
    -- SENALES INTERNAS
    ------------------------------------------------------------

    signal direccion_rom :
        std_logic_vector(2 downto 0);

    signal dato_rom :
        std_logic_vector(4 downto 0);

begin

    ------------------------------------------------------------
    -- GENERAR DIRECCION
    ------------------------------------------------------------

    U_DIRECCION : codificador_direccion
        port map (
            color     => color,
            tamano    => tamano,
            direccion => direccion_rom
        );

    ------------------------------------------------------------
    -- CONSULTAR ROM
    ------------------------------------------------------------

    U_ROM : rom_categorias
        port map (
            direccion => direccion_rom,
            dato      => dato_rom
        );

    ------------------------------------------------------------
    -- SALIDAS
    ------------------------------------------------------------

    valida <= dato_rom(4);

    ruta <= dato_rom(3 downto 0);

end architecture estructural;
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

## SystemAlfa/Hardware_Sensores/control_lectura_sensores.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

-- Coordinador de presencia, HC-SR04 y TCS3200 implementado como FSM Moore.
--
-- Estados:
--   ESPERA               : espera una nueva pieza del V183.
--   INICIAR_MEDICIONES   : genera pulsos de inicio para ambos lectores.
--   ESPERAR_MEDICIONES   : espera que terminen ultrasonido y color.
--   PREPARAR_EVENTO      : guarda los datos o prepara un rechazo.
--   ENVIAR_EVENTO        : genera PRESENCIA activa-baja al nucleo.
--   ESPERAR_RETIRO       : espera que la pieza salga del V183.
--   ESPERAR_LIBERACION   : confirma que el sensor quedo libre.
entity control_lectura_sensores is
    generic (
        CICLOS_PULSO_CORE : positive := 1000000;
        CICLOS_LIBERACION : positive := 1000000
    );
    port (
        reloj               : in  std_logic;
        reinicio            : in  std_logic;

        pulso_presencia     : in  std_logic;
        presencia_fisica    : in  std_logic;

        hc_lista            : in  std_logic;
        hc_valida           : in  std_logic;
        hc_tamano           : in  std_logic;

        tcs_lista           : in  std_logic;
        tcs_valida          : in  std_logic;
        tcs_color           : in  std_logic_vector(1 downto 0);

        iniciar_hc          : out std_logic;
        iniciar_tcs         : out std_logic;

        presencia_core_n    : out std_logic;
        color_core          : out std_logic_vector(1 downto 0);
        tamano_core         : out std_logic;

        ocupado             : out std_logic;
        error_sensores      : out std_logic
    );
end entity control_lectura_sensores;

architecture fsm_tres_procesos of control_lectura_sensores is

    type tipo_estado is (
        ESPERA,
        INICIAR_MEDICIONES,
        ESPERAR_MEDICIONES,
        PREPARAR_EVENTO,
        ENVIAR_EVENTO,
        ESPERAR_RETIRO,
        ESPERAR_LIBERACION
    );

    signal estado_actual    : tipo_estado := ESPERA;
    signal estado_siguiente : tipo_estado := ESPERA;

    signal hc_termino  : std_logic := '0';
    signal tcs_termino : std_logic := '0';

    signal hc_valida_guardada  : std_logic := '0';
    signal tcs_valida_guardada : std_logic := '0';
    signal tamano_guardado     : std_logic := '0';
    signal color_guardado      : std_logic_vector(1 downto 0) := "00";

    signal color_core_reg  : std_logic_vector(1 downto 0) := "00";
    signal tamano_core_reg : std_logic := '0';
    signal error_reg       : std_logic := '0';

    signal cuenta_pulso      : integer range 0 to CICLOS_PULSO_CORE-1 := 0;
    signal cuenta_liberacion : integer range 0 to CICLOS_LIBERACION-1 := 0;

begin

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, datos y contadores
    ------------------------------------------------------------------------
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            estado_actual        <= ESPERA;
            hc_termino           <= '0';
            tcs_termino          <= '0';
            hc_valida_guardada   <= '0';
            tcs_valida_guardada  <= '0';
            tamano_guardado      <= '0';
            color_guardado       <= "00";
            color_core_reg       <= "00";
            tamano_core_reg      <= '0';
            error_reg            <= '0';
            cuenta_pulso         <= 0;
            cuenta_liberacion    <= 0;

        elsif rising_edge(reloj) then
            estado_actual <= estado_siguiente;

            case estado_actual is

                when ESPERA =>
                    hc_termino          <= '0';
                    tcs_termino         <= '0';
                    hc_valida_guardada  <= '0';
                    tcs_valida_guardada <= '0';
                    cuenta_pulso        <= 0;
                    cuenta_liberacion   <= 0;
                    error_reg           <= '0';

                when INICIAR_MEDICIONES =>
                    color_core_reg  <= "00";
                    tamano_core_reg <= '0';

                when ESPERAR_MEDICIONES =>
                    if hc_lista = '1' then
                        hc_termino          <= '1';
                        hc_valida_guardada  <= hc_valida;
                        tamano_guardado     <= hc_tamano;
                    end if;

                    if tcs_lista = '1' then
                        tcs_termino          <= '1';
                        tcs_valida_guardada  <= tcs_valida;
                        color_guardado       <= tcs_color;
                    end if;

                when PREPARAR_EVENTO =>
                    cuenta_pulso <= 0;

                    if hc_valida_guardada = '1' and
                       tcs_valida_guardada = '1' then
                        color_core_reg  <= color_guardado;
                        tamano_core_reg <= tamano_guardado;
                        error_reg       <= '0';
                    else
                        -- Color 00 obliga a la ROM del nucleo a generar rechazo.
                        color_core_reg  <= "00";
                        tamano_core_reg <= '0';
                        error_reg       <= '1';
                    end if;

                when ENVIAR_EVENTO =>
                    if cuenta_pulso = CICLOS_PULSO_CORE-1 then
                        cuenta_pulso <= 0;
                    else
                        cuenta_pulso <= cuenta_pulso + 1;
                    end if;

                when ESPERAR_RETIRO =>
                    if presencia_fisica = '0' then
                        cuenta_liberacion <= 0;
                    end if;

                when ESPERAR_LIBERACION =>
                    if presencia_fisica = '1' then
                        cuenta_liberacion <= 0;
                    elsif cuenta_liberacion = CICLOS_LIBERACION-1 then
                        cuenta_liberacion <= 0;
                    else
                        cuenta_liberacion <= cuenta_liberacion + 1;
                    end if;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(
        estado_actual,
        pulso_presencia,
        presencia_fisica,
        hc_termino,
        tcs_termino,
        hc_lista,
        tcs_lista,
        cuenta_pulso,
        cuenta_liberacion
    )
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when ESPERA =>
                if pulso_presencia = '1' then
                    estado_siguiente <= INICIAR_MEDICIONES;
                end if;

            when INICIAR_MEDICIONES =>
                estado_siguiente <= ESPERAR_MEDICIONES;

            when ESPERAR_MEDICIONES =>
                if (hc_termino = '1' or hc_lista = '1') and
                   (tcs_termino = '1' or tcs_lista = '1') then
                    estado_siguiente <= PREPARAR_EVENTO;
                end if;

            when PREPARAR_EVENTO =>
                estado_siguiente <= ENVIAR_EVENTO;

            when ENVIAR_EVENTO =>
                if cuenta_pulso = CICLOS_PULSO_CORE-1 then
                    estado_siguiente <= ESPERAR_RETIRO;
                end if;

            when ESPERAR_RETIRO =>
                if presencia_fisica = '0' then
                    estado_siguiente <= ESPERAR_LIBERACION;
                end if;

            when ESPERAR_LIBERACION =>
                if presencia_fisica = '1' then
                    estado_siguiente <= ESPERAR_RETIRO;
                elsif cuenta_liberacion = CICLOS_LIBERACION-1 then
                    estado_siguiente <= ESPERA;
                end if;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        iniciar_hc       <= '0';
        iniciar_tcs      <= '0';
        presencia_core_n <= '1';
        ocupado          <= '1';

        case estado_actual is

            when ESPERA =>
                ocupado <= '0';

            when INICIAR_MEDICIONES =>
                iniciar_hc  <= '1';
                iniciar_tcs <= '1';

            when ENVIAR_EVENTO =>
                presencia_core_n <= '0';

            when others =>
                null;

        end case;
    end process;

    color_core     <= color_core_reg;
    tamano_core    <= tamano_core_reg;
    error_sensores <= error_reg;

end architecture fsm_tres_procesos;
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

## SystemAlfa/Pruebas_ModelSim/maquina_estados_control_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity maquina_estados_control_TB is
end entity maquina_estados_control_TB;

architecture prueba
of maquina_estados_control_TB is

    component maquina_estados_control is
        port (
            reloj,
            reinicio :
                in std_logic;

            marcha,
            nueva_pieza,
            pieza_valida :
                in std_logic;

            registrar_evento,
            contar_pieza :
                out std_logic;

            alarma_estado,
            ocupado :
                out std_logic;

            estado_codigo :
                out std_logic_vector(2 downto 0)
        );
    end component;

    signal RELOJ_TB :
        std_logic := '0';

    signal REINICIO_TB :
        std_logic := '1';

    signal MARCHA_TB :
        std_logic := '0';

    signal NUEVA_PIEZA_TB :
        std_logic := '0';

    signal PIEZA_VALIDA_TB :
        std_logic := '0';

    signal REGISTRAR_EVENTO_TB :
        std_logic;

    signal CONTAR_PIEZA_TB :
        std_logic;

    signal ALARMA_ESTADO_TB :
        std_logic;

    signal OCUPADO_TB :
        std_logic;

    signal ESTADO_CODIGO_TB :
        std_logic_vector(2 downto 0);

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <=
        not RELOJ_TB after 10 ns
        when not FIN_TB
        else '0';

    DUT1 : maquina_estados_control
        port map (
            reloj =>
                RELOJ_TB,

            reinicio =>
                REINICIO_TB,

            marcha =>
                MARCHA_TB,

            nueva_pieza =>
                NUEVA_PIEZA_TB,

            pieza_valida =>
                PIEZA_VALIDA_TB,

            registrar_evento =>
                REGISTRAR_EVENTO_TB,

            contar_pieza =>
                CONTAR_PIEZA_TB,

            alarma_estado =>
                ALARMA_ESTADO_TB,

            ocupado =>
                OCUPADO_TB,

            estado_codigo =>
                ESTADO_CODIGO_TB
        );

    STIMULUS : process

        procedure esperar_estado(
            codigo :
                std_logic_vector(2 downto 0)
        ) is
        begin

            wait until rising_edge(RELOJ_TB);

            wait for 1 ns;

            assert
                ESTADO_CODIGO_TB = codigo

                report
                    "Estado inesperado"

                severity failure;

        end procedure;

    begin

        --------------------------------------------------------
        -- RESET
        --------------------------------------------------------

        wait for 25 ns;

        REINICIO_TB <= '0';

        wait for 5 ns;

        assert
            ESTADO_CODIGO_TB = "000"

            report
                "No inicia en ESPERA"

            severity failure;

        --------------------------------------------------------
        -- CAMINO VALIDO
        --------------------------------------------------------

        MARCHA_TB <= '1';

        PIEZA_VALIDA_TB <= '1';

        NUEVA_PIEZA_TB <= '1';

        esperar_estado("001"); -- DETECCION

        NUEVA_PIEZA_TB <= '0';

        esperar_estado("010"); -- LECTURA

        esperar_estado("011"); -- CLASIFICACION

        esperar_estado("100"); -- REGISTRO

        assert
            REGISTRAR_EVENTO_TB = '1'
            and
            CONTAR_PIEZA_TB = '1'

            report
                "No registra pieza valida"

            severity failure;

        esperar_estado("000"); -- ESPERA

        --------------------------------------------------------
        -- CAMINO INVALIDO
        --------------------------------------------------------

        PIEZA_VALIDA_TB <= '0';

        NUEVA_PIEZA_TB <= '1';

        esperar_estado("001");

        NUEVA_PIEZA_TB <= '0';

        esperar_estado("010");

        esperar_estado("011");

        assert
            REGISTRAR_EVENTO_TB = '1'
            and
            CONTAR_PIEZA_TB = '0'
            and
            ALARMA_ESTADO_TB = '1'

            report
                "Rechazo incorrecto"

            severity failure;

        esperar_estado("101");

        assert
            ALARMA_ESTADO_TB = '1'

            report
                "Alarma no retenida"

            severity failure;

        --------------------------------------------------------
        -- RESET DESDE ERROR
        --------------------------------------------------------

        REINICIO_TB <= '1';

        wait for 2 ns;

        assert
            ESTADO_CODIGO_TB = "000"

            report
                "Reset no vuelve a ESPERA"

            severity failure;

        report
            "OK: maquina_estados_control_TB"
            severity note;

        FIN_TB <= true;

        wait;

    end process STIMULUS;

end architecture prueba;
```

## SystemAlfa/Pruebas_ModelSim/memoria_ram_historial_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria_ram_historial_TB is
end entity memoria_ram_historial_TB;

architecture prueba
of memoria_ram_historial_TB is

    component memoria_ram_historial is
        port (
            reloj :
                in std_logic;

            habilitar_escritura :
                in std_logic;

            direccion_escritura :
                in std_logic_vector(2 downto 0);

            direccion_lectura :
                in std_logic_vector(2 downto 0);

            dato_entrada :
                in std_logic_vector(20 downto 0);

            dato_salida :
                out std_logic_vector(20 downto 0)
        );
    end component;

    signal RELOJ_TB :
        std_logic := '0';

    signal HABILITAR_ESCRITURA_TB :
        std_logic := '0';

    signal DIRECCION_ESCRITURA_TB :
        std_logic_vector(2 downto 0) :=
        "000";

    signal DIRECCION_LECTURA_TB :
        std_logic_vector(2 downto 0) :=
        "000";

    signal DATO_ENTRADA_TB :
        std_logic_vector(20 downto 0) :=
        (others => '0');

    signal DATO_SALIDA_TB :
        std_logic_vector(20 downto 0);

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <=
        not RELOJ_TB after 10 ns
        when not FIN_TB
        else '0';

    DUT1 : memoria_ram_historial
        port map (
            reloj =>
                RELOJ_TB,

            habilitar_escritura =>
                HABILITAR_ESCRITURA_TB,

            direccion_escritura =>
                DIRECCION_ESCRITURA_TB,

            direccion_lectura =>
                DIRECCION_LECTURA_TB,

            dato_entrada =>
                DATO_ENTRADA_TB,

            dato_salida =>
                DATO_SALIDA_TB
        );

    STIMULUS : process

        procedure escribir(
            direccion : natural;
            dato      : natural
        ) is
        begin

            DIRECCION_ESCRITURA_TB <=
                std_logic_vector(
                    to_unsigned(direccion, 3)
                );

            DATO_ENTRADA_TB <=
                std_logic_vector(
                    to_unsigned(dato, 21)
                );

            HABILITAR_ESCRITURA_TB <= '1';

            wait until rising_edge(RELOJ_TB);

            wait for 1 ns;

            HABILITAR_ESCRITURA_TB <= '0';

        end procedure;

        procedure comprobar(
            direccion : natural;
            dato      : natural
        ) is
        begin

            DIRECCION_LECTURA_TB <=
                std_logic_vector(
                    to_unsigned(direccion, 3)
                );

            wait for 2 ns;

            assert
                DATO_SALIDA_TB =
                std_logic_vector(
                    to_unsigned(dato, 21)
                )

                report
                    "Lectura incorrecta de RAM"

                severity failure;

        end procedure;

    begin

        -- Escribir las ocho posiciones.
        for i in 0 to 7 loop

            escribir(
                i,
                100 + i
            );

        end loop;

        -- Leerlas.
        for i in 0 to 7 loop

            comprobar(
                i,
                100 + i
            );

        end loop;

        -- Sobrescribir posicion 3.
        escribir(
            3,
            777
        );

        comprobar(
            3,
            777
        );

        -- Las otras deben seguir iguales.
        comprobar(
            2,
            102
        );

        comprobar(
            4,
            104
        );

        report
            "OK: memoria_ram_historial_TB"
            severity note;

        FIN_TB <= true;

        wait;

    end process STIMULUS;

end architecture prueba;
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

## SystemAlfa/Pruebas_ModelSim/RF1_Transporte_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF1_Transporte_TB is
end entity RF1_Transporte_TB;

architecture RF1_Transporte_TB_arch of RF1_Transporte_TB is

    component RF1_Transporte is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO : positive := 500000
        );
        port (
            RELOJ, REINICIO_BAJO,
            CAMBIO_VELOCIDAD, LINEA_MARCHA : in std_logic;

            VISOR_VELOCIDAD : out std_logic_vector(6 downto 0);
            LINEA_ACTIVA : out std_logic
        );
    end component;

    signal RELOJ_TB : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal CAMBIO_VELOCIDAD_TB : std_logic := '1';
    signal LINEA_MARCHA_TB : std_logic := '1';

    signal VISOR_VELOCIDAD_TB : std_logic_vector(6 downto 0);
    signal LINEA_ACTIVA_TB : std_logic;
    signal FIN_TB : boolean := false;

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", "1111001", "0100100", "0110000",
        "0011001", "0010010", "0000010", "1111000",
        "0000000", "0010000", "0001000", "0000011",
        "1000110", "0100001", "0000110", "0001110"
    );

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF1_Transporte
        generic map (
            FRECUENCIA_RELOJ_HZ => 60,
            CICLOS_FILTRO => 3
        )
        port map (
            RELOJ => RELOJ_TB,
            REINICIO_BAJO => REINICIO_BAJO_TB,
            CAMBIO_VELOCIDAD => CAMBIO_VELOCIDAD_TB,
            LINEA_MARCHA => LINEA_MARCHA_TB,
            VISOR_VELOCIDAD => VISOR_VELOCIDAD_TB,
            LINEA_ACTIVA => LINEA_ACTIVA_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

    begin

        esperar(4);
        REINICIO_BAJO_TB <= '1';

        -- SW3 sigue alto: debe arrancar sin pedir una transicion.
        wait until LINEA_ACTIVA_TB = '1' for 2 us;

        assert LINEA_ACTIVA_TB = '1'
            report "No arranca con SW3 alto tras reset"
            severity failure;

        assert VISOR_VELOCIDAD_TB = PATRONES(0)
            report "Velocidad inicial distinta de cero"
            severity failure;

        -- Reset durante la marcha.
        REINICIO_BAJO_TB <= '0';
        esperar(5);

        assert LINEA_ACTIVA_TB = '0'
            report "La linea sigue activa durante reset"
            severity failure;

        REINICIO_BAJO_TB <= '1';

        wait until LINEA_ACTIVA_TB = '1' for 2 us;

        assert LINEA_ACTIVA_TB = '1'
            report "No reanuda al soltar reset con SW3 alto"
            severity failure;

        -- Probar los cuatro niveles.
        for i in 1 to 4 loop

            CAMBIO_VELOCIDAD_TB <= '0';
            esperar(10);

            assert VISOR_VELOCIDAD_TB = PATRONES(i mod 4)
                report "Nivel de velocidad incorrecto"
                severity failure;

            -- Mantener el boton no debe cambiar otra vez.
            esperar(25);

            assert VISOR_VELOCIDAD_TB = PATRONES(i mod 4)
                report "Una pulsacion produjo varios cambios"
                severity failure;

            CAMBIO_VELOCIDAD_TB <= '1';
            esperar(10);

        end loop;

        -- SW3 bajo detiene la linea.
        LINEA_MARCHA_TB <= '0';
        esperar(8);

        for i in 1 to 100 loop
            esperar;

            assert LINEA_ACTIVA_TB = '0'
                report "La linea no permanece detenida"
                severity failure;
        end loop;

        report "OK: RF1_Transporte_TB" severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF1_Transporte_TB_arch;
```

## SystemAlfa/Pruebas_ModelSim/RF2_Inspeccion_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF2_Inspeccion_TB is
end entity RF2_Inspeccion_TB;

architecture RF2_Inspeccion_TB_arch of RF2_Inspeccion_TB is

    component RF2_Inspeccion is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO :
                in std_logic;

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO, LED_PIEZA :
                out std_logic
        );
    end component;

    signal RELOJ_TB         : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal PRESENCIA_TB     : std_logic := '0';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal LED_PIEZA_TB :
        std_logic;

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF2_Inspeccion
        generic map (
            CICLOS_FILTRO => 3
        )
        port map (
            RELOJ           => RELOJ_TB,
            REINICIO_BAJO   => REINICIO_BAJO_TB,
            PRESENCIA       => PRESENCIA_TB,
            SELECTOR_COLOR  => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO => SELECTOR_TAMANO_TB,
            LED_COLOR       => LED_COLOR_TB,
            LED_TAMANO      => LED_TAMANO_TB,
            LED_PIEZA       => LED_PIEZA_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

    begin

        -- Liberar reinicio.
        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(16);

        assert LED_PIEZA_TB = '0'
            report "RF2 detecto una pieza inexistente"
            severity failure;

        -- Sensor libre.
        PRESENCIA_TB <= '1';
        esperar(10);

        -- Probar las 8 combinaciones posibles.
        for i in 0 to 7 loop

            SELECTOR_COLOR_TB <=
                std_logic_vector(to_unsigned(i / 2, 2));

            if i mod 2 = 0 then
                SELECTOR_TAMANO_TB <= '0';
            else
                SELECTOR_TAMANO_TB <= '1';
            end if;

            esperar(8);

            -- Pulsar presencia.
            PRESENCIA_TB <= '0';
            esperar(10);

            assert
                LED_COLOR_TB = SELECTOR_COLOR_TB and
                LED_TAMANO_TB = SELECTOR_TAMANO_TB

                report "RF2 no guardo los atributos"
                severity failure;

            assert LED_PIEZA_TB = '1'
                report "RF2 no indico pieza"
                severity failure;

            -- Liberar presencia.
            PRESENCIA_TB <= '1';
            esperar(10);

        end loop;

        -- Los atributos no deben cambiar solos.
        SELECTOR_COLOR_TB <= "01";
        SELECTOR_TAMANO_TB <= '0';
        esperar(10);

        assert
            LED_COLOR_TB = "11" and
            LED_TAMANO_TB = '1'

            report "Los atributos cambiaron sin nueva captura"
            severity failure;

        -- Reiniciar.
        REINICIO_BAJO_TB <= '0';
        esperar(4);

        assert
            LED_PIEZA_TB = '0' and
            LED_COLOR_TB = "00" and
            LED_TAMANO_TB = '0'

            report "RF2 no se reinicio"
            severity failure;

        report "OK: RF2_Inspeccion_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF2_Inspeccion_TB_arch;
```

## SystemAlfa/Pruebas_ModelSim/RF3_Clasificacion_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF3_Clasificacion_TB is
end entity RF3_Clasificacion_TB;

architecture RF3_Clasificacion_TB_arch
of RF3_Clasificacion_TB is

    component RF3_Clasificacion is
        generic (
            CICLOS_FILTRO : positive := 500000;
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO :
                in std_logic;

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO :
                out std_logic;

            RUTA_PIEZA :
                out std_logic_vector(3 downto 0);

            ALARMA :
                out std_logic
        );
    end component;

    signal RELOJ_TB         : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal PRESENCIA_TB     : std_logic := '1';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal RUTA_PIEZA_TB :
        std_logic_vector(3 downto 0);

    signal ALARMA_TB :
        std_logic;

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF3_Clasificacion
        generic map (
            CICLOS_FILTRO => 3,
            CICLOS_ATASCO => 100
        )
        port map (
            RELOJ           => RELOJ_TB,
            REINICIO_BAJO   => REINICIO_BAJO_TB,
            PRESENCIA       => PRESENCIA_TB,
            SELECTOR_COLOR  => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO => SELECTOR_TAMANO_TB,
            LED_COLOR       => LED_COLOR_TB,
            LED_TAMANO      => LED_TAMANO_TB,
            RUTA_PIEZA      => RUTA_PIEZA_TB,
            ALARMA          => ALARMA_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

        procedure ingresar(categoria : positive) is
        begin

            SELECTOR_COLOR_TB <=
                std_logic_vector(
                    to_unsigned((categoria + 1) / 2, 2)
                );

            if categoria mod 2 = 0 then
                SELECTOR_TAMANO_TB <= '1';
            else
                SELECTOR_TAMANO_TB <= '0';
            end if;

            esperar(8);

            PRESENCIA_TB <= '0';
            esperar(10);

            PRESENCIA_TB <= '1';
            esperar(10);

        end procedure;

    begin

        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(10);

        assert
            RUTA_PIEZA_TB = "0000" and
            ALARMA_TB = '0'

            report "Estado inicial incorrecto"
            severity failure;

        -- Las seis combinaciones deben ser válidas.
        for i in 1 to 6 loop

            ingresar(i);

            assert
                RUTA_PIEZA_TB =
                    std_logic_vector(to_unsigned(i, 4))

                report "Categoria incorrecta"
                severity failure;

            assert ALARMA_TB = '0'
                report "Categoria valida genero alarma"
                severity failure;

        end loop;

        -- Color 00 debe ser rechazo.
        SELECTOR_COLOR_TB <= "00";
        esperar(8);

        PRESENCIA_TB <= '0';
        esperar(10);

        PRESENCIA_TB <= '1';
        esperar(10);

        assert
            RUTA_PIEZA_TB = "1000" and
            ALARMA_TB = '1'

            report "El rechazo no funciona"
            severity failure;

        report "OK: RF3_Clasificacion_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF3_Clasificacion_TB_arch;
```

## SystemAlfa/Pruebas_ModelSim/RF4_Historial_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF4_Historial_TB is
end entity RF4_Historial_TB;

architecture RF4_Historial_TB_arch
of RF4_Historial_TB is

    component RF4_Historial is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO,
            VER_HISTORIAL,
            SIGUIENTE_HISTORIAL :
                in std_logic;

            VISOR_TOTAL,
            VISOR_TOTAL_ALTO :
                out std_logic_vector(6 downto 0);

            TIEMPO_HISTORIAL_ALTO,
            TIEMPO_HISTORIAL_BAJO :
                out std_logic_vector(6 downto 0);

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO,
            LED_REGISTRO_VALIDO,
            LED_REGLA_VALIDA,
            LED_LIMITE :
                out std_logic;

            RUTA_REGLA :
                out std_logic_vector(3 downto 0)
        );
    end component;

    signal RELOJ_TB         : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal PRESENCIA_TB     : std_logic := '1';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal VER_HISTORIAL_TB :
        std_logic := '0';

    signal SIGUIENTE_HISTORIAL_TB :
        std_logic := '0';

    signal VISOR_TOTAL_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_TOTAL_ALTO_TB :
        std_logic_vector(6 downto 0);

    signal TIEMPO_HISTORIAL_ALTO_TB :
        std_logic_vector(6 downto 0);

    signal TIEMPO_HISTORIAL_BAJO_TB :
        std_logic_vector(6 downto 0);

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal LED_REGISTRO_VALIDO_TB :
        std_logic;

    signal LED_REGLA_VALIDA_TB :
        std_logic;

    signal LED_LIMITE_TB :
        std_logic;

    signal RUTA_REGLA_TB :
        std_logic_vector(3 downto 0);

    signal FIN_TB :
        boolean := false;

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", "1111001", "0100100", "0110000",
        "0011001", "0010010", "0000010", "1111000",
        "0000000", "0010000", "0001000", "0000011",
        "1000110", "0100001", "0000110", "0001110"
    );

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

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF4_Historial
        generic map (
            FRECUENCIA_RELOJ_HZ => 1000,
            CICLOS_FILTRO       => 3
        )
        port map (
            RELOJ                  => RELOJ_TB,
            REINICIO_BAJO          => REINICIO_BAJO_TB,
            PRESENCIA              => PRESENCIA_TB,
            SELECTOR_COLOR         => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO        => SELECTOR_TAMANO_TB,
            VER_HISTORIAL          => VER_HISTORIAL_TB,
            SIGUIENTE_HISTORIAL    => SIGUIENTE_HISTORIAL_TB,
            VISOR_TOTAL            => VISOR_TOTAL_TB,
            VISOR_TOTAL_ALTO       => VISOR_TOTAL_ALTO_TB,
            TIEMPO_HISTORIAL_ALTO  => TIEMPO_HISTORIAL_ALTO_TB,
            TIEMPO_HISTORIAL_BAJO  => TIEMPO_HISTORIAL_BAJO_TB,
            LED_COLOR              => LED_COLOR_TB,
            LED_TAMANO             => LED_TAMANO_TB,
            LED_REGISTRO_VALIDO    => LED_REGISTRO_VALIDO_TB,
            LED_REGLA_VALIDA       => LED_REGLA_VALIDA_TB,
            LED_LIMITE             => LED_LIMITE_TB,
            RUTA_REGLA             => RUTA_REGLA_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

        procedure ingresar(id : positive) is
        begin

            SELECTOR_COLOR_TB <=
                std_logic_vector(
                    to_unsigned(((id - 1) mod 6) / 2 + 1, 2)
                );

            if id mod 2 = 0 then
                SELECTOR_TAMANO_TB <= '1';
            else
                SELECTOR_TAMANO_TB <= '0';
            end if;

            esperar(8);

            PRESENCIA_TB <= '0';
            esperar(10);

            PRESENCIA_TB <= '1';
            esperar(10);

        end procedure;

        procedure avanzar is
        begin
            SIGUIENTE_HISTORIAL_TB <= '1';
            esperar(10);

            SIGUIENTE_HISTORIAL_TB <= '0';
            esperar(10);
        end procedure;

    begin

        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(12);

        -- Historial inicialmente vacío.
        VER_HISTORIAL_TB <= '1';
        esperar(5);

        assert LED_REGISTRO_VALIDO_TB = '0'
            report "Historial no inicia vacio"
            severity failure;

        VER_HISTORIAL_TB <= '0';
        esperar(5);

        -- Registrar dos piezas.
        ingresar(1);
        ingresar(2);

        VER_HISTORIAL_TB <= '1';
        esperar(5);

        assert LED_REGISTRO_VALIDO_TB = '1'
            report "No se recupero el primer registro"
            severity failure;

        avanzar;

        assert LED_REGISTRO_VALIDO_TB = '1'
            report "No se recupero el segundo registro"
            severity failure;

        report "OK: RF4_Historial_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF4_Historial_TB_arch;
```

## SystemAlfa/Pruebas_ModelSim/RF5_Conteo_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF5_Conteo_TB is
end entity RF5_Conteo_TB;

architecture RF5_Conteo_TB_arch
of RF5_Conteo_TB is

    component RF5_Conteo is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000;
            CICLOS_ATASCO       : positive := 250000000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO,
            CAMBIO_VELOCIDAD,
            LINEA_MARCHA :
                in std_logic;

            VISOR_TOTAL,
            VISOR_TOTAL_MEDIO,
            VISOR_TOTAL_ALTO :
                out std_logic_vector(6 downto 0);

            VISOR_VELOCIDAD :
                out std_logic_vector(6 downto 0);

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO,
            LINEA_ACTIVA,
            LED_RECHAZO,
            ALARMA,
            LED_LIMITE :
                out std_logic
        );
    end component;

    signal RELOJ_TB         : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal PRESENCIA_TB     : std_logic := '1';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal CAMBIO_VELOCIDAD_TB :
        std_logic := '1';

    signal LINEA_MARCHA_TB :
        std_logic := '0';

    signal VISOR_TOTAL_TB,
           VISOR_TOTAL_MEDIO_TB,
           VISOR_TOTAL_ALTO_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_VELOCIDAD_TB :
        std_logic_vector(6 downto 0);

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB,
           LINEA_ACTIVA_TB,
           LED_RECHAZO_TB,
           ALARMA_TB,
           LED_LIMITE_TB :
        std_logic;

    signal FIN_TB :
        boolean := false;

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", "1111001", "0100100", "0110000",
        "0011001", "0010010", "0000010", "1111000",
        "0000000", "0010000", "0001000", "0000011",
        "1000110", "0100001", "0000110", "0001110"
    );

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

    function leer_decimal(
        c, d, u : std_logic_vector(6 downto 0)
    ) return integer is

        variable a, b, e : integer;

    begin

        a := leer_hex(c);
        b := leer_hex(d);
        e := leer_hex(u);

        if
            a < 0 or a > 9 or
            b < 0 or b > 9 or
            e < 0 or e > 9
        then
            return -1;
        end if;

        return 100*a + 10*b + e;

    end function;

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF5_Conteo
        generic map (
            FRECUENCIA_RELOJ_HZ => 60,
            CICLOS_FILTRO       => 3,
            CICLOS_ATASCO       => 10000
        )
        port map (
            RELOJ               => RELOJ_TB,
            REINICIO_BAJO       => REINICIO_BAJO_TB,
            PRESENCIA           => PRESENCIA_TB,
            SELECTOR_COLOR      => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO     => SELECTOR_TAMANO_TB,
            CAMBIO_VELOCIDAD    => CAMBIO_VELOCIDAD_TB,
            LINEA_MARCHA        => LINEA_MARCHA_TB,
            VISOR_TOTAL         => VISOR_TOTAL_TB,
            VISOR_TOTAL_MEDIO   => VISOR_TOTAL_MEDIO_TB,
            VISOR_TOTAL_ALTO    => VISOR_TOTAL_ALTO_TB,
            VISOR_VELOCIDAD     => VISOR_VELOCIDAD_TB,
            LED_COLOR           => LED_COLOR_TB,
            LED_TAMANO          => LED_TAMANO_TB,
            LINEA_ACTIVA        => LINEA_ACTIVA_TB,
            LED_RECHAZO         => LED_RECHAZO_TB,
            ALARMA              => ALARMA_TB,
            LED_LIMITE          => LED_LIMITE_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

        procedure ingresar(categoria : positive) is
        begin

            SELECTOR_COLOR_TB <=
                std_logic_vector(
                    to_unsigned((categoria + 1) / 2, 2)
                );

            if categoria mod 2 = 0 then
                SELECTOR_TAMANO_TB <= '1';
            else
                SELECTOR_TAMANO_TB <= '0';
            end if;

            esperar(8);

            PRESENCIA_TB <= '0';
            esperar(10);

            PRESENCIA_TB <= '1';
            esperar(10);

        end procedure;

        procedure comprobar(n : natural) is
        begin

            assert
                leer_decimal(
                    VISOR_TOTAL_ALTO_TB,
                    VISOR_TOTAL_MEDIO_TB,
                    VISOR_TOTAL_TB
                ) = n

                report "Total decimal incorrecto"
                severity failure;

        end procedure;

    begin

        -- Reset.
        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(12);

        -- Rearmar línea.
        LINEA_MARCHA_TB <= '0';
        esperar(8);

        LINEA_MARCHA_TB <= '1';
        esperar(8);

        comprobar(0);

        -- Las seis categorías válidas deben contar.
        for i in 1 to 6 loop
            ingresar(i);
            comprobar(i);
        end loop;

        -- Detener línea: no debe contar.
        LINEA_MARCHA_TB <= '0';
        esperar(8);

        ingresar(1);
        comprobar(6);

        -- Reanudar.
        LINEA_MARCHA_TB <= '1';
        esperar(8);

        -- Color inválido.
        SELECTOR_COLOR_TB <= "00";
        esperar(8);

        PRESENCIA_TB <= '0';
        esperar(10);

        PRESENCIA_TB <= '1';
        esperar(10);

        comprobar(6);

        assert
            ALARMA_TB = '1' and
            LED_RECHAZO_TB = '1' and
            LINEA_ACTIVA_TB = '0'

            report "Rechazo incorrecto"
            severity failure;

        report "OK: RF5_Conteo_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF5_Conteo_TB_arch;
```

## SystemAlfa/Pruebas_ModelSim/rom_categorias_TB.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_categorias_TB is
end entity rom_categorias_TB;

architecture prueba of rom_categorias_TB is

    component rom_categorias is
        port (
            direccion :
                in std_logic_vector(2 downto 0);

            dato :
                out std_logic_vector(4 downto 0)
        );
    end component;

    signal DIRECCION_TB :
        std_logic_vector(2 downto 0) :=
        "000";

    signal DATO_TB :
        std_logic_vector(4 downto 0);

begin

    DUT1 : rom_categorias
        port map (
            direccion =>
                DIRECCION_TB,

            dato =>
                DATO_TB
        );

    STIMULUS : process

        type tipo_esperados is
            array (0 to 7)
            of std_logic_vector(4 downto 0);

        constant ESPERADOS :
            tipo_esperados := (

            "01000",
            "01000",
            "10001",
            "10010",
            "10011",
            "10100",
            "10101",
            "10110"

        );

    begin

        for i in 0 to 7 loop

            DIRECCION_TB <=
                std_logic_vector(
                    to_unsigned(i, 3)
                );

            wait for 10 ns;

            assert
                DATO_TB = ESPERADOS(i)

                report
                    "Dato incorrecto en ROM"

                severity failure;

        end loop;

        report
            "OK: rom_categorias_TB"
            severity note;

        wait;

    end process STIMULUS;

end architecture prueba;
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

## SystemAlfa/RF1_Transporte/RF1_Placa.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF1_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW     : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end entity RF1_Placa;

architecture estructural of RF1_Placa is

    component RF1_Transporte is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            RELOJ             : in std_logic;
            REINICIO_BAJO     : in std_logic;
            CAMBIO_VELOCIDAD  : in std_logic;
            LINEA_MARCHA      : in std_logic;

            VISOR_VELOCIDAD : out std_logic_vector(6 downto 0);
            LINEA_ACTIVA    : out std_logic
        );
    end component;

    signal visor_velocidad : std_logic_vector(6 downto 0);
    signal linea_activa    : std_logic;

begin

    U_RF1 : RF1_Transporte
        port map (
            RELOJ            => CLOCK_50,
            REINICIO_BAJO    => BUTTON(1),
            CAMBIO_VELOCIDAD => BUTTON(2),
            LINEA_MARCHA     => SW(3),

            VISOR_VELOCIDAD => visor_velocidad,
            LINEA_ACTIVA    => linea_activa
        );

    LEDG(2 downto 0) <= (others => '0');
    LEDG(3) <= linea_activa;
    LEDG(9 downto 4) <= (others => '0');

    HEX0 <= "1111111";
    HEX1 <= visor_velocidad;
    HEX2 <= "1111111";
    HEX3 <= "1111111";

end architecture estructural;
```

## SystemAlfa/RF1_Transporte/RF1_Transporte.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF1_Transporte is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO       : positive := 500000
    );
    port (
        RELOJ             : in std_logic;
        REINICIO_BAJO     : in std_logic;
        CAMBIO_VELOCIDAD  : in std_logic;
        LINEA_MARCHA      : in std_logic;

        VISOR_VELOCIDAD : out std_logic_vector(6 downto 0);
        LINEA_ACTIVA    : out std_logic
    );
end entity RF1_Transporte;

architecture estructural of RF1_Transporte is

    component reinicio_seguro is
        port (
            reloj           : in std_logic;
            reinicio_bajo   : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component selector_velocidad is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            reloj        : in std_logic;
            reinicio     : in std_logic;
            boton_bajo   : in std_logic;

            nivel_salida : out std_logic_vector(1 downto 0);
            pulso_linea  : out std_logic;
            segmentos    : out std_logic_vector(6 downto 0)
        );
    end component;

    component control_linea is
        port (
            reloj               : in std_logic;
            reinicio            : in std_logic;
            marcha              : in std_logic;
            bloqueo             : in std_logic;
            pulso_linea_entrada : in std_logic;

            pulso_motor : out std_logic;
            led_linea   : out std_logic;
            en_marcha   : out std_logic
        );
    end component;

    signal reinicio_alto : std_logic;
    signal pulso_linea   : std_logic;

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_VELOCIDAD : selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO       => CICLOS_FILTRO
        )
        port map (
            reloj        => RELOJ,
            reinicio     => reinicio_alto,
            boton_bajo   => CAMBIO_VELOCIDAD,
            nivel_salida => open,
            pulso_linea  => pulso_linea,
            segmentos    => VISOR_VELOCIDAD
        );

    U_LINEA : control_linea
        port map (
            reloj                => RELOJ,
            reinicio             => reinicio_alto,
            marcha               => LINEA_MARCHA,
            bloqueo              => '0',
            pulso_linea_entrada  => pulso_linea,

            pulso_motor => open,
            led_linea   => LINEA_ACTIVA,
            en_marcha   => open
        );

end architecture estructural;
```

## SystemAlfa/RF2_Inspeccion/RF2_Inspeccion.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF2_Inspeccion is
    generic (
        CICLOS_FILTRO : positive := 500000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);
        SELECTOR_TAMANO : in std_logic;

        LED_COLOR : out std_logic_vector(1 downto 0);
        LED_TAMANO, LED_PIEZA : out std_logic
    );
end entity RF2_Inspeccion;

architecture estructural of RF2_Inspeccion is

    component reinicio_seguro is
        port (
            reloj, reinicio_bajo : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, presencia_baja : in std_logic;
            color_selector : in std_logic_vector(1 downto 0);
            tamano_selector : in std_logic;

            nueva_pieza, presencia_activa : out std_logic;
            color : out std_logic_vector(1 downto 0);
            tamano : out std_logic
        );
    end component;

    signal reinicio_alto, nueva : std_logic;

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,
            color_selector   => SELECTOR_COLOR,
            tamano_selector  => SELECTOR_TAMANO,
            nueva_pieza      => nueva,
            presencia_activa => open,
            color            => LED_COLOR,
            tamano           => LED_TAMANO
        );

    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            LED_PIEZA <= '0';

        elsif rising_edge(RELOJ) then
            if nueva = '1' then
                LED_PIEZA <= '1';
            end if;
        end if;
    end process;

end architecture estructural;
```

## SystemAlfa/RF2_Inspeccion/RF2_Placa.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF2_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW     : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end entity RF2_Placa;

architecture estructural of RF2_Placa is

    component RF2_Inspeccion is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            RELOJ          : in std_logic;
            REINICIO_BAJO  : in std_logic;
            PRESENCIA      : in std_logic;

            SELECTOR_COLOR  : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO : in std_logic;

            LED_COLOR  : out std_logic_vector(1 downto 0);
            LED_TAMANO : out std_logic;
            LED_PIEZA  : out std_logic
        );
    end component;

    signal led_color  : std_logic_vector(1 downto 0);
    signal led_tamano : std_logic;
    signal led_pieza  : std_logic;

begin

    U_RF2 : RF2_Inspeccion
        port map (
            RELOJ          => CLOCK_50,
            REINICIO_BAJO  => BUTTON(1),
            PRESENCIA      => BUTTON(0),

            SELECTOR_COLOR  => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),

            LED_COLOR  => led_color,
            LED_TAMANO => led_tamano,
            LED_PIEZA  => led_pieza
        );

    LEDG(1 downto 0) <= led_color;
    LEDG(2) <= led_tamano;
    LEDG(3) <= led_pieza;
    LEDG(9 downto 4) <= (others => '0');

    HEX0 <= "1111111";
    HEX1 <= "1111111";
    HEX2 <= "1111111";
    HEX3 <= "1111111";

end architecture estructural;
```

## SystemAlfa/RF3_Clasificacion/RF3_Clasificacion.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF3_Clasificacion is
    generic (
        CICLOS_FILTRO : positive := 500000;
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);
        SELECTOR_TAMANO : in std_logic;

        LED_COLOR : out std_logic_vector(1 downto 0);
        LED_TAMANO : out std_logic;
        RUTA_PIEZA : out std_logic_vector(3 downto 0);
        ALARMA : out std_logic
    );
end entity RF3_Clasificacion;

architecture estructural of RF3_Clasificacion is

    component reinicio_seguro is
        port (
            reloj, reinicio_bajo : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, presencia_baja : in std_logic;
            color_selector : in std_logic_vector(1 downto 0);
            tamano_selector : in std_logic;

            nueva_pieza, presencia_activa : out std_logic;
            color : out std_logic_vector(1 downto 0);
            tamano : out std_logic
        );
    end component;

    component clasificador_ruta is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            aceptada : out std_logic
        );
    end component;

    component supervisor_error is
        generic (
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            reloj, reinicio, marcha, presencia_activa : in std_logic;
            nueva_pieza, pieza_valida : in std_logic;
            alarma : out std_logic
        );
    end component;

    signal reinicio_alto, nueva, presente, tamano, valida :
        std_logic;

    signal color : std_logic_vector(1 downto 0);
    signal ruta : std_logic_vector(3 downto 0);

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,
            color_selector   => SELECTOR_COLOR,
            tamano_selector  => SELECTOR_TAMANO,
            nueva_pieza      => nueva,
            presencia_activa => presente,
            color            => color,
            tamano           => tamano
        );

    U_CLASIFICADOR : clasificador_ruta
        port map (
            color    => color,
            tamano   => tamano,
            ruta     => ruta,
            aceptada => valida
        );

    U_ERRORES : supervisor_error
        generic map (
            CICLOS_ATASCO => CICLOS_ATASCO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            marcha           => '1',
            presencia_activa => presente,
            nueva_pieza      => nueva,
            pieza_valida     => valida,
            alarma           => ALARMA
        );

    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            RUTA_PIEZA <= "0000";

        elsif rising_edge(RELOJ) then
            if nueva = '1' then
                RUTA_PIEZA <= ruta;
            end if;
        end if;
    end process;

    LED_COLOR <= color;
    LED_TAMANO <= tamano;

end architecture estructural;
```

## SystemAlfa/RF3_Clasificacion/RF3_Placa.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF3_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW     : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end entity RF3_Placa;

architecture estructural of RF3_Placa is

    component RF3_Clasificacion is
        generic (
            CICLOS_FILTRO : positive := 500000;
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            RELOJ          : in std_logic;
            REINICIO_BAJO  : in std_logic;
            PRESENCIA      : in std_logic;

            SELECTOR_COLOR  : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO : in std_logic;

            LED_COLOR  : out std_logic_vector(1 downto 0);
            LED_TAMANO : out std_logic;

            RUTA_PIEZA : out std_logic_vector(3 downto 0);
            ALARMA     : out std_logic
        );
    end component;

    signal led_color  : std_logic_vector(1 downto 0);
    signal led_tamano : std_logic;

    signal ruta_pieza : std_logic_vector(3 downto 0);
    signal alarma     : std_logic;

begin

    U_RF3 : RF3_Clasificacion
        port map (
            RELOJ          => CLOCK_50,
            REINICIO_BAJO  => BUTTON(1),
            PRESENCIA      => BUTTON(0),

            SELECTOR_COLOR  => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),

            LED_COLOR  => led_color,
            LED_TAMANO => led_tamano,

            RUTA_PIEZA => ruta_pieza,
            ALARMA     => alarma
        );

    LEDG(1 downto 0) <= led_color;
    LEDG(2) <= led_tamano;

    LEDG(3) <= '0';

    LEDG(7 downto 4) <= ruta_pieza;

    LEDG(8) <= alarma;
    LEDG(9) <= '0';

    HEX0 <= "1111111";
    HEX1 <= "1111111";
    HEX2 <= "1111111";
    HEX3 <= "1111111";

end architecture estructural;
```

## SystemAlfa/RF4_Historial/RF4_Historial.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF4_Historial is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);

        SELECTOR_TAMANO, VER_HISTORIAL, SIGUIENTE_HISTORIAL :
            in std_logic;

        VISOR_TOTAL, VISOR_TOTAL_ALTO :
            out std_logic_vector(6 downto 0);

        TIEMPO_HISTORIAL_ALTO, TIEMPO_HISTORIAL_BAJO :
            out std_logic_vector(6 downto 0);

        LED_COLOR : out std_logic_vector(1 downto 0);

        LED_TAMANO, LED_REGISTRO_VALIDO,
        LED_REGLA_VALIDA, LED_LIMITE :
            out std_logic;

        RUTA_REGLA : out std_logic_vector(3 downto 0)
    );
end entity RF4_Historial;

architecture estructural of RF4_Historial is

    component reinicio_seguro is
        port (
            reloj, reinicio_bajo : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, presencia_baja : in std_logic;
            color_selector : in std_logic_vector(1 downto 0);
            tamano_selector : in std_logic;

            nueva_pieza, presencia_activa : out std_logic;
            color : out std_logic_vector(1 downto 0);
            tamano : out std_logic
        );
    end component;

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component divisor_frecuencia is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000
        );
        port (
            reloj, reinicio : in std_logic;
            nivel : in std_logic_vector(1 downto 0);
            pulso_linea : out std_logic
        );
    end component;

    component contador_segundos is
        port (
            reloj, reinicio, pulso_segundo : in std_logic;
            segundos : out std_logic_vector(7 downto 0)
        );
    end component;

    component sincronizador is
        generic (
            ANCHO_BITS : positive := 1
        );
        port (
            reloj, reinicio : in std_logic;
            entrada : in std_logic_vector(ANCHO_BITS-1 downto 0);
            salida : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj, reinicio, boton_entrada : in std_logic;
            pulso_salida, estado_salida : out std_logic
        );
    end component;

    component historial is
        port (
            reloj, reinicio, escribir : in std_logic;

            posicion_escritura, posicion_lectura :
                in std_logic_vector(2 downto 0);

            tiempo_entrada, identificador_entrada :
                in std_logic_vector(7 downto 0);

            color_entrada : in std_logic_vector(1 downto 0);
            tamano_entrada : in std_logic;

            tiempo_salida, identificador_salida :
                out std_logic_vector(7 downto 0);

            color_salida : out std_logic_vector(1 downto 0);
            tamano_salida, registro_valido : out std_logic
        );
    end component;

    component tabla_reglas is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            valida : out std_logic
        );
    end component;

    component decodificador_7segmentos is
        port (
            numero : in std_logic_vector(3 downto 0);
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    component registro_color is
        port (
            reloj, reinicio, HABILITAR : in std_logic;
            color_entrada : in std_logic_vector(1 downto 0);
            color_salida : out std_logic_vector(1 downto 0)
        );
    end component;

    component registro_tamano is
        port (
            reloj, reinicio, HABILITAR, tamano_entrada :
                in std_logic;
            tamano_salida : out std_logic
        );
    end component;

    signal reinicio_alto, nueva, guardar, limite :
        std_logic;

    signal color, color_historial, color_vista, color_guardado :
        std_logic_vector(1 downto 0);

    signal tamano, tamano_historial, tamano_vista, tamano_guardado :
        std_logic;

    signal total, identificador_nuevo,
           identificador_historial, identificador_vista :
        std_logic_vector(7 downto 0);

    signal segundos, tiempo_historial, tiempo_vista :
        std_logic_vector(7 downto 0);

    signal pulso_segundo, siguiente, avanzar,
           registro_historial_valido, hay_datos :
        std_logic;

    signal posicion_escritura, posicion_lectura :
        std_logic_vector(2 downto 0);

    signal modo_entrada, modo :
        std_logic_vector(0 downto 0);

    signal vista_valida, regla_valida : std_logic;
    signal ruta : std_logic_vector(3 downto 0);

    signal segmentos_identificador_bajo, segmentos_identificador_alto,
           segmentos_tiempo_bajo, segmentos_tiempo_alto :
        std_logic_vector(6 downto 0);

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,
            color_selector   => SELECTOR_COLOR,
            tamano_selector  => SELECTOR_TAMANO,
            nueva_pieza      => nueva,
            presencia_activa => open,
            color            => color,
            tamano           => tamano
        );

    -- Se permiten hasta 255 eventos por lote.
    limite <= '1' when total = x"FF" else '0';
    guardar <= nueva and not limite;

    identificador_nuevo <= std_logic_vector(unsigned(total) + 1);

    U_IDENTIFICADOR : contador_ascendente
        generic map (
            ANCHO_BITS => 8
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => guardar,
            CUENTA    => total
        );

    U_ESCRITURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => guardar,
            CUENTA    => posicion_escritura
        );

    U_PULSO_SEGUNDO : divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj       => RELOJ,
            reinicio    => reinicio_alto,
            nivel       => "01",
            pulso_linea => pulso_segundo
        );

    U_TIEMPO : contador_segundos
        port map (
            reloj         => RELOJ,
            reinicio      => reinicio_alto,
            pulso_segundo => pulso_segundo,
            segundos      => segundos
        );

    modo_entrada(0) <= VER_HISTORIAL;

    U_MODO : sincronizador
        generic map (
            ANCHO_BITS => 1
        )
        port map (
            reloj    => RELOJ,
            reinicio => reinicio_alto,
            entrada  => modo_entrada,
            salida   => modo
        );

    U_SIGUIENTE : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj         => RELOJ,
            reinicio      => reinicio_alto,
            boton_entrada => SIGUIENTE_HISTORIAL,
            pulso_salida  => siguiente,
            estado_salida => open
        );

    avanzar <= siguiente and modo(0);

    U_LECTURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => avanzar,
            CUENTA    => posicion_lectura
        );

    U_MEMORIA : historial
        port map (
            reloj                 => RELOJ,
            reinicio              => reinicio_alto,
            escribir              => guardar,
            posicion_escritura    => posicion_escritura,
            posicion_lectura      => posicion_lectura,
            tiempo_entrada        => segundos,
            identificador_entrada => identificador_nuevo,
            color_entrada         => color,
            tamano_entrada        => tamano,
            tiempo_salida         => tiempo_historial,
            identificador_salida  => identificador_historial,
            color_salida          => color_historial,
            tamano_salida         => tamano_historial,
            registro_valido       => registro_historial_valido
        );

    U_COLOR_GUARDADO : registro_color
        port map (
            reloj         => RELOJ,
            reinicio      => reinicio_alto,
            HABILITAR     => guardar,
            color_entrada => color,
            color_salida  => color_guardado
        );

    U_TAMANO_GUARDADO : registro_tamano
        port map (
            reloj          => RELOJ,
            reinicio       => reinicio_alto,
            HABILITAR      => guardar,
            tamano_entrada => tamano,
            tamano_salida  => tamano_guardado
        );

    hay_datos <= '0' when total = x"00" else '1';

    vista_valida <= registro_historial_valido
        when modo(0) = '1' else hay_datos;

    identificador_vista <= identificador_historial
        when modo(0) = '1' else total;

    color_vista <= color_historial
        when modo(0) = '1' else color_guardado;

    tamano_vista <= tamano_historial
        when modo(0) = '1' else tamano_guardado;

    tiempo_vista <= tiempo_historial
        when modo(0) = '1' else segundos;

    U_REGLAS : tabla_reglas
        port map (
            color  => color_vista,
            tamano => tamano_vista,
            ruta   => ruta,
            valida => regla_valida
        );

    U_IDENTIFICADOR_BAJO : decodificador_7segmentos
        port map (
            numero    => identificador_vista(3 downto 0),
            segmentos => segmentos_identificador_bajo
        );

    U_IDENTIFICADOR_ALTO : decodificador_7segmentos
        port map (
            numero    => identificador_vista(7 downto 4),
            segmentos => segmentos_identificador_alto
        );

    U_TIEMPO_BAJO : decodificador_7segmentos
        port map (
            numero    => tiempo_vista(3 downto 0),
            segmentos => segmentos_tiempo_bajo
        );

    U_TIEMPO_ALTO : decodificador_7segmentos
        port map (
            numero    => tiempo_vista(7 downto 4),
            segmentos => segmentos_tiempo_alto
        );

    -- Las posiciones vacias se muestran con los displays apagados
    VISOR_TOTAL <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_identificador_bajo;

    VISOR_TOTAL_ALTO <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_identificador_alto;

    TIEMPO_HISTORIAL_BAJO <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_tiempo_bajo;

    TIEMPO_HISTORIAL_ALTO <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_tiempo_alto;

    LED_COLOR <= color_vista
        when vista_valida = '1' else "00";

    LED_TAMANO <= tamano_vista and vista_valida;
    LED_REGISTRO_VALIDO <= vista_valida;
    LED_REGLA_VALIDA <= regla_valida and vista_valida;

    RUTA_REGLA <= ruta
        when vista_valida = '1' else "0000";

    LED_LIMITE <= limite;

end architecture estructural;
```

## SystemAlfa/RF4_Historial/RF4_Placa.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF4_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW     : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end entity RF4_Placa;

architecture estructural of RF4_Placa is

    component RF4_Historial is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            RELOJ         : in std_logic;
            REINICIO_BAJO : in std_logic;
            PRESENCIA     : in std_logic;

            SELECTOR_COLOR  : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO : in std_logic;

            VER_HISTORIAL       : in std_logic;
            SIGUIENTE_HISTORIAL : in std_logic;

            VISOR_TOTAL      : out std_logic_vector(6 downto 0);
            VISOR_TOTAL_ALTO : out std_logic_vector(6 downto 0);

            TIEMPO_HISTORIAL_ALTO :
                out std_logic_vector(6 downto 0);

            TIEMPO_HISTORIAL_BAJO :
                out std_logic_vector(6 downto 0);

            LED_COLOR : out std_logic_vector(1 downto 0);

            LED_TAMANO           : out std_logic;
            LED_REGISTRO_VALIDO  : out std_logic;
            LED_REGLA_VALIDA     : out std_logic;
            LED_LIMITE           : out std_logic;

            RUTA_REGLA : out std_logic_vector(3 downto 0)
        );
    end component;

    signal led_color : std_logic_vector(1 downto 0);

    signal led_tamano          : std_logic;
    signal registro_valido     : std_logic;
    signal regla_valida        : std_logic;
    signal limite              : std_logic;

    signal ruta_regla :
        std_logic_vector(3 downto 0);

    signal visor_total :
        std_logic_vector(6 downto 0);

    signal visor_total_alto :
        std_logic_vector(6 downto 0);

    signal tiempo_bajo :
        std_logic_vector(6 downto 0);

    signal tiempo_alto :
        std_logic_vector(6 downto 0);

begin

    U_RF4 : RF4_Historial
        port map (
            RELOJ         => CLOCK_50,
            REINICIO_BAJO => BUTTON(1),
            PRESENCIA     => BUTTON(0),

            SELECTOR_COLOR  => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),

            VER_HISTORIAL       => SW(4),
            SIGUIENTE_HISTORIAL => SW(5),

            VISOR_TOTAL      => visor_total,
            VISOR_TOTAL_ALTO => visor_total_alto,

            TIEMPO_HISTORIAL_ALTO => tiempo_alto,
            TIEMPO_HISTORIAL_BAJO => tiempo_bajo,

            LED_COLOR => led_color,

            LED_TAMANO          => led_tamano,
            LED_REGISTRO_VALIDO => registro_valido,
            LED_REGLA_VALIDA    => regla_valida,
            LED_LIMITE          => limite,

            RUTA_REGLA => ruta_regla
        );

    LEDG(1 downto 0) <= led_color;
    LEDG(2) <= led_tamano;
    LEDG(3) <= registro_valido;

    LEDG(7 downto 4) <= ruta_regla;

    LEDG(8) <= regla_valida;
    LEDG(9) <= limite;

    HEX0 <= visor_total;
    HEX1 <= visor_total_alto;
    HEX2 <= tiempo_bajo;
    HEX3 <= tiempo_alto;

end architecture estructural;
```

## SystemAlfa/RF5_Conteo/RF5_Conteo.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF5_Conteo is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000;
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);

        SELECTOR_TAMANO, CAMBIO_VELOCIDAD, LINEA_MARCHA :
            in std_logic;

        VISOR_TOTAL, VISOR_TOTAL_MEDIO, VISOR_TOTAL_ALTO :
            out std_logic_vector(6 downto 0);

        VISOR_VELOCIDAD : out std_logic_vector(6 downto 0);
        LED_COLOR : out std_logic_vector(1 downto 0);

        LED_TAMANO, LINEA_ACTIVA, LED_RECHAZO, ALARMA, LED_LIMITE :
            out std_logic
    );
end entity RF5_Conteo;

architecture estructural of RF5_Conteo is

    component reinicio_seguro is
        port (
            reloj, reinicio_bajo : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, presencia_baja : in std_logic;
            color_selector : in std_logic_vector(1 downto 0);
            tamano_selector : in std_logic;

            nueva_pieza, presencia_activa : out std_logic;
            color : out std_logic_vector(1 downto 0);
            tamano : out std_logic
        );
    end component;

    component tabla_reglas is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            valida : out std_logic
        );
    end component;

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component selector_velocidad is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, boton_bajo : in std_logic;
            nivel_salida : out std_logic_vector(1 downto 0);
            pulso_linea : out std_logic;
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    component control_linea is
        port (
            reloj, reinicio, marcha, bloqueo, pulso_linea_entrada :
                in std_logic;
            pulso_motor, led_linea, en_marcha :
                out std_logic
        );
    end component;

    component supervisor_error is
        generic (
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            reloj, reinicio, marcha, presencia_activa : in std_logic;
            nueva_pieza, pieza_valida : in std_logic;
            alarma : out std_logic
        );
    end component;

    component decodificador_7segmentos is
        port (
            numero : in std_logic_vector(3 downto 0);
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    component conversor_binario_decimal is
        port (
            numero_binario : in std_logic_vector(9 downto 0);
            centenas : out std_logic_vector(3 downto 0);
            decenas : out std_logic_vector(3 downto 0);
            unidades : out std_logic_vector(3 downto 0)
        );
    end component;

    signal reinicio_alto, nueva, presente, tamano, valida :
        std_logic;

    signal color : std_logic_vector(1 downto 0);
    signal total : std_logic_vector(9 downto 0);

    signal digito_centenas, digito_decenas, digito_unidades :
        std_logic_vector(3 downto 0);

    signal contar, error, limite, bloqueo,
           marcha_real, pulso_linea :
        std_logic;

    signal segmentos_velocidad :
        std_logic_vector(6 downto 0);

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,
            color_selector   => SELECTOR_COLOR,
            tamano_selector  => SELECTOR_TAMANO,
            nueva_pieza      => nueva,
            presencia_activa => presente,
            color            => color,
            tamano           => tamano
        );

    U_REGLAS : tabla_reglas
        port map (
            color  => color,
            tamano => tamano,
            ruta   => open,
            valida => valida
        );

    limite <= '1' when unsigned(total) >= 999 else '0';
    bloqueo <= error or limite;

    -- El conteo no depende de los pulsos de velocidad
    contar <= nueva and valida and marcha_real;

    U_TOTAL : contador_ascendente
        generic map (
            ANCHO_BITS => 10
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => contar,
            CUENTA    => total
        );

    U_VELOCIDAD : selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO       => CICLOS_FILTRO
        )
        port map (
            reloj        => RELOJ,
            reinicio     => reinicio_alto,
            boton_bajo   => CAMBIO_VELOCIDAD,
            nivel_salida => open,
            pulso_linea  => pulso_linea,
            segmentos    => segmentos_velocidad
        );

    U_LINEA : control_linea
        port map (
            reloj              => RELOJ,
            reinicio           => reinicio_alto,
            marcha             => LINEA_MARCHA,
            bloqueo            => bloqueo,
            pulso_linea_entrada => pulso_linea,
            pulso_motor        => open,
            led_linea          => LINEA_ACTIVA,
            en_marcha          => marcha_real
        );

    U_ERRORES : supervisor_error
        generic map (
            CICLOS_ATASCO => CICLOS_ATASCO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            marcha           => marcha_real,
            presencia_activa => presente,
            nueva_pieza      => nueva,
            pieza_valida     => valida,
            alarma           => error
        );

    -- El total se presenta en decimal: centenas, decenas y unidades
    U_CONVERSOR_DECIMAL : conversor_binario_decimal
        port map (
            numero_binario => total,
            centenas => digito_centenas,
            decenas => digito_decenas,
            unidades => digito_unidades
        );

    U_TOTAL0 : decodificador_7segmentos
        port map (
            numero    => digito_unidades,
            segmentos => VISOR_TOTAL
        );

    U_TOTAL1 : decodificador_7segmentos
        port map (
            numero    => digito_decenas,
            segmentos => VISOR_TOTAL_MEDIO
        );

    U_TOTAL2 : decodificador_7segmentos
        port map (
            numero    => digito_centenas,
            segmentos => VISOR_TOTAL_ALTO
        );

    VISOR_VELOCIDAD <= segmentos_velocidad
        when marcha_real = '1' else "0111111";

    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            LED_RECHAZO <= '0';

        elsif rising_edge(RELOJ) then
            if nueva = '1' then
                LED_RECHAZO <= not valida;
            end if;
        end if;
    end process;

    LED_COLOR <= color;
    LED_TAMANO <= tamano;
    ALARMA <= error;
    LED_LIMITE <= limite;

end architecture estructural;
```

## SystemAlfa/RF5_Conteo/RF5_Placa.vhd - CONSERVADO

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity RF5_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW     : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end entity RF5_Placa;

architecture estructural of RF5_Placa is

    component RF5_Conteo is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000;
            CICLOS_ATASCO       : positive := 250000000
        );
        port (
            RELOJ         : in std_logic;
            REINICIO_BAJO : in std_logic;
            PRESENCIA     : in std_logic;

            SELECTOR_COLOR : in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO    : in std_logic;
            CAMBIO_VELOCIDAD   : in std_logic;
            LINEA_MARCHA       : in std_logic;

            VISOR_TOTAL       : out std_logic_vector(6 downto 0);
            VISOR_TOTAL_MEDIO : out std_logic_vector(6 downto 0);
            VISOR_TOTAL_ALTO  : out std_logic_vector(6 downto 0);

            VISOR_VELOCIDAD :
                out std_logic_vector(6 downto 0);

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO   : out std_logic;
            LINEA_ACTIVA : out std_logic;
            LED_RECHAZO  : out std_logic;
            ALARMA       : out std_logic;
            LED_LIMITE   : out std_logic
        );
    end component;

    signal visor_total :
        std_logic_vector(6 downto 0);

    signal visor_total_medio :
        std_logic_vector(6 downto 0);

    signal visor_total_alto :
        std_logic_vector(6 downto 0);

    signal visor_velocidad :
        std_logic_vector(6 downto 0);

    signal led_color :
        std_logic_vector(1 downto 0);

    signal led_tamano   : std_logic;
    signal linea_activa : std_logic;
    signal led_rechazo  : std_logic;
    signal alarma       : std_logic;
    signal limite       : std_logic;

begin

    U_RF5 : RF5_Conteo
        port map (
            RELOJ         => CLOCK_50,
            REINICIO_BAJO => BUTTON(1),
            PRESENCIA     => BUTTON(0),

            SELECTOR_COLOR  => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),

            CAMBIO_VELOCIDAD => BUTTON(2),
            LINEA_MARCHA     => SW(3),

            VISOR_TOTAL       => visor_total,
            VISOR_TOTAL_MEDIO => visor_total_medio,
            VISOR_TOTAL_ALTO  => visor_total_alto,

            VISOR_VELOCIDAD => visor_velocidad,

            LED_COLOR => led_color,

            LED_TAMANO   => led_tamano,
            LINEA_ACTIVA => linea_activa,
            LED_RECHAZO  => led_rechazo,
            ALARMA       => alarma,
            LED_LIMITE   => limite
        );

    LEDG(1 downto 0) <= led_color;

    LEDG(2) <= led_tamano;
    LEDG(3) <= linea_activa;
    LEDG(4) <= led_rechazo;

    LEDG(7 downto 5) <= (others => '0');

    LEDG(8) <= alarma;
    LEDG(9) <= limite;

    HEX0 <= visor_total;
    HEX1 <= visor_velocidad;
    HEX2 <= visor_total_medio;
    HEX3 <= visor_total_alto;

end architecture estructural;
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
