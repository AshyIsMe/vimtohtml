#!/bin/bash

# AA TODO: currently this in an alias so you have to source this script or put it in your .bashrc
#alias vimtohtml='vim -c ":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | wq" -c "wqa"'

set -e

## Render a whole directory out to HTML with vim's :TOhtml command
## Usage: vimtohtml.sh [options]
##
##       [-h     | --help]     Print this help message
##       [-c colorscheme | --colorscheme colorscheme]  Use the specified colourscheme
##       [-b arg | --bar arg]  Bars the baz

BASE=$(cd $(dirname $0); pwd -P)

usage() {
   echo "$(grep "^## " "${BASH_SOURCE[0]}" | cut -c 4-)"
   exit 0
}

error() {
   cat <<< "$@" 1>&2
   exit 1
}

[[ $# == 0 ]] && usage

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    "--colorscheme")  set -- "$@" "-c" ;;
    "--bar")  set -- "$@" "-b" ;;
    *)        set -- "$@" "$arg"
  esac
done
# Parse short options
OPTIND=1
while getopts "hc:b:" opt
do
  case "$opt" in
    "h") usage; exit 0 ;;
    "c") COLORSCHEME="-c \":colorscheme $OPTARG\"" ;;
    "b") BAR="$OPTARG" ;;
    "?") usage >&2; exit 1 ;;
    ":") error "Option -$OPTARG requires an argument.";;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

#ARGDOCOMMAND="-c ':argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | wq' -c 'wqa'"

ARGS=$@

if [[ -n "$COLORSCHEME" ]]; then
   echo "COLORSCHEME: $COLORSCHEME"
fi
if [[ -n "$BAR" ]]; then
   echo "BAR: $BAR"
fi

echo "Rest of the args were: $ARGS"

##echo "$COLORSCHEME" -c "\":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | wq' -c 'wqa'\"" "$ARGS"
#vim "$COLORSCHEME" -c ":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | wq" -c "wqa" $ARGS

## Try to handle directories properly
##vim "$COLORSCHEME" -c ":argdo set eventignore-=Syntax | if &filetype == \"netrw\" | TOhtml | w %:t/testing.html | else | if &filetype != \"\" | TOhtml | endif | endif | wq" -c "wqa" $ARGS


for f in $ARGS
do
  if [ -d "$f" ]
  then
    cd "$f"
    OUTPUTDIR=$(pwd)_TOhtml
    echo "mkdir $OUTPUTDIR"
    mkdir "$OUTPUTDIR"

    FILES=$(ls -p $f | grep -v /)
    vim "$COLORSCHEME" -c ":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | w $OUTPUTDIR/%:t | q" -c "qa!" $FILES

  elif [ -f "$f" ]
  then
    OUTPUTDIR=$(pwd)
    vim "$COLORSCHEME" -c ":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | w $OUTPUTDIR/%:t | q" -c "qa!" "$f"
  fi
done
