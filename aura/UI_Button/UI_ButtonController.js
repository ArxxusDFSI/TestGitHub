({
	buttonClick : function(component, event, helper) {
		var js = component.get("v.onClickFunction");
		if (js) {
			$A.enqueueAction(js);
		}
	}
})