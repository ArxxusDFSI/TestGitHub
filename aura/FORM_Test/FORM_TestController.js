({
    doSubmit: function(component, event, helper){
        debugger;
        
        component.set('v.statusOfSave', 'Working...');
        
        var action = component.get('c.updateCaseItem');
        action.setParams({caseItemId: component.get('v.caseItemId')});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.statusOfSave', 'Success');
            }
            else {
                component.set('v.statusOfSave', 'Error');
            }
        });
        $A.enqueueAction(action);
    }
})