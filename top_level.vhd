library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    Port ( clk : in STD_LOGIC;
           dac1 : out STD_LOGIC;
           dac2 : out STD_LOGIC);
end top_level;

architecture Behavioral of top_level is
    signal sample_count : unsigned(5 downto 0) := (others => '0');
    type a_samples is array (0 to 47) of signed(11 downto 0);
    signal samples    : a_samples := (
        to_signed(   66,12), to_signed(  199,12), to_signed(  329,12),
        to_signed(  452,12), to_signed(  568,12), to_signed(  675,12),
        to_signed(  769,12), to_signed(  851,12), to_signed(  918,12),
        to_signed(  969,12), to_signed( 1004,12), to_signed( 1021,12),
        to_signed( 1021,12), to_signed( 1004,12), to_signed(  969,12),
        to_signed(  918,12), to_signed(  851,12), to_signed(  769,12),
        to_signed(  675,12), to_signed(  568,12), to_signed(  452,12),
        to_signed(  329,12), to_signed(  199,12), to_signed(   66,12),
        to_signed(  -67,12), to_signed( -200,12), to_signed( -330,12),
        to_signed( -453,12), to_signed( -569,12), to_signed( -676,12),
        to_signed( -770,12), to_signed( -852,12), to_signed( -919,12),
        to_signed( -970,12), to_signed(-1005,12), to_signed(-1022,12),
        to_signed(-1022,12), to_signed(-1005,12), to_signed( -970,12),
        to_signed( -919,12), to_signed( -852,12), to_signed( -770,12),
        to_signed( -676,12), to_signed( -569,12), to_signed( -453,12),
        to_signed( -330,12), to_signed( -200,12), to_signed(  -67,12));
    signal count       : unsigned(9 downto 0) := (others => '0');
    signal sample      : signed(11 downto 0)  := (others => '0');
   
    signal dac1_out    : std_logic           := '0';
    signal dac1_accum  : signed(15 downto 0) := (others => '0');

    signal dac2_out    : std_logic           := '0';
    signal dac2_accum1 : signed(15 downto 0) := (others => '0');
    signal dac2_accum2 : signed(15 downto 0) := (others => '0');

begin

    dac1 <= dac1_out;
    dac2 <= dac2_out;
   
dac1_proc: process(clk)
    variable new_val : signed(15 downto 0);
    begin
        if rising_edge(clk) then
           if dac1_out = '1' then
              new_val := dac1_accum + sample - 2048;
           else
              new_val := dac1_accum + sample + 2048;
           end if;
           if new_val > 0 then
              dac1_out <= '1';
           else
              dac1_out <= '0';
           end if;
           dac1_accum <= new_val;
       end if;
    end process;

dac2_proc: process(clk)
    variable new_val1 : signed(15 downto 0);
    variable new_val2 : signed(15 downto 0);
    begin
        if rising_edge(clk) then
           if dac2_out = '1' then
              new_val1 := dac2_accum1 + sample - 2048;
           else
              new_val1 := dac2_accum1 + sample + 2048;
           end if;

           if dac2_out = '1' then
              new_val2 := dac2_accum2 + new_val1 - 2048;
           else
              new_val2 := dac2_accum2 + new_val1 + 2048;
           end if;

           if new_val2 > 0 then
              dac2_out <= '1';
           else
              dac2_out <= '0';
           end if;
           dac2_accum1 <= new_val1;
           dac2_accum2 <= new_val2;
       end if;
    end process;

gen_samples: process(clk)
    begin
        if rising_edge(clk) then
            sample <= samples(to_integer(sample_count));
            if count = 999 then
                if sample_count = 47 then
                   sample_count <= (others => '0');
                else
                   sample_count <= sample_count +1;
                end if;
                count <= (others => '0');
            else
                count <= count + 1;
            end if;
         end if;
    end process;

end Behavioral;
