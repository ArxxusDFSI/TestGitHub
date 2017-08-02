({
    init : function(component, event, helper) {
        var url = window.location.search.substring(1);
        url = url.split('=');
        if (url[0] == 'activationCode'){
            var activationCode = url[1];
            
            var action = component.get('c.verifyCode');
            action.setParams({
                'activationCode': activationCode
            });
            action.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set('v.showPassword',true);
                } else if (state === 'ERROR') {
                    component.set('v.errorMessage', response.getError()[0].message);
                    console.error("error");
                }
            });
            $A.enqueueAction(action);
        }
    },
    passwordLengthCheck: function(component, event, helper) {
        var password = document.getElementById('password').value;
        if (password.length < 8) {
            $A.util.addClass(component.find('pwd'), 'has-error');
            component.set('v.passwordLengthError', true);
        }  else if (password. toUpperCase().includes('PASSWORD')) {
            $A.util.addClass(component.find('pwd'), 'has-error');
            component.set('v.passwordComplexityError', true);
        } else {
            $A.util.removeClass(component.find('pwd'), 'has-error');
            component.set('v.passwordLengthError', false);
            component.set('v.passwordComplexityError', false);
        }
    },
    checkPassword: function(component, event, helper) {
        var password = document.getElementById('reconfirmPassword').value;
        if (password == document.getElementById('password').value) {
            $A.util.removeClass(component.find('confirmPassword'), 'has-error');
            component.set('v.passwordError', false);	
        }  else {
            $A.util.addClass(component.find('confirmPassword'), 'has-error');
            component.set('v.passwordError', true);	
        }
    },
    
    submit: function(component, event, helper) {
        var url = window.location.search.substring(1);
        url = url.split('=');
        if (url[0] == 'activationCode'){
            var activationCode = url[1];
            var action = component.get('c.activateAccount');
            action.setParams({
                'activationCode': activationCode,
                'password': document.getElementById('password').value
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    window.location = response.returnValue;
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    console.error("error");
                }
            });
            $A.enqueueAction(action);
        }
    }
})