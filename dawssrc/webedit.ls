Module webedit

use JS.HTTPresult

use bits

use seq.byte

use classinfo

use seq.classinfo

use set.classinfo

use daws

use file

use seq.file

use kernal

use real

use seq.real

use seq1.real

use standard

use webIO

use webIOtypes

use JS.HTTPstate.seq.word

use seq1.seq.word

use webHTTP.seq.word

use seq1.word

Export HTTPwords(h2:JS.HTTPstate.seq.word, h:JS.HTTPresult) real
{???? this is a very important export to have. otherwise file reading does not work!}

Function batch real
{???? had to use primitive get and set because other ones use towords which only works for single paragraph}
let cssbytes = toseqbyte.getElementValue:jsbytes("file-css")
let discard = setElementValue("message", ""),
if n.cssbytes = 0 then setElementValue("message", "Please select a css file")
else
 let classinfo = processCSS.cssbytes
 let bytes = toseqbyte.getElementValue:jsbytes("file-content"),
 if n.cssbytes = 0 then setElementValue("message", "Please select a html file")
 else
  let txt = processHTML(bytes, classinfo),
  setElementValue("file-content", jsUTF8.txt)

Function test5 real
let data = toseqbyte.getElementValue:jsbytes("file-content")
let discard =setElementValue("message", "got data")
let classinfo = processCSS.toseqbyte.getElementValue:jsbytes("file-css"),
let discard1 =setElementValue("message", "processedCCS")
let a=processTXT(data, asset.classinfo, false, "en")
let discard2 =setElementValue("message", "processedTXT")
setElementValue("file-html", jsUTF8.a)

Function webedit real setElementValue("message", "ready")

function showZ(out:seq.word) seq.word
for acc = "", w ∈ out do acc + encodeword(decodeword.w + char1."Z"),
acc 
