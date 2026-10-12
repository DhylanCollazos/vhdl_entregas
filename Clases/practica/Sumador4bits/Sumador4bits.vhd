library ieee;
use ieee.std_logic_1164.all;

entity Sumador4bits is
    port
    (
        A, B : in bit_vector(3 downto 0);

        cin : in bit;
        operacion : in bit; -- 0: suma; 1: resta

        Display_Unidades : out std_logic_vector(6 downto 0);
        Display_Decenas  : out std_logic_vector(6 downto 0);

        signo : out std_logic -- 1: resultado negativo
    );
end Sumador4bits;

architecture arch_Sumador4bits of Sumador4bits is

    -- Sumador de cuatro bits.
    component fullAdder4bits
        port
        (
            A, B : in bit_vector(3 downto 0);
            Cin  : in bit;

            Sum  : out bit_vector(3 downto 0);
            Cout : out bit
        );
    end component;

    -- Restador con signo y magnitud.
    component restador
        port
        (
            x, y : in std_logic_vector(3 downto 0);

            sign     : out std_logic;
            magnitud : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Conversor a decenas y unidades.
    component binarioBCD
        port
        (
            suma : in bit_vector(3 downto 0);
            cout : in bit;

            unidades : out std_logic_vector(3 downto 0);
            decenas  : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Decodificador de siete segmentos.
    component decodificador
        port
        (
            c : in std_logic_vector(3 downto 0);
            s : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Salidas del sumador.
    signal suma : bit_vector(3 downto 0);
    signal cout : bit;

    -- Entradas y salidas del restador.
    signal A_slv, B_slv : std_logic_vector(3 downto 0);
    signal magnitud_resta : std_logic_vector(3 downto 0);
    signal signo_resta : std_logic;

    -- Resultado seleccionado para el conversor.
    signal entrada_bcd : bit_vector(3 downto 0);
    signal carry_bcd : bit;

    -- Digitos para los decodificadores.
    signal unidades : std_logic_vector(3 downto 0);
    signal decenas  : std_logic_vector(3 downto 0);

begin

    -- SUMA: A + B + cin.
    SUMADOR : fullAdder4bits
        port map(A, B, cin, suma, cout);

    -- Adaptamos las entradas al tipo utilizado por el restador.
    A_slv <= to_stdlogicvector(A);
    B_slv <= to_stdlogicvector(B);

    -- RESTA: A - B. cin no modifica esta operacion.
    RESTADOR_4 : restador
        port map(A_slv, B_slv, signo_resta, magnitud_resta);

    -- Seleccionamos suma o magnitud de la resta.
    entrada_bcd <= suma when operacion = '0'
                   else to_bitvector(magnitud_resta);

    -- El acarreo de salida solo se utiliza en la suma.
    carry_bcd <= cout when operacion = '0'
                 else '0';

    -- El signo se indica por separado.
    signo <= signo_resta when operacion = '1'
             else '0';

    -- Convertimos el resultado seleccionado.
    BCD : binarioBCD
        port map(entrada_bcd, carry_bcd, unidades, decenas);

    -- Display de unidades.
    DEC_UNIDADES : decodificador
        port map(unidades, Display_Unidades);

    -- Display de decenas.
    DEC_DECENAS : decodificador
        port map(decenas, Display_Decenas);

end arch_Sumador4bits;