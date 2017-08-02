/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the Case trigger Helper class 
                        
Test Class:     NA
History
05/June/2017    <Shyamala Sridevi>     Created
------------------------------------------------------------*/
public class CaseTriggerHelperOLCN {
	
    public static Boolean islookUpOnInsurerProcessing = true;      
    public static Final String CASE_ORIGIN ='Web';
    
    
    public static list<case> getOlcnCases(list<case> allCases)
    {
        list<case> olcnCases = new List<case>(); // to filter cases that are OLCN only
        for(case c:allCases)
        {
            if(c.RecordTypeId == MetaUtilityOLCN.getCaseOnlineClaimRecordType())
            olcnCases.add(c);
        }
        return olcnCases;
    }
    
    public static void lookupContactOnCase(list<case> newCaseList)
    {
        try
        {
            newCaseList = getOlcnCases(newCaseList);        
            ID ContactRecordtype=MetaUtilityOLCN.getContactOLCNRecordType();
            ID AccountRecordtype=MetaUtilityOLCN.getAccountIndividualOLCNRecordType();
            list<string> firstnamelst=new list<string>();
            list<string> Lastnamelst=new list<string>();
            list<string> emaillst=new list<string>();
            list<string> phonelist=new list<string>();
           
            for (case cas:newCaseList)
            {
               system.debug('---'+cas.recordtypeid);
                if(cas.OLCN_FormFirstName__c!=null && cas.OLCN_FormLastName__c !=null && (cas.OLCN_FormEmail__c!=null || cas.OLCN_FormPhone__c!=null)){
                    firstnamelst.add(cas.OLCN_FormFirstName__c);
                    Lastnamelst.add(cas.OLCN_FormLastName__c);
                    emaillst.add(cas.OLCN_FormEmail__c);
                    phonelist.add(cas.OLCN_FormPhone__c);
                }
                if(cas.OLCN_FormRepFirstName__c!=null && cas.OLCN_FormRepLastName__c!=null && (cas.OLCN_FormRepEmail__c!=null || cas.OLCN_FormRepPhone__c!=null))
                {
                    firstnamelst.add(cas.OLCN_FormRepFirstName__c);
                    Lastnamelst.add(cas.OLCN_FormRepLastName__c);
                    emaillst.add(cas.OLCN_FormRepEmail__c);
                    phonelist.add(cas.OLCN_FormRepPhone__c);
                }
                
            }
            map<string,contact> contactMAP=new map<string,contact>();
            map<string,contact> creatcontact=new map<string,contact>();
            map<string,account> creataccount=new map<string,account>();
            
           
           if(firstnamelst.size()>0 && Lastnamelst.size()>0 && (emaillst.size()>0 || phonelist.size()>0) )
           {
                for(contact cnt:[select id,firstname,lastname,email,phone from contact where recordtypeid =: ContactRecordtype  and firstname IN:firstnamelst and lastname IN:Lastnamelst and (email IN:emaillst OR  phone IN:phonelist)])
                {
                    string cntstring=cnt.firstname+cnt.lastname;
               
                    contactMAP.put(cntstring,cnt);
                }        
                for(case cas1:newCaseList)
                {
                	system.debug('<<<<<cas55.OLCN_RepType__c>>>'+cas1.OLCN_RepType__c);
                    string casstring=cas1.OLCN_FormFirstName__c+cas1.OLCN_FormLastName__c;
                    string casrepstring=cas1.OLCN_FormRepFirstName__c+cas1.OLCN_FormRepLastName__c;
                    if(!contactMAP.isEmpty() && contactMAP.get(casstring)!=null)
                    {
                        contact c=contactMAP.get(casstring);
                        if(c.email==cas1.OLCN_FormEmail__c || c.phone==cas1.OLCN_FormPhone__c)
                        cas1.Contactid=contactMAP.get(casstring).id;
                        
                    }
                    else{
                        if(cas1.OLCN_FormFirstName__c!=null && cas1.OLCN_FormLastName__c !=null && (cas1.OLCN_FormEmail__c!=null || cas1.OLCN_FormPhone__c!=null)){
                            account acc=new account(Name=cas1.OLCN_FormFirstName__c+' '+cas1.OLCN_FormLastName__c,phone=cas1.OLCN_FormPhone__c,RecordtypeID=AccountRecordtype);
                            creataccount.put(casstring,acc);
                            
                            system.debug('<<<<<cas1.OLCN_RepType__c>>>'+cas1.OLCN_RepType__c);
                            contact cont=new contact(firstname=cas1.OLCN_FormFirstName__c,lastname=cas1.OLCN_FormLastName__c,email=cas1.OLCN_FormEmail__c,phone=cas1.OLCN_FormPhone__c,type__c=cas1.OLCN_RepType__c,RecordTypeId=ContactRecordtype);
                            creatcontact.put(casstring,cont);
                        }
                    }
                    if(!contactMAP.isEmpty() && contactMAP.get(casrepstring)!=null)
                    {
                        contact c=contactMAP.get(casrepstring);
                        if(c.email==cas1.OLCN_FormRepEmail__c || c.phone==cas1.OLCN_FormRepPhone__c){
                        cas1.OLCN_RepContact__c=contactMAP.get(casrepstring).id;
                        }
                    }else{
                        if(cas1.OLCN_FormRepFirstName__c!=null && cas1.OLCN_FormRepLastName__c!=null && (cas1.OLCN_FormRepEmail__c!=null || cas1.OLCN_FormRepPhone__c!=null)){
                            account acc=new account(Name=cas1.OLCN_FormRepFirstName__c+' '+cas1.OLCN_FormRepLastName__c,phone=cas1.OLCN_FormRepPhone__c,RecordtypeID=AccountRecordtype);
                            creataccount.put(casrepstring,acc);
                            
                            system.debug('<<<<<cas1.OLCN_RepType__cXX>>>'+cas1.OLCN_RepType__c);
                            
                            contact cont=new contact(firstname=cas1.OLCN_FormRepFirstName__c,lastname=cas1.OLCN_FormRepLastName__c,email=cas1.OLCN_FormRepEmail__c,phone=cas1.OLCN_FormRepPhone__c,type__c=cas1.OLCN_RepType__c,RecordTypeId=ContactRecordtype);
                            creatcontact.put(casrepstring,cont);
                        }
                    }
                
                }
             if(!creataccount.isempty()){
             insert creataccount.values();
             }
             if(!creatcontact.isempty()){
             insert creatcontact.values();
             }
            for(case cas1:newCaseList)
            {
                string casINSstring=cas1.OLCN_FormFirstName__c+cas1.OLCN_FormLastName__c;
                string casrepstring1=cas1.OLCN_FormRepFirstName__c+cas1.OLCN_FormRepLastName__c;
                if(!creatcontact.isempty() && cas1.contactid == null && cas1.OLCN_FormFirstName__c!=null && cas1.OLCN_FormLastName__c!=null)
                {
                    cas1.Contactid=creatcontact.get(casINSstring).id;
                }
                if(!creatcontact.isempty() &&cas1.OLCN_RepContact__c== null && cas1.OLCN_FormRepFirstName__c!=null && cas1.OLCN_FormRepLastName__c!=null)
                {
                    cas1.OLCN_RepContact__c=creatcontact.get(casrepstring1).id;
                }
            }
            
            if(!creatcontact.isempty() && !creataccount.isEmpty())
            {
                list<contact> contactlinkToaccount=new list<contact>();
                system.debug('---'+creatcontact);
                for(string contactrec:creatcontact.keyset())
                {
                    system.debug(contactrec);
                    id cntid=creatcontact.get(contactrec).id;
                    id accountRecordId=creataccount.get(contactrec).id;
                    contact can=new contact (id=cntid,accountId=accountRecordId);
                    contactlinkToaccount.add(can);
                }
                if(contactlinkToaccount.size()>0)
                {
                     update contactlinkToaccount;
                }
             }   
          }           
      }catch(exception ex){
          system.debug('Exception thrown' + ex.getmessage());
      }
  }
        
  public static void lookUpOnInsurer(list<case> newCaseList)
  {   
         newCaseList = getOlcnCases(newCaseList);
         if(islookUpOnInsurerProcessing)
         {           
            ID accRecordType=MetaUtilityOLCN.getAccountBusinessOLCNRecordType();
        
            islookUpOnInsurerProcessing=false;
            list<string> insurerCodeList=new list<string>(); 
            map<string,account> mapForInsurerCodeName=new map<string,account>();
            for (case caseRecord:newCaseList)
            {
                if(caseRecord.OLCN_InsurerCode__c!=null && caseRecord.OLCN_InsurerCode__c !='')
                {
                    insurerCodeList.add(caseRecord.OLCN_InsurerCode__c);
                }
            }
            If(insurerCodeList.size()>0)
            {
                for(Account insurer:[select id,OLCN_InsurerCode__c from account where OLCN_InsurerCode__c IN :insurerCodeList and RecordTypeId=:accRecordType  ])
                {
                    mapForInsurerCodeName.put(insurer.OLCN_InsurerCode__c,insurer);
                }
            }
            for (case caseRecord:newCaseList)
            {
                if(!mapForInsurerCodeName.isempty() && caseRecord.OLCN_InsurerCode__c !=null && caseRecord.OLCN_InsurerCode__c!='' && mapForInsurerCodeName.get(caseRecord.OLCN_InsurerCode__c)!=null)
                {
                    caseRecord.OLCN_Insurer__c=mapForInsurerCodeName.get(caseRecord.OLCN_InsurerCode__c).id;
                }else{
                    caseRecord.OLCN_Insurer__c=Null;
                }
            }
         }
   }    


	//This method check for duplicate cases.
	public static void checkDuplicateCases(list<case> newCaseList){
		try{
	         newCaseList = getOlcnCases(newCaseList);
	         Id OLCNCaseRecordtype=MetaUtilityOLCN.getCaseOnlineClaimRecordType();
	         
	         list<String> firstNameList = new list<String>(); 									//List to handle injured person's first name
	         list<String> lastNameList = new list<String>(); 									//List to handle injured person's last name
	         list<Date> accidentDateList = new list<Date>(); 									//List to handle injured person's accident date
	         list<String> regoNumberList = new list<String>(); 									//List to handle injured person's register number
	         map<String,list<case>> duplicateIdentityKeyToCaseRecordsMap = new map<String,list<case>>();		//Map to hold duplicate identification key To Case record mapping.
	         
	         if (!newCaseList.isEmpty()){
	         	
	         	for(case newCaseRecord :newCaseList){
	         		
					if(newCaseRecord.Origin==CASE_ORIGIN && newCaseRecord.OLCN_FormFirstName__c!=null && newCaseRecord.OLCN_FormLastName__c!=null && newCaseRecord.OLCN_AccidentDate__c!=null && newCaseRecord.OLCN_AtFaultRegistrationNumber__c!=null) {
	                        String duplicateIdentityKeyNew ='';					//Key for duplicate identification for new case records.
	                        firstNameList.add(newCaseRecord.OLCN_FormFirstName__c);
	                        lastNameList.add(newCaseRecord.OLCN_FormLastName__c);
	                        accidentDateList.add(newCaseRecord.OLCN_AccidentDate__c);
	                        regoNumberList.add(newCaseRecord.OLCN_AtFaultRegistrationNumber__c);
	                        
	                        duplicateIdentityKeyNew = newCaseRecord.OLCN_FormFirstName__c + newCaseRecord.OLCN_FormLastName__c + newCaseRecord.OLCN_AccidentDate__c + newCaseRecord.OLCN_AtFaultRegistrationNumber__c;
	                        
	                        if(duplicateIdentityKeyToCaseRecordsMap.containsKey(duplicateIdentityKeyNew)){ 
	                        	duplicateIdentityKeyToCaseRecordsMap.get(duplicateIdentityKeyNew).add(newCaseRecord);
	                        }else{
	                        	duplicateIdentityKeyToCaseRecordsMap.put(duplicateIdentityKeyNew,new list<case> {newCaseRecord});
	                        }
	                        
					}
	         	}
	         	
	         	for(case oldCaseRecord:[Select id,OLCN_FormFirstName__c,OLCN_FormLastName__c,OLCN_AccidentDate__c,OLCN_AtFaultRegistrationNumber__c From case Where recordtypeid =: OLCNCaseRecordtype 
	                    						And Origin =:CASE_ORIGIN And OLCN_FormFirstName__c IN:firstNameList And OLCN_FormLastName__c IN:lastNameList 
	                    						And OLCN_AccidentDate__c IN:accidentDateList And OLCN_AtFaultRegistrationNumber__c IN:regoNumberList]){
					
					String duplicateIdentityKeyOld ='';		//Key for duplicate identification for old case records.
					duplicateIdentityKeyOld = oldCaseRecord.OLCN_FormFirstName__c + oldCaseRecord.OLCN_FormLastName__c + oldCaseRecord.OLCN_AccidentDate__c + oldCaseRecord.OLCN_AtFaultRegistrationNumber__c; 
					
					if(duplicateIdentityKeyToCaseRecordsMap.ContainsKey(duplicateIdentityKeyOld)){
						for(case newCaseRecord : duplicateIdentityKeyToCaseRecordsMap.get(duplicateIdentityKeyOld)){
							newCaseRecord.Status='New'; 
		                	newCaseRecord.OLCN_CloseReason__c='Duplicate';
						}
                    }
				}
          }
		}catch(exception ex){
            system.debug('Exception thrown' + ex.getmessage()); 
		}
	}

}