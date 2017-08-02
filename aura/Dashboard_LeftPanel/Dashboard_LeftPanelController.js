({
	init : function(component, event, helper) {
        component.set('v.communityOriginlink', window.location.origin);
		var action = component.get('c.getCaseItems');
        var location = window.location.pathname.split('/');
        if (location && location[1])
            component.set('v.communitylink', '/' + location[1]);
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === 'SUCCESS') {
                var application = JSON.parse(response.returnValue);
                component.set('v.profileId', application.userId);
                component.set('v.openApplications', application.openCaseItems);
                component.set('v.pendingApplications', application.pendingCaseItems);
                component.set('v.draftApplications', application.draftCaseItems);
                component.set('v.closedApplications', application.closedCaseItems);
                component.set('v.userName', application.userFirstName + ' ' + application.userLastName);
                if (application.openCaseItems.length === 0 && application.pendingCaseItems.length === 0 && application.draftCaseItems.length === 0 && application.closedCaseItems.length === 0) {
                    component.set('v.newUser', true);
                }
                else component.set('v.newUser', false);
                console.log(application);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
	},
    doneRendering: function(component, event, helper) {
        var height;
        var iOS = /iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        if (jQuery('#caseDetailsPage') && jQuery('#caseDetailsPage').height())
            height = jQuery('#caseDetailsPage').height();
        else if (jQuery('#disputeForm') && jQuery('#disputeForm').height())
            height = jQuery('#disputeForm').height(); 
        else if (jQuery('#dashboard') && jQuery('#dashboard').height())
            height = jQuery('#dashboard').outerHeight() + jQuery('#dashboardGrey').outerHeight();
        else if (jQuery('#userProfile') && jQuery('#userProfile').height())
            height = jQuery('#userProfile').outerHeight();
        else if (jQuery('#changePasswordPage') && jQuery('#changePasswordPage').height())
            height = jQuery('#changePasswordPage').outerHeight();
        if (height && !iOS)
            jQuery('#dashboard_LeftPanel').height(height);
    }
})