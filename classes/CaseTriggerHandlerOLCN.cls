/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This Class is the Handler class for the Case trigger,Holds all the Case Trigger logic.
                        
Test Class:     TestDataUtilityOLCN
History
04/June/2017    Ankit     Created
------------------------------------------------------------*/
public class CaseTriggerHandlerOLCN {
    
    public static void run() {
        
        //All isInsert Logic to be placed here
        if(Trigger.isInsert){            
            if(Trigger.isBefore){
                CaseTriggerHandlerOLCN.createContacts(); 
                CaseTriggerHandlerOLCN.lookUpOnInsurer();               
                //Logic to check duplicate cases
                CaseTriggerHandlerOLCN.checkDuplicateCases();
            }
            if(Trigger.isAfter){  
              
            }            
        }
        
        //All isUpdate Logic to be placed here
        if(Trigger.isUpdate){            
            if(Trigger.isBefore){ 
                CaseTriggerHandlerOLCN.lookUpOnInsurer();                               
            }
            if(Trigger.isAfter){ 
            
            }
            
        }
        if(trigger.isdelete){
              
        }               
    }
    
    //All the methods will come here
    public static void createContacts() {
        CaseTriggerHelperOLCN.lookupContactOnCase(trigger.new);
    } 
    
    public static void lookUpOnInsurer() {
        CaseTriggerHelperOLCN.lookUpOnInsurer((list<case>)trigger.new); 
    }      
    
    //Added by lavanya to check duplicate cases
    public static void checkDuplicateCases() {
        CaseTriggerHelperOLCN.checkDuplicateCases(trigger.new); 
    } 

}