// all the js for the directory app

var Directory = {
    
    startDirectory : function startDirectory() {
        NativeBridge.call('directoryListing', [0], 'NativeBridge.showAlert()');
    },
    
    showAlert : function showAlert(msg) {
        alert(msg);
    },
    
    showData : function showData(passedJSONData) {
        var $companyDirectoryList = $("#companyDirectoryList");
        $.each(passedJSONData, function(i, obj) {
            //use obj.id and obj.name here, for example:
            // alert(obj.first_name);
            var $lineText = "<li> " + obj.first_name + " " + obj.last_name + " </li>";
            $companyDirectoryList.append($lineText);
        });
    }
  
} // end Directory Object

// outside of main object to start
window.addEventListener("load",function () {
  try {
    Directory.startDirectory();
  } catch(e){
    // send off to help files with error message
    alert(e);
  }
},false);
