
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"00",x"00",x"00",x"60"),
     1 => (x"18",x"30",x"60",x"40"),
     2 => (x"01",x"03",x"06",x"0c"),
     3 => (x"59",x"7f",x"3e",x"00"),
     4 => (x"00",x"3e",x"7f",x"4d"),
     5 => (x"7f",x"06",x"04",x"00"),
     6 => (x"00",x"00",x"00",x"7f"),
     7 => (x"71",x"63",x"42",x"00"),
     8 => (x"00",x"46",x"4f",x"59"),
     9 => (x"49",x"63",x"22",x"00"),
    10 => (x"00",x"36",x"7f",x"49"),
    11 => (x"13",x"16",x"1c",x"18"),
    12 => (x"00",x"10",x"7f",x"7f"),
    13 => (x"45",x"67",x"27",x"00"),
    14 => (x"00",x"39",x"7d",x"45"),
    15 => (x"4b",x"7e",x"3c",x"00"),
    16 => (x"00",x"30",x"79",x"49"),
    17 => (x"71",x"01",x"01",x"00"),
    18 => (x"00",x"07",x"0f",x"79"),
    19 => (x"49",x"7f",x"36",x"00"),
    20 => (x"00",x"36",x"7f",x"49"),
    21 => (x"49",x"4f",x"06",x"00"),
    22 => (x"00",x"1e",x"3f",x"69"),
    23 => (x"66",x"00",x"00",x"00"),
    24 => (x"00",x"00",x"00",x"66"),
    25 => (x"e6",x"80",x"00",x"00"),
    26 => (x"00",x"00",x"00",x"66"),
    27 => (x"14",x"08",x"08",x"00"),
    28 => (x"00",x"22",x"22",x"14"),
    29 => (x"14",x"14",x"14",x"00"),
    30 => (x"00",x"14",x"14",x"14"),
    31 => (x"14",x"22",x"22",x"00"),
    32 => (x"00",x"08",x"08",x"14"),
    33 => (x"51",x"03",x"02",x"00"),
    34 => (x"00",x"06",x"0f",x"59"),
    35 => (x"5d",x"41",x"7f",x"3e"),
    36 => (x"00",x"1e",x"1f",x"55"),
    37 => (x"09",x"7f",x"7e",x"00"),
    38 => (x"00",x"7e",x"7f",x"09"),
    39 => (x"49",x"7f",x"7f",x"00"),
    40 => (x"00",x"36",x"7f",x"49"),
    41 => (x"63",x"3e",x"1c",x"00"),
    42 => (x"00",x"41",x"41",x"41"),
    43 => (x"41",x"7f",x"7f",x"00"),
    44 => (x"00",x"1c",x"3e",x"63"),
    45 => (x"49",x"7f",x"7f",x"00"),
    46 => (x"00",x"41",x"41",x"49"),
    47 => (x"09",x"7f",x"7f",x"00"),
    48 => (x"00",x"01",x"01",x"09"),
    49 => (x"41",x"7f",x"3e",x"00"),
    50 => (x"00",x"7a",x"7b",x"49"),
    51 => (x"08",x"7f",x"7f",x"00"),
    52 => (x"00",x"7f",x"7f",x"08"),
    53 => (x"7f",x"41",x"00",x"00"),
    54 => (x"00",x"00",x"41",x"7f"),
    55 => (x"40",x"60",x"20",x"00"),
    56 => (x"00",x"3f",x"7f",x"40"),
    57 => (x"1c",x"08",x"7f",x"7f"),
    58 => (x"00",x"41",x"63",x"36"),
    59 => (x"40",x"7f",x"7f",x"00"),
    60 => (x"00",x"40",x"40",x"40"),
    61 => (x"0c",x"06",x"7f",x"7f"),
    62 => (x"00",x"7f",x"7f",x"06"),
    63 => (x"0c",x"06",x"7f",x"7f"),
    64 => (x"00",x"7f",x"7f",x"18"),
    65 => (x"41",x"7f",x"3e",x"00"),
    66 => (x"00",x"3e",x"7f",x"41"),
    67 => (x"09",x"7f",x"7f",x"00"),
    68 => (x"00",x"06",x"0f",x"09"),
    69 => (x"61",x"41",x"7f",x"3e"),
    70 => (x"00",x"40",x"7e",x"7f"),
    71 => (x"09",x"7f",x"7f",x"00"),
    72 => (x"00",x"66",x"7f",x"19"),
    73 => (x"4d",x"6f",x"26",x"00"),
    74 => (x"00",x"32",x"7b",x"59"),
    75 => (x"7f",x"01",x"01",x"00"),
    76 => (x"00",x"01",x"01",x"7f"),
    77 => (x"40",x"7f",x"3f",x"00"),
    78 => (x"00",x"3f",x"7f",x"40"),
    79 => (x"70",x"3f",x"0f",x"00"),
    80 => (x"00",x"0f",x"3f",x"70"),
    81 => (x"18",x"30",x"7f",x"7f"),
    82 => (x"00",x"7f",x"7f",x"30"),
    83 => (x"1c",x"36",x"63",x"41"),
    84 => (x"41",x"63",x"36",x"1c"),
    85 => (x"7c",x"06",x"03",x"01"),
    86 => (x"01",x"03",x"06",x"7c"),
    87 => (x"4d",x"59",x"71",x"61"),
    88 => (x"00",x"41",x"43",x"47"),
    89 => (x"7f",x"7f",x"00",x"00"),
    90 => (x"00",x"00",x"41",x"41"),
    91 => (x"0c",x"06",x"03",x"01"),
    92 => (x"40",x"60",x"30",x"18"),
    93 => (x"41",x"41",x"00",x"00"),
    94 => (x"00",x"00",x"7f",x"7f"),
    95 => (x"03",x"06",x"0c",x"08"),
    96 => (x"00",x"08",x"0c",x"06"),
    97 => (x"80",x"80",x"80",x"80"),
    98 => (x"00",x"80",x"80",x"80"),
    99 => (x"03",x"00",x"00",x"00"),
   100 => (x"00",x"00",x"04",x"07"),
   101 => (x"54",x"74",x"20",x"00"),
   102 => (x"00",x"78",x"7c",x"54"),
   103 => (x"44",x"7f",x"7f",x"00"),
   104 => (x"00",x"38",x"7c",x"44"),
   105 => (x"44",x"7c",x"38",x"00"),
   106 => (x"00",x"00",x"44",x"44"),
   107 => (x"44",x"7c",x"38",x"00"),
   108 => (x"00",x"7f",x"7f",x"44"),
   109 => (x"54",x"7c",x"38",x"00"),
   110 => (x"00",x"18",x"5c",x"54"),
   111 => (x"7f",x"7e",x"04",x"00"),
   112 => (x"00",x"00",x"05",x"05"),
   113 => (x"a4",x"bc",x"18",x"00"),
   114 => (x"00",x"7c",x"fc",x"a4"),
   115 => (x"04",x"7f",x"7f",x"00"),
   116 => (x"00",x"78",x"7c",x"04"),
   117 => (x"3d",x"00",x"00",x"00"),
   118 => (x"00",x"00",x"40",x"7d"),
   119 => (x"80",x"80",x"80",x"00"),
   120 => (x"00",x"00",x"7d",x"fd"),
   121 => (x"10",x"7f",x"7f",x"00"),
   122 => (x"00",x"44",x"6c",x"38"),
   123 => (x"3f",x"00",x"00",x"00"),
   124 => (x"00",x"00",x"40",x"7f"),
   125 => (x"18",x"0c",x"7c",x"7c"),
   126 => (x"00",x"78",x"7c",x"0c"),
   127 => (x"04",x"7c",x"7c",x"00"),
   128 => (x"00",x"78",x"7c",x"04"),
   129 => (x"44",x"7c",x"38",x"00"),
   130 => (x"00",x"38",x"7c",x"44"),
   131 => (x"24",x"fc",x"fc",x"00"),
   132 => (x"00",x"18",x"3c",x"24"),
   133 => (x"24",x"3c",x"18",x"00"),
   134 => (x"00",x"fc",x"fc",x"24"),
   135 => (x"04",x"7c",x"7c",x"00"),
   136 => (x"00",x"08",x"0c",x"04"),
   137 => (x"54",x"5c",x"48",x"00"),
   138 => (x"00",x"20",x"74",x"54"),
   139 => (x"7f",x"3f",x"04",x"00"),
   140 => (x"00",x"00",x"44",x"44"),
   141 => (x"40",x"7c",x"3c",x"00"),
   142 => (x"00",x"7c",x"7c",x"40"),
   143 => (x"60",x"3c",x"1c",x"00"),
   144 => (x"00",x"1c",x"3c",x"60"),
   145 => (x"30",x"60",x"7c",x"3c"),
   146 => (x"00",x"3c",x"7c",x"60"),
   147 => (x"10",x"38",x"6c",x"44"),
   148 => (x"00",x"44",x"6c",x"38"),
   149 => (x"e0",x"bc",x"1c",x"00"),
   150 => (x"00",x"1c",x"3c",x"60"),
   151 => (x"74",x"64",x"44",x"00"),
   152 => (x"00",x"44",x"4c",x"5c"),
   153 => (x"3e",x"08",x"08",x"00"),
   154 => (x"00",x"41",x"41",x"77"),
   155 => (x"7f",x"00",x"00",x"00"),
   156 => (x"00",x"00",x"00",x"7f"),
   157 => (x"77",x"41",x"41",x"00"),
   158 => (x"00",x"08",x"08",x"3e"),
   159 => (x"03",x"01",x"01",x"02"),
   160 => (x"00",x"01",x"02",x"02"),
   161 => (x"7f",x"7f",x"7f",x"7f"),
   162 => (x"00",x"7f",x"7f",x"7f"),
   163 => (x"1c",x"1c",x"08",x"08"),
   164 => (x"7f",x"7f",x"3e",x"3e"),
   165 => (x"3e",x"3e",x"7f",x"7f"),
   166 => (x"08",x"08",x"1c",x"1c"),
   167 => (x"7c",x"18",x"10",x"00"),
   168 => (x"00",x"10",x"18",x"7c"),
   169 => (x"7c",x"30",x"10",x"00"),
   170 => (x"00",x"10",x"30",x"7c"),
   171 => (x"60",x"60",x"30",x"10"),
   172 => (x"00",x"06",x"1e",x"78"),
   173 => (x"18",x"3c",x"66",x"42"),
   174 => (x"00",x"42",x"66",x"3c"),
   175 => (x"c2",x"6a",x"38",x"78"),
   176 => (x"00",x"38",x"6c",x"c6"),
   177 => (x"60",x"00",x"00",x"60"),
   178 => (x"00",x"60",x"00",x"00"),
   179 => (x"5c",x"5b",x"5e",x"0e"),
   180 => (x"86",x"fc",x"0e",x"5d"),
   181 => (x"f7",x"c2",x"7e",x"71"),
   182 => (x"c0",x"4c",x"bf",x"c4"),
   183 => (x"c4",x"1e",x"c0",x"4b"),
   184 => (x"c4",x"02",x"ab",x"66"),
   185 => (x"c2",x"4d",x"c0",x"87"),
   186 => (x"75",x"4d",x"c1",x"87"),
   187 => (x"ee",x"49",x"73",x"1e"),
   188 => (x"86",x"c8",x"87",x"e3"),
   189 => (x"ef",x"49",x"e0",x"c0"),
   190 => (x"a4",x"c4",x"87",x"ec"),
   191 => (x"f0",x"49",x"6a",x"4a"),
   192 => (x"ca",x"f1",x"87",x"f3"),
   193 => (x"c1",x"84",x"cc",x"87"),
   194 => (x"ab",x"b7",x"c8",x"83"),
   195 => (x"87",x"cd",x"ff",x"04"),
   196 => (x"4d",x"26",x"8e",x"fc"),
   197 => (x"4b",x"26",x"4c",x"26"),
   198 => (x"71",x"1e",x"4f",x"26"),
   199 => (x"c8",x"f7",x"c2",x"4a"),
   200 => (x"c8",x"f7",x"c2",x"5a"),
   201 => (x"49",x"78",x"c7",x"48"),
   202 => (x"26",x"87",x"e1",x"fe"),
   203 => (x"1e",x"73",x"1e",x"4f"),
   204 => (x"0b",x"fc",x"4b",x"71"),
   205 => (x"4a",x"73",x"0b",x"7b"),
   206 => (x"c0",x"c1",x"9a",x"c1"),
   207 => (x"c7",x"ed",x"49",x"a2"),
   208 => (x"c0",x"da",x"c2",x"87"),
   209 => (x"26",x"4b",x"26",x"5b"),
   210 => (x"4a",x"71",x"1e",x"4f"),
   211 => (x"72",x"1e",x"66",x"c4"),
   212 => (x"87",x"fb",x"eb",x"49"),
   213 => (x"4f",x"26",x"8e",x"fc"),
   214 => (x"48",x"d4",x"ff",x"1e"),
   215 => (x"ff",x"78",x"ff",x"c3"),
   216 => (x"e1",x"c0",x"48",x"d0"),
   217 => (x"48",x"d4",x"ff",x"78"),
   218 => (x"48",x"71",x"78",x"c1"),
   219 => (x"d4",x"ff",x"30",x"c4"),
   220 => (x"d0",x"ff",x"78",x"08"),
   221 => (x"78",x"e0",x"c0",x"48"),
   222 => (x"5e",x"0e",x"4f",x"26"),
   223 => (x"0e",x"5d",x"5c",x"5b"),
   224 => (x"7e",x"c0",x"86",x"f4"),
   225 => (x"ec",x"48",x"a6",x"c8"),
   226 => (x"80",x"fc",x"78",x"bf"),
   227 => (x"bf",x"c4",x"f7",x"c2"),
   228 => (x"cc",x"f7",x"c2",x"78"),
   229 => (x"bf",x"e8",x"4c",x"bf"),
   230 => (x"fc",x"d9",x"c2",x"4d"),
   231 => (x"f9",x"e3",x"49",x"bf"),
   232 => (x"e8",x"49",x"c7",x"87"),
   233 => (x"49",x"70",x"87",x"f1"),
   234 => (x"d0",x"05",x"99",x"c2"),
   235 => (x"f4",x"d9",x"c2",x"87"),
   236 => (x"b9",x"ff",x"49",x"bf"),
   237 => (x"c1",x"99",x"66",x"c8"),
   238 => (x"f9",x"c1",x"02",x"99"),
   239 => (x"49",x"e8",x"cf",x"87"),
   240 => (x"70",x"87",x"fd",x"ca"),
   241 => (x"e8",x"49",x"c7",x"4b"),
   242 => (x"98",x"70",x"87",x"cd"),
   243 => (x"c8",x"87",x"c9",x"05"),
   244 => (x"99",x"c1",x"49",x"66"),
   245 => (x"87",x"fe",x"c0",x"02"),
   246 => (x"ec",x"48",x"a6",x"c8"),
   247 => (x"f9",x"e2",x"78",x"bf"),
   248 => (x"ca",x"49",x"73",x"87"),
   249 => (x"98",x"70",x"87",x"e6"),
   250 => (x"c2",x"87",x"d7",x"02"),
   251 => (x"49",x"bf",x"f0",x"d9"),
   252 => (x"d9",x"c2",x"b9",x"c1"),
   253 => (x"fd",x"71",x"59",x"f4"),
   254 => (x"e8",x"cf",x"87",x"de"),
   255 => (x"87",x"c0",x"ca",x"49"),
   256 => (x"49",x"c7",x"4b",x"70"),
   257 => (x"70",x"87",x"d0",x"e7"),
   258 => (x"cb",x"ff",x"05",x"98"),
   259 => (x"49",x"66",x"c8",x"87"),
   260 => (x"ff",x"05",x"99",x"c1"),
   261 => (x"d9",x"c2",x"87",x"c2"),
   262 => (x"c1",x"4a",x"bf",x"fc"),
   263 => (x"c0",x"da",x"c2",x"ba"),
   264 => (x"7a",x"0a",x"fc",x"5a"),
   265 => (x"c1",x"9a",x"c1",x"0a"),
   266 => (x"e9",x"49",x"a2",x"c0"),
   267 => (x"da",x"c1",x"87",x"da"),
   268 => (x"87",x"e3",x"e6",x"49"),
   269 => (x"d9",x"c2",x"7e",x"c1"),
   270 => (x"66",x"c8",x"48",x"f4"),
   271 => (x"fc",x"d9",x"c2",x"78"),
   272 => (x"e9",x"c0",x"05",x"bf"),
   273 => (x"c3",x"49",x"75",x"87"),
   274 => (x"1e",x"71",x"99",x"ff"),
   275 => (x"f8",x"fb",x"49",x"c0"),
   276 => (x"c8",x"49",x"75",x"87"),
   277 => (x"1e",x"71",x"29",x"b7"),
   278 => (x"ec",x"fb",x"49",x"c1"),
   279 => (x"c3",x"86",x"c8",x"87"),
   280 => (x"f2",x"e5",x"49",x"fd"),
   281 => (x"49",x"fa",x"c3",x"87"),
   282 => (x"c7",x"87",x"ec",x"e5"),
   283 => (x"49",x"75",x"87",x"f4"),
   284 => (x"c8",x"99",x"ff",x"c3"),
   285 => (x"b5",x"71",x"2d",x"b7"),
   286 => (x"c0",x"02",x"9d",x"75"),
   287 => (x"a6",x"c8",x"87",x"e4"),
   288 => (x"bf",x"c8",x"ff",x"48"),
   289 => (x"49",x"66",x"c8",x"78"),
   290 => (x"bf",x"f8",x"d9",x"c2"),
   291 => (x"a9",x"e0",x"c2",x"89"),
   292 => (x"87",x"c4",x"c0",x"03"),
   293 => (x"87",x"d0",x"4d",x"c0"),
   294 => (x"48",x"f8",x"d9",x"c2"),
   295 => (x"c0",x"78",x"66",x"c8"),
   296 => (x"d9",x"c2",x"87",x"c6"),
   297 => (x"78",x"c0",x"48",x"f8"),
   298 => (x"99",x"c8",x"49",x"75"),
   299 => (x"87",x"ce",x"c0",x"05"),
   300 => (x"e4",x"49",x"f5",x"c3"),
   301 => (x"49",x"70",x"87",x"e1"),
   302 => (x"c0",x"02",x"99",x"c2"),
   303 => (x"f7",x"c2",x"87",x"e7"),
   304 => (x"c0",x"02",x"bf",x"c8"),
   305 => (x"c1",x"48",x"87",x"ca"),
   306 => (x"cc",x"f7",x"c2",x"88"),
   307 => (x"87",x"d3",x"c0",x"58"),
   308 => (x"c1",x"48",x"66",x"c4"),
   309 => (x"7e",x"70",x"80",x"e0"),
   310 => (x"c0",x"02",x"bf",x"6e"),
   311 => (x"ff",x"4b",x"87",x"c5"),
   312 => (x"c1",x"0f",x"73",x"49"),
   313 => (x"c4",x"49",x"75",x"7e"),
   314 => (x"ce",x"c0",x"05",x"99"),
   315 => (x"49",x"f2",x"c3",x"87"),
   316 => (x"70",x"87",x"e4",x"e3"),
   317 => (x"02",x"99",x"c2",x"49"),
   318 => (x"c2",x"87",x"ea",x"c0"),
   319 => (x"7e",x"bf",x"c8",x"f7"),
   320 => (x"a8",x"b7",x"c7",x"48"),
   321 => (x"87",x"cb",x"c0",x"03"),
   322 => (x"80",x"c1",x"48",x"6e"),
   323 => (x"58",x"cc",x"f7",x"c2"),
   324 => (x"c4",x"87",x"d0",x"c0"),
   325 => (x"e0",x"c1",x"4a",x"66"),
   326 => (x"c0",x"02",x"6a",x"82"),
   327 => (x"fe",x"4b",x"87",x"c5"),
   328 => (x"c1",x"0f",x"73",x"49"),
   329 => (x"49",x"fd",x"c3",x"7e"),
   330 => (x"70",x"87",x"ec",x"e2"),
   331 => (x"02",x"99",x"c2",x"49"),
   332 => (x"c2",x"87",x"e6",x"c0"),
   333 => (x"02",x"bf",x"c8",x"f7"),
   334 => (x"c2",x"87",x"c9",x"c0"),
   335 => (x"c0",x"48",x"c8",x"f7"),
   336 => (x"87",x"d3",x"c0",x"78"),
   337 => (x"c1",x"48",x"66",x"c4"),
   338 => (x"7e",x"70",x"80",x"e0"),
   339 => (x"c0",x"02",x"bf",x"6e"),
   340 => (x"fd",x"4b",x"87",x"c5"),
   341 => (x"c1",x"0f",x"73",x"49"),
   342 => (x"49",x"fa",x"c3",x"7e"),
   343 => (x"70",x"87",x"f8",x"e1"),
   344 => (x"02",x"99",x"c2",x"49"),
   345 => (x"c2",x"87",x"ea",x"c0"),
   346 => (x"48",x"bf",x"c8",x"f7"),
   347 => (x"03",x"a8",x"b7",x"c7"),
   348 => (x"c2",x"87",x"c9",x"c0"),
   349 => (x"c7",x"48",x"c8",x"f7"),
   350 => (x"87",x"d3",x"c0",x"78"),
   351 => (x"c1",x"48",x"66",x"c4"),
   352 => (x"7e",x"70",x"80",x"e0"),
   353 => (x"c0",x"02",x"bf",x"6e"),
   354 => (x"fc",x"4b",x"87",x"c5"),
   355 => (x"c1",x"0f",x"73",x"49"),
   356 => (x"c3",x"48",x"75",x"7e"),
   357 => (x"a6",x"cc",x"98",x"f0"),
   358 => (x"05",x"98",x"70",x"58"),
   359 => (x"c1",x"87",x"ce",x"c0"),
   360 => (x"f2",x"e0",x"49",x"da"),
   361 => (x"c2",x"49",x"70",x"87"),
   362 => (x"f9",x"c1",x"02",x"99"),
   363 => (x"49",x"e8",x"cf",x"87"),
   364 => (x"70",x"87",x"cd",x"c3"),
   365 => (x"c0",x"f7",x"c2",x"4b"),
   366 => (x"c2",x"50",x"c0",x"48"),
   367 => (x"bf",x"97",x"c0",x"f7"),
   368 => (x"87",x"d2",x"c1",x"05"),
   369 => (x"c0",x"05",x"66",x"c8"),
   370 => (x"da",x"c1",x"87",x"cc"),
   371 => (x"87",x"c7",x"e0",x"49"),
   372 => (x"c1",x"02",x"98",x"70"),
   373 => (x"bf",x"e8",x"87",x"c0"),
   374 => (x"ff",x"c3",x"49",x"4d"),
   375 => (x"2d",x"b7",x"c8",x"99"),
   376 => (x"da",x"ff",x"b5",x"71"),
   377 => (x"49",x"73",x"87",x"f4"),
   378 => (x"70",x"87",x"e1",x"c2"),
   379 => (x"c6",x"c0",x"02",x"98"),
   380 => (x"c0",x"f7",x"c2",x"87"),
   381 => (x"c2",x"50",x"c1",x"48"),
   382 => (x"bf",x"97",x"c0",x"f7"),
   383 => (x"87",x"d6",x"c0",x"05"),
   384 => (x"f0",x"c3",x"49",x"75"),
   385 => (x"cd",x"ff",x"05",x"99"),
   386 => (x"49",x"da",x"c1",x"87"),
   387 => (x"87",x"c7",x"df",x"ff"),
   388 => (x"ff",x"05",x"98",x"70"),
   389 => (x"f7",x"c2",x"87",x"c0"),
   390 => (x"4b",x"49",x"bf",x"c8"),
   391 => (x"66",x"c4",x"93",x"cc"),
   392 => (x"71",x"4b",x"6b",x"83"),
   393 => (x"9c",x"74",x"0f",x"73"),
   394 => (x"87",x"e9",x"c0",x"02"),
   395 => (x"e4",x"c0",x"02",x"6c"),
   396 => (x"ff",x"49",x"6c",x"87"),
   397 => (x"70",x"87",x"e0",x"de"),
   398 => (x"02",x"99",x"c1",x"49"),
   399 => (x"c4",x"87",x"cb",x"c0"),
   400 => (x"f7",x"c2",x"4b",x"a4"),
   401 => (x"6b",x"49",x"bf",x"c8"),
   402 => (x"84",x"c8",x"0f",x"4b"),
   403 => (x"87",x"c5",x"c0",x"02"),
   404 => (x"dc",x"ff",x"05",x"6c"),
   405 => (x"c0",x"02",x"6e",x"87"),
   406 => (x"f7",x"c2",x"87",x"c8"),
   407 => (x"f1",x"49",x"bf",x"c8"),
   408 => (x"8e",x"f4",x"87",x"ea"),
   409 => (x"4c",x"26",x"4d",x"26"),
   410 => (x"4f",x"26",x"4b",x"26"),
   411 => (x"00",x"00",x"00",x"10"),
   412 => (x"00",x"00",x"00",x"00"),
   413 => (x"00",x"00",x"00",x"00"),
   414 => (x"00",x"00",x"00",x"00"),
   415 => (x"00",x"00",x"00",x"00"),
   416 => (x"ff",x"4a",x"71",x"1e"),
   417 => (x"72",x"49",x"bf",x"c8"),
   418 => (x"4f",x"26",x"48",x"a1"),
   419 => (x"bf",x"c8",x"ff",x"1e"),
   420 => (x"c0",x"c0",x"fe",x"89"),
   421 => (x"a9",x"c0",x"c0",x"c0"),
   422 => (x"c0",x"87",x"c4",x"01"),
   423 => (x"c1",x"87",x"c2",x"4a"),
   424 => (x"26",x"48",x"72",x"4a"),
   425 => (x"5b",x"5e",x"0e",x"4f"),
   426 => (x"71",x"0e",x"5d",x"5c"),
   427 => (x"4c",x"d4",x"ff",x"4b"),
   428 => (x"c0",x"48",x"66",x"d0"),
   429 => (x"ff",x"49",x"d6",x"78"),
   430 => (x"c3",x"87",x"d9",x"dd"),
   431 => (x"49",x"6c",x"7c",x"ff"),
   432 => (x"71",x"99",x"ff",x"c3"),
   433 => (x"f0",x"c3",x"49",x"4d"),
   434 => (x"a9",x"e0",x"c1",x"99"),
   435 => (x"c3",x"87",x"cb",x"05"),
   436 => (x"48",x"6c",x"7c",x"ff"),
   437 => (x"66",x"d0",x"98",x"c3"),
   438 => (x"ff",x"c3",x"78",x"08"),
   439 => (x"49",x"4a",x"6c",x"7c"),
   440 => (x"ff",x"c3",x"31",x"c8"),
   441 => (x"71",x"4a",x"6c",x"7c"),
   442 => (x"c8",x"49",x"72",x"b2"),
   443 => (x"7c",x"ff",x"c3",x"31"),
   444 => (x"b2",x"71",x"4a",x"6c"),
   445 => (x"31",x"c8",x"49",x"72"),
   446 => (x"6c",x"7c",x"ff",x"c3"),
   447 => (x"ff",x"b2",x"71",x"4a"),
   448 => (x"e0",x"c0",x"48",x"d0"),
   449 => (x"02",x"9b",x"73",x"78"),
   450 => (x"7b",x"72",x"87",x"c2"),
   451 => (x"4d",x"26",x"48",x"75"),
   452 => (x"4b",x"26",x"4c",x"26"),
   453 => (x"26",x"1e",x"4f",x"26"),
   454 => (x"5b",x"5e",x"0e",x"4f"),
   455 => (x"86",x"f8",x"0e",x"5c"),
   456 => (x"a6",x"c8",x"1e",x"76"),
   457 => (x"87",x"fd",x"fd",x"49"),
   458 => (x"4b",x"70",x"86",x"c4"),
   459 => (x"a8",x"c4",x"48",x"6e"),
   460 => (x"87",x"fb",x"c2",x"03"),
   461 => (x"f0",x"c3",x"4a",x"73"),
   462 => (x"aa",x"d0",x"c1",x"9a"),
   463 => (x"c1",x"87",x"c7",x"02"),
   464 => (x"c2",x"05",x"aa",x"e0"),
   465 => (x"49",x"73",x"87",x"e9"),
   466 => (x"c3",x"02",x"99",x"c8"),
   467 => (x"87",x"c6",x"ff",x"87"),
   468 => (x"9c",x"c3",x"4c",x"73"),
   469 => (x"c1",x"05",x"ac",x"c2"),
   470 => (x"66",x"c4",x"87",x"c4"),
   471 => (x"71",x"31",x"c9",x"49"),
   472 => (x"4a",x"66",x"c4",x"1e"),
   473 => (x"c2",x"92",x"cc",x"c1"),
   474 => (x"72",x"49",x"d0",x"f7"),
   475 => (x"db",x"cd",x"fe",x"81"),
   476 => (x"ff",x"49",x"d8",x"87"),
   477 => (x"c8",x"87",x"dd",x"da"),
   478 => (x"e4",x"c2",x"1e",x"c0"),
   479 => (x"e6",x"fd",x"49",x"c8"),
   480 => (x"d0",x"ff",x"87",x"f1"),
   481 => (x"78",x"e0",x"c0",x"48"),
   482 => (x"1e",x"c8",x"e4",x"c2"),
   483 => (x"c1",x"4a",x"66",x"cc"),
   484 => (x"f7",x"c2",x"92",x"cc"),
   485 => (x"81",x"72",x"49",x"d0"),
   486 => (x"87",x"f1",x"cb",x"fe"),
   487 => (x"ac",x"c1",x"86",x"cc"),
   488 => (x"87",x"cb",x"c1",x"05"),
   489 => (x"fd",x"49",x"ee",x"c0"),
   490 => (x"c4",x"87",x"e1",x"e3"),
   491 => (x"31",x"c9",x"49",x"66"),
   492 => (x"66",x"c4",x"1e",x"71"),
   493 => (x"92",x"cc",x"c1",x"4a"),
   494 => (x"49",x"d0",x"f7",x"c2"),
   495 => (x"cc",x"fe",x"81",x"72"),
   496 => (x"e4",x"c2",x"87",x"ca"),
   497 => (x"66",x"c8",x"1e",x"c8"),
   498 => (x"92",x"cc",x"c1",x"4a"),
   499 => (x"49",x"d0",x"f7",x"c2"),
   500 => (x"c9",x"fe",x"81",x"72"),
   501 => (x"49",x"d7",x"87",x"f8"),
   502 => (x"87",x"f8",x"d8",x"ff"),
   503 => (x"c2",x"1e",x"c0",x"c8"),
   504 => (x"fd",x"49",x"c8",x"e4"),
   505 => (x"cc",x"87",x"e9",x"e4"),
   506 => (x"48",x"d0",x"ff",x"86"),
   507 => (x"f8",x"78",x"e0",x"c0"),
   508 => (x"26",x"4c",x"26",x"8e"),
   509 => (x"1e",x"4f",x"26",x"4b"),
   510 => (x"b7",x"c4",x"4a",x"71"),
   511 => (x"87",x"ce",x"03",x"aa"),
   512 => (x"cc",x"c1",x"49",x"72"),
   513 => (x"d0",x"f7",x"c2",x"91"),
   514 => (x"81",x"c8",x"c1",x"81"),
   515 => (x"4f",x"26",x"79",x"c0"),
   516 => (x"5c",x"5b",x"5e",x"0e"),
   517 => (x"86",x"fc",x"0e",x"5d"),
   518 => (x"d4",x"ff",x"4a",x"71"),
   519 => (x"d4",x"4c",x"c0",x"4b"),
   520 => (x"b7",x"c3",x"4d",x"66"),
   521 => (x"c2",x"c2",x"01",x"ad"),
   522 => (x"02",x"9a",x"72",x"87"),
   523 => (x"1e",x"87",x"ec",x"c0"),
   524 => (x"cc",x"c1",x"49",x"75"),
   525 => (x"d0",x"f7",x"c2",x"91"),
   526 => (x"c8",x"80",x"71",x"48"),
   527 => (x"66",x"c4",x"58",x"a6"),
   528 => (x"d3",x"c3",x"fe",x"49"),
   529 => (x"70",x"86",x"c4",x"87"),
   530 => (x"87",x"d4",x"02",x"98"),
   531 => (x"c8",x"c1",x"49",x"6e"),
   532 => (x"6e",x"79",x"c1",x"81"),
   533 => (x"69",x"81",x"c8",x"49"),
   534 => (x"75",x"87",x"c5",x"4c"),
   535 => (x"87",x"d7",x"fe",x"49"),
   536 => (x"c8",x"48",x"d0",x"ff"),
   537 => (x"7b",x"dd",x"78",x"e1"),
   538 => (x"ff",x"c3",x"48",x"74"),
   539 => (x"74",x"7b",x"70",x"98"),
   540 => (x"29",x"b7",x"c8",x"49"),
   541 => (x"ff",x"c3",x"48",x"71"),
   542 => (x"74",x"7b",x"70",x"98"),
   543 => (x"29",x"b7",x"d0",x"49"),
   544 => (x"ff",x"c3",x"48",x"71"),
   545 => (x"74",x"7b",x"70",x"98"),
   546 => (x"28",x"b7",x"d8",x"48"),
   547 => (x"7b",x"c0",x"7b",x"70"),
   548 => (x"7b",x"7b",x"7b",x"7b"),
   549 => (x"7b",x"7b",x"7b",x"7b"),
   550 => (x"ff",x"7b",x"7b",x"7b"),
   551 => (x"e0",x"c0",x"48",x"d0"),
   552 => (x"dc",x"1e",x"75",x"78"),
   553 => (x"d0",x"d6",x"ff",x"49"),
   554 => (x"fc",x"86",x"c4",x"87"),
   555 => (x"26",x"4d",x"26",x"8e"),
   556 => (x"26",x"4b",x"26",x"4c"),
   557 => (x"e3",x"c2",x"1e",x"4f"),
   558 => (x"fe",x"49",x"bf",x"c4"),
   559 => (x"c0",x"87",x"c3",x"dd"),
   560 => (x"00",x"4f",x"26",x"48"),
   561 => (x"00",x"00",x"28",x"c8"),
   562 => (x"43",x"45",x"50",x"53"),
   563 => (x"4d",x"55",x"52",x"54"),
   564 => (x"00",x"4d",x"4f",x"52"),
   565 => (x"00",x"00",x"1b",x"bf"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

