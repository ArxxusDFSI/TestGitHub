({
    init : function(component, event, helper) {
        var action;
        var applicationId;
        var url = window.location.search.substring(1);
        helper.setFormData(component);
        if (window.location.pathname && window.location.pathname.split('/')[1])
            component.set('v.communitylink', window.location.pathname.split('/')[1]);
        url = url.split('=');
        if (window.location.pathname == '/apex/DRS_Case_WorkerCaseItemCreate'){
            component.set('v.isLoadedInConsole', true);
            component.set('v.pageNumber', 2);
            component.set('v.showInfo', false);
            component.set('v.form.agreeCondition', true);
        }

        var recordId = component.get('v.recordId');
        var action;
        if (url && url[0] == 'recordId' || recordId){
            if(recordId) {
                component.set('v.isLoadedInSalesforce',true);
                applicationId = recordId;
            }
            else {
                applicationId = url[1];
            }
            helper.loadExistFormData(component, applicationId);
        }
        else {
            helper.loadNewFormData(component, helper);
        }
    },
    validteCheckboxes: function(component, event, helper) {
        component.set('v.checkBoxRequired', false);
    },
    behalfOfWorker: function(component, event, helper) {
        var form = component.get('v.form');
        var formCopy = component.get('v.formCopy');
        console.log(formCopy.givenName);
        if (component.find('behalfOfWorker').get('v.value') == 'no'){
            form.title = '';
            form.givenName = '';
            form.surname = '';
            form.dob = '';
            form.contact = '';
            form.emailAddress = '';
            form.postal = '';
            form.suburb = '';
            form.state = '';
            form.postcode = '';
            if (formCopy.givenName)
                form.representativeName = formCopy.givenName + ' ' + formCopy.surname;
            form.representativeContact = formCopy.contact;
            form.emailAddressRepresentative = formCopy.emailAddress;
            form.representativeAddress = formCopy.postal;
            form.representativeSuburb = formCopy.suburb;
            form.representativeState = formCopy.state;
            form.representativePostcode = formCopy.postcode;
        }
        else if (component.find('behalfOfWorker').get('v.value') == 'yes'){
            form.title = formCopy.title;
            form.givenName = formCopy.givenName;
            form.surname = formCopy.surname;
            form.dob = formCopy.dob;
            form.contact = formCopy.contact;
            form.emailAddress = formCopy.emailAddress;
            form.postal = formCopy.postal;
            form.suburb = formCopy.suburb;
            form.state = formCopy.state;
            form.postcode = formCopy.postcode;
        }
        component.set('v.form', form);
    },
    save : function(component, event, helper) {
        component.set('v.buttonDisable', true);
        if (component.get('v.autoSaving'))
            window.setTimeout(
                $A.getCallback(function() {
                    helper.saveForm(component, helper, false);
                }), 5000
            );
        else helper.saveForm(component, helper, false);
    },
    submit : function(component, event, helper) {
        if (helper.validateFields(component)) {
            helper.submitForm(component);
        }
        else {
            window.scrollTo(0,0);
        }
    },
    doShowInfo: function(component, event, helper) {
        component.set('v.showInfo', true);
    },
    next: function(component, event, helper) {
        var agreeCondition = component.find('agreeCondition');
        if (agreeCondition.get('v.value') == 'yes'){
            agreeCondition.set('v.errorMessage', '');
            component.set('v.pageNumber', component.get('v.pageNumber') + 1);
        }
        else {
            agreeCondition.set('v.errorMessage', 'Please agree to the conditions before continue');
        }
        window.scrollTo(0,0);
    },
    back: function(component, event, helper) {
        component.set('v.pageNumber', component.get('v.pageNumber') - 1);
    },
    print: function(component, event, helper) {
        window.print();
    },
    collapse: function(component, event, helper) {
        var target = event.target;
        if (event.target.firstElementChild)
            target = event.target.firstElementChild;
        if (target.className.indexOf('down') > -1) {
            target.className = "more-less glyphicon glyphicon-chevron-up";
        }
        else {
            target.className = "more-less glyphicon glyphicon-chevron-down";
        }
    }
})