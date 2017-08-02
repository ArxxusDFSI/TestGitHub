({
	blurFunction : function(component, event, helper) {
		var max = component.get('v.max');
		var min = component.get('v.min');
		var value = component.get('v.value');
		if (max && value.toString().length > max) {
			component.set('v.errorMessage', 'Invalid ' + component.get('v.label'));
		}
		else if (min && value.toString().length < min) {
			component.set('v.errorMessage', 'Invalid ' + component.get('v.label'));
		}
		else if (value) {
			component.set('v.errorMessage', '');
		}
	}
})