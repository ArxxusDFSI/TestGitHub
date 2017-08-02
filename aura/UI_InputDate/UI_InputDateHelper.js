({
	getAge : function(dateString) {
		var today = new Date();
        var birthDate = dateString.split('/');
        var age = today.getFullYear() - parseInt(birthDate[2]);
        var m = today.getMonth() + 1 - parseInt(birthDate[1]);
        if (m < 0 || (m === 0 && today.getDate() < parseInt(birthDate[0]))) {
            age--;
        }
        return age;
	}
})