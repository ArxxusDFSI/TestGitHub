///A controller class for community dashboards
public without sharing class DRS_Dashboard_CC {
    
    ///Gets whether the logged in user is a Delegated Admin or not
    @AuraEnabled
    public static Boolean isDelegatedAdmin() {
        return DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId());
    } 
    
    ///Gets lists of Case Item Lists for the Dashboard:
    ///	Draft Cases: When an application is Saved for Later by a worker. This list is only available for workers
    ///	Open Cases: When the logged in user is part of the case team of an open case
    ///	Closed Cases: When the logged in user is part of the case team of a closed case
    @AuraEnabled
    public static String getCaseItems() {
        Set<Id> setCaseIds = new Set<Id>();
        User objUser = DRS_ContactService.getUserDetails(UserInfo.getUserId());
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = new DRS_GlobalWrapper.DashboardJSON();
        objDashboardJSON.userId = UserInfo.getUserId();
        objDashboardJSON.userFirstName = objUser.FirstName;
        objDashboardJSON.userLastName = objUser.LastName;
        objDashboardJSON.openCaseItems = new List<DRS_GlobalWrapper.CaseItemJSON>();
        objDashboardJSON.pendingCaseItems = new List<DRS_GlobalWrapper.CaseItemJSON>();
        objDashboardJSON.draftCaseItems = new List<DRS_GlobalWrapper.CaseItemJSON>();
        objDashboardJSON.closedCaseItems = new List<DRS_GlobalWrapper.CaseItemJSON>();
        DRS_GlobalWrapper.CaseItemJSON objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
        
        Contact objContact = DRS_ContactService.getContactForUser();
        if(String.isNotBlank(objContact.Role__c) && 
           (objContact.Role__c.contains(DRS_ContactService.ContactRoleWorker) || objContact.Role__c.contains(DRS_ContactService.ContactRoleLegalRep))) {
               objDashboardJSON.showNewApplication = true;
        }
        
        List<Case> listCases = DRS_CaseService.getOpenCasesForUser(UserInfo.getUserId());
        List<Case> listClosedCases = DRS_CaseService.getClosedCasesForUser(UserInfo.getUserId());
        List<CaseItem__c> listPendingCaseItems = new List<CaseItem__c>();
        Boolean isWorker = DRS_ContactService.isWorkerUser(UserInfo.getUserId());
        Boolean isPending = false;
        
        for(Case objCase : listCases) {
            isPending = false;
            
            for(CaseItem__c objCaseItem : objCase.CaseItems__r) {
                if((objCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending || objCaseItem.Status__c == DRS_CaseService.CaseItemStatusDraft) 
                   && String.isNotBlank(objCaseItem.RoleGroup__c)
                   && (objCaseItem.RoleGroup__c.contains(objContact.Account.Type))) 
                {
                    objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
                    objCaseItemJSON.caseItemId = objCaseItem.Id;
                    objCaseItemJSON.caseId = objCase.Id;
                    objCaseItemJSON.caseNumber = objCase.CaseNumber;
                    objCaseItemJSON.submittedBy = objCase.Contact.Name;
                    objCaseItemJSON.submittedDate = (objCase.DateTimeCaseLodged__c != null ? objCase.DateTimeCaseLodged__c.format(DRS_GlobalUtility.DateTimeFormat) : '');
                    objCaseItemJSON.status = objCase.Status;
                    objCaseItemJSON.communityPageURL = objCaseItem.CommunityPageURL__c;
                    objCaseItemJSON.createdDate = objCaseItem.CreatedDate.format(DRS_GlobalUtility.DateTimeFormat);
                    objCaseItemJSON.caseItemType = objCaseItem.Type__c;
                    
                    if(objCaseItem.Type__c == DRS_CaseService.WorkerCaseItemType) {
                        if(objCaseItem.ExpiryDate__c != null) {
                            objCaseItemJSON.remainingTimeToExpire = String.valueOf(Date.today().daysBetween(objCaseItem.ExpiryDate__c.date()));
                        }
                        objDashboardJSON.draftCaseItems.add(objCaseItemJSON);
                    }
                    else {
                        objDashboardJSON.pendingCaseItems.add(objCaseItemJSON);
                    }
                    isPending = true;
                    break;
                }
                else if(objCaseItem.Status__c == DRS_CaseService.CaseItemStatusExpired) {
                    isPending = true;
                    break;
                }
            }
            
            if(!isPending && objCase.Status != DRS_CaseService.CaseStatusDraft) {
                objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
                objCaseItemJSON.caseId = objCase.Id;
                objCaseItemJSON.caseNumber = objCase.CaseNumber;
                objCaseItemJSON.submittedBy = objCase.Contact.Name;
                objCaseItemJSON.submittedDate = (objCase.DateTimeCaseLodged__c != null ? objCase.DateTimeCaseLodged__c.format(DRS_GlobalUtility.DateTimeFormat) : '');
                objCaseItemJSON.status = objCase.Status;
                objDashboardJSON.openCaseItems.add(objCaseItemJSON);
            }
        }
        
        ///Author Jun ZHOU
        ///Return Close Case Items
        if(listClosedCases != null && !listClosedCases.isEmpty()) {
            for(Case objCase : listClosedCases) {
                objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
                objCaseItemJSON.caseId = objCase.Id;
                objCaseItemJSON.caseNumber = objCase.CaseNumber;
                objCaseItemJSON.submittedBy = objCase.Contact.Name;
                objCaseItemJSON.submittedDate = (objCase.DateTimeCaseLodged__c != null ? objCase.DateTimeCaseLodged__c.format(DRS_GlobalUtility.DateTimeFormat) : '');
                objCaseItemJSON.status = objCase.Status;
                objDashboardJSON.closedCaseItems.add(objCaseItemJSON);
            }
        }
        
        System.debug('---DRS_Dashboard_CC:getCaseItems:objDashboardJSON:' + JSON.serialize(objDashboardJSON));
        return JSON.serialize(objDashboardJSON);
    }
    
    ///Deletes the Case Item
    /// Calls the customization to delete Case Items, Attachments
    //	The customization calls S3 to delete the Attachments from S3
    @AuraEnabled
    public static void deleteDrafCaseItem(String caseId) {
        try {
            DRS_CaseService.deleteDraftCase(caseId);
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleAuraException(excep, 'DRS_Dashboard_CC', 'deleteDrafCaseItem');
        }
    }
}