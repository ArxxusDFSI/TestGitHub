public class DRS_MarkDuplicateCase_Batch implements Database.Batchable<SObject>, System.Schedulable {
    
    public List<AggregateResult> start(Database.BatchableContext objBatchableContext) {
        System.debug('---DRS_MarkDuplicateCase_Batch:start:objBatchableContext' + objBatchableContext);
        
        List<AggregateResult> listDuplicateCases = new List<AggregateResult>();
        listDuplicateCases.addAll([
            Select DRS_ContactLastname__c, ClaimNumber__c
            From Case
            Where RecordType.DeveloperName =: DRS_CaseService.RecordTypeMeritReviewService
            And Status !=: DRS_CaseService.CaseStatusDraft
            And ClaimNumber__c != ''
            Group By DRS_ContactLastname__c, ClaimNumber__c
            Having Count(DRS_ContactLastname__c) > 1
        ]);
        listDuplicateCases.addAll([
            Select DRS_ContactLastname__c, DateOfInjury__c
            From Case
            Where RecordType.DeveloperName =: DRS_CaseService.RecordTypeMeritReviewService
            And Status !=: DRS_CaseService.CaseStatusDraft
            And DateOfInjury__c != null
            Group By DRS_ContactLastname__c, DateOfInjury__c
            Having Count(DRS_ContactLastname__c) > 1
        ]);
        listDuplicateCases.addAll([
            Select DRS_ContactLastname__c, WCDNoticeDate__c
            From Case
            Where RecordType.DeveloperName =: DRS_CaseService.RecordTypeMeritReviewService
            And Status !=: DRS_CaseService.CaseStatusDraft
            And WCDNoticeDate__c != null
            Group By DRS_ContactLastname__c, WCDNoticeDate__c
            Having Count(DRS_ContactLastname__c) > 1
        ]);
        return listDuplicateCases;
    }
    
    public void execute(Database.BatchableContext objBatchableContext, List<AggregateResult> listDuplicateCases) {
        System.debug('---DRS_MarkDuplicateCase_Batch:execute:listDuplicateCases.size():' + listDuplicateCases.size());
        
        List<Object> listDuplicateCasesJSON;
        Map<String,Object> mapDuplicateCaseJSON;
        listDuplicateCasesJSON = (List<Object>)JSON.deserializeUntyped(JSON.serialize(listDuplicateCases));
        System.debug('---DRS_MarkDuplicateCase_Batch:execute:listDuplicateCasesJSON:' + listDuplicateCasesJSON);
        
        List<Case> listCasesToUpdate = new List<Case>();
        Map<String,List<Object>> mapFilters = new Map<String,List<Object>>();
        String lastName = 'DRS_ContactLastname__c';
        String claimNumber = 'ClaimNumber__c';
        String dateOfInjury = 'DateOfInjury__c';
        String wcdNoticeDate = 'WCDNoticeDate__c';
        mapFilters.put(lastName, new List<String>());
        mapFilters.put(claimNumber, new List<String>());
        mapFilters.put(dateOfInjury, new List<Date>());
        mapFilters.put(wcdNoticeDate, new List<Date>());
        
        for(Object objDuplicateCase : listDuplicateCasesJSON) {
            mapDuplicateCaseJSON = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objDuplicateCase));
            
            mapFilters.get(lastName).add((String)mapDuplicateCaseJSON.get(lastName));
            
            if(mapDuplicateCaseJSON.containsKey(claimNumber)) {
                mapFilters.get(claimNumber).add((String)mapDuplicateCaseJSON.get(claimNumber));
            }
            else if(mapDuplicateCaseJSON.containsKey(dateOfInjury)) {
                mapFilters.get(dateOfInjury).add(DRS_GlobalUtility.getDateFromSalesforceString((String)mapDuplicateCaseJSON.get(dateOfInjury)));
            }
            else if(mapDuplicateCaseJSON.containsKey(wcdNoticeDate)) {
                mapFilters.get(wcdNoticeDate).add(DRS_GlobalUtility.getDateFromSalesforceString((String)mapDuplicateCaseJSON.get(wcdNoticeDate)));
            }
        }
        
        System.debug('---DRS_MarkDuplicateCase_Batch:execute:mapFilters:' + mapFilters);
        
        for(Case objCase : [
            Select Id, DRS_ContactLastName__c, ClaimNumber__c, DateOfInjury__c, WCDNoticeDate__c, DuplicateFlag__c
            From Case
            Where DRS_ContactLastName__c =: (List<String>)mapFilters.get(lastName)
            And (
                ClaimNumber__c =: (List<String>)mapFilters.get(claimNumber)
                OR DateOfInjury__c =: (List<Date>)mapFilters.get(dateOfInjury)
                OR WCDNoticeDate__c =: (List<Date>)mapFilters.get(wcdNoticeDate))
        ]) {
            for(Object objDuplicateCase : listDuplicateCasesJSON) {
                mapDuplicateCaseJSON = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objDuplicateCase));
                System.debug('---DRS_MarkDuplicateCase_Batch:execute:mapDuplicateCaseJSON:' + mapDuplicateCaseJSON);
                
                if(objCase.DuplicateFlag__c == false && 
                   String.isNotBlank(objCase.DRS_ContactLastName__c) && objCase.DRS_ContactLastName__c == (String)mapDuplicateCaseJSON.get(lastName) &&
                   ((mapDuplicateCaseJSON.containsKey(claimNumber) &&
                     String.isNotBlank(objCase.ClaimNumber__c) && objCase.ClaimNumber__c == (String)mapDuplicateCaseJSON.get(claimNumber)) ||
                    (mapDuplicateCaseJSON.containsKey(dateOfInjury) &&
                     objCase.DateOfInjury__c != null && objCase.DateOfInjury__c == DRS_GlobalUtility.getDateFromSalesforceString((String)mapDuplicateCaseJSON.get(dateOfInjury))) ||
                    (mapDuplicateCaseJSON.containsKey(wcdNoticeDate) &&
                     objCase.WCDNoticeDate__c != null && objCase.WCDNoticeDate__c == DRS_GlobalUtility.getDateFromSalesforceString((String)mapDuplicateCaseJSON.get(dateOfInjury)))))
                {
                    objCase.DuplicateFlag__c = true;
                    listCasesToUpdate.add(objCase);
                }
            }
        }
        
        System.debug('---DRS_MarkDuplicateCase_Batch:execute:listCasesToUpdate.size()' + listCasesToUpdate.size());
        if(listCasesToUpdate.size() > 0) {
            Update listCasesToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext objBatchableContext) {
        
    }
    
    public void execute(SchedulableContext objSchedulableContext) {
        Database.executeBatch(new DRS_MarkDuplicateCase_Batch(), 1000);
    }
    
}