// Blomby Car
// #ID = 29732

// HELPERS
NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

// $2403: Game State [8 bit]
//        0x0c = high score name entry
//        0x12 = boot screen
//        0x16 = press 1P or 2P button
//        0x18, 0x19 = bon voiage
//        0x1b = stage map
//        0x1c = stage loaded
//        0x1d = countdown about to begin
//        0x1e = "attention"
//        0x1f = countdown in progress
//        0x20 = race in progress
//        0x26 = time limit exceeded
//        0x27 = race over
//        0x23, 0x24 = finish line
//        0x2b = game over, continue?
//        0x3e = all transitions (fade out)
//        0x58, 0x59 = winner
//        0x5a = you are the champion
//        0x5d = smile for a photo
//        0x5e = the end
//        0xe4, 0xe5, 0xe6, 0xe7 = BLOMBY CAR title
//        0xe9 = get ready for this infernal raid
//        0xea = your goal is to reach DAKAR from PARIS
//        0xeb = demo play
//        0xfe = high score
function game_state() => byte(0x002403)
function game_state_group() => high4(0x002403)

STATE_BONVOIAGE = 0x18
STATE_MAP = 0x1B
STATE_COUNTDOWN = 0x1F
STATE_RACE = 0x20
STATE_RACE_OVERTIME = 0x26
STATE_FINISH = 0x24
STATE_RACE_OVER = 0x27
STATE_CONTINUE = 0x2B
STATE_CHAMPION = 0x5A
STATE_DEMO = 0xEB
STATE_HIGH_SCORE = 0xFE

GROUP_SETUP = 0x1
GROUP_RACE = 0x2
GROUP_WINNER = 0x5
GROUP_TITLE = 0xE

EMOJI_STATE = {
	STATE_DEMO: "📽",
	0x1E: "🚥",
	0x1F: "🚥",
	0x1D: "🚥",
	STATE_RACE: "🚩",
	STATE_FINISH: "🏁",
	STATE_RACE_OVERTIME: "❗🚩",
	STATE_RACE_OVER: "❌🚩",
}

// $2CC6: Current Speed [8 bit]
//        max = 0x16 (22), 200km/h
//        mult by 9.0909...
function speed() => byte(0x002CC6)
function speed_real() => speed() * 9.091

// $2CF2: Current Loaded Track [8 bit]
//        works in demo play as well
function loaded_track() => byte(0x002CF2)

// $2EDF: Credits [8 bit]
function credits() => byte(0x002EDF)

// $2FA1: Crash Indicator [8 bit]
//        0 = Driving
//        3 = Crashing
function crash() => byte(0x002FA1)
function is_crashing() => crash() == 3

CRASH_STATE = {
	0: "",
	3: "🔧",
}

// $3010: Clock Time (in tenths) [16 bit]
function clock() => word(0x003010)

// $301E: Score [32 bit]
function score() => dword(0x00301E)

// $30A3: Current Track [8 bit]
//        0 = Madrid
//        1 = Gibraltar
//        2 = Tombouctou
//        3 = Dakar
function track() => byte(0x0030A3)

TRACK_MADRID = 0
TRACK_GIBRALTAR = 1
TRACK_TOMBOUCTOU = 2
TRACK_DAKAR = 3

// $30A6: Track #1 Clear Time [16 bit]
// $30AA: Track #2 Clear Time [16 bit]
// $30AE: Track #3 Clear Time [16 bit]
// $30B2: Track #4 Clear Time [16 bit]
function clear_time(i) => word(0x0030A6 + i * 4)

CITIES = ["Paris", "Madrid", "Gibraltar", "Tombouctou", "Dakar"]
LEGS = {}
for i in range(0,3) { LEGS[i] = format("{0} to {1}", CITIES[i], CITIES[i+1]) }

// $30D6: Checkpoint Time Bonus [16 bit]
function checkpoint_time() => word(0x0030D6)

// $3111: Difficulty [8 bit] - set by dip switch
//        0 = Normal
//        1 = Easy
//        2 = Hard
//        3 = Hardest
function difficulty() => byte(0x003111)

DIFF_EASY = 1
DIFF_NORMAL = 0
DIFF_HARD = 2
DIFF_HARDEST = 3

DIFFICULTY = {
	DIFF_EASY: "Easy",
	DIFF_NORMAL: "Normal",
	DIFF_HARD: "Hard",
	DIFF_HARDEST: "Hardest",
}

// $5C42: Player Current Rank [8 bit]
//        zero-indexed (0 = first, 1 = second, etc)
function leaderboard_rank() => byte(0x005C42)

rp_state = rich_presence_lookup("State", game_state(), EMOJI_STATE, fallback="🚩")
rp_crash = rich_presence_lookup("Crash", crash(), CRASH_STATE, fallback="")
rp_score = rich_presence_value("Score", score(), "SCORE")
rp_speed = rich_presence_value("Number", speed_real())
rp_time = rich_presence_value("Timer", clock(), "FIXED1")
rp_leg = rich_presence_lookup("Leg", track(), LEGS, fallback="Paris to Dakar")
rp_demo_leg = rich_presence_lookup("Leg", loaded_track(), LEGS, fallback="Paris to Dakar")
rp_diff = rich_presence_lookup("Difficulty", difficulty(), DIFFICULTY, fallback="Normal")

rich_presence_conditional_display(game_state_group() == GROUP_RACE,
    "{0}{1} Racing from {2} | 🏎 {3} km/h | ⏲️ {4} | 💰 {5} | {6} Difficulty",
	rp_state, rp_crash, rp_leg, rp_speed, rp_time, rp_score, rp_diff
)

rich_presence_conditional_display(game_state_group() == GROUP_WINNER,
    "🏆 You are the champion! 🏅 | 💰 {0} | {1} Difficulty",
	rp_score, rp_diff
)

rich_presence_conditional_display(game_state_group() == GROUP_SETUP && game_state() <= 0x1D,
    "🗺️ Reviewing the route from {0}",
	rp_leg
)

rich_presence_conditional_display(game_state_group() == GROUP_SETUP,
    "{0}{1} Racing from {2} | 🏎{3} km/h | ⏲️ {4} | 💰 {5} | {6} Difficulty",
	rp_state, rp_crash, rp_leg, rp_speed, rp_time, rp_score, rp_diff
)

rich_presence_conditional_display(game_state() == STATE_DEMO,
    "📽 [DEMO] Racing from {0} | 🏎 {1} km/h | ⏲️ {2}",
	rp_demo_leg, rp_speed, rp_time
)

rich_presence_display(
    "Blomby Car is preparing for this Infernal Raid"
)

function race_start() => prev(game_state()) == STATE_COUNTDOWN && game_state() == STATE_RACE && clock() == 0
function race_complete() => prev(game_state_group()) == GROUP_RACE && game_state() == STATE_FINISH
function rally_start() => race_start() && track() == 0
function rally_complete() => race_complete() && track() == 3
function win_game() => game_state() == STATE_CHAMPION

ach_names = [
	"Vive la Blombe",
	"Strait Into Gibraltar",
	"From Here to Timbuktu",
	"The Tsar of Dakar",
]

for track in range(0,3)
{
	achievement(
		title=ach_names[track],
		description=format("Complete the {0} leg of the race on Normal difficulty or higher", LEGS[track]),
		points=if_else(track == TRACK_DAKAR, 25, 5),
		type=if_else(track == TRACK_DAKAR, "win_condition", "progression"),
		trigger=(track() == track && difficulty() != DIFF_EASY && race_complete())
	)
}

if (false) // DISABLED
achievement(
	title="Super Blomby Dakart",
	description="Complete all four legs of the Paris-Dakar rally on Hard difficulty or higher",
	points=25,
	trigger=(
		// a hit for completing each track in the rally on Hardest
		measured(
			tally_of(range(0,3), 4, (x) => once(track() == x && race_complete())), 
			when=difficulty() >= DIFF_HARD
		) &&

		// trigger on You Are The Champion
		game_state() == STATE_CHAMPION &&

		// reset if you're back at the start
		never(game_state() == STATE_BONVOIAGE)
	)
)

achievement(
	title="From Paris to Dakar, One-Way Non-Stop (1CC)",
	description="Complete all four legs with only one credit on Normal difficulty or higher",
	points=50,
	trigger=(
		// checkpoint hit at the start of the rally if we are on the right difficulty
		difficulty() != DIFF_EASY && once(rally_start()) &&

		// trigger when we complete the rally
		trigger_when(rally_complete()) &&

		// reset if we ever use a continue
		never(game_state() == STATE_CONTINUE || credits() < prev(credits())) &&

		// reset if you're back at the start
		never(game_state() == STATE_BONVOIAGE)
	)
)

TOP_SPEED_TIME = 15
achievement(
	title="Speed Demon",
	description=format("Reach and maintain top speed (200 km/h) for more than {0} seconds", TOP_SPEED_TIME),
	points=5,
	trigger=(tally(TOP_SPEED_TIME * 60, speed() >= 0x16) && never(speed() < 0x16) && never(game_state() != STATE_RACE))
)

for track in range(0,3)
{
	achievement(
		title=format("Rally Expert {0}: {1}", ROMAN[track+1], LEGS[track]),
		description=format("Complete the {0} leg of the race without crashing", LEGS[track]),
		points=10,
		trigger=(
			// correct track
			track() == track && game_state_group() == GROUP_RACE &&

			// trigger when the player crosses the finish line
			trigger_when(race_complete()) &&

			// disable if the player crashes
			disable_when(is_crashing(), until=race_start())
		)
	)
}

GOAL_TIMES = {
	TRACK_MADRID: 1450,
	TRACK_GIBRALTAR: 1300,
	TRACK_TOMBOUCTOU: 1400,
	TRACK_DAKAR: 1650,
}

for track in range(0,3)
{
	achievement(
		title=format("Infernal Raid {0}: {1}", ROMAN[track+1], LEGS[track]),
		description=format("Complete the {0} leg of the race in {1}.{2} seconds or less on Normal difficulty or higher",
			LEGS[track], GOAL_TIMES[track]/10, GOAL_TIMES[track]%10),
		points=10,
		trigger=(
			// correct track, difficulty, and the time is still valid
			track() == track && game_state_group() == GROUP_RACE && difficulty() != DIFF_EASY &&
			
			// timer hasn't expired yet
			clock() <= GOAL_TIMES[track] &&
			
			// trigger when the player crosses the finish line
			trigger_when(race_complete())
		)
	)
}

//for diff in [DIFF_NORMAL, DIFF_HARD, DIFF_HARDEST]
diff = DIFF_NORMAL
for track in range(0,3)
{
	leaderboard(
		title=format("#{0} {1} ({2})", track+1, LEGS[track], DIFFICULTY[diff]),
		description=format("Complete the {0} leg as quickly as possible on {1} difficulty", LEGS[track], DIFFICULTY[diff]),

		start=race_complete() && track() == track && difficulty() == diff,
		cancel=track() != track,
		submit=always_true(),

		value=clock(),
		format="FIXED1",
		lower_is_better=true
	)
}

leaderboard(
	title=format("Paris-Dakar Star ({0})", DIFFICULTY[diff]),
	description=format("Clear all four legs of the Paris-Dakar rally as quickly as possible on {0} difficulty", DIFFICULTY[diff]),

	start=game_state() == STATE_CHAMPION && difficulty() == diff,
	cancel=game_state() != STATE_CHAMPION,
	submit=always_true(),

	value=sum_of(range(0,3), clear_time),
	format="FIXED1",
	lower_is_better=true
)