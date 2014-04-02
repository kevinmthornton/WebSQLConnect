function setIntervalTest(onSuccess) {
  var j=0;
  var starTime = new Date().getTime();
  var interval = window.setInterval(function () {
  
    NativeBridge.call("setBackgroundColor", [0,0,j++/255]);
    
    // document.getElementById("count").innerHTML = j;
    // document.getElementById("count2").textContent = j;
    
    if (j==255) {
      document.body.innerHTML += "SetInterval executed in "+(new Date().getTime()-starTime)+" ms<br/>";
      window.clearInterval(interval);
      if (onSuccess)
        onSuccess();
    }
    
  },0);
}

function callbackLoopTest(onSuccess) {
  
  var starTime = new Date().getTime();
  var i=0;
  function loop() {
    try {
      if (i>255) {
        
        document.body.innerHTML += "Loop executed in "+(new Date().getTime()-starTime)+" ms<br/>";
        if (onSuccess)
          onSuccess();
        return;
      }
      // document.getElementById("count").innerHTML = i;
      // document.getElementById("count2").textContent = i;
    
      NativeBridge.call("setBackgroundColor", [0,0,i++/255], function () {
        loop();
      });
    } catch(e) {
      alert(e);
    }
  };
  loop();
}

function promptTest(onSuccess) {
  window.setTimeout(function () {
    NativeBridge.call("prompt", ["do you see blue background ?"],function (response){
      if (response) {
        document.body.innerHTML+="<br/>You saw blue background, all is perfectly fine!<br/>";
      } else {
        document.body.innerHTML+="<br/>Are you sure ? Because you have to see blue!<br/>";
      }
      if (onSuccess)
        onSuccess();
    });
  }, 600);
}

function callIFrameBGColor(args) {
  
     // var iframe = document.createElement("IFRAME");
      var iframe = document.getElementById("mainIFrame");
    
    // alert("js-frame:" + functionName + ":" + callbackId+ ":" + encodeURIComponent(JSON.stringify(args)));
    // iframe.setAttribute("src", "js-frame:" + functionName + ":" + callbackId+ ":" + encodeURIComponent(JSON.stringify(args)));
    iframe.setAttribute("src", "js-frame:setBackgroundColor:" + '0' + ":" + encodeURIComponent(JSON.stringify(args)));
}
// hide iFrame totally and see if this works

// callbacks don't work; try calling a different JS function on the returnResult: method in MyWebView and see if that does anything
// try including jquery mobile js
// try including jquery js
// try including PhoneGap.js

// try native call to show another view controller, just open a new view controller on top of current web view

// taken out since loop does not inrement

window.addEventListener("load",function () {
  
  try {
    
    callbackLoopTest(function () {
      
      setIntervalTest(function () {
        
        promptTest();
        
      });
      
    });
    
  } catch(e){
    alert(e);
  }
},false);






