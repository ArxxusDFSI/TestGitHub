/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This Class is the controller class for InsurerPortal forgot Password Page.
                        
Test Class:     InsurerPortal_ForgotPwdControllerTest
History
14/July/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
global class InsurerPortal_ForgotPasswordController {

    @AuraEnabled
    public static String forgotPassword(String userName, String checkEmailUrl) {
       try {
                Site.forgotPassword(userName);
                //ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                if(!Site.isValidUsername(userName)) {
                    return Label.Site.invalid_email;
                }
               // aura.redirect(checkEmailRef);
                return 'success';
           }
           catch (Exception ex) {return ex.getMessage();}
    }

}