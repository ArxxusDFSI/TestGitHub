({
	onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.keyCode == '13')
            $A.enqueueAction(component.get('c.submit'));
    },
    submit : function(component, event, helper) {
    	var form = component.get('v.form');
		if (!form.oldPassword)
			component.set('v.errorMessage', 'Old password is required');
		else if (form.password && form.password != form.reconfirmPassword)
			component.set('v.errorMessage', 'Password mismatch');
		else if (form.password && form.password == form.reconfirmPassword){
			var action = component.get('c.changePassword');
			action.setParams({oldPassword: form.oldPassword, newPassword: form.password, verifyNewPassword: form.reconfirmPassword});
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === 'SUCCESS') {
	            	component.set('v.errorMessage', '');
	                component.set('v.successMessage', 'Your password has successfully updated!')
	            }
	            else {
	                component.set('v.errorMessage', response.getError()[0].message);
	            }
	        });
	        $A.enqueueAction(action);
		}
	}
})