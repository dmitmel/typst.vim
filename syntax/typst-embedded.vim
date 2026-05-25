" Vim syntax file
" Language: Typst
" Maintainer: Kaj Munhoz Arfvidsson
" Upstream: https://github.com/kaarmu/typst.vim

let s:cpo_save = &cpoptions
set cpoptions&vim

for s:name in get(g:, 'typst_embedded_languages', [])
    let s:langname = substitute(s:name, '  *-> .*$', '', '')
    let s:langfile = substitute(s:name, '^.* ->  *', '', '')
    let s:include = ['syntax include'
                \   ,'@typstEmbedded_'..s:langname
                \   ,'syntax/'..s:langfile..'.vim']
    let s:regionname = 'typstMarkupCodeBlock_' . s:langname
    let s:rule = ['syn region'
                \,s:regionname
                \,'matchgroup=Macro'
                \,'start=/\z(```\+\)'..s:langname..'\>/ end=/\z1/'
                \,'contains=@typstEmbedded_'..s:langname
                \,'keepend']
    if get(g:, 'typst_conceal', 0)
        let s:rule += ['concealends']
    endif
    execute 'silent! ' .. join(s:include, ' ')
    unlet! b:current_syntax
    execute join(s:rule, ' ')
    execute 'syntax cluster typstMarkupRawRegions add=' . s:regionname
endfor

let &cpoptions = s:cpo_save
unlet s:cpo_save
" vim: sw=4 sts=4 et fdm=marker fdl=0
