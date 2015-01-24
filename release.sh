#!/bin/sh

npm run-script compile
git add lib
git ci -m 'compile new version'
npm version patch
bower version patch
git push origin
git push origin --tags
npm publish
