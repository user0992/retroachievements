// ~Unlicensed~ Titenic
// #ID = 8654

// $0028: Game State [8 bit]
//        0x01 = Playing
//        0x02 = Continue?
//        0x09, 0x0C = Cutscene
//        0x0B = Title
//        0x0F = Credits
STATE_PLAYING = 0x01
STATE_CONTINUE = 0x02
STATE_CUTSCENE_INTRO = 0x0C
STATE_CUTSCENE = 0x09
STATE_TITLE = 0x0B
STATE_CREDITS = 0x0F

function game_state() => byte(0x000028)
function now_playing() => game_state() == STATE_PLAYING

// $0038: Paused [8 bit BE]
//        0 = Unpaused, 1 = Paused
function is_paused() => byte(0x000038) == 1

// $0091: Score [24 bit]
//        multiply value by 10
function score() => tbyte(0x000091) * 10

// $0160: Time Remaining - "Seconds" [8 bit]
//        only relevant in stage 5 escape

// $0161: Time Remaining - "Minutes" [8 bit]
//        only relevant in stage 5 escape
function time_sec() => byte(0x000160)
function time_min() => byte(0x000161)
function timer() => time_min() * 60 + time_sec()

// $0173: Current Character [8 bit]
//        01 = Rose
//        02 = Jack
CHAR_ROSE = 1
CHAR_JACK = 2
function player_char() => byte(0x000173)

// $0185: Character X Position [8 bit]
function char_xpos() => byte(0x000185)

// $0189: Character Y Position [8 bit]
function char_ypos() => byte(0x000189)

// $018D: Life Count [8 bit]
function lives() => byte(0x00018D)

// $0193: Damage Taken [8 bit]
//        0x57 = dead
function damage() => byte(0x000193)
function health() => 0x57 - damage()

// $0199: Level Number [8 bit] - zero-indexed
//        0 = Level 1
//        1 = Level 2
//        2 = Level 3
//        3 = Level 4
//        4 = Level 5
//        5 = game beaten, AND replaying Level 1 after credits
function level() => byte(0x000199)

// $031E: Animation Frame [8 bit]
//        0x0b = Jack fallen down
//        0x19 = Jack shoulder check
//        0x30 = Jack wins
//        0x31-0x35 Jack idle frames
//        0x0c = Rose fallen down
//        0x29 = Rose wins
//        0x2a-0x2e Rose idle frames
function anim() => byte(0x00031E)

// $0347: Boss Y Position [8 bit] - Stage 2
//        goes to 0x80 when kicked in water
//        0xd0 = boat deck, larger means kicked in water

// $0348: Boss Y Position [8 bit] - Stage 5
//        goes to 0x80 when kicked in water
//        0xd0 = boat deck, larger means kicked in water
BOSS_POSITION = [0, 0x000347, 0, 0, 0x000348]
function boss_ypos(lvl) => byte(BOSS_POSITION[lvl])

// $04E8: Room ID [8 bit]
//        0x00-0x02 = Stage 1 (1up in 0x02)
//        0x03-0x05 = Stage 2 (1up in 0x04)
//        0x06-0x08 = Stage 3
//        0x09,0x0d,0x12 = Stage 4 main deck
//        0x0a = Stage 4 lower side room
//        0x0b = Stage 4 upper side room (1up)
//        0x0c = Stage 4 boss room
//        0x0e-0x11 = Stage 5 (1up in 0x0f)
ROOMS_1UP = [0x02, 0x04, 0x0B, 0x0F]
ROOMS_TIMED = [0x0E, 0x0F, 0x10]
function room_id() => byte(0x0004E8)

// $0564: Flashing Death Timer [8 bit BE]
//        0x00 = alive
//        0x02 = fallen (freezes here if you get back up immediately)
//        jumps to 0x81, then counts up; at 0xBB, if still on ground, death
//        continues counting up to 0xF8 and snaps to 0x00 if standing
function death_timer() => byte(0x000564)

// $0675: Boss Health - Stage 2
//        0x5f = dead

// $0685: Boss Health - Stage 3
//        0x5f = dead

// $068C: Boss Health - Stage 1
//        0x5f = dead

// $0699: Boss Health - Stage 4
//        0x5f = dead

// $06A0: Boss Health - Stage 5
//        0x5f = dead
BOSS_HEALTH = [0x00068C, 0x000675, 0x000685, 0x000699, 0x0006A0]
function boss_health(lvl) => byte(BOSS_HEALTH[lvl])

CharLookup = {
    CHAR_JACK: "Jack",
    CHAR_ROSE: "Rose",
}

LifeLookup = {
    0x01: "Life",
}

DeckLookup = {
	0: "1",
	1: "2",
	2: "3",
	3: "4",
	4: "5",
}

rich_presence_conditional_display(game_state() == STATE_PLAYING,
    "{0} is escaping deck {1} of the Titenic | ❤️{2}/87, {3} {4} | {5} points",
    rich_presence_lookup("Char", player_char(), CharLookup, fallback="Jack"),
    rich_presence_lookup("Deck", level(), DeckLookup, fallback="1"),
    rich_presence_value("Number", health()),
    rich_presence_value("Number", lives()),
    rich_presence_lookup("Life", lives(), LifeLookup, fallback="Lives"),
    rich_presence_value("Number", score())
)

rich_presence_conditional_display(level() == 5 && !now_playing(),
    "Being rescued from the 🚢 RMS Titenic (The story, all names, characters, and incidents portrayed in this production are fictitious. No identification with actual persons, living or deceased, is intended or should be inferred.)"
)

rich_presence_display(
    "Aboard the maiden voyage of the 🚢 RMS Titenic"
)

STAGE_CLEARS = [
    {"level": 0, "title": "Near, Far, Wherever You Are", "desc": "Clear Stage 1", "anim": 0x30},
    {"level": 1, "title": "I Believe That the Heart Does Go On", "desc": "Clear Stage 2", "anim": 0x30},
    {"level": 2, "title": "Once More, You Open the Door", "desc": "Clear Stage 3", "anim": 0x30},
    {"level": 3, "title": "And You're Here in my Heart", "desc": "Clear Stage 4", "anim": 0x29},
    {"level": 4, "title": "And My Heart Will Go On and On", "desc": "Clear Stage 5", "anim": 0x29},
]

for stage in STAGE_CLEARS
{
    type = "progression"
    points = 5
    if (stage["level"] == 4)
    {
        type = "win_condition"
        points = 25
    }

    achievement(
        title=stage["title"],
        description=stage["desc"],
        points=points,
        type=type,
        trigger=(
            // check if the character is in their victory pose animation
            anim() == stage["anim"] &&

            // as the level changes from the prev to the next level
            prev(level()) == stage["level"] && level() == stage["level"] + 1
        )
    )
}

collect_all_1ups = []
for room in ROOMS_1UP
    array_push(collect_all_1ups, once(room_id() == room && lives() == prev(lives()) + 1))

achievement
(
    title="And Last for a Lifetime",
    description="Collect every 1up in the game",
    points=10,

    // check that all 1ups have been collected
    trigger=measured(tally(length(collect_all_1ups), collect_all_1ups))
)

achievement
(
    title="You're Here, There's Nothing I Fear",
    description="Cross the second room of Stage 3 without getting hit",
    points=10,
    trigger=(
        // checkpoint hit on entering room 7
        once(prev(room_id()) == 0x06 && room_id() == 0x07) &&

        // success when exiting room 7
        trigger_when(prev(room_id()) == 0x07 && room_id() == 0x08) &&

        // reset when losing health
        never(damage() > prev(damage())) &&

        // reset when falling over
        never(anim() == 0x0B)
    )
)

achievement
(
    title="I See You",
    description="Have Jack draw you like one of his French girls",
    points=1,
    trigger=(
        // playing as Jack
        player_char() == CHAR_JACK && (level() < 3 || level() == 5) &&

        // idle animations for Jack (drawing pose)
        anim() >= 0x31 && anim() <= 0x35
    )
)

achievement
(
    title="I Feel You",
    description="Is now really an appropriate time for afternoon tea, Rose?",
    points=1,
    trigger=(
        // playing as Rose
        player_char() == CHAR_ROSE && level() >= 3 && level() < 5 &&

        // idle animations for Rose (tea time)
        anim() >= 0x2a && anim() <= 0x2e
    )
)

achievement
(
    title="You Are Safe in My Heart (But Not in the Water)",
    description="Cool Cal off by sending him for a swim",
    points=10,
    trigger=(
        // boss fight in stage 2
        (room_id() == 0x05 && boss_ypos(1) >= 0xe0) ||

        // boss fight in stage 5
        (room_id() == 0x11 && boss_ypos(4) >= 0xe0)
    )
)

achievement
(
    title="One True Time I'd Hold to",
    description="In one attempt, clear all of the timed rooms in Stage 5 without running out of time",
    points=10,
    trigger=(
        // challenge begins on first entering Stage 5
        once(game_state() == STATE_PLAYING && room_id() == 0x0E && timer() > 0) &&

        // ends after the timed section
        trigger_when(room_id() == 0x11) &&

        // reset if the timer ever reaches 0
        never(timer() == 0)
    )
)

achievement
(
    title="In My Life, We'll Always Go On",
    description="Complete the game without using a continue",
    points=25,
    trigger=(
        // challenge begins on first room
        once(prev(game_state()) == STATE_CUTSCENE_INTRO && game_state() == STATE_PLAYING) &&

        // ends at end of game
        trigger_when(prev(level()) == 4 && level() == 5) &&

        // reset if we run out of lives
        never(lives() == 0xFF) && never(game_state() == STATE_CONTINUE)
    )
)

achievement
(
    title="And Never Let Go 'Til We're Gone",
    description="Don't let yourself succumb to death! Get back up and continue fighting, at zero health",
    points=1,
    trigger=(
        // ran out of health and player fell down (dead)
        // rose fall down is 0x0D - 1 -> 0x0C
        // jack fall down is 0x0D - 2 -> 0x0B
        once(health() == 0 && anim() == 0x0D - player_char() && death_timer() == 0x02) &&

        // got back up! (animation value is not death, and not because the timer just ran out)
        (anim() != 0x0D - player_char() && prev(death_timer()) != 0xBB) &&

        // achievement shouldn't fire if the health resets, due to death or healing
        never(health() > 0) &&

        // reset if the timer indicates we are dying, but the player wasn't downed
        never(death_timer() == 0 && prev(anim()) != 0x0D - prev(player_char()))
    )
)

SCORE_GOAL = 10000
achievement
(
    title="You Have Come to Show You Go On",
    description="Earn a score higher than " + SCORE_GOAL,
    points=10,
    trigger=(
        // currently in-game
        now_playing() &&

        // score reaches the goal value
        prev(score()) < SCORE_GOAL && score() >= SCORE_GOAL
    )
)

leaderboard
(
	title="Hurry to the Lifeboats!",
	description="Starting from the title screen, escape the Titenic as quickly as possible.",

	// start when you finish watching the intro cutscene
	start=(prev(game_state()) == STATE_CUTSCENE_INTRO && game_state() == STATE_PLAYING),

	// cancel if we ever return to the title screen
	cancel=(game_state() == STATE_TITLE),

	// submit when level 4 is completed
	submit=(prev(level()) == 4 && level() == 5),

	// value is the number of frames spent playing the game
	value=measured(tally(0, game_state() == STATE_PLAYING)),
	format="FRAMES",
	lower_is_better=true
)