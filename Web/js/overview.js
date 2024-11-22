var current = { id: -1, };
function reset_loaded()
{
	current.set = null;
	current.local = null;
	current.notes = [];
	current.assessment = { pass: true, };
}
var assetList = [];

function __noop(event)
{
	event.stopPropagation();
	event.preventDefault();
}

document.ondragover = __noop;
document.ondragenter = __noop;

document.ondrop = function(event)
{
	event.preventDefault();
	for (const file of event.dataTransfer.files)
	{
		let idregex = file.name.match(/^(\d+)/);
		let thisid = +idregex[1] || -1;
		if (thisid != current.id)
		{
			current.id = thisid;
			reset_loaded();
		}
		
		let reader = new FileReader();
		if (file.name.endsWith('-Notes.json'))
			reader.onload = function(event)
			{
				let data = JSON.parse(event.target.result);
				load_code_notes(data);
			};
		else if (file.name.endsWith('.json'))
			reader.onload = function(event)
			{
				let data = JSON.parse(event.target.result);
				load_achievement_set(data);
			};
		else if (file.name.endsWith('-Rich.txt'))
			reader.onload = function(event)
			{
				// would prefer to get the Rich Presence from the RichPresencePatch in the json!
				let data = event.target.result;
				// load_rich_presence(data);
			};
		else if (file.name.endsWith('-User.txt'))
			reader.onload = function(event)
			{
				let data = event.target.result;
				load_user_file(data);
			};
		reader.readAsText(file);
	}
}

function get_note(v)
{
	let addr = +v, note = null;
	for (const cn of current.notes || [])
		if (cn.contains(addr)) note = cn;
	if (!note) return null;

	let note_text = "";
	let relevant_text = note.note;
	if (addr != note.addr)
	{
		let base = '0x' + note.addr.toString(16).padStart(8, '0');
		let offset = '0x' + (addr - note.addr).toString(16);
		note_text += `[Indirect ${base} + ${offset}]\n`;
	}
	note_text += relevant_text;
	return note_text;
}

function make_logic_table(logic, assessment = [], grouplabel = (i) => i == 0 ? "Core Group" : `Alt Group ${i}`)
{
	let logictbl = document.createElement('table');
	let logicbody = document.createElement('tbody');

	for (const [gi, g] of logic.groups.entries())
	{
		const HEADERS = ["id", "Flag", "Type", "Size", "Mem/Val", "Cmp", "Type", "Size", "Mem/Val", "Hits"];

		// name the group
		let titlerow = document.createElement('tr');
		titlerow.classList.add('group-hdr', 'header')
		let titlecell = document.createElement('td');
		titlecell.appendChild(document.createTextNode(grouplabel(gi)));
		titlecell.setAttribute('colspan', HEADERS.length);
		titlerow.appendChild(titlecell);
		logicbody.appendChild(titlerow);

		// column headers
		let hdrrow = document.createElement('tr');
		hdrrow.classList.add('col-hdr', 'header')
		for (const hdr of HEADERS)
		{
			let td = document.createElement('td');
			td.appendChild(document.createTextNode(hdr));
			hdrrow.appendChild(td);
		}
		logicbody.appendChild(hdrrow);

		for (const [ri, req] of g.entries())
		{
			let reqrow = document.createElement('tr');
			for (const issue of assessment)
				if (issue.target == req) reqrow.classList.add('warn');
			let reqdata = ["", "", "", "", "", "", "", "", "", ""];

			reqdata[0] = "" + (ri + 1);
			if (req.flag) reqdata[1] = req.flag.name;
			reqdata[2] = req.lhs.type.name;
			if (req.lhs.size) reqdata[3] = req.lhs.size.name;
			reqdata[4] = req.lhs.type.addr ? ('0x' + req.lhs.value.padStart(8, '0')) : req.lhs.value;
			if (req.op && req.rhs)
			{
				reqdata[5] = req.op;
				reqdata[6] = req.rhs.type.name;
				if (req.rhs.size) reqdata[7] = req.rhs.size.name;
				reqdata[8] = req.rhs.type.addr ? ('0x' + req.rhs.value.padStart(8, '0')) : req.rhs.value;
				if (!req.flag || req.flag.hits) reqdata[9] = "(" + req.hits + ")";
			}

			for (const v of reqdata)
			{
				let td = document.createElement('td');
				let span = td.appendChild(document.createElement('span'));
				span.appendChild(document.createTextNode(v));
				if (typeof v === 'string' && v.startsWith('0x'))
				{
					let note = get_note(v);
					if (note)
					{
						span.classList.add('tooltip');
						let tooltip = span.appendChild(document.createElement('span'));
						tooltip.classList.add('tooltip-info');
						let pre = tooltip.appendChild(document.createElement('pre'));
						pre.appendChild(document.createTextNode(note));
					}
				}
				reqrow.appendChild(td);
			}
			logicbody.appendChild(reqrow);
		}
	}
	logictbl.appendChild(logicbody);
	return logictbl;
}

function load_achievement(ach, row)
{
	let feedback = current.assessment.achievements.get(ach.id);
	let feedback_targets = new Set(feedback.issues.map(x => x.target));

	let elts = [];
	let infobox = document.createElement('div');
	elts.push(infobox);

	if (ach.badge)
	{
		let achlink = infobox.appendChild(document.createElement('a'));
		achlink.setAttribute('href', `https://retroachievements.org/achievement/${ach.id}`);
		let badge = achlink.appendChild(document.createElement('img'));
		badge.classList.add('icon');
		badge.setAttribute('src', ach.badge);
	}

	let header = infobox.appendChild(document.createElement('h2'));
	let title_mod = ach.title;
	if (feedback_targets.has('title'))
		title_mod = `<span class="warn">${title_mod}</span>`;
	header.innerHTML = `🏆 ${title_mod} (${ach.points})`;
	header.classList.add('ach-title');

	let labels = [];
	if (ach.state) labels.push(ach.state.name);
	if (ach.achtype) labels.push(ach.achtype);

	if (labels.length)
	{
		let labeldiv = infobox.appendChild(document.createElement('div'));
		labeldiv.classList.add('ach-label');

		let label = labeldiv.appendChild(document.createElement('em'));
		label.appendChild(document.createTextNode(`[${labels.join(', ')}]`));
	}

	let desc = infobox.appendChild(document.createElement('p'));
	let desc_mod = ach.desc;
	if (feedback_targets.has('desc'))
		desc_mod = `<span class="warn">${desc_mod}</span>`;
	desc.innerHTML = desc_mod;
	desc.classList.add('ach-desc');

	let logicdiv = document.createElement('div');
	logicdiv.classList.add('data-table');
	logicdiv.appendChild(make_logic_table(ach.logic, feedback.issues));
	elts.push(logicdiv);

	let feedbackdiv = document.createElement('div');
	feedbackdiv.classList.add('feedback');
	elts.push(feedbackdiv);

	feedbackdiv.appendChild(document.createElement('h1'))
		.appendChild(document.createTextNode('Feedback'));

	function make_issue_list_entry(issue)
	{
		let text = issue.type.desc;
		for (const ref of issue.type.ref)
			text += ` <sup>[<a href="${ref}">ref</a>]</sup>`;
		if (issue.detail) text += "<br/>" + issue.detail;
		return text;
	}

	let cissues;
	cissues = feedback.issues.filter(x => ['title', 'desc'].includes(x.target));
	if (cissues.length > 0)
	{
		feedbackdiv.appendChild(document.createElement('h2'))
			.appendChild(document.createTextNode('Presentation & Writing'));
		let ul = feedbackdiv.appendChild(document.createElement('ul'));
		for (const issue of cissues)
		{
			let li = ul.appendChild(document.createElement('li'));
			li.innerHTML = make_issue_list_entry(issue);
		}
	}

	cissues = feedback.issues.filter(x => !['title', 'desc'].includes(x.target));
	if (cissues.length > 0)
	{
		feedbackdiv.appendChild(document.createElement('h2'))
			.appendChild(document.createTextNode('Logic & Design'));
		let ul = feedbackdiv.appendChild(document.createElement('ul'));
		for (const issue of cissues)
		{
			let li = ul.appendChild(document.createElement('li'));
			li.innerHTML = make_issue_list_entry(issue);
		}
	}

	document.getElementById('info-container').replaceChildren(...elts);
	document.getElementById('asset-info').scrollTop = 0;
	select_row(row);
}

function load_leaderboard(lb, row)
{
	let elts = [];
	let infobox = document.createElement('div');
	infobox.classList.add('main-header');
	elts.push(infobox);

	if (current.set && current.set.icon)
	{
		let badge = infobox.appendChild(document.createElement('img'));
		badge.classList.add('icon');
		badge.setAttribute('src', current.set.icon);
	}

	let header = infobox.appendChild(document.createElement('h2'));
	header.appendChild(document.createTextNode(`📊 ${lb.title}`));
	header.classList.add('ach-title');

	let labels = [];
	if (lb.state) labels.push(lb.state.name);

	if (labels.length)
	{
		let labeldiv = infobox.appendChild(document.createElement('div'));
		labeldiv.classList.add('ach-label');

		let label = labeldiv.appendChild(document.createElement('em'));
		label.appendChild(document.createTextNode(`[${labels.join(', ')}]`));
	}

	let desc = infobox.appendChild(document.createElement('p'));
	desc.appendChild(document.createTextNode(lb.desc));
	desc.classList.add('ach-desc');

	let logicdiv = document.createElement('div');
	logicdiv.classList.add('data-table');
	logicdiv.appendChild(document.createElement('h3')).appendChild(document.createTextNode("START"));
	logicdiv.appendChild(make_logic_table(lb.components['STA']));
	logicdiv.appendChild(document.createElement('h3')).appendChild(document.createTextNode("CANCEL"));
	logicdiv.appendChild(make_logic_table(lb.components['CAN']));
	logicdiv.appendChild(document.createElement('h3')).appendChild(document.createTextNode("SUBMIT"));
	logicdiv.appendChild(make_logic_table(lb.components['SUB']));
	logicdiv.appendChild(document.createElement('h3')).appendChild(document.createTextNode("VALUE"));
	logicdiv.appendChild(make_logic_table(lb.components['VAL'], [], (i) => `Value Group ${i+1}`));
	elts.push(logicdiv);

	document.getElementById('info-container').replaceChildren(...elts);
	document.getElementById('asset-info').scrollTop = 0;
	select_row(row);
}

function load_overview(sidebar)
{
	if (current.set == null) return;
	let elts = [];

	let badge = document.createElement('img');
	badge.classList.add('icon');
	badge.setAttribute('src', current.set.icon);
	elts.push(badge);

	let header = document.createElement('h1');
	header.appendChild(document.createTextNode(current.set.title));
	elts.push(header);

	document.getElementById('info-container').replaceChildren(...elts);
	document.getElementById('asset-info').scrollTop = 0;
	select_row(sidebar);
}

function load_code_notes_overview(sidebar)
{
	if (current.notes == null) return;
	let elts = [];

	let infobox = document.createElement('div');
	infobox.classList.add('main-header');
	elts.push(infobox);

	let header;
	if (current.set != null)
	{
		let anchor = infobox.appendChild(document.createElement('a'));
		anchor.setAttribute('href', `https://retroachievements.org/codenotes.php?g=${current.id}`);
		let badge = anchor.appendChild(document.createElement('img'));
		badge.classList.add('icon');
		badge.setAttribute('src', current.set.icon);

		header = infobox.appendChild(document.createElement('h1'));
		header.appendChild(document.createTextNode(current.set.title));
	}

	let authors = new Set(current.notes.map(x => x.author));
	infobox.appendChild(document.createElement('p'))
		.innerHTML = `There are <a href="https://retroachievements.org/codenotes.php?g=${current.id}">${current.notes.length} code notes</a> by ${authors.size} author(s): ${[...authors].join(', ')}`;
	if (!current.assessment.notes.pass())
		infobox.appendChild(document.createElement('p'))
			.appendChild(document.createTextNode(`⚠️ There are ${current.assessment.notes.issues.length} issues to resolve`));

	const HEADERS = ['Address', 'Note', 'Author'];
	let tablediv = document.createElement('div');
	tablediv.classList.add('data-table');
	let table = tablediv.appendChild(document.createElement('table'));
	table.classList.add('code-notes');

	let tblhdr = table.appendChild(document.createElement('thead'));
	let titlerow = tblhdr.appendChild(document.createElement('tr'));
	titlerow.classList.add('group-hdr', 'header')
	let titlecell = titlerow.appendChild(document.createElement('td'));
	titlecell.appendChild(document.createTextNode("Code Notes"));
	titlecell.setAttribute('colspan', HEADERS.length);
	let hdrrow = tblhdr.appendChild(document.createElement('tr'));
	for (const hdr of HEADERS)
		hdrrow.appendChild(document.createElement('td')).appendChild(document.createTextNode(hdr));

	let tbody = table.appendChild(document.createElement('tbody'));
	for (const note of current.notes)
	{
		let row = ["", "", ""];
		let addrinfo = '0x' + note.addr.toString(16).padStart(8, '0');
		if (note.size > 8) addrinfo += ' - ' + '0x' + (note.addr + note.size - 1).toString(16).padStart(8, '0');

		let tr = tbody.appendChild(document.createElement('tr'));
		tr.appendChild(document.createElement('td')).appendChild(document.createTextNode(addrinfo));
		tr.appendChild(document.createElement('td'))
			.appendChild(document.createElement('pre'))
			.appendChild(document.createTextNode(note.note));

		for (const issue of current.assessment.notes.issues)
			if (issue.target == note)
				tr.classList.add('warn');
		
		let author = tr.appendChild(document.createElement('td'));
		let tt = author.appendChild(document.createElement('span'));
		tt.classList.add('tooltip');
		let anchor = tt.appendChild(document.createElement('a'));
		anchor.setAttribute('href', `https://retroachievements.org/user/${note.author}`);
		let img = anchor.appendChild(document.createElement('img'))
		img.setAttribute('src', `https://media.retroachievements.org/UserPic/${note.author}.png`);
		img.setAttribute('width', 24);
		img.setAttribute('height', 24);
		let ttinfo = tt.appendChild(document.createElement('span'));
		ttinfo.classList.add('tooltip-info');
		ttinfo.appendChild(document.createTextNode(note.author));
	}
	elts.push(tablediv);

	document.getElementById('info-container').replaceChildren(...elts);
	document.getElementById('asset-info').scrollTop = 0;
	select_row(sidebar);
}

function add_asset_row(type, asset_name, callback = null)
{
	let tr = document.createElement('tr');
	tr.classList.add(type)

	let td_asset_name = document.createElement('td');
	td_asset_name.classList.add('asset-name');
	td_asset_name.appendChild(document.createTextNode(asset_name));
	tr.appendChild(td_asset_name);

	tr.onclick = callback;
	return tr;
}

function select_row(row)
{
	for (let tr of document.getElementById('list-body').children)
		tr.classList.remove('selected');
	row.classList.add('selected');
}

function all_achievements()
{
	let res = [];
	if (current.set  ) res = res.concat(current.set.achievements);
	if (current.local) res = res.concat(current.local.achievements);
	return res;
}

function all_leaderboards()
{
	let res = [];
	if (current.set  ) res = res.concat(current.set.leaderboards);
	if (current.local) res = res.concat(current.local.leaderboards);
	return res;
}

function update_assessment()
{
	current.assessment.achievements = new Map(all_achievements().map(x => [x.id, assess_achievement(x)]));
	current.assessment.leaderboards = new Map(all_leaderboards().map(x => [x.id, assess_leaderboard(x)]));
}

function load_achievement_set(json)
{
	current.set = AchievementSet.fromJSON(json);
	update_assessment();

	for (const jach of json.Achievements)
		if (current.assessment.achievements.has(jach.ID))
			current.assessment.achievements.get(jach.ID).mem_length = jach.MemAddr.length;
	rebuild_sidebar();
}

function load_user_file(txt)
{
	current.local = AchievementSet.fromLocal(txt);
	current.local.id = current.id;
	update_assessment();

	rebuild_sidebar();
}

function load_code_notes(json)
{
	current.notes = [];
	for (const obj of json)
		if (obj.Note)
			current.notes.push(new CodeNote(obj.Address, obj.Note, obj.User));

	current.assessment.notes = assess_code_notes(current.notes);
	if (current.set) // update the achievement assessments because there are some code note verification checks
		current.assessment.achievements = new Map(current.set.achievements.map(x => [x.id, assess_achievement(x)]));
	rebuild_sidebar();
}

function rebuild_sidebar()
{
	let header;
	assetList = [];
	let post_load = null;

	if (current.set != null)
	{
		let overview_row = add_asset_row('info', "🔍 Set Overview");
		overview_row.onclick = function(){ load_overview(overview_row); };
		if (!post_load) post_load = overview_row.onclick;
		assetList.push(overview_row);
	}

	if (current.notes.length > 0)
	{
		let code_notes_row = add_asset_row('info', "📝 Code Notes");
		code_notes_row.onclick = function(){ load_code_notes_overview(code_notes_row); };
		if (!post_load) post_load = code_notes_row.onclick;
		assetList.push(code_notes_row);
	}
	
	if (current.set != null || current.local != null)
	{
		header = document.createElement('tr');
		header.classList.add("asset-header");
		header.appendChild(document.createElement('td')).appendChild(document.createTextNode("Achievements"));
		assetList.push(header);

		for (const ach of all_achievements().sort((a, b) => a.state.rank - b.state.rank))
		{
			let feedback = current.assessment.achievements.get(ach.id);
			let tr = add_asset_row(feedback.pass() ? 'pass' : 'fail', `🏆 ${ach.state.marker}${ach.title} (${ach.points})`);
			tr.onclick = function(){ load_achievement(ach, tr); };
			assetList.push(tr);

			// preload image
			let img = new Image();
			img.src = ach.badge;
		}

		header = document.createElement('tr');
		header.classList.add("asset-header");
		header.appendChild(document.createElement('td')).appendChild(document.createTextNode("Leaderboards"));
		assetList.push(header);

		for (const lb of all_leaderboards().sort((a, b) => a.state.rank - b.state.rank))
		{
			let feedback = current.assessment.leaderboards.get(lb.id);
			let tr = add_asset_row(feedback.pass() ? 'pass' : 'fail', `📊 ${lb.state.marker}${lb.title}`);
			tr.onclick = function(){ load_leaderboard(lb, tr); };
			assetList.push(tr);
		}
	}

	document.getElementById('list-body').replaceChildren(...assetList);
	if (document.querySelectorAll('.list-body .selected').length == 0 && post_load) post_load();
}