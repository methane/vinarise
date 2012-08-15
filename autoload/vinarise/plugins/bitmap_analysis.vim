"=============================================================================
" FILE: bitmap_analysis.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" Last Modified: 15 Aug 2012.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! vinarise#plugins#bitmap_analysis#define()
  return s:plugin
endfunction

" Variables  "{{{
"}}}

let s:plugin = {
      \ 'name' : 'bitmap_analysis',
      \ 'description' : 'bitmap analyzer',
      \}

function! s:plugin.initialize(vinarise, context)"{{{
  call unite#sources#vinarise_analysis#add_analyzers(s:analyzer)
endfunction"}}}
function! s:plugin.finalize(vinarise, context)"{{{
endfunction"}}}

let s:analyzer = {
      \ 'name' : 'bitmap',
      \ 'description' : 'bitmap analyzer',
      \}

function! s:analyzer.detect(vinarise, context)"{{{
  return a:vinarise.get_bytes(0, 2) == [0x42, 0x4d]
endfunction"}}}

function! s:analyzer.parse(vinarise, context)"{{{
  let candidates = []
  let offset = 0

  let file_header = { 'name' : 'BITMAPFILEHEADER', 'value' : []}

  let value = {
        \ 'name' : 'bfType', 'value' : 'BM',
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ }
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfSize', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ }
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfReserved1', 'value' : a:vinarise.get_int16_le(offset),
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ }
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfReserved2', 'value' : a:vinarise.get_int16_le(offset),
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ }
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfOffBits', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ }
  call add(file_header.value, value)
  let offset += value.size

  call add(candidates, file_header)

  let bisize = a:vinarise.get_int32_le(offset)

  if bisize == 40
    " BITMAPINFOHEADER
    call add(candidates, 'BITMAPINFOHEADER')

    " call add(candidates, 'biSize = ' . bisize)
    " let offset += 4
    " call add(candidates, 'biWidth = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
    " call add(candidates, 'biHeight = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
    " call add(candidates, 'biPlains = ' . a:vinarise.get_int16_le(offset))
    " let offset += 2
    " call add(candidates, 'biBitCount = ' . a:vinarise.get_int16_le(offset))
    " let offset += 2
    " call add(candidates, 'biCompression = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
    " call add(candidates, 'biSizeImage = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
    " call add(candidates, 'biXPixPerMeter = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
    " call add(candidates, 'biYPixPerMeter = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
    " call add(candidates, 'biClrUsed = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
    " call add(candidates, 'biClrImportant = ' . a:vinarise.get_int32_le(offset))
    " let offset += 4
  endif

  return candidates
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
