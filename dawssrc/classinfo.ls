Module classinfo

use bits

use seq.char

use seq.classinfo

use set.classinfo

use sort.classinfo

use standard

Export type:classinfo

Export type:tagorder

Export key(classinfo) word

Export baseon(classinfo) word

Export def(classinfo) seq.word

Export tag(classinfo) word

Export toseq(tagorder) seq.classinfo

type classinfo is key:word, baseon:word, def:seq.word, tag:word, flags:bits

type tagorder is toseq:seq.classinfo

The set.classinfo will be ordered by key. The taginfo will be ordered by tag. 

Function totagorder(a:seq.classinfo) tagorder tagorder.sort>3.a

Function lookuptag(lst:set.classinfo, tag:word) seq.classinfo
lookuptag(totagorder.toseq.lst, tag)

Function lookupkey(lst:set.classinfo, key:word) seq.classinfo
toseq.lookup(lst, classinfo(key, key, "", key, tobits.0))

Function lookuptag(s:tagorder, tag:word) seq.classinfo
let j = binarysearch>3(toseq.s, classinfo(tag, tag, "", tag, tobits.0)),
if j < 0 then empty:seq.classinfo
else
 for low = j, high = j, up = true, down = true
 while up ∨ down
 do
  let newdown = low > 1 ∧ tag = tag.(toseq.s) sub (low - 1)
  let newup = high < n.toseq.s ∧ tag = tag.(toseq.s) sub (high + 1)
  let newlow = if newdown then low - 1 else low,
  let newhigh = if newup then high + 1 else high,
  next(newlow, newhigh, newup, newdown),
 subseq(toseq.s, low, high)

Function %(a:classinfo) seq.word esc.[key.a, baseon.a, tag.a] + def.a

Function >1(a:classinfo, b:classinfo) ordering >1(key.a, key.b)

function >3(a:classinfo, b:classinfo) ordering >1(tag.a, tag.b)

function =(a:classinfo, b:classinfo) boolean key.a = key.b

Function tokey(w:word) word
let a = decodeword.w,
if a sub 2 = char1."/" then w else encodeword([char1."/"] + decodeword.w << 1)

Function esc(z:seq.word) seq.word
for dd = "", e ∈ z
do
 if e
 ∈ "/p
 /br /sp /tag" then dd + "/sp /tag:(e) /sp"
 else dd + e,
dd

Function removeesc(z:seq.word) seq.word
for dd = "", e ∈ z
do
 if e
 ∈ "/p
 /br /sp /tag"
 ∧ subseq(dd, n.dd - 1, n.dd) = "/sp /tag" then dd >> 2 + e
 else dd + e,
dd

Function classinfo(base:set.classinfo, str:seq.word) seq.classinfo
for acc = empty:seq.classinfo, s ∈ break(str, ",", false)
do
 assert n.s > 1 report "replacements too short" + esc.s
 let key = s sub 1,
 let basekey = s sub 2,
 if key = basekey then acc
 else
  let t = decodeword.key
  assert t sub 1 = char1."/" report "incorrect class spec:(key) full string" + str
  let class = encodeword(t << 1)
  let info2 = lookupkey(base, basekey)
  assert not.isempty.info2 report esc."no base class key basekey:" + basekey + "key:" + key,
  let basedef = info2 sub 1,
  acc + classinfo(key, basekey, "class: " + class + s << 2, tag.basedef, flags.basedef),
acc

Function classinfo(base:set.classinfo, ele:word, class:word, more:seq.word) classinfo
let basekey = merge("/" + ele)
let key = merge("/" + class)
let info2 = lookupkey(base, basekey)
assert not.isempty.info2 report esc."no base class key basekey:" + basekey + "key:" + key
let basedef = info2 sub 1,
classinfo(key, basekey, "class: " + class + more, tag.basedef, flags.basedef)

function mktag(str:seq.word) seq.classinfo
let key = str sub 1
let ele = decodeword.str sub 1 << 1
let endtag = encodeword([char1."<", char1."/"] + ele + char1.">")
let tag = encodeword([char1."<"] + ele)
let hasmark2 = key ∈ "/em /strong /b /i /q /span /caption /a /sub /sup /img /link"
let markbit = tobits(if hasmark2 then 2 else 0)
let a = classinfo(key, key, str << 1, tag, markbit),
if noendtag.a ∨ isdefine.a then [a]
else if hasmark2 then [a, classinfo(endtag, tag, "", endtag, tobits.1 ∨ markbit)]
else [a, classinfo(endtag, tag, "", endtag, tobits.1)]

Function ismark(a:classinfo) boolean (flags.a ∧ bits.2) = bits.2

Function noendtag(a:classinfo) boolean tag.a ∈ "<!doctype <! <link <meta <br <img <hr <?xml"

Function isendtag(a:classinfo) boolean (flags.a ∧ bits.1) = bits.1

Function isdefine(a:classinfo) boolean n.def.a > 3 ∧ (def.a) sub 1 = baseon.a

Function defaults seq.classinfo
let t =
 mktag."/q output: <q class id > content </q> totxt:content class"
  + mktag."/b output: <b class id > content </b> totxt:content class"
  + mktag."/i output: <i class id > content </i> totxt:content class"
  + mktag."/em output: <em class id > content </em> totxt:content class"
  + mktag."/strong output: <strong class id > content </strong> totxt:content class"
  + mktag."/span output: <span class id > content </span> totxt:content class"
  + mktag."/caption output: <caption class id > content </caption> totxt:content class"
  + mktag."/a output: <a class id href = ? href ? /url > content </a> totxt:content href class"
  + mktag."/sub output: <sub class id > content </sub> totxt:content class"
  + mktag."/sup output: <sup class id > content </sup> totxt:content class"
  + mktag."/!doctype"
  + mktag."/meta"
  + mktag."/!"
  + mktag."/html"
  + mktag."/body"
  + mktag."/?xml"
  + mktag."/head <body>: /tag <body> output: <head > content </head> <body> totxt: content"
  + mktag."/link rel: stylesheet output:<link rel href = ? content ? /url /> totxt: = href /mark = class"
  + mktag."/title output: <title class > content </title> totxt: content class
 /br"
  + mktag."/hr output: <hr class /> totxt: 
 /p content class"
  + mktag."/br output: content <br class id /> totxt: content id class
 /br"
  + mktag."/img alt: a picture output: <img class id alt src = prefix content postfix /url /> totxt:= prefix src postfix /post /pre /mark = id class"
  + mktag."/style"
  + mktag."/p output: <p class id > content </p> totxt: 
 /p content id class
 /p"
  + mktag."/h1 output: <h1 class id > content </h1> totxt: 
 /p content id class"
  + mktag."/h2 output: <h2 class id > content </h2> totxt: 
 /p content id class"
  + mktag."/h3 output: <h3 class id > content </h3> totxt: 
 /p content id class"
  + mktag."/h4 output: <h4 class id > content </h4> totxt: 
 /p content id class"
  + mktag."/h5 output: <h5 class id > content </h5> totxt: 
 /p content id class"
  + mktag."/h6 output: <h6 class id > content </h6> totxt: 
 /p content id class"
  + mktag."/table output: <table class id > content </table> totxt: 
 /p content id class"
  + mktag."/li output: <li class id > content totxt: 
 /p content id class
 /p"
  + mktag."/ol output: <ol class id > content </ol> totxt: 
 /p content id class
 /p"
  + mktag."/ul output: <ul class id > content </ul> totxt: 
 /p content id class"
  + mktag."/div output: <div class id > content </div> /div: /div totxt: 
 /p = /div = content id class"
  + mktag."/tr output: <tr class id > content </tr> totxt: content id class
 /br"
  + mktag."/td output: <td class id > content </td> totxt: content id class"
  + mktag."/th output: <th class id > content </th> totxt: content id class"
  + mktag."/href /href: href output: /href colon content"
  + mktag."/id /id: id output: /id colon content"
  + mktag."/rel /rel: rel output: /rel colon content"
{for et ="", e ∈ t do for acc ="", intag = false, invalue = false, w ∈ extractdef (def.e," output" sub 1) do if intag then if w ∈" >" then next (acc, false, false) else if w ∈" =" then next (acc, intag, true) else if w ∈" /url" then next (acc, intag, false) else if invalue then next (acc, intag, invalue) else next (acc+w, intag, invalue) else let info = lookuptag (asset.t, w) next (acc, not.isempty.info ∧ not.isendtag.info sub 1, false) et+acc assert false report toseq.(asset.et-" class" sub 1)}
t

Function extractdef(defs:seq.word, name:word) seq.word
for notdone = true, inquote = false, found = false, acc = "", e ∈ defs + "dummy:"
while notdone ∨ inquote
do
 if found then
  if acc = "" ∧ e ∈ "'" then next(notdone, true, found, acc)
  else if e ∈ ":: " then
   if not.inquote then next(false, false, found, acc >> 1)
   else if subseq(acc, n.acc - 1, n.acc - 1) = "'" then next(false, false, found, acc >> 2)
   else next(notdone, inquote, found, acc + e)
  else next(notdone, inquote, found, acc + e)
 else if not.inquote then
  if e = name then next(notdone, inquote, found, [e])
  else if e ∈ ":: " then
   if name ∈ subseq(acc, 1, 1) then {found} next(notdone, inquote, true, "")
   else next(notdone, inquote, found, ":")
  else if e ∈ "'" ∧ acc ∈ [": ", ":"] ∧ e ∈ "'" then next(notdone, true, false, "")
  else next(notdone, inquote, found, [e])
 else
  {inquote = true ∧ found = false:: only save the last few characters in acc}
  if e ∈ "'" then next(notdone, inquote, found, [e])
  else if subseq(acc, 1, 1) = "'" ∧ n.acc = 2 ∧ e ∈ ":: " then
   {end of quote}
   if name ∈ subseq(acc, 2, 2) then {found} next(notdone, false, true, "")
   else next(notdone, false, found, ":")
  else next(notdone, inquote, found, subseq(acc, n.acc, n.acc) + e),
if not.found then "" else acc

function unittest boolean
let tests =
 [
  ["abc:' output: not this ' output: this one", "this one"]
  , ["abc:output output: ' this: one '", "this: one"]
  , ["abc:output output: ' this:' one '", "this:' one"]
  , ["output: first output output:second output", "first output"]
  , ["abc:output output: this one", "this one"]
 ]
for acc = "", t ∈ tests
do
 let a = extractdef(t sub 1, "output" sub 1)
 assert a = t sub 2 report "failed" + t sub 1 + "/p should be:" + t sub 2 + "/p got:" + a,
 acc,
true 
