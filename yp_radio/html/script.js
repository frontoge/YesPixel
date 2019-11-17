$(function(){
	function display(bool) {
		if (bool == true) {
			$('#container').show();
		} else {
			$('#container').hide();
		}
	}

	display(false);

	window.addEventListener('message', function(event){
		if (event.data.type == 'ui') {
			display(event.data.enable);
		}
	});

});