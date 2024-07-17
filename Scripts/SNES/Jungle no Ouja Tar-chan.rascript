// Jungle no Ouja Tar-chan: Sekai Manyuu Dai Kakutou no Maki
// #ID = 23001

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

function ptr(addr) => word(addr)

// --- MEMORY -------------------------------------------------------------------

// $0702: Camera X [16 bit]
// $070A: Camera Y [16 bit]
function camera_x() => word(0x000702)
function camera_y() => word(0x00070A)

// $074F: Game Difficulty [8 bit]
//        0 = Normal (default)
//        1 = Easy
//        2 = Hard
function game_difficulty() => byte(0x00074F)

DIFF_EASY = 1
DIFF_NORMAL = 0
DIFF_HARD = 2

// $0750: Current Stage [8 bit]
//        0 = Protect the Jungle | Tank
//        1 = Rural China | Ouki
//        2 = Las Vegas | Apollonia Mask
//        3 = Vampire Castle | Dan Marceau
//        4 = Cerberus Island | Iron Mask
//        5 = [No Stage] | Enraged Iron Mask
function current_stage() => byte(0x000750)

STAGE_JUNGLE = 0
STAGE_CHINA = 1
STAGE_VEGAS = 2
STAGE_VAMPIRE = 3
STAGE_FACTORY = 4

// $0751: Stage Info [8 bit]
//        bit5 = has died, respawned
//        bit7 = boss stage
META_STAGE_ADDR = 0x000751

function has_respawned() => bit5(META_STAGE_ADDR)
function is_boss() => bit7(META_STAGE_ADDR)

// $0752: Nuts Collected [8 bit]
function nuts_collected() => byte(0x000752)

// $0753: Powerups [8 bit]
//        bit6 = otter
//        bit7 = armadillo
POWERUPS_ADDR = 0x000753

function has_otter() => bit6(POWERUPS_ADDR)
function has_armadillo() => bit7(POWERUPS_ADDR)

// $0754: Player Health [8 bit]
//        20 max, 0 dead
function health() => byte(0x000754)

// $0755: Stage/Round Timer [8 bit]
//        - Level doesn't end at 0, but Tar-Chan can't heal anymore
//        - Ends the boss round and pauses for both to heal
function timer() => byte(0x000755)

// $0756: Boss Round [8 bit]
//        1 is first round, 5 is final round
function boss_round() => byte(0x000756)

// $0757: Enemy Health [8 bit]
//        20 max, 0 dead
function enemy_health() => byte(0x000757)

// $0758: Score [24 bit]
function score() => tbyte(0x000758)

// $075C: Lives Remaining [8 bit]
function lives() => byte(0x00075C)

// $075D: Total Nuts Collected [16 bit]
//        0-200 = no ending
//        201-400 = sunset "bad" ending
//        401+ = sunset "good" ending
function nuts_total() => word(0x00075D)

// $0761: Pointer to Tar-chan [16 bit]
//        
//        +0x05 | Player Pose/State [8 bit]
//        .. 0x01 = stage start
//        .. 0x02 = changing direction, dying
//        .. 0x03 = idle standing
//        .. 0x05 = healing
//        .. 0x07 = idle flexing
//        .. 0x09 = idle dodging
//        .. 0x0D = starting run from idle
//        .. 0x0F = running
//        .. 0x17 = normal punch
//        .. 0x19 = "tarzan punch"
//        .. 0x1B = starting jump
//        .. 0x1D = jumping/launching up
//        .. 0x23 = crouching
//        .. 0x25 = crouching normal punch
//        .. 0x27 = crouching tarzan punch
//        .. 0x2F = standing
//        .. 0x30 = walking off platform
//        .. 0x31 = airborne
//        .. 0x35 = "floating" (tanuki pose, mash jump)
//        .. 0x36 = touching ground from floating
//        .. 0x37 = landing from floating
//        .. 0x38 = touching ground from falling
//        .. 0x39 = landing from falling
//        .. 0x3C = grabbing a wall
//        .. 0x3F = pulling up on a wall
//        .. 0x41 = swinging vine
//        .. 0x46 = touching spikes transition
//        .. 0x47 = armadillo roll
//        .. 0x48 = touching water transition
//        .. 0x49 = otter swimming
//        .. 0x4B = normal air kick
//        .. 0x4D = "tarzan kick"
//        .. 0x4F = normal kick hits (wall, enemy, etc)
//        .. 0x51 = tarzan kick hits
//        .. 0x59 = spikes ouch
//        .. 0x5B = electrocuted
//        .. 0x5D = knocked back
//        .. 0x60 = enter up launch
//        .. 0x61 = up launch
//        .. 0x62 = enter diagonal launch
//        .. 0x63 = diagonal launch
//        .. 0x6F = hentai
//        .. 0x71 = stage complete
//        .. 0x79 = healing complete, full health
//        +0x41 | Player X Position [16 bit]
//        +0x44 | Player Y Position [16 bit]
function player_addr() => ptr(0x000761)

function player_pose() => byte(player_addr() + 0x05)
function player_x() => word(player_addr() + 0x41)
function player_y() => word(player_addr() + 0x44)

POSE_HENTAI = 0x6F
POSE_HEALING = 0x05
POSE_TANUKI = 0x35
POSE_VICTORY = 0x71

// $076D: Pointer to Boss [16 bit]
//        
//        +0x05 | Boss Pose/State [8 bit]
//        .. Boss 4: Dan Marceau
//        .... 0x15 = jumping
//        .... 0x1D = slow spit
//        .... 0x1F = fast spit
function boss_addr() => ptr(0x00076D)

function boss_pose() => byte(boss_addr() + 0x05)
function boss_x() => word(boss_addr() + 0x41)
function boss_y() => word(boss_addr() + 0x44)

DAN_POSE_JUMP = 0x15
DAN_POSE_SPIT = [
	0x1D, // slow
	0x1F, // fast
	0x21, // down
]

// $4074: Pointer to Stage Data [16 bit]
//        +0x3EC | Stage timer with frames [16 bit]
function stage_data_addr() => ptr(0x004074)

function has_stage_ptr() => stage_data_addr() != 0xFFFF
function full_timer() => word(stage_data_addr() + 0x3EC)

function timer_frac() => full_timer() / 256.0

// $40E8: TAR Team Members Defeated [8 bit]
//        in rock-paper-scissors bonus minigame
function tar_team_members_defeated() => byte(0x0040E8)

// $40E9: MAX Team Members Defeated [8 bit]
//        in rock-paper-scissors bonus minigame
function max_team_members_defeated() => byte(0x0040E9)

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function hentai_count(n, when=always_true()) => (
	// measure how many times hentai magazine was collected
	measured(repeated(n, prev(player_pose()) != POSE_HENTAI && player_pose() == POSE_HENTAI), when=when) &&

	// reset if the player dies
	never(lives() < prev(lives())) &&

	// reset if the player changes stages
	never(current_stage() != prev(current_stage()))
)

function boss_fight_start() => is_boss() == 1 && prev(stage_data_addr()) == 0xFFFF && has_stage_ptr()

function win_boss_fight() => (
	// boss is dead
	is_boss() == 1 && enemy_health() == 0 && 

	// pose changed from something else to a victory pose
	prev(player_pose()) != POSE_VICTORY && player_pose() == POSE_VICTORY
)

function win_the_game() => current_stage() == 5 && win_boss_fight()

function in_bonus_game() => (
	// not final stage
	current_stage() < STAGE_FACTORY &&

	// checkpoint hit on boss fight ending
	once(win_boss_fight()) &&

	// state setup for bonus game
	once(max_team_members_defeated() == 0 && tar_team_members_defeated() == 0) &&

	// common sense values
	max_team_members_defeated() <= 5 && tar_team_members_defeated() <= 5 &&

	// clear this flag when the level changes
	never(current_stage() != prev(current_stage()))
)

// --- MAIN DATA -------------------------------------------------------------------

STAGES = [
	{
		"id": STAGE_JUNGLE,
		"name": "Jungle",
		"boss": "a Tank",
		"hentai": 2,
		"time": 70,
		
		"main_title": "Protect the Jungle!", "main_pts": 5,
		"speed_title": "Rollin' Deep in Jungle Japes",

		"boss_title": "Stand Your Ground", "boss_pts": 5,
		"boss_desc": "Defeat the tank in the jungle without moving",
		"boss_trigger": disable_when(prev(player_x()) != player_x() || prev(player_y()) != player_y(), until=boss_fight_start()),
	},
	{
		"id": STAGE_CHINA,
		"name": "China",
		"boss": "Ouki",
		"hentai": -1,
		"time": 60,
		
		"main_title": "A Rival in Rural China", "main_pts": 5,
		"speed_title": "Silk Road Sprinter",

		"boss_title": "Not Even a Scratch", "boss_pts": 10,
		"boss_desc": "Defeat Ouki without taking any damage",
		"boss_trigger": disable_when(health() < prev(health()), until=boss_fight_start()),
	},
	{
		"id": STAGE_VEGAS,
		"name": "Las Vegas",
		"boss": "Apollonia Mask",
		"hentai": 2,
		"time": 60,
		
		"main_title": "High Roller", "main_pts": 5,
		"speed_title": "Running the Tables",

		"boss_title": "Las Vegas Prize Fight", "boss_pts": 5,
		"boss_desc": "Defeat Apollonia Mask in the first round",
		"boss_trigger": (boss_round() == 1),
	},
	{
		"id": STAGE_VAMPIRE,
		"name": "Vampire Castle",
		"boss": "Dan Marceau",
		"hentai": -1,
		"time": 50,
		
		"main_title": "King of the Vampire's Castle", "main_pts": 10,
		"speed_title": "Like a Bat Out of Hell",

		"boss_title": "Say It, Don't Spray It", "boss_pts": 5,
		"boss_desc": "Defeat Dan Marceau without getting hit by his spit attack",
		"boss_trigger": (
			// checkpoint hit for boss fight starting
			once(boss_fight_start()) && never(!has_stage_ptr()) &&
			// clear the checkpoint hit for the boss fight if get spit on
			never(
				// register a hit if Dan spits, clear if he jumps, since jump->kick doesn't count
				once(
					// any spit will count
					any_of(DAN_POSE_SPIT, (x) => boss_pose() == x) &&
					// reset next if on a jump
					never(boss_pose() == DAN_POSE_JUMP)
				) && 
				// health goes down after a spit
				health() < prev(health())
			)
		),
	},
	{
		"id": STAGE_FACTORY,
		"name": "Cerberus Island",
		"boss": "Iron Mask",
		"hentai": 4,
		"time": 20,
		
		"main_title": "The Man Who Could Not Die", "main_pts": 25,
		"speed_title": "Rapid Assembly",

		"boss_title": "A Decisive Battle at Cerberus Island", "boss_pts": 10,
		"boss_desc": "Win either fight against Iron Mask in the first round",
		"boss_trigger": (boss_round() == 1),
	},
]

ENDINGS = [
	{
		"title": "Nut Collector",
		"ending": "sunset ending",
		"points": 10,
		"nuts": 201,
	},
	{
		"title": "Nuts about Nuts",
		"ending": "good sunset ending",
		"points": 25,
		"nuts": 400,
	},
]

// --- RICH PRESENCE -------------------------------------------------------------------

STAGE_LOOKUP = {}
BOSS_LOOKUP = {}

for stage in STAGES
{
	STAGE_LOOKUP[stage["id"]] = stage["name"]
	BOSS_LOOKUP[stage["id"]] = stage["boss"]
}

// final boss refight advances stage counter
STAGE_LOOKUP[5] = STAGE_LOOKUP[STAGE_FACTORY]
BOSS_LOOKUP[5] = "Enraged " + BOSS_LOOKUP[STAGE_FACTORY]

ROUND_LOOKUP = {
	1: " R1",
	2: " R2",
	3: " R3",
	4: " R4",
	5: " R5",
}

DIFF_LOOKUP = {
	DIFF_EASY: "🔰 Easy",
	DIFF_NORMAL: "🦍 Normal",
	DIFF_HARD: "💀 Hard",
}

rp_stage = rich_presence_lookup("Stage", current_stage(), STAGE_LOOKUP, fallback=STAGE_LOOKUP[0])
rp_difficulty = rich_presence_lookup("Difficulty", game_difficulty(), DIFF_LOOKUP, fallback=DIFF_LOOKUP[DIFF_NORMAL])

rp_boss_name = rich_presence_lookup("Boss", current_stage(), BOSS_LOOKUP, fallback="another challenger")
rp_boss_round = rich_presence_lookup("RoundInfo", boss_round(), ROUND_LOOKUP, fallback="")
rp_boss_health = rich_presence_value("_Number", enemy_health() * 5, "VALUE")

rp_powerup_otter = rich_presence_lookup("Otter", has_otter(), {1: " 🦦"}, fallback="")
rp_powerup_dillo = rich_presence_lookup("Armadillo", has_armadillo(), {1: " 🛡️"}, fallback="")

rp_time = rich_presence_value("_Number", timer(), "VALUE")
rp_lives = rich_presence_value("_Number", lives(), "VALUE")
rp_health = rich_presence_value("_Number", health() * 5, "VALUE")
rp_hentai = rich_presence_value("_Number", hentai_count(99), "VALUE")

rp_bonus_tar = rich_presence_value("_Number", tar_team_members_defeated(), "VALUE")
rp_bonus_max = rich_presence_value("_Number", max_team_members_defeated(), "VALUE")

rich_presence_conditional_display(has_stage_ptr() && is_boss() == 0,
    "🚩{0}{4}{5} | 👨{1} 🌰{2}% ⏳{3} | 📖{6} | {7} Difficulty",
	rp_stage,
	rp_lives, rp_health, rp_time,
	rp_powerup_otter, rp_powerup_dillo,
	rp_hentai, rp_difficulty
)

rich_presence_conditional_display(in_bonus_game(),
    "🚩{0} | Bonus Game ✊✋✌️ | TAR {1} - {2} MAX",
	rp_stage, 
	rp_bonus_max, rp_bonus_tar
)

rich_presence_conditional_display(has_stage_ptr() && is_boss() == 1,
    "🚩{0} 👊{5} vs {6} ({7}%) | 👨{1} 🌰{2}% ⏳{3} | {4} Difficulty",
	rp_stage, 
	rp_lives, rp_health, rp_time,
	rp_difficulty,
	rp_boss_round, rp_boss_name, rp_boss_health
)

rich_presence_display(
	"Tar-chan is going on a worldwide fighting tour!"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

ach_id = 448218
for stage in STAGES
{
	id = stage["id"] + if_else(stage["id"]==STAGE_FACTORY, 1, 0)
	achievement(id=ach_id,
		title=stage["main_title"],
		description=format("Complete stage {0} on normal mode or higher", stage["id"]+1),
		type=if_else(stage["id"]==STAGE_FACTORY, "win_condition", "progression"),
		points=stage["main_pts"],
		trigger=game_difficulty() != DIFF_EASY && current_stage() == id && win_boss_fight()
	)
	ach_id = ach_id + 1
}

achievement(id=448223,
	title="The Great Fighting World Tour",
	description="Complete the game on hard mode",
	points=25,
	trigger=game_difficulty() == DIFF_HARD && win_the_game()
)

ach_id = 448224
for stage in STAGES
{
	achievement(id=ach_id,
		title=stage["speed_title"],
		description=format("Complete stage {0} with {1} or more seconds remaining", stage["id"]+1, stage["time"]),
		points=10,
		trigger=(
			// correct stage and not on boss
			current_stage() == stage["id"] && is_boss() == 0 &&
			// enough time remaining when the player is celebrating
			timer() >= stage["time"] && trigger_when(player_pose() == POSE_VICTORY)
		)
	)
	ach_id = ach_id + 1
}

hcount = 0
ach_id = 448229
for stage in STAGES if (stage["hentai"] != -1)
{
	hcount = hcount + 1
	achievement(id=ach_id,
		title=format("Hentai Hunter {0}", ROMAN[hcount]),
		description=format("Collect all the adult magazines in stage {0}", stage["id"]+1),
		points=if_else(stage["hentai"] > 2, 10, 5),
		trigger=hentai_count(stage["hentai"], when=current_stage() == stage["id"] && is_boss() == 0)
	)
	ach_id = ach_id + 1
}

ach_id = 448232
for stage in STAGES
{
	achievement(id=ach_id,
		title=stage["boss_title"],
		description=stage["boss_desc"],
		points=stage["boss_pts"],
		trigger=(
			// correct stage and on the boss
			current_stage() == stage["id"] && is_boss() == 1 &&
			// special context for the boss challenge
			stage["boss_trigger"] &&
			// trigger when the boss dies
			trigger_when(enemy_health() == 0 && player_pose() == POSE_VICTORY)
		)
	)
	ach_id = ach_id + 1
}

achievement(id=448237,
	title="I Read It for the Articles",
	description="Collect an adult magazine",
	points=3,
	trigger=has_stage_ptr() && is_boss() == 0 && health() == 20 && player_pose() == POSE_HENTAI
)

achievement(id=448238,
	title="Gotta Have Thick Skin",
	description="Collect the armadillo powerup",
	points=2,
	trigger=has_stage_ptr() && is_boss() == 0 && prev(has_armadillo()) == 0 && has_armadillo() == 1
)

achievement(id=448239,
	title="Welcome to the Otter Slide",
	description="Collect the otter powerup",
	points=2,
	trigger=has_stage_ptr() && is_boss() == 0 && prev(has_otter()) == 0 && has_otter() == 1
)

achievement(id=448240,
	title="Spread Your \"Wings\"",
	description="Float like a tanuki. Best not to think about it too much.",
	points=1,
	trigger=has_stage_ptr() && player_pose() == POSE_TANUKI
)

achievement(id=448241,
	title="Licking Your Wounds",
	description="Restore your health in a level with patient meditation",
	points=1,
	trigger=has_stage_ptr() && is_boss() == 0 && player_pose() == POSE_HEALING && health() > prev(health())
)

achievement(id=448244,
	title="Janken Pon!",
	description="Earn an extra life in the Rock-Paper-Scissors bonus game",
	points=3,
	trigger=in_bonus_game() && max_team_members_defeated() == 5 && lives() > prev(lives())
)

JUNGLE_NUTS = 90
achievement(id=448242,
	title="No Nut Left Behind",
	description=format("In one life, collect all {0} acorns in stage 1", JUNGLE_NUTS),
	points=5,
	trigger=measured(nuts_collected() >= JUNGLE_NUTS, when=current_stage() == STAGE_JUNGLE && is_boss() == 0)
)

/*
CASTLE_SKIP_X1 = 0x0300
CASTLE_SKIP_X2 = 0x06A0
achievement(
	title="Come Out to the Coast, We'll Get Together, Have a Few Laughs",
	description="Skip ahead in the Vampire Castle by climbing over the top of the stage by the elevators",
	type="missable",
	points=3,
	trigger=(
		// correct stage
		current_stage() == STAGE_VAMPIRE && is_boss() == 0 &&
		// in the correct area for the achievement
		(player_y() == 0 || player_y() > 0xFF00) && (player_x() >= CASTLE_SKIP_X1 && player_x() <= CASTLE_SKIP_X2)
	)
)
*/

ach_id = 449211
for ach in ENDINGS
{
	achievement(id=ach_id,
		title=ach["title"],
		description=format("Collect {0} or more nuts to see the {1}", ach["nuts"], ach["ending"]),
		points=ach["points"],
		trigger=win_the_game() && nuts_total() >= ach["nuts"]
	)
	ach_id = ach_id + 1
}

achievement(id=312607,
	title="[VOID]",
	description="[VOID]",
	points=0,
	trigger=always_false()
)

// --- LEADERBOARDS -------------------------------------------------------------------

lb_id = 108233
leaderboard(id=lb_id,
	title="Highest Score",
	description="Complete the game and earn the highest score possible on any difficulty.",

	start=win_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=score(),
	format="SCORE",
	lower_is_better=false
)

for stage in STAGES
{
	lb_id = lb_id + 1
	leaderboard(id=lb_id,
		title=format("{0} Speedrun", stage["name"]),
		description=format("Reach the end of stage {0} as quickly as possible.", stage["id"]+1),

		start=(current_stage() == stage["id"] && is_boss() == 0 && player_pose() == POSE_VICTORY && full_timer() > 0),
		cancel=always_false(),
		submit=always_true(),

		value=timer_frac() * 1000,
		format="FIXED3",
		lower_is_better=false
	)
}
