/*------------------------------------------------------------
Author:         Shyamala Sridevi 
Company:        Capgemini
Description:    This Schedule class is to send the emails to the insurer every day at 12AM and 12PM.
                        
Test Class:     InsurerDigestOLCN_Batch_Test
History
05/June/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
Global Class InsurerDigestOLCN_Schedule implements Schedulable
{
      Global Void Execute(SchedulableContext sc) {
          CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :sc.getTriggerId()];
          if(ct != null) {
              System.abortJob(ct.Id); 
          }
          InsurerDigestOLCN_Batch batch = new InsurerDigestOLCN_Batch(); 
          if(!Test.isRunningTest()){  
              database.executeBatch(batch,10);
          }        
      }
}