({
	  onChange: function(component, event, helper) {
        var ipEmailVal = event.source.elements["0"].value;
        var emailRegEx = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i;

        if (emailRegEx.test(ipEmailVal)) {
			      $A.util.removeClass(component, 'has-error');
          	component.set('v.inputErrorMessage', '');
            component.set('v.errorMessage', '');
          	var js = component.get('v.action.inputText');
          	if (js)
              js(component, event, helper);
        }  else {
            $A.util.addClass(component, 'has-error');
            component.set('v.inputErrorMessage', true);	
        }
  	}
})