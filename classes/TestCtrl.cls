public without sharing class TestCtrl {
    
    @AuraEnabled
    public static void updateCaseItem(String caseItemId) {
        for(CaseItem__c objCaseItem : [Select Id, Status__c From CaseItem__c Where Id =: caseItemId]) {
            if(objCaseItem.Status__c == 'Submitted') {
                objCaseItem.Status__c = DRS_CaseService.CaseItemStatusPending;
                Update objCaseItem;
            }
            objCaseItem.Status__c = 'Submitted';
            Update objCaseItem;
        }
    }
    
}