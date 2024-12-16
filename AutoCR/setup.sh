#!/bin/sh

npm install --save-dev @babel/core @babel/cli @babel/preset-react
npm install ink react

npx babel js/feedback.js --out-file feedback.transpiled.js
npx babel js/overview.js --out-file overview.transpiled.js

