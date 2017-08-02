({
	init : function(component, event, helper) {
		var location = window.location.pathname.split('/');
        if (location && location[1])
            component.set('v.communitylink', '/' + location[1]);
        if (location[3] === 'userlogin' || location[3] === 'createaccount' || location[3] === 'forgot-password'){
        	component.set('v.hideBacktoHome', true);
        }
        component.set('v.hostname', window.location.origin + '/' + location[1] + '/s');
	}
})