/*******************************************************************************************
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the Lightening Component for CaseExportContoller Page                      
Test Class:     CaseExportContoller_test
History
13/July/2017    Shyamala Sridevi     Created
********************************************************************************************/
public class CaseExportContoller
{
    @AuraEnabled
    public static List<Case> getCaseList(string lastndays)
    {
        string soqlString ='Select CaseNumber,OLCN_InsurerStatus__c,OLCN_Insurer__r.Name,OLCN_MatchedDay__c,OLCN_MatchedMonth__c,OLCN_MatchedYear__c,OLCN_AccidentDay__c,OLCN_AccidentMonth__c,OLCN_AccidentYear__c,OLCN_AtFaultRegistrationNumber__c,OLCN_AccidentLocation__c,OLCN_FormFirstName__c,OLCN_FormLastName__c,OLCN_FormEmail__c,OLCN_FormPhone__c,OLCN_AccidentRole__c,OLCN_AccidentRoleOther__c,OLCN_FormSubmitter__c,OLCN_RepType__c,OLCN_RepTypeOther__c,OLCN_FormRepFirstName__c,OLCN_FormRepLastName__c,OLCN_FormRepEmail__c,OLCN_RepPhone__c,OLCN_SendTo__c from Case Where OLCN_InsurerStatus__c IN (\'New\',\'Updated\')';
               
        if(!string.isEmpty(lastndays))
        {
            soqlString = soqlString+'and OLCN_MatchedDate__c =LAST_N_DAYS :'+lastndays;
        }
        List<Case> caseList=database.query(soqlString);
        updateCaseInsurerStatus(caseList);      
        return caseList;
    }   
    public static Void updateCaseInsurerStatus(list<Case> listOfCases)
    {
        list<Case> listOfCaseRecords=new List<Case>();
        for(case caseID:listOfCases)
        {
            Case caseRecord=new Case();
            caseRecord.id=caseID.id;
            caseRecord.OLCN_InsurerStatus__c='Downloaded';
            listOfCaseRecords.add(caseRecord);
        }
        update(listOfCaseRecords);
    }    
}