/*------------------------------------------------------------
Author:         <Shyamala Sridevi>
Company:        Capgemini
Description:    This is the test class for InsurerDigestOLCN_Batch
                        
Test Class:     NA
History
05/June/2017    <Shyamala Sridevi>     Created
------------------------------------------------------------*/
@isTest(SeeAllData=false )
public with sharing class InsurerDigestOLCN_Batch_Test {
    
    //All test methods will come here.
    //Create test data inside TestDataUtilityOLCN
    @testsetup
    public static void testSetupData()
    { 
        TestDataUtilityOLCN.createAccountList(); 
    }
    public static testMethod void testInsurerDigestEmails()
    {
           Test.startTest();                 
           List<Account> lstAcc=[select id,OLCN_Email__c,(select id from cases__r) from Account where OLCN_Email__c!=null and RecordType.Name='Business'];
           InsurerDigestOLCN_Batch DB = new InsurerDigestOLCN_Batch();
           DataBase.ExecuteBatch(DB); 
        // DB.execute(null, lstAcc);
           String sch ='0 0 0/12 1/1 * ? *';
           InsurerDigestOLCN_Schedule scheduleObj=new InsurerDigestOLCN_Schedule ();
           String jobId = System.schedule('InsurerDigestOLCN',sch,scheduleObj);
           Test.stopTest();      
    }   
}