({
	init : function(component, event, helper) {
		var action = component.get('c.getCaseItems');
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === 'SUCCESS') {
                var application = JSON.parse(response.returnValue);
                component.set('v.profileId', application.userId);
                component.set('v.openApplications', application.openCaseItems.concat(application.pendingCaseItems));
                component.set('v.draftApplications', application.draftCaseItems);
                component.set('v.closedApplications', application.closedCaseItems);
                component.set('v.userName', application.userFirstName);
                console.log(application);
                if (application.openCaseItems.length === 0 && application.pendingCaseItems.length === 0 && application.draftCaseItems.length === 0 && application.closedCaseItems.length === 0) {
                    component.set('v.newUser', true);
                }
                else component.set('v.newUser', false);
                console.log(application);
                var location = window.location.pathname.split('/');
                if (location && location[1])
                    component.set('v.communitylink', '/' + location[1]);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
        if (window.location.search)
            window.location.href = window.location.origin + window.location.pathname;
	},
    deleteCase : function(component, event, helper) {
        jQuery('#backdrop').addClass('slds-backdrop--open');
        jQuery('#confirmDeleteModal').addClass('slds-fade-in-open');
        component.set('v.toDeleteCaseItemId', event.target.data);
    },
    closeConfirmDeleteModal : function(component, event, helper) {
        jQuery('#confirmDeleteModal').removeClass('slds-fade-in-open');
        jQuery('#backdrop').removeClass('slds-backdrop--open');
    },
    continueConfirmDeleteModal : function(component, event, helper) {
        var action = component.get('c.deleteDrafCaseItem');
        action.setParams({caseId: component.get('v.toDeleteCaseItemId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                jQuery('#confirmDeleteModal').removeClass('slds-fade-in-open');
                jQuery('#backdrop').removeClass('slds-backdrop--open');
                location.reload();
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
    }
})