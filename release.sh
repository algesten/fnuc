#!/bin/sh

step="minor"

npm version "${step}"
npm publish
git add lib
git ci -m 'compile new version'
# remove tag again since bower will set it.
v=`grep version package.json | awk -F '\"' '{print $4}'`
git tag -d "v${v}"
bower version "${step}"
git push origin
git push origin --tags
