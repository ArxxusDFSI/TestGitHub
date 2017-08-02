({
	selectionChange : function(component, event, helper) {
		component.set('v.checked', event.target.checked);
		var js = component.get("v.onClickFunction");
		if (js) {
			$A.enqueueAction(js);
		}
	}
})