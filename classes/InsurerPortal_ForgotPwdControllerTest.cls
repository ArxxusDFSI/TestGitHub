/*------------------------------------------------------------
Author:         Shyamala Sridevi
Company:        Capgemini
Description:    This is the test class for InsurerPortal_ForgotPasswordController.
                        
Test Class:     InsurerPortal_ForgotPwdControllerTest
History
14/July/2017    Shyamala Sridevi     Created
------------------------------------------------------------*/
@IsTest()
public with sharing class InsurerPortal_ForgotPwdControllerTest {

     /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
     @IsTest
     static void testLightningForgotPasswordControllerInvalidUserName() {
          System.assertEquals(InsurerPortal_ForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
          System.assertEquals(InsurerPortal_ForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
          System.assertEquals(InsurerPortal_ForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
     }
    
     /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
     @IsTest
     static void LightningForgotPasswordControllerInstantiation() {
          InsurerPortal_ForgotPasswordController.forgotPassword('abc@gmail.com','');
    
     }
}