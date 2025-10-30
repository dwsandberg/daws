Module daws

use UTF8

use bits

use seq.byte

use seq.char

use seq1.char

use classinfo

use seq1.classinfo

use set.classinfo

use file

use seq.file

use format5

use seq1.int

use stack.int

use seq1.mark

use stack.mark

use standard

use seq1.stkinfo

use stack.stkinfo

use textio

use word

use seq.word

use seq1.seq.word

use stack.seq.word

use seq1.word

use stack.word

Function daws(input:seq.file) seq.file
{COMMAND}
let xhtml = false
for out = empty:seq.file, replacements = empty:set.classinfo, f ∈ input
do
 if ext.fn.f ∈ "css" then next(out, asset.processCSS.data.f)
 else if ext.fn.f ∈ "txt" then
  let newfilename = changeext(fn.f, "html"),
  next(out + file(newfilename, processTXT(data.f, replacements, xhtml, "en")), replacements)
 else
  assert ext.fn.f ∈ "html" report "extension not handled:(ext.fn.f)",
  next(out + file(changeext(fn.f, "txt"), processHTML(data.f, toseq.replacements)), replacements),
out

Function processCSS(data:seq.byte) seq.classinfo
{???? need to add more base elements}
let z = breakparagraph.data
for acc = asset.defaults, p ∈ z
do
 for acc1 = acc, idx = findindex(p, "{" sub 1)
 while idx ≤ n.p
 do
  let new =
   if idx > n.p
   ∨ idx < 4
   ∨ p sub (idx - 3) ∉ "p span table img h1 h2 h3 h4 h5 h6 div em strong b i q caption a th td tr" then acc1
   else
    let more =
     if subseq(p, idx + 1, idx + 2) = "/* daws" then subseq(p, idx + 3, findindex(p, "*/" sub 1) - 1)
     else ""
    let zz = subseq(p, idx - 3, idx - 1),
    {assert zz ∈ [" table.shab"," table.recipe"," span.avoidwrap"," span.literal"," span.comment"," span.keyword"," span.block"," img.pic"," p.clear"] report subseq (p, idx-3, idx-1)}
    acc1 + classinfo(acc1, {class} p sub (idx - 3), {ele} p sub (idx - 1), more),
  next(new, idx + findindex(p << idx, "{" sub 1)),
 acc1,
toseq.acc

type mark is kind:word, place:int

function %(m:mark) seq.word ":(kind.m):(place.m)"

function push(s:stack.mark, i:int) stack.mark push(s, mark("mark" sub 1, i))

Function processTXT(
data:seq.byte
, replacements:set.classinfo
, xhtml:boolean
, lang:seq.word
) seq.byte
let z = breakparagraph.data
let p1 = z sub 1
for header = 0, idx = 1, w ∈ p1
do next(if w ∈ "/link /title" then idx else header, idx + 1)
let newz = [subseq(p1, 1, header) + "/head", p1 << header] + z << 1
let header1 =
 textformat(
  if xhtml then "<?xml version =:(dq."/tag 1.0") encoding =:(dq."/tag utf-8") ?> <html xmlns =:(dq."/tag http://www.w3.org/1999/xhtml") xmlns:epub =:(dq."/tag http://www.idpf.org/2007/ops") >"
  else "<!doctype html> <html lang =:(dq("/tag" + lang)) > <meta charset =:(dq."/tag utf-8") >"
 )
let final = textformat(if xhtml then "/tag </body></html>" else ""),
toseqbyte(header1 + HTMLformat.txt2html(newz, replacements, xhtml) + final)

Function txt2html(z:seq.seq.word, replacements:set.classinfo, xhtml:boolean) seq.word
{covert paragraph to html}
for acc0 = "", mark0 = push(empty:stack.mark, mark("block" sub 1, 0)), p ∈ z
do
 assert place.top.mark0 = n.acc0 report "check23" + %.top.mark0 + %.n.acc0
 for defines = "", marks = mark0, acc = acc0, e ∈ p
 do
  if e ∈ "//" then next(defines, push(marks, n.acc), acc)
  else
   let r = lookupkey(replacements, e),
   if isempty.r then next(defines, marks, acc + e)
   else
    let r1 = r sub 1,
    if baseon.r1 ∈ "/div /ol /ul" ∧ key.r1 = p sub 1 then
     {start of new div or list if key begins at beginning of block.}
     let newmarks =
      push(
       push(pop.marks, mark(if baseon.r1 ∈ "/div" then "div" sub 1 else "list" sub 1, n.acc))
       , top.marks
      ),
     next(defines, newmarks, acc)
    else
     for combinedDef = def.r1, att = r1
     while key.att ≠ baseon.att
     do
      let att0 = lookupkey(replacements, baseon.att)
      assert not.isempty.att0 report "Did not find baseon for" + key.att + baseon.att + esc.p,
      next(combinedDef + def.att0 sub 1, att0 sub 1)
     for marks1 = marks, acc11 = acc, work = true
     while work
     do
      if baseon.r1 ∈ "/li" ∧ kind.top.marks1 ∈ "block" then
       if n.toseq.marks1 = 1 then
        let new = push(pop.marks, mark("list" sub 1, place.top.marks1)),
        next(new, acc11, work)
       else if xhtml then
        let place = place.top.marks1
        let new = subseq(acc11, 1, place) + "/tag </li>" + acc11 << place,
        let stk = push(pop.marks1, mark(kind.top.marks1, place + 2)),
        next(stk, new, false)
       else next(marks1, acc11, false)
      else if baseon.r1 ∈ "/tr" ∧ kind.top.marks1 ∈ "cell" then next(pop.marks1, acc11, work)
      else if baseon.r1 ∈ "/table" ∧ kind.top.marks1 ∈ "row" then next(pop.marks1, acc11, work)
      else next(marks1, acc11, false)
     let stk1 = marks1
     let acc1 =
      if baseon.r1 ∈ "/div" then finishp(acc11, stk1, xhtml)
      else if baseon.r1 ∈ "/ol /ul" then
       let t = "/sp /tag /li /sp /tag >"
       let zz = if subseq(acc11, n.acc11 - n.t + 1, n.acc11) = t then acc11 >> n.t else acc11,
       acc11
      else acc11
     let lastplace = lastplace(acc1, r1, stk1)
     let smallacc = subseq(acc1, 1, lastplace),
     let content = subseq(acc1, lastplace + 1, n.acc1),
     if isdefine.r1 then
      let content1 = if ":" sub 1 ∈ content ∨ ":" sub 1 ∈ content then "':(content) '" else content
      {assert content ∈ [" #ftnt1"] report" DEFINES"+key.r1+esc.content}
      let eval = evaldef("", defines + combinedDef, content1, replacements, xhtml),
      let stk2 = if kind.top.stk1 ∈ "mark" then pop.stk1 else stk1,
      next(defines + eval, stk2, smallacc)
     else
      let new = evaldef(smallacc, defines + combinedDef, content, replacements, xhtml),
      if baseon.r1 ∈ "/br" then next(defines, marks, new)
      else if ismark.r1 then
       let stk2 = if kind.top.stk1 ∈ "mark" then pop.stk1 else stk1
       let stk3 = if baseon.r1 ∈ "/caption" then push(stk2, mark("row" sub 1, n.new)) else stk2,
       next(defines, stk3, new)
      else
       assert baseon.r1
       ∈ "/td /th /tr
       /p /h1 /h2 /h3 /h4 /h5 /h6 /table /li /ol /ul /div /link /title /head /hr" report "not handled?" + baseon.r1
       let tmp =
        if baseon.r1 ∈ "/tr" then "row"
        else if baseon.r1 ∈ "/td /th" then "cell"
        else "block"
       let stk3 = if kind.top.stk1 ∈ tmp then pop.stk1 else stk1
       let stk4 =
        if baseon.r1 ∈ "/div" then
         assert kind.top.stk3 ∈ "div" report "expecting div on stack",
         pop.stk3
        else
         {if baseon.r1 ∈" /li" then push (stk3, mark (" li" sub 1, n.new)) else}
         if baseon.r1 ∈ "/ol /ul" ∧ kind.top.stk3 ∈ "list" then
          assert kind.top.stk3 ∈ "list div" report "expecting list on stack",
          pop.stk3
         else stk3
       {assert baseon.r1 ∉" /ol" report" K"+esc.%.toseq.stk4}
       let stk2 = push(stk4, mark(tmp sub 1, n.new)),
       next(defines, stk2, new),
 let newacc = finishp(acc, marks, xhtml),
 if newacc = acc then next(acc, marks)
 else next(newacc, push(pop.marks, mark("block" sub 1, n.newacc))),
acc0

function finishp(acc:seq.word, marks:stack.mark, xhtml:boolean) seq.word
if n.acc = place.top.marks then acc
else
 let top = place.top.marks,
 subseq(acc, 1, top)
  + "/tag <p>"
  + subseq(acc, top + 1, n.acc)
  + if xhtml then "/tag </p>" else ""

Function lastplace(acc:seq.word, r1:classinfo, stk:stack.mark) int
if baseon.r1 ∈ "/head" then 0
else if ismark.r1 ∨ isdefine.r1 then if kind.top.stk ∈ "mark" then place.top.stk else n.acc - 1
else if baseon.r1 ∈ "/div" then
 for stk2 = stk while not.isempty.stk2 ∧ kind.top.stk2 ≠ "div" sub 1 do pop.stk2
 assert not.isempty.stk2 report "/div requires a begin marker:(toseq.stk) /p" + esc.acc,
 place.top.stk2
else if baseon.r1 ∈ "/ol /ul" then
 assert not.isempty.stk ∧ kind.top.stk ∈ "block" ∧ not.isempty.pop.stk ∧ kind.top.pop.stk ∈ "list div" report "problem with list mark:(toseq.stk)",
 place.top.pop.stk
else place.top.stk

function getAttr(txt:seq.word, class:seq.word) seq.word
let x = findindex(txt, class sub 1),
if x ≥ n.txt then ""
else if txt sub (x + 1) ∉ "=" then ""
else
 let t = txt sub (x + 2),
 if t ∈ dq then
  let y = findindex(txt << (x + 2), t),
  subseq(txt, x + 3, y - 1 + x + 2)
 else [t]

function towords2(f:UTF8) seq.word
let bytes = toseqbyte.f
{add char < to end of f to force out last line}
for acc = empty:seq.word, b = 0, e = 0, intag = false, ele ∈ bytes + tobyte.toint.char1."<"
do
 if toint.ele = toint.char1."<" then next(acc + towords.UTF8.fix.subseq(bytes, b, e), e + 1, e + 1, true)
 else if intag ∧ toint.ele = toint.char1.">" then
  if toint.bytes sub (b + 1) = toint.char1."/" then {end tag} next(acc + towords.UTF8.fix.subseq(bytes, b, e + 1), e + 2, e + 1, false)
  else next(acc + towords.UTF8.subseq(bytes, b, e) + ">", e + 2, e + 1, false)
 else next(acc, b, e + 1, intag),
acc

function fix(s:seq.byte) seq.byte
if n.s < 3 then s
else
 for acc = empty:seq.byte, last& = 0, b ∈ s
 do
  if toint.b = toint.char1."&" then next(acc + b, n.acc + 1)
  else if last& = 0 ∨ toint.b ≠ toint.char1.";" then next(acc + b, last&)
  else
   let str = towords.UTF8.subseq(acc, last& + 1, n.acc)
   let a = if str = "amp" then char1."&" else if str = "lt" then char1."<" else char.0,
   if a ≠ char.0 then next(subseq(acc, 1, last& - 1) + toseqbyte.encodeUTF8.a, 0)
   else
    assert not(toint.b = toint.char1.";") ∨ last& = 0 report "MMM" + str + towords.UTF8.acc,
    next(acc + b, last&),
 acc

type stkinfo is info:classinfo, tagcontent:seq.word, place:int

function %(s:stkinfo) seq.word [key.info.s] + %.place.s

Function processHTML(data:seq.byte, replacements:seq.classinfo) seq.byte
let out = towords2.UTF8.data
let notused = empty:set.classinfo
for
 taglen = 0
 , stk = empty:stack.stkinfo
 , tagorder = totagorder.replacements
 , taglookup = empty:set.classinfo
 , acc = ""
 , w ∈ out
do
 if taglen > 0 ∧ w ∉ ">" then
  {gathering tag}
  next(if taglen > 0 then taglen + 1 else 0, stk, tagorder, taglookup, acc + w)
 else if taglen = 0 then
  let info0 = lookuptag(tagorder, w),
  if isempty.info0 then
   {w is outside tag and not a tag}
   let neww =
    if w
    ∈ "/p
    /br /tag" then "/sp /tag" + w
    else if w ∈ "&amp;" then "&"
    else if w ∈ "&lt;" then "<"
    else [w],
   next(0, stk, tagorder, notused, acc + neww)
  else
   let att = info0 sub 1,
   if not.isendtag.att then {found begining of tag} next(1, stk, tagorder, asset.info0, acc + w)
   else
    {found endtag}
    assert n.info0 = 1 report "problem 76"
    let nlist = n.cleanstk(att, stk),
    next(0, pop(stk, nlist), tagorder, notused, keylist(tagorder, acc, stk, nlist))
 else
  {end of tag}
  assert taglen > 0 ∧ w ∈ ">" report "problem 77"
  let tagcontent = subseq(acc, n.acc - taglen + 1, n.acc)
  let basekey = tokey.tagcontent sub 1
  let cls = getAttr(tagcontent, "class")
  let key = if isempty.cls then basekey else merge("/" + cls)
  let info1 = lookupkey(taglookup, key)
  let newclassinfo = isempty.info1
  let att =
   if newclassinfo then
    let ele = encodeword(decodeword.tagcontent sub 1 << 1),
    classinfo(taglookup, ele, cls sub 1, "")
   else info1 sub 1,
  let newtagorder = if newclassinfo then totagorder(toseq.tagorder + att) else tagorder,
  if noendtag.att then
   let tmpstk = push(stk, stkinfo(att, tagcontent, n.acc - n.tagcontent)),
   next(0, stk, newtagorder, notused, keylist(newtagorder, acc >> n.tagcontent, tmpstk, 1))
  else
   let nclean = n.cleanstk(att, stk)
   let acc1 = keylist(tagorder, acc >> n.tagcontent, stk, nclean),
   let stk2 = push(pop(stk, nclean), stkinfo(att, tagcontent, n.acc1)),
   next(0, stk2, newtagorder, notused, acc1)
{let t = for txt ="", e ∈ toseq.tagorder do if key.e = baseon.e ∨ isendtag.e then txt else let b = if subseq (def.e, 1, 2) =" class: " ∧ key.e = merge (" /"+subseq (def.e, 3, 3)) then def.e << 3 else def.e, txt+key.e+baseon.e+b+",", esc.txt >> 1+" /replacements
/p"+acc assert false report" done"+t,}
toseqbyte.textFormat5.acc

function %(a:char) seq.word [encodeword.[a]]

function rmpostfix(t:seq.word, postfix:seq.word) seq.word
if n.t < n.postfix then t
else
 for A = t, postfix1 = postfix
 while not.isempty.postfix1 ∧ last.postfix1 = last.A
 do next(A >> 1, postfix >> 1),
 A

function rmprefix(prefix:seq.word, A:seq.word) seq.word
if n.A < n.prefix then A
else
 for B = A, prefix1 = prefix
 while not.isempty.prefix1 ∧ prefix1 sub 1 = B sub 1
 do next(B << 1, prefix1 << 1),
 if isempty.prefix1 ∨ isempty.B then B
 else
  let m1 = decodeword.prefix1 sub 1
  let m2 = decodeword.B sub 1,
  if subseq(m2, 1, n.m1) = m1 then [encodeword(m2 << n.m1)] + B << 1 else B

function getattnames(def:seq.word, t:seq.classinfo) seq.word
for acc = "", intag = false, invalue = false, w ∈ def
do
 if intag then
  if w ∈ ">" then next(acc, false, false)
  else if w ∈ "=" then next(acc, intag, true)
  else if w ∈ "/url" then next(acc, intag, false)
  else if invalue then next(acc, intag, invalue)
  else next(acc + w, intag, invalue)
 else
  let info = lookuptag(asset.t, w),
  next(acc, not.isempty.info ∧ not.isendtag.info sub 1, false),
acc

function cleanstk(att:classinfo, stk:stack.stkinfo) seq.stkinfo
let baseon = tokey.baseon.att
let endtag = isendtag.att,
if endtag ∧ baseon ∈ "/li /tr /td /th" then empty:seq.stkinfo
else if endtag ∧ ismark.att then [top.stk]
else if not.endtag ∧ baseon ∈ "/ol /ul" then empty:seq.stkinfo
else
 {for acc ="", e ∈ toseq.stk do acc+baseon.info.e}
 let group1 = "/p /table /h1 /h2 /h3 /h4 /h5 /h6 /style /title /head /li"
 let removeend =
  if endtag ∧ baseon ∈ "/div" then group1 + "/div"
  else if baseon ∈ "/td /th" then "/td /th"
  else if baseon ∈ "/tr" then "/td /th /tr"
  else if baseon ∈ "/ol /ul" then group1 + (if endtag then "/li" else "")
  else if baseon ∈ group1 ∨ baseon ∈ "/div" then group1 + "/td /th /tr"
  else ""
 for result = empty:seq.stkinfo, stk1 = stk
 while not.isempty.stk1 ∧ baseon.info.top.stk1 ∈ removeend
 do next(result + top.stk1, pop.stk1)
 let result1 = if endtag ∧ baseon ∈ "/ol /ul" then result + top.stk1 else result,
 {assert baseon ∉" /ol /ul" ∨ place.top.stk ∈ [8, 62, 125] report" vv:(baseon):(endtag)"+esc.removeend}
 result1

function isnested(stk:stack.stkinfo) boolean
for acc = false, i = pop.pop.stk
while not.acc ∧ not.isempty.i
do next(baseon.info.top.i ∈ "/ol /ul", pop.i),
acc

function keylist(tagorder:tagorder, accin:seq.word, stk:stack.stkinfo, n:int) seq.word
let noclass = false
let maxidx = n.toseq.stk - 1
let beginlist =
 maxidx > 1
 ∧ baseon.info.top.stk
 ∈ "/li
 /p"
 ∧ baseon.info.undertop(stk, 1) ∈ "/ol /ul"
 ∧ place.undertop(stk, 1) = place.undertop(stk, 0)
let acc =
 if beginlist ∧ isnested.stk then subseq(accin, 1, place.top.stk) + key.info.undertop(stk, 1) + accin << place.top.stk
 else accin
for pend = acc, idx = 0
while idx < n
do
 let e = undertop(stk, idx)
 let kind = baseon.info.e
 for combinedDef = def.info.e, att3 = info.e
 while baseon.att3 ≠ key.att3
 do
  let z = lookupkey(asset.toseq.tagorder, baseon.att3)
  assert n.z = 1 report "problem:(baseon.info.e):(z)",
  next(combinedDef + def.z sub 1, z sub 1)
 let totxt = extractdef(combinedDef, "totxt" sub 1)
 let pend2 =
  if kind ∈ "/li /div /ol /ul" ∧ not.isempty.pend ∧ last.pend ∈ "/p" then pend >> 1
  else pend
 let content = pend2 << place.e,
 let other = pend2 >> n.content,
 if noclass ∧ kind ∈ "/span" then next(other + content, idx + 1)
 else
  let content1 = if ismark.info.e ∧ n.content > 1 then "//" + content else content,
  next(convertText(other, totxt, e, combinedDef, content1, noclass), idx + 1)
{assert isempty.stk ∨ baseon.info.top.stk ∈" /li" ∨ n.acc ∈ [28, 171, 189, 215] ∨ n.acc < 171 report":(n) KL:(n.acc)"+esc (acc)+"
/p:(esc.%.toseq.stk)"}
pend

function convertText(
other:seq.word
, totxt:seq.word
, e:stkinfo
, combinedDef:seq.word
, content1:seq.word
, noclass:boolean
) seq.word
for acc10 = other, stk = empty:stack.seq.word, ele ∈ totxt
do
 if ele ∈ "=" then
  if isempty.stk then next(acc10, push(stk, "bottom"))
  else next(acc10 + top.stk, empty:stack.seq.word)
 else if not.isempty.stk then
  let newstk =
   if ele ∈ "/pre" then
    let args = top(stk, 2),
    push(pop(stk, 2), rmprefix(args sub 1, args sub 2))
   else if ele ∈ "/post" then
    let args = top(stk, 2),
    push(pop(stk, 2), rmpostfix(args sub 1, args sub 2))
   else if ele ∈ "/mark" then if n.top.stk = 1 then stk else push(pop.stk, "//" + top.stk)
   else
    let tmp = getAttr(tagcontent.e, [ele]),
    push(stk, if isempty.tmp then extractdef(combinedDef, ele) else tmp),
  next(acc10, newstk)
 else
  next(
   acc10
    + (if ele ∈ "content" then content1
   else if ele ∈ "class" then
    let key = if noclass then baseon.info.e else key.info.e,
    if key ∈ "/p" then ""
    else if key ∈ "/br" then
     "/sp /tag
     /br /sp
     /br"
    else [key]
   else if ele
   ∈ "/br
   /p" then if subseq(acc10, n.acc10, n.acc10) = "/p" then "" else [ele]
   else
    let tmp = getAttr(tagcontent.e, [ele]),
    if isempty.tmp then "" else "//" + tmp + merge("/" + ele)
   )
   , stk
  ),
acc10

function evaldef(
smallacc:seq.word
, defs:seq.word
, content:seq.word
, replacements:set.classinfo
, xhtml:boolean
) seq.word
{???? needs work. change so calculation of values is between =. change /url to pre and post}
let name = "output" sub 1
for
 stk = empty:stack.seq.word
 , acc = smallacc
 , intag = false
 , last = ""
 , e ∈ extractdef(defs, name) + "?"
do
 if isempty.last then next(stk, acc, intag, [e])
 else
  let info = lookuptag(replacements, last sub 1),
  if not.isempty.info then
   if isendtag.info sub 1 then
    let new = if xhtml ∨ last ≠ "</p>" then acc + "/tag" + last + "/sp" else acc,
    next(stk, new, intag, [e])
   else
    let acc1 =
     if last sub 1 ∈ "<sub <sup" then if last.acc ∈ "/tag" then acc + last else acc + "/tag" + last
     else acc + "/sp /tag" + last + "/sp",
    next(stk, acc1, true, [e])
  else if last = ">" then next(stk, acc + "/tag >", false, [e])
  else if last = "/>" then next(stk, acc + (if xhtml then "/tag />" else ">"), false, [e])
  else if not.isempty.stk then
   if last = "/url" then
    assert n.toseq.stk = 4 report "XXX"
    let args = top(stk, 4)
    let t = %.subseq(args, 2, 4),
    let val = if subseq(t, 1, 2) = ".." then ".." + merge(t << 2) else [merge.t],
    next(pop(stk, 4), acc + attribute(val, (args sub 1) sub 1), intag, [e])
   else
    let value = extractdef(defs, last sub 1, content)
    let value2 =
     if subseq(value, n.value, n.value) = "/tag" then
      assert false report "here 456",
      value >> 1
     else value,
    assert last sub 1 ∈ "prefix content postfix href ?" report extractdef(defs, name) + "in eval:(last)" + esc.value,
    next(push(stk, value2), acc, intag, [e])
  else if intag then
   if e ∉ "=" then
    let val = extractdef(defs, last sub 1, content),
    next(stk, acc + attribute(val, last sub 1), intag, [e])
   else next(push(stk, last), acc, intag, "")
  else next(stk, acc + extractdef(defs, last sub 1, content), intag, [e]),
acc

function attribute(val:seq.word, att:word) seq.word
if isempty.val then ""
else "/sp:(att) /tag =:(if {n.val > 1} true then dq.val else val)"

function extractdef(defs:seq.word, name:word, content:seq.word) seq.word
if name ∈ "content" then content
else if name ∈ "colon" then ": "
else extractdef(defs, name)

Function showZ(out:seq.word) seq.word
for acc = "", w ∈ out
do
 acc
  + if w
 ∈ "/tag /sp <* *> /cell
 /row
 /br
 /p" then encodeword(decodeword.w + char1."Z")
 else w,
acc 
