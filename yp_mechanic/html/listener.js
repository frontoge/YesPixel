$(function(){
	var balance;
	var amount = document.getElementById('amount');
	var balanceText = document.getElementById('balance');

	function display(bool) {
		if (bool == true) {
			$('#container').show();
		} else {
			$('#container').hide();
		}
	}

	function resetUi(){
		balanceText.innerHTML = 'Balance: $';
		amount.value = 0;
	}

	display(false);

	window.addEventListener('message', function(event) {
		var item = event.data;
		if (item.type == "ui") {
			if (item.enable === true) {
				display(true);
				balanceText.innerHTML += item.societyBalance;
				balance = parseInt(item.societyBalance);
				amount.max = balance;
			} else {
				display(false);
			}
		}
	});

	document.onkeyup = function(e) {
		if (e.key == "Escape" || e.which == 27) {
			display(false);
			resetUi();
			$.post("http://yp_mechanic/exit", JSON.stringify({}));
		}
	};

	var box = document.getElementById('container');
	var withdraw = document.getElementById('withdraw');
	var deposit = document.getElementById('deposit');

	box.addEventListener('click', function(){
		if (amount.value < amount.min) {
			amount.value = 0;
		}
	});

	withdraw.addEventListener('click', function(){
		if (amount.value <= balance){
			$.post("http://yp_mechanic/withdraw", JSON.stringify({
				value: amount.value
			}));
			resetUi();
		}
	});

	deposit.addEventListener('click', function(){
		$.post("http://yp_mechanic/deposit", JSON.stringify({
			value: amount.value
		}));
		resetUi();
	});


});	