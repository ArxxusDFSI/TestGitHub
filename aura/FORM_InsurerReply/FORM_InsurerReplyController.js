({
    init : function(component, event, helper) {
        var action = component.get('c.getExistingCaseItem');
        var applicationId;
        var recordId = component.get('v.recordId');
        if (window.location.pathname && window.location.pathname.split('/')[1])
            component.set('v.communitylink', window.location.pathname.split('/')[1]);
        var url = window.location.search.substring(1);
        url = url.split('=');
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
                if ( !(returnValue.status == 'Pending' || returnValue.status == 'Draft')  || returnValue.isLocked)
                    component.set('v.formLocked', true);
                component.set('v.formStatus', returnValue.status);
                if (returnValue.submittedBy) {
                    component.set('v.submittedBy', returnValue.submittedBy);
                    component.set('v.submittedDate', returnValue.submittedDate);
                }
                component.set('v.applicationId', returnValue.caseItemId);
                component.set('v.caseNumber', returnValue.caseNumber);
                component.set('v.caseId', returnValue.caseId);
                component.set('v.uploadDocuments', returnValue.attachments);
                applicationData = JSON.parse(returnValue.caseItemData); 
                console.log(applicationData);
                component.set('v.notReviewDecisionDate', returnValue.notReviewDecisionDate);
                var i;
                var field;
                var html = '';
                for (i in applicationData){
                    console.log(i);
                    if (i == 'insurerReviewDate' || i == 'emailAddress' || i == 'behalfOfWorker' ){
                        //do nothing
                    }
                    else if (component.find(i) && component.find(i).find('datepicker')){//prefill email
                        component.find(i).find('datepicker').elements[0].value = applicationData[i];
                        if ( !(returnValue.status == 'Pending' || returnValue.status == 'Draft')  || returnValue.isLocked)
                            component.find(i).find('datepicker').elements[0].disabled = true;
                    }
                    else if (document.getElementById(i)){
                        if (document.getElementById(i).type == "checkbox")
                            document.getElementById(i).checked = applicationData[i];
                        else document.getElementById(i).value = applicationData[i];
                        if ( !(returnValue.status == 'Pending' || returnValue.status == 'Draft')  || returnValue.isLocked)
                            document.getElementById(i).disabled = true;
                    }
                    else if (i == 'attachments'){
                        
                    }
                    else if (applicationData[i] && i != 'insurer'){//radio button
                        field =  jQuery('input[name='+i+'][value="' + applicationData[i] + '"]');
                        if (field && field.length>0){
                            field.prop('checked', 'checked');
                        }
                        if (returnValue.status == 'Submitted' || returnValue.isLocked)
                            jQuery('input[name='+i+']').attr('disabled', true);
                    }
                }
                if ( !(returnValue.status == 'Pending' || returnValue.status == 'Draft')  || returnValue.isLocked) {
                    component.set('v.formLocked', true);
                    jQuery('#replyForm :input').prop( "disabled", true );
                }
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    save : function(component, event, helper) {
        var params = {};
        var $inputs = jQuery('#replyForm :input');
        component.set('v.buttonDisable', true);
        $inputs.each(function() {
            if (this.type == "checkbox" && this.name.indexOf('category_sub') == -1)
                params[this.name] = this.checked;
            else if (this.className && this.className.indexOf('inputDate') != -1 && component.find(this.id) && component.find(this.id).find('datepicker').elements[0].value)
                params[this.id] = component.find(this.id).find('datepicker').elements[0].value;
            else if (this.className && this.className.indexOf('insurerLookup') != -1){
                if (component.find('insurer').get('v.selectedInsurer'))
                    params['insurer'] = component.find('insurer').get('v.selectedInsurer');
                else params['insurer'] = '';
            }
            else if (this.type == "radio" && this.name != 'category' && this.name.indexOf('category_sub') == -1){
                if (this.checked)
                    params[this.name] = this.value;
                else if(!params[this.name] || (params[this.name] && params[this.name].length < 1)) 
                    params[this.name] = '';
            }
            else if (this.id && this.id != 'uploadFileDescription' && this.id != 'fileUploaderInput' && this.name.indexOf('category_sub') == -1) {
                params[this.id] = this.value;
            }
        });
        params['caseId'] = component.get('v.caseId');
        params['caseItemId'] = component.get('v.applicationId');
        params['attachments'] = component.get('v.uploadDocuments');
        params['notReviewDecisionDate'] = component.get('v.notReviewDecisionDate');
        var action = component.get('c.savePauseInsurerCaseItem');
        action.setParams({caseItemJson : JSON.stringify(params)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.successMessage', 'Form saved!');
                window.scrollTo(0, 0);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
                window.scrollTo(0, 0);
            }
            component.set('v.buttonDisable', false);
        });
        
        $A.enqueueAction(action);
    },
    submit : function(component, event, helper) {
        var params = {};
        var $inputs = jQuery('#replyForm :input');
        component.set('v.buttonDisable', true);
        $inputs.each(function() {
            if (this.type == "checkbox" && this.name.indexOf('category_sub') == -1)
                params[this.name] = this.checked;
            else if (this.className && this.className.indexOf('inputDate') != -1 && component.find(this.id) && component.find(this.id).find('datepicker').elements[0].value)
                params[this.id] = component.find(this.id).find('datepicker').elements[0].value;
            else if (this.className && this.className.indexOf('insurerLookup') != -1){
                if (component.find('insurer').get('v.selectedInsurer'))
                    params['insurer'] = component.find('insurer').get('v.selectedInsurer');
                else params['insurer'] = '';
            }
            else if (this.type == "radio" && this.name != 'category' && this.name.indexOf('category_sub') == -1){
                if (this.checked)
                    params[this.name] = this.value;
                else if(!params[this.name] || (params[this.name] && params[this.name].length < 1)) 
                    params[this.name] = '';
            }
            else if (this.id && this.id != 'uploadFileDescription' && this.id != 'fileUploaderInput' && this.name.indexOf('category_sub') == -1) {
                params[this.id] = this.value;
            }
        });
        params['caseId'] = component.get('v.caseId');
        params['caseItemId'] = component.get('v.applicationId');
        params['attachments'] = component.get('v.uploadDocuments');
        params['notReviewDecisionDate'] = component.get('v.notReviewDecisionDate');
        var action = component.get('c.saveInsurerCaseItem');
        action.setParams({caseItemJson : JSON.stringify(params)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                window.location.href = "/insurerlegal/s/casedetail?recordId=" + component.get('v.caseId');
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
                window.scrollTo(0, 0);
            }
            component.set('v.buttonDisable', false);
        });
        
        $A.enqueueAction(action);
    }
})