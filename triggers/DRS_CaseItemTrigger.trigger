trigger DRS_CaseItemTrigger on CaseItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DRS_CaseItemTriggerHandler.run();
}