setlocal errorformat=%f:%l:\ %m,%f:%l-%\\d%\\+:\ %m
if filereadable('Makefile')
  setlocal makeprg=make
else
  exec "setlocal makeprg=make\\ -f\\ ~/scripts/make/latex.mk\\ " . substitute(bufname("%"),"tex$","pdf", "")
endif

setlocal spelllang=en_us spell
setlocal indentexpr=

setlocal tw=100
