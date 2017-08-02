({
	submit : function(component, event, helper) {
		var value = component.find('username').get('v.value');
		var action = component.get('c.resetPassword');
		if (value && !component.get('v.errorMessage')){
	        action.setParams({userName: value});
	        action.setCallback(this, function(response) {
                component.set('v.errorMessage', '');
	            var state = response.getState();
	            if (state === 'SUCCESS') {
	                if(response.returnValue.indexOf('Invalid') >= 0) {
	                    component.set('v.vaildation', true);
	                    component.set('v.errorMessage', response.returnValue);
	                }
	                else {
	                    component.set('v.vaildation', true);
	                    component.set('v.successMessage', response.returnValue);
	                }
	            }
	            else {
	                component.set('v.vaildation', true);
	                component.set('v.errorMessage', response.returnValue);
	            }
	        });
	        $A.enqueueAction(action);
	    }
	},
    
    checkEmail: function(component, event, helper) {
        var ipEmailVal = component.find('username').get('v.value');
        var emailRegEx = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i;

        if (emailRegEx.test(ipEmailVal)) {
            $A.util.removeClass(component, 'has-error');
            component.set('v.errorMessage', '');
            // var js = component.get('v.action.inputText');
            // if (js)
            //   js(component, event, helper);
        }  else {
            $A.util.addClass(component, 'has-error');
            component.set('v.errorMessage', 'Invalid Email. Please check the email you have entered.');  
        }
    }
})