# Twitter bot posting new archaeology papers that include R code

[![.github/workflows/archaepaperswithcode.yml](https://github.com/benmarwick/archaepaperswithcode/actions/workflows/archaepaperswithcode.yml/badge.svg)](https://github.com/benmarwick/archaepaperswithcode/actions/workflows/archaepaperswithcode.yml)

This twitter bot runs from a simple R script. When there is an update to our list of archaeology papers with R code https://github.com/benmarwick/ctv-archaeology#publications-that-include-r-code, the script here posts a tweet with details of the new paper. 

The bot tweets at https://twitter.com/archpaperscode

## How this works

When an update is made to https://github.com/benmarwick/ctv-archaeology#publications-that-include-r-code, [GitHub Actions](https://github.com/benmarwick/ctv-archaeology/blob/master/.github/workflows/main.yml) runs on that repository and triggers a run of [GitHub Actions](https://github.com/benmarwick/archaepaperswithcode/blob/main/.github/workflows/archaepaperswithcode.yml) on this repository. GitHub Actions runs the R code in the [script file](https://github.com/benmarwick/archaepaperswithcode/blob/main/archaepaperswithcode.R) on this repository, which analyses the [commit history of the repo with the list of papers](https://github.com/benmarwick/ctv-archaeology/commits/master), extracts the text that was just added, and composes and posts a tweet with that text.

To post to Twitter from  GitHub Actions, the [Twitter App](https://developer.twitter.com/en/portal/projects/1525591587522084864/apps/24274200/settings) needs to be generated with elevated access to the V2 API (read and write) - apply for access from essential after generation. Once you have set up the twitter account, you need to set the 4 keys referred to in the R script as secrets in the [github repo settings](https://github.com/benmarwick/archaepaperswithcode/settings/secrets/actions). 

## License

MIT for code 
