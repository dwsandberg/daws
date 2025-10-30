Module format5

use UTF8

use bits

use stack.blkstk

use seq.byte

use seq1.byte

use seq.char

use standard

type blkstk is result:UTF8, kind:word

Function textFormat5(s:seq.word) UTF8
{OPTION INLINE
/br nospace means add no space before word}
if isempty.s then emptyUTF8
else
 for
  stk = empty:stack.blkstk
  , cmd = true
  , result = emptyUTF8
  , Space = false
  , this = s sub 1
  , w ∈ s << 1 + "?"
 do
  let chars = decodeword.this,
  if n.chars = 1 then
   let ch = chars sub 1,
   if ch ∈ (decodeword.merge."+-.:" + char.10 + char.32) then {no Space before or after} next(stk, cmd, result + chars, false, w)
   else if ch ∈ decodeword.merge.",]}):(dq)" then {no Space before but Space after} next(stk, cmd, result + chars, true, w)
   else if ch ∈ decodeword.merge."([{" then
    {Space before but no Space after}
    next(stk, cmd, if Space then result + char.32 + chars else result + chars, false, w)
   else next(stk, cmd, if Space then result + char.32 + ch else result + ch, true, w)
  else if n.chars = 2 then
   if this ∈ ". : " then {no Space before or after} next(stk, cmd, result + chars, false, w)
   else if not.cmd then
    let chars2 = if not.Space then result + chars else result + char.32 + chars,
    next(stk, cmd, chars2, true, w)
   else if this ∈ "/p" then next(stk, cmd, paragraph.result, false, w)
   else
    let chars2 = if not.Space then result + chars else result + char.32 + chars,
    next(stk, cmd, chars2, true, w)
  else if this = escapeformat then next(stk, not.cmd, result, Space, w)
  else if not.cmd then
   let chars2 = if not.Space then result + chars else result + char.32 + chars,
   next(stk, cmd, chars2, true, w)
  else if this ∈ "/sp" then
   if not.isempty.toseqbyte.result ∧ last.toseqbyte.result = tobyte.32 then next(stk, cmd, result, false, w)
   else next(stk, cmd, result + char.32, false, w)
  else if this ∈ "/br" then
   let z = UTF8.linebreak.toseqbyte.result,
   next(stk, cmd, z, false, w)
  else if this ∈ "/tag" then next(stk, cmd, result + decodeword.w, false, "/cell" sub 1)
  else
   let chars2 = if not.Space then result + chars else result + char.32 + chars,
   next(stk, cmd, chars2, true, w),
 result + char.32

function haslinebreak(b:seq.byte) boolean endbreak.b > 0

function endbreak(b:seq.byte) int
for a = tobyte.32, count = 0, e ∈ reverse.b
while a = tobyte.32
do next(e, count + 1),
if a ≠ tobyte.10 then 0 else count

function paragraph(ain:UTF8) UTF8
let a = toseqbyte.ain,
ain + if not.haslinebreak.a then [char.10, char.10] else [char.10]

function linebreak(a:seq.byte) seq.byte
if not.haslinebreak.a then a + [tobyte.10] else a 
