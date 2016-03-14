#!/bin/bash



# AA TODO: currently this in an alias so you have to source this script or put it in your .bashrc
alias vimtohtml='vim -c ":argdo set eventignore-=Syntax | if &filetype != \"\" | TOhtml | endif | wq" -c "wqa"'
