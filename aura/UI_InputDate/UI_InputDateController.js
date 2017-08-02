({
	onScriptLoad: function(component, event, helper) {
	    /*if (typeof jQuery !== "undefined" && typeof $j === "undefined") {
            window.$j = window.jQuery.noConflict(true);
            console.log('Loaded JQuery: %s', window.$j.fn.jquery);
        }*/
        //var startDate = component.get('v.minDate');
        //var endDate = window.moment().add(component.get('v.maxDateYearDiff'), 'y');
        //var endDateString = window.moment(endDate).format('DD/MM/YYYYY');
        var id = component.get('v.id');
        var date_input = jQuery('#' + id);
        var container = 'body'; // '#' + id;
        var options = {
            format: 'dd/mm/yyyy',
            container: container,
            autoclose: true
        };
        date_input.datepicker(options).on('changeDate', function(e) {
            component.set('v.value', e.target.value);
            if (component.get('v.value') && component.get('v.mustbe14years')){
                var age = helper.getAge(e.target.value);
                if (age < 14){
                    component.set('v.errorMessage', 'The birth date must be a valid date and the person must be 14 years or older');
                }
                else if (component.get('v.value')){
                    component.set('v.errorMessage', '');
                }
            }
            else if (component.get('v.value'))
                component.set('v.errorMessage', '');
        }).blur(function(e){
            component.set('v.value', e.target.value);
            if (component.get('v.value') && component.get('v.mustbe14years')){
                var age = helper.getAge(e.target.value);
                if (age < 14){
                    component.set('v.errorMessage', 'You must be 14 years or older to proceed');
                }
                else if (component.get('v.value')){
                    component.set('v.errorMessage', '');
                }
            }
            else if (component.get('v.value')){
                component.set('v.errorMessage', '');
            }
        });
	}
})