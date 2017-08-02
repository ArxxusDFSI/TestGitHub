({
	onClickFunction: function(component, event, helper) {
		component.set('v.value', event.target.value);
		var js = component.get("v.onClickFunction");
		if (js) {
       		$A.enqueueAction(js);
		}
		component.set('v.errorMessage', '');
	}
})