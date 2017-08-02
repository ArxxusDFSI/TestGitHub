public class DRS_TaskTriggerHandler {
    public static void run() {
        if(Trigger.isExecuting) {
            try{
                if (Trigger.isBefore && Trigger.isInsert) {
                    DRS_TaskTriggerHandler.beforeInsert();
                }
                else if(Trigger.isAfter && Trigger.isInsert) {}
                else if(Trigger.isBefore && Trigger.isUpdate) {}
                else if(Trigger.isAfter && Trigger.isUpdate) {}
            }
            catch(System.DmlException excep) {
                System.debug('---DRS_TaskTriggerHandler:DMLException:Message:' + excep.getMessage());
                System.debug('---DRS_TaskTriggerHandler:DMLException:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
            catch(System.Exception excep) {
                System.debug('---DRS_TaskTriggerHandler:Exception:Message:' + excep.getMessage());
                System.debug('---DRS_TaskTriggerHandler:Exception:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
        }
    }
    
    public static void beforeInsert() {
        DRS_CaseService.setupTasksWithTaskTemplateDetails(Trigger.new);
    }
    
}