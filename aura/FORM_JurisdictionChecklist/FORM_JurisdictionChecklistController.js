({
	init : function(component, event, helper) {
		var action = component.get('c.getExistingCaseItem');
        var url = window.location.search.substring(1);
        url = url.split('=');
        applicationId = url[1];

        action.setParams({caseItemId: applicationId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var data = JSON.parse(response.returnValue);
                var caseItemData = JSON.parse(data.caseItemData);
                if (caseItemData){
                	for (var key in caseItemData) {
                		if (component.get('v.' + key) != undefined)
                			component.set('v.'+key, caseItemData[key]);
                		else if (jQuery('#' + key))
                			jQuery('#' + key).val(caseItemData[key]);
                	}
                }
                component.set('v.caseDetail', data);
                component.set('v.insurer', data.insurer);
                component.set('v.caseItemId', data.caseItemId);
                component.set('v.caseId', data.caseId);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
            helper.saveForm(component, helper);
        });
        $A.enqueueAction(action);

	},
	submit: function(component, event, helper) {
		var action = component.get('c.saveAllocationChecklist');
		var $inputs = jQuery('#checklist :input');
		var params = helper.getFormData(component);

		component.set('v.buttonDisable', true);
		action.setParams({caseItemJson: JSON.stringify(params)});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
            	component.set('v.vaildation', true);
            	window.scrollTo(0,0);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
            component.set('v.buttonDisable', false);
        });
        $A.enqueueAction(action);
	},
})