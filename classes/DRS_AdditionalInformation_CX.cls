public without sharing class DRS_AdditionalInformation_CX {
    
    public Task objtask {get;set;}
    public CaseItem__c objCaseItem {get;set;}
    
    private string caseId;    
    private ApexPages.StandardController objStandardController;
    
    public DRS_AdditionalInformation_CX(ApexPages.StandardController objStandardController) {
        this.objStandardController = objStandardController;
        this.caseId = objStandardController.getRecord().Id;
        
        TaskTemplate__c objTaskTemplate = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.AdditionalInformationTaskType);
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        
        this.objTask = new Task();
        this.objTask.TaskTemplate__c = objTaskTemplate.Id;
        this.objTask.WhatId = caseId;
        this.objTask.OwnerId = objMRSConfiguration.DefaultTaskOwner__c;
        this.objTask.IsReminderSet  = true;
        this.objTask.ReminderDateTime = this.objTask.ActivityDate;
        this.objTask.Status = DRS_CaseService.InitialTaskStatus;
        this.objTask.IsVisibleInSelfService = true;
        
        this.objCaseItem = new CaseItem__c();
        this.objCaseItem.Case__c = caseId;
        this.objCaseItem.Type__c = DRS_CaseService.AdditionalInformationTaskType;
        this.objCaseItem.Status__c = DRS_CaseService.CaseItemStatusPending;
        this.objCaseItem.CommunityPageURL__c = objTaskTemplate.CommunityPageURL__c;
        this.objCaseItem.DueDate__c = Date.Today().addDays(objTaskTemplate.DaysUntilDueDate__c.intValue());
    }
    
    public PageReference saveAdditionalInformation() {
        DRS_GlobalWrapper.AdditionalInformationJSON objAdditionalInformationJSON = new DRS_GlobalWrapper.AdditionalInformationJSON();
        objAdditionalInformationJSON.requestDetails = objTask.Description;
        this.objCaseItem.CaseItemData__c = JSON.serializePretty(objAdditionalInformationJSON);
        this.objCaseItem.DueDate__c = objTask.ActivityDate;
        Insert this.objCaseItem;
        
        this.objTask.CaseItem__c = this.objCaseItem.Id;
        Insert this.objTask;
        
        DRS_CaseService.sendEmailsToAllCaseTeamMembers(DRS_CaseService.EmailAdditionalInformationRequired, this.caseId, null);
        
        return null;
    }
    
}