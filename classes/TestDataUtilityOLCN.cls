/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    Utill class to contain reusable code for test data creation.
                        
Test Class:     NA
History
04/June/2017    Ankit     Created
05/June/2017    Shyamala Sridevi     Updated to create the test data for InsurerDigestOLCN_Batch_Test test class 
------------------------------------------------------------*/
@isTest
public class TestDataUtilityOLCN {
   
    public static void createAccountList()
    {
        List<Account> lstAccount= new List<Account>();
        List<Contact> listOfContact= new List<Contact>();
        list<User>    userList=new List<User>();
     
        Id IPM_BusinessRecordTypeId = MetaUtilityOLCN.getAccountBusinessOLCNRecordType();
        for(Integer i=0 ;i <100;i++)
        {
            Account acc = new Account();
            acc.Name ='name'+i;
            acc.RecordTypeId=IPM_BusinessRecordTypeId;
            acc.OLCN_Email__C='name'+i+'@t.com';
            lstAccount.add(acc);
        }
        
        insert lstAccount;
        for(Integer i=0 ;i <100;i++)
        {
            Contact cnt=new Contact();
            cnt.LastName='testlast'+1;
            cnt.FirstName='testFirst'+1;
            cnt.Email='test'+i+'@test.com';
            cnt.Phone='090901'+1;
            cnt.AccountId=lstAccount[i].id;
            listOfContact.add(cnt);
        }
        insert listOfContact;
        
        Profile p = [Select ID, Name from Profile Where Name = '~CTP Insurer'];
        for(Integer i=0 ;i <100;i++){
            User u = New User(
            userName = 'test'+Math.random()+ '@test.com',
            firstName = 'Test-First'+i,
            lastName = 'Test-Last'+i,
            alias = 'test'+i,
            email = 'test'+i+'@test.com',
            communityNickName  = string.valueOf(math.random()).substring(0,6)+i,
            profileID = p.id,
            timeZoneSidKey = 'America/New_York', 
            localeSidKey = 'en_US', 
            emailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            contactID = listOfContact[i].id

            );
            userList.add(u);
        }
        insert userList;
        
        Id CaseRecordType= MetaUtilityOLCN.getCaseOnlineClaimRecordType();
        List<Case> caseLst=new List<Case>();
        for(Integer i=0 ;i <100;i++){
            Case c=new Case ();
            c.RecordTypeId=caseRecordType;
            c.Subject='Test'+i;
            c.Status='New'+i;
            c.OLCN_FormFirstName__c='test'+i;
            c.OLCN_FormLastName__c='testlast'+i;
            c.OLCN_FormEmail__c='test'+i+'@test.com';
            c.OLCN_FormPhone__c='09090'+i;
            c.OLCN_FormRepFirstName__c='rep'+i;
            c.OLCN_FormRepLastName__c='replast'+i;
            c.OLCN_FormRepEmail__c='rep'+i+'@test.com';
            c.OLCN_FormRepPhone__c='90887'+i; 
            c.OLCN_InsurerStatus__c='New';
            caseLst.add(c);    
        }
        insert caseLst;
        for(Integer i=1; i<50; i++)
        {
            caseLst[i].OLCN_Insurer__c= lstAccount[i].id;
        }
        update caseLst;
    }
    public static testmethod void  creatCase()
    {
        Id IPM_ContactRecordType = MetaUtilityOLCN.getContactOLCNRecordType(); 
        Contact cnt=new Contact();
        cnt.RecordTypeID=IPM_ContactRecordType;
        cnt.LastName='testlast1';
        cnt.FirstName='test1';
        cnt.Email='test1@test.com';
        cnt.Phone='090901';
        
        insert cnt;
        Contact cntRep=new Contact();
        cntRep.RecordTypeID=IPM_ContactRecordType;
        cntRep.LastName='replast1';
        cntRep.FirstName='rep1';
        cntRep.Email='rep1@test.com';
        cntRep.Phone='908871';
        insert cntRep;
        
        Id caseRecordtype= MetaUtilityOLCN.getCaseOnlineClaimRecordType();
        List<Case> caseLst=new List<Case>();
        for(Integer i=0 ;i <10;i++){
            Case c=new Case ();
            c.RecordTypeId=CaseRecordtype;
            c.Subject='Test'+i;
            c.Status='New'+i;
            c.OLCN_FormFirstName__c='test'+i;
            c.OLCN_FormLastName__c='testlast'+i;
            c.OLCN_FormEmail__c='test'+i+'@test.com';
            c.OLCN_FormPhone__c='09090'+i;
            c.OLCN_FormRepFirstName__c='rep'+i;
            c.OLCN_FormRepLastName__c='replast'+i;
            c.OLCN_FormRepEmail__c='rep'+i+'@test.com';
            c.OLCN_FormRepPhone__c='90887'+i; 
            c.OLCN_InsurerStatus__c='New';
            caseLst.add(c);    
        }
        insert caseLst;
        
        Id IPM_BusinessRecordTypeId =  MetaUtilityOLCN.getAccountIndividualOLCNRecordType();
        Account acc = new Account();
        acc.Name ='name';
        acc.Recordtypeid=IPM_BusinessRecordTypeId;
        acc.OLCN_Email__C='name@t.com';
        acc.OLCN_InsurerCode__c='26 - AAMI';
        insert acc;
        caseLst[0].OLCN_Insurer__c=acc.id;
        caseLst[0].OLCN_InsurerStatus__c='New';
        caseLst[0].OLCN_InsurerCode__c='26 - AAMI';
        caseLst[0].OLCN_InsurerEmail__c='test@gmail.com';
        
        update caseLst[0];
        caseLst[0].OLCN_InsurerStatus__c='Updated';
        
        update caseLst[0];
        delete caseLst[0];
    }
   public static testMethod void createCaseList()
    {
         
         List<Case>   caseList = new List<Case>();
         List<Case>   duplicateCaseList = new List<Case>();              
         List<String> fname = new List<String>();
         List<String> lname = new List<String>();
         List<Date>   accidentdate = new List<Date>();
         List<String> regonumber = new List<String>();
         
         Id CaseRecordtype= MetaUtilityOLCN.getCaseOnlineClaimRecordType();   
                        
         //New Cases
         for(Integer i=0 ;i <10;i++)
         {
            Case cs = new Case();
            cs.OLCN_FormFirstName__c ='FName'+i;
            cs.RecordTypeId=CaseRecordType;
            cs.OLCN_FormLastName__c ='LName'+i;
            cs.OLCN_AccidentDate__c=date.Today();
            cs.OLCN_AtFaultRegistrationNumber__c='123abc' +i;
            cs.Status='New';
            cs.Origin='Web';
                                  
            caseList.add(cs);
         }
         insert caseList;
        //Duplicate Cases
        for(Integer i=0 ;i <10;i++)
         {
            Case cs = new Case();
            cs.OLCN_FormFirstName__c ='FName'+i;
            cs.RecordTypeId=CaseRecordType;
            cs.OLCN_FormLastName__c ='LName'+i;
            
            cs.OLCN_AccidentDate__c=date.Today();
            cs.OLCN_AtFaultRegistrationNumber__c='123abc' +i;
         // cs.OLCN_CloseReason__c = 'Duplicate';
         // cs.Status='New';
            cs.Origin='Web';
            duplicateCaseList.add(cs);
         }          
        insert duplicateCaseList;
 //       for(Integer i=0 ;i <10;i++)
 //        {
  //      system.assertEquals(duplicateCaseList[i].OLCN_CloseReason__c, null);
  //      system.assertEquals(duplicateCaseList[i].Status, 'New'); 
  //       }
	}
}