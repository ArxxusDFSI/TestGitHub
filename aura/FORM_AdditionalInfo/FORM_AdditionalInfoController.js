({
	init: function(component, event, helper){
		var action = component.get('c.getExistingCaseItem');
        var applicationId;
        if (window.location.pathname && window.location.pathname.split('/')[1])
            component.set('v.communitylink', window.location.pathname.split('/')[1]);
        var url = window.location.search.substring(1);
        url = url.split('=');
        
        var recordId = component.get('v.recordId');
        if(recordId) {
            component.set('v.isLoadedInSalesforce',true);
            applicationId = recordId;
        }
        else if (url[0] == 'recordId') {
            applicationId = url[1];
        }
        action.setParams({caseItemId: applicationId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = JSON.parse(response.returnValue);
                console.log(returnValue);
                if (returnValue.status == 'Submitted' || returnValue.isLocked)
                    component.set('v.formLocked', true);
                if (returnValue.submittedBy) {
                    component.set('v.submittedBy', returnValue.submittedBy);
                    component.set('v.submittedDate', returnValue.submittedDate);
                }
                component.set('v.applicationId', returnValue.caseItemId);
                component.set('v.caseNumber', returnValue.caseNumber);
                component.set('v.caseId', returnValue.caseId);
                component.set('v.uploadDocuments', returnValue.attachments);
                component.set('v.applicationData', returnValue.caseItemData);
                var applicationData = JSON.parse(returnValue.caseItemData);
                component.set('v.requestDetails', applicationData.requestDetails);
                for (i in applicationData){
                    if (document.getElementById(i)){
                        document.getElementById(i).value = applicationData[i];
                        if (returnValue.status == 'Submitted' || returnValue.isLocked)
                            document.getElementById(i).disabled = true;
                    }

                    else if (i == 'attachments'){
                        
                    }
                }
                if (returnValue.status == 'Submitted' || returnValue.isLocked) {
                    component.set('v.formLocked', true);
                    jQuery('#additionalForm :input').prop( "disabled", true );
                }
            } else if (state === 'ERROR') {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	},
	submit : function(component, event, helper) {
        var action = component.get('c.saveAdditionalInformation');
        var params = {};
        params['response'] = $('#response').val();
        params['caseId'] = component.get('v.caseId');
        params['caseItemId'] = component.get('v.applicationId');
        params['attachments'] = component.get('v.uploadDocuments');
        params['requestDetails'] = component.get('v.requestDetails');
        action.setParams({caseItemJson : component.get('v.applicationData'), additionalInformationJSON: JSON.stringify(params)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                window.location.href = '/' + window.location.pathname.split('/')[1] + "/s/casedetail?recordId=" + component.get('v.caseId');
            } else if (state === 'ERROR') {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
    }
})