public without sharing class DRS_CaseItem_CX {
    ApexPages.StandardController objStandardController;
    public string recordId {get;set;}
    public string componentName {get;set;}
    
    public DRS_CaseItem_CX(ApexPages.StandardController objStandardController) {
        this.objStandardController = objStandardController;
        this.recordId = objStandardController.getRecord().Id;
        
        CaseItem__c objCaseItem = DRS_CaseService.getCaseItemDetails(this.recordId);
        if(objCaseItem.CommunityPageURL__c == 'form') {
            componentName = 'c:FORM_Dispute';
        }
        else if(objCaseItem.CommunityPageURL__c == 'insurerform') {
            componentName = 'c:FORM_InsurerReply';
        }
        else if(objCaseItem.CommunityPageURL__c == 'additionalinfo') {
            componentName = 'c:FORM_AdditionalInfo';
        }
        else if(objCaseItem.CommunityPageURL__c == 'jurisdictionchecklist') {
            componentName = 'c:FORM_Checklist';
        }
        else if(objCaseItem.CommunityPageURL__c == 'allocationchecklist') {
            componentName = 'c:FORM_JurisdictionChecklist';
        }
    }
}