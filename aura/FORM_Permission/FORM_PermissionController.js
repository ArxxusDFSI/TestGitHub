({
    init: function(component, event, helper) {
        var action = component.get('c.isDelegatedAdmin');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.isDelegatedAdmin', response.returnValue);
                var action1 = component.get('c.getUsersForAccount');
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var userList = JSON.parse(response.returnValue);
                        component.set('v.users', userList.activeUsers);
                        component.set('v.inActiveUsers', userList.inActiveUsers);
                        component.set('v.activeUsers', userList.activeUsers);
                        component.set('v.pendingUsers', userList.pendingUsers);
                    }
                    else {
                        component.set('v.errorMessage', response.getError()[0].message);
                    }
                });
                $A.enqueueAction(action1);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

        action = component.get('c.getAvailableRoles');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.roles', JSON.parse(response.returnValue));
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

        action = component.get('c.getAccounts');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var accounts = JSON.parse(response.returnValue);
                if (accounts && accounts.length > 0)
                    component.set('v.accounts', accounts);
                else component.set('v.accountsDisabled', true);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    addUser: function(component, event, helper) {
        component.set('v.modalMode', 'new');
        component.set('v.errorMessage', null);
        jQuery('#addUserForm :input, select').each(function() {
           this.value = '';
        });
        //component.set('v.accountsDisabled', true);
        component.find('usersList').elements[0].value = component.get('v.userListValue');
        jQuery('#backdrop').addClass('slds-backdrop--open');
        jQuery('#addUserModal').addClass('slds-fade-in-open');
    },

    editUser: function(component, event, helper) {
        var user = event.target.parentElement.parentElement.data;
        component.set('v.userId', user.id);
        component.set('v.contactId', user.contactId);
        component.set('v.errorMessage', '');
        var action = component.get('c.getUserWithId');
        var userId;
        if(user.id) {
            userId = user.id;
        }
        else {
            userId = user.contactId;
        }
        
        action.setParams({userId: userId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var userList = JSON.parse(response.returnValue);
                $('#firstName').val(userList.firstName);
                $('#lastName').val(userList.lastName);
                component.find('email').set('v.value', userList.emailAddress);
                $('#phone').val(userList.phone);
                if (userList.address){
                   $('#address').val(userList.address);
                   $('#suburb').val(userList.suburb);
                   $('#state').val(userList.state);
                   $('#postcode').val(userList.postcode);
                }
                $('#role').val(userList.role);
                $('#accounts').val(userList.accountId);
                //component.set('v.accountsDisabled', false);
                component.set('v.modalMode', 'edit');
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
            jQuery('#backdrop').addClass('slds-backdrop--open');
            jQuery('#addUserModal').addClass('slds-fade-in-open');
        });
        $A.enqueueAction(action);
    },

    saveModal: function(component, event, helper) {
        component.set('v.buttonDisable', true);
        var action = component.get('c.registerUser');
        var params = {};
        jQuery('#addUserForm :input, select').each(function() {
            if (this.type == 'email')
                params['emailAddress'] = this.value;
            else if (this.id == 'accounts'){
                params['accountId'] = this.value;
                params['accountName'] = this.textContent;
            }
            else if (this.id)
                params[this.id] = this.value;
        });
        action.setParams({userJSON: JSON.stringify(params)});
        action.setCallback(this, function(response) {
            component.set('v.buttonDisable', false);
            var state = response.getState();
            if (state === 'SUCCESS') {
                if (component.get('v.modalMode') == 'new'){
                    location.reload();
                }
                else {
                    var userList = JSON.parse(response.returnValue);
                    component.set('v.users', userList);
                    var users = component.get('v.users');
                    users.push(params);
                    component.set('v.users', users);
                    jQuery('#addUserForm :input, select').each(function() {
                        this.value = '';
                    });
                    jQuery('#addUserModal').removeClass('slds-fade-in-open');
                    jQuery('#backdrop').removeClass('slds-backdrop--open');
                }
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateModal: function(component, event, helper) {
        component.set('v.buttonDisable', true);
        var action = component.get('c.updateUser');
        var params = {};
        jQuery('#addUserForm :input, select').each(function() {
            if (this.type == 'email')
                params['emailAddress'] = this.value;
            else if (this.id)
                params[this.id] = this.value;
        });
        params['Id'] = component.get('v.userId');
        params['contactId'] = component.get('v.contactId');
        action.setParams({userJSON: JSON.stringify(params)});
        action.setCallback(this, function(response) {
            component.set('v.buttonDisable', false);
            var state = response.getState();
            if (state === 'SUCCESS') {
                location.reload();
                //jQuery('#addUserModal').removeClass('slds-fade-in-open');
                //jQuery('#backdrop').removeClass('slds-backdrop--open');
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    closeModal: function(component, event, helper) {
        jQuery('#addUserModal').removeClass('slds-fade-in-open');
        jQuery('#backdrop').removeClass('slds-backdrop--open');
    },

    confirmAction: function(component, event, helper) {
        var user = event.target.parentElement.parentElement.data;
        component.set('v.userId', user.id);
        component.set('v.contactId', user.contactId);
        component.set('v.userEmail', user.emailAddress);
        if (event.target.innerHTML == 'Deactivate'){
            component.set('v.confirmUserModal', 'deactivate');
        }
        else if (event.target.innerHTML == 'Activate')
            component.set('v.confirmUserModal', 'activate');
        else component.set('v.confirmUserModal',  'email');
        jQuery('#deactivateUserModal').addClass('slds-fade-in-open');
        jQuery('#backdrop').addClass('slds-backdrop--open');
    }, 

    closeConfirmUserModal: function(component, event, helper) {
        jQuery('#deactivateUserModal').removeClass('slds-fade-in-open');
        jQuery('#backdrop').removeClass('slds-backdrop--open');
    },

    saveConfirmUserModal: function(component, event, helper) {
        var value = component.get('v.userListValue');
        var id = component.get('v.userId');
        var contactId = component.get('v.contactId');
        var action;

        if (value == 'activeUsers'){
            action = component.get('c.deactivateUser');
            action.setParams({userId: id});
        }
        else if (value == 'pendingUsers') {
            action = component.get('c.resendActivationEmail');
            action.setParams({emailAddress: component.get('v.userEmail'), contactId: contactId});
        }
        else if (value == 'inActiveUsers'){
            action = component.get('c.activateUser');
            action.setParams({userId: id});
        }
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                location.reload();
            }
        });
        $A.enqueueAction(action);
    }, 

    sortColumn: function(component, event, helper) {
        function formatDate(dataDate){
            if(dataDate == null || dataDate === ''){
                return new Date();
            }

            var day = (dataDate.split(" ")[0]).split('/');
            var hour = (dataDate.split(" ")[1]).split(':');

            // return new Date(day, month[, date[, hours[, minutes[, seconds[, milliseconds]]]]]);
            return new Date(day[2], day[1], day[0], hour[0], hour[1], hour[2]);
        }

        // get all the users
        var userList = component.get('v.users');
        var dataProperty = event.currentTarget.dataproperty;
        var dataType = event.currentTarget.datatype;
        
        $('#caseTeamTable .glyphicon').remove();

        // Descending sorting
        if (!event.currentTarget.data || event.currentTarget.data == 'down'){
            event.currentTarget.data = 'up';
            
            // Add Arrow Icon (pointing up)
            event.currentTarget.innerHTML += '<span class="glyphicon glyphicon-arrow-up" aria-hidden="true"/>';
    
            // Sort users
            if(dataType == 'number'){
                userList.sort(function(a, b){
                    return b[dataProperty] - a[dataProperty];
                });
            }else if (dataType == 'text'){
                userList.sort(function(a, b){
                    if(a[dataProperty] < b[dataProperty]) return 1;
                    if(a[dataProperty] > b[dataProperty]) return -1;
                    return 0;
                });
            }else if(dataType == 'date'){
                userList.sort(function(a,b){
                    return formatDate(b[dataProperty]) - formatDate(a[dataProperty]);
                });
            }
        }
        // Ascending sorting
        else if (event.currentTarget.data == 'up'){
            event.currentTarget.data = 'down';

            // Add Arrow Icon (pinting down)
            event.currentTarget.innerHTML += '<span class="glyphicon glyphicon-arrow-down" aria-hidden="true"/>';

            // Sort users
            if(dataType == 'number'){
                userList.sort(function(a, b){
                    return a[dataProperty] - b[dataProperty];
                });
            }else if (dataType == 'text'){
                userList.sort(function(a, b){
                    if(a[dataProperty] < b[dataProperty]) return -1;
                    if(a[dataProperty] > b[dataProperty]) return 1;
                    return 0;
                });
            }else if(dataType == 'date'){
                userList.sort(function(a,b){
                    return formatDate(a[dataProperty]) - formatDate(b[dataProperty]);
                });
            }

        }

        component.set('v.users', userList);

    },

    updateUsersList: function(component, event, helper) {
        var value = component.find('usersList').get('v.value');
        component.set('v.users', component.get('v.' + value));
    }
})