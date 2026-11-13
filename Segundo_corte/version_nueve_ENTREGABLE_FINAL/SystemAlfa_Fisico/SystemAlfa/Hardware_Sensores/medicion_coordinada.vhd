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
