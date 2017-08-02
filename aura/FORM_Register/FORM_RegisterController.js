({
    init: function(component, event, helper){
        if (window.location.pathname && window.location.pathname.split('/')[1])
            component.set('v.communitylink', window.location.pathname.split('/')[1]);
        component.set('v.form', {
            'title': 'Mr.',
            'firstName': '',
            'lastName': '',
            'birthDate': '',
            'phone': '',
            'mailingStreet': '',
            'mailingCity': '',
            'mailingState': 'NSW',
            'mailingPostalCode': '',
            'emailAddress': '',
            'password': '',
            'solePractitioner': '',
            'laySocietyNumber': '',
            'validFrom': '',
            'validTo': ''
        });
    }, 
    passwordLengthCheck: function(component, event, helper) {
        var password = component.find('password').get('v.value');
        if (password.length < 8) {
            component.find('password').set('v.errorMessage', 'Password length require minimum 8 characters');
        }  else if (password.toUpperCase().includes('PASSWORD')) {
            component.find('password').set('v.errorMessage', 'Your password cannot be easy to guess');
        } else {
            component.find('password').set('v.errorMessage', '');
        }
  	},
    checkPassword: function(component, event, helper) {
        var password = component.find('password').get('v.value');
        var confirmPassword = component.find('confirmPassword').get('v.value');
        if (password == confirmPassword) {
			component.find('confirmPassword').set('v.errorMessage', '');
        }  else {
            component.find('confirmPassword').set('v.errorMessage', 'Password not match');
        }
  	},
    submit: function(component, event, helper) {
        component.set('v.buttonDisable', true);
        var action = component.get('c.registerApplicant');
        var form = component.get('v.form');
        var valid = true;
        var fieldsToCheck = {
            'title': 'Please enter a Title',
            'firstName': 'Please enter a Given name(s)',
            'lastName': 'Please enter a Surname',
            'birthDate': 'Please enter a Date of Birth',
            'phone': 'Please enter a Contact Number',
            'mailingStreet': 'Please enter a Postal address',
            'mailingCity': 'Please enter a Suburb',
            'mailingState': 'Please enter a State',
            'mailingPostalCode': 'Please enter a PostCode',
            'password': 'Please enter a Password',
            'confirmPassword': 'Please enter a password'
        }
        if (form.mailingPostalCode)
            form.mailingPostalCode = form.mailingPostalCode.toString();
        Object.keys(fieldsToCheck).forEach(function(field) {
            var cmp = component.find(field);
            var value = cmp.get('v.value');
            if (value){
                cmp.set('v.errorMessage', '');
            }
            else {
                cmp.set('v.errorMessage', fieldsToCheck[field]);
                valid = false;
            }
        });
        if (form.solePractitioner == 'yes') {
            if (!form.laySocietyNumber) {
                component.find('laySocietyNumber').set('v.errorMessage', 'Please enter a law society no');
                valid = false;
            }
            if (!form.validFrom) {
                component.find('validFrom').set('v.errorMessage', 'Please enter a valid from');
                valid = false;
            }
            if (!form.validTo) {
                component.find('validTo').set('v.errorMessage', 'Please enter a valid to');
                valid = false;
            }
        }
        form.solePractitioner = component.get('v.solePractitioner');

        if (valid){
        	action.setParams(form);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    window.location.href = "/" + component.get('v.communitylink') + "/s/confirmRegistration";
                }
                else {
                    component.set('v.errorMessage', response.getError()[0].message);
                    window.scrollTo(0, 0);
                }
                component.set('v.buttonDisable', false);
            });
            
            $A.enqueueAction(action);   
        }
        else component.set('v.buttonDisable', false);
    },
    checkedIsSolePractitioner: function(component, event, helper) {
        if(component.find('solePractitioner').get('v.value') == 'no') {
            component.set('v.solePractitioner', false);
        }
        else {
            component.set('v.solePractitioner', true);
        }
        //window.scrollTo(0, document.body.scrollHeight);
    }
})