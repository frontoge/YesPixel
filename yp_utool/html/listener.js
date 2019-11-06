$(function(){
	var items = document.getElementsByClassName("itembox");
	var plusButtons = new Array();
	var minusButtons = new Array();
	var amounts = new Array();
	var repairCost = 85;
	var screwCost = 10;
	var pliersCost = 10;
	var flareCost = 15;
	var total = 0;
	var costDisplay = document.getElementById("total");

	function updatetotal(){
		var totalCost = 0;
		for (var x = 0; x < amounts.length; x++){
			if (Number(amounts[x].value) > Number(amounts[x].max)){amounts[x].value = amounts[x].max};
			if (Number(amounts[x].value) < Number(amounts[x].min)){amounts[x].value = amounts[x].min};
		}
		totalCost += repairCost * Number(amounts[0].value);
		totalCost += flareCost * Number(amounts[1].value);
		totalCost += screwCost * Number(amounts[2].value);
		totalCost += pliersCost * Number(amounts[3].value);
		costDisplay.innerHTML = "Total: $" + totalCost;
		total = totalCost;
	}


	function display(bool) {
    	if (bool == true) {
     		$('#container').show();
    	} else {
      		$('#container').hide();
    	}
  	}

  	function resetUI(){
  		var nextFrame = document.getElementById("checkoutframe");
		container.style.display = "block";
		nextFrame.style.display = "none";
		total = 0;
		var totalDisplay = document.getElementById('total');
		totalDisplay.innerHTML = "Total: $0";
		for (var i = 0; i < amounts.length; i++){
			amounts[i].value = 0;
		}
  	}

  display(false);

  for (var x = 0; x < items.length; x++) {
		plusButtons[x] = items[x].querySelector("#plusbutton");
		minusButtons[x] = items[x].querySelector('#minusbutton');
		amounts[x] = items[x].querySelector("#count");
	}

	var container = document.getElementById("frame");
	container.addEventListener('click', function(){
		updatetotal();
	})

	var checkout = document.getElementById("checkout");
	checkout.addEventListener('click', function(){
		if (total != 0){
			var nextFrame = document.getElementById("checkoutframe");
			container.style.display = "none";
			nextFrame.style.display = "block";
			var totalDisplay = document.getElementById('totaldisplay');
			totaldisplay.innerHTML = "Total: $" + total;
		}
	});

    window.addEventListener('message', function(event) {
    	var item = event.data;
    	if (item.type === "enableui") {
      		if (item.enable === true) {
        		display(true);
      		} else {
        		display(false);
      		}
    	}
  	});

  	document.onkeyup = function(e) {
    	if (e.key == "Escape" || e.which == 27) {
      		display(false);
      		$.post("http://yp_utool/exit", JSON.stringify({}));
      		resetUI();
    	}
  	};

  	var cashBox = document.getElementById('cashbox');
  	cashbox.addEventListener('click', function(){
  		display(false);
  		$.post("http://yp_utool/buyWithCash", JSON.stringify({
  			total: total,
  			repairs: Number(amounts[0].value),
  			flares: Number(amounts[1].value),
  			screws: Number(amounts[2].value),
  			pliers: Number(amounts[3].value)
  			}));
  		resetUI();
  		$.post("http://yp_utool/exit", JSON.stringify({}));
 	});

 	var cardBox = document.getElementById('cardbox');
  	cardbox.addEventListener('click', function(){
  		display(false);
  		$.post("http://yp_utool/buyWithCard", JSON.stringify({
  			total: total,
  			repairs: Number(amounts[0].value),
  			flares: Number(amounts[1].value),
  			screws: Number(amounts[2].value),
  			pliers: Number(amounts[3].value)
  			}));
  		resetUI();
  		$.post("http://yp_utool/exit", JSON.stringify({}));
 	});

	plusButtons[0].addEventListener('click', function(){
		if (Number(amounts[0].value) != amounts[0].max) {
			amounts[0].value = Number(amounts[0].value) + 1;
		}
	});

	plusButtons[1].addEventListener('click', function(){
		if (Number(amounts[1].value) != amounts[1].max) {
			amounts[1].value = Number(amounts[1].value) + 1;
		}
	});

	plusButtons[2].addEventListener('click', function(){ 
		if (Number(amounts[2].value) != amounts[2].max) {
			amounts[2].value = Number(amounts[2].value) + 1;
		}
	});

	plusButtons[3].addEventListener('click', function(){
		if (Number(amounts[3].value) != amounts[3].max) {
			amounts[3].value = Number(amounts[3].value) + 1;
		}
	});

	minusButtons[0].addEventListener('click', function(){
		if (Number(amounts[0].value) != amounts[0].min) {
			amounts[0].value = Number(amounts[0].value) - 1;
		}
	});

	minusButtons[1].addEventListener('click', function(){
		if (Number(amounts[1].value) != amounts[1].min) {
			amounts[1].value = Number(amounts[1].value) - 1;
		}
	});

	minusButtons[2].addEventListener('click', function(){ 
		if (Number(amounts[2].value) != amounts[2].min) {
			amounts[2].value = Number(amounts[2].value) - 1;
		}
	});

	minusButtons[3].addEventListener('click', function(){
		if (Number(amounts[3].value) != amounts[3].min) {
			amounts[3].value = Number(amounts[3].value) - 1;
		}
	});
});