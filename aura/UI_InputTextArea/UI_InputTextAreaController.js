({
	blurFunction : function(component, event, helper) {
		if (component.get('v.value'))
			component.set('v.errorMessage', '');
	}
})