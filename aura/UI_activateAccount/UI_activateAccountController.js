({
    init : function(component, event, helper) {
        /*if (typeof jQuery !== "undefined" && typeof $j === "undefined") {
            window.$j = window.jQuery.noConflict(true);
            console.log('Loaded JQuery: %s', window.$j.fn.jquery);
        }*/
        component.set('v.messageToDisplay', 'Please wait...');
        var url = window.location.search.substring(1);
        url = url.split('=');
        if (url[0] == 'activationCode'){
            var activationCode = url[1];
            
            var action = component.get('c.activateAccount');
            action.setParams({
                'activationCode': activationCode
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set("v.messageToDisplay","Thanks for activating your account. You will be redirected to the login page soon.");
                    window.location = '/mrs01/s';
                } else if (state === 'ERROR') {
                    component.set('v.messageToDisplay', '');
                    component.set('v.errorMessage', response.getError()[0].message);
                }
            });
            $A.enqueueAction(action);
        }
    }
})