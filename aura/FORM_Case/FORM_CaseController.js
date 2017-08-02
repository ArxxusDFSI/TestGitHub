({
    init : function(component, event, helper) {
        var caseId;
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
        var location = window.location.pathname.split('/');
        if (location && location[1])
            component.set('v.communitylink', '/' + location[1] + '/s');
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            
            if (sParameterName[0] === 'recordId') {
                component.set('v.caseId', sParameterName[1] === undefined ? true : sParameterName[1]);
                caseId = sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
        
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
                var status = caseDetails.status;
                var statusBar = $('#statusBar').find('li');
                var statusOn = false;
                for (var i=0; i<statusBar.length; i++){
                    if (statusBar[i].data == status){
                        statusBar[i].className += ' slds-is-current';
                        statusOn = true;
                    }
                    else if (statusOn)
                        statusBar[i].className += ' slds-is-incomplete';
                    else if (!statusOn){
                        statusBar[i].className += ' slds-is-complete';
                        statusBar[i].childNodes[0].innerHTML += '<span class="glyphicon glyphicon-ok" aria-hidden="true"/>'
                    }
                }
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get('c.getCaseTeamBuilder');
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var caseTeamBuilder = JSON.parse(response.returnValue);
                console.log(caseTeamBuilder);
                component.set('v.users', caseTeamBuilder.caseTeamMembers);
                //component.set('v.roles', caseTeamBuilder.roles);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        
        /*$A.createComponent(
            "forceChatter:publisher",
            {
                "context": "RECORD",
                "recordId": caseId
            },
            function(objPublisher, status, errorMessage){
                if (status === "SUCCESS") {
                    var publisherContainer = component.get("v.publisherPlaceHolder");
                    publisherContainer.push(objPublisher);
                    component.set("v.publisherPlaceHolder", publisherContainer);
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        
        $A.createComponent(
            "forceChatter:feed",
            {
                "type":"Record",
                "subjectId":caseId,
                "feedDesign":"BROWSE" 
            },
            function(objFeed, status, errorMessage){
                if (status === "SUCCESS") {
                    var feedPlaceHolder = component.get("v.feedPlaceHolder");
                    feedPlaceHolder.push(objFeed);
                    component.set("v.feedPlaceHolder", feedPlaceHolder);
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );*/
    },
    manage : function(component, event, helper) {
        jQuery('#backdrop').addClass('slds-backdrop--open');
        jQuery('#teamModal').addClass('slds-fade-in-open');
	},
    saveTeamModal : function(component, event, helper) {
        var users = component.get('v.users');
        var selectedUsers = [];
        var roles = component.get('v.roles');
        var table = jQuery('#caseTeamTable tr');
        var i = 0;
        component.set('v.errorMessageRole', '');
        for (var index=0; index<table.length; index++){
            var td = $(table[index]).find('td');
            if (td && td.length > 0 && td[0] && td[0].childNodes && td[0].childNodes[0].checked){
                selectedUsers.push(users[index-1]);
                var option = td[2].childNodes[0].children;
                var valid = false;
                for (var j=0; j<option.length; j++){
                    if (option[j].selected && option[j].value){
                        selectedUsers[i].roleName = option[j].value;
                        selectedUsers[i].roleId = option[j].data;
                        valid = true;
                        i++;
                    }
                };
                if (!valid)
                    component.set('v.errorMessageRole', 'Please select a role for the selected user');
            }
        };
        if (!component.get('v.errorMessageRole')){
            component.set('v.users', selectedUsers);
            jQuery('#teamModal').removeClass('slds-fade-in-open');
      		jQuery('#backdrop').removeClass('slds-backdrop--open');
            
            var action = component.get('c.saveCaseTeamMembers');
            action.setParams({
                caseId : component.get('v.caseId'),
                caseTeamMemberJSONs : JSON.stringify(selectedUsers)
            });
            
            action.setCallback(this, function(response) {
                location.reload();
            });
            $A.enqueueAction(action);
        }
	},
    closeTeamModal: function(component, event, helper) {
        jQuery('#teamModal').removeClass('slds-fade-in-open');
        jQuery('#backdrop').removeClass('slds-backdrop--open');
    },
    upload : function(component, event, helper) {
		jQuery('#fileUploaderInput').change(function() {
            component.set('v.fileName', this.files[0].name);
            jQuery('#backdrop').addClass('slds-backdrop--open');
  			jQuery('#modal').addClass('slds-fade-in-open');
    	}).click();
	},
    closeModal : function(component, event, helper) {
        jQuery('#modal').removeClass('slds-fade-in-open');
  		jQuery('#backdrop').removeClass('slds-backdrop--open');
    },
    saveFile : function(component, event, helper) {
        var category = jQuery('input[name=category]:checked').val();
        var categoryId = jQuery('input[name=category]:checked')[0].data;
        var subcategory = jQuery('input[name=category_sub]:checked').val();
        var subcategoryId = jQuery('input[name=category_sub]:checked')[0].data;
        var uploadFileDescription = jQuery('#uploadFileDescription').val();
        var decisions = [];
        var category_sub_checkbox = jQuery('input[name=category_sub_checkbox]:checked');
        for (var i=0; i<category_sub_checkbox.length; i++){
            if (categoryId == category_sub_checkbox[i].data)
                decisions[i] = category_sub_checkbox[i].value;
        }
        if (category && uploadFileDescription){
			var attachments = component.get('v.uploadDocuments');
            attachments.push({
                'name': component.get('v.fileName'),
                'category': category,
                'subcategory': categoryId == subcategoryId ? subcategory : '',
                'decisions': decisions,
                'description': uploadFileDescription,
                'dateLoaded': helper.todayDate(),
                'submitter': component.get('v.loginUser')
            });
            component.set('v.uploadDocuments', attachments);
            jQuery('#uploadFileDescription').val('');
            jQuery('#modal').removeClass('slds-fade-in-open');
            jQuery('#backdrop').removeClass('slds-backdrop--open');
            component.set('v.fileUploadValidation', false);
            
            //send new attachment data to backend
            var action = component.get('c.addAttachment');
            var param = {
                name : component.get('v.fileName'),
                category : category,
                description : uploadFileDescription,
                caseId : component.get('v.caseId')
            }
            action.setParams({
                attachmentJSON : JSON.stringify(param)
            });
            
            action.setCallback(this, function(response) {
                console.log(response.state);
            });
            
            $A.enqueueAction(action);
        }
        else {
            component.set('v.fileUploadValidation', true);
        }
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