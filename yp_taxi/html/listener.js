$(function(){
	const fadedStart = "#598559";
	const readyStart = "#267926";
	const fadedStop = "#a86767";
	const readyStop = "#9a3434";
	var total = document.getElementById('totalvalue');
	var rate = document.getElementById('ratevalue');
	var start = document.getElementById('startbutton');
	var stop = document.getElementById('stopbutton');
	
	function display(bool){
		if (bool) {
			$('#container').show();
		}
		else {
			$('#container').hide();
		}
	}

	display(false);

	window.addEventListener('message', function(event){
		item = event.data;
		if (item.type == 'ui'){
			display(item.enable);
			total.innerHTML = '$'+item.total;
			rate.innerHTML = '$'+item.rate;
		}
		else if(item.type == 'update') {
			if (item.element == 'rate') {
				rate.innerHTML = '$'+item.value;
			}
			else if (item.element == 'total') {

				total.innerHTML = '$'+item.value
			}
		}
		else if (item.type == 'start') {
			start.style.background = fadedStart;
			stop.style.background = readyStop;
		}
		else if (item.type == 'stop'){
			start.style.background = readyStart;
			stop.style.background = fadedStop;
		}
	})
});