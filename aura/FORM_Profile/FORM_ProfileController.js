({
    init : function(component, event, helper) {
        var location = window.location.pathname.split('/');
        if (location && location[1])
            component.set('v.communitylink', '/' + location[1] + '/s');
        var action = component.get('c.getContactForUser');
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                var dob = returnValue.Birthdate;
                if (dob)
                    returnValue.Birthdate = dob.substring(8,10) + "/" + dob.substring(5,7) + "/" + dob.substring(0,4);
                if (!returnValue.Salutation)
                    returnValue.Salutation = 'Mr.';
                component.set('v.form', returnValue);
            } else if (state === 'ERROR') {
                component.set('v.errorMessage', response.getError()[0].message);
                window.scrollTo(0,0);
            }
        });
        
        $A.enqueueAction(action);
    },
    submit : function(component, event, helper) {
        var action = component.get('c.saveProfile');
        var params = {
            profileJSON : JSON.stringify(component.get('v.form'))
        };
        console.log(params);
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS')
                component.set('v.vaildation', true);
            else if (state === 'ERROR') 
                component.set('v.errorMessage', response.getError()[0].message);
            window.scrollTo(0,0);
        });
        
        $A.enqueueAction(action);
    }
})