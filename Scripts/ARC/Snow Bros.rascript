// Snow Bros.: Nick & Tom | The Winter Bobble
// #ID = 12236

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

function build_score(addr)
{
	return (
		 low4(addr+2) +
		high4(addr+2) * 10 +
		 low4(addr+3) * 100 +
		high4(addr+3) * 1000 +
		 low4(addr+0) * 10000 +
		high4(addr+0) * 100000 +
		 low4(addr+1) * 1000000 +
		high4(addr+1) * 10000000
	)
}

// --- MEMORY -------------------------------------------------------------------

// $0194: Credits [8 bit]
function credits() => byte(0x000194)

// $01BE: Dip Switch 1 [8 bit]
//        bit0 | region (0 = US, 1 = EU)
//        bit1 | invert screen (0 = normal, 1 = inverted)
//        bit2 | test mode (0 = off, 1 = on)
//        bit3 | attract mode sound (0 = on, 1 = off)
//        bit4 + bit5 | coin A (00 = 1 coin, 01 = 2 coin, 10 = 3 coin, 11 = 4 coin)
//        bit6 + bit7 | coin B (00 = 1 coin, 01 = 2 coin, 10 = 3 coin, 11 = 4 coin)
// $01C0: Dip Switch 2 [8 bit]
//        bit0 + bit1 | difficulty (00 = B, 01 = A, 10 = C, 11 = D)
//        bit2 + bit3 | extend (00 = 100k, 01 = 200k, 10 = 100k+200k, 11 = no extend)
//        bit4 + bit5 | starting lives (00 = 3, 01 = 1, 10 = 4, 11 = 2)
//        bit6 | invulnerability (0 = normal game, 1 = "no-death, stop mode")
//        bit7 | continues allowed (0 = yes, 1 = no)
DIP_SWITCH_1 = 0x0001BE
DIP_SWITCH_2 = 0x0001C0

function region() => bit0(DIP_SWITCH_1)
function difficulty() => byte(DIP_SWITCH_2) & 0x03
function god_mode() => bit6(DIP_SWITCH_2)
function extend_points() => byte(DIP_SWITCH_2) & 0x0C
function starting_lives() => byte(DIP_SWITCH_2) & 0x30

DIFF_EASY = 1
DIFF_NORMAL = 0
DIFF_HARD = 2
DIFF_VHARD = 3

EXTEND_100K = 0x00
EXTEND_200K = 0x04
EXTEND_BOTH = 0x08
EXTEND_NONE = 0x0C

LIVES_3 = 0x00
LIVES_1 = 0x10
LIVES_4 = 0x20
LIVES_2 = 0x30

// $01CA: High Score - 00XX0000 [8 bit] (BCD)
// $01CB: High Score - XX000000 [8 bit] (BCD)
// $01CC: High Score - 000000XX [8 bit] (BCD)
// $01CD: High Score - 0000XX00 [8 bit] (BCD)
function high_score() => build_score(0x0001CA)

// $01CE: 1st Place Score - 00XX0000 [8 bit] (BCD)
// $01CF: 1st Place Score - XX000000 [8 bit] (BCD)
// $01D0: 1st Place Score - 000000XX [8 bit] (BCD)
// $01D1: 1st Place Score - 0000XX00 [8 bit] (BCD)
// $01D2: 2nd Place Score - 00XX0000 [8 bit] (BCD)
// $01D3: 2nd Place Score - XX000000 [8 bit] (BCD)
// $01D4: 2nd Place Score - 000000XX [8 bit] (BCD)
// $01D5: 2nd Place Score - 0000XX00 [8 bit] (BCD)
// $01D6: 3rd Place Score - 00XX0000 [8 bit] (BCD)
// $01D7: 3rd Place Score - XX000000 [8 bit] (BCD)
// $01D8: 3rd Place Score - 000000XX [8 bit] (BCD)
// $01D9: 3rd Place Score - 0000XX00 [8 bit] (BCD)
// $01DA: 4th Place Score - 00XX0000 [8 bit] (BCD)
// $01DB: 4th Place Score - XX000000 [8 bit] (BCD)
// $01DC: 4th Place Score - 000000XX [8 bit] (BCD)
// $01DD: 4th Place Score - 0000XX00 [8 bit] (BCD)
// $01DE: 5th Place Score - 00XX0000 [8 bit] (BCD)
// $01DF: 5th Place Score - XX000000 [8 bit] (BCD)
// $01E0: 5th Place Score - 000000XX [8 bit] (BCD)
// $01E1: 5th Place Score - 0000XX00 [8 bit] (BCD)
SCOREBOARD = array_map(range(0,4), (i) => build_score(0x0001CE + 4 * i))

// $1566: Demo Play [8 bit]
//        1 = Attract mode
//        0 = Playing game
function demo_play() => byte(0x001566)

// $1572: Floor ID [8 bit]
function floor_id() => byte(0x001572) + 1

// $1574: Enemies Remaining [8 bit]
function enemies_remaining() => byte(0x001574)

// $1576: Items Remaining [8 bit]
function items_remaining() => byte(0x001576)

// $1580: P1 Score - 00XX0000 [8 bit] (BCD)
// $1581: P1 Score - XX000000 [8 bit] (BCD)
// $1582: P1 Score - 000000XX [8 bit] (BCD)
// $1583: P1 Score - 0000XX00 [8 bit] (BCD)
function p1_score() => build_score(0x001580)

// $1590: P1 Lives [8 bit]
//        03 = 2 extra lives (the starting amount)
//        00 = Game Over
function p1_lives() => byte(0x001590)

// $1596: P2 Score - 00XX0000 [8 bit] (BCD)
// $1597: P2 Score - XX000000 [8 bit] (BCD)
// $1598: P2 Score - 000000XX [8 bit] (BCD)
// $1599: P2 Score - 0000XX00 [8 bit] (BCD)
function p2_score() => build_score(0x001596)

// $15A6: P2 Lives [8 bit]
//        03 = 2 extra lives (the starting amount)
//        00 = Game Over
function p2_lives() => byte(0x0015A6)

// $15A9: Power-Ups [8 bit]
//        bit4 | blue - shot size
//        bit5 | yellow - shot range
//        bit6 | red - running speed
//        bit7 | green - temporary floating invincibility
P1_POWERUPS = 0x0015A9

function p1_power_blu() => bit4(P1_POWERUPS)
function p1_power_yel() => bit5(P1_POWERUPS)
function p1_power_red() => bit6(P1_POWERUPS)
function p1_power_grn() => bit7(P1_POWERUPS)

// $15AB: P1's SNOW Letters [8 bit]
// $15AA: P2's SNOW Letters [8 bit]
//        
//        bit0 | S
//        bit1 | N
//        bit2 | O
//        bit3 | W
//        bit7 | complete, awarding extra life
P1_SNOW = 0x0015AB
P2_SNOW = 0x0015AA

function p1_snow_count() => bitcount(P1_SNOW) - bit7(P1_SNOW)
function p2_snow_count() => bitcount(P2_SNOW) - bit7(P2_SNOW)

// $15AC: P1 Input [8 bit]
// $15AE: P2 Input [8 bit]
//        
//        bit0 | up
//        bit1 | down
//        bit2 | left
//        bit3 | right
//        bit4 | fire
//        bit5 | jump
function p1_input() => byte(0x0015AC)
function p2_input() => byte(0x0015AE)

// $15B8: P1 X Position [16 bit]
// $15BA: P1 Y Position [16 bit]
function p1_x_position() => word(0x0015B8)
function p1_y_position() => word(0x0015BA)

// $15F8: P2 X Position [16 bit]
// $15FA: P2 Y Position [16 bit]
function p2_x_position() => word(0x0015F8)
function p2_y_position() => word(0x0015FA)

// $1630: Enemy Array [8 x 64 bytes]
//        First slot is Pumpkin Head in all non-boss stages
//        
//        +0x02 | Color Palette [8 bit]
//        +0x08 | X Position
//        +0x0A | Y Position [16 bit]
//        +0x0C | Graphics offset X [16 bit]
//        +0x0E | Graphics offset Y [16 bit]
ENEMY_ARRAY = 0x001630

function enemy_gfx_y(i) => word(ENEMY_ARRAY + i*64 + 0x0E)

// $165C: Snowballs Rolled [8 bit]
//        counts per round, resets to 0
//        this value is located in a strange place lol
function snowballs_rolled() => byte(0x00165C)

// $18CA: Boss HP 1 [16 bit]
//        F10 (Mogera) boss starts with 2560
//        F20 (Gamackichi) boss starts with 1792
//        F30 (To-Chan and Ka-Chan) boss (right) starts with 768
//        F40 (Big Nose) boss (right) starts with 1566
//        F50 (Rock Bubbles) boss (right) starts with 2560
//        dead = -1 (0xFFFF), can take additional damage
// $190A: Boss HP 2 [16 bit]
//        F30 boss (left) starts with 768
//        F40 boss (left) starts with 1566
//        F50 boss (left) starts with 2560
//        dead = -1 (0xFFFF), can take additional damage
function boss1_hp() => word(0x0018CA)
function boss2_hp() => word(0x00190A)

// $18CC: Timer [16 bit]
//        Used for boss fights (frames remaining)
//        Used for continuing (seconds remaining)
function timer1() => word(0x0018CC)
function timer2() => word(0x00190C)

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// p1 score should be 0 during the demo, so if it is not it's going through the RAM clearing
// briefly before the demo actually starts, everything zeroes temporarily, including high score
function boot_sequence() => (demo_play() != 0 && byte(0x001580) != 0) || (high_score() == 0)

// p2 is playing if p2 is ever given a position on stage when attract mode is off
function p2_active() => demo_play() == 0 && (p2_x_position() != 0 || p2_y_position() != 0)
function p2_playing() => once(p2_active() && never(demo_play() == 1))

function boss_dead(x) => x > 0xF000 // negative value

// required dip switch settings
function correct_settings() => (
	difficulty() != DIFF_EASY && // normal or harder
	god_mode() != 1 && 
	extend_points() != EXTEND_BOTH && // every other option is worse than default
	starting_lives() != LIVES_4 // default life count is fine, or lower if you're nasty
)

// game starts
function start_game() => prev(demo_play()) == 1 && demo_play() == 0 && floor_id() == 1

// game un-starts
function win_the_game() => floor_id() == 50 && boss_dead(boss1_hp()) && boss_dead(boss2_hp())

// cheating!
//function check_cheating() => disable_when(!correct_settings(), until=(demo_play() == 1))
function check_cheating() => (
	disable_when(difficulty() == DIFF_EASY,      until=(demo_play() == 1)) &&
	disable_when(god_mode() == 1,                until=(demo_play() == 1)) &&
	disable_when(extend_points() == EXTEND_BOTH, until=(demo_play() == 1)) &&
	disable_when(starting_lives() == LIVES_4,    until=(demo_play() == 1)) &&
	disable_when(p2_active(),                    until=(demo_play() == 1))
)

// check if we are currently in a 1CC run
function is_1cc() => (
	// checkpoint hit at the start of the game
	once(start_game()) &&

	// reset if the credit count goes down
	never(credits() < prev(credits())) &&

	// reset if either player runs out of lives
	never(p1_lives() < prev(p1_lives()) && p1_lives() == 0) &&
	never(p2_lives() < prev(p2_lives()) && p2_lives() == 0) &&

	// reset if back to the demo
	never(demo_play() == 1)
)

function credit_count() => measured(tally(0, 
	once(start_game()),
	(p1_lives() < prev(p1_lives()) && p1_lives() == 0),
	(p2_lives() < prev(p2_lives()) && p2_lives() == 0)
)) && never(demo_play() == 1)

// --- MAIN DATA -------------------------------------------------------------------

// Gamackichi returns to the bottom of the stage in 30 seconds
BOSS2_CYCLE1_END = 5280

// the first platform in the birds arena is at 0x1d00, and flipping from a snowball only puts the player at or above that point for 4f
BOSS3_LOWEST_PLATFORM = 0x1D00
BOSS3_PAUSELOCK_FRAMES = 6

// max allowed snowballs in the big nose fight
BOSS4_MAX_SNOWBALLS = 15

// this is a y value slightly higher than max jump height to check for being bubbled
BOSS5_BUBBLE_Y = 0x2880

STAGES = [
	{
		"progression_title": "Welcome to Snowland",

		"boss_title": "Ogre Battle",
		"boss_name": "Mogera",
		"boss_health": [boss1_hp(),],
		"boss_maxhp": 2560,

		"challenge_title": "What Are We Fighting For?",
		"challenge_desc": "Clear Floor 10 without damaging Mogera and without dying",
		"challenge_pts": 3,

		"challenge_start": timer1() == 7080,
		"challenge_reset": never(p1_lives() < prev(p1_lives())) && never(boss1_hp() < prev(boss1_hp()) && timer1() > 0),
		"challenge_trigger": prev(timer1()) == 1 && timer1() == 0 && p1_lives() > 0
	},
	{
		"progression_title": "Topsy Turvy",

		"boss_title": "Ask Not For Whom the Frog Croaks",
		"boss_name": "Gamackichi",
		"boss_health": [boss1_hp(),],
		"boss_maxhp": 1792,

		"challenge_title": "He Croaks For Thee",
		"challenge_desc": "Defeat Gamackichi before he returns to the bottom of the stage",
		"challenge_pts": 10,

		"challenge_start": timer1() == 7080,
		"challenge_reset": never(timer1() < BOSS2_CYCLE1_END),
		"challenge_trigger": boss_dead(boss1_hp())
	},
	{
		"progression_title": "Frozen Factory",

		"boss_title": "Leaving the Nest",
		"boss_name": "To-Chan and Ka-Chan",
		"boss_health": [boss1_hp(), boss2_hp()],
		"boss_maxhp": 768,

		"challenge_title": "Grounded in Reality",
		"challenge_desc": "Defeat To-Chan and Ka-Chan without ever leaving the floor",
		"challenge_pts": 5,

		"challenge_start": timer2() > 6900 && p1_y_position() <= 0x0e00,
		"challenge_reset": (
			never(p1_y_position() > BOSS3_LOWEST_PLATFORM)
		//	never(repeated(BOSS3_PAUSELOCK_FRAMES, // this checks if the player climbed onto a platform
		//		p1_y_position() >= BOSS3_LOWEST_PLATFORM && never(p1_y_position() < BOSS3_LOWEST_PLATFORM)
		//	))
		),
		"challenge_trigger": boss_dead(boss1_hp()) && boss_dead(boss2_hp())
	},
	{
		"progression_title": "Hotda Castle",

		"boss_title": "Rhinophobia",
		"boss_name": "the Big Nose Golems",
		"boss_health": [boss1_hp(), boss2_hp()],
		"boss_maxhp": 1566,

		"challenge_title": "I'm Just Getting Warmed Up",
		"challenge_desc": format("Defeat the Big Nose Golems pushing no more than {0} snowballs", BOSS4_MAX_SNOWBALLS),
		"challenge_pts": 10,

		"challenge_start": timer2() == 21240,
		"challenge_reset": never(tally_of(range(1,3), BOSS4_MAX_SNOWBALLS+1, (x) => snowballs_rolled() >= prev(snowballs_rolled()) + x)),
		"challenge_trigger": boss_dead(boss1_hp()) && boss_dead(boss2_hp())
	},
	{
		"progression_title": "",

		"boss_title": "Two Princesses for Me",
		"boss_name": "the Rock Bubbles",
		"boss_health": [boss1_hp(), boss2_hp()],
		"boss_maxhp": 2560,

		"challenge_title": "I Don't Mean to Get Carried Away",
		"challenge_desc": "Defeat the Rock Bubbles without ever getting lifted by a bubble",
		"challenge_pts": 0, // 10,

		"challenge_start": (prev(floor_id()) == 49 || prev(p1_lives()) == 0) && p1_lives() > 0 && floor_id() == 50,
		"challenge_reset": never(p1_y_position() > BOSS5_BUBBLE_Y),
		"challenge_trigger": boss_dead(boss1_hp()) && boss_dead(boss2_hp())
	},
]

POINTS_THRESHOLDS = [
	{"p":  100000, "d":   "100,000", "title": "How Do You Build a Snowman?", "value": 3},
	{"p":  500000, "d":   "500,000", "title": "Studying Snowman Engineering", "value": 10},
	{"p": 1250000, "d": "1,250,000", "title": "A Good Snowman Is Hard To Build", "value": 25},
]

// --- RICH PRESENCE -------------------------------------------------------------------

BossLookup = {
	10: "vs. 👹 Mogera | ",
	20: "vs. 🐸 Gamackichi | ",
	30: "vs. 🐦 To-Chan and 🐦 Ka-Chan | ",
	40: "vs. 👃 Big Nose 👃 | ",
	50: "vs. 🗿 Rock Bubbles 🗿 | ",
}

rp_floor = rich_presence_value("_Number", floor_id(), "VALUE")
rp_boss = rich_presence_lookup("BossInfo", floor_id(), BossLookup, fallback="")
rp_1cc_coin = rich_presence_lookup("_1CC", credit_count(), {1: " 🪙"}, fallback="")
rp_credits = rich_presence_value("_Number", credit_count(), "VALUE")

rp_lives_p1 = rich_presence_value("_Number", p1_lives(), "VALUE")
rp_score_p1 = rich_presence_value("_Score", p1_score(), "SCORE")

rp_pspace_p1 = rich_presence_lookup("pSpace", byte(P1_POWERUPS), {0: ""}, fallback=" ")
rp_powerR_p1 = rich_presence_lookup("PowerR", p1_power_red(), {1: "🟥"}, fallback="")
rp_powerB_p1 = rich_presence_lookup("PowerB", p1_power_blu(), {1: "🟦"}, fallback="")
rp_powerY_p1 = rich_presence_lookup("PowerY", p1_power_yel(), {1: "🟨"}, fallback="")
rp_powerG_p1 = rich_presence_lookup("PowerG", p1_power_grn(), {1: "🟩"}, fallback="")

rich_presence_conditional_display(demo_play() == 1 || boot_sequence(),
	"☃️ Nick & Tom ☃️ are getting ready to rescue Princesses Puripuri and Puchipuchi"
)

rich_presence_conditional_display(p2_playing(),
	"⚠️ Achievements disabled for two player mode"
)

rich_presence_conditional_display(!correct_settings(),
	"⚠️ Achievements disabled for incorrect dip switches"
)

rich_presence_display(
	"{2}Floor {1} | ☃️ {3}{5}{6}{7}{8}{9} | 💯 {4}{0}",
	rp_1cc_coin, rp_floor, rp_boss,
	rp_lives_p1, rp_score_p1, rp_pspace_p1, rp_powerR_p1, rp_powerB_p1, rp_powerY_p1, rp_powerG_p1
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

for s in range(0, length(STAGES)-1)
{
	stage = STAGES[s]
	floor = (s+1) * 10
	
	achievement(
		title=stage["boss_title"],
		description=format("Defeat {0} on Floor {1}", stage["boss_name"], floor),
		type=if_else(s == 4, "win_condition", ""),
		points=if_else(s == 4, 25, 5),
		trigger=(
			// in game, correct settings
			check_cheating() && demo_play() == 0 &&

			// correct floor and boss died 
			floor_id() == floor && trigger_when(all_of(stage["boss_health"], boss_dead))
		)
	)

	if (stage["challenge_pts"] > 0)
		achievement(
			title=stage["challenge_title"],
			description=stage["challenge_desc"],
			points=stage["challenge_pts"],
			trigger=(
				// in game, correct settings
				check_cheating() && demo_play() == 0 &&

				// checkpoint on start of fight
				once(floor_id() == floor && stage["challenge_start"]) &&

				// reset if leaving the stage
				never(prev(floor_id()) != floor) &&

				// reset and trigger conditions
				stage["challenge_reset"] && trigger_when(stage["challenge_trigger"])
			)
		)

	if (s < length(STAGES)-1)
		achievement(
			title=stage["progression_title"],
			description=format("Complete Stage {0}", s+1),
			type="progression",
			points=5,
			trigger=(
				// in game, correct settings
				check_cheating() && demo_play() == 0 &&

				// transition between levels
				prev(floor_id()) == floor && floor_id() == floor + 1
			)
		)
}

achievement(
	title="Unmeltable",
	description="Complete the game with only one credit",
	points=50,
	trigger=(
		// correct settings
		check_cheating() &&

		// checkpoint hit on starting the game
		once(start_game() && never(demo_play() == 1)) &&

		// reset if either player runs out of lives
		never(p1_lives() < prev(p1_lives()) && p1_lives() == 0) &&
		never(p2_lives() < prev(p2_lives()) && p2_lives() == 0) &&

		// trigger when the boss of the final floor dies
		trigger_when(win_the_game())
	)
)

achievement(
	title="Don't Fear the Reaper",
	description="Complete any floor after Pumpkin Head has spawned",
	points=2,
	trigger=(
		// in game, correct settings
		check_cheating() && demo_play() == 0 &&

		// Pumpkin Head has spawned on this level
		once(enemy_gfx_y(0) == 0x800) &&

		// reset if Pumpkin Head left because the player died
		never(p1_lives() < prev(p1_lives())) &&
		never(p2_lives() < prev(p2_lives())) &&

		// trigger if the level is completed
		floor_id() > prev(floor_id())
	)
)

achievement(
	title="Juiced Up!",
	description="Fully power up with red, blue, and yellow potions",
	points=10,
	trigger=(
		// correct settings
		check_cheating() &&

		// previously fewer powerups active
		prev(p1_power_blu() + p1_power_yel() + p1_power_red()) < 3 &&

		// count the number of potions collected (in-game check is a MeasuredIf)
		measured(p1_power_blu() + p1_power_yel() + p1_power_red() == 3, when=demo_play() == 0)
	)
)

achievement(
	title="Hulk Smash!",
	description="Defeat 3 enemies under the effect of a single green potion",
	points=10,
	trigger=(
		// in game, correct settings
		check_cheating() && demo_play() == 0 &&

		// reset if the powerup wears off
		never(p1_power_grn() == 0) &&

		// count the number of enemies who die
		measured(tally_of(range(1,3), 3, (x) => prev(enemies_remaining()) - enemies_remaining() >= x))
	)
)

achievement(
	title="Let Me Spell It Out for You",
	description="Spell SNOW and earn an extra life",
	points=10,
	trigger=(
		// in game, correct settings
		check_cheating() && demo_play() == 0 &&

		// count SNOW letters and check if a life is being awarded
		measured(p1_snow_count() == 4) && bit7(P1_SNOW) == 1
	)
)

achievement(
	title="A Snowball's Chance In Hell",
	description="Clear all enemies on screen with a single snowball",
	points=5,
	trigger=(
		// in game, correct settings
		check_cheating() && demo_play() == 0 &&

		// check that the level was completed and only one snowball was pushed
		prev(enemies_remaining()) > 0 && enemies_remaining() == 0 && snowballs_rolled() == 1 &&

		// pauselock if a green potion is used this round
		disable_when(p1_power_grn() == 1,
			until=prev(floor_id()) != floor_id() || demo_play() == 1 || p1_lives() == 0) &&

		// pauselock if this is a boss floor
		disable_when(boss1_hp() + boss2_hp() != 0,
			until=prev(floor_id()) != floor_id() || demo_play() == 1 || p1_lives() == 0)
	)
)

for x in POINTS_THRESHOLDS
{
	achievement(
		title=x["title"],
		description=format("Earn {0} points", x["d"]),
		points=x["value"],
		trigger=(
			// in game, correct settings
			check_cheating() && demo_play() == 0 &&

			// earned da points
			prev(p1_score()) < x["p"] && p1_score() >= x["p"]
		)
	)
}

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Snow Rollin'",
	description="Beat the game rolling as few snowballs possible",

	start=start_game(),
	cancel=!correct_settings() || demo_play() == 1,
	submit=win_the_game(),

	value=measured(tally_of(range(1,3), 0, (x) => snowballs_rolled() >= prev(snowballs_rolled()) + x)),
	format="VALUE",
	lower_is_better=true
)

leaderboard(
	title="How To Build a Snowman",
	description="Earn the highest score possible",

	start=p1_score() > 0 && ((prev(p1_lives()) > 0 && p1_lives() == 0) || win_the_game()),
	cancel=!correct_settings(),
	submit=always_true(),

	value=p1_score(),
	format="VALUE",
	lower_is_better=false
)
