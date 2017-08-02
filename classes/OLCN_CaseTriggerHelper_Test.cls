/*------------------------------------------------------------
Author:         Lavanya Uddarraju
Company:        Capgemini
Description:    This is the test class for Case trigger Helper class 
                        
History
27/July/2017    <Lavanya Uddarraju>     Created
------------------------------------------------------------*/
@isTest
public class OLCN_CaseTriggerHelper_Test{

 //   @testsetup
    public static testmethod void testSetUpData()
    {           
		//TestDataUtilityOLCN.createCaseList();
		Id CaseRecordType= MetaUtilityOLCN.getCaseOnlineClaimRecordType(); 
        case cs = new case();
        cs.OLCN_FormFirstName__c ='FName';
        cs.RecordTypeId=CaseRecordType;
        cs.OLCN_FormLastName__c ='LName';
        cs.OLCN_AccidentDate__c=Date.Today();
        cs.OLCN_AtFaultRegistrationNumber__c='123abc';
        cs.Origin='Web';
        insert cs;
        
        case cs1 = new case();
        cs1.OLCN_FormFirstName__c ='FName';
        cs1.RecordTypeId=CaseRecordType;
        cs1.OLCN_FormLastName__c ='LName';
        cs1.OLCN_AccidentDate__c=Date.Today();
        cs1.OLCN_AtFaultRegistrationNumber__c='123abc';
        cs1.Origin='Web';
        insert cs1;
        system.assertEquals(cs1.OLCN_CloseReason__c, 'Duplicate');
        
        
    }           
}