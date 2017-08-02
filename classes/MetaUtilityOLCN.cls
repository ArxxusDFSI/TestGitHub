/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This Class is the MetaUtilityOLCN which is used to handle the logic to return the meta data like RecordtypeID.
                        
Test Class:     TestDataUtilityOLCN
History
18/July/2017    Shyamala Sridevi Created
------------------------------------------------------------*/
public class MetaUtilityOLCN{
    
    static String onlineClaimRecordTypeId;
    static String businessOLCNRecordTypeId;
    static String individualOLCNRecordTypeId;
    static String contactOLCNRecordTypeId;
    public static String getCaseOnlineClaimRecordType()
    {
        if(MetaUtilityOLCN.empty(onlineClaimRecordTypeId))
        {
            onlineClaimRecordTypeId = [Select Id from RecordType where DeveloperName='Online_Claims_Notification' and sObjectType = 'Case' limit 1].Id;
        }
        return onlineClaimRecordTypeId;
    }
        
    public static String getAccountBusinessOLCNRecordType()
    {
        if(MetaUtilityOLCN.empty(businessOLCNRecordTypeId))
        {
            businessOLCNRecordTypeId = [Select Id from RecordType where DeveloperName='Business_OLCN' and sObjectType = 'Account' limit 1].Id;
        
        }
        return businessOLCNRecordTypeId;
    }
    
    public static String getAccountIndividualOLCNRecordType()
    {
        if(MetaUtilityOLCN.empty(individualOLCNRecordTypeId))
        {
        individualOLCNRecordTypeId = [Select Id from RecordType where DeveloperName='Individual_OLCN' and sObjectType = 'Account' limit 1].Id;
        }
        return individualOLCNRecordTypeId;
    }
    
    public static String getContactOLCNRecordType()
    {
        if(MetaUtilityOLCN.empty(contactOLCNRecordTypeId))
        {
        contactOLCNRecordTypeId = [Select Id from RecordType where DeveloperName='Contact_OLCN' and sObjectType = 'Contact' limit 1].Id;
        }
        return contactOLCNRecordTypeId;
    }
    
    public static Boolean empty(string o)
    {
        return o==null || o.trim()=='';
    }
    
    public static String getGeneralSettingValue(string recordName)
    {
        try{
            OLCN_GeneralSetting__c secttingRecord=OLCN_GeneralSetting__c.getInstance(recordName);
            if(secttingRecord!=null){
                return secttingRecord.OLCN_value__C;
            }else{ return '';}
        }catch(exception ex){
            return '';
        }
    }

}