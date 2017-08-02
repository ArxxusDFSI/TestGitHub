///Controller class for handling Case Detail and Case List pages
public without sharing class DRS_Case_CC {
    
    ///Gets the details of a Case based on caseId
    @AuraEnabled
    public static String getCaseJSON(String caseId) {
        try {
            DRS_GlobalWrapper.CaseJSON objCaseJSON = new DRS_GlobalWrapper.CaseJSON();
            
            Case objCase = DRS_CaseService.getCaseDetails(caseId);
            System.debug('---DRS_Case_CC:getCaseJSON:objCase:' + JSON.serializePretty(objCase));
            Boolean isInternalUser = DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId());
            Boolean isWorkerUser = DRS_ContactService.isWorkerUser(UserInfo.getUserId());
            
            objCaseJSON.submittedCaseItems = new List<DRS_GlobalWrapper.CaseItemJSON>();
            objCaseJSON.pendingCaseItems = new List<DRS_GlobalWrapper.CaseItemJSON>();
            objCaseJSON.attachments = new List<DRS_GlobalWrapper.AttachmentJSON>();
            objCaseJSON.caseTeamMembers = new List<DRS_GlobalWrapper.CaseTeamMemberJSON>();
            DRS_GlobalWrapper.CaseItemJSON objCaseItemJSON;
            DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON;
            DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMemberJSON;
            Contact objContact = DRS_ContactService.getContactForUser();
            
            for(CaseItem__c objCaseItem : objCase.CaseItems__r) {
                if(objCaseItem.Type__c == DRS_CaseService.AllocationChecklistTaskType ||
                   objCaseItem.Type__c == DRS_CaseService.JurisdictionChecklistTaskType) {
                       continue;
                }
                objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
                objCaseItemJSON.CaseItemId = objCaseItem.Id;
                objCaseItemJSON.name = objCaseItem.Name;
                objCaseItemJSON.status = objCaseItem.Status__c;
                objCaseItemJSON.dateSubmitted = objCaseItem.CreatedDate.format(DRS_GlobalUtility.DateTimeFormat);
                objCaseItemJSON.submittedBy = objCaseItem.SubmittedByName__c;
                objCaseItemJSON.CaseItemType = objCaseItem.Type__c;
                objCaseItemJSON.communityPageURL = objCaseItem.CommunityPageURL__c;
                objCaseItemJSON.roleGroup = objCaseItem.RoleGroup__c;
                objCaseItemJSON.dueDate = objCaseItem.DueDate__c != null ? objCaseItem.DueDate__c.format(DRS_GlobalUtility.DateFormat) : '';
                
                objCaseItemJSON.showView = false;
                if(objCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending) {
                    if(objCaseItem.RoleGroup__c.contains(objContact.Account.Type)){
                        objCaseItemJSON.showView = true;
                    }
                    objCaseJSON.pendingCaseItems.add(objCaseItemJSON);
                }
                else {
                    objCaseJSON.submittedCaseItems.add(objCaseItemJSON);
                }
            }
            
            for(Attachment__c objAttachment : objCase.Attachments__r) {
                if(isInternalUser == false && objAttachment.ExternallyVisible__c == false) {
                    continue;
                }
                objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON();
                objAttachmentJSON.name = objAttachment.FileName__c;
                objAttachmentJSON.description = objAttachment.Description__c;
                objAttachmentJSON.category = objAttachment.CategoryA__c;
                objAttachmentJSON.tier2 = objAttachment.CategoryB__c;
                objAttachmentJSON.tier3 = objAttachment.CategoryC__c;
                objAttachmentJSON.author = objAttachment.Author__c;
                objAttachmentJSON.dateOfDocument = DRS_GlobalUtility.convertDateToString(objAttachment.AuthoredDate__c);
                objAttachmentJSON.submitter = objAttachment.SubmittedBy__c;
                objAttachmentJSON.dateLoaded = objAttachment.CreatedDate.format(DRS_GlobalUtility.DateTimeFormat);
                objAttachmentJSON.caseItemId = objAttachment.CaseItem__c;
                objAttachmentJSON.attachmentId = objAttachment.Id;
                objCaseJSON.attachments.add(objAttachmentJSON);
            }
            
            for(CaseTeamMember objCaseTeamMember : objCase.TeamMembers) {
                if(objCaseTeamMember.TeamRole.PreferencesVisibleInCSP == true) {
                    objCaseTeamMemberJSON = new DRS_GlobalWrapper.CaseTeamMemberJSON();
                    objCaseTeamMemberJSON.memberName = objCaseTeamMember.Member.Name;
                    objCaseTeamMemberJSON.roleName = objCaseTeamMember.TeamRole.Name;
                    objCaseJSON.caseTeamMembers.add(objCaseTeamMemberJSON);
                }
            }
            
            objCaseJSON.caseNumber = objCase.CaseNumber;
            objCaseJSON.caseId = objCase.Id;
            objCaseJSON.status = objCase.Status;
            objCaseJSON.claimNumber = objCase.ClaimNumber__c;
            objCaseJSON.primaryContactName = objCase.PrimaryContactName__c;
            objCaseJSON.primaryContactPublicEmail = objCase.PrimaryContactPublicEmail__c;
            objCaseJSON.primaryContactPublicPhone = objCase.PrimaryContactPublicPhone__c;
            objCaseJSON.dateLodged = objCase.DateTimeCaseLodged__c != null ? objCase.DateTimeCaseLodged__c.format(DRS_GlobalUtility.DateTimeFormat) : '';
            objCaseJSON.workerName = objCase.Contact.Name;
            objCaseJSON.insurer = objCase.Insurer__r.Name;
            objCaseJSON.loggedInUserName = objContact.Name;
            objCaseJSON.showManageCaseTeamMembers = !isWorkerUser;
            
            System.debug('---DRS_Case_CC:getCaseJSON:objCaseJSON:' + JSON.serializePretty(objCaseJSON)); JSON.serialize(objCaseJSON);
            return JSON.serialize(objCaseJSON);
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_Case_CC', 'getCaseJSON');
        }
    }
    
    @AuraEnabled
    public static String getCaseDetailSnippets() {
        DRS_GlobalWrapper.CaseDetailJSON objCaseDetailJSON = new DRS_GlobalWrapper.CaseDetailJSON();
        objCaseDetailJSON.caseStatuses = new List<DRS_GlobalWrapper.SnippetJSON>();
        objCaseDetailJSON.pendingCases = new DRS_GlobalWrapper.SnippetJSON();
        objCaseDetailJSON.attachments = new DRS_GlobalWrapper.SnippetJSON();
        objCaseDetailJSON.caseItems = new DRS_GlobalWrapper.SnippetJSON();
        DRS_GlobalWrapper.SnippetJSON objSnippetJSON = new DRS_GlobalWrapper.SnippetJSON();
        
        List<Snippet__c> listSnippets = DRS_GlobalUtility.getSnippetsForLocation(DRS_GlobalUtility.LocationMRSCaseStatus, null);
        List<Snippet__c> listDescriptions = DRS_GlobalUtility.getSnippetsForLocation(DRS_GlobalUtility.LocationMRSCaseDetails, null);
        System.debug('---DRS_Case_CC:getCaseDetailSnippets:listSnippets:' + JSON.serializePretty(listSnippets));
        System.debug('---DRS_Case_CC:getCaseDetailSnippets:listDescriptions:' + JSON.serializePretty(listDescriptions));
        
        for(Snippet__c objSnippet : listSnippets) {
            objSnippetJSON = new DRS_GlobalWrapper.SnippetJSON();
            objSnippetJSON.name = objSnippet.SnippetName__c;
            objSnippetJSON.description = objSnippet.Value__c;
            objCaseDetailJSON.caseStatuses.add(objSnippetJSON);
        }
        for(Snippet__c objSnippet : listDescriptions) {
            if(objSnippet.SnippetName__c == 'pendingCases') {
                objCaseDetailJSON.pendingCases.name = objSnippet.SnippetName__c;
                objCaseDetailJSON.pendingCases.description = objSnippet.Value__c;
            }
            else if(objSnippet.SnippetName__c == 'attachments') {
                objCaseDetailJSON.attachments.name = objSnippet.SnippetName__c;
                objCaseDetailJSON.attachments.description = objSnippet.Value__c;
            }
            else if(objSnippet.SnippetName__c == 'caseItems') {
                objCaseDetailJSON.caseItems.name = objSnippet.SnippetName__c;
                objCaseDetailJSON.caseItems.description = objSnippet.Value__c;
            }
        }
        
        System.debug('---DRS_Case_CC:getCaseDetailSnippets:objCaseDetailJSON:' + JSON.serializePretty(objCaseDetailJSON));
        return JSON.serialize(objCaseDetailJSON);
    }
    
    @AuraEnabled
    public static String getCaseTeamBuilder(String caseId) {
        try {
            DRS_GlobalWrapper.CaseTeamBuilderJSON objCaseTeamBuilderJSON = new DRS_GlobalWrapper.CaseTeamBuilderJSON();
            objCaseTeamBuilderJSON.caseTeamMembers = new List<DRS_GlobalWrapper.CaseTeamMemberJSON>();
            objCaseTeamBuilderJSON.roles = new List<DRS_GlobalWrapper.RoleJSON>();
            DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMemberJSON;
            DRS_GlobalWrapper.RoleJSON objRoleJSON;
            
            Map<String,Id> caseTeamRoles = DRS_CaseService.getCaseTeamRoles();
            Case objCase = DRS_CaseService.getCaseDetails(caseId);
            Contact objContact = DRS_ContactService.getContactForUser(UserInfo.getUserId());
            List<User> listUsers = DRS_ContactService.getUsersForAccount(objContact.AccountId);
            List<String> contactRoles = (String.isNotBlank(objContact.Role__c) ? objContact.Role__c.split(';') : new List<String>());
            List<CaseTeamRoleAssociation__c> listCaseTeamRoleAssociations = new List<CaseTeamRoleAssociation__c>();
            listCaseTeamRoleAssociations = DRS_GlobalUtility.getCaseTeamRoleAssociationForAccountType(objContact.Account.Type);
            
            System.debug('---DRS_Case_CC:getCaseTeamBuilder:listUsers:' + listUsers);
            for(User objUser : listUsers) {
                objCaseTeamMemberJSON = new DRS_GlobalWrapper.CaseTeamMemberJSON();
                objCaseTeamMemberJSON.caseId = caseId;
                objCaseTeamMemberJSON.memberId = objUser.Id;
                objCaseTeamMemberJSON.memberName = objUser.Name;
                objCaseTeamMemberJSON.isExisting = false;
                objCaseTeamMemberJSON.availableRoles = new List<DRS_GlobalWrapper.RoleJSON>();
                
                contactRoles = (String.isNotBlank(objUser.Contact.Role__c) ? objUser.Contact.Role__c.split(';') : new List<String>());
                
                for(String contactRole : contactRoles) {
                    for(CaseTeamRoleAssociation__c objCaseTeamRoleAssociations : listCaseTeamRoleAssociations) {
                        if(contactRole == objCaseTeamRoleAssociations.ContactRole__c && contactRole != DRS_ContactService.ContactRoleAdministrator) {
                            objRoleJSON = new DRS_GlobalWrapper.RoleJSON();
                            objRoleJSON.roleId = caseTeamRoles.get(objCaseTeamRoleAssociations.CaseTeamRole__c);
                            objRoleJSON.roleName = objCaseTeamRoleAssociations.CaseTeamRole__c;
                            objCaseTeamMemberJSON.availableRoles.add(objRoleJSON);
                            break;
                        }
                    }
                }
                
                if(objCaseTeamMemberJSON.availableRoles.size() > 0) {
                    for(CaseTeamMember objCaseTeamMember : objCase.TeamMembers) {
                        if (objUser.Id == objCaseTeamMember.Member.Id) {
                            objCaseTeamMemberJSON.caseTeamMemberId = objCaseTeamMember.Id;
                            objCaseTeamMemberJSON.roleId = objCaseTeamMember.TeamRole.Id;
                            objCaseTeamMemberJSON.roleName = objCaseTeamMember.TeamRole.Name;
                            objCaseTeamMemberJSON.isExisting = true;
                            break;
                        }
                    }
                    objCaseTeamBuilderJSON.caseTeamMembers.add(objCaseTeamMemberJSON);
                }
            }
            System.debug('---DRS_Case_CC:getCaseTeamBuilder:objCaseTeamBuilderJSON.caseTeamMembers:' + objCaseTeamBuilderJSON.caseTeamMembers);
            
            System.debug('---DRS_Case_CC:getCaseTeamBuilder:objCaseTeamBuilderJSON:' + JSON.serializePretty(objCaseTeamBuilderJSON));
            return JSON.serialize(objCaseTeamBuilderJSON);
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_Case_CC', 'getCaseTeamBuilder');
        }
    }
    
    @AuraEnabled 
    public static String saveCaseTeamMembers(String caseId, String caseTeamMemberJSONs) {
        System.debug('---DRS_Case_CC:saveCaseTeamMembers:caseTeamMemberJSONs:' + caseTeamMemberJSONs);
        try{            
            DRS_CaseService.saveCaseTeamMembers(caseId, caseTeamMemberJSONs);
        }
        catch(DRS_GlobalException.ServiceException excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_Case_CC', 'saveCaseTeamMembers');
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static String addAttachment(String attachmentJSON) {
        System.debug('---DRS_Case_CC:addAttachment:attachmentJSON:' + attachmentJSON);
        try {
            return DRS_CaseService.addAttachment(attachmentJSON);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'addAttachment');
        }
    }
    
    @AuraEnabled
    public static String getCaseList() {
        
        List<DRS_GlobalWrapper.CaseJSON> listCaseJSON = new List<DRS_GlobalWrapper.CaseJSON>();
        DRS_GlobalWrapper.CaseJSON objCaseJSON;
        List<Case> listCases;
        
        if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
            listCases = DRS_CaseService.getOpenCasesForAdminUser(UserInfo.getUserId());
        }
        else {
            listCases = DRS_CaseService.getOpenCasesForUser(UserInfo.getUserId());
        }
        
        for(Case objCase : listCases) {
            if(objCase.Status == DRS_CaseService.CaseStatusDraft) {continue;}
            objCaseJSON = new DRS_GlobalWrapper.CaseJSON();
            objCaseJSON.caseId = objCase.Id;
            objCaseJSON.caseNumber = objCase.CaseNumber;
            objCaseJSON.status = objCase.Status;
            objCaseJSON.claimNumber = objCase.ClaimNumber__c;
            objCaseJSON.dateLodged = objCase.DateTimeCaseLodged__c != null ? objCase.DateTimeCaseLodged__c.format(DRS_GlobalUtility.DateTimeFormat) : '';
            objCaseJSON.insurer = objCase.Insurer__r.Name;
            objCaseJSON.workerName = objCase.Contact.Name;
            listCaseJSON.add(objCaseJSON);
        }
        
        System.debug('---DRS_Case_CC:getCaseList:listCaseJSON:' + JSON.serializePretty(listCaseJSON));
        return JSON.serialize(listCaseJSON);
    }

}