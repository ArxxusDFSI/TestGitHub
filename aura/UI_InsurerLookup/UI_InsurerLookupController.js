({
	insurerSearch: function(component, event, helper) {
		var action = component.get('c.getInsurersByName');
        var inputValue = component.find('insurerInput').elements["0"].childNodes[1].value;
        if (inputValue && inputValue.length>2){
            action.setParams({'insurerName':inputValue});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set('v.feedback', response.returnValue);
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    console.error("error");
                }
            });
            $A.enqueueAction(action);
        }
	},
	selectInsurer: function(component, event, helper) {
        component.set('v.feedback', []);
        component.set('v.selectedInsurer', {Id: event.target.attributes['data-id'].value, Name: event.target.attributes['data-name'].value});
    	console.log (event.target.attributes['data-id'].value + " " + event.target.attributes['data-name'].value);
        component.set('v.validation', false);
        $A.util.removeClass(component.find('has-feedback'), 'has-error');
    },
    insurerValidate:function(component, event, helper) {
        setTimeout(function() {
            var selectedInsurer = component.get('v.selectedInsurer');
            if (selectedInsurer && selectedInsurer.Id && component.find('insurerInput').elements["0"].childNodes[1].value == selectedInsurer.Name){
                component.set('v.validation', false);
                $A.util.removeClass(component.find('has-feedback'), 'has-error');
            }
            else {
                $A.util.addClass(component.find('has-feedback'), 'has-error');
                component.set('v.validation', true);
            }
        }, 500);
    }
})