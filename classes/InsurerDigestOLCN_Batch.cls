/*------------------------------------------------------------
Author:         Shyamala Sridevi 
Company:        Capgemini
Description:    This batch class is to send the emails to the insurer every day at 12AM and 12PM.
                        
Test Class:     InsurerDigestOLCN_Batch_Test
History
05/June/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
Global class InsurerDigestOLCN_Batch implements database.Batchable<sobject>, Database.stateful  {
    Global  Map<id,string> sendEmail=new Map<id,string>();
    Global  Id caseOLCNRecordTypeId = MetaUtilityOLCN.getCaseOnlineClaimRecordType();
    Global Database.QueryLocator start(Database.BatchableContext BC){
            return Database.getQueryLocator('select id,Email__c from Account where OLCN_Email__c!=null and isPartner=true and RecordType.DeveloperName =\'Business_OLCN\'');
             
            
    } 
    Global void execute(Database.BatchableContext BC, List<sObject> Scope){       
        Set<Id> accountIds=new Set<Id>();
        for(Account acc:(List<Account>)Scope)
            {          
                sendEmail.put(acc.id,acc.OLCN_Email__c);
                accountIds.add(acc.id);
            }
        Map<Id,Account> updateAccountMap=new Map<Id,Account>();
        for(Account accountRecord:[select id,(select id from cases__r where OLCN_InsurerStatus__c='Updated' and recordtypeid =:caseOLCNRecordTypeId) from account where RecordType.DeveloperName ='Business_OLCN' And Id IN:accountIds])
        {
            accountRecord.OLCN_InsurerProcessStatusUpdateCount__c=accountRecord.cases__r.size();
            updateAccountMap.put(accountRecord.id,accountRecord);
        }
        for(Account accounNewtRecord:[select id,(select id from cases__r where OLCN_InsurerStatus__c='New' and recordtypeid =:caseOLCNRecordTypeId) from account where RecordType.DeveloperName ='Business_OLCN' And Id IN:accountIds])
        {
            updateAccountMap.get(accounNewtRecord.id).OLCN_InsurerProcessStatusNewCount__c=accounNewtRecord.cases__r.size();
           
        }
        update updateAccountMap.values();
    }
    Global void finish(Database.BatchableContext BC){
          try{
                Id templateId = [Select id from EmailTemplate where DeveloperName=:'Insurer_digest_email'].id;
                if(templateId !=null)
                {
                    List<Messaging.SingleEmailMessage> mailList =new List<Messaging.SingleEmailMessage>();
                    for(id accountRecord:sendEmail.keySet())
                    { 
                            Messaging.SingleEmailMessage Mail = Messaging.renderStoredEmailTemplate(templateId,system.UserInfo.getuserid(),accountRecord);
                            List<String> Emails=new List<String>();
                            Emails.add(sendEmail.get(accountRecord));
                            Mail.setToAddresses(Emails);
                            Mail.setSaveAsActivity(false);
                            mailList.add(Mail);            
                    }
                    Messaging.sendEmail(mailList);
                } 
          }
          catch(exception ex)
          {
              system.debug('Exception :'+ex.getMessage());
          }    
          String sch ='0 0 0/12 1/1 * ? *';
          InsurerDigestOLCN_Schedule scheduleObj=new InsurerDigestOLCN_Schedule ();
          if(!Test.isRunningTest()){   
              String JobId = System.schedule('InsurerDigestOLCN'+system.now(),sch,scheduleObj);
          }
    }
}