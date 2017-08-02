/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    Trigger on Case.
                        
Test Class:     NA
History
04/June/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
trigger CaseTriggerOLCN on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     CaseTriggerHandlerOLCN.run();
}