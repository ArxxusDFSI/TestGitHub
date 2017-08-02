public class DRS_SetupData {
    
    public static final String ALLPROJECTS = 'ALL';
    public static final String DFSI_MRS_1703 = 'DFSI_MRS_1703';
    public static final String DFSI_MRS_1705 = 'DFSI_MRS_1705';
    public static final String DFSI_MRS_1706 = 'DFSI_MRS_1706';
    
    private static final String DEV = 'DEV';
    private static final String UAT = 'UAT';
    private static final String PROD = 'PROD';
    private static final String DEV_UAT = 'DEV_UAT';
    private static final String ALLENVIRONMENTS = 'DEV_UAT_PROD';
    
    private static Map<String, Profile> mapProfiles;
    private static Map<String, Id> mapRecordTypes;
    private static Map<String, Group> mapQueues;
    private static Map<String, DomainSite> mapDomainSites;
    private static Map<String, UserRole> mapUserRoles;
    private static List<String> currentProjects;
    private static String currentEnvironment;
    private static String currentEnvironmentSuffix;
    private static User adminUser;
    
    public static void processData() {
        System.debug('---DRS_SetupData:processData');
        List<String> listProjects = new List<String>();
        listProjects.add(DRS_SetupData.ALLPROJECTS);
        DRS_SetupData.processData(listProjects, DRS_SetupData.DEV_UAT);
    }
    
    public static void processData(String projectName, String environment) {
    	DRS_SetupData.processData(new List<String>{projectName}, environment);
    }
    
    public static void processData(List<String> listProjects, String environment) {
        System.debug('---DRS_SetupData:processData:listProjects:' + listProjects +', environment:' + environment);
        DRS_SetupData.currentProjects = listProjects;
        DRS_SetupData.currentEnvironment = environment;
        
        DRS_SetupData.initializeDRS_SetupData();
        DRS_SetupData.initializeCustomSettings();
        DRS_SetupData.initializeObjectData();
    }
    
    private static void initializeDRS_SetupData() {
        System.debug('---DRS_SetupData:initializeDRS_SetupData');
        String host = URL.getSalesforceBaseUrl().getHost();
        String suffix = '';
        if(host.left(2) == 'cs') {
            suffix = DRS_GlobalUtility.getGuid().left(8);
        }
        else {
            suffix = host.substringAfter('.');
        }
        DRS_SetupData.currentEnvironmentSuffix = suffix;
        
        DRS_SetupData.mapProfiles = new Map<String, Profile>();
        
        for(Profile objProfile : [
            Select Id, Name
            From Profile
        ]) {
            DRS_SetupData.mapProfiles.put(objProfile.Name, objProfile);
        }
        
        DRS_SetupData.mapRecordTypes = DRS_GlobalUtility.getRecordTypes();
        DRS_SetupData.mapQueues = new Map<String, Group>();
        for(Group objGroup : [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue']) {
            DRS_SetupData.mapQueues.put(objGroup.DeveloperName, objGroup);
        }
        
        for(User objUser : [Select Id From User Where UserName =: 'default.owner@dfsi.' + DRS_SetupData.currentEnvironmentSuffix + '.gov.au' And UserRoleId != null Limit 1]) {
            DRS_SetupData.adminUser = objUser;
        }
        if(adminUser == null) {
            for(User objUser : [Select Id From User Where Profile.Name = 'System Administrator' And UserRoleId != null Limit 1]) {
                DRS_SetupData.adminUser = objUser;
            }
        }
        
        DRS_SetupData.mapUserRoles = new Map<String,UserRole>();
        for(UserRole objUserRole : [Select Id, DeveloperName From UserRole Limit 1]) {
            DRS_SetupData.mapUserRoles.put(objUserRole.DeveloperName, objUserRole);
        }
        
        if(DRS_SetupData.adminUser == null) {
            DRS_SetupData.adminUser = new User(
        		ProfileId = DRS_SetupData.mapProfiles.get('System Administrator').Id,
        		UserRoleId = DRS_SetupData.mapUserRoles.values()[0].Id,
        		Username = 'default.owner@dfsi.' + DRS_SetupData.currentEnvironmentSuffix + '.gov.au',
        		FirstName = 'Default',
        		LastName = 'Owner',
        		CommunityNickname =  'Default' + DRS_GlobalUtility.getGuid().left(8),
        		Email = 'support@dfsi.gov.au',
        		Alias = DRS_GlobalUtility.getGuid().left(8),
        		TimeZoneSidKey = 'Australia/Sydney',
        		LocaleSidKey = 'en_AU',
        		EmailEncodingKey = 'ISO-8859-1',
        		LanguageLocaleKey = 'en_US'
            );
            Insert DRS_SetupData.adminUser;
        }
        
        DRS_SetupData.mapDomainSites = new Map<String, DomainSite>();
        for(DomainSite objDomainSite : [Select Id, SiteId, PathPrefix, DomainId, Domain.Domain From DomainSite]) {
            DRS_SetupData.mapDomainSites.put(objDomainSite.PathPrefix, objDomainSite);
        }
    }
    
    private static void initializeObjectData() {
        DRS_SetupData.initializeTaskTemplates();
    }
    
    private static void initializeCustomSettings(){
        System.debug('---DRS_SetupData:initializeCustomSettings');
        DRS_SetupData.initializeMRSCustomSettings();
    }
    
    private static Boolean isCurrentProjectEnvironment(String project, String environment) {
        System.debug('---DRS_SetupData:isCurrentProjectEnvironment:project:' + project + ', environment:' + environment);
        if(String.isNotBlank(environment) && (environment.contains(DRS_SetupData.currentEnvironment) || environment == DRS_SetupData.ALLENVIRONMENTS)) {
            for(String projectItem : DRS_SetupData.currentProjects) {
                if(projectItem == DRS_SetupData.ALLPROJECTS) {
                    return true;
                }
                else if(projectItem == project) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    private static void initializeTaskTemplates() {
        System.debug('---DRS_SetupData:initializeTaskTemplates');
        List<TaskTemplate__c> listTaskTemplates = new List<TaskTemplate__c>();
        
        if(DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1703, DRS_SetupData.ALLENVIRONMENTS)) {
            listTaskTemplates = new List<TaskTemplate__c>([
                Select Id
                From TaskTemplate__c
            ]);
            Delete listTaskTemplates;
            
            listTaskTemplates = new List<TaskTemplate__c>();
            listTaskTemplates.add(new TaskTemplate__c(Name = DRS_CaseService.InsurerReplyTaskType, Type__c = DRS_CaseService.InsurerReplyTaskType, CommunityPageURL__c = 'insurerform', Subject__c = DRS_CaseService.InsurerReplyTaskType, Description__c = DRS_CaseService.InsurerReplyTaskType, DaysUntilDueDate__c = 10));
            listTaskTemplates.add(new TaskTemplate__c(Name = DRS_CaseService.AdditionalInformationTaskType, Type__c = DRS_CaseService.AdditionalInformationTaskType, CommunityPageURL__c = 'additionalinfo', Subject__c = DRS_CaseService.AdditionalInformationTaskType, Description__c = DRS_CaseService.AdditionalInformationTaskType, DaysUntilDueDate__c = 10));
            listTaskTemplates.add(new TaskTemplate__c(Name = DRS_CaseService.JurisdictionChecklistTaskType, Type__c = DRS_CaseService.AllocationChecklistTaskType, CommunityPageURL__c = 'allocationchecklist', Subject__c = DRS_CaseService.JurisdictionChecklistTaskType, Description__c = DRS_CaseService.JurisdictionChecklistTaskType, DaysUntilDueDate__c = 10));
            listTaskTemplates.add(new TaskTemplate__c(Name = 'Update Case Team', Subject__c = 'Update Case Team and Primary Contact', Description__c = 'Please Assign Case Team Members for Internal MRS Staff, and set a Primary Contact, and then assign the Case to the Case.'));
            listTaskTemplates.add(new TaskTemplate__c(Name = 'Validate Insurer and Insurer Triage users', Subject__c = 'Validate Insurer', Description__c = 'Validate the correct Insurer has been selected by the applicant, and ensure that the Insurer selected has active Triage users associated with their account'));
            listTaskTemplates.add(new TaskTemplate__c(Name = 'Send Decision', Subject__c = 'Send Decision', Description__c = 'Email and Post Decision to parties.'));
        }
        if(DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1705, DRS_SetupData.ALLENVIRONMENTS)) {
			listTaskTemplates.add(new TaskTemplate__c(Name = 'MRS Assign to CMA', Subject__c = 'Assign Case to CMA', Description__c = 'Please assign the case back to the CMA once the decision has been sent. (This will be set as the Decision Sent Date)'));
			listTaskTemplates.add(new TaskTemplate__c(Name = 'MRS Decision', Subject__c = 'MRS Decision', Description__c = 'Please complete your Merit Review Decision. And Upload the final decision document/s to the Case Items section.'));
        }
        if(DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1706, DRS_SetupData.ALLENVIRONMENTS)) {
        	listTaskTemplates.add(new TaskTemplate__c(Name = DRS_CaseService.AllocationChecklistTaskType, Type__c = DRS_CaseService.JurisdictionChecklistTaskType, CommunityPageURL__c = 'jurisdictionchecklist', Subject__c = DRS_CaseService.AllocationChecklistTaskType, Description__c = DRS_CaseService.AllocationChecklistTaskType, DaysUntilDueDate__c = 10));
            listTaskTemplates.add(new TaskTemplate__c(Name = 'MRS Responded to App', Subject__c = 'Respond to App', Description__c = 'Please close this task once you have responded to the App (This will be set as the Respond to Date Sent)'));
        }
        if(listTaskTemplates.size() > 0) {
        	Insert listTaskTemplates;
        }
    }
    
    private static void initializeMRSCustomSettings() {
        System.debug('---DRS_SetupData:initializeMRSCustomSettings');
        Map<String, CaseTeamRoleAssociation__c> mapCaseTeamRoleAssociations = CaseTeamRoleAssociation__c.getall();
        Configuration__c objMRSConfiguration;
        try {
         objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        }
        catch(Exception excep) { }
        
        if(DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1703, DRS_SetupData.ALLENVIRONMENTS) ||
           DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1705, DRS_SetupData.ALLENVIRONMENTS)) {
            if(mapCaseTeamRoleAssociations.size() > 0) {
                Delete mapCaseTeamRoleAssociations.values();
            }
            
            mapCaseTeamRoleAssociations = new Map<String, CaseTeamRoleAssociation__c>();
            mapCaseTeamRoleAssociations.put(
            	'Insurer_Claims_Manager_Claims_Manager',
            	new CaseTeamRoleAssociation__c(Name = 'Insurer_Claims_Manager_Claims_Manager', AccountType__c = 'Insurer', CaseTeamRole__c = 'Insurer Claims Manager', ContactRole__c = 'Claims Manager')
            );
            mapCaseTeamRoleAssociations.put(
            	'Insurer_Triager_Triage',
            	new CaseTeamRoleAssociation__c(Name = 'Insurer_Triager_Triage', AccountType__c = 'Insurer', CaseTeamRole__c = 'Insurer Triager', ContactRole__c = 'Triage')
            );
            mapCaseTeamRoleAssociations.put(
            	'Insurer_Legal_Rep_Legal_Rep',
            	new CaseTeamRoleAssociation__c(Name = 'Insurer_Legal_Rep_Legal_Rep', AccountType__c = 'Insurer', CaseTeamRole__c = 'Insurer Legal Rep', ContactRole__c = 'Legal Rep')
            );
            mapCaseTeamRoleAssociations.put(
            	'Insurer_Administrator',
            	new CaseTeamRoleAssociation__c(Name = 'Insurer_Administrator', AccountType__c = 'Insurer', CaseTeamRole__c = '', ContactRole__c = 'Administrator')
            );
            mapCaseTeamRoleAssociations.put(
            	'Legal_Firm_Legal_Rep',
            	new CaseTeamRoleAssociation__c(Name = 'Legal_Firm_Legal_Rep', AccountType__c = 'Legal Firm', CaseTeamRole__c = 'Legal Representative', ContactRole__c = 'Legal Rep')
            );
            Insert mapCaseTeamRoleAssociations.values();
        }
        
        if(DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1703, DRS_SetupData.ALLENVIRONMENTS) ||
           DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1705, DRS_SetupData.ALLENVIRONMENTS)) {
            if(objMRSConfiguration != null) {
                Delete objMRSConfiguration;
            }
               
               objMRSConfiguration = new Configuration__c();
               objMRSConfiguration.Name = 'Merit Review Services';
               objMRSConfiguration.CaseOwner__c = DRS_SetupData.mapQueues.get('Merit_Review_Service').Id;
               objMRSConfiguration.CommunityAccountOwner__c = adminUser.Id;
               objMRSConfiguration.DefaultTaskOwner__c = adminUser.Id;
               objMRSConfiguration.ProfileId1__c = DRS_SetupData.mapProfiles.get('MRS Applicant Community User').Id;
               objMRSConfiguration.ProfileId2__c = DRS_SetupData.mapProfiles.get('MRS Insurer Community User').Id;
               objMRSConfiguration.SiteId1__c = DRS_SetupData.mapDomainSites.get('/mrs01/s').SiteId;
               objMRSConfiguration.SiteId2__c = DRS_SetupData.mapDomainSites.get('/insurerlegal/s').SiteId;
               objMRSConfiguration.NumberOfDaysToExpire__c = 90;
               objMRSConfiguration.S3BucketName__c = 'prizmdocdata-test';
               objMRSConfiguration.S3EncryptionScheme__c = 'SHA-256';
               objMRSConfiguration.S3HeaderEncryptionScheme__c = 'AWS4-HMAC-SHA256';
               objMRSConfiguration.S3Host__c = 's3-ap-southeast-2.amazonaws.com';
               objMRSConfiguration.S3Region__c = 'ap-southeast-2';
               objMRSConfiguration.S3ServerSideEncryptionAlgorithm__c = 'AES256';
               objMRSConfiguration.S3Timeout__c = '10800';
               objMRSConfiguration.Username__c = 'Username';
               objMRSConfiguration.Password__c = 'Password';
               
               for(OrgWideEmailAddress objOrgWideEmailAddress : [Select Id From OrgWideEmailAddress Where DisplayName = 'State Insurance Regulatory Authority']) {
                   objMRSConfiguration.FromEmailAddress__c = objOrgWideEmailAddress.Id;
               }
               
               if(DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1706, DRS_SetupData.DEV)) {
                   objMRSConfiguration.EC2ServerPath__c = 'https://d1l96qz2fc0rch.cloudfront.net';
               }
               else if(DRS_SetupData.isCurrentProjectEnvironment(DRS_SetupData.DFSI_MRS_1706, DRS_SetupData.UAT)) {
                   objMRSConfiguration.EC2ServerPath__c = 'https://d2wy8o9xqmu45y.cloudfront.net';
               }
               
               Insert objMRSConfiguration;
        }
    }
    
}