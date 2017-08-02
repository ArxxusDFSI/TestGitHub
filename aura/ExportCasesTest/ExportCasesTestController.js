({
	export : function(component, event, helper) {
		 var caselist =[];
        var action=component.get("c.getCaseList");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                caselist= response.getReturnValue();
            }
        });
        alert('@@@'+caselist);
	}
})