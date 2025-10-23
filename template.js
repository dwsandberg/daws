
function printcontext(){
    function p2(x){
      if (x == 0) return "none" ;
      let  i32 = new Uint32Array(memory.buffer, x, 2);
      let i32b= new Uint32Array(memory.buffer, i32[0] , 12);
      let txt="instance "+ i32[0].toString(16)+"  OP:"+ i32[1].toString(16);
       txt+=" encodeno "+i32b[0].toString(16);
       txt+=" size "+i32b[2].toString(16);
       txt+=" etable "+i32b[4].toString(16);
       txt+=" dtable "+i32b[5].toString(16);
       txt+=" all"+i32b[6].toString(16);
       txt+=" last"+i32b[8].toString(16);
    //  return " instance "+ i32[0].toString(16)+"  OP:"+ i32[1].toString(16);  
     return txt;
   }

  function used(x) {
	    let t=(x) & 0xFFFF0000;
   	        let chain= "";
      	 	    while(t  != 0) { chain+=" "+(t >> 16).toString(16);
      	 	 	   let i32a= new Uint32Array(memory.buffer, t, 4);
      	 	 	   t=i32a[0];  
      	 	      }
      	 	     return chain;}
  let  i32 = new Uint32Array(memory.buffer, 0, 6);
  let  i32cp = new Uint32Array(memory.buffer, i32[3], 16);
  let  i32pp = new Uint32Array(memory.buffer, i32cp[3], 16);
  console.log( " NF:"+i32[1].toString(16)+" LF:"+i32[2].toString(16)+
                " FB:"+used(i32[4]) 
               +" \nCP:"+i32[3].toString(16) + 
                " E1 "+ p2(i32cp[5]) 
      	 +" E2 "+ p2(i32cp [6]) 
     	 +" E3 "+ p2(i32cp [7])   
     	 + " used "+used( i32[2])
     	 +" \nPP:"+i32cp[3].toString(16)
     	 +"NF:"+i32pp[1].toString(16)+" LF:"+i32pp[2].toString(16)
          + " E1 "+ p2(i32pp[5]) 
      	 +" E2 "+ p2(i32pp [6]) 
     	 +" E3 "+ p2(i32pp [7])   
  		 + " used "+used( i32pp[2])
      +" \n PP:"+i32pp[3].toString(16)
     	 ); 
   }



  var memory;  var exports;  var inprogress=0;
  
function select(evt,actionfunc) {
  let id=evt.target.id
  if (id != 'undefined' )  actionfunc(jsstring2UTF8bytes(id)); 
}
 
function makeDraggable(evt,drawfunc) {
        var svg = evt.target;
  var selectedElement, offset, transform,attx,atty ;
 
svg.addEventListener('mousedown', startDrag);
svg.addEventListener('mousemove', drag);
svg.addEventListener('mouseup', endDrag);
svg.addEventListener('mouseleave', endDrag);
svg.addEventListener('touchstart', startDrag);
svg.addEventListener('touchmove', drag);
svg.addEventListener('touchend', endDrag);
svg.addEventListener('touchleave', endDrag);
svg.addEventListener('touchcancel', endDrag);
 
 
       function getMousePosition(evt) {
            var CTM = svg.getScreenCTM();
            if (evt.touches) { evt = evt.touches[0]; }
            return {
              x: (evt.clientX - CTM.e) / CTM.a,
              y: (evt.clientY - CTM.f) / CTM.d
            };
         }
 
     function startDrag(evt) { 
    if (evt.target.classList.contains('draggable')) {
     selectedElement = evt.target ;
      attx=   evt.target.tagName=="circle" ? "cx":"x";
      atty=  evt.target.tagName=="circle" ? "cy":"y" ;
      offset = getMousePosition(evt);
      offset.x -= parseFloat(selectedElement.getAttributeNS(null, attx));
      offset.y -= parseFloat(selectedElement.getAttributeNS(null, atty));
    }
  }
          
function drag(evt) {
    if (selectedElement) {
      evt.preventDefault();
      var coord = getMousePosition(evt);
      selectedElement.setAttributeNS(null, attx, coord.x - offset.x);
      selectedElement.setAttributeNS(null, atty, coord.y - offset.y);
      	 let id=selectedElement.id;
      	 if (id != 'undefined' )
      	  drawfunc(jsstring2UTF8bytes(id));     
     }
 }
  
 function endDrag(evt) {selectedElement = false;}
}
  
function tobytearray(data,nobits)  { 
   let i32a = new Uint32Array(memory.buffer, data, 16);
//   console.log("tobytearray"+i32a[0]+" "+i32a[2]);
    if (i32a[0] >= 3) {  
      let i32= new Uint32Array(memory.buffer, i32a[4], 4); 
      let total=i32a[2];
      let blksize=i32[2];
      let j=4;
      let arr=new Array(0);
      let offset=0;
      while( total > 0) { 
//        console.log("L"+(total > blksize ?blksize:total));
       arr.push(...new Uint8Array(memory.buffer,i32a[j]+16, (total > blksize ?blksize:total) * nobits / 8 )) ;
       j=j+2; total=total-blksize
      }
       let t=new Uint8Array(arr);
//       console.log("JK"+t.length+" "+i32a[2]);
       return t;
       }
     else {
       return  new Uint8Array(memory.buffer, data+16,i32a[2] * nobits / 8); 
    }}
  
function asjsstring ( offset){  
 let  utf8decoder = new TextDecoder();
 return  utf8decoder.decode(tobytearray(offset,8)) ;
 }

function jsstring2UTF8bytes(r){
  // console.log("js"+r);
   const encoder = new TextEncoder();
   const i8src = encoder.encode(r);
   let sp = exports.allocatespace3( (( i8src.length+7) / 8 + 2));
   let  i32a = new Uint32Array(memory.buffer, sp, 4); 
   i32a [ 0]= 1; i32a [1]=0; i32a [ 2]= i8src.length ; i32a [3]=0;
   let  i8dst = new Uint8Array(memory.buffer, sp + 16, i8src.length); 
   i8dst.set(i8src); 
   return sp;
}

function finaljsHTTP(data,nobits ){
  const blksize=8000;
 let size=data.byteLength;
 let offset=0;
 let noblks= Math.trunc((size+ 8* blksize -1 )/ (8*blksize));
 let i32blk =0;
 let blkidx=4;
 let blks=0;
 if (size >   (8 * blksize)){
     blks = exports.allocatespace3( (noblks + 2)); 
     i32blk = new Uint32Array(memory.buffer, blks, noblks*2+4); 
//   console.log("Asize:"+size+ ">"+ 8*blksize +":"+i32blk);
     i32blk[0]=exports.blockseqtype(); i32blk[1]=0; 
     i32blk [ 2]=8 / nobits * size ;  i32blk [ 3]=0;
  };
  while (size >0)   {
    let thisblocksize=size >   8*blksize ? 8*blksize :size;
    let  tausize = Math.trunc((thisblocksize+ 7)/ 8); 
 //     console.log("filesize:"+tausize+"b:"+noblks);
    let  sp = exports.allocatespace3((tausize + 2)); 
    let  i32a = new Uint32Array(memory.buffer, sp, 4); 
    i32a [ 0]= 64   == nobits ?0:1; i32a [ 1]= 0;
    i32a [ 2]= 8 / nobits *thisblocksize ;  i32a [ 3]= 0 ; 
    let  i8src = new Uint8Array(data, offset,   thisblocksize); 
    let  i8dst = new Uint8Array(memory.buffer, sp + 16, thisblocksize); 
    i8dst.set(i8src); 
    if (blks==0) {return sp; } 
    else {    
       i32blk = new Uint32Array(memory.buffer, blks, noblks*2+4); 
       i32blk[blkidx++]=sp;i32blk[blkidx++]=0; }
       size-= 8* blksize;
       offset+= 8* blksize;
   }
  return blks;  } 
  
 
 
 function pageinit(library,page) {
var importObject = { imports:{ 
  abortfunc:function(arg){ throw arg ; return document.getElementById("demo").innerHTML ="abort"; } 
, randomfunc: () =>  Math.floor(Math.random()* 10000000 ) 
, sin: arg =>  Math.sin(arg)  
, cos:arg =>  Math.cos(arg)  
, tan:arg =>   Math.tan(arg)  
, sqrt:arg =>    Math.sqrt(arg)  
, arcsin:arg =>   Math.asin(arg)  
, arccos:arg =>    Math.acos(arg) 
, clockReal:function(){return performance.now()}
, callprocess:function(wrapper, args){ 
 console.log("callprocess 1");
  try { return exports.processbody(wrapper, args); } 
  catch(err){ 
    var b; 
  console.log("catch err"+ err.message +"err"+"name:"+(err.name)); 
    if(err.message ===undefined){ b = err; } 
    else if(err.message.startsWith("Division")){ b = 0; } 
    else { b = 0; } 
    return exports.handleerror(b); } 
} 

, setelementvalue:function  (id ,textin ){
  let text=asjsstring(textin); 
  console.log("SETELEMENT"+text);   
  let  z = document.getElementById(asjsstring( id )); 
  /* replaced with switch below. 10/21/2025
  let  kind = z.tagName; 
   console.log("SETELEMENT"+text +kind);   
  if(kind==="TEXTAREA" || kind=="SELECT" )z.value =  text.trim();
  else if(kind==="INPUT") {
    if (z.type=="checkbox" ) 
       z.checked=   (text.trim() ==   "true"  ? "checked" : "" ); 
    else z.value=text.trim();}
  else z.innerHTML = text;*/
   switch(z.tagName) {
   case "SELECT":
   case "TEXTAREA": z.value =  text.trim(); break;
   case "PRE":z.textContent =  text.trim()
   case "INPUT": 
   if (z.type=="checkbox" ) 
       z.checked=   (text.trim() ==   "true"  ? "checked" : "" ); 
    else z.value=text.trim();  
    break;
    default:z.innerHTML = text;
    }
  return 0; 
}
  
, getelementvalue:function  (id){ 
  console.log("GETELEMENT"+asjsstring( id));   
  let  z = document.getElementById(asjsstring( id).trim()); 
  /* let  kind=z.tagName ;
  let r=""
  if (kind=="INPUT" & z.type=="radio")  
   { var ele = document.getElementsByName(z.name);
    for (i = 0; i < ele.length; i++) {
            if (ele[i].checked) r=ele[i].value;
        }
   }
  r=(kind=="TEXTAREA"  )? z.value:
         (kind=="INPUT")?   ( 
           ( z.type=="checkbox")?   z.checked :
           ( z.type=="radio")?   r :
             z.value):
         (kind=="SELECT")? z.value:   z.innerHTML ; 
   */
   switch(z.tagName) {
   case "SELECT":  
   case "TEXTAREA": r=z.value  ; break;
   case "PRE" : r=z.textContent; break;
   case "INPUT": 
        switch(z.type){ 
          case "checkbox":  r= z.checked ; break;
            case "radio":
                var ele = document.getElementsByName(z.name);
               for (i = 0; i < ele.length; i++)  
                  if (ele[i].checked) r=ele[i].value;
                break;
             default: r=z.value;
             }
    break;
    default: r=z.innerHTML  ;
    }
    console.log("GETELEMENT"+asjsstring( id)+"="+r);   
  return jsstring2UTF8bytes(r); 
}

,getattributes2:function(idbytes, attsbytes ) {
  let atts=asjsstring(attsbytes);
  let myArr = atts.trim().split(" ");
  let element=document.getElementById(asjsstring(idbytes).trim());
     console.log("getattributes2:"+asjsstring(idbytes));
  let result="";
  let i ;
  if(element instanceof SVGElement)  
    for( i=0; i <  myArr.length; i++)  {
       let thisatt= myArr[i].trim();
       if (thisatt=="BBwidth" )  result+=   element.getBBox().width+" ";
       else result+=element.getAttributeNS(null, thisatt  )+" ";
    }
  else 
    for( i=0; i <  myArr.length; i++)  { 
       let t=myArr[i].trim()
       if (t=="textContent"){
          console.log("SDF"+element.textContent);
        result+=element.textContent+" "; }
       else 
      result+=element.getAttribute( t )+" ";
    }
    return jsstring2UTF8bytes(result); 
}

,setattribute2:function (id, att   ,value   ){
// console.log("set "+asjsstring(id)+asjsstring(att )+asjsstring(value)); 
  let element=document.getElementById(asjsstring(id).trim());
  if(element instanceof SVGElement)  
    element.setAttributeNS(null,asjsstring(att ).trim(),asjsstring(value).trim());
  else element.setAttribute(asjsstring(att).trim(),asjsstring(value));
 return 0; 
}

,  callevent2:function (id,  event   ){
let a=document.getElementById(asjsstring(id).trim())
console.log("SDF"+a+"EVENT"+asjsstring(event).trim());
 a.dispatchEvent(new Event(asjsstring(event).trim()));
  return(0);
  }

, replacesvg: function(id, xml ){
  var doc=new DOMParser().parseFromString(
  '<svg xmlns="http://www.w3.org/2000/svg"> <g id="newnode">'+ 
  asjsstring(xml)+'</g> </svg>', 'application/xml');
  console.log("XML"+asjsstring(xml));
  var someElement=document.getElementById(asjsstring(id ).trim());
  if (someElement == null ) return 0;
  while (someElement.firstChild) {
   someElement.removeChild(someElement.firstChild);
  }
  someElement.appendChild(someElement.ownerDocument.importNode(doc.getElementById("newnode"), true));
  return 0;
}

 //    method:UTF8 header:UTF8 body:UTF8
 //      header: UTF8, body:T
   

 ,jsHTTP:function (url,methodx,data,followfunc,state) {
// only handles one header //
   var nobits=8;
   var responeheader="";
  let header=asjsstring(methodx);
    console.log("header"+header)
    console.log("jsHTTP1"+asjsstring(followfunc))
  method=header.split(" ")[0];
  if ( method == "NONE" ){ 
    exports[asjsstring(followfunc)](state);
    return 0;
  }
  inprogress++;
  let tmp=  header.slice(method.length);
  let parts=tmp.split(":");
  var headers = new Headers();
  if (parts.length==2) {  headers.append(parts[0].trim(), parts[1].trim());}
  fetch( asjsstring(url),
       { method, headers, body: (method=="GET" )? null : tobytearray(data,nobits  )  }   
       )
  .then( function (response)   {
    responeheader=response.status+" "+response.statusText+"\n";
    for (var pair of response.headers.entries()) {
      responeheader+=(pair[0]+ ': '+ pair[1]+"\n");
    }
    return response.arrayBuffer();
     })
  .then(function (result) {
    console.log(responeheader)
      let a=jsstring2UTF8bytes( responeheader);
      let b=finaljsHTTP(result,nobits);
      let rec  = exports.jsmakepair(b,a);
      console.log("jsHTTP2"+asjsstring(followfunc))
     inprogress--; exports[asjsstring(followfunc)](state,rec ); }) 
  }
  ,URLargs:function (){
    var args="";
 for (const p of new URLSearchParams(window.location.search)) {
  args=args+ p[0]+": "+p[1]+" "}
return  jsstring2UTF8bytes(args);}
, openWindow2:function(name){
let page=asjsstring(name);
    console.log("openwindow"+page);
window.open(page);
 return 0;
}

  
 } } ; 
  fetch(""+library+".wasm")
 .then(function(response){ return response.arrayBuffer()})
 .then(function(bytes){ return WebAssembly.instantiate(bytes, importObject)})
 .then(function(results){ 
   memory = results.instance.exports.memory ; 
   exports = results.instance.exports ; page ();});}
   
  