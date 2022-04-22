#!/bin/bash

domain="puremail.cyou"
repo="deploy"
branch="gh-pages"

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

if [[ -d "resources" ]]
then
  echo "Deleting old resources..."
  rm -rf resources
fi

if [[ -d "_site" ]]
then
  echo "Deleting old publication..."
  rm -rf _site
fi

mkdir _site

if [[ -d ".git/worktrees/_site/" ]]
then
  echo "Delating .git/worktrees/_site/"
  git worktree prune
  git worktree remove -f _site
  rm -rf .git/worktrees/_site/
fi

if [[ `git br|grep $branch` ]]
then
  git br -D $branch
fi

echo "Checking out $branch branch into public..."
git worktree add -b $branch _site $repo/$branch

rm -rf _site/*

set -e

# echo "Cleaning up the environment..."
# yarn clean

# echo "Generating site (minified HTML)"
# hugo --minify --cleanDestinationDir --gc

# echo "Generating site (minified HTML)..."
# npm run build:prod:clean

echo "Generating site..."
npm run build

cd _site

if [[ -n $domain ]]
then
  echo "Adding CNAME"
  echo $domain > CNAME
  touch .nojekyll
fi

# paths=("${(@f)$(find . -name '_*')}")
# unset 'paths[-1]'

# include=""

# for i ("$paths[@]") include="$include,\"$i\""

# includes="includes: [$include]"
# include="include: [$include]"

# echo $include > _config.yml
# echo $includes >> _config.yml

echo "Updating $branch branch"
git add --all && git commit --allow-empty -m "Publishing to $branch" && git push -f $repo $branch

cd ..

# rm -f .hugo_build.lock
