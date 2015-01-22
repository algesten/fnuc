#!/bin/sh

npm run-script compile
git add lib
git ci -m 'compile new version'
npm version patch
