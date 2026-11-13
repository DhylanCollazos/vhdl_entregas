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
