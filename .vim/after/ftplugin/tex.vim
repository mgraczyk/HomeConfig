setlocal errorformat=%f:%l:\ %m,%f:%l-%\\d%\\+:\ %m
if filereadable('Makefile')
  setlocal makeprg=make
else
  exec "setlocal makeprg=make\\ -f\\ ~/scripts/make/latex.mk\\ " . substitute(bufname("%"),"tex$","pdf", "")
endif

setlocal spell spelllang=en_us
setlocal indentexpr=

setlocal tw=100
