#!/bin/sh

npm run-script version
git add lib
git ci -m 'compile new version'
npm version patch
