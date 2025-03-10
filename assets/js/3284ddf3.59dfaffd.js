"use strict";(self.webpackChunkscout_docs=self.webpackChunkscout_docs||[]).push([[21],{82:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/images/matrix-f_sharp-97db287e089fb133039c3aaa7dcec79c.png"},420:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/files/matrix-ce640ae3f304c5a0741ea7217c39c2b2.png"},1264:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/files/chord-edc-a990320844d6d87aad08600f241ebfde.png"},2021:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/files/matrix-trio-f394787ec815be24dd67b81fe8e43ce7.png"},5014:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/images/chord-cde-cf0be930ccf28f7421ea390fc94e4e58.png"},5346:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/images/matrix-ce640ae3f304c5a0741ea7217c39c2b2.png"},5532:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/files/matrix-f_sharp-97db287e089fb133039c3aaa7dcec79c.png"},6798:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/images/chord-edc-a990320844d6d87aad08600f241ebfde.png"},7221:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/files/chord-individual-d1b8d3daf964bb003c8c19e5a45bf169.png"},7571:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/images/chord-individual-d1b8d3daf964bb003c8c19e5a45bf169.png"},8453:(e,t,n)=>{n.d(t,{R:()=>o,x:()=>h});var s=n(6540);const i={},r=s.createContext(i);function o(e){const t=s.useContext(r);return s.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function h(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),s.createElement(r.Provider,{value:t},e.children)}},8879:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/images/matrix-trio-f394787ec815be24dd67b81fe8e43ce7.png"},8931:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>h,default:()=>a,frontMatter:()=>o,metadata:()=>s,toc:()=>d});const s=JSON.parse('{"id":"the-chord-problem","title":"The chord problem","description":"Sometimes playing specific chords","source":"@site/docs/the-chord-problem.md","sourceDirName":".","slug":"/the-chord-problem","permalink":"/scout/the-chord-problem","draft":false,"unlisted":false,"tags":[],"version":"current","frontMatter":{"id":"the-chord-problem","title":"The chord problem","description":"Sometimes playing specific chords","sidebar_label":"The chord problem","image":"/img/scout-10-838-032.gif","slug":"/the-chord-problem"},"sidebar":"someSidebar","previous":{"title":"Opening the enclosure","permalink":"/scout/opening-the-enclosure"},"next":{"title":"Schematics","permalink":"/scout/schematics"}}');var i=n(4848),r=n(8453);const o={id:"the-chord-problem",title:"The chord problem",description:"Sometimes playing specific chords",sidebar_label:"The chord problem",image:"/img/scout-10-838-032.gif",slug:"/the-chord-problem"},h=void 0,c={},d=[{value:"Reproduce the issue",id:"reproduce-the-issue",level:2},{value:"Debugging with the serial monitor",id:"debugging-with-the-serial-monitor",level:2},{value:"Checking the schematic",id:"checking-the-schematic",level:2},{value:"A matrix of keys",id:"a-matrix-of-keys",level:3},{value:"Connecting rows and columns",id:"connecting-rows-and-columns",level:3},{value:"Is it a bug?",id:"is-it-a-bug",level:2},{value:"Homework",id:"homework",level:3}];function l(e){const t={a:"a",em:"em",h2:"h2",h3:"h3",img:"img",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,r.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(t.p,{children:"The Scout is monophonic; it can only play one note at a time. If you try to hold multiple notes simultaneously, it tries to do what's called \"last note priority\" and only plays the most recently held key's note."}),"\n",(0,i.jsx)(t.p,{children:"But sometimes, specific chords or sets of keys seem to add a note that you hadn't anticipated."}),"\n",(0,i.jsx)(t.h2,{id:"reproduce-the-issue",children:"Reproduce the issue"}),"\n",(0,i.jsxs)(t.ol,{children:["\n",(0,i.jsxs)(t.li,{children:["Play the first three white keys individually in succession. ",(0,i.jsx)(t.strong,{children:"C"}),", then ",(0,i.jsx)(t.strong,{children:"D"}),", then ",(0,i.jsx)(t.strong,{children:"E"}),". They should sound exactly as you'd expect."]}),"\n",(0,i.jsxs)(t.li,{children:["Now, play them together. ",(0,i.jsx)(t.strong,{children:"C"})," ",(0,i.jsx)(t.em,{children:"and"})," ",(0,i.jsx)(t.strong,{children:"D"})," ",(0,i.jsx)(t.em,{children:"and"})," ",(0,i.jsx)(t.strong,{children:"E"}),"."]}),"\n",(0,i.jsxs)(t.li,{children:["Notice that it plays a totally different note at the end there instead of ",(0,i.jsx)(t.strong,{children:"E"}),". If you continue playing keys up individually, you'll discover that we got an ",(0,i.jsx)(t.strong,{children:"F#"})," at the end instead of the E we were expecting."]}),"\n",(0,i.jsxs)(t.li,{children:["Now play the same run of those first three white keys but in the reverse order. ",(0,i.jsx)(t.strong,{children:"E"})," ",(0,i.jsx)(t.em,{children:"and"})," ",(0,i.jsx)(t.strong,{children:"D"})," ",(0,i.jsx)(t.em,{children:"and"})," ",(0,i.jsx)(t.strong,{children:"C"}),"."]}),"\n",(0,i.jsxs)(t.li,{children:["Again, notice that the third note at the end is ",(0,i.jsx)(t.strong,{children:"F#"}),"."]}),"\n"]}),"\n",(0,i.jsx)(t.p,{children:"Super weird, right? Why is this happening?"}),"\n",(0,i.jsx)(t.h2,{id:"debugging-with-the-serial-monitor",children:"Debugging with the serial monitor"}),"\n",(0,i.jsxs)(t.p,{children:["If we ",(0,i.jsx)(t.a,{href:"/scout/change-the-arduino-code#serial-debugging",children:"log out the indexes of the buttons"})," being pressed and play ",(0,i.jsx)(t.strong,{children:"C"}),", ",(0,i.jsx)(t.strong,{children:"D"}),", ",(0,i.jsx)(t.strong,{children:"E"})," individually it looks like this:"]}),"\n",(0,i.jsx)(t.p,{children:(0,i.jsx)(t.a,{target:"_blank","data-noBrokenLinkCheck":!0,href:n(7221).A+"",children:(0,i.jsx)(t.img,{alt:"Screengrab of the Arduino serial monitor while playing C, D, and E individually",src:n(7571).A+"",width:"911",height:"694"})})}),"\n",(0,i.jsxs)(t.p,{children:["Makes sense. ",(0,i.jsx)(t.strong,{children:"0"})," is ",(0,i.jsx)(t.strong,{children:"C"}),", ",(0,i.jsx)(t.strong,{children:"2"})," is ",(0,i.jsx)(t.strong,{children:"D"}),", and ",(0,i.jsx)(t.strong,{children:"4"})," is ",(0,i.jsx)(t.strong,{children:"E"}),". That's just what we expected! (In code, we order lists starting at 0 instead of 1, so the indexes of the list of 17 keys go from 0 to 16, not 1 to 17.)"]}),"\n",(0,i.jsx)(t.p,{children:"But holding them together looks like this:"}),"\n",(0,i.jsx)(t.p,{children:(0,i.jsx)(t.a,{target:"_blank","data-noBrokenLinkCheck":!0,href:n(9544).A+"",children:(0,i.jsx)(t.img,{alt:"Screengrab of the Arduino serial monitor while playing C, D, and E together",src:n(5014).A+"",width:"911",height:"694"})})}),"\n",(0,i.jsxs)(t.p,{children:["The ",(0,i.jsx)(t.strong,{children:"0"}),", ",(0,i.jsx)(t.strong,{children:"2"}),", ",(0,i.jsx)(t.strong,{children:"4"})," are in there (reverse ordered but that's irrelevant) but we also see a fourth index, ",(0,i.jsx)(t.strong,{children:"6"}),". That's the index of the ",(0,i.jsx)(t.strong,{children:"F#"})," key."]}),"\n",(0,i.jsxs)(t.p,{children:["Playing and holding ",(0,i.jsx)(t.strong,{children:"E"}),", ",(0,i.jsx)(t.strong,{children:"D"}),", ",(0,i.jsx)(t.strong,{children:"C"})," is the same with a different order:"]}),"\n",(0,i.jsx)(t.p,{children:(0,i.jsx)(t.a,{target:"_blank","data-noBrokenLinkCheck":!0,href:n(1264).A+"",children:(0,i.jsx)(t.img,{alt:"Screengrab of the Arduino serial monitor while playing E, D, and C together",src:n(6798).A+"",width:"911",height:"694"})})}),"\n",(0,i.jsxs)(t.p,{children:["That doesn't solve our problem, but it does tell us that the microcontroller is indeed interpreting that the ",(0,i.jsx)(t.strong,{children:"C"}),", ",(0,i.jsx)(t.strong,{children:"D"}),", and ",(0,i.jsx)(t.strong,{children:"E"})," keys are being pressed but, for some reason, incorrectly ",(0,i.jsx)(t.em,{children:"adding"})," the ",(0,i.jsx)(t.strong,{children:"F#"}),"."]}),"\n",(0,i.jsx)(t.h2,{id:"checking-the-schematic",children:"Checking the schematic"}),"\n",(0,i.jsx)(t.h3,{id:"a-matrix-of-keys",children:"A matrix of keys"}),"\n",(0,i.jsx)(t.p,{children:"The Scout has 17 keys but they only take up 9 pins on the ATmega328. It does this by convincing the microcontroller that the 17 keys are arranged in a matrix of rows and columns: 4 rows * 5 columns = 20 possible keys."}),"\n",(0,i.jsx)(t.p,{children:"When a key is pressed and its switch closes, the pins for its row and column connect."}),"\n",(0,i.jsxs)(t.p,{children:["The matrix of rows and columns with the notes labelled, read from top to bottom and ",(0,i.jsx)(t.em,{children:"then"})," left to right:"]}),"\n",(0,i.jsx)(t.p,{children:(0,i.jsx)(t.a,{target:"_blank","data-noBrokenLinkCheck":!0,href:n(420).A+"",children:(0,i.jsx)(t.img,{alt:"Matrix schematic with switches labelled to their corresponding notes",src:n(5346).A+"",width:"2067",height:"1220"})})}),"\n",(0,i.jsxs)(t.ul,{children:["\n",(0,i.jsxs)(t.li,{children:[(0,i.jsx)(t.strong,{children:"Note 1:"})," The ATmega328 only has 14 digital input/output (IO) pins, which wouldn't be enough for all the keys if they were wired individually. There are other ways besides a matrix to get more IO out of our chip but they all require soldering more components."]}),"\n",(0,i.jsxs)(t.li,{children:[(0,i.jsx)(t.strong,{children:"Note 2:"})," The 3 remaining, unused matrix spots in the bottom right are available for use on the ",(0,i.jsx)(t.a,{href:"/scout/change-the-arduino-code#pins",children:'"HACK" header'}),"."]}),"\n",(0,i.jsxs)(t.li,{children:[(0,i.jsx)(t.strong,{children:"Note 3:"})," Awkwardly, the hardware components for the notes are indexed from SW2 to SW18, because only the code uses zero-indexing and the on/off switch was SW1. Thankfully, at least they are still in linear order!"]}),"\n"]}),"\n",(0,i.jsx)(t.h3,{id:"connecting-rows-and-columns",children:"Connecting rows and columns"}),"\n",(0,i.jsxs)(t.p,{children:["We can see that ",(0,i.jsx)(t.strong,{children:"C"})," is ",(0,i.jsx)(t.strong,{children:"R1C1"})," (Row 1, column 1), ",(0,i.jsx)(t.strong,{children:"D"})," is ",(0,i.jsx)(t.strong,{children:"R3C1"}),", and ",(0,i.jsx)(t.strong,{children:"E"})," is ",(0,i.jsx)(t.strong,{children:"R1C2"}),"."]}),"\n",(0,i.jsx)(t.p,{children:(0,i.jsx)(t.a,{target:"_blank","data-noBrokenLinkCheck":!0,href:n(2021).A+"",children:(0,i.jsx)(t.img,{alt:"Matrix schematic with C, D, and E matrix points highlighted",src:n(8879).A+"",width:"2067",height:"1220"})})}),"\n",(0,i.jsxs)(t.p,{children:["But to the microcontroller, it also sure looks like you're pressing ",(0,i.jsx)(t.strong,{children:"F#"})," at ",(0,i.jsx)(t.strong,{children:"R3C2"}),". I mean, how could it know you're not? So it just throws it in there."]}),"\n",(0,i.jsx)(t.p,{children:(0,i.jsx)(t.a,{target:"_blank","data-noBrokenLinkCheck":!0,href:n(5532).A+"",children:(0,i.jsx)(t.img,{alt:"Matrix schematic with C, D, and E matrix points highlighted",src:n(82).A+"",width:"2067",height:"1220"})})}),"\n",(0,i.jsx)(t.p,{children:"That's the culprit!!"}),"\n",(0,i.jsx)(t.h2,{id:"is-it-a-bug",children:"Is it a bug?"}),"\n",(0,i.jsxs)(t.p,{children:['Issues like this "chord problem" are normally avoided on more complex matrix circuits like your computer keyboard with diodes along the switches, but these were ommitted on the Scout to cut down on kit cost and assembly time. The Scout\'s monophony was an intentional limitation to deter encountering it. After all, ',(0,i.jsx)(t.em,{children:"it is supposed to be simple instrument"}),"!"]}),"\n",(0,i.jsxs)(t.p,{children:["So it's ",(0,i.jsx)(t.em,{children:"kind of"})," a bug but ",(0,i.jsx)(t.em,{children:"more"}),' like a "known issue" and a cost to be paid for the simplicity of the Scout\'s assembly.']}),"\n",(0,i.jsx)(t.h3,{id:"homework",children:"Homework"}),"\n",(0,i.jsx)(t.p,{children:'Looking at the matrix schematic, can you find other key combinations that will have the "chord problem"?'})]})}function a(e={}){const{wrapper:t}={...(0,r.R)(),...e.components};return t?(0,i.jsx)(t,{...e,children:(0,i.jsx)(l,{...e})}):l(e)}},9544:(e,t,n)=>{n.d(t,{A:()=>s});const s=n.p+"assets/files/chord-cde-cf0be930ccf28f7421ea390fc94e4e58.png"}}]);