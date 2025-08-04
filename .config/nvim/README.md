## This is me writing some mental notes for using NVIM

### Inserting!

`i` = insert before letter
`I` = insert at start of line
`a` = insert after letter
`A` = insert after line! <--- Super useful
`o` = insert line after
`O` = insert line before

### Replacing!

`r` = replace one letter
`R` = Replace a whole bunch of letters!

### Movement!

`hjkl` = Move around the slow way
`23j` = down 23 lines
`/` = find a word after cursor
`?` = find a word before the cursor
`n` = next occurance
`N` = previous occurance
`f` = find a letter in the current line after cursor i.e. `fX` to find X
`F` = find a letter in the current line before the cursor

### Cool stuff!

`:w <NAME>` = Save to file. You can also select text and save the selected text to file
`:r <FILE>` = insert file contents at cursor!
`<CTR-r>=60*60` = Expression mode! While inserting, type Ctr-r = to add an expression and insert result

### Copy paste!

`y` = 'yank' some text (AKA copy)
`yy` = yank the current line
`p` = put the yanked text somewhere
`P` = put before the cursor

-- Advanced Copy Paste
`yiw` = yank word from anywhere within the word
`"ayiw` = into register(") named (a) (y)ank (i)nner (w)ord
`ciw<CTR-r>a<ESC>` = (c)hange (i)nner (w)ord with <contents of (r)egister> named (a)
`:reg` = inspect registers
`"dp` = paste content from register d
`ma` = mark a line "a"
`"ad'a` = delete the block between cursor and marker "a" into register "a"

### Searching!

`/` = searches stuff, yeah cool
`:s/{foo}/{bar}` = replaces foo with bar
`:s/{foo}/{bar}/g` = replaces foo with bar across whole line
`:%s/{foo}/{bar}` = replaces foo with bar across whole file!

### Search options:

`:set hls` = Set hlsearch which highlights the search term in the doc
`:set nohls` = Disable hlsearch
`:set is` = Set Incremental search which shows matches as you type
`:set nois` = Disable Incremental Search
`:set ic` = Ignore case
`:noh` = No highlight, disables the highlight for the current search
Note. Prepend no to turn off. prepend inv to invert
