///A utility class to have helper functions
///The class will also be used for functionatlity where overriding sharing rules is required
public without sharing class DRS_GlobalUtility {
    ///Variable declarations
    public static final String DateFormat = 'dd/MM/yyyy';
    public static final String DateTimeFormat = 'dd/MM/yyyy hh:mm:ss';
    public static final String LocationMRSUpload = 'mrs.upload';
    public static final String LocationMRSCaseStatus = 'mrs.casedetail.status';
    public static final String LocationMRSCaseDetails = 'mrs.casedetail.casedetails';
    public static final String RESTGetMethod = 'GET';
    public static final String RESTPutMethod = 'PUT';
    public static final String RESTDeleteMethod = 'DELETE';
    public static final String RESTPostMethod = 'POST';
    
    private static Configuration__c objMRSConfiguration;
    private static Map<String,Id> mapRecordTypes;
    private static Map<String,PermissionSet> mapPermissionSets;
    
    ///Calculates the next working day. Takes into consideration holidays and weekends, based on the Holidays object
    public static DateTime getDateDifferenceWithHolidays(DateTime startingDateTime, Long numberOfDays){
        if(startingDateTime != null) {
            ///Get the BusinessHours for Monday 
            BusinessHours objBusinessHours;
            try {
                objBusinessHours = [Select Id, MondayStartTime, MondayEndTime From BusinessHours Where IsDefault = true];
            }
            catch(Exception excep) {
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.BusinessHoursNotDefined));
            }
            
            ///Calculate the number of milliseconds in a day by subtracting start time from end time
            Long milliSecondsInADay = DateTime.newInstance(Date.today(), objBusinessHours.MondayEndTime).getTime() - DateTime.newInstance(Date.today(), objBusinessHours.MondayStartTime).getTime();
            System.debug('---DRS_GlobalUtility:getDateDifferenceWithHolidays:milliSecondsInADay:' + milliSecondsInADay);
            System.debug('---DRS_GlobalUtility:getDateDifferenceWithHolidays:numberOfDays:' + numberOfDays);
            
            ///Calculate the milliseconds after which the next working day should be
            ///The millisecond difference is a requirement of BusinessHour class
            Long numberOfDaysMilliseconds = milliSecondsInADay * numberOfDays;
            System.debug('---DRS_GlobalUtility:getDateDifferenceWithHolidays:numberOfDaysMilliseconds:' + numberOfDaysMilliseconds);
            
            ///Use BusinessHour calculation to get the next business day
            DateTime differenceDateTime = BusinessHours.add(objBusinessHours.Id, startingDateTime, numberOfDaysMilliseconds);
            System.debug('---DRS_GlobalUtility:getDateDifferenceWithHolidays:differenceDateTime:' + differenceDateTime);
            return differenceDateTime;
        }
        return startingDateTime;
    }
    
    ///Calculates the number of days after the startingDateTime.
    ///	If the ending date falls on a weekend or a holiday, returns the next possible working day
    public static DateTime getDateDifferenceWithNextWorkingDay(DateTime startingDateTime, Integer numberOfDays){
    	///Get the BusinessHours for Monday 
        BusinessHours objBusinessHours;
        try {
            objBusinessHours = [Select Id, MondayStartTime, MondayEndTime From BusinessHours Where IsDefault = true];
        }
        catch(Exception excep) {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.BusinessHoursNotDefined));
        }
        
        ///Add the number of days to starting date time to get tentative end date
        DateTime endingDateTime = startingDateTime.addDays(numberOfDays);
        System.debug('---DRS_GlobalUtility:getDateDifferenceWithNextWorkingDay:endingDateTime before holidays:' + endingDateTime);
        
        ///Use BusinessHours class to get actual working day on or after the tentative end date
        endingDateTime = BusinessHours.nextStartDate(objBusinessHours.Id, endingDateTime);
        System.debug('---DRS_GlobalUtility:getDateDifferenceWithNextWorkingDay:endingDateTime after holidays:' + endingDateTime);
        
        return DRS_GlobalUtility.convertToUserTimeZone(endingDateTime);
    }
    
    ///Converts the input DateTime to the logged in User's TimeZone
    public static DateTime convertToUserTimeZone(DateTime inputDateTime) {
    	System.debug('---DRS_GlobalUtility:convertToUserTimeZone:inputDateTime:' + inputDateTime);
    	DateTime outputDateTime;
    	if(inputDateTime != null) {
    		String convertedDateTime = inputDateTime.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().getId());
    		System.debug('---DRS_GlobalUtility:convertToUserTimeZone:convertedDateTime:' + convertedDateTime);
    		outputDateTime = DateTime.valueOfGMT(convertedDateTime);
    		System.debug('---DRS_GlobalUtility:convertToUserTimeZone:outputDateTime:' + outputDateTime);
    	}
    	return outputDateTime;
    }
    
    ///Gets the Snippets for Location__c
    ///Filters the Snippets for listPermissionSetNames. If the list is empty, returns all records for the Location__c
    public static List<Snippet__c> getSnippetsForLocation(String location, List<String> listPermissionSetNames) {
        ///Get all Snippets for Location__c which are Active
        List<Snippet__c> listSnippetsFiltered = new List<Snippet__c>();
        List<Snippet__c> listSnippets = new List<Snippet__c>([
            Select Id, IsActive__c, Location__c, SnippetName__c, PermissionSetNames__c,
            UniqueName__c, UniqueNameValidation__c, Value__c
            From Snippet__c
            Where Location__c =: location
            And IsActive__c = true
            Order By SnippetName__c Asc
        ]);
        
        ///If listPermissionSetNames is empty return the fetched results
        if(listPermissionSetNames == null || listPermissionSetNames.size() == 0) {
            return listSnippets;
        }
        
        ///Otherwise, filter the results for the provided Permission Sets
        ///PermissionSetNames__c is a comma separted list of values stored in a long text area
        ///The listPermissionSetNames cannot be directly used in the SOQL
        for(Snippet__c objSnippet : listSnippets) {
            if(String.isNotBlank(objSnippet.PermissionSetNames__c)) {
                for(String permissionSetName : listPermissionSetNames) {
                    if(objSnippet.PermissionSetNames__c.contains(permissionSetName)) {
                        listSnippetsFiltered.add(objSnippet);
                        break;
                    }
                }
            }
        }
        return listSnippetsFiltered;
    }
    
    ///Gets boolean value from String
    ///Converts 'yes' or 'true' to TRUE
    public static Boolean getBooleanFromString(String booleanString) {
        if(String.isNotBlank(booleanString)) {
            if(booleanString.toLowerCase() == 'yes' || booleanString.toLowerCase() == 'true') {
                return true;
            }
        }
        return false;
    }
    
    ///Gets the DomainSite for siteId
    public static DomainSite getDomainSiteForId(String siteId) {
        return [
            Select Id, SiteId, PathPrefix, DomainId, Domain.Domain 
            From DomainSite 
            Where SiteId =: siteId
        ];
    }
    
    ///Gets String or Empty String for the value provided
    public static String getStringValue(String stringValue) {
    	if(String.isNotBlank(stringValue)) {
    		return stringValue;
    	}
    	return '';
    }
    
    ///Converts the Date to a String date
    ///Format is dd/MM/yyyy
    public static String convertDateToString(Date dateValue){
        if(dateValue != null) {
            String day = String.valueOf(dateValue.day());
            String month = String.valueOf(dateValue.month());
            String year = String.valueOf(dateValue.year());
            return day.leftPad(2, '0') + '/' + month.leftPad(2, '0') + '/' + year.leftPad(4, '0');
        }
        return '';
    }
    
    ///Converts a String into a Date
    public static Date getDateFromString(String dateString) {
        if(String.isNotBlank(dateString)) {
            String[] dateParts = dateString.split('/');
            return Date.newInstance(integer.valueOf(dateParts[2]), integer.valueOf(dateParts[1]), integer.valueOf(dateParts[0]));
        }
        return null;
    }
    
    ///Converts a Salesforce Date String into a Date
    public static Date getDateFromSalesforceString(String dateString) {
        if(String.isNotBlank(dateString)) {
            String[] dateParts = dateString.split('-');
            return Date.newInstance(integer.valueOf(dateParts[0]), integer.valueOf(dateParts[1]), integer.valueOf(dateParts[2]));
        }
        return null;
    }
    
    ///Gets the Configuration__c Custom MetaDataType values for 'MRS_Configuration' record
    public static Configuration__c getMRSConfiguration() {
        if(DRS_GlobalUtility.objMRSConfiguration == null) {
            DRS_GlobalUtility.objMRSConfiguration = [
                Select Id, CommunityAccountOwner__c, ProfileId1__c, CaseOwner__c,
                DefaultTaskOwner__c, ProfileId2__c, SiteId1__c, SiteId2__c, 
                NumberOfDaysToExpire__c, Username__c, Password__c, S3BucketName__c,
                S3EncryptionScheme__c, S3HeaderEncryptionScheme__c, S3Host__c,
                S3Region__c, S3ServerSideEncryptionAlgorithm__c, S3Timeout__c,
                EC2ServerPath__c, FromEmailAddress__c
                From Configuration__c 
                Where Name = 'Merit Review Services'
            ];
        }
        return DRS_GlobalUtility.objMRSConfiguration;
    }
    
    ///Gets the values of Case Team Role Association custom setting
    public static List<CaseTeamRoleAssociation__c> getCaseTeamRoleAssociationForAccountType(String accountType) {
        return [
            Select Name, ContactRole__c, CaseTeamRole__c, AccountType__c
            From CaseTeamRoleAssociation__c
            Where AccountType__c =: accountType
        ];
    }
    
    ///Gets the CaseTeamRoleAssociation__c for contactRoles and accountType
    public static List<CaseTeamRoleAssociation__c> getCaseTeamRoleAssociationForContact(List<String> contactRoles, String accountType) {
        return [
            Select Name, ContactRole__c, CaseTeamRole__c, AccountType__c
            From CaseTeamRoleAssociation__c
            Where ContactRole__c =: contactRoles
            And AccountType__c =: accountType
        ];
    }
    
    ///Returns a Map of RecordType
    /// The key is in format 'SobjectType_DeveloperName' e.g. 'CaseItem__c_Insurer'
    /// The value is Id of the RecordType
    public static Map<String,Id> getRecordTypes() {
        if(DRS_GlobalUtility.mapRecordTypes == null) {
            DRS_GlobalUtility.mapRecordTypes = new Map<String,Id>();
            
            for(RecordType objRecordType : [
                Select Id, DeveloperName, SobjectType
                From RecordType
            ]) {
                DRS_GlobalUtility.mapRecordTypes.put(objRecordType.SobjectType + '_' + objRecordType.DeveloperName, objRecordType.Id);
            }
        }
        return DRS_GlobalUtility.mapRecordTypes;
    }
    
    ///Returns a Map of PermissionSet
    //  The key is the DeveloperName of the Permission Set
    //  The value is the PermissionSet object
    public static Map<String,PermissionSet> getPermissionSets() {
        if(DRS_GlobalUtility.mapPermissionSets == null) {
            DRS_GlobalUtility.mapPermissionSets = new Map<String, PermissionSet>();
            for(PermissionSet objPermissionSet : [
                Select Id, Name
                From PermissionSet
                Limit 1000
            ]) {
                DRS_GlobalUtility.mapPermissionSets.put(objPermissionSet.Name, objPermissionSet);
            }
        }
        return DRS_GlobalUtility.mapPermissionSets;
    }
    
    ///Generates and returns a GUID
    public static String getGuid() {
        Blob cryptoKey = Crypto.GenerateAESKey(128);
        String encodedHex = EncodingUtil.ConvertTohex(cryptoKey);
        String guid = encodedHex.SubString(0,8)+ '-' + encodedHex.SubString(8,12) + '-' + encodedHex.SubString(12,16) + '-' + encodedHex.SubString(16,20) + '-' + encodedHex.substring(20);
        return guid;
    }
    
    ///Gets Attachment object for the provided parentId
    public static List<Attachment> getAttachmentsForParent(String parentId) {
        return [
            Select Name, Body, BodyLength 
            From Attachment 
            Where ParentId =: parentId];
    }
    
    ///Gets the details of EmailTemplate based on the developer name for the email template
    public static EmailTemplate getEmailTemplateForDeveloperName(String developerName) {
        return [
            Select Id, HTMLValue, Subject
            From EmailTemplate Template 
            Where DeveloperName =: developerName];
    }
    
    ///Sends an email using SingleEmailMessage class
    public static void sendEmailUsingTemplate(string templateName, Map<String,String> mapMergeFieldValues, List<String> toAddresses, Map<String,Map<String,String>> mapContactFields) {
        if(toAddresses == null || toAddresses.size() == 0) return;
        
        ///Initialize the EmailTemplate class using the templateName provided
        ///Send it to an invalid email address
        /// This is required to get the letterhead with formatting
        /// The rollback will stop the email from getting sent out
        EmailTemplate objEmailTemplate = DRS_GlobalUtility.getEmailTemplateForDeveloperName(templateName);
        List<String> invalidToAddresses = new List<String>();
        invalidToAddresses.add('invalid@invali.d.com.invalid.au');
        
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.setTemplateId(objEmailTemplate.Id);
        emailMessage.setTargetObjectId(UserInfo.getUserId());
        emailMessage.setToAddresses(invalidToAddresses);
        emailMessage.setSaveAsActivity(false);
        
        Savepoint sp = DRS_GlobalUtility.createSavePoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMessage});
        DRS_GlobalUtility.rollbackSavePoint(sp);
        
        ///Update the HTML body of the EmailTemplate with the merge field values provided in the map
        System.debug('---DRS_GlobalUtility:sendEmailUsingTemplate:getHTMLBody:' + emailMessage.getHTMLBody());
        String htmlValue = emailMessage.getHTMLBody();
        String subject = emailMessage.getSubject();
        
        if(mapMergeFieldValues != null) {
            for(String mergeField : mapMergeFieldValues.keySet()) {
                htmlValue = htmlValue.replace(mergeField, mapMergeFieldValues.get(mergeField));
                subject = subject.replace(mergeField, mapMergeFieldValues.get(mergeField));
            }
        }
        
        ///If there is an attachment for the EmailTemplate, get the attachment and attach to the SingleEmailMessage
        List<Messaging.EmailFileAttachment> listEmailFileAttachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment objEmailFileAttachment;
        for (Attachment objAttachment : DRS_GlobalUtility.getAttachmentsForParent(objEmailTemplate.Id)) {
            objEmailFileAttachment = new Messaging.Emailfileattachment();
            objEmailFileAttachment.setFileName(objAttachment.Name);
            objEmailFileAttachment.setBody(objAttachment.Body);
            listEmailFileAttachments.add(objEmailFileAttachment);
        }
        
        DRS_GlobalUtility.sendEmail(subject, htmlValue, toAddresses, listEmailFileAttachments, mapContactFields);
    }
    
    ///Sends an email using SingleEmailMessage class
    public static void sendEmail(String subject, String htmlBody, List<String> toAddresses, List<Messaging.EmailFileAttachment> listEmailFileAttachments, Map<String,Map<String,String>> mapContactFields) {
        System.debug('---DRS_GlobalUtility:sendEmail:subject: ' + subject + ' : htmlBody: ' + htmlBody + ' : toAddresses : ' + toAddresses);
        
        if(toAddresses != null && toAddresses.size() > 0) {
        	List<Messaging.SingleEmailMessage> listSingleEmailMessages = new List<Messaging.SingleEmailMessage>();
        	String subjectUpdated = '';
        	String htmlBodyUpdated = '';
        	Integer counter = 0;
        	
	        Messaging.SingleEmailMessage emailMessage;
	        emailMessage = new Messaging.SingleEmailMessage();
	        if(!htmlBody.contains('<html>')) {
	            htmlBody = '<html>' + htmlBody + '</html>';
	        }
	        emailMessage.setOrgWideEmailAddressId(DRS_GlobalUtility.getMRSConfiguration().FromEmailAddress__c);
	        emailMessage.setSaveAsActivity(false);
	        if(listEmailFileAttachments != null && listEmailFileAttachments.size() > 0) {
	            emailMessage.setFileAttachments(listEmailFileAttachments);
	        }
	        if(mapContactFields != null && mapContactFields.size() > 0) {
		        for(String toAddress : toAddresses) {
		        	emailMessage = new Messaging.SingleEmailMessage();
			        emailMessage.setOrgWideEmailAddressId(DRS_GlobalUtility.getMRSConfiguration().FromEmailAddress__c);
			        emailMessage.setSaveAsActivity(false);
			        if(listEmailFileAttachments != null && listEmailFileAttachments.size() > 0) {
			            emailMessage.setFileAttachments(listEmailFileAttachments);
			        }
			        
		        	subjectUpdated = subject;
		        	htmlBodyUpdated = htmlBody;
		        	
		        	for(String mergeFieldKey : mapContactFields.get(toAddress).keySet()) {
		        		subjectUpdated = subjectUpdated.replace(mergeFieldKey, mapContactFields.get(toAddress).get(mergeFieldKey));
		        		htmlBodyUpdated = htmlBodyUpdated.replace(mergeFieldKey, mapContactFields.get(toAddress).get(mergeFieldKey));
		        	}
		        	emailMessage.setHtmlBody(htmlBodyUpdated);
		            emailMessage.setSubject(subjectUpdated);
		            emailMessage.setToAddresses(new String[]{toAddress});
	            	listSingleEmailMessages.add(emailMessage);
	            	
		            counter++;
		        }
	        }
	        else {
		        emailMessage.setHtmlBody(htmlBody);
	            emailMessage.setToAddresses(toAddresses);
	            emailMessage.setSubject(subject);
	            listSingleEmailMessages.add(emailMessage);
	        }
	        if(!Test.isRunningTest()) {
                Messaging.sendEmail(listSingleEmailMessages);
            }
    	}
    }
    
    ///Handles the Exception to raise specific errors. Mainly used in Service classes
    ///Throws GeneralError message if an unhandled exception is raised
    public static String handleServiceException(System.Exception excep, String className, String methodName) {
        if(excep instanceof DRS_GlobalException.ServiceException) {
            System.debug('---' + className + ':' + methodName + ':' + excep);
            throw new DRS_GlobalException.ServiceException(excep.getMessage());
        }
        else {
            System.debug('---' + className + ':' + methodName + ':' + excep);
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.GeneralError));
            //throw excep;
        }
    }
    
    ///Handles the Exception to raise specific errors. Mainly used in Controller classes
    ///Throws GeneralError message if an unhandled exception is raised
    public static String handleAuraException(System.Exception excep, String className, String methodName){
        if(excep instanceof DRS_GlobalException.ServiceException ||
           excep instanceof AuraHandledException) {
               System.debug('---' + className + ':' + methodName + ':' + excep);
               throw new AuraHandledException(excep.getMessage());
           }
        else {
            System.debug('---' + className + ':' + methodName + ':' + excep);
            throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.GeneralError));
            //throw new AuraHandledException(excep.getMessage());
        }
    }
    
    ///Handles the Exception to raise specific errors. Mainly used in Web Services
    ///Throws GeneralError message if an unhandled exception is raised
    public static String handleRestServiceException(System.Exception excep, String className, RestRequest objRestRequest, RestResponse objRestResponse){
        System.debug('---className:' + className);
        System.debug('---RestContext.request:' + objRestRequest);
        System.debug('---RestContext.response:' + objRestResponse);
        if(excep instanceof DRS_GlobalException.RestServiceException ||
           excep instanceof DRS_GlobalException.ServiceException) {
               throw new DRS_GlobalException.RestServiceException(excep.getMessage());
           }
        else {
            throw new DRS_GlobalException.RestServiceException(DRS_MessageService.getMessage(DRS_MessageService.GeneralError));
        }
    }
    
    public static Case updateCase(Case objCase) {
        Update objCase;
        return objCase;
    }
    
    public static list<CaseTeamMember> insertCaseTeamMembers(List<DRS_GlobalWrapper.CaseTeamMemberJSON> listCaseTeamMemberJSONs) {
        List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
        CaseTeamMember objCaseTeamMember;
        for(DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMemberJSON : listCaseTeamMemberJSONs) {
            objCaseTeamMember = new CaseTeamMember();
            objCaseTeamMember.ParentId = objCaseTeamMemberJSON.caseId;
            objCaseTeamMember.MemberId = objCaseTeamMemberJSON.memberId;
            objCaseTeamMember.TeamRoleId = objCaseTeamMemberJSON.roleId;
            listCaseTeamMembers.add(objCaseTeamMember);
        }
        Insert listCaseTeamMembers;
        return listCaseTeamMembers;
    }
    
    ///Create Case Team Members using the JSON from the form
    public static void saveCaseTeamMembers(String caseId, String caseTeamMemberJSONs) {
        ///Variable declarations
        List<CaseTeamMember> listCaseTeamMembersToDelete = new List<CaseTeamMember>();
        List<CaseTeamMember> listCaseTeamMembersToAdd = new List<CaseTeamMember>();
        List<CaseTeamMember> listCaseTeamMembersToUpdate = new List<CaseTeamMember>();
        Contact objContact = DRS_ContactService.getContactForUser(UserInfo.getUserId());
        List<User> listUsers = DRS_ContactService.getUsersForAccount(objContact.AccountId);
        List<Id> listUserIds = new List<Id>();
        CaseTeamMember objCaseTeamMemberToInsert;
        Map<String,Map<String,String>> mapContactMergeFields = new Map<String,Map<String,String>>();
        Boolean doNothing = false;
        
        ///Initialize the variables
        List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
        List<DRS_GlobalWrapper.CaseTeamMemberJSON> listCaseTeamMemberJSON = (List<DRS_GlobalWrapper.CaseTeamMemberJSON>)JSON.deserialize(caseTeamMemberJSONs, List<DRS_GlobalWrapper.CaseTeamMemberJSON>.class);
        
        ///Create a list of all Case Team members who are part of the Account of the current User 
        for(CaseTeamMember objCaseTeamMember : DRS_CaseService.getCaseTeamMembers(caseId)) {
            for(User objUser : listUsers) {
                if(objUser.Id == objCaseTeamMember.MemberId) {
                    listCaseTeamMembers.add(objCaseTeamMember);
                }
            }
        }
        
        ///Iterate over the Case Team Member JSON
        ///If the Member exits in existing Case Team Members, check the Role
        /// If the Role has not changed do nothing
        /// Otherwise add the member in update list
        ///Otherwise add the member to insert list
        for(DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMemberJSON : listCaseTeamMemberJSON) {
            doNothing = false;
            for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
                if(objCaseTeamMemberJSON.memberId == objCaseTeamMember.MemberId) {
                    if(objCaseTeamMemberJSON.roleId != objCaseTeamMember.TeamRoleId) {
                        objCaseTeamMember.TeamRoleId = objCaseTeamMemberJSON.roleId;
                        listCaseTeamMembersToUpdate.add(objCaseTeamMember);
                    }
                    doNothing = true;
                    break;
                }
            }
            if(doNothing) {
                continue;
            }
            else {
                System.debug('---DRS_CaseService:saveCaseTeamMembers:objCaseTeamMember:' + caseId + ' ' + objCaseTeamMemberJSON.memberId + ' ' + objCaseTeamMemberJSON.roleId);
                objCaseTeamMemberToInsert = new CaseTeamMember();
                objCaseTeamMemberToInsert.ParentId = caseId;
                objCaseTeamMemberToInsert.MemberId = objCaseTeamMemberJSON.memberId;
                objCaseTeamMemberToInsert.TeamRoleId = objCaseTeamMemberJSON.roleId;
                listCaseTeamMembersToAdd.add(objCaseTeamMemberToInsert);
                listUserIds.add(objCaseTeamMemberJSON.memberId);
            }
        }
        
        ///Iterate over the existing Case Team Members
        ///If an existing member is not found in Case Team Member JSON
        /// Add the member to delete list
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            doNothing = false;
            for(DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMemberJSON : listCaseTeamMemberJSON) {
                if(objCaseTeamMemberJSON.memberId == objCaseTeamMember.MemberId) {
                    doNothing = true;
                    break;
                }
            }
            if(doNothing) {
                continue;
            }
            else {
                listCaseTeamMembersToDelete.add(objCaseTeamMember);
            }
        }
        
        System.debug('---DRS_CaseService:saveCaseTeamMembers:listCaseTeamMembersToDelete:' + listCaseTeamMembersToDelete);
        System.debug('---DRS_CaseService:saveCaseTeamMembers:listCaseTeamMembersToAdd:' + listCaseTeamMembersToAdd);
        
        ///Perform Insert, Update and Delete DMLs
        if(listCaseTeamMembersToDelete.size() > 0) {
            Delete listCaseTeamMembersToDelete;
        }
        if(listCaseTeamMembersToAdd.size() > 0) {
            Insert listCaseTeamMembersToAdd;
        }
        if(listCaseTeamMembersToUpdate.size() > 0) {
            Update listCaseTeamMembersToUpdate;
        }
        
        ///Send an email to newly added case team members
        Map<Id,User> mapUsers = new Map<Id,User>();
        for(User objUser : DRS_ContactService.getUserContactsForUsers(listUserIds)) {
            mapUsers.put(objUser.Id, objUser);
        }
        
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        DomainSite objInsurerDomainSite = DRS_GlobalUtility.getDomainSiteForId(objMRSConfiguration.SiteId2__c);
        Case objCase = DRS_CaseService.getCaseDetails(caseId);
        Map<String,String> mapMergeFieldValues = new Map<String,String>();
        mapMergeFieldValues.put('{CaseNumber}', objCase.CaseNumber);
        mapMergeFieldValues.put('{dateTimeStamp}', DateTime.now().format(DRS_GlobalUtility.DateTimeFormat));
        String caseLink = 'https://' + objInsurerDomainSite.Domain.Domain + objInsurerDomainSite.PathPrefix + '/casedetail?recordId=' + objCase.Id;
        mapMergeFieldValues.put('{CaseLink}', caseLink);
        List<String> toAddresses = new List<String>();
        for(User objUser : mapUsers.values()) { 
           if ((objUser.Contact.Account.Type == DRS_AccountService.TypeInsurer ||
               objUser.Contact.Account.Type == DRS_AccountService.TypeLegalFirm)
				&& String.isNotBlank(objUser.Contact.Email)) {
               toAddresses.add(objUser.Contact.Email);
               mapContactMergeFields.put(objUser.Contact.Email, DRS_ContactService.getContactMergeFields(DRS_ContactService.getContactObjectFromUser(objUser)));
           }
    	}
    	if(toAddresses.size() > 0) {
            DRS_GlobalUtility.sendEmailUsingTemplate(DRS_CaseService.EmailCaseTeamMemberAdded, mapMergeFieldValues, toAddresses, mapContactMergeFields);
        }
        //DRS_CaseService.sendEmailsToAllCaseTeamMembers(DRS_CaseService.EmailCaseTeamMemberAdded, caseId, null);
    }
    
    ///Performs the DML operations for the particular list of SObjects provided
    public static void performDML(List<SObject> listToInsert, List<SObject> listToUpdate, List<SObject> listToDelete) {
        //if(listToInsert != null && listToInsert.size() > 0) {
        //  Insert listToInsert;
        //}
        if(listToUpdate != null && listToUpdate.size() > 0) {
            listToUpdate.sort();
            Update listToUpdate;
        }
        //if(listToDelete != null && listToDelete.size() > 0) {
        //  Delete listToDelete;
        //}
    }
    
    ///Sends a REST request to the provided endpoint
    ///Returns the HttpResponse received
    public static HttpResponse callRESTAPI(String method, String endpoint, String body, Map<String,String> headers) {
        try {
            System.debug('---DRS_GlobalUtility:callRESTAPI:method:' + method + ', endpoint:' + endpoint + ', body:' + body);
            HttpRequest objHttpRequest = new HttpRequest();
            objHttpRequest.setEndpoint(endpoint);
            objHttpRequest.setMethod(method);
            if(string.isNotBlank(body)) {
                objHttpRequest.setBody(body);
            }
            if(headers != null) {
                for(String header : headers.keySet()) {
                    objHttpRequest.setHeader(header, headers.get(header));
                }
            }
            Http objHttp = new Http();
            HttpResponse objHttpResponse = objHttp.send(objHttpRequest);
            System.debug('---DRS_GlobalUtility:callRESTAPI:objHttpResponse:' + objHttpResponse);
            return objHttpResponse;
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_GlobalUtility', 'callRESTAPI');
        }
        return null;
    }
    
    ///Logs the message in ApplicationLog__c object
    public static ApplicationLog__c getAppliationLogError(
        String message, String integrationPayload, String logCode, String referencId, String referenceInformation, String className, String functionName, String stackTrace) 
    {
        ApplicationLog__c objApplicationLog = new ApplicationLog__c(
            Source__c = className,
            SourceFunction__c = functionName,
            DebugLevel__c = 'Error',
            LogCode__c = logCode,
            IntegrationPayload__c = integrationPayload,
            Message__c = message,
            ReferenceId__c = referencId,
            ReferenceInformation__c = referenceInformation,
            StackTrace__c = stackTrace);
        return objApplicationLog;
    }
    
    ///Creates a SavePoint in Salesforce and returns it
    ///	Returns a null value if running in Test context
    public static System.SavePoint createSavePoint() {
    	if(!Test.isRunningTest()) {
    		return Database.setSavepoint();
    	}
    	else {
    		return null;
    	}
    }
    
    ///Creates a SavePoint in Salesforce and returns it
    ///	Returns a null value if running in Test context
    public static void rollbackSavePoint(System.SavePoint objSavePoint) {
    	if(!Test.isRunningTest() && objSavePoint != null) {
    		Database.rollback(objSavePoint);
    	}
    }
}