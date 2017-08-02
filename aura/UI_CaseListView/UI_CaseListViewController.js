({
	init : function(component, event, helper) {
		var action = component.get('c.getCaseList');
		var location = window.location.pathname.split('/');
        if (location && location[1])
            component.set('v.communitylink', '/' + location[1] + '/s');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var cases = JSON.parse(response.returnValue);
                component.set('v.cases', cases);
            }
            else {
                component.set('v.errorMessage', response.getError()[0].message);
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

		// get all the cases
		var cases = component.get('v.cases');
		var dataProperty = event.currentTarget.dataproperty;
		var dataType = event.currentTarget.datatype;
		
		$('#caseTeamTable .glyphicon').remove();

		// Descending sorting
		if (!event.currentTarget.data || event.currentTarget.data == 'down'){
			event.currentTarget.data = 'up';
			
			// Add Arrow Icon (pointing up)
			event.currentTarget.innerHTML += '<span class="glyphicon glyphicon-arrow-up" aria-hidden="true"/>';
	
			// Sort Cases
			if(dataType == 'number'){
				cases.sort(function sortCases(a, b){
					return b[dataProperty] - a[dataProperty];
				});
			}else if (dataType == 'text'){
				cases.sort(function(a, b){
				    if(a[dataProperty] < b[dataProperty]) return 1;
				    if(a[dataProperty] > b[dataProperty]) return -1;
				    return 0;
				});
			}else if(dataType == 'date'){
				cases.sort(function(a,b){	
				  	return formatDate(b[dataProperty]) - formatDate(a[dataProperty]);
				});
			}
		}
		// Ascending sorting
		else if (event.currentTarget.data == 'up'){
			event.currentTarget.data = 'down';

			// Add Arrow Icon (pinting down)
			event.currentTarget.innerHTML += '<span class="glyphicon glyphicon-arrow-down" aria-hidden="true"/>';

			// Sort Cases
			if(dataType == 'number'){
				cases.sort(function sortCases(a, b){
					return a[dataProperty] - b[dataProperty];
				});
			}else if (dataType == 'text'){
				cases.sort(function(a, b){
				    if(a[dataProperty] < b[dataProperty]) return -1;
				    if(a[dataProperty] > b[dataProperty]) return 1;
				    return 0;
				});
			}else if(dataType == 'date'){
				cases.sort(function(a,b){	
				  	return formatDate(a[dataProperty]) - formatDate(b[dataProperty]);
				});
			}

		}

		component.set('v.cases', cases);
	},

	refresh: function(component, event, helper) {
		location.reload();
	}
})