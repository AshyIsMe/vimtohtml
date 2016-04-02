#!/bin/bash
set -e

## Render a whole directory out to HTML with vim's :TOhtml command
## Usage: vimtohtml.sh [options]
##
##       [-h     | --help]     Print this help message
##       [-c colorscheme | --colorscheme colorscheme]  Use the specified colourscheme

BASE=$(cd $(dirname $0); pwd -P)

usage() {
   echo "$(grep "^## " "${BASH_SOURCE[0]}" | cut -c 4-)"
   exit 0
}

error() {
   cat <<< "$@" 1>&2
   exit 1
}

#AA TODO: Need a hashmap of file extensions to language types

# Takes a filepath as an argument.
# Read from filepath and surround with markdown code block syntax including pandoc 
# language specification and output to stdout
# eg: tomarkdown somefile.c
# => ``` {.c}
#    #include <stdlib.h>
#    ...
#    ```
tomarkdown() {
  filename=$(basename "$1")
  extension="${filename##*.}"
  filename="${filename%.*}"

  #AA TODO: Finish this function
}

[[ $# == 0 ]] && usage

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    "--colorscheme")  set -- "$@" "-c" ;;
    *)        set -- "$@" "$arg"
  esac
done
# Parse short options
OPTIND=1
while getopts "hc:" opt
do
  case "$opt" in
    "h") usage; exit 0 ;;
    "c") COLORSCHEME="--highlight-style $OPTARG" ;;
    "?") usage >&2; exit 1 ;;
    ":") error "Option -$OPTARG requires an argument.";;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

ARGS=("$@")

if [[ -n "$COLORSCHEME" ]]; then
   echo "COLORSCHEME: $COLORSCHEME"
fi
echo "Rest of the args were:" "${ARGS[@]}"

for f in "${ARGS[@]}"
do
  if [[ -d "$f" ]]; then
    cd "$f"
    OUTPUTDIR=${PWD##*/}_TOhtml
    mkdir "../$OUTPUTDIR"
    cd -

    find "$f" -type d -not -path "*/.*" | cpio -pdumv "$OUTPUTDIR"  # Clone the directory heirarchy without files

    #Open files in vim and call :TOhtml
    #find "$f" -type f -not -path "*/.*" -print0 | xargs -0 -o -n 5 -P 8 vim "$COLORSCHEME" -c ":argdo set eventignore-=Syntax | if &filetype != \"\" && &filetype != \"netrw\"| silent TOhtml | w $OUTPUTDIR/%:. | endif | q" -c "qa!"


    #AA TODO add in the markdown header and footer (``` {.language} ```)
    find "$f" -type f -not -path "*/.*" -print0 | xargs -I sourcefile -0 -o pandoc -f markdown -s "$COLORSCHEME" -o sourcefile".html"

    #AA TODO: Render some index pages

  elif [[ -f "$f" ]]; then

    OUTPUTDIR=$(pwd)
    vim "$COLORSCHEME" -c ":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | w $OUTPUTDIR/%:t | q" -c "qa!" "$f"
  fi
done