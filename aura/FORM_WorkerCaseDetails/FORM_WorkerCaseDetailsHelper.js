({
	todayDate: function(){
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        if(dd<10){
            dd='0'+dd;
        } 
        if(mm<10){
            mm='0'+mm;
        } 
        var today = dd+'/'+mm+'/'+yyyy;
        return today;
    },
    getCaseJson: function(component, caseId) {
        var action = component.get('c.getCaseJSON');
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var caseDetails = JSON.parse(response.returnValue);
                console.log(caseDetails);
                component.set('v.caseDetail', caseDetails);
                component.set('v.caseApplications', caseDetails.submittedCaseItems);
                component.set('v.pendingApplications', caseDetails.pendingCaseItems);
                for (var j=0; j<caseDetails.attachments.length; j++){
                    if (caseDetails.attachments[j].category){
                        var tier2 = caseDetails.attachments[j].tier2 || '';
                        var tier3 = caseDetails.attachments[j].tier3 || '';
                        caseDetails.attachments[j].category = caseDetails.attachments[j].category + '\n' + tier2 + '\n' + tier3;
                    }
                }
                component.set('v.uploadDocuments', caseDetails.attachments);
                component.set('v.caseTeamMembers', caseDetails.caseTeamMembers);
                component.set('v.loginUser', caseDetails.loggedInUserName);
                component.set('v.showManageCaseTeamMembers', caseDetails.showManageCaseTeamMembers);
                if (caseDetails.dateLodged){
                    var dateTime = caseDetails.dateLodged.split(' ');
                    component.set('v.day', dateTime[0]);
                    component.set('v.time', dateTime[1]);
                }
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getCaseSnippet: function(component){
        var action = component.get('c.getCaseDetailSnippets');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var snippets = JSON.parse(response.returnValue);
                var workflows = [];
                component.set('v.snippets', snippets);
                for (var i=0; i<snippets.caseStatuses.length; i++){
                    var name = snippets.caseStatuses[i].name;
                    name = name.split('.')
                    workflows.push({
                        key: name[0],
                        label: name[1],
                        tooltip: snippets.caseStatuses[i].description
                    });
                }
                component.set('v.workflows', workflows);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getCaseTeamBuilder: function(component, caseId){
        var action = component.get('c.getCaseTeamBuilder');
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var caseTeamBuilder = JSON.parse(response.returnValue);
                console.log(caseTeamBuilder);
                component.set('v.users', caseTeamBuilder.caseTeamMembers);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }
})