$(function(){

	var loaded = false;
	var itemData;
	var price = 0;

	function display(state) {
		if (state) {
			$('#container').show();
		}else {
			$('#container').hide();
		}
	}

	function clearDocument() {
		price = 0;
		
		const keys = Object.keys(itemData);
		for (const key of keys) {
			$('#' + key + " > #count").val('0');
		}
	}

	function updatePrice() {
		price = 0;
		const keys = Object.keys(itemData);
		for (const key of keys) {
			price += parseInt($("#" + key + " > #count").val()) * itemData[key]['price'];
		}
		$('#price').html('Total: $' + price);
	}

	function loadLimits() {
		const keys = Object.keys(itemData);
		for (const key of keys) {
			$('#' + key + " > #count").val('0');

			$('#' + key + " > #count").on('input', function(){
				var value = parseInt($('#' + key + " > #count").val());
				if (value < 0) { //if the input value is less than 0 set to 0
					$('#' + key + " > #count").val('0');
				} else if(value > itemData[key]['limit']) { //if the input value is higher than the limit set to max
					$('#' + key + " > #count").val('' + itemData[key]['limit']);
				}
				updatePrice();
			});

			$('#' + key + " > #decrease").on('click', function(){
				var value = parseInt($('#' + key + " > #count").val()) - 1;
				if (value <= 0) {
					value = '0'
				} 
				$('#' + key + ' > #count').val('' + value);
				updatePrice();
			})

			$('#' + key + " > #increase").on('click', function(){
				var value = parseInt($('#' + key + " > #count").val()) + 1;
				if (value > itemData[key]['limit']) {
					value = itemData[key]['limit']
				} 
				$('#' + key + ' > #count').val('' + value);
				updatePrice();
			})
		}
	}

	$('#clear').on('click', clearDocument);

	$('#payCash').on('click', function() {
		var items = new Object();
		const keys = Object.keys(itemData);
		for (const key of keys) {
			items[key] = parseInt($('#' + key + " > #count").val());
			
		}
		if (price) {
			$.post('http://yp_utool/checkoutCash', JSON.stringify(items));
		}
	});

	$('#payCard').on('click', function() {
		var items = new Object();
		const keys = Object.keys(itemData);
		for (const key of keys) {
			items[key] = parseInt($('#' + key + " > #count").val());
		}
		if (price) {
			$.post('http://yp_utool/checkoutCard', JSON.stringify(items));
		}
	});

	window.addEventListener('message', function(event) {
		var item = event.data;
		if (item.type == 'enable') {
			display(true);
			itemData = item.items;
			if (!loaded) {
				loadLimits();
				loaded = true;
			}
		}else if (item.type == 'clear') {
			clearDocument();
		}
	});

	document.onkeyup = function(e) {
		if (e.key == "Escape" || e.which == 27) {
			display(false);
			$.post("http://yp_utool/exit", JSON.stringify({}));
		}
	};
});