# Run vim's :TOhtml command on a whole directory

Github is horrible to read on a tablet in chrome.
There's a horizontal scrolling bug, the colours are terrible and the font becomes tiny for some reason.

Vim in a terminal emulator is pretty good but it's not great for lazy code reading in bed.
Hence this little tool.



## Usage
```
$ git clone https://github.com/antirez/redis    #Grab a sweet codebase to read
$ vimtohtml redis

$ find redis_TOhtml   #All files have been rendered to html with vim's syntax highlighting
```
