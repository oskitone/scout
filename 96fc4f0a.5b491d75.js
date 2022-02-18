(window.webpackJsonp=window.webpackJsonp||[]).push([[18],{165:function(e,t,r){"use strict";r.r(t),t.default=r.p+"assets/images/060201@0.5x-c48378d515f353edaa65c2db02a1aefc.jpg"},166:function(e,t,r){"use strict";r.r(t),t.default=r.p+"assets/images/060500@0.5x-176a9e0ac28ee5490bf4cbbfce15e8a3.jpg"},85:function(e,t,r){"use strict";r.r(t),r.d(t,"frontMatter",(function(){return i})),r.d(t,"metadata",(function(){return c})),r.d(t,"rightToc",(function(){return l})),r.d(t,"default",(function(){return u}));var n=r(3),o=r(7),a=(r(0),r(96)),i={id:"get-loud",title:"Get loud",description:"How to solder the Scout's amp to, you guessed it!, get loud.",sidebar_label:"Get loud",image:"/img/pcb_assembly/060500@0.5x.jpg",slug:"/get-loud"},c={unversionedId:"get-loud",id:"get-loud",isDocsHomePage:!1,title:"Get loud",description:"How to solder the Scout's amp to, you guessed it!, get loud.",source:"@site/docs/get-loud.md",slug:"/get-loud",permalink:"/scout/get-loud",version:"current",sidebar_label:"Get loud",sidebar:"someSidebar",previous:{title:"Make some noise",permalink:"/scout/make-some-noise"},next:{title:"More notes",permalink:"/scout/more-notes"}},l=[{value:"Steps",id:"steps",children:[]},{value:"Test",id:"test",children:[]}],s={rightToc:l};function u(e){var t=e.components,i=Object(o.a)(e,["components"]);return Object(a.b)("wrapper",Object(n.a)({},s,i,{components:t,mdxType:"MDXLayout"}),Object(a.b)("h2",{id:"steps"},"Steps"),Object(a.b)("ol",null,Object(a.b)("li",{parentName:"ol"},"Solder capacitors ",Object(a.b)("strong",{parentName:"li"},"C5")," (220uF) and ",Object(a.b)("strong",{parentName:"li"},"C6")," (.1uF, marked 104) and resistor ",Object(a.b)("strong",{parentName:"li"},"R4")," (1m, Brown Black Green; resistor body may be blue in your kit).",Object(a.b)("ul",{parentName:"li"},Object(a.b)("li",{parentName:"ul"},"Make sure ",Object(a.b)("strong",{parentName:"li"},"C5"),"'s polariy matches its footprint, just like ",Object(a.b)("strong",{parentName:"li"},"C1"),"."))),Object(a.b)("li",{parentName:"ol"},"Wire speaker to ",Object(a.b)("strong",{parentName:"li"},"LS1"),".",Object(a.b)("ol",{parentName:"li"},Object(a.b)("li",{parentName:"ol"},"Thread remaining ribbon cable through hole.\n",Object(a.b)("img",{alt:"060201@0.5x.jpg",src:r(165).default})),Object(a.b)("li",{parentName:"ol"},"Strip insulation and solder to ",Object(a.b)("strong",{parentName:"li"},"LS1"),"."),Object(a.b)("li",{parentName:"ol"},'Strip and solder the other ends to the speaker, matching the "+" and "-" sides.'))),Object(a.b)("li",{parentName:"ol"},"Solder socket ",Object(a.b)("strong",{parentName:"li"},"U2"),". Match its dimple to the footprint, just like ",Object(a.b)("strong",{parentName:"li"},"U1"),"."),Object(a.b)("li",{parentName:"ol"},"With the power off, carefully insert ",Object(a.b)("strong",{parentName:"li"},"LM386")," chip, again making sure its inserted the correct way.")),Object(a.b)("h2",{id:"test"},"Test"),Object(a.b)("p",null,"Power on, unplug your headphones, and press the switch. It should be playing out of the speaker now. Power off."),Object(a.b)("p",null,Object(a.b)("img",{alt:"060500@0.5x.jpg",src:r(166).default})))}u.isMDXComponent=!0},96:function(e,t,r){"use strict";r.d(t,"a",(function(){return p})),r.d(t,"b",(function(){return m}));var n=r(0),o=r.n(n);function a(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function i(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function c(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?i(Object(r),!0).forEach((function(t){a(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):i(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function l(e,t){if(null==e)return{};var r,n,o=function(e,t){if(null==e)return{};var r,n,o={},a=Object.keys(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||(o[r]=e[r]);return o}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(o[r]=e[r])}return o}var s=o.a.createContext({}),u=function(e){var t=o.a.useContext(s),r=t;return e&&(r="function"==typeof e?e(t):c(c({},t),e)),r},p=function(e){var t=u(e.components);return o.a.createElement(s.Provider,{value:t},e.children)},b={inlineCode:"code",wrapper:function(e){var t=e.children;return o.a.createElement(o.a.Fragment,{},t)}},d=o.a.forwardRef((function(e,t){var r=e.components,n=e.mdxType,a=e.originalType,i=e.parentName,s=l(e,["components","mdxType","originalType","parentName"]),p=u(r),d=n,m=p["".concat(i,".").concat(d)]||p[d]||b[d]||a;return r?o.a.createElement(m,c(c({ref:t},s),{},{components:r})):o.a.createElement(m,c({ref:t},s))}));function m(e,t){var r=arguments,n=t&&t.mdxType;if("string"==typeof e||n){var a=r.length,i=new Array(a);i[0]=d;var c={};for(var l in t)hasOwnProperty.call(t,l)&&(c[l]=t[l]);c.originalType=e,c.mdxType="string"==typeof e?e:n,i[1]=c;for(var s=2;s<a;s++)i[s]=r[s];return o.a.createElement.apply(null,i)}return o.a.createElement.apply(null,r)}d.displayName="MDXCreateElement"}}]);