library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    Port ( clk : in STD_LOGIC;
           sw  : in STD_LOGIC_VECTOR(3 downto 0);
           dac : out STD_LOGIC);
end top_level;

architecture Behavioral of top_level is
    component first_order_dac is
    port (
        i_clk : in std_logic;
        i_res : in std_logic;
        i_func : in std_logic_vector(15 downto 0);
        o_DAC : out std_logic);
    end component;

    component second_order_dac is
        port (
        i_clk : in std_logic;
        i_res : in std_logic;
        i_func : in std_logic_vector(15 downto 0);
        o_DAC : out std_logic);
    end component;

    signal sample_count : unsigned(5 downto 0) := (others => '0');
    type a_samples is array (0 to 49) of signed(15 downto 0);
    signal samples    : a_samples := (
        to_signed(  1029,16), to_signed(  3070,16), to_signed(  5062,16), to_signed(  6975,16), to_signed(  8778,16),
        to_signed( 10443,16), to_signed( 11943,16), to_signed( 13254,16), to_signed( 14357,16), to_signed( 15233,16),
        to_signed( 15869,16), to_signed( 16254,16), to_signed( 16384,16), to_signed( 16254,16), to_signed( 15869,16),
        to_signed( 15233,16), to_signed( 14357,16), to_signed( 13254,16), to_signed( 11943,16), to_signed( 10443,16),
        to_signed(  8778,16), to_signed(  6975,16), to_signed(  5062,16), to_signed(  3070,16), to_signed(  1028,16),
        to_signed( -1029,16), to_signed( -3071,16), to_signed( -5063,16), to_signed( -6976,16), to_signed( -8779,16),
        to_signed(-10444,16), to_signed(-11944,16), to_signed(-13255,16), to_signed(-14358,16), to_signed(-15234,16),
        to_signed(-15870,16), to_signed(-16255,16), to_signed(-16384,16), to_signed(-16255,16), to_signed(-15870,16),
        to_signed(-15234,16), to_signed(-14358,16), to_signed(-13255,16), to_signed(-11944,16), to_signed(-10444,16),
        to_signed( -8779,16), to_signed( -6976,16), to_signed( -5063,16), to_signed( -3071,16), to_signed( -1029,16));
    signal count       : unsigned(9 downto 0) := (others => '0');
    signal sample      : signed(15 downto 0)  := (others => '0');
    
    signal dac1_out    : std_logic           := '0';
    signal dac1_accum  : signed(19 downto 0) := (others => '0');

    signal dac2_out    : std_logic           := '0';
    signal dac2_accum1 : signed(19 downto 0) := (others => '0');
    signal dac2_accum2 : signed(19 downto 0) := (others => '0');


    signal dac1_verilog_out  : std_logic           := '0';
    signal dac2_verilog_out  : std_logic           := '0';
    signal mask              : unsigned(2 downto 0);
begin

   with sw(3 downto 2) select mask <= "000" when "00",
                                      "001" when "01",
                                      "011" when "11",
                                      "111" when others;
process(clk)
    begin
        if rising_edge(clk) then
            case sw(1 downto 0) is
                when "00"   => dac <= dac1_out;
                when "01"   => dac <= dac2_out;
                when "10"   => dac <= dac1_verilog_out;
                when others => dac <= dac2_verilog_out;
            end case;
        end if;
    end process;   


dac1_proc: process(clk)
    variable new_val : signed(19 downto 0);
    begin
        if rising_edge(clk) and (count(2 downto 0) and mask) = "000" then
           if dac1_out = '1' then 
              new_val := dac1_accum + signed(sample) - 32768;
           else
              new_val := dac1_accum + signed(sample) + 32768;
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
    variable new_val1 : signed(19 downto 0);
    variable new_val2 : signed(19 downto 0);
    begin
        if rising_edge(clk) and (count(2 downto 0) and mask) = "000" then
           if dac2_out = '1' then 
              new_val1 := dac2_accum1 + sample - 32768;
           else
              new_val1 := dac2_accum1 + sample + 32768;
           end if;

           if dac2_out = '1' then 
              new_val2 := dac2_accum2 + new_val1 - 32768;
           else
              new_val2 := dac2_accum2 + new_val1 + 32768;
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
                if sample_count = 49 then
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

v1: first_order_dac port map (
        i_clk  => clk,
        i_res  => '1',
        i_func => std_logic_vector(sample),
        o_DAC  => dac1_verilog_out);

v2: second_order_dac port map (
        i_clk  => clk,
        i_res  => '1',
        i_func => std_logic_vector(sample),
        o_DAC  => dac2_verilog_out);

end Behavioral;
