
const fs = require('fs');
const vm = require('vm');
const path = require('path');
const React = require('react');

const logicPath = path.resolve(__dirname, './js/logic.js');
const achievementsPath = path.resolve(__dirname, './js/achievements.js');
const feedbackPath = path.resolve(__dirname, './feedback.transpiled.js');
const overviewPath = path.resolve(__dirname, './overview.transpiled.js');
const logicContent = fs.readFileSync(logicPath, 'utf8');
const scriptContent = fs.readFileSync(achievementsPath, 'utf8');
const feedbackContent = fs.readFileSync(feedbackPath, 'utf8');
const overviewContent = fs.readFileSync(overviewPath, 'utf8');
const sandbox = {};
vm.createContext(sandbox);
const combinedContent = `${logicContent}\n${scriptContent}`;
vm.runInContext(combinedContent, sandbox);
vm.runInContext(feedbackContent, sandbox);
vm.runInContext(overviewContent, sandbox);
// vm.runInContext(logicContent, sandbox);
// vm.runInContext(scriptContent, sandbox);

sandbox.reset_loaded()
sandbox.React = React
sandbox.console = console

//console.log(Object.keys(sandbox));

//let data = JSON.parse(event.target.result);
//set = AchievementSet.fromJSON(json);

// Parse command-line arguments
const args = process.argv.slice(2);
if (args.length < 1) {
console.error("Usage: node cli-tool.js <input-file>");
process.exit(1);
}

function clearSelected()
{
    console.log("clearSelected called");
}

function isIterable(obj) {
    // checks for null and undefined
    if (obj == null) {
        return false;
    }
    return typeof obj[Symbol.iterator] === 'function';
}

origUpdate = sandbox.update

function digin(obj) {
    let result = "";
    // console.log(typeof obj)
    if (!isIterable(obj)) {
        if (typeof obj.props.children == "undefined")
            return "" + obj.props;
        return "" + digin(obj.props.children)
    }
    for (let p of obj) {
        if (typeof p == "object") {
            if (result != "") {
                result += " ";
            }
            if (p.props != null) {
                result += digin(p.props.children)
            }
        } else {
            result += p;
        }
    }
    return result;
}

function find(haystack, needle)
{
    for (let entry of haystack) {
        if (entry.id == needle) {
            return entry;
        }
    }
    return null
}

function reportAssessment(id, assessment, all)
{
    if (assessment.issues.length == 0) {
        return;
    }
    entry = find(all, id)
    title = ""
    if (entry != null) {
        title = entry.title;
    }
    console.log("Issues in " +id + " " + title);
    for (let issue of assessment.issues) {
        console.log(issue.type.desc);
        if (issue.detail != null) {
            // console.log(issue.detail);
            let result = digin(issue.detail.props.children);
            console.log(result);
        }
    }
}
var filesRead = 0;
function report() {
    console.log("status: " + sandbox.SEVERITY_TO_CLASS[sandbox.current.assessment.set.status()])
    let achievements = sandbox.all_achievements();
    for (let entry of sandbox.current.assessment.achievements) {
        reportAssessment(entry[0], entry[1], achievements)
    }
    let leaderboards = sandbox.all_leaderboards();
    for (let entry of sandbox.current.assessment.leaderboards) {
        reportAssessment(entry[0], entry[1], leaderboards)
    }
    reportAssessment("Notes", sandbox.current.assessment.notes, [])
    reportAssessment("RP", sandbox.current.assessment.rp, [])
    reportAssessment("Set", sandbox.current.assessment.set, [])
}
function update()
{
    origUpdate()
    if (filesRead == args.length) {
        report();
    }
}
sandbox.update = update

for (i = 0; i < args.length; i++) {
    const inputFile = args[i];
    fs.readFile(inputFile, 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading file: ${err.message}`);
            process.exit(1);
        }
        try {
            // Process the file content
            if (inputFile.endsWith('-Notes.json')) {
                filesRead++;
                sandbox.load_code_notes(JSON.parse(data))
            }
            else if (inputFile.endsWith('.json')) {
                filesRead++;
                sandbox.load_achievement_set(JSON.parse(data));
            }
            else if (inputFile.endsWith('-Rich.txt')) {
                filesRead++;
                sandbox.load_rich_presence(data, true);
            }
            else if (inputFile.endsWith('-User.txt')) {
                filesRead++;
                sandbox.load_user_file(data);
            }
        } catch (err) {
            console.error(`Error processing file: ${err.message}`);
        }
    });
}

