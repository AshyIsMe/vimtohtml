# Run vim's :TOhtml command on a whole directory

Github is horrible to read on a tablet in chrome.
There's a horizontal scrolling bug, the colours are terrible and the font becomes tiny for some reason.

Vim in a terminal emulator is pretty good but it's not great for lazy code reading in bed.
Hence this little tool.



## Usage
```
$ cd src
$ vimtohtml *.c

$ open *.html
```


# TODO

## Intended Usage
```
# Grab a sweet codebase to read
$ git clone https://github.com/antirez/redis
$ cd redis

# Run vimtohtml in the directory and wait for it to finish
$ vimtohtml .

# Now open the index in your favourite browser and browse away with your favourite vim colorscheme embedded!
$ open index.html

```
