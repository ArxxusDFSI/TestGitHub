({
    handleActionEvent : function(component, event) {
        var action = event.getParam('action');
        var params = event.getParam('params');
        
        switch (action) {
            case 'oAuthInitStartLoading':
                component.set('v.isStatusLoading', true);
                break;
            case 'oAuthInitDoneLoading':
                params = JSON.parse(params);
                component.set('v.isAuthorized', params.isAuthorized);
                component.set('v.authorizingUser', params.authorizingUser);
                if (params.authorizingUser) {
                    component.set('v.showUsername', true);
                }

                component.set('v.isStatusLoading', false);
                break;
            case 'oAuthStatusUpdate':
                params = JSON.parse(params);
                
                var isAuthorized = component.get('v.isAuthorized') || params.isAuthorized;
                component.set('v.isAuthorized', isAuthorized);
                
                var authorizingUser;
                if (isAuthorized) {
                    authorizingUser = params.authorizingUser ? params.authorizingUser : component.get('v.authorizingUser');
                    component.find('authorizingUser').getElement().style.color = 'black';
                }
                else {
                    authorizingUser = 'Authorization was denied.';
                    component.find('authorizingUser').getElement().style.color = 'red';
                }
                component.set('v.authorizingUser', authorizingUser);
                component.set('v.showUsername', true);
                
                if (isAuthorized) {
                    var moveToNextStep = component.getEvent("moveToNextStep");
                    moveToNextStep.setParams({
                        success: true
                    });
                    moveToNextStep.fire();
                }
                break;
            case 'oAuthStartLoading':
                component.set('v.isStatusLoading', true);
                break;
            case 'oAuthDoneLoading':
                component.set('v.isStatusLoading', false);
                
                var doneLoading = component.getEvent('actionEvent');
                doneLoading.setParams({
                    action: 'doneLoading'
                });
                doneLoading.fire();
                break;
            case 'oAuthError':
                var errorEvent = component.getEvent('showError');
                errorEvent.setParams({
                    message: params
                });
                errorEvent.fire();
            default:
                break;
        }
    },
    startOAuthFlow : function(component, event) {
        var authorizeLoopServices = component.find('authorizeLoopServices');
        authorizeLoopServices.startOAuthFlow();
    }
})