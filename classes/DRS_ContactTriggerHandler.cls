public class DRS_ContactTriggerHandler {
    public static void run() {
        if(Trigger.isExecuting) {
            try{
                if (Trigger.isBefore && Trigger.isInsert) {
                    DRS_ContactTriggerHandler.beforeInsert();
                }
                else if(Trigger.isAfter && Trigger.isInsert) {
                }
                else if(Trigger.isBefore && Trigger.isUpdate) {
                    DRS_ContactTriggerHandler.beforeUpdate();
                }
                else if(Trigger.isAfter && Trigger.isUpdate) {
                    DRS_ContactTriggerHandler.afterUpdate();
                }
                else if(Trigger.isAfter && Trigger.isDelete) {
                    DRS_ContactTriggerHandler.afterDelete();
                }
            }
            catch(System.DmlException excep) {
                System.debug('---DRS_ContactTriggerHandler:DMLException:Message:' + excep.getMessage());
                System.debug('---DRS_ContactTriggerHandler:DMLException:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
            catch(System.Exception excep) {
                System.debug('---DRS_ContactTriggerHandler:Exception:Message:' + excep.getMessage());
                System.debug('---DRS_ContactTriggerHandler:Exception:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
        }
    }
    
    public static void beforeInsert() { }
    
    public static void beforeUpdate() { }
    
    public static void afterUpdate() {
        List<SObject> listToUpdate = new List<SObject>();
        listToUpdate = DRS_ContactService.updateContactLastNameOnCases(JSON.serialize((Map<Id,Contact>)Trigger.oldMap), JSON.serialize((Map<Id,Contact>)Trigger.newMap));
        DRS_GlobalUtility.performDML(null, listToUpdate, null);
    }
    
    public static void afterDelete() {
        List<SObject> listToUpdate = new List<SObject>();
        listToUpdate = DRS_ContactService.updateContactLastNameOnCases(JSON.serialize((Map<Id,Contact>)Trigger.oldMap), null);
        DRS_GlobalUtility.performDML(null, listToUpdate, null);
    }
}