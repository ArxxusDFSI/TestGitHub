trigger DRS_TopicAssignmentTrigger on TopicAssignment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DRS_TopicAssignmentTriggerHandler.run();
}