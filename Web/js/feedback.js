// reversal of comparison
const FLIP_CMP = new Map([["=", "!="], ["!=", "="], [">", "<="], ["<", ">="], [">=", "<"], ["<=", ">"]]);

// title case helpers
const TITLE_CASE_MINORS = new Set([
	'a', 'an', 'and', 'as', 'at', 'but', 'by', 'en', 'for', 'from', 'how', 'if', 'in', "n'", "'n'",
	'neither', 'nor', 'of', 'on', 'only', 'onto', 'out', 'or', 'over', 'per', 'so', 'than', 'that', 
	'the', 'to', 'until', 'up', 'upon', 'v', 'v.', 'versus', 'vs', 'vs.', 'via', 'when', 
	'with', 'without', 'yet',
]);
function tc_minor(word) { return TITLE_CASE_MINORS.has(word); }
function make_title_case(phrase)
{
	function tc(s) { return s.charAt(0).toUpperCase() + s.substring(1); }
	return phrase.replace(/[\w'\u2019]+/g, function(x, i)
	{
		if (x == x.toUpperCase()) return x; // assume allcaps for a reason
		if (i == 0 || i + x.length == phrase.length) return tc(x);
		return tc_minor(x) ? x : tc(x);
	});
}
function titlecase_links(phrase)
{
	let q = encodeURIComponent(phrase);
	return [
		`https://titlecaseconverter.com/?style=CMOS&showExplanations=1&keepAllCaps=1&multiLine=1&highlightChanges=1&convertOnPaste=1&straightQuotes=1&title=${q}`,
		`https://capitalizemytitle.com/style/Chicago/?title=${q}`,
	];
}

const FeedbackSeverity = Object.freeze({
	INFO: 0,
	WARN: 1,
	ERROR: 2,
});
const Feedback = Object.freeze({
	// writing policy feedback
	TITLE_CASE: { severity: FeedbackSeverity.WARN, desc: "Titles should be written in title case according to the Chicago Manual of Style.",
		ref: ["https://en.wikipedia.org/wiki/Title_case#Chicago_Manual_of_Style",], },
	TITLE_PUNCTUATION: { severity: FeedbackSeverity.WARN, desc: "Achievement titles are not full sentences, and should not end with punctuation (exception: ?, !, or ellipses).",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#punctuation",], },
	DESC_SENTENCE_CASE: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should not be in title case, but rather sentence case.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#capitalization-1",], },
	DESC_PUNCT_CONSISTENCY: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should be consistent about whether or not they end with punctuation.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#punctuation-1",], },
	DESC_BRACKETS: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should avoid brackets where possible.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#brackets-parentheses",], },
	DESC_SYMBOLS: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions are discouraged from using symbols to describe conditions.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",], },
	DESC_QUOTES: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should only use double quotation marks, except for quotes inside quotes.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",], },
	NUM_FORMAT: { severity: FeedbackSeverity.INFO, desc: "Numbers should be formatted to conform to English standards (period for decimal separation, commas for grouping).",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#number-formatting",], },
	NO_EMOJI: { severity: FeedbackSeverity.WARN, desc: "Achievement titles and descriptions may not contain emoji.",
		ref: [
			"https://docs.retroachievements.org/guidelines/content/writing-policy.html#emojis",
			"https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",
		], },
	SPECIAL_CHARS: { severity: FeedbackSeverity.WARN, desc: "Avoid using accented/special characters, as they can have rendering issues.",
		ref: [
			"https://docs.retroachievements.org/guidelines/content/naming-conventions.html",
			"https://docs.retroachievements.org/developer-docs/tips-and-tricks.html#naming-convention-tips",
		], },
	FOREIGN_CHARS: { severity: FeedbackSeverity.INFO, desc: `Achievement titles and descriptions should be written in English and should avoid special characters. For policy exceptions regarding the use of foreign language, ${send_message_to("QATeam")}`,
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#language",], },

	// set design errors
	NO_PROGRESSION: { severity: FeedbackSeverity.INFO, desc: "Set lacks progression achievements (win conditions found). This might be unavoidable, depending on the game, but progression achievements should be added when possible.",
		ref: ["https://docs.retroachievements.org/guidelines/content/progression-and-win-condition-guidelines.html#progression-conditions",], },
	NO_TYPING: { severity: FeedbackSeverity.WARN, desc: "Set lacks progression and win condition typing.",
		ref: [
			"https://docs.retroachievements.org/guidelines/content/progression-and-win-condition-guidelines.html#progression-conditions",
			"https://docs.retroachievements.org/guidelines/content/progression-and-win-condition-guidelines.html#win-conditions",
		], },
	ACHIEVEMENT_DIFFICULTY: { severity: FeedbackSeverity.INFO, desc: "A good spread of achievement difficulties is important.",
		ref: ["https://docs.retroachievements.org/developer-docs/difficulty-scale-and-balance.html",], },
	PROGRESSION_ONLY: { severity: FeedbackSeverity.WARN, desc: "Progression-only sets should be avoided. Consider adding custom challenge achievements to improve it.",
		ref: ["https://retroachievements.org/game/5442",], },

	// code notes
	NOTE_EMPTY: { severity: FeedbackSeverity.WARN, desc: "Empty code note.",
		ref: [], },
	NOTE_NO_SIZE: { severity: FeedbackSeverity.WARN, desc: "Code notes must have size information.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#specifying-memory-addresses-size",], },
	NOTE_ENUM_HEX: { severity: FeedbackSeverity.WARN, desc: "Enumerated hex values in code notes must be prefixed with \"0x\".",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#adding-values-and-labels",], },

	// rich presence
	NO_DYNAMIC_RP: { severity: FeedbackSeverity.WARN, desc: "Dynamic rich presence is required for all sets.",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#introduction',], },
	NO_CONDITIONAL_DISPLAY: { severity: FeedbackSeverity.INFO, desc: "Good rich presence usually requires conditional displays.",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#conditional-display-strings',], },
	MISSING_NOTE_RP: { severity: FeedbackSeverity.WARN, desc: "All addresses used in rich presence require a code note.",
		ref: [], },
		
	// code errors
	BAD_CHAIN: { severity: FeedbackSeverity.ERROR, desc: "The last requirement of a group cannot have a chaining flag.",
		ref: [], },
	MISSING_NOTE: { severity: FeedbackSeverity.WARN, desc: "All addresses used in achievement logic require a code note.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html",], },
	ONE_CONDITION: { severity: FeedbackSeverity.WARN, desc: "One-condition achievements are dangerous and should be avoided.",
		ref: ["https://docs.retroachievements.org/developer-docs/tips-and-tricks.html#achievement-creation-tips",], },
	MISSING_DELTA: { severity: FeedbackSeverity.INFO, desc: "Using Delta helps to control precisely when an achievement triggers. All achievements benefit from its use.",
		ref: [
			'https://docs.retroachievements.org/developer-docs/delta-values.html',
			'https://docs.retroachievements.org/developer-docs/prior-values.html',
		], },
	COMMON_ALT: { severity: FeedbackSeverity.INFO, desc: "If every alt group contains the same bit of logic in common, it can be refactored back into the Core group.",
		ref: [], },
	STALE_ADDADDRESS: { severity: FeedbackSeverity.WARN, desc: "AddAddress should only ever use Mem. Stale references with AddAddress can be dangerous.",
		ref: ['https://docs.retroachievements.org/developer-docs/hit-counts.html',], },
	PAUSELOCK_NO_RESET: { severity: FeedbackSeverity.WARN, desc: "PauseLocks require a reset, either via ResetNextIf, or a ResetIf in another group.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/pauseif.html#pauseif-with-hit-counts',], },
	HIT_NO_RESET: { severity: FeedbackSeverity.WARN, desc: "Hit counts require a reset, either via ResetIf or ResetNextIf.",
		ref: ['https://docs.retroachievements.org/developer-docs/hit-counts.html',], },
	USELESS_ANDNEXT: { severity: FeedbackSeverity.WARN, desc: "Combining requirements with AND is the default behavior. Useless AndNext flags should be removed.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/andnext-ornext.html',], },
	UUO_RESET: { severity: FeedbackSeverity.WARN, desc: "ResetIf should only be used with achievements that have hitcounts.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetif.html',], },
	UUO_RNI: { severity: FeedbackSeverity.WARN, desc: "ResetNextIf should only be used with requirements that have hitcounts.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetnextif.html',], },
	UUO_PAUSE: { severity: FeedbackSeverity.WARN, desc: "PauseIf should only be used with requirements that have hitcounts.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/pauseif.html',], },
	PAUSING_MEASURED: { severity: FeedbackSeverity.INFO, desc: "PauseIf should only be used with requirements that have hitcounts, unless being used to freeze updates to a Measured requirement.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/measured.html#measured',], },
	RESET_HITCOUNT_1: { severity: FeedbackSeverity.WARN, desc: "A ResetIf or ResetNextIf with a hitcount of 1 does not require a hitcount. The hitcount can be safely removed.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetif.html',], },
	USELESS_ADDSUB: { severity: FeedbackSeverity.WARN, desc: "Using AddSource and SubSource is better supported in old emulators, and should be preferred where possible.",
		ref: [
			'https://docs.retroachievements.org/developer-docs/flags/addsource.html',
			'https://docs.retroachievements.org/developer-docs/flags/subsource.html',
		], },
	UNSATISFIABLE: { severity: FeedbackSeverity.ERROR, desc: "Requirement can never be satisfied. If this is intentional, writing it explicitly is preferred (Val 0 = Val 1, for instance).",
		ref: [], },
});

class Issue
{
	type;
	target;
	detail = null;
	constructor(type, target, detail = null)
	{
		this.type = type;
		this.target = target;
		this.detail = detail;
	}
}

class Assessment
{
	issues = [];
	stats = {};
	constructor()
	{
	}

	add(x) { return this.issues.push(x); }
	pass() { return this.issues.filter(x => x.type.severity > FeedbackSeverity.INFO).length == 0; }

	combine(o)
	{
		for (const issue of o.issues) this.add(issue);
		Object.assign(this.stats, o.stats);
	}
}

function send_message_to(target)
{ return `<a href="https://retroachievements.org/messages/create?to=${target}">message ${target}</a>`; }

function* missing_notes(logic)
{
	function _is_missing(operand)
	{
		if (!operand || !operand.type.addr) return false;
		let addr = parseInt(operand.value, 16);
		for (const cn of current.notes || [])
			if (cn.contains(addr)) return false;
		return true;
	}
	
	for (const [gi, g] of logic.groups.entries())
	{
		let prev_addaddress = false;
		for (const [ri, req] of g.entries())
		{
			let lastreport = null;
			for (const operand of [req.lhs, req.rhs])
				if (!prev_addaddress && _is_missing(operand))
				{
					if (lastreport == operand.value) continue;
					yield { addr: operand.value, req: req, };
					lastreport = operand.value;
				}
			prev_addaddress = req.flag == ReqFlag.ADDADDRESS;
		}
	}
}

function assess_logic(logic)
{
	let res = new Assessment();
	res.mem_length = -1;

	// flattened version of the logic
	const flat = [].concat(...logic.groups);
	const operands = new Set(logic.getOperands());
	const comparisons = flat.map(x => x.op).filter(x => FLIP_CMP.has(x));

	// number of groups (number of alt groups is this minus 1)
	res.stats.group_count = logic.groups.length;
	res.stats.alt_groups = res.stats.group_count - 1;

	// size of the largest group
	res.stats.group_maxsize = Math.max(...logic.groups.map((x) => x.length));

	// total number of conditions
	res.stats.cond_count = logic.groups.reduce((a, e) => a + e.length, 0);

	// set of unique flags, comparisons, and sizes used in the achievement
	res.stats.unique_flags = new Set(logic.getFlags());
	res.stats.unique_cmps = new Set(comparisons);
	res.stats.unique_sizes = new Set(logic.getMemSizes()).difference(BitProficiency);

	// list of all chained requirements
	let chains = [];
	for (const [gi, g] of logic.groups.entries())
	{
		let curr_chain = [];
		for (const [ri, req] of g.entries())
		{
			curr_chain.push(req);
			if (!req.flag || !req.flag.chain)
			{ chains.push(curr_chain); curr_chain = []; }
		}
	}

	// length of longest requirement chain
	res.stats.max_chain = Math.max(...chains.map(x => x.length));

	// count of achievements with hit counts
	res.stats.hit_counts_one = flat.filter(x => x.hits == 1).length;
	res.stats.hit_counts_many = flat.filter(x => x.hits > 1).length;

	// count of achievements with PauseIf
	res.stats.pause_ifs = flat.filter(x => x.flag == ReqFlag.PAUSEIF).length;
	res.stats.pause_locks = flat.filter(x => x.flag == ReqFlag.PAUSEIF && x.hits > 0).length;

	// count of achievements with ResetIf
	res.stats.reset_ifs = flat.filter(x => x.flag == ReqFlag.RESETIF).length;
	res.stats.reset_with_hits = flat.filter(x => x.flag == ReqFlag.RESETIF && x.hits > 0).length;

	// count of achievements with Deltas and Prior
	res.stats.deltas = [...operands].filter(x => x.type == ReqType.DELTA).length;
	res.stats.priors = [...operands].filter(x => x.type == ReqType.PRIOR).length;
	
	// list of addresses & virtual addresses
	res.stats.addresses = new Set(logic.getAddresses());
	res.stats.virtual_addresses = new Set();
	function _req2str(req) { return req.lhs.toString() + (!req.rhs ? '' : (req.op + req.rhs.toString())); }
	for (const [gi, g] of logic.groups.entries())
	{
		let prefix = '';
		for (const [ri, req] of g.entries())
		{
			if (req.flag == ReqFlag.ADDADDRESS)
				prefix += _req2str(req) + ':';
			else
			{
				if (req.lhs && req.lhs.type.addr) res.stats.virtual_addresses.add(prefix + req.lhs.toString());
				if (req.rhs && req.rhs.type.addr) res.stats.virtual_addresses.add(prefix + req.rhs.toString());
				prefix = '';
			}
		}
	}
	
	// skip this if notes aren't loaded
	if (current.notes.length)
	{
		for (const x of missing_notes(logic))
			res.add(new Issue(Feedback.MISSING_NOTE, x.req, 
				`Address <code>0x${x.addr.padStart(8, '0')}</code> missing note`));
	}

	if (res.stats.deltas + res.stats.priors == 0)
		res.add(new Issue(Feedback.MISSING_DELTA, null));

	for (const [gi, g] of logic.groups.entries())
	{
		const last = g[g.length-1];
		if (last.flag && last.flag.chain)
			res.add(new Issue(Feedback.BAD_CHAIN, last));
	}

	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
		{
			// using AddAddress with Delta/Prior is dangerous
			if (req.flag == ReqFlag.ADDADDRESS && [ReqType.DELTA, ReqType.PRIOR].includes(req.type))
				res.add(new Issue(Feedback.STALE_ADDADDRESS, req));
		}

	// achievement is *possibly* an OCA if there is only one virtual address or only one comparison happens
	// TODO: there should be a better way to determine this
	res.stats.oca = res.stats.virtual_addresses.size <= 1 || comparisons.length <= 1;
	if (res.stats.oca) res.add(new Issue(Feedback.ONE_CONDITION, null));

	// check for Mem>Del Counter
	res.stats.mem_del = flat.filter(x => x.hits > 0 && x.isCmp() && x.op != '=' && x.lhs.value == x.rhs.value &&
		[x.lhs.type, x.rhs.type].includes(ReqType.MEM) && [x.lhs.type, x.rhs.type].includes(ReqType.DELTA)).length;

	let groups_with_reset = new Set();
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
			if (req.flag == ReqFlag.RESETIF)
				groups_with_reset.add(gi);

	const COMBINING_MODIFIER_FLAGS = new Set([
		ReqFlag.ADDADDRESS,
		ReqFlag.ADDSOURCE,
		ReqFlag.SUBSOURCE,
		ReqFlag.ANDNEXT,
		ReqFlag.ORNEXT,
	]);

	res.stats.pause_lock_alt_reset = 0;
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
		{
			if (req.hits > 0)
			{
				let foundrni = false;
				for (let i = ri - 1; i >= 0 && !foundrni; i--)
				{
					if (g[i].flag == ReqFlag.RESETNEXTIF) foundrni = true;
					if (!COMBINING_MODIFIER_FLAGS.has(g[i].flag)) break;
				}

				// this is a pauselock
				if (req.flag == ReqFlag.PAUSEIF)
				{
					if (!foundrni)
					{
						if (groups_with_reset.difference(new Set([gi])).size == 0)
							res.add(new Issue(Feedback.PAUSELOCK_NO_RESET, req));
						else
							res.stats.pauselock_alt_reset += 1;
					}
				}
				else if (req.flag != ReqFlag.RESETIF)
				{
					if (!foundrni && res.stats.reset_ifs == 0)
						res.add(new Issue(Feedback.HIT_NO_RESET, req));
				}
			}
		}

	let smod = res.stats.source_modification = new Map(['*', '/', '&', '^', '%', '+', '-'].map(x => [x, 0]));
	for (let req of flat) if (smod.has(req.op)) smod.set(req.op, smod.get(req.op) + 1);
	
	let has_hits = flat.reduce((a, e) => a + e.hits, 0) > 0;
	for (const [gi, g] of logic.groups.entries())
	{
		let group_flags = new Set(g.map(x => x.flag));
		for (const [ri, req] of g.entries())
		{
			function invert_chain()
			{
				function invert_req(req)
				{
					let copy = req.clone();
					if      (copy.flag == ReqFlag.ANDNEXT) copy.flag = ReqFlag.ORNEXT;
					else if (copy.flag == ReqFlag.ORNEXT ) copy.flag = ReqFlag.ANDNEXT;
					if (FLIP_CMP.has(copy.op)) copy.op = FLIP_CMP.get(copy.op);
					return copy;
				}

				let target = invert_req(req);
				target.flag = null;
				target.hits = 0;

				let res = target.toMarkdown();
				for (let i = ri - 1; i >= 0; i--)
				{
					if (!COMBINING_MODIFIER_FLAGS.has(g[i].flag)) break;
					res = invert_req(g[i]).toMarkdown() + '\n' + res;
				}
				return res;
			}

			if (req.flag == ReqFlag.PAUSEIF && !has_hits)
			{
				// if the group has a Measured flag, give a slightly different warning
				if (group_flags.has(ReqFlag.MEASURED) || group_flags.has(ReqFlag.MEASUREDP))
					res.add(new Issue(Feedback.PAUSING_MEASURED, req));
				else
					res.add(new Issue(Feedback.UUO_PAUSE, req,
						`Automated recommended change:<br/><pre><code>${invert_chain()}</code></pre>`));
			}
			else if (req.flag == ReqFlag.RESETIF && !has_hits)
				res.add(new Issue(Feedback.UUO_RESET, req,
					`Automated recommended change:<br/><pre><code>${invert_chain()}</code></pre>`));
			else if (req.flag == ReqFlag.RESETIF && req.hits == 1)
				res.add(new Issue(Feedback.RESET_HITCOUNT_1, req,
					`Automated recommended change:<br/><pre><code>${invert_chain()}</code></pre>`));
			else if (req.flag == ReqFlag.RESETNEXTIF)
			{
				for (let i = ri + 1; i < g.length; i++)
				{
					// if the requirement has hits, RNI is valid
					if (g[i].hits > 0) break;

					// if this is a combining flag like AddAddress or AndNext, the chain continues
					if (COMBINING_MODIFIER_FLAGS.has(g[i].flag)) continue;

					// otherwise, RNI was not valid
					res.add(new Issue(Feedback.UUO_RNI, req));
					break;
				}
			}
		}
	}
	return res;
}

const EMOJI_RE = /\p{Emoji_Presentation}/gu;
const TYPOGRAPHY_PUNCT = /[\u2018\u2019\u201C\u201D]/gu;
const FOREIGN_RE = /(?:\p{Script=Arabic}|\p{Script=Armenian}|\p{Script=Bengali}|\p{Script=Bopomofo}|\p{Script=Braille}|\p{Script=Buhid}|\p{Script=Canadian_Aboriginal}|\p{Script=Cherokee}|\p{Script=Cyrillic}|\p{Script=Devanagari}|\p{Script=Ethiopic}|\p{Script=Georgian}|\p{Script=Greek}|\p{Script=Gujarati}|\p{Script=Gurmukhi}|\p{Script=Han}|\p{Script=Hangul}|\p{Script=Hanunoo}|\p{Script=Hebrew}|\p{Script=Hiragana}|\p{Script=Inherited}|\p{Script=Kannada}|\p{Script=Katakana}|\p{Script=Khmer}|\p{Script=Lao}|\p{Script=Limbu}|\p{Script=Malayalam}|\p{Script=Mongolian}|\p{Script=Myanmar}|\p{Script=Ogham}|\p{Script=Oriya}|\p{Script=Runic}|\p{Script=Sinhala}|\p{Script=Syriac}|\p{Script=Tagalog}|\p{Script=Tagbanwa}|\p{Script=Tamil}|\p{Script=Telugu}|\p{Script=Thaana}|\p{Script=Thai}|\p{Script=Tibetan}|\p{Script=Yi})+/gu;
const NON_ASCII_RE = /(?:[^\x00-\x7F])+/g;

function assess_writing(asset)
{
	let res = new Assessment();

	res.corrected_title = make_title_case(asset.title);
	if (res.corrected_title != asset.title)
	{
		const links = [...titlecase_links(asset.title).entries()].map(
			([i, url]) => `[<a href="${url}">${i+1}</a>]`).join(' ');
		res.add(new Issue(Feedback.TITLE_CASE, 'title', 
			`Automated suggestion: <em>${res.corrected_title}</em> &mdash; Additional suggestions: ${links}`));
	}

	if (asset.title.endsWith('.') && !asset.title.endsWith('..'))
		res.add(new Issue(Feedback.TITLE_PUNCTUATION, 'title'));

	function build_indicated_feedback(text, re)
	{ return '<em>' + text.replace(re, x => `<span class="warn">${x}</span>`) + '</em>'; }

	for (const elt of ['title', 'desc'])
	{
		if (EMOJI_RE.test(asset[elt]))
			res.add(new Issue(Feedback.NO_EMOJI, elt));
		else if (TYPOGRAPHY_PUNCT.test(asset[elt]))
		{
			let corrected = asset[elt].replace(/[\u2018\u2019]/g, "'").replace(/[\u201C\u201D]/g, '"');
			res.add(new Issue(Feedback.SPECIAL_CHARS, elt,
				'"Smart" quotes are great for typography, but often don\'t render correctly in emulators<br/>' +
				build_indicated_feedback(asset[elt], TYPOGRAPHY_PUNCT) + ` &xrArr; <code>${corrected}</code>`));
		}
		else if (FOREIGN_RE.test(asset[elt]))
			res.add(new Issue(Feedback.FOREIGN_CHARS, elt,
				build_indicated_feedback(asset[elt], FOREIGN_RE)));
		else if (NON_ASCII_RE.test(asset[elt]))
			res.add(new Issue(Feedback.SPECIAL_CHARS, elt,
				build_indicated_feedback(asset[elt], NON_ASCII_RE)));
	}

	if (/[\{\[\(](.+)[\}\]\)]/.test(asset.desc))
		res.add(new Issue(Feedback.DESC_BRACKETS, 'desc'));

	return res;
}

function assess_achievement(ach)
{
	let res = new Assessment();

	res.combine(assess_writing(ach));
	res.combine(assess_logic(ach.logic));

	return res;
}

function assess_leaderboard(lb)
{
	// assess writing initially
	let res = assess_writing(lb);

	res.combine(assess_logic(lb.components['STA']));

	res.stats.is_instant_submission = lb.components['SUB'].groups.every(g => g.every(req => req.isAlwaysTrue()));
	res.stats.conditional_value = lb.components['VAL'].groups.length > 1 &&
		lb.components['VAL'].groups.every(
			g => 
				g.some(req => req.flag == ReqFlag.MEASUREDIF) && 
				g.some(req => req.flag == ReqFlag.MEASURED || req.flag == ReqFlag.MEASUREDP)
		);

	return res;
}

function assess_code_notes(notes)
{
	let res = new Assessment();

	res.stats.size_counts = new Map();
	res.stats.author_counts = new Map();
	for (const note of notes)
	{
		res.stats.author_counts.set(note.author, 1 + (res.stats.author_counts.get(note.author) || 0));
		if (note.note.trim() == '')
			res.add(new Issue(Feedback.NOTE_EMPTY, note));
		
		if (note.type == null && note.size == 1)
			res.add(new Issue(Feedback.NOTE_NO_SIZE, note));
		else
		{
			let type = note.type ? note.type.name : 'Other';
			res.stats.size_counts.set(type, 1 + (res.stats.size_counts.get(type) || 0));
		}

		// TODO: check enumerated values
	}

	res.stats.notes_count = notes.length;
	let all_addresses = all_achievements().reduce((a, e) => a.concat(e.logic.getAddresses()), []);
	let used_notes = notes.filter(x => all_addresses.some(y => x.contains(y)));

	res.stats.notes_used = used_notes.length;
	res.stats.notes_unused = res.stats.notes_count - res.stats.notes_used;
		
	return res;
}

function assess_rich_presence()
{
	let res = new Assessment();
	if (!current.rp) return res;

	res.stats.mem_length = current.rp.text.length;
	res.stats.custom_macros = new Map([...Object.entries(current.rp.macros)]
		.filter(([k, v]) => current.rp.custom_macros.has(k))
	);
	res.stats.lookups = current.rp.lookups;

	res.stats.display_groups = current.rp.display.length;
	res.stats.cond_display = current.rp.display.filter(x => x.condition != null).length;
	res.stats.max_lookups = Math.max(...current.rp.display.map(x => x.lookups.length));

	if (res.stats.max_lookups == 0 && res.stats.cond_display == 0)
		res.add(new Issue(Feedback.NO_DYNAMIC_RP, null));
	else if (res.stats.cond_display == 0)
		res.add(new Issue(Feedback.NO_CONDITIONAL_DISPLAY, null));

	if (current.notes.length)
		for (const [di, d] of current.rp.display.entries())
		{
			if (d.condition != null)
				for (const x of missing_notes(d.condition))
					res.add(new Issue(Feedback.MISSING_NOTE_RP, null,
						`Missing note for condition of display #${di+1}: <code>0x${x.addr.padStart(8, '0')}</code>`));
			for (const [li, look] of d.lookups.entries())
				for (const x of missing_notes(look.calc))
					res.add(new Issue(Feedback.MISSING_NOTE_RP, null,
						`Missing note for ${look.name} lookup of display #${di+1}: <code>0x${x.addr.padStart(8, '0')}</code>`));
		}

	return res;
}

function assess_set()
{
	let res = new Assessment();
	const achievements = all_achievements();
	const achfeedback = [...current.assessment.achievements.values()];

	// counts of achievement types
	res.stats.achievement_count = achievements.length;
	let achstate = res.stats.achievement_state = new Map(Object.values(AssetState).map(x => [x, 0]));
	for (const ach of achievements) achstate.set(ach.state, achstate.get(ach.state) + 1);

	let achtype = res.stats.achievement_type = new Map(['', 'progression', 'win_condition', 'missable'].map(x => [x, []]));
	for (const ach of achievements) achtype.get(ach.achtype || '').push(ach);

	// reflect an issue if achievement typing hasn't been added
	if (achtype.get('win_condition').length == 0 && achtype.get('progression').length == 0)
		res.add(new Issue(Feedback.NO_TYPING, null));
	else if (achtype.get('progression').length == 0)
		res.add(new Issue(Feedback.NO_PROGRESSION, null));
	
	// points total and average
	res.stats.total_points = achievements.reduce((a, e) => a + e.points, 0);
	res.stats.avg_points = res.stats.total_points / res.stats.achievement_count;

	// all components used across all achievements
	res.stats.all_flags = achfeedback.reduce((a, e) => a.union(e.stats.unique_flags), new Set());
	res.stats.all_cmps = achfeedback.reduce((a, e) => a.union(e.stats.unique_cmps), new Set());
	res.stats.all_sizes = achfeedback.reduce((a, e) => a.union(e.stats.unique_sizes), new Set());

	// number of achievements using bit operations, such as BitX and BitCount
	res.stats.using_bit_ops = achievements.filter(x => new Set(x.logic.getMemSizes()).intersection(BitProficiency).size > 0);

	// number of achievements using each feature
	res.stats.using_alt_groups = achievements.filter(x => current.assessment.achievements.get(x.id).stats.alt_groups > 0);
	res.stats.using_delta = achievements.filter(x => { const s = current.assessment.achievements.get(x.id).stats; return s.deltas + s.priors > 0; });
	res.stats.using_hitcounts = achievements.filter(x => current.assessment.achievements.get(x.id).stats.hit_counts_many > 0);
	res.stats.using_checkpoint_hits = achievements.filter(x => current.assessment.achievements.get(x.id).stats.hit_counts_one > 0);
	res.stats.using_pauselock = achievements.filter(x => current.assessment.achievements.get(x.id).stats.pause_locks > 0);
	res.stats.using_pauselock_alt_reset = achievements.filter(x => current.assessment.achievements.get(x.id).stats.pause_lock_alt_reset > 0);

	// count of achievements using each flag type
	res.stats.using_flag = new Map(Object.values(ReqFlag).map(x => [x, 0]));
	for (const ach of achievements)
		for (const flag of current.assessment.achievements.get(ach.id).stats.unique_flags)
			res.stats.using_flag.set(flag, res.stats.using_flag.get(flag) + 1);

	return res;
}