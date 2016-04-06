#!/usr/bin/env bash
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
    "c") COLORSCHEME="--highlight-style=$OPTARG" ;;
    "?") usage >&2; exit 1 ;;
    ":") error "Option -$OPTARG requires an argument.";;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

ARGS=("$@")

#Hashmap of file extensions to language types supported by pandoc
declare -A filetypes
filetypes=(
  ["ada"]="ada"
  ["agda"]="agda"
  ["c"]="c"
  ["clj"]="clojure"
  ["h"]="cpp"
  ["cpp"]="cpp"
  ["cs"]="csharp"
  ["d"]="d"
  ["ex"]="elixir"
  ["exs"]="elixir"
  ["f90"]="fortran"
  ["f95"]="fortran"
  ["f03"]="fortran"
  ["go"]="go"
  ["hs"]="haskell"
  ["idr"]="idris"
  ["java"]="java"
  ["js"]="javascript"
  ["jl"]="julia"
  ["kt"]="kotlin"
  ["lisp"]="lisp"
  ["cl"]="lisp"
  ["m"]="matlab"
  ["mlx"]="matlab"
  ["ml"]="ocaml"
  ["mli"]="ocaml"
  ["pl"]="perl"
  ["php"]="php"
  ["pro"]="prolog" # prolog also uses .pl.  Let's assume perl is more active in the wild...
  ["py"]="python"
  ["r"]="r"
  ["rb"]="ruby"
  ["scala"]="scala"
  ["scm"]="scheme"
  ["ss"]="scheme"
  ["tcl"]="tcl"
  ["lua"]="lua"
)

# Takes a filepath as an argument.
# Read from filepath and surround with markdown code block syntax including pandoc
# language specification and output to stdout
# eg: tomarkdown somefile.c
# => ``` {.c}
#    #include <stdlib.h>
#    ...
#    ```
tomarkdown() {
  local filename=$(basename "$1")
  local extension="${filename##*.}"
  local filename="${filename%.*}"

  local filetype="${filetypes["$extension"]}"

  echo "\`\`\` {.$filetype}"
  cat "$1"
  echo "\`\`\`"
}


for f in "${ARGS[@]}"
do
  if [[ -d "$f" ]]; then
    cd "$f"
    OUTPUTDIR=${PWD##*/}_TOhtml
    mkdir "../$OUTPUTDIR"
    cd -

    find "$f" -type d -not -path "*/.*" | cpio -pdumv "$OUTPUTDIR"  # Clone the directory heirarchy without files

    #AA TODO Process substitution will never work like this because it happens before xargs is called!!
    find "$f" -type f -not -path "*/.*" -print0 | xargs -I {} -0 -o pandoc -f markdown -s "$COLORSCHEME" -o {}".html" <(tomarkdown {})

    #AA TODO: Render some index pages

  elif [[ -f "$f" ]]; then

    OUTPUTDIR=$(pwd)
    #vim "$COLORSCHEME" -c ":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | w $OUTPUTDIR/%:t | q" -c "qa!" "$f"

    tomarkdown "$f" > "$f.md"
    pandoc --from markdown -s "$COLORSCHEME" -o "$f.html" "$f.md"
  fi
done
