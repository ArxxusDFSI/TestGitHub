({
	updateQ3bResult : function(component) {
		function process(date){
		   var parts = date.split("/");
		   return new Date(parts[2], parts[1] - 1, parts[0]);
		}
		var date = component.get('v.notReviewDecisionDate');
		var submittedDate = component.get('v.submittedDate');
		var dateDiff;
		var newStatus;
		if (date && submittedDate)
			dateDiff = (process(submittedDate) - process(date)) / 60 / 60 / 24 / 1000;

		if (dateDiff && dateDiff <= 30){
			component.set('v.q3bResult', 'failed');
			newStatus = 'failed';
		}
		else if (date){
			component.set('v.q3bResult', 'success');
			newStatus = 'success';
		}
		else component.set('v.q3bResult', 'empty');
		this.updateGlobalStatus(component, newStatus);
	},
	updateQ3Result : function(component) {
		function process(date){
		   var parts = date.split("/");
		   return new Date(parts[2], parts[1] - 1, parts[0]);
		}
		var date = component.get('v.supportingDocumentAttachedDate');
		var submittedDate = component.get('v.submittedDate');
		var dateDiff;
		var newStatus;
		if (date && submittedDate)
			dateDiff = (process(submittedDate) - process(date)) / 60 / 60 / 24 / 1000;

		if (dateDiff && dateDiff < 0){
			component.set('v.q4bResult', 'failed');
			newStatus = 'failed';
		}
		else if (date){
			component.set('v.q4bResult', 'success');
			newStatus = 'success';
		}
		else component.set('v.q4bResult', 'info');

		if (dateDiff && dateDiff > 30){
			component.set('v.q4aResult', 'failed');
			newStatus = 'failed';
		}
		else if (date){
			component.set('v.q4aResult', 'success');
		}
		else component.set('v.q4aResult', 'info');
		this.updateGlobalStatus(component, newStatus);
	},
	updateQ4bResult: function(component){
		var date = component.get('v.submittedDate');
		var action = component.get('c.getDateDifferenceWithHolidays');
		var supportingDocumentAttachedDate = component.get('v.supportingDocumentAttachedDate');
		if (supportingDocumentAttachedDate && date){
			action.setParams({startingDate: date, numberOfDays: '30'});
			action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === 'SUCCESS' && response.returnValue) {
	            	component.set('v.q4b', response.returnValue);
	            }
	            else {
	                component.set('v.errorMessage', response.getError()[0].message);
	            }
	        });
	        $A.enqueueAction(action);
        }
	},
	getFormData: function(component){
		var $inputs = jQuery('#checklist :input');
		var params = {};

		$inputs.each(function() {
			if (this.type != 'button'){
				if (this.className && this.className.indexOf('inputDate') != -1 && component.find(this.id) && component.find(this.id).find('datepicker').elements[0].value)
	                params[this.id] = component.find(this.id).find('datepicker').elements[0].value;
	            else if (this.id) 
	                params[this.id] = this.value;
			}
		});
		params['caseId'] = component.get('v.caseId');
		params['caseItemId'] = component.get('v.caseItemId');
		params['insurer'] = component.get('v.insurer');
		params['status'] = component.get('v.status');
		return params;
	}, 
	saveForm: function(component, helper){
		var action = component.get('c.saveAllocationChecklist');
        var params = helper.getFormData(component);
		action.setParams({caseItemJson : JSON.stringify(params)});
        window.setTimeout(
        	$A.getCallback(function() {
            	console.log('form saved');
            	helper.saveForm(component,helper);
        	}), 60000
        );
        $A.enqueueAction(action);
	},
	questionValidation: function(component, event, status) {
		var newStatus;
		if (event.target.id == 'q1'){
			if (event.target.value == 'yes'){
				newStatus = 'success';
				component.set('v.q1', 'yes');
			}
			else if (event.target.value == 'no'){
				newStatus = 'failed';
				component.set('v.q1', 'no');
			}
			else {
				newStatus = 'info';
				component.set('v.q1', '');
			}
		}
		else if (event.target.id == 'q2'){
			if (event.target.value == 'yes'){
				newStatus = 'success';
				component.set('v.q2', 'yes');
			}
			else{
				newStatus = 'success';
				component.set('v.q2', 'no');
			} 
		}
		else if (event.target.id == 'q2a'){
			if (event.target.value == 'yes'){
				newStatus = 'success';
				component.set('v.q2a', 'yes');
			}
			else if (event.target.value == 'no'){
				newStatus = 'failed';
				component.set('v.q2a', 'no');
			} 
			else {
				newStatus = 'info';
				component.set('v.q2avalue', '');
			}
		}
		else if (event.target.id == 'q3a'){
			if (event.target.value == 'yes'){
				newStatus = 'success';
				component.set('v.q3a', 'yes');
			}
			else if (event.target.value == 'no'){
				newStatus = 'failed';
				component.set('v.q3a', 'no');
			} 
			else {
				newStatus = 'info';
				component.set('v.q3avalue', '');
			}
		}
		else if (event.target.id == 'q5'){
			if (event.target.value == 'yes'){
				newStatus = 'success';
				component.set('v.q5', 'yes');
			}
			else if (event.target.value == 'no'){
				newStatus = 'info';
				component.set('v.q5', 'no');
			} 
			else {
				newStatus = 'info';
				component.set('v.q5', '');
			}
		}
		else if (event.target.id == 'q5a'){
			if (event.target.value == 'yes'){
				newStatus = 'failed';
				component.set('v.q5a', 'yes');
			}
			else if (event.target.value == 'no'){
				newStatus = 'success';
				component.set('v.q5a', 'no');
			} 
			else {
				newStatus = 'info';
				component.set('v.q5a', '');
			}
		}
		else if (event.target.id == 'q6'){
			if (event.target.value == 'yes'){
				newStatus = 'failed';
				component.set('v.q6', 'yes');
			}
			else if (event.target.value == 'no'){
				newStatus = 'success';
				component.set('v.q6', 'no');
			} 
			else {
				newStatus = 'info';
				component.set('v.q6', '');
			}
		}
		this.updateGlobalStatus(component, newStatus);
	},
	updateGlobalStatus: function(component, newStatus) {
		if (component.get('v.q1') != 'no' && 
			component.get('v.q2a') != 'no' &&
			component.get('v.q3a') != 'no' &&
			component.get('v.q5a') != 'yes' &&
			component.get('v.q6') != 'yes' &&
			component.get('v.q3bResult') != 'failed' &&
			component.get('v.q4bResult') != 'failed' ) {
			component.set('v.status', newStatus);
		}
		if (newStatus == 'failed') {
			component.set('v.status', newStatus);
		}
	}
})