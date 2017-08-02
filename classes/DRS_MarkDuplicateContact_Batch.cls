public class DRS_MarkDuplicateContact_Batch implements Database.Batchable<SObject>, System.Schedulable {
    
    public List<AggregateResult> start(Database.BatchableContext objBatchableContext) {
        System.debug('---DRS_MarkDuplicateContact_Batch:start:objBatchableContext' + objBatchableContext);
        return [
            Select LastName, BirthDate
            From Contact
            Group By LastName, BirthDate
            Having Count(LastName) > 1
        ];
    }
    
    public void execute(Database.BatchableContext objBatchableContext, List<AggregateResult> listDuplicateContacts) {
        System.debug('---DRS_MarkDuplicateContact_Batch:execute:listDuplicateContacts.size()' + listDuplicateContacts.size());
        
        List<Contact> listContactsToUpdate = new List<Contact>();
        Map<String,List<Object>> mapFilters = new Map<String,List<Object>>();
        String lastName = 'LastName';
        String birthDate = 'BirthDate';
        mapFilters.put(lastName, new List<String>());
        mapFilters.put(birthDate, new List<Date>());
        
        for(AggregateResult objDuplicateContact : listDuplicateContacts) {
            mapFilters.get(lastName).add((String)objDuplicateContact.get(lastName));
            mapFilters.get(birthDate).add((Date)objDuplicateContact.get(birthDate));
        }
        
        for(Contact objContact : [
            Select Id, LastName, BirthDate, DuplicateFlag__c
            From Contact
            Where LastName =: (List<String>)mapFilters.get(lastName)
            And BirthDate =: (List<Date>)mapFilters.get(birthDate)
        ]) {
            for(AggregateResult objDuplicateContact : listDuplicateContacts) {
                if(objContact.DuplicateFlag__c == false && 
                   String.isNotBlank(objContact.LastName) && objContact.LastName == (String)objDuplicateContact.get(lastName) &&
                   objContact.BirthDate != null && objContact.BirthDate == (Date)objDuplicateContact.get(birthDate)) {
                       objContact.DuplicateFlag__c = true;
                       listContactsToUpdate.add(objContact);
                   }
            }
        }
        
        System.debug('---DRS_MarkDuplicateContact_Batch:execute:listContactsToUpdate.size()' + listContactsToUpdate.size());
        if(listContactsToUpdate.size() > 0) {
            Update listContactsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext objBatchableContext) {
        
    }
    
    public void execute(SchedulableContext objSchedulableContext) {
        Database.executeBatch(new DRS_MarkDuplicateContact_Batch(), 1000);
    }
    
}