public without sharing class DRS_CaseItemTriggerHandler {
    public static void run() {
        if(Trigger.isExecuting) {
            try{
                if (Trigger.isBefore && Trigger.isInsert) {
                    DRS_CaseItemTriggerHandler.beforeInsert();
                }
                else if(Trigger.isAfter && Trigger.isInsert) {
                }
                else if(Trigger.isBefore && Trigger.isUpdate) {
                    DRS_CaseItemTriggerHandler.beforeUpdate();
                }
                else if(Trigger.isAfter && Trigger.isUpdate) {
                    DRS_CaseItemTriggerHandler.afterUpdate();
                }
            }
            catch(System.DmlException excep) {
                System.debug('---DRS_CaseItemTriggerHandler:DMLException:Message:' + excep.getMessage());
                System.debug('---DRS_CaseItemTriggerHandler:DMLException:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
            catch(System.Exception excep) {
                System.debug('---DRS_CaseItemTriggerHandler:Exception:Message:' + excep.getMessage());
                System.debug('---DRS_CaseItemTriggerHandler:Exception:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
        }
    }
    
    public static void beforeInsert() { }
    
    public static void beforeUpdate() { }
    
    public static void afterUpdate() {
        List<SObject> listToUpdate = new List<SObject>();
        listToUpdate = DRS_CaseService.markCaseItemTasksAsCompleted(JSON.serialize((Map<Id,CaseItem__c>)Trigger.oldMap), JSON.serialize((Map<Id,CaseItem__c>)Trigger.newMap));
        DRS_GlobalUtility.performDML(null, listToUpdate, null);
    }
}