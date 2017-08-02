({
	onBlurFunction: function(component, event, helper) {
		component.set('v.value', component.find('secret').get('v.value'));
		var js = component.get("v.onBlurFunction");
		if (js) {
       		$A.enqueueAction(js);
		}
		if (component.get('v.value'))
			component.set('v.errorMessage', '');
	},
	keyup : function(component, event, helper) {
		var js = component.get("v.keyup");
		if (js) {
       		$A.enqueueAction(js);
		}
	}
})