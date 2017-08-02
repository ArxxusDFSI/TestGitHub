({
    handleForgotPassword: function (component, event, helpler) {
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var action = component.get("c.forgotPassword");
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != "success") {
               component.set("v.errorMessage","Invalid UserName. Please check the UserName you have entered.");
               component.set("v.showError",true);
               component.set("v.showSuccess",false);
            }else if(rtnValue=="success"){
                component.set("v.successMessage","Please Check Your Email.");
                component.set("v.showError",false);
                component.set("v.showSuccess",true);
                
            }
            
       });
        $A.enqueueAction(action);
    }
})