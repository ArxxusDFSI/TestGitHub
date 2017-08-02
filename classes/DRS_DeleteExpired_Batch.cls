public class DRS_DeleteExpired_Batch implements Database.Batchable<SObject>, System.Schedulable, Database.AllowsCallouts {
    private Integer numberOfDays {get;set;}
    
    public DRS_DeleteExpired_Batch() {
        this.numberOfDays = 1;
    }
    
    public DRS_DeleteExpired_Batch(Integer numberOfDays) {
        this.numberOfDays = numberOfDays;
    }
    
    public List<Case> start(Database.BatchableContext objBatchableContext) {
        String caseSOQL = '' +
            ' Select Id, Status, ' +
            ' (Select Id From CaseItems__r), ' +
            ' (Select Id From Attachments__r) ' +
            ' From Case ' +
            ' Where (Status = \'' + DRS_CaseService.CaseStatusClosed + '\' And CaseReasons__c = \'' + DRS_CaseService.CaseReasonExpired + '\') ' +
            ' And ClosedDate >= Last_N_Days:' + this.numberOfDays + ' ';
        return Database.query(caseSOQL);
    }
    
    public void execute(Database.BatchableContext objBatchableContext, List<Case> listCases) {
        try {
            List<SObject> listObjectsToDelete = new List<SObject>();
            List<SObject> listObjectsToUpdate = new List<SObject>();
            List<ApplicationLog__c> listApplicationLogsToInsert = new List<ApplicationLog__c>();
            String signedURL;
            for(Case objCase : listCases) {
                signedURL = DRS_S3Service.getSignedDeleteUrl(objCase.Id);
                HttpResponse objHttpResponse = DRS_GlobalUtility.callRESTAPI(DRS_GlobalUtility.RESTDeleteMethod, signedURL, null, null);
                
                if(objHttpResponse.getStatusCode() == 204) {
                    for(CaseItem__c objCaseItem : objCase.CaseItems__r) {
                        listObjectsToDelete.add(objCaseItem);
                    }
                    for(Attachment__c objAttachment : objCase.Attachments__r) {
                        listObjectsToDelete.add(objAttachment);
                    }
                    if(objCase.Status != DRS_CaseService.CaseStatusClosed) {
                        objCase.Status = DRS_CaseService.CaseStatusClosed;
                        objCase.CaseReasons__c = DRS_CaseService.CaseReasonDeletedDraft;
                        listObjectsToUpdate.add(objCase);
                    }
                }
                else {
                    listApplicationLogsToInsert.add(DRS_GlobalUtility.getAppliationLogError(
                        objHttpResponse.getBody(), DRS_GlobalUtility.RESTDeleteMethod + ' ' + signedURL, String.valueOf(objHttpResponse.getStatusCode()), objCase.Id, 'Delete attachments related to case', 'DRS_DeleteExpired_Batch', 'execute', ''));
                }
            }
            
            System.debug('---DRS_DeleteExpired_Batch:execute:listObjectsToDelete:' + listObjectsToDelete);
            System.debug('---DRS_DeleteExpired_Batch:execute:listApplicationLogsToInsert:' + listApplicationLogsToInsert);
            
            if(listObjectsToDelete.size() > 0) {
                listObjectsToDelete.sort();
                Delete listObjectsToDelete;
            }
            if(listObjectsToUpdate.size() > 0) {
                listObjectsToUpdate.sort();
                Update listObjectsToUpdate;
            }
            if(listApplicationLogsToInsert.size() > 0) {
                listApplicationLogsToInsert.sort();
                Insert listApplicationLogsToInsert;
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_DeleteExpired_Batch', 'execute');
        }
    }
    
    public void finish(Database.BatchableContext objBatchableContext) {
        
    }
    
    public void execute(SchedulableContext objSchedulableContext) {
        Database.executeBatch(new DRS_DeleteExpired_Batch(), 30);
    }
    
}