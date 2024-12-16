
all: feedback.transpiled.js overview.transpiled.js

feedback.transpiled.js: js/feedback.js
	npx babel $< --out-file $@

overview.transpiled.js: js/overview.js
	npx babel $< --out-file $@
