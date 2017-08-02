///A controller class to handle Register and Login functionality for the communities
public without sharing class DRS_RegisterLogin_CC {
    
    ///Gets the Contact information for the logged in User
    @AuraEnabled
    public static Contact getContactForUser(){
        return DRS_ContactService.getContactForUser();
    }
    
    ///Registers a new applicant based on the data provided
    @AuraEnabled
    public static String registerApplicant(
        String title,
        String firstName, String lastName, String birthDate, String phone, String emailAddress, 
        String mailingStreet, String mailingCity, String mailingState, String mailingPostalCode, 
        String password, Boolean solePractitioner, String laySocietyNumber, String validFrom, 
        String validTo)
    {
        try {
            System.debug('---DRS_RegisterLogin_CC:registerApplicant:solePractitioner:' + solePractitioner);
            
            DRS_RegistrationService.registerApplicant(
                title,
                firstName, lastName, birthDate, phone, emailAddress, mailingStreet, mailingCity, 
                mailingState, mailingPostalCode, password, ((solePractitioner != null && solePractitioner) ? DRS_ContactService.ContactRoleSolePractitioner : DRS_ContactService.ContactRoleWorker), 'activateAccount', 
                null, false, laySocietyNumber, validFrom, validTo);
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_RegisterLogin_CC', 'registerApplicant');
        }
        return 'Success';
    }
    
    ///Activates a community user based on the Activation Code provide
    @AuraEnabled
    public static String activateAccount(String activationCode){
        try{
            Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
            DRS_RegistrationService.activateAccount(activationCode, objMRSConfiguration.ProfileId1__c);
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_RegisterLogin_CC', 'activateAccount');
        }
        return 'Success';
    }
    
    ///Saves the profile of the currently logged in user
    @AuraEnabled
    public static String saveProfile(String profileJSON) {
        System.debug('---DRS_RegisterLogin_CC:saveProfile:profileJSON:' + profileJSON);
        
        ///Create a save point before executing changes
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        try {
            DRS_GlobalWrapper.ProfileJSON objProfileJSON = (DRS_GlobalWrapper.ProfileJSON)JSON.deserialize(profileJSON, DRS_GlobalWrapper.ProfileJSON.class);
            
            ///Apply the profile changes
            DRS_ContactService.updateProfile(
                objProfileJSON.title,
                objProfileJSON.firstName, objProfileJSON.lastName, objProfileJSON.birthDate, objProfileJSON.phone, 
                objProfileJSON.mailingStreet, objProfileJSON.mailingCity, objProfileJSON.mailingState, objProfileJSON.mailingPostalCode, 
                null, null, null,
                objProfileJSON.email, '', UserInfo.getUserId(), null);
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_RegisterLogin_CC', 'saveProfile');
        }
        
        return 'Success';
    }
    
    ///Resets the password for the UserName
    @AuraEnabled
    public static String resetPassword(String userName) {
        system.debug('userName =' + userName);
        boolean success = false;
        if(isUserNameExisting(userName)) {
            Site.forgotPassword(userName);
            return 'Please Check Your Email.';
        }else {
            return DRS_MessageService.getMessage('EmailNotExists');
        }
        
    }
    
    private static boolean isUserNameExisting(String username) {
        Boolean isUserNameExisting = false;
        String queryString = 'Select Id from User where email=:username';
        List<User> communityUsers = Database.query(queryString);
        system.debug('communityUsers ='+ communityUsers);
        if(communityUsers!=null && !communityUsers.isEmpty()) {
           isUserNameExisting = true;
        }
        return isUserNameExisting;
    }
    
}