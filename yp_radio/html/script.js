$(function(){
	var text = document.getElementById('channel');
	var box = document.getElementById('container');
	var submit = document.getElementById('submit');

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
			text.value = event.data.channel;
		}
	});

	document.onkeyup = function(e) {
		if (e.key == "Escape" || e.which == 27) {
			$.post("http://yp_radio/exit", JSON.stringify({}));
		}
	};

	box.addEventListener('click', function(){
		if (text.value < text.min){
			text.value = text.min;
		}
		else if (text.value > text.max){
			text.value = text.max;
		}
	});

	submit.addEventListener('click', function(){
		$.post("http://yp_radio/swapChannel", JSON.stringify({channel: text.value}));
	});

});