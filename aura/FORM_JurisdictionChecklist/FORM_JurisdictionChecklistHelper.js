({
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
	}
})