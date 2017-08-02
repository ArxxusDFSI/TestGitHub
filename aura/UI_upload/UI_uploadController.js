({
    init: function(component, event, helper) {
        if (window.location.pathname == '/apex/DRS_Case_UploadApp' || window.location.pathname == '/apex/DRS_Case_WorkerCaseItemCreate'){
            component.set('v.pageMode', 'internal');
            component.set('v.communityPagePrefix', '/apex');
        }
        else if (window.location.pathname && window.location.pathname.split('/')[1]) {
            component.set('v.communityPagePrefix', '/' + window.location.pathname.split('/')[1]);
        }
        component.set('v.uploadForm', {
            'internalAuthor': '',
            'decisionSentDate': '',
            'internalReviewer': '',
            'author': '',
            'dateOfDocument': '',
            'fromDateCorrespondance': '',
            'toDateCorrespondance': '',
            'description': '',
            'externallyVisible': false,
            'category': '',
            'tier2': '',
            'tier3':''
        });
        helper.getCategories(component);
    },
    onScriptLoad: function(component, event, helper) {
        jQuery('.glyphicon-info-sign').tooltip();
    },
    openView : function(component, event, helper) {
        console.log('Setting: ' + event);
        //component.set('v.viewDocument', event.currentTarget.getAttribute('data-url'));
        window.open(component.get('v.communityPagePrefix') + "/DRS_Attachment_View?id=" + event.currentTarget.getAttribute('data-url'));
    },
    closeView : function(component, event, helper) {
        console.log('Closing');
        component.set('v.viewDocument', null);
    },
    upload : function(component, event, helper) {
        jQuery('#fileUploaderInput').change(function() {
            if (this.files.length === 0){
                return;
            } 
            component.set('v.fileName', this.files && this.files[0] && this.files[0].name);
            jQuery('#backdrop').addClass('slds-backdrop--open');
            jQuery('#modal').addClass('slds-fade-in-open');
        }).click();
    },
    closeModal : function(component, event, helper) {
        jQuery('#fileUploaderInput').val('');
        jQuery('#modal').removeClass('slds-fade-in-open');
        jQuery('#backdrop').removeClass('slds-backdrop--open');
    },
    saveFile : function(component, event, helper) {
        var isValid = false;
        var category = jQuery('input[name=category]:checked').val();
        var categoryId = jQuery('input[name=category]:checked')[0] && jQuery('input[name=category]:checked')[0].data;
        var subcategoryId = jQuery('input[name=category_sub]:checked')[0] && jQuery('input[name=category_sub]:checked')[0].data;
        var subcategory = jQuery('input[name=category_sub]:checked').val();
        //var uploadFileDescription = jQuery('#uploadFileDescription').val();
        var externallyVisible = jQuery('#externallyVisible').is(':checked');
        //var author = jQuery('#author').val();
        //var dateOfDocument = jQuery('#dateOfDocument').val();
        var tier3;
        var category_sub_checkbox = jQuery('input[name=category_sub_checkbox]:checked');
        //var fromDateCorrespondance = jQuery('#fromDateCorrespondance') && jQuery('#fromDateCorrespondance').val();
        //var toDateCorrespondance = jQuery('#toDateCorrespondance') && jQuery('#toDateCorrespondance').val();
        var files = jQuery('#fileUploaderInput').prop("files");
        var fileName = files[0].name;
        var fileSize = files[0].size;
        var fileExtention = fileName.substring(fileName.lastIndexOf('.') + 1).toUpperCase();
        var extentionsArray = ['PDF', 'DOC', 'DOCX', 'BMP', 'JPG', 'TIF', 'PNG', 'GIF']; 
        var params = component.get('v.uploadForm');

        if (category && params.description && params.author && params.dateOfDocument){ //Check that all the fields required are for Categories and Sub-Categories are filled
            isValid = true;
        }
        else if(params.description && window.location.pathname.split('/')[1] != 'insurerlegal'){ //Check that all the description is filled //MRS-316 remove cateogry from worker
            isValid = true;
        }
        else if(component.get('v.pageMode') === 'internal') {
            isValid = true;
        }
        else { //Otherwise, show an error 
            component.set('v.fileUploadValidationError', true);
            window.scrollTo(0, 0);
        }
        //If the input was correct
        //Upload the file to S3 and reset the form fields
        //Set uploaded documents array with newly attached file values
        if(isValid) {
            if (component.get('v.pageMode') != 'internal') {
                jQuery('#backdrop').addClass('slds-backdrop--open');
                jQuery('#progressBarModal').addClass('slds-fade-in-open');
                helper.startProgressBar(component, helper);
            }
            for (var i=0; i<category_sub_checkbox.length; i++){
                tier3 = category_sub_checkbox[i].value;
                category_sub_checkbox[i].checked = false;
            }
            //Create the paramaters to be passed to the backend
            params.name = component.get('v.fileName');
            params.category = category;
            params.tier2 = subcategory;
            params.tier3 = tier3;
            params.caseId = component.get('v.caseId');
            params.caseItemId = component.get('v.caseItemId') || '';
            params.dateLoaded = helper.todayDate();
            params.submitter = component.get('v.loginUser');
            params.externallyVisible = externallyVisible;
            
            //Push the information for new attachment to uploadDocuments array
            var uploadDocuments = component.get('v.uploadDocuments');
            uploadDocuments.push (params);
            component.set('v.uploadDocuments', uploadDocuments);
            
            //Reset the form elements
            if (subcategory){
                jQuery('input[name=category_sub]:checked').prop('checked', false);
                jQuery('input[name=category]:checked').prop('checked', false);
            }
            component.set('v.optionSubmenuVisible', '');
            component.set('v.optionSubSubmenuVisible', '');
            component.set('v.uploadForm', {
                'internalAuthor': '',
                'decisionSentDate': '',
                'internalReviewer': '',
                'author': '',
                'dateOfDocument': '',
                'fromDateCorrespondance': '',
                'toDateCorrespondance': '',
                'description': '',
                'externallyVisible': ''
            });
            jQuery('#modal').removeClass('slds-fade-in-open');
            jQuery('#backdrop').removeClass('slds-backdrop--open');
            component.set('v.fileUploadValidationError', false);
            
            var action = component.get('c.addAttachmentAndGetSignedURL');
            action.setParams({
                attachmentJSON : JSON.stringify(params)
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var attachmentSaveResponse = JSON.parse(response.returnValue);
                    helper.handleAttachmentArray(component, attachmentSaveResponse);
                    
                    var sendToS3UsingSignedURL = function (file, signedURL, component) {
                        
                        return jQuery.ajax({
                            url: signedURL,
                            contentType: (!file.type || file.type ==='')? 'binary/octet-stream' : file.type,
                            headers: {'x-amz-server-side-encryption':'AES256'},
                            type: 'PUT',
                            data: file,
                            processData: false,
                            success: function(result){
                                helper.handleUploadSuccess(component, result); 
                            },
                            error: function(err){ helper.handleUploadError(component, err); }
                        });
                    };
                    
                    var s3Url = attachmentSaveResponse.saveURL;
                    return sendToS3UsingSignedURL(files[0], s3Url, component).done(function(data, status, headers, config) {
                        
                    });
                    
                }
                else {
                    component.set('v.errorMessage', response.getError()[0].message);
                }
            });
            $A.enqueueAction(action);
        }
    },
    removeFile: function(component, event){
        var uploadDocuments = component.get('v.uploadDocuments');
        uploadDocuments.splice(event.target.data, 1);
        component.set('v.uploadDocuments', uploadDocuments);
        var action = component.get('c.removeAttachment');
        action.setParams({
            attachmentId : event.target.name
        }); 
        action.setCallback(this, function(response) {
            console.log(response.state);
        });
        
        $A.enqueueAction(action);
    },
    evntOptionSubmenu: function(component, event){
        // get Option Index
        var data = parseInt(event.target.data, 10);
        component.set('v.optionSubmenuVisible', data);
    },
    evntSubOptionSubmenu: function(component, event, helper) {
        var data = parseInt(event.target.data, 10);
        component.set('v.optionSubSubmenuVisible', data);
    }
})