/*
The : is used when defining an object and it's properties. The : assigns a function as a property of an object literal.
var obj = {
   queryString: function() {
      //some code
   }
}
Now obj.queryString() is your function.
*/

// main section for global functions
// app is our global object for the functionality of the mobile site
var app = {
   //*** employee funtions 
   findByName: function() {
        console.log('findByName');
        this.store.findByName($('.search-key').val(), function(employees) {
            var l = employees.length;
            var e;
            $('.employee-list').empty();
            for (var i=0; i<l; i++) {
                e = employees[i];
                $('.employee-list').append('<li><a href="#employees/' + e.id + '">' + e.firstName + ' ' + e.lastName + '</a></li>');
            }
        });
    // close off the findByName: function --> must have comma after to continue with other functions    
    },

   showAlert: function (message, title) {
        if (navigator.notification) {
            navigator.notification.alert(message, null, title, 'OK');
        } else {
            alert(title ? (title + ": " + message) : message);
        }
     },

   initEmployee: function() {
        // before alert test it was just this -> this.store = new MemoryStore();
        // store will be the new variable holding the MemoryStore object which is a JSON list of employees
        // this could also be: LocalStorageStore if we were to include ls-store.js instead of memory-store.js
        // this could also be: WebSqlStore if we were to include webslq-store.js instead of memory-store.js
        this.store = new MemoryStore(function() {
            // The scope of 'this' is the event. In order to call the 'showAlert' function, we must explicity call 'app.showAlert(...);'
            app.showAlert('Store Initialized', 'Info');
        });
        $('.search-key').on('keyup', $.proxy(this.findByName, this));
    }, // init employee
    // *** end employee functions
    
    // Bind Event Listeners -> from boilerplate phonegap build for .js file
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent' function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    },
    
 
    // kick off the app and all it's congifurations
    initialize: function() {
        // from boilerplate index.js file
        this.bindEvents();
        
    } // initalize --> this should be last; no comma after closing }
}; // app

// fire off the initialization of the app for the entire site on each load
app.initialize();