" Vim syntax file
" Language: Typst
" Maintainer: Kaj Munhoz Arfvidsson
" Upstream: https://github.com/kaarmu/typst.vim

if exists("b:current_syntax")
    finish
endif

call typst#options#init()
if !g:typst_syntax_highlight
    finish
endif

if g:typst_conceal
    command! -nargs=* TypstConcealends <args> concealends
else
    command! -nargs=* TypstConcealends <args>
endif

syntax sync fromstart
syntax spell toplevel


" Code {{{1
syntax cluster typstCode
    \ contains=@typstComments
            \ ,typstCodeInvalidChar
            \ ,typstCodeOperator
            \ ,@typstCodeKeywords
            \ ,@typstCodeConstants
            \ ,@typstCodeIdentifiers
            \ ,@typstCodeParens

" These characters never appear as part of valid tokens in code mode, with the
" exception of %, which can get matched after a number.
syntax match typstCodeInvalidChar contained /[#%&'?@\\^|~]/

" On its own the exclamation sign is not a valid token, but it is part of the
" `!=` inequality operator. `!` is not included in the list of invalid
" characters because it is annoying to always get an error while you are typing
" `!=`, so I tried making a rule that only matches an exclamation mark when it
" is not directly in front of the cursor (`\%#` matches at the cursor position,
" `\@!` negates this), so that an error is not shown immediately after `!` is
" typed. However, I'm not sure if this rule can have any annoying side-effects
" such as flickering or performance degradation, so I'm leaving it commented out.
" syntax match typstCodeInvalidChar contained /!\%#\@!/

" The list of all operators in the code mode:
" <https://github.com/typst/typst/blob/v0.14.2/docs/reference/language/scripting.md#operators>
syntax match typstCodeOperator contained /[-+/*<=>!]=\|[-+/*<=>]\|\.\./

" Code > Identifiers & Functions {{{2
syntax cluster typstCode add=typstCodeIdentifier,typstCodeFunction

" The `\%(-*\)\@>` construct will consume all dashes in front of an identifier.
" It is necessary so that, for instance, `--` doesn't get highlighted as a minus
" in front of a variable named `-`.
syntax match typstCodeIdentifier
    \ contained
    \ /\<\%(-*\)\@>\zs\K\%(\k\|-\)*\>/
    \ skipwhite skipempty nextgroup=typstCodeIdentifierDot

" Must come after typstCodeIdentifier
syntax match typstCodeFunction
    \ contained
    \ /\<\%(-*\)\@>\zs\K\%(\k\|-\)*\>\ze[\(\[]/
    \ skipwhite skipempty nextgroup=typstCodeFunctionArguments

syntax match typstCodeIdentifierDot
    \ contained
    \ /\./
    \ skipwhite skipempty nextgroup=typstCodeIdentifier,typstCodeFunction

syntax region typstCodeFunctionArguments
    \ contained transparent
    \ matchgroup=typstCodeParen start=/(/ end=/)/
    \ contains=@typstCode
    \ skipwhite skipempty nextgroup=typstCodeIdentifierDot

syntax region typstCodeFunctionArguments
    \ contained transparent
    \ matchgroup=typstCodeBracket start=/\[/ end=/\]/
    \ contains=@typstMarkup
    \ skipwhite skipempty nextgroup=typstCodeIdentifierDot


" Code > Keywords {{{2
" NOTE: The keywords must come after everything user functions and variables!
syntax cluster typstCodeKeywords
    \ contains=typstCodeConditional
            \ ,typstCodeRepeat
            \ ,typstCodeKeyword
            \ ,typstCodeStatement
syntax keyword typstCodeConditional
    \ contained
    \ if else
syntax keyword typstCodeRepeat
    \ contained
    \ while for
syntax keyword typstCodeKeyword
    \ contained
    \ not in and or return
syntax region typstCodeStatement
    \ contained
    \ matchgroup=typstCodeStatementWord start=/\v(let|set|import|include|context)>/
    \ matchgroup=Noise end=/\v%(;|$)/
    \ contains=@typstCode
syntax region typstCodeStatement
    \ contained
    \ matchgroup=typstCodeStatementWord start=/\<show\>/
    \ matchgroup=Noise end=/:/
    \ contains=@typstCode
    \ skipwhite nextgroup=@typstCode,typstCodeShowRocket
syntax match typstCodeShowRocket
    \ contained
    \ /.*=>/
    \ contains=@typstCode
    \ skipwhite nextgroup=@typstCode

" Code > Constants {{{2
syntax cluster typstCodeConstants
    \ contains=typstCodeConstant
            \ ,typstCodeBoolean
            \ ,typstCodeFloat
            \ ,typstCodeInteger
            \ ,typstCodeString
            \ ,typstCodeLabel

" Must come after typstCodeIdentifier
syntax match typstCodeConstant
    \ contained
    \ /\<\%(-*\)\@>\zs\%(none\|auto\)\>/

syntax match typstCodeBoolean
    \ contained
    \ /\<\%(-*\)\@>\zs\%(true\|false\)\>/

syntax cluster typstCodeFloatSuffixes
    \ contains=typstCodeFloatRatio
            \ ,typstCodeFloatLength
            \ ,typstCodeFloatAngle
            \ ,typstCodeFloatFraction

" 1.0, 1., .0, 1.e6, 1.e-6, 1.e+6, 1e6
" For the sake of simplicity, regular decimal integers like 123 are also matched by this rule.
syntax match typstCodeFloat
    \ contained
    \ /\v%(\d+\.\d*|\.\d+|\d+)%([eE][+-]?\d+)?/
    \ nextgroup=typstCodeInvalidNumberSuffix,@typstCodeFloatSuffixes

" Note that binary, octal and hexadecimal integers cannot have a unit suffix!
syntax match typstCodeInteger
    \ contained
    \ /\v%(0b[01]+|0o\o+|0x\x+)/
    \ nextgroup=typstCodeInvalidNumberSuffix

" Must come *before* patterns for the valid suffixes, so that it gets lower priority when matching.
syntax match typstCodeInvalidNumberSuffix contained /[[:alnum:]%]\+/

syntax match typstCodeFloatRatio contained /%\%(\k\@!\|-\@=\)/
syntax match typstCodeFloatLength contained /\%(pt\|mm\|cm\|in\|em\)\%(\>\|\ze-\)/
syntax match typstCodeFloatAngle contained /\%(deg\|rad\)\%(\>\|\ze-\)/
syntax match typstCodeFloatFraction contained /fr\%(\>\|\ze-\)/

syntax region typstCodeString
    \ contained
    \ start=/"/ skip=/\\\\\|\\"/ end=/"/
    \ contains=typstEscaped,@Spell
syntax match typstCodeLabel
    \ contained
    \ /\v\<%(\k|:|\.|-)*\>/

" Code > Parens {{{2
syntax cluster typstCodeParens
    \ contains=typstCodeParenRegion
            \ ,typstCodeBraceRegion
            \ ,typstCodeBracketRegion
            \ ,typstCodeDollarRegion
            \ ,@typstMarkupRawRegions

syntax region typstCodeParenRegion
    \ contained transparent
    \ matchgroup=typstCodeParen start=/(/ end=/)/
    \ contains=@typstCode

syntax region typstCodeBraceRegion
    \ contained transparent
    \ matchgroup=typstCodeBrace start=/{/ end=/}/
    \ contains=@typstCode

syntax region typstCodeBracketRegion
    \ contained transparent
    \ matchgroup=typstCodeBracket start=/\[/ end=/\]/
    \ contains=@typstMarkup

syntax region typstCodeDollarRegion
    \ contained
    \ matchgroup=typstCodeDollar start=/\$/ end=/\$/
    \ contains=@typstMath


" Hashtag {{{1
syntax cluster typstHashtag contains=typstHashtagInvalidChar

" Basically all ASCII punctuation characters are invalid immediately following
" a hashtag, apart from these: _, {, [, (, `, ", $. They will get matched by
" syntax rules below, which will take priority and override this one. Whitespace
" immediately after the hashtag is also invalid.
syntax match typstHashtagInvalidChar /#\_./hs=s+1

" Hashtag > Identifiers & Functions {{{2
syntax cluster typstHashtag add=typstHashtagIdentifier,typstHashtagFunction

syntax cluster typstHashtagMemberAccess
    \ contains=typstHashtagFieldAccess
            \ ,typstHashtagMethodCall
            \ ,typstHashtagFunctionArguments
            \ ,typstHashtagSemicolon

syntax match typstHashtagIdentifier
    \ /#-\@!\K\%(\k\|-\)*\>/
    \ nextgroup=@typstHashtagMemberAccess

" Must come after typstHashtagIdentifier
syntax match typstHashtagFunction
    \ /#-\@!\K\%(\k\|-\)*\>\ze[\(\[]/
    \ nextgroup=typstHashtagFunctionArguments

syntax match typstHashtagFieldAccess
    \ contained
    \ /\.-\@!\K\%(\k\|-\)*\>/hs=s+1
    \ nextgroup=@typstHashtagMemberAccess

" Must come after typstHashtagFieldAccess
syntax match typstHashtagMethodCall
    \ contained
    \ /\.-\@!\K\%(\k\|-\)*\>\ze[\(\[]/hs=s+1
    \ nextgroup=typstHashtagFunctionArguments

syntax match typstHashtagSemicolon contained /;/

syntax region typstHashtagFunctionArguments
    \ contained transparent
    \ matchgroup=typstCodeParen start=/(/ end=/)/
    \ matchgroup=typstHashtagSemicolon end=/;/
    \ contains=@typstCode
    \ nextgroup=@typstHashtagMemberAccess

syntax region typstHashtagFunctionArguments
    \ contained transparent
    \ matchgroup=typstCodeBracket start=/\[/ end=/\]/
    \ contains=@typstMarkup
    \ nextgroup=@typstHashtagMemberAccess


if g:typst_conceal_emoji
    runtime! syntax/typst-emoji.vim
endif


" Hashtag > Constants {{{2
syntax cluster typstHashtag add=
    \ typstHashtagConstant,
    \ typstHashtagBoolean,
    \ typstHashtagString,
    \ typstHashtagInteger,
    \ typstHashtagFloat,
    \ typstHashtagLabel,

" Must come after typstHashtagIdentifier
syntax match typstHashtagConstant
    \ /#\%(none\|auto\)\>/
    \ nextgroup=@typstHashtagMemberAccess

syntax match typstHashtagBoolean
    \ /#\%(true\|false\)\>/
    \ nextgroup=@typstHashtagMemberAccess

syntax region typstHashtagString
    \ start=/#"/ skip=/\\\\\|\\"/ end=/"/
    \ contains=typstEscaped,@Spell
    \ nextgroup=@typstHashtagMemberAccess

syntax match typstHashtagFloat
    \ /\v#%(\d+\.\d*|\.\d+|\d+)%([eE][+-]?\d+)?[[:alnum:]%]*/he=s+1
    \ contains=typstCodeFloat
    \ nextgroup=@typstHashtagMemberAccess

syntax match typstHashtagInteger
    \ /#\%(0b[01]\+\|0o\o\+\|0x\x\+\)[[:alnum:]%]*/he=s+1
    \ contains=typstCodeInteger
    \ nextgroup=@typstHashtagMemberAccess

syntax match typstHashtagLabel
    \ /\v#\<%(\k|-)%(\k|:|\.|-)*\>/
    \ nextgroup=@typstHashtagMemberAccess

syntax region typstHashtagRawInline
    \ start=/#`/ end=/`/ keepend
    \ nextgroup=@typstHashtagMemberAccess

" TODO: typstHashtagRawBlock

" Hashtag > Parens {{{2
syntax cluster typstHashtag add=
    \ typstHashtagParenRegion,
    \ typstHashtagBraceRegion,
    \ typstHashtagBracketRegion,
    \ typstHashtagDollarRegion,

syntax region typstHashtagParenRegion
    \ transparent
    \ matchgroup=typstHashtagParen start=/#(/ end=/)/
    \ contains=@typstCode
    \ nextgroup=@typstHashtagMemberAccess

syntax region typstHashtagBraceRegion
    \ transparent
    \ matchgroup=typstHashtagBrace start=/#{/ end=/}/
    \ contains=@typstCode
    \ nextgroup=@typstHashtagMemberAccess

syntax region typstHashtagBracketRegion
    \ transparent
    \ matchgroup=typstHashtagBracket start=/#\[/ end=/\]/
    \ contains=@typstMarkup
    \ nextgroup=@typstHashtagMemberAccess

syntax region typstHashtagDollarRegion
    \ transparent
    \ matchgroup=typstHashtagDollar start=/#\$/ end=/\$/
    \ contains=@typstMath
    \ nextgroup=@typstHashtagMemberAccess

" Hashtag > Keywords {{{2
syntax cluster typstHashtag add=
    \ typstHashtagConditional,
    \ typstHashtagRepeat,
    \ typstHashtagKeyword,
    \ typstHashtagStatement,

syntax region typstHashtagRepeat
    \ contained
    \ matchgroup=typstHashtagRepeat start=/\v#(while|for)>/ end=/\v\ze(\{|\[)/
    \ contains=@typstCode

syntax match typstHashtagKeyword
    \ /#return\>/
    \ skipwhite nextgroup=@typstCode

syntax region typstHashtagStatement
    \ matchgroup=typstHashtagStatementWord start=/\v#(let|set|import|include|context)>/
    \ matchgroup=Noise end=/\v%(;|$)/
    \ contains=@typstCode

syntax region typstHashtagStatement
    \ matchgroup=typstHashtagStatementWord start=/#show\>/
    \ matchgroup=Noise end=/:/
    \ contains=@typstCode
    \ skipwhite nextgroup=@typstCode,typstCodeShowRocket

" This rule exists solely to catch the start of an `#if` statement in markup and
" redirect to a rule that matches `if` without the hashtag. This is done so that
" we can reuse the same rule for both the start of an `#if` statement and for
" `else if` clauses. `me=s+1` moves the end of this match to the `#` character,
" so the group in `nextgroup` will be matched immediately after the `#`.
syntax match typstHashtagConditional /#if\>/me=s+1 nextgroup=typstHashtagIfStatement

" The purpose of the long regex in the `end=/.../` pattern is to find where the
" condition of the `#if` stops and the body begins. This is made complicated by
" the fact that in Typst, unlike in C-like languages, the condition of the `if`
" statement is not surrounded with parentheses. Instead, Typst will try to parse
" a complete valid expression, and then expect a `[ ... ]` or `{ ... }` block of
" the body to follow immediately afterwards. However, a bracketed/braced block
" is also a valid expression and can just as well be part of the condition, e.g.
" `#if check[markup].something != 0 or { (long + complicated).expression() } {`,
" so how do we tell where the body actually begins? I employ a simple heuristic
" to avoid terminating the condition region prematurely: when an opening brace
" or bracket is found, I use a negative look-behind to check if the preceding
" token looks like it extends the expression or doesn't. For example, binary and
" unary operators require an operand on the right-hand side, so a bracket after
" an operator is parsed as its operand and thus it becomes a part of the overall
" condition. If a bracket comes immediately after a non-whitespace character -
" it is most likely an argument to a function. Lastly, if it comes right after
" the keyword `if`, then it is definitely parsed as the start of an expression.
syntax region typstHashtagIfStatement
    \ contained transparent
    \ matchgroup=typstHashtagIf start=/\<if\>/
    \ matchgroup=NONE end=/$\|\ze;\|\%([-+*/<>!=]=\s*\|[-+*/<>=]\s*\|\<\%(and\|or\|not\|in\|if\)\>\s*\|\S\)\@<!\ze[\[\{]/
    \ contains=@typstCode
    \ nextgroup=typstHashtagIfClause,typstHashtagSemicolon

syntax region typstHashtagIfClause
    \ contained transparent
    \ matchgroup=typstCodeBracket start=/\[/ end=/\]/
    \ contains=@typstMarkup
    \ skipwhite nextgroup=typstHashtagElse,typstHashtagSemicolon

syntax region typstHashtagIfClause
    \ contained transparent
    \ matchgroup=typstCodeBrace start=/{/ end=/}/
    \ contains=@typstCode
    \ skipwhite nextgroup=typstHashtagElse,typstHashtagSemicolon

syntax match typstHashtagElse
    \ contained
    \ /\<else\>/
    \ skipwhite nextgroup=typstHashtagElseClause,typstHashtagIfStatement,typstHashtagSemicolon

syntax region typstHashtagElseClause
    \ contained transparent
    \ matchgroup=typstCodeBracket start=/\[/ end=/\]/
    \ contains=@typstMarkup

syntax region typstHashtagElseClause
    \ contained transparent
    \ matchgroup=typstCodeBrace start=/{/ end=/}/
    \ contains=@typstCode

" Markup {{{1
syntax cluster typstMarkup
    \ contains=@typstComments
            \ ,typstEscaped
            \ ,@Spell
            \ ,@typstHashtag
            \ ,@typstMarkupText

" Markup > Text {{{2
syntax cluster typstMarkupText
    \ contains=@typstMarkupRawRegions
            \ ,typstMarkupLabel
            \ ,typstMarkupRefMarker
            \ ,typstMarkupUrl
            \ ,typstMarkupHeading
            \ ,typstMarkupBulletList
            \ ,typstMarkupEnumList
            \ ,typstMarkupTermMarker
            \ ,typstMarkupBold
            \ ,typstMarkupItalic
            \ ,typstMarkupLinebreak
            \ ,typstMarkupNonbreakingSpace
            \ ,typstMarkupSoftHyphen
            \ ,typstMarkupDash
            \ ,typstMarkupEllipsis
            \ ,typstMarkupDollarRegion

" Raw Text
syntax cluster typstMarkupRawRegions contains=
    \ typstMarkupRawInline,
    \ typstMarkupRawBlock,
    \ typstMarkupCodeBlockTypst,
syntax region typstMarkupRawInline
    \ start=/`/ end=/`/ keepend
syntax region typstMarkupRawBlock
    \ matchgroup=Macro start=/\z(```\+\)\w*/ end=/\z1/ keepend
TypstConcealends syntax region typstMarkupCodeBlockTypst
    \ matchgroup=Macro start=/\z(```\+\)typst/ end=/\z1/ keepend
    \ contains=@typstMarkup
runtime! syntax/typst-embedded.vim

" Label & Reference
syntax match typstMarkupLabel
    \ /\v\<%(\k|:|\.|-)*\>/
" Ref markers can't end in ':' or '.', but labels can
syntax match typstMarkupRefMarker
    \ /\v\@%(\k|:|\.|-)*%(\k|-)/

" URL
syntax match typstMarkupUrl
    \ "\v\w+://\S*"

" Heading
syntax match typstMarkupHeading
    \ /^\s*\zs=\{1,6}\s.*$/
    \ contains=@typstMarkup,@Spell

" Lists
syntax match typstMarkupBulletList
    \ /\v^\s*-\s+/
syntax match typstMarkupEnumList
    \ /\v^\s*(\+|\d+\.)\s+/
syntax region typstMarkupTermMarker
    \ oneline start=/\v^\s*\/\s/ end=/:/
    \ contains=@typstMarkup

" Bold & Italic
syntax match typstMarkupBold
    \ /\v(\w|\\)@1<!\*\S@=.{-}(\n.{-1,})*\S@1<=\\@1<!\*/
    \ contains=typstMarkupBoldRegion
syntax match typstMarkupItalic
    \ /\v(\w|\\)@1<!_\S@=.{-}(\n.{-1,})*\S@1<=\\@1<!_/
    \ contains=typstMarkupItalicRegion
syntax match typstMarkupBoldItalic
    \ contained
    \ /\v(\w|\\)@1<![_\*]\S@=.{-}(\n.{-1,})*\S@1<=\\@1<!\2/
    \ contains=typstMarkupBoldRegion,typstMarkupItalicRegion
TypstConcealends syntax region typstMarkupBoldRegion
    \ contained
    \ transparent matchgroup=typstMarkupBold
    \ start=/\(^\|[^0-9a-zA-Z]\)\@<=\*/ end=/\*\($\|[^0-9a-zA-Z]\)\@=/
    \ contains=typstMarkupBoldItalic,@typstMarkup,@Spell
TypstConcealends syntax region typstMarkupItalicRegion
    \ contained
    \ transparent matchgroup=typstMarkupItalic
    \ start=/\(^\|[^0-9a-zA-Z]\)\@<=_/ end=/_\($\|[^0-9a-zA-Z]\)\@=/
    \ contains=typstMarkupBoldItalic,@typstMarkup,@Spell

" Linebreak & Special Whitespace
syntax match typstMarkupLinebreak
    \ /\\/
syntax match typstMarkupNonbreakingSpace
    \ /\~/

" Special Symbols
syntax match typstMarkupSoftHyphen
    \ /-?/
syntax match typstMarkupDash
    \ /-\{2,3}/
syntax match typstMarkupEllipsis
    \ /\.\.\./

syntax region typstMarkupDollarRegion
    \ matchgroup=typstMarkupDollar start=/\$/ end=/\$/
    \ contains=@typstMath


" Math {{{1
syntax cluster typstMath
    \ contains=@typstComments
            \ ,typstEscaped
            \ ,@typstHashtag
            \ ,typstMathIdentifier
            \ ,typstMathFunction
            \ ,typstMathNumber
            \ ,typstMathSymbol
            \ ,typstMathBold
            \ ,typstMathScripts
            \ ,typstMathQuote

" a math identifier should be like \k without '_'
syntax match typstMathIdentifier
    \ /\v<\a%(\a|\d)+>/
    \ contained
syntax match typstMathFunction
    \ /\v<\a%(\a|\d)+\ze\(/
    \ contained
syntax match typstMathNumber
    \ /\v<\d+>/
    \ contained
syntax region typstMathQuote
    \ matchgroup=String start=/"/ skip=/\\\\\|\\"/ end=/"/
    \ contained

if g:typst_conceal_math
    runtime! syntax/typst-symbols.vim
endif

" Common {{{1

" Common > Comment {{{2
syntax cluster typstComments
    \ contains=typstCommentLine,typstCommentBlock,typstShebang

" The patterns for comments must come after typstCodeOperator, since it includes a `/`
syntax region typstCommentLine
    \ start="/\*" end="\*/" keepend
    \ contains=typstCommentTodo,@Spell

syntax region typstCommentBlock
    \ start="//" end=/$/ keepend
    \ contains=typstCommentTodo,@Spell

syntax keyword typstCommentTodo
    \ contained
    \ TODO FIXME XXX TBD

" Must come after typstHashtagInvalidChar
syntax region typstShebang
    \ start=/\%^#!/ end=/$/ keepend

" Common > Escapes {{{2

" Must come absolutely last, so that it takes priority over every other pattern!
syntax match typstEscaped /\\u{\x*}\|\\[^[:space:]]/


" Highlighting {{{1

" Highlighting > Linked groups {{{2
highlight default link typstCommentBlock            Comment
highlight default link typstCommentLine             Comment
highlight default link typstCommentTodo             Todo
highlight default link typstShebang                 Special
highlight default link typstEscaped                 Special

highlight default link typstCodeInvalidChar         Error
highlight default link typstCodeOperator            Operator
highlight default link typstCodeConditional         Conditional
highlight default link typstCodeRepeat              Repeat
highlight default link typstCodeKeyword             Keyword
highlight default link typstCodeConstant            Constant
highlight default link typstCodeBoolean             Boolean
highlight default link typstCodeInteger             Number
highlight default link typstCodeFloat               Number
highlight default link typstCodeInvalidNumberSuffix Error
highlight default link typstCodeFloatLength         Number
highlight default link typstCodeFloatAngle          Number
highlight default link typstCodeFloatRatio          Number
highlight default link typstCodeFloatFraction       Number
highlight default link typstCodeString              String
highlight default link typstCodeLabel               Structure
highlight default link typstCodeStatementWord       Statement
highlight default link typstCodeIdentifier          Identifier
highlight default link typstCodeFieldAccess         Identifier
highlight default link typstCodeMethodCall          Function
highlight default link typstCodeIdentifierDot       Noise
highlight default link typstCodeFunction            Function
highlight default link typstCodeParen               Noise
highlight default link typstCodeBrace               Noise
highlight default link typstCodeBracket             Noise
highlight default link typstCodeDollar              Special

highlight default link typstHashtagInvalidChar      Error
" highlight default link typstHashtagControlFlowError Error
highlight default link typstHashtagConditional      Conditional
highlight default link typstHashtagElse             typstHashtagConditional
highlight default link typstHashtagRepeat           Repeat
highlight default link typstHashtagKeyword          Keyword
highlight default link typstHashtagConstant         Constant
highlight default link typstHashtagBoolean          Boolean
highlight default link typstHashtagString           String
highlight default link typstHashtagInteger          Number
highlight default link typstHashtagFloat            Number
highlight default link typstHashtagLabel            Structure
highlight default link typstHashtagRawInline        Special
highlight default link typstHashtagStatementWord    Statement
highlight default link typstHashtagIdentifier       Identifier
highlight default link typstHashtagFieldAccess      Identifier
highlight default link typstHashtagMethodCall       Function
highlight default link typstHashtagSemicolon        Noise
highlight default link typstHashtagFunction         Function
highlight default link typstHashtagParen            Noise
highlight default link typstHashtagBrace            Noise
highlight default link typstHashtagBracket          Noise
highlight default link typstHashtagDollar           Special

highlight default link typstMarkupRawInline         Macro
highlight default link typstMarkupRawBlock          Macro
highlight default link typstMarkupLabel             Structure
highlight default link typstMarkupRefMarker         Structure
highlight default link typstMarkupBulletList        Structure
highlight default link typstMarkupHeading           Title
" highlight default link typstMarkupItalicError       Error
" highlight default link typstMarkupBoldError         Error
highlight default link typstMarkupEnumList          Structure
highlight default link typstMarkupLinebreak         Structure
highlight default link typstMarkupNonbreakingSpace  Structure
highlight default link typstMarkupSoftHyphen        Structure
highlight default link typstMarkupDash              Structure
highlight default link typstMarkupEllipsis          Structure
highlight default link typstMarkupTermMarker        Structure
highlight default link typstMarkupDollar            Special

highlight default link typstMathIdentifier          Identifier
highlight default link typstMathFunction            Statement
highlight default link typstMathNumber              Number
highlight default link typstMathSymbol              Statement

" Highlighting > Custom Styling {{{2
highlight! Conceal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE

highlight default typstMarkupUrl                        term=underline          cterm=underline         gui=underline
highlight default typstMarkupBold                       term=bold               cterm=bold              gui=bold
highlight default typstMarkupItalic                     term=italic             cterm=italic            gui=italic
highlight default typstMarkupBoldItalic                 term=bold,italic        cterm=bold,italic       gui=bold,italic

" }}}1

let b:current_syntax = "typst"

delcommand TypstConcealends

" vim: sw=4 sts=4 et fdm=marker fdl=0
