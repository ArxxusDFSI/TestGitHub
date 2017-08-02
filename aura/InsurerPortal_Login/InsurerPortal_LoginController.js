({
    initialize: function(component, event, helper) {
        var url = window.location.search.substring(1);
		url = url.split('=');
        if (url){
            var counter = 0;
            for(counter = 0; counter < url.length; counter++) {
                if(url[counter] == 'startURL') {
                    component.set('v.startUrl', url[counter+1]);
                }
                
            }
        }
        if (window.location.pathname && window.location.pathname.split('/')[1])
            component.set('v.community', window.location.pathname.split('/')[1]);

        //IE error
        var action = component.get("c.isAuthenticated");
        action.setCallback(this, function(response){
            
            var rtnValue = response.getReturnValue();
            
            if (rtnValue) {
                    window.location = '/' + window.location.pathname.split('/')[1] + '/s';
            }
        });
        $A.enqueueAction(action);
    },
    
    submit: function (component, event, helper) {
        
        helper.handleLogin(component, event, helper);
    },
    
    keyup: function(component, event, helper){
        //checks for "enter" key
        if ((event && event.keyCode === 13) || (this.event && this.event.keyCode === 13))
            helper.handleLogin(component, event, helper);
    }
})