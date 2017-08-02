public class DRS_TopicAssignmentTriggerHandler {
    public static void run() {
        if(Trigger.isExecuting) {
            try{
                if (Trigger.isBefore && Trigger.isInsert) {}
                else if(Trigger.isAfter && Trigger.isInsert) {
                    DRS_TopicAssignmentTriggerHandler.afterInsert();
                }
                else if(Trigger.isBefore && Trigger.isUpdate) {}
                else if(Trigger.isAfter && Trigger.isUpdate) {}
                else if(Trigger.isAfter && Trigger.isDelete) {
                    DRS_TopicAssignmentTriggerHandler.afterDelete();
                }
            }
            catch(System.DmlException excep) {
                System.debug('---DRS_TopicAssignmentTriggerHandler:DMLException:Message:' + excep.getMessage());
                System.debug('---DRS_TopicAssignmentTriggerHandler:DMLException:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
            catch(System.Exception excep) {
                System.debug('---DRS_TopicAssignmentTriggerHandler:Exception:Message:' + excep.getMessage());
                System.debug('---DRS_TopicAssignmentTriggerHandler:Exception:StackTrace:' + excep.getStackTraceString());
                throw excep;
            }
        }
    }
    
    private static void afterInsert() {
        List<SObject> listToUpdate = new List<SObject>();
        listToUpdate = DRS_CaseService.updateCaseTopicAssignment(null, JSON.serialize((Map<Id,TopicAssignment>)Trigger.newMap));
        DRS_GlobalUtility.performDML(null, listToUpdate, null);
    }
    
    private static void afterDelete() {
        List<SObject> listToUpdate = new List<SObject>();
        listToUpdate = DRS_CaseService.updateCaseTopicAssignment(JSON.serialize((Map<Id,TopicAssignment>)Trigger.oldMap), null);
        DRS_GlobalUtility.performDML(null, listToUpdate, null);
    }
}