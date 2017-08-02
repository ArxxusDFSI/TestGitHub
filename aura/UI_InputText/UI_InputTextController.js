({
	keyupFunction : function(component, event, helper) {
		var js = component.get("v.keyup");
		if (js) {
       		$A.enqueueAction(js);
		}
	},
	blurFunction : function(component, event, helper) {
		var js = component.get("v.blurFunction");
		if (js) {
       		$A.enqueueAction(js);
		}
		if (component.get('v.value'))
			component.set('v.errorMessage', '');
	}
})