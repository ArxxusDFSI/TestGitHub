({
	init : function(component, event, helper) {
        var action = component.get('c.isDelegatedAdmin');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.isDelegatedAdmin', response.returnValue);
                var action1 = component.get('c.getCaseItems');
                var location = window.location.pathname.split('/');
                if (location && location[1])
                    component.set('v.communitylink', '/' + location[1] + '/s');
                action1.setParams({});
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var application = JSON.parse(response.returnValue);
                        component.set('v.profileId', application.userId);
                        component.set('v.openApplications', application.openCaseItems);
                        component.set('v.pendingApplications', application.pendingCaseItems);
                        component.set('v.closedApplications', application.closedCaseItems);
                        component.set('v.showNewApplication', application.showNewApplication);
                        component.set('v.draftApplications', application.draftCaseItems);
                    }
                    else {
                        component.set('v.errorMessage', response.getError()[0].message);
                    }
                });
                
                $A.enqueueAction(action1);
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