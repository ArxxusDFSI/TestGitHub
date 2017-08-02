({
    init : function(component, event, helper) {
        var caseId;
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariables = sPageURL.split('&');
        var sParameterName;
        var location = window.location.pathname.split('/');
        if (location && location[1])
            component.set('v.communitylink', '/' + location[1] + '/s');
        for (var i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            
            if (sParameterName[0] === 'recordId') {
                component.set('v.caseId', sParameterName[1] === undefined ? true : sParameterName[1]);
                caseId = sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
        
        helper.getCaseSnippet(component);
        helper.getCaseJson(component, caseId);

        if (location[1] != 'mrs01')
            helper.getCaseTeamBuilder(component, caseId);
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