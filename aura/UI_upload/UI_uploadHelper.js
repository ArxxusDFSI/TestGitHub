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
    getCategories: function(component) {
        action = component.get('c.getCategories');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var responseData = JSON.parse(response.returnValue);
                var categoryData = {};
                var snippetName, tier1, tier2, tier3, tier2Data;
                for (var i=0; i<responseData.length; i++){
                    snippetName = responseData[i].SnippetName__c.split('.');
                    tier1 = snippetName[0];
                    tier2 = snippetName[1];
                    tier3 = snippetName[2];
                    if (!categoryData[tier1])
                        categoryData[tier1] = {};
                    if (!categoryData[tier1].tier2)
                        categoryData[tier1].tier2 = [];
                    if (tier3){
                        for (var j=0; j<categoryData[tier1].tier2.length; j++){
                            if (categoryData[tier1].tier2[j].name == tier2){
                                categoryData[tier1].tier2[j].tier3.push({
                                    'value': responseData[i].Value__c.replace(/\s+/g, ' '),
                                    'name': tier3
                                });
                            }
                        }
                    }
                    else if (tier2){
                        if (tier2 == 'helptext')
                            categoryData[tier1].helptext = responseData[i].Value__c.replace(/\s+/g, ' ');
                        else{
                            tier2Data = {
                                'value': responseData[i].Value__c.replace(/\s+/g, ' '),
                                'name': tier2,
                                'tier3': []
                            };
                            categoryData[tier1].tier2.push(tier2Data);
                        }
                    }
                        else if (tier1){
                            categoryData[tier1].value = responseData[i].Value__c.replace(/\s+/g, ' ');
                        }
                }
                component.set('v.categories', Object.keys(categoryData).map(function(key) {
                    return categoryData[key];
                }));
            }
        });
        $A.enqueueAction(action);
    },
    startProgressBar: function(component, helper) {
        var timer = window.setTimeout(
            $A.getCallback(function() {
                var progressPercentage = component.get('v.progressPercentage');
                if (parseInt(progressPercentage) < 99) {
                    component.set('v.progressPercentage', progressPercentage + 1);
                    helper.startProgressBar(component, helper);
                }
                else {
                    window.clearTimeout(timer);
                }
            }), 100
        );
    },
    handleUploadSuccess: function(component, result) {
        if (window.location.pathname != '/apex/DRS_Case_UploadApp') {
            component.set('v.progressPercentage', 100);
            window.setTimeout(
                $A.getCallback(function() {
                    jQuery('#backdrop').removeClass('slds-backdrop--open');
                    jQuery('#progressBarModal').removeClass('slds-fade-in-open');
                    component.set('v.progressPercentage', 0);
                    if (window.location.pathname == "/insurerlegal/s/casedetail") {
                        location.reload();
                    }
                }), 1000
            );
        }
        
        if (window.location.pathname == '/apex/DRS_Case_UploadApp') {
            sforce.console.getEnclosingPrimaryTabId(function(result) { 
                sforce.console.refreshPrimaryTabById(result.id, true, function(result2) {
                    sforce.console.getEnclosingTabId(function(result3) {
                        sforce.console.closeTab(result3.id);
                    });
                });
            });
        }
    },
    handleUploadError: function(component, err) {
        if (window.location.pathname != '/apex/DRS_Case_UploadApp') {
            component.set('v.progressPercentage', 100);
            window.setTimeout(
                $A.getCallback(function() {
                    jQuery('#backdrop').removeClass('slds-backdrop--open');
                    jQuery('#progressBarModal').removeClass('slds-fade-in-open');
                    component.set('v.progressPercentage', 0);
                }), 1000
            );
        }
        console.log("Uploading error: " + err);
        var uploadDocuments = component.get('v.uploadDocuments');
        var attachmendId = uploadDocuments[uploadDocuments.length - 1].attachmentId;
        uploadDocuments.splice(-1, 1);
        component.set('v.uploadDocuments', uploadDocuments);
        var action = component.get('c.removeAttachment');
        action.setParams({
            attachmentId : attachmendId
        }); 
        action.setCallback(this, function(response) {
            console.log(response.state);
        });
        
        $A.enqueueAction(action);
    },
    handleMultipartUploadError: function(component, err, attachmentJSON) {
        var action = component.get('c.abortMultipartUpload');
        action.setParams({
            attachmentJSON : attachmentJSON
        }); 
        action.setCallback(this, function(response) {
            console.log(response.state);
        });
        
        $A.enqueueAction(action);
    },
    handleAttachmentArray: function(component, attachmentSaveResponse) {
        var uploadDocumentArray = component.get('v.uploadDocuments');
        var length = component.get('v.uploadDocuments').length - 1;
        uploadDocumentArray[length].attachmentId = attachmentSaveResponse.attachmentId;
        component.set('v.uploadDocuments', uploadDocumentArray);
        
        jQuery('#uploadDoc' + length).attr('name', attachmentSaveResponse.attachmentId);
        jQuery('#uploadDoc' + length).attr('attachmentId', attachmentSaveResponse.attachmentId);
        jQuery('#uploadDoc' + length).attr('url', attachmentSaveResponse.saveURL);
    }
})