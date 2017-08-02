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
                		else if (jQuery('#' + key)){
                			jQuery('#' + key).val(caseItemData[key]);
                		}
                	}
                }
                debugger;
                component.set('v.caseDetail', data);
                component.set('v.insurer', data.insurer);
                component.set('v.caseItemId', data.caseItemId);
                component.set('v.caseId', data.caseId);
                jQuery('#dateOfInjury').val(data.dateOfInjury);
                component.set('v.supportingDocumentAttachedDate', caseItemData.supportingDocumentAttachedDate || data.supportingDocumentAttachedDate);
                component.set('v.notReviewDecisionDate', data.notReviewDecisionDate);
                component.set('v.submittedDate', caseItemData.submittedDate || data.submittedDate);
                if (caseItemData.status)
                	component.set('v.status', caseItemData.status);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
	        //MRS-205 Create 30 secs autosave
            helper.saveForm(component, helper);
        });
        $A.enqueueAction(action);
	},
	q3aResult: function(component, event, helper) {
		var supportingDocumentAttachedDate = component.get('v.supportingDocumentAttachedDate');
		if (supportingDocumentAttachedDate)
			helper.updateQ4bResult(component);
		else component.set('v.q4b', '');
	},
	q3bResult: function(component, event, helper) {
		helper.updateQ3bResult(component);
	},
	q4DateUpdate: function(component, event, helper) {
		helper.updateQ4bResult(component);
        helper.updateQ3Result(component);
	},
	submit: function(component, event, helper) {
		var action = component.get('c.saveAllocationChecklist');
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
	validation: function(component, event, helper) {
		helper.questionValidation(component, event, component.get('v.status'));
	}
})