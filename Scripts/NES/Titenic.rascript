// ~Unlicensed~ Titenic
// #ID = 8654

OBJECT_IDS = 0x030a
OBJECT_ANIMS = 0x00031E
OBJECT_Y = 0x0346

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
function anim() => byte(OBJECT_ANIMS)

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

CharLookup = {
    CHAR_JACK: "Jack",
    CHAR_ROSE: "Rose",
}

DeckLookup = {
    0: "1",
    1: "2",
    2: "3",
    3: "4",
    4: "5",
}

rich_presence_conditional_display(game_state() == STATE_PLAYING,
    "{0} is escaping deck {1} of the Titenic | ❤️{2}%, {3} {4} | {5} points",
    rich_presence_lookup("Char", player_char(), CharLookup, fallback="Jack"),
    rich_presence_lookup("Deck", level(), DeckLookup, fallback="1"),
    rich_presence_value("_Number", 100.0 * health() / 87.0, "VALUE"),
    rich_presence_value("_Number", lives(), "VALUE"),
    rich_presence_lookup("Life", lives(), {1: "Life"}, fallback="Lives"),
    rich_presence_value("_Number", score(), "VALUE")
)

rich_presence_conditional_display(level() == 5 && !now_playing(),
    "Being rescued from the 🚢 RMS Titenic (The story, all names, characters, and incidents portrayed " +
    "in this production are fictitious. No identification with actual persons, living or deceased, is " +
    "intended or should be inferred.)"
)

rich_presence_display(
    "Aboard the maiden voyage of the 🚢 RMS Titenic"
)

STAGE_CLEARS = {
    0x00: "Near, Far, Wherever You Are",
    0x01: "I Believe That the Heart Does Go On",
    0x02: "Once More, You Open the Door",
    0x03: "And You're Here in my Heart",
    0x04: "And My Heart Will Go On and On",
}

for stage in STAGE_CLEARS
{
    type = "progression"
    points = 5
    if (stage == 4)
    {
        type = "win_condition"
        points = 25
    }

    achievement(
        title=STAGE_CLEARS[stage],
        description="Clear Stage " + (stage + 1),
        points=points,
        type=type,
        trigger=(
            // game has just gone to cutscene
            game_state() == STATE_CUTSCENE &&

            // as the level changes from the prev to the next level
            prev(level()) == stage && level() == stage + 1
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

SLOTS_TO_CHECK = 4
ROOM_BOSSES = {
    0x05: 0x40,
    0x08: 0x41,
    0x11: 0x03,
}

CAL_FALLING_FRAMES = [0x24, 0x25]
achievement
(
    title="You Are Safe in My Heart (But Not in the Water)",
    description="Cool Cal off by sending him for a swim",
    points=10,
    trigger=(
        // for each of the boss fights...
        any_of(ROOM_BOSSES, room => 
        (
            // if we are in the boss room
            room_id() == room && 
        
            // and any of the first 4 object slots are Cal and below the boat deck
            any_of(range(1,SLOTS_TO_CHECK), i =>
            (
                // Cal in this slot
                byte(OBJECT_IDS + i) == ROOM_BOSSES[room] && 

                // animation for Cal falling is 0x24 and 0x25
                any_of(CAL_FALLING_FRAMES, x => byte(OBJECT_ANIMS + i) == x) &&

                // below deck
                byte(OBJECT_Y + i) >= 0xE0
            ))
        ))
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