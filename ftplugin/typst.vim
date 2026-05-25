" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

compiler typst

" " If you're on typst <v0.8, workaround for https://github.com/typst/typst/issues/1937
" set errorformat^=\/%f:%l:%c:%m

if get(g:, 'typst_recommended_style', 1)
    setlocal expandtab
    setlocal tabstop=8
    setlocal softtabstop=2
    setlocal shiftwidth=2
endif

if get(g:, 'typst_folding', 0)
    setlocal foldexpr=typst#foldexpr()
    setlocal foldmethod=expr
    if !exists("b:undo_ftplugin")
        let b:undo_ftplugin = ""
    endif
    let b:undo_ftplugin .= "|setl foldexpr< foldmethod<"
endif

if get(g:, 'typst_conceal', 0)
    setlocal conceallevel=2
endif

setlocal commentstring=//\ %s
setlocal comments=s1:/*,mb:*,ex:*/,://

setlocal formatoptions+=croqn
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatlistpat+=\\\|^\\s*[-+\]\\s\\+

if has('win32')
    setlocal iskeyword=a-z,A-Z,48-57,_,-,128-167,224-235
else
    setlocal iskeyword=a-z,A-Z,48-57,_,-,192-255
endif

setlocal suffixesadd=.typ

command! -nargs=* -buffer TypstWatch call typst#TypstWatch(<f-args>)

command! -buffer Toc call typst#Toc('vertical')
command! -buffer Toch call typst#Toc('horizontal')
command! -buffer Tocv call typst#Toc('vertical')
command! -buffer Toct call typst#Toc('tab')

let &cpoptions = s:save_cpo
unlet s:save_cpo
" vim: tabstop=8 shiftwidth=4 softtabstop=4 expandtab
