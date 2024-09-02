"-- BASIC CONFIG --
let g:gruvbox_italic=1

colorscheme one
set background=light
set termguicolors
let g:airline_theme='one'

set virtualedit=onemore

set guioptions-=T
set guioptions-=L
"set guifont=SauceCodePro\ Nerd\ Font
set guifont=Monaco
set belloff=all

set mouse=a

set number
set ruler

syntax enable
set ww=<,>,[,]
set splitbelow

set smarttab
set cindent
set tabstop=4
set shiftwidth=4
set autoindent
set relativenumber

set autowriteall
set clipboard=unnamedplus

let g:auto_save = 1


command Config :e ~/.vimrc

autocmd InsertEnter * :set relativenumber&
autocmd InsertLeave * :set relativenumber

"-- MAPPINGS --"

inoremap <c-s> <C-O>:write<CR>

inoremap <c-z> <C-O>:undo<CR>
inoremap <c-y> <C-O>:redo<CR>
inoremap <c-o> <C-O>:edit 
map <c-p> <Esc>pi

nmap <S-Up> v<Up>
nmap <S-Down> v<Down>
nmap <S-Left> v<Left>
nmap <S-Right> v<Right>
vmap <S-Up> <Up>
vmap <S-Down> <Down>
vmap <S-Left> <Left>
vmap <S-Right> <Right>
imap <S-Up> <Esc>v<Up>
imap <S-Down> <Esc>v<Down>
imap <S-Left> <Esc>v<Left>
imap <S-Right> <Esc>v<Right>

inoremap <c-f> :FZF<CR>
nnoremap f :FZF<CR>
nnoremap q :quitall
nnoremap <c-t> :term<CR>
nnoremap , :Config<CR>
nnoremap b<Left> :bprevious<CR>
nnoremap b<Right> :bnext<CR>
nnoremap bq :bd<CR>
nnoremap bo :bnew<CR>

nnoremap To :tabnew<CR>
nnoremap Tq :tabclose<CR>
nnoremap Tk :tabonly<CR>
nnoremap T<Left> :tabprevious<CR>
nnoremap T<Right> :tabnext<CR>

"nnoremap s :write<CR>

nnoremap sv :vsplit<CR>
nnoremap sh :split<CR>
nmap sn <c-w>j
nmap sm <c-w>_
nmap se <c-w>=
nmap s<Left> <c-w>h
nmap s<Right> <c-w>l
nmap s<Down> <c-w>j
nmap s<Up> <c-w>k

"-- PLUGIN CONFIG --"

"let g:coc_global_extensions = ['coc-json', 'coc-clangd']

"let g:airline_theme='bubblegum'
"let g:airline#extensions#tabline#enabled=1

let g:one_allow_italics=1

let g:clang_format#auto_format = 1
let g:clang_format#style_options = {
    \ "AllowShortLoopsOnASingleLine":"true",
	\ "AllowShortBlocksOnASingleLine":"true",
	\ "AlignAfterOpenBracket":"Align",
	\ "AlignConsecutiveAssignments":"true",
	\ "AlignConsecutiveDeclarations":"true",
	\ "AlignConsecutiveMacros":"true",
	\ "AlignEscapedNewlines":"true",
	\ "BreakBeforeBraces":"Attach",
	\ "BreakBeforeTernaryOperators":"true",
	\ "BreakConstructorInitializers":"BeforeComma",
	\ "BreakInheritanceList":"BeforeComma",
	\ "BreakStringLiterals":"false",
	\ "ColumnLimit":0,
	\ "Cpp11BracedListStyle":"false",
	\ "FixNamespaceComments":"true",
	\ "IncludeBlocks":"Regroup",
	\ "IndentCaseBlocks":"true",
	\ "IndentCaseLabels":"true",
	\ "IndentPPDirectives":"AfterHash",
	\ "IndentWidth":4,
	\ "MaxEmptyLinesToKeep":2,
	\ "NamespaceIndentation":"All",
	\ "PointerAlignment":"Left",
	\ "SortIncludes":"true",
	\ "SortUsingDeclarations":"true",
	\ "SpaceAfterCStyleCast":"true",
	\ "SpaceAfterLogicalNot":"false",
	\ "SpaceAfterTemplateKeyword":"false",
	\ "SpaceBeforeAssignmentOperators":"true",
	\ "SpaceBeforeCpp11BracedList":"false",
	\ "SpaceBeforeCtorInitializerColon":"true",
	\ "SpaceBeforeInheritanceColon":"true",
	\ "SpaceBeforeRangeBasedForLoopColon":"true",
	\ "SpaceBeforeSquareBrackets":"false",
	\ "SpaceInEmptyBlock":"false",
	\ "SpaceInEmptyParentheses":"false",
	\ "SpacesBeforeTrailingComments":4,
	\ "SpacesInAngles":"false",
	\ "SpacesInCStyleCastParentheses":"false",
	\ "SpacesInConditionalStatement":"false",
	\ "SpacesInContainerLiterals":"false",
	\ "SpacesInParentheses":"false",
	\ "SpacesInSquareBrackets":"false",
	\ "TabWidth":4,
	\ "UseTab":"Always"}

" COC.NVIM

" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes


call ale#linter#Define('c', {
	\ 'name': 'clangd',
	\ 'lsp': 'stdio',
	\ 'executable': '/usr/bin/clangd',
	\ 'command': '%e',
	\ 'project_root': '.'
	\ })

let g:ale_completion_enabled=1
let g:ale_linters_explicit = 1

set omnifunc=ale#completetion#OmniFunc
