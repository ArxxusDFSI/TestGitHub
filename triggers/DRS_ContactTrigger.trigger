trigger DRS_ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DRS_ContactTriggerHandler.run();
}