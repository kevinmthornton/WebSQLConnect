// 
// Use this javascript to request native objective-c code
var NativeBridge = {
  // functionName : string 
  // args : JSON string 
  // callback : function with n-arguments that is going to be called when the native code returned
  call : function call(functionName, args, callbackFunction) {
    var iframe = document.getElementById("mainIFrame");
    iframe.setAttribute("src", "js-frame:" + functionName + ":" + callbackFunction + ":" + encodeURIComponent(JSON.stringify(args)));
  },
  
  showAlert : function showAlert() {
    alert("Complete");
  }
  
};


