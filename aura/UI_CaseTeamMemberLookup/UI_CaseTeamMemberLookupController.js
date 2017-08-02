({
	teamMemberLookup: function(component, event, helper) {
        var action = component.get('c.getUserFromName');
        var inputValue = component.find('caseTeamMemberInput').elements[0].value;
        if (inputValue && inputValue.length>2){
            action.setParams({
                caseId: component.get('v.caseId'), 
                userName: inputValue
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set('v.feedback', JSON.parse(response.returnValue));
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    console.error("error");
                }
            });
            $A.enqueueAction(action);
        }
    },
    teamMemberValidate: function(component, event, helper) {
    	setTimeout(function() {
            var selectedMember = component.get('v.selectedMember');
            if (selectedMember && selectedMember.userId && component.find('caseTeamMemberInput').elements[0].value == selectedMember.userName){
                component.set('v.validation', false);
                $A.util.removeClass(component.find('has-feedback'), 'has-error');
            }
            else {
                $A.util.addClass(component.find('has-feedback'), 'has-error');
                component.set('v.validation', true);
            }
        }, 500);
    },
    selectMember: function(component, event, helper) {
        component.set('v.feedback', []);
        component.set('v.selectedMember', {userId: event.target.attributes['data-id'].value, userName: event.target.attributes['data-name'].value});
    	console.log (event.target.attributes['data-id'].value + " " + event.target.attributes['data-name'].value);
        component.set('v.validation', false);
        $A.util.removeClass(component.find('has-feedback'), 'has-error');
    }
})