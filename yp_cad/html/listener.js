$(function() {
	var job;
	var logedin = false;
	var currentPage = '#login_page';

	function display(bool) {
		if (bool == true) {
			$('#container').show();
			if (!logedin) {
				var loginPage = $('#login_page');
				loginPage.fadeIn(2000);
			}
		} else {
			$('#container').hide();
		}
	}

	function setLoginName(name) {
		document.getElementById('username').value = name;
	}

	function login() {
		logedin = true;
		$('#login_page').hide();

		if (job != 'police') {
			$('#warrants_button').hide();
			$('#bolos_button').hide();
			$('#reports_button').hide();
		}else {
			$('#warrants_button').show();
			$('#bolos_button').show();
			$('#reports_button').show();
		}
		$('#nav').fadeIn(500);

		goRecords();
	}

	function swapPage(dest) {
		if (currentPage != dest) {
			$(currentPage).hide();
			currentPage = dest;
			$(currentPage).fadeIn(500);
		}
	}

	function goHome() {
		$('#nav').hide();
		swapPage('#login_page');
	}

	function goRecords() {
		swapPage('#public_page');
	}

	function goWarrants() {}

	function goBolos() {}

	function goReports() {
		swapPage('#reports_page');
	}

	display(false);

	window.addEventListener('message', function(event) {
		var item = event.data;
		if (item.type == 'ui') {
			if (item.enable === true) {
				display(true);
				job = item.job;
				setLoginName(item.name);
			}
		}
	});

	document.onkeyup = function(e) {
		if (e.key == "Escape" || e.which == 27) {
			display(false);
			if (!logedin) {
				$('#login_page').hide();
			}
			$.post("http://yp_cad/exit", JSON.stringify({}));
		}
	};

	document.getElementById('login_button').addEventListener('click', login);

	//Start nav bar listeners
	document.getElementById('home_button').addEventListener('click', goHome);
	document.getElementById('records_button').addEventListener('click', goRecords);
	document.getElementById('warrants_button').addEventListener('click', goWarrants);
	document.getElementById('bolos_button').addEventListener('click', goBolos);
	document.getElementById('reports_button').addEventListener('click', goReports);


});