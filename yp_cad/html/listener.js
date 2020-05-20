$(function() {
	
	//Game Statuses
	var logedin = false;
	var currentPage = '#login_page';
	var reportsTab;

	//UI Elements
	
	var chargeList = $('#reports_charges');

	//Game Data
	var lawbook;
	var trafficLaws;
	var criminalLaws;
	var job;

	var suggestions;

	//Report data
	var months = 0;
	var serviceM = 0;
	var fine = 0;
	var target = undefined;
	var charges = {};

	

	//UI Functions
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

	//Login Functions
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

	//Report functions
	//gets the html for a charge in the lawbook
	function loadLaw(index) {
		var retString = '<li class="reports_charge_item"><p class="charge_name">'; //{sentence} Months</button></li>
		var item = lawbook[index];
		retString += item['code'] + ' ' + item['name'] + '</p><button id="charge' + index + '" class=';

		if (item['code'][0] == '1' || item['code'][0] == '2' || item['code'][0] == '3') { //If its not felony
			retString += '"charge_miss_button">';
		} else {
			retString += '"charge_felony_button">';
		}

		if (item['type'] == 'death') {
			retString += 'DEATH</button></li>';
		} else if(item['type'] == 'fine') {
			retString += '$' + item['sentence'] + ' Fine</button></li>';
		} else if(item['type'] == 'jail') {
			retString += item['sentence'] + ' Months</button></li>';
		} else if(item['type'] == 'service') {
			retString += item['sentence'] + ' Months Service</button></li>';
		}

		return retString;
	}

	function updateSentence(){
		$('#reports_charges_list').html('$' + fine + ' fine ' + serviceM + ' Months Service ' + months + ' Months');
	}

	function setReports(reportPage) {
		$(reportsTab).hide();
		reportsTab = reportPage;
		$(reportPage).show();
		chargeList.empty();
		
		if (reportPage == '#reports_traffic_head') {
			for (let i = 0; i < lawbook['length']; i++) {
				if (lawbook[i]['code'][0] == '1') {
					chargeList.append(loadLaw(i))//.attr('id', 'charge' + toString(i));
				}
			}
		}
		else {
			for (let i = 0; i < lawbook['length']; i++) {
				if (lawbook[i]['code'][0] != '1') {
					chargeList.append(loadLaw(i))//.attr('id', 'charge' + toString(i));
				}
			}
		}

		for (let i = 0; i < lawbook['length']; i++) {
			$('#charge' + i).on('click', function(){
				if (lawbook[i]['type'] == 'fine') {
					fine += lawbook[i]['sentence'];
				}else if (lawbook[i]['type'] == 'jail') {
					months += lawbook[i]['sentence'];
				}else if (lawbook[i]['type'] == 'service') {
					serviceM += lawbook[i]['sentence'];
				}

				if (charges[lawbook[i]['code']] == undefined || charges[lawbook[i]['code']] == 0) {
					charges[lawbook[i]['code']] = 1;
					$('#reports_results_record').append('<li id="selectedcharge' + i + '" class="reports_results_r_item">' + lawbook[i]['name'] + ' x' + charges[lawbook[i]['code']] + '</li>');
				}
				else {
					charges[lawbook[i]['code']] += 1
					$('#selectedcharge' + i).html(lawbook[i]['name'] + ' x ' + charges[lawbook[i]['code']]);
				}
				$('#selectedcharge' + i).click(function(e){
					$(this).remove();
					if (lawbook[i]['type'] == 'fine') {
						fine -= lawbook[i]['sentence'] * charges[lawbook[i]['code']];
					}else if (lawbook[i]['type'] == 'jail') {
						months -= lawbook[i]['sentence'] * charges[lawbook[i]['code']];
					}else if (lawbook[i]['type'] == 'service') {
						serviceM -= lawbook[i]['sentence'] * charges[lawbook[i]['code']];
					}
					charges[lawbook[i]['code']] = 0;
					updateSentence();
				})
				updateSentence();
			});
		}
	}

	function submitReport() {
		if (target != undefined && Object.keys(charges).length > 0) {
			$.post('http://yp_cad/fileReport', JSON.stringify({target: target, charges: JSON.stringify(charges)}));
			const keys = Object.keys(charges);
			for (const key of keys){
				charges[key] = 0;
			}
			target = undefined;
			fine = 0;
			months = 0;
			serviceM = 0;

			$('#reports_r_name').html('Name: ');
			$('#reports_r_dob').html('DOB: ');
			$('#reports_r_sex').html('Sex: ');
			$('#reports_r_dmv').html('DMV points: ');
			$('#reports_r_felon').html('Felon: ');
			$('#reports_results_record').empty();
			$('#reports_suggestions_list').empty();
			updateSentence();
		}
	}
	

	//Public Records Functions
	function searchPublicRecords(type) {
		var searchBar;
		if (type == 'public'){
			searchBar = document.getElementById('pr_searchbar');
		} else if (type == 'arrest'){
			searchBar = document.getElementById('reports_search_input');
		}
		$.post('http://yp_cad/searchRecords', JSON.stringify({name: searchBar.value, type: type}));
	}

	function displayRecords(data, type) {
		var felon = data['felon'] ? 'Yes' : 'No';
		var record = undefined;
		if (data['record'] != undefined) {
			record = JSON.parse(data['record']);
		}
		if (type == 'public') {
			//load at public records page
			$('#pr_r_record_list').empty();
			$('#pr_r_name').html('Name: ' + data['firstname'] + ' ' + data['lastname']);
			$('#pr_r_dob').html('DOB: ' + data['dateofbirth']);
			$('#pr_r_sex').html('Sex: ' + data['sex']);
			$('#pr_r_dmv').html('DMV points: ' + data['dmv']);
			$('#pr_r_felon').html('Felon: ' + felon);

			if (record != undefined){
				const keys = Object.keys(record);
				for (const key of keys) {
					if (record[key] != 0) {
						for (var i = 0; i < lawbook['length']; i++) {
							if (lawbook[i]['code'] == key) {
								$('#pr_r_record_list').append("<li class='pr_r_record_item'><p class='pr_r_record_item_label'>" + lawbook[i]['name'] + ' x' + record[key] + "</p></li>");
							}
						}
					}
				}
			} else {
				$('#pr_r_record_list').append("<li class='pr_r_record_item'><p class='pr_r_record_item_label'>" + lawbook[i]['name'] + ' x' + record[key] + "</p></li>");
			}

		}else if (type == 'arrest') {
			//load at arrest reports section
			$('#reports_r_name').html('Name: ' + data['firstname'] + ' ' + data['lastname']);
			$('#reports_r_dob').html('DOB: ' + data['dateofbirth']);
			$('#reports_r_sex').html('Sex: ' + data['sex']);
			$('#reports_r_dmv').html('DMV points: ' + data['dmv']);
			$('#reports_r_felon').html('Felon: ' + felon);
			target = data['identifier'];
		}
	}

	function displaySuggestions(data, type) {
		suggestions = data;
		var list;
		if (type == 'public') {
			list = $('#pr_suggestions_list');
			list.empty();
			const keys = Object.keys(data);
			for (const key of keys) { //Go through each member in the data
				var html = "<li id='pr_suggestion_" + key + "' class='pr_suggestion'><p class='pr_suggestion_label'>" + data[key].firstname + " " + data[key].lastname + "</p></li>";
				list.append(html);
				$('#pr_suggestion_' + key).on('click', function(){
					displayRecords(data[key], type);
				});
			}
		}else if (type == 'arrest') {
			list = $('#reports_suggestions_list');
			list.empty();
			const keys = Object.keys(data);
			for (const key of keys) { //Go through each member in the data
				var html = "<li id='reports_suggestion_" + key + "' class='reports_suggestion'><p class='reports_suggestion_label'>" + data[key].firstname + " " + data[key].lastname + "</p></li>";
				list.append(html);
				$('#reports_suggestion_' + key).on('click', function(){
					displayRecords(data[key], type);
				});
			}
		}
	}

	

/*****************
* Nav Bar functions
*******************/
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
		$('#pr_r_name').html('Name: ');
		$('#pr_r_dob').html('DOB: ');
		$('#pr_r_sex').html('Sex: ');
		$('#pr_r_dmv').html('DMV points: ');
		$('#pr_r_felon').html('Felon: ');
		$('#pr_r_record_list').empty();
		$('#pr_suggestions_list').empty();
		swapPage('#public_page');
	}

	function goWarrants() {}

	function goBolos() {}

	function goReports() {
		if (!lawbook) {
			$.post("http://yp_cad/getLaws", JSON.stringify({}));
		}
		swapPage('#reports_page');
	}

	/*
	* Callback listeners
	*/

	display(false);

	window.addEventListener('message', function(event) {
		var item = event.data;
		if (item.type == 'ui') {
			if (item.enable === true) {
				display(true);
				job = item.job;
				setLoginName(item.name);
			}
		}else if(item.type == 'laws'){
			lawbook = item.laws;
			lawbook['length'] = item.size;
			reportsTab = '#reports_arrest_head';
			setReports('#reports_arrest_head');
		}else if(item.type == 'records') {
			displaySuggestions(item.results, item.category);
			//displayRecords(item.results, item.category);
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

	//Login Listeners
	document.getElementById('login_button').addEventListener('click', login);

	//Start nav bar listeners
	document.getElementById('home_button').addEventListener('click', goHome);
	document.getElementById('records_button').addEventListener('click', goRecords);
	document.getElementById('warrants_button').addEventListener('click', goWarrants);
	document.getElementById('bolos_button').addEventListener('click', goBolos);
	document.getElementById('reports_button').addEventListener('click', goReports);

	//Public Record Page listeners
	document.getElementById('pr_searchbutton').addEventListener('click', function(){
		searchPublicRecords('public');
	});

	document.getElementById('reports_searchbutton').addEventListener('click', function(){
		searchPublicRecords('arrest');
	});

	//Report Page Listeners
	document.getElementById('reports_traffic_button').addEventListener('click', function() {
		setReports('#reports_traffic_head');
	});
	document.getElementById('reports_arrest_button').addEventListener('click', function() {
		setReports('#reports_arrest_head');
	});

	$('#reports_submit').on('click', submitReport);

	


});