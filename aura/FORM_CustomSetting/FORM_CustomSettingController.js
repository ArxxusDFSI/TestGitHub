({
	init : function(component, event, helper) {
		var location = window.location.pathname.split('/');
        if (location && location[1])
            component.set('v.communitylink', '/' + location[1] + '/s');
        
	}
})