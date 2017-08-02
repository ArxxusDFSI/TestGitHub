({
    handleLogin: function (component, event, helpler) {
        var params = component.get('v.form');
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        startUrl = decodeURIComponent(startUrl);
        if (!params.username) {
            component.find('username').set('v.errorMessage', 'User name is incorrect');
        }
        if (!params.pwd) {
            component.find('pwd').set('v.errorMessage', 'Password is incorrect');
        }
        if (params.username && params.pwd) {
            component.set('v.buttonDisable', true);
            action.setParams({
                username: params.username, 
                password: params.pwd, 
                startUrl: startUrl || ''
            });
            //console.log(params.username + ' ' + params.pwd + ' ' + startUrl);
            action.setCallback(this, function(response){
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage",rtnValue);
                }
                else {
                    component.set('v.buttonDisable', false);
                    component.set("v.errorMessage", '');
                }
            });
            $A.enqueueAction(action);
        }
    }
})