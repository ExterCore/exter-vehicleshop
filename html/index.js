const formatter = new Intl.NumberFormat('en-US');
showroomOpen = false;
showroomMenuOpen = false;
selectedCategory = null;
vehicles = {};
currentVeh = null;
currentColor = null;
currentVehLabel = null;
currentPrice = null;
currentCategoryVehs = [];
currentCategoryVehs2 = [];
currentPaymentType = null;
selectedSpot = null;
selectedSpotVehicle = null;
showroomVehicles = [];
addStockVehicles = [];
currentDealershipId = null;
sellMenuOpen = false;
managementState = false;
inputOpen = false;
currentShowroomMenu = null;
useCustomImg = false;
currentSellModel = null;
currentSellPrice = 0;
currency = "$";
currentSellType = null;
window.addEventListener('message', function(event) {
    ed = event.data;
    if (ed.action === "openDealership") {
		currency = ed.currency;
		useCustomImg = ed.customImg;
		currentDealershipId = ed.dealershipId;
		managementState = ed.managementState;
		document.getElementById("MDSPaymentDivBottomPayButton1").style.display = "none";
		document.getElementById("MDSPaymentDivBottomPayButton2").style.display = "none";
		currentCategoryVehs = [];
		currentCategoryVehs2 = [];
		currentVeh = null;
		selectedCategory = null;
		showroomOpen = true;
		document.getElementById("mainDiv").style.display = "flex";
		document.getElementById("mainDivBottomCenterDiv").innerHTML="";
		vehicles = ed.vehicles;
		document.getElementById("MDSCategoriesDivInside").innerHTML="";
		ed.categories.forEach(function(categoryData, index) {
			let size = 3.5;
			if (categoryData.name === "cycles" || categoryData.name === "motorcycles") {
				size = 2.5;
			}
			var categoryHTML = `<div class="MDSCategoryDiv" id="MDSCategoryDiv-${categoryData.name}" onclick="clFunc('showCategoryVehicles', '${categoryData.name}')"><img src="files/${categoryData.name}.png" style="width: ${size}vw;"><span>${categoryData.label}</span></div>`;
			appendHtml(document.getElementById("MDSCategoriesDivInside"), categoryHTML);
			if (!selectedCategory) {
				selectedCategory = categoryData.name;
				clFunc('showCategoryVehicles', selectedCategory)
			}
		});
	} else if (ed.action === "closeUI") {
		showroomOpen = false;
		document.getElementById("mainDiv").style.display = "none";
		document.getElementById("confirmDiv").style.display = "none";
	} else if (ed.action === "updateCarInformations") {
		// Acceleration
		document.getElementById("MDSSpecificationDivTopRight-acceleration").innerHTML=parseInt(ed.acceleration);
		document.getElementById("MDSSpecificationDivBottomInside-acceleration").style.width = ed.acceleration;
		document.getElementById("MDSSpecificationDivBottomLine-acceleration").style.left = ed.acceleration;
		// Speed
		document.getElementById("MDSSpecificationDivTopRight-speed").innerHTML=parseInt(ed.speed);
		document.getElementById("MDSSpecificationDivBottomInside-speed").style.width = ed.speed / 2;
		document.getElementById("MDSSpecificationDivBottomLine-speed").style.left = ed.speed / 2;
		// Braking
		let brake = ed.brake * 100;
		if (brake >= 100) {
			document.getElementById("MDSSpecificationDivTopRight-brake").innerHTML=brake.toFixed(0);
			document.getElementById("MDSSpecificationDivBottomInside-brake").style.width = "99%";
			document.getElementById("MDSSpecificationDivBottomLine-brake").style.left = "99%";
		} else {
			document.getElementById("MDSSpecificationDivTopRight-brake").innerHTML=brake.toFixed(0);
			document.getElementById("MDSSpecificationDivBottomInside-brake").style.width = brake + "%";
			document.getElementById("MDSSpecificationDivBottomLine-brake").style.left = brake + "%";
		}
	} else if (ed.action === "startTestTimer") {
		$("#testDriveDivProgbar").stop().css({width: '100%'}).animate({
			width: "0%",
		}, ed.testDriveTime, 'linear', function() {});
		document.getElementById("testDriveDiv").style.display = "flex";
		var timer = ed.testDriveTime / 1000, minutes, seconds;
		timerInt = setInterval(function() {
			minutes = parseInt(timer / 60, 10);
			seconds = parseInt(timer % 60, 10);
			minutes = minutes < 10 ? "0" + minutes : minutes;
			seconds = seconds < 10 ? "0" + seconds : seconds;
			document.getElementById("testDriveTimer").innerHTML=minutes.toString() + ":" + seconds.toString();
			if (--timer < 0) {
				clearInterval(timerInt);
				document.getElementById("testDriveTimer").innerHTML="00:00";
				document.getElementById("testDriveDiv").style.display = "none";
				var xhr = new XMLHttpRequest();
				xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
				xhr.setRequestHeader('Content-Type', 'application/json');
				xhr.send(JSON.stringify({action: "finishTest"}));
			}
		}, 1000);
	} else if (ed.action === "stopTestTimer") {
		clearInterval(timerInt);
		document.getElementById("testDriveTimer").innerHTML="00:00";
		document.getElementById("testDriveDiv").style.display = "none";
	} if (ed.action === "openShowroomMenu") {
		currentDealershipId = ed.dealershipId;
		document.getElementById("showroomDivTopInput").value="";
		document.getElementById("showroomDiv").style.display = "flex";
		showroomMenuOpen = true;
		selectedSpotVehicle = null;
		selectedSpot = null;
		// Spots
		document.getElementById("showroomDivBottomLeft").innerHTML="";
		ed.spots.forEach(function(spotData, index) {
			var spotHTML = `<div class="showroomDivBottomLeftDiv" id="showroomDivBottomLeftDiv-${spotData.id}" onclick="clFunc('selectSpot', '${spotData.id}')"><i class="fas fa-street-view"></i><span>Spot #${spotData.id}</span></div>`;
			appendHtml(document.getElementById("showroomDivBottomLeft"), spotHTML);
			if (!selectedSpot) {
				clFunc('selectSpot', spotData.id)
			}
		});
		// Vehicles
		document.getElementById("showroomDivBottomRight").innerHTML="";
		ed.vehicles.forEach(function(vehicleData, index) {
			checkIfImageExists(`https://docs.fivem.net/vehicles/${vehicleData.model}.webp`, (exists) => {
				if (exists) {
					var spotVehicleHTML = `
					<div id="showroomDivBottomRightDiv">
						<div id="showroomDivBottomRightDivTop">
							<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
							<img src="https://docs.fivem.net/vehicles/${vehicleData.model}.webp" loading="lazy">
						</div>
						<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('selectSpotVehicle', '${vehicleData.model}')"><span>Display</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
					</div>`;
					appendHtml(document.getElementById("showroomDivBottomRight"), spotVehicleHTML);
				} else {
					if (useCustomImg) {
						var spotVehicleHTML = `
						<div id="showroomDivBottomRightDiv">
							<div id="showroomDivBottomRightDivTop">
								<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
								<img src="customcars/${vehicleData.model}.png" loading="lazy">
							</div>
							<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('selectSpotVehicle', '${vehicleData.model}')"><span>Display</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
						</div>`;
						appendHtml(document.getElementById("showroomDivBottomRight"), spotVehicleHTML);
					} else {
						var spotVehicleHTML = `
						<div id="showroomDivBottomRightDiv">
							<div id="showroomDivBottomRightDivTop">
								<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
								<img src="files/car.png" loading="lazy">
							</div>
							<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('selectSpotVehicle', '${vehicleData.model}')"><span>Display</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
						</div>`;
						appendHtml(document.getElementById("showroomDivBottomRight"), spotVehicleHTML);
					}
				}
			});
		});
		showroomVehicles = [...new Set(ed.vehicles.map((vehicle) => {return vehicle}))];
	} else if (ed.action === "openSellMenu") {
		sellMenuOpen = true;
		currentDealershipId = ed.dealershipId;
		document.getElementById("showroomDivTopInput2").value="";
		document.getElementById("sellVehicleDiv").style.display = "flex";
		selectedSpotVehicle = null;
		selectedSpot = null;
		document.getElementById("showroomDivBottomRight2").scrollTop = 0;
		document.getElementById("showroomDivBottomRight3").scrollTop = 0;
		document.getElementById("showroomDivBottomRight2").innerHTML="";
		currentShowroomMenu = "showAllVehiclesToRequest";
		if (ed.sellBtnActive) {
			ed.vehicles.forEach(function(vehicleData, index) {
				if (vehicleData.stock >= 1) {
					let stockText = `${vehicleData.stock}x Stock`;
					let stockClass = "MDBCDVehicleDivTopRightSide-21";
					if (vehicleData.stock === 0 || vehicleData.stock === undefined) {
						stockText = "Out of Stock";
						stockClass = "MDBCDVehicleDivTopRightSide-22";
					}
					checkIfImageExists(`https://docs.fivem.net/vehicles/${vehicleData.model}.webp`, (exists) => {
						if (exists) {
							var spotVehicleHTML2 = `
							<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${vehicleData.name}">
								<div id="showroomDivBottomRightDivTop">
									<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
									<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
									<img src="https://docs.fivem.net/vehicles/${vehicleData.model}.webp" loading="lazy">
								</div>
								<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('selectSellVehicle', '${vehicleData.model}', '${vehicleData.price}')" oncontextmenu="clFunc('selectSellVehicle', '${vehicleData.model}', '${vehicleData.price}', 'myself')" style="gap: 0.2vw;"><span>Send Request</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
							</div>`;
							appendHtml(document.getElementById("showroomDivBottomRight2"), spotVehicleHTML2);
						} else {
							if (useCustomImg) {
								var spotVehicleHTML2 = `
								<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${vehicleData.name}">
									<div id="showroomDivBottomRightDivTop">
										<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
										<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
										<img src="customcars/${vehicleData.model}.webp" loading="lazy">
									</div>
									<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('selectSellVehicle', '${vehicleData.model}', '${vehicleData.price}')" oncontextmenu="clFunc('selectSellVehicle', '${vehicleData.model}', '${vehicleData.price}', 'myself')" style="gap: 0.2vw;"><span>Send Request</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
								</div>`;
								appendHtml(document.getElementById("showroomDivBottomRight2"), spotVehicleHTML2);
							} else {
								var spotVehicleHTML2 = `
								<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${vehicleData.name}">
									<div id="showroomDivBottomRightDivTop">
										<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
										<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
										<img src="files/car.png" loading="lazy">
									</div>
									<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('selectSellVehicle', '${vehicleData.model}', '${vehicleData.price}')" oncontextmenu="clFunc('selectSellVehicle', '${vehicleData.model}', '${vehicleData.price}', 'myself')" style="gap: 0.2vw;"><span>Send Request</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
								</div>`;
								appendHtml(document.getElementById("showroomDivBottomRight2"), spotVehicleHTML2);
							}
						}
					});
				}
			});
		}
		document.getElementById("showroomDivBottomRight2").style.display = "flex";
		document.getElementById("showroomDivBottomLeft2").innerHTML="";
		if (ed.sellBtnActive) {
			appendHtml(document.getElementById("showroomDivBottomLeft2"), `<div class="showroomDivBottomLeftDiv showroomDivBottomLeftDivActive" onclick="clFunc('showAllVehiclesToRequest')" id="showroomDivBottomLeftDiv-AddStockAll"><i class="fas fa-street-view"></i><span>Sell</span></div>`);
		}
		if (ed.showAddStockBtn === true) {
			var showroomVehiclesCategories = `
			<div class="showroomDivBottomLeftDiv" onclick="clFunc('addStockForAllVehiclesDialog')"><i class="fas fa-street-view"></i><span>Add Stock For All Vehicles</span></div>
			<div class="showroomDivBottomLeftDiv" id="showroomDivBottomLeftDiv-AddStock" onclick="clFunc('showAllVehiclesToAddStock')"><i class="fas fa-street-view"></i><span>Add Stock</span></div>
			`;
			appendHtml(document.getElementById("showroomDivBottomLeft2"), showroomVehiclesCategories);
			document.getElementById("showroomDivBottomRight3").innerHTML="";
			document.getElementById("showroomDivBottomRight3").style.display = "none";
			ed.vehicles2.forEach(function(vehicleData, index) {
				let stockText = `${vehicleData.stock}x Stock`;
				let stockClass = "MDBCDVehicleDivTopRightSide-21";
				if (vehicleData.stock === 0 || vehicleData.stock === undefined) {
					stockText = "Out of Stock";
					stockClass = "MDBCDVehicleDivTopRightSide-22";
				}
				checkIfImageExists(`https://docs.fivem.net/vehicles/${vehicleData.model}.webp`, (exists) => {
					if (exists) {
						var spotVehicleHTML3 = `
						<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${vehicleData.name}">
							<div id="showroomDivBottomRightDivTop">
								<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
								<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
								<img src="https://docs.fivem.net/vehicles/${vehicleData.model}.webp" loading="lazy">
							</div>
							<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('addStockToVeh', '${vehicleData.name}', '${vehicleData.model}')" style="gap: 0.2vw;"><span>Add Stock</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
						</div>`;
						appendHtml(document.getElementById("showroomDivBottomRight3"), spotVehicleHTML3);
					} else {
						if (useCustomImg) {
							var spotVehicleHTML3 = `
							<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${vehicleData.name}">
								<div id="showroomDivBottomRightDivTop">
									<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
									<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
									<img src="customcars/${vehicleData.model}.png" loading="lazy">
								</div>
								<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('addStockToVeh', '${vehicleData.name}', '${vehicleData.model}')" style="gap: 0.2vw;"><span>Add Stock</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
							</div>`;
							appendHtml(document.getElementById("showroomDivBottomRight3"), spotVehicleHTML3);
						} else {
							var spotVehicleHTML3 = `
							<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${vehicleData.name}">
								<div id="showroomDivBottomRightDivTop">
									<div id="showroomDivBottomRightDivTopTextDiv"><span>${vehicleData.name}</span></div>
									<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
									<img src="files/car.png" loading="lazy">
								</div>
								<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${vehicleData.model}" onclick="clFunc('addStockToVeh', '${vehicleData.name}', '${vehicleData.model}')" style="gap: 0.2vw;"><span>Add Stock</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
							</div>`;
							appendHtml(document.getElementById("showroomDivBottomRight3"), spotVehicleHTML3);
						}
					}
				});
			});
		}
		showroomVehicles = [...new Set(ed.vehicles.map((vehicle) => {return vehicle}))];
		addStockVehicles = [...new Set(ed.vehicles2.map((vehicle) => {return vehicle}))];
	}
    document.onkeyup = function(data) {
		if (data.which == 27 && showroomOpen) {
			showroomOpen = false;
			showroomMenuOpen = false;
			document.getElementById("showroomDiv").style.display = "none";
			document.getElementById("mainDiv").style.display = "none";
			document.getElementById("confirmDiv").style.display = "none";
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "close", type: "showroom"}));
		}
		if (data.which == 27 && showroomMenuOpen) {
			showroomMenuOpen = false;
			document.getElementById("showroomDiv").style.display = "none";
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "close", type: "showroomEdit", dealershipId: currentDealershipId}));
		}
		if (data.which == 27 && sellMenuOpen) {
			sellMenuOpen = false;
			document.getElementById("sellVehicleDiv").style.display = "none";
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "close", type: "sellMenu"}));
		}
		if (data.which == 27 && inputOpen) {
			inputOpen = false;
			document.getElementById("inputDiv").style.display = "none";
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "close", type: "another"}));
		}
		// if (data.which == 87 && showroomOpen) {
		// 	var xhr = new XMLHttpRequest();
		// 	xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		// 	xhr.setRequestHeader('Content-Type', 'application/json');
		// 	xhr.send(JSON.stringify({action: "camUp"}));
		// }
		// if (data.which == 83 && showroomOpen) {
		// 	var xhr = new XMLHttpRequest();
		// 	xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		// 	xhr.setRequestHeader('Content-Type', 'application/json');
		// 	xhr.send(JSON.stringify({action: "camDown"}));
		// }
		if (data.which == 65 && showroomOpen) {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "camLeft"}));
		}
		if (data.which == 68 && showroomOpen) {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "camRight"}));
		}
		if (data.which == 81 && showroomOpen) {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "zoomOut"}));
		}
		if (data.which == 69 && showroomOpen) {
			var xhr = new XMLHttpRequest();
			xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
			xhr.setRequestHeader('Content-Type', 'application/json');
			xhr.send(JSON.stringify({action: "zoomIn"}));
		}
	}
})

function clFunc(name1, name2, name3, name4, name5, name6) {
	if (name1 === "showCategoryVehicles") {
		currentCategoryVehs = [];
		if (selectedCategory) {
			document.getElementById("MDSCategoryDiv-" + selectedCategory).classList.remove("MDSCategoryDivActive");
		}
		currentVeh = null;
		selectedCategory = name2;
		document.getElementById("MDSCategoryDiv-" + name2).classList.add("MDSCategoryDivActive");
		// Insert Vehicles
		document.getElementById("mainDivBottomCenterDiv").innerHTML="";
		vehicles.forEach(function(vehData, index) {
			if (vehData.category === name2 && typeof vehData.stock == "number") {
				let firstLetter = vehData.model.charAt(0);
				let firstLetterCap = firstLetter.toUpperCase();
				let remainingLetters = vehData.model.slice(1);
				let vLabel = vehData.brand + " " + firstLetterCap + remainingLetters;
				let stockText = "In Stock";
				let stockClass = "MDBCDVehicleDivTopRightSide1";
				if (vehData.stock === 0 || vehData.stock === undefined) {
					stockText = "Out of Stock";
					stockClass = "MDBCDVehicleDivTopRightSide2";
				}
				checkIfImageExists(`https://docs.fivem.net/vehicles/${vehData.model}.webp`, (exists) => {
					if (exists) {
						var vehiclesHTML = `
						<div class="MDBCDVehicleDiv" id="MDBCDVehicleDiv-${vehData.spawncode}" onclick="clFunc('chooseVeh', '${vehData.spawncode}', '${vehData.categoryLabel}', '${vehData.price}', '${vLabel}', '${vehData.stock}')">
							<div id="MDBCDVehicleDivTop">
								<div id="MDBCDVehicleDivTopLeftSide">
									<h4>${vehData.brand} ${vehData.model}</h4>
									<span style="font-family: Gilroy-Regular; color: rgba(255, 255, 255, 0.45); font-size: 0.8vw;">${vehData.categoryLabel}</span>
								</div>
								<div class="MDBCDVehicleDivTopRightSide ${stockClass}"><span>${stockText}</span></div>
							</div>
							<img src="https://docs.fivem.net/vehicles/${vehData.model}.webp" style="width: auto; height: 80px;" loading="lazy">
							<div id="MDBCDVehicleDivBottom">
								<div class="MDBCDVehicleDivTopRightSide" style="bottom: 0; color: rgba(144, 255, 215, 0.77); text-shadow: 0px 0px 4.8px rgba(144, 255, 215, 0.55);"><span>${currency}${vehData.price}</span></div>
							</div>
						</div>`;
						appendHtml(document.getElementById("mainDivBottomCenterDiv"), vehiclesHTML);
						if (!currentVeh) {
							currentVeh = vehData.spawncode;
							clFunc('chooseVeh', currentVeh, vehData.categoryLabel, vehData.price, vLabel, vehData.stock)
						}
					} else {
						if (useCustomImg) {
							var vehiclesHTML = `
							<div class="MDBCDVehicleDiv" id="MDBCDVehicleDiv-${vehData.spawncode}" onclick="clFunc('chooseVeh', '${vehData.spawncode}', '${vehData.categoryLabel}', '${vehData.price}', '${vLabel}', '${vehData.stock}')">
								<div id="MDBCDVehicleDivTop">
									<div id="MDBCDVehicleDivTopLeftSide">
										<h4>${vehData.brand} ${vehData.model}</h4>
										<span style="font-family: Gilroy-Regular; color: rgba(255, 255, 255, 0.45); font-size: 0.8vw;">${vehData.categoryLabel}</span>
									</div>
									<div class="MDBCDVehicleDivTopRightSide ${stockClass}"><span>${stockText}</span></div>
								</div>
								<img src="customcars/${vehData.model}.png" style="width: auto; height: 80px;" loading="lazy">
								<div id="MDBCDVehicleDivBottom">
									<div class="MDBCDVehicleDivTopRightSide" style="bottom: 0; color: rgba(144, 255, 215, 0.77); text-shadow: 0px 0px 4.8px rgba(144, 255, 215, 0.55);"><span>${currency}${vehData.price}</span></div>
								</div>
							</div>`;
							appendHtml(document.getElementById("mainDivBottomCenterDiv"), vehiclesHTML);
							if (!currentVeh) {
								currentVeh = vehData.spawncode;
								clFunc('chooseVeh', currentVeh, vehData.categoryLabel, vehData.price, vLabel, vehData.stock)
							}
						} else {
							var vehiclesHTML = `
							<div class="MDBCDVehicleDiv" id="MDBCDVehicleDiv-${vehData.spawncode}" onclick="clFunc('chooseVeh', '${vehData.spawncode}', '${vehData.categoryLabel}', '${vehData.price}', '${vLabel}', '${vehData.stock}')">
								<div id="MDBCDVehicleDivTop">
									<div id="MDBCDVehicleDivTopLeftSide">
										<h4>${vehData.brand} ${vehData.model}</h4>
										<span style="font-family: Gilroy-Regular; color: rgba(255, 255, 255, 0.45); font-size: 0.8vw;">${vehData.categoryLabel}</span>
									</div>
									<div class="MDBCDVehicleDivTopRightSide ${stockClass}"><span>${stockText}</span></div>
								</div>
								<img src="files/car.png" style="width: auto; height: 80px;" loading="lazy">
								<div id="MDBCDVehicleDivBottom">
									<div class="MDBCDVehicleDivTopRightSide" style="bottom: 0; color: rgba(144, 255, 215, 0.77); text-shadow: 0px 0px 4.8px rgba(144, 255, 215, 0.55);"><span>${currency}${vehData.price}</span></div>
								</div>
							</div>`;
							appendHtml(document.getElementById("mainDivBottomCenterDiv"), vehiclesHTML);
							if (!currentVeh) {
								currentVeh = vehData.spawncode;
								clFunc('chooseVeh', currentVeh, vehData.categoryLabel, vehData.price, vLabel, vehData.stock)
							}
						}
					}
				});
				// setTimeout(() => {
				// 	if (!currentVeh) {
				// 		currentVeh = vehData.spawncode;
				// 		clFunc('chooseVeh', currentVeh, vehData.categoryLabel, vehData.price, vLabel, vehData.stock)
				// 	}
				// }, 500);
				currentCategoryVehs.push({
					spawncode: vehData.spawncode,
					brand: vehData.brand,
					model: vehData.model,
					categoryLabel: vehData.categoryLabel,
					price: vehData.price,
					vLabel: vLabel,
					stock: vehData.stock
				});
			}
		});
		currentCategoryVehs22 = [...new Set(currentCategoryVehs.map((vehicle) => {return vehicle}))];
		document.getElementById("mainDivBottomCenterDiv").scrollLeft = 0;
	} else if (name1 === "chooseVeh") {
		if (currentVeh) {
			if (document.getElementById("MDBCDVehicleDiv-" + currentVeh)) {
				document.getElementById("MDBCDVehicleDiv-" + currentVeh).classList.remove("MDBCDVehicleDivActive");
			}
		}
		document.getElementById("confirmDiv").style.display = "none";
		currentVehLabel = name5;
		currentVeh = name2;
		document.getElementById("MDBCDVehicleDiv-" + currentVeh).classList.add("MDBCDVehicleDivActive");
		document.getElementById("vehPrice").innerHTML=currency + formatter.format(Number(name4));
		currentPrice = currency + formatter.format(Number(name4));
		// document.getElementById("vehClass").innerHTML=name3.charAt(0);
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "chooseVeh", veh: name2}));
		document.getElementById("MDSCarLabelDiv").innerHTML=name2;
		if (currentColor) {
			document.querySelector("#MDSCCDColorDiv-" + currentColor).classList.remove("MDSCCDColorDivActive");
			currentColor = null;
		}
		let stock = Number(name6);
		if (managementState === false) {
			if (stock >= 1) {
				document.getElementById("MDSPaymentDivBottomPayButton1").style.display = "flex";
				document.getElementById("MDSPaymentDivBottomPayButton2").style.display = "flex";
			} else {
				document.getElementById("MDSPaymentDivBottomPayButton1").style.display = "none";
				document.getElementById("MDSPaymentDivBottomPayButton2").style.display = "none";
			}
		}
	} else if (name1 === "changeVehColor") {
		if (currentColor) {
			document.querySelector("#MDSCCDColorDiv-" + currentColor).classList.remove("MDSCCDColorDivActive");
		}
		currentColor = Number(name4);
		document.querySelector("#MDSCCDColorDiv-" + currentColor).classList.add("MDSCCDColorDivActive");
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "changeVehColor", r: Number(name2), g: Number(name3), b: Number(name4)}));
	} else if (name1 === "scrollLeft") {
		document.getElementById("mainDivBottomCenterDiv").scrollLeft -= 35;
	} else if (name1 === "scrollRight") {
		document.getElementById("mainDivBottomCenterDiv").scrollLeft += 35;
	} else if (name1 === "startTestDrive") {
		showroomOpen = false;
		document.getElementById("mainDiv").style.display = "none";
		document.getElementById("confirmDiv").style.display = "none";
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "close", type: "showroom", test: true, model: currentVeh}));
	} else if (name1 === "buyVeh") {
		document.getElementById("confirmDivButton1").setAttribute('onclick', "clFunc('cancelPurchase')");
		document.getElementById("confirmDivButton2").setAttribute('onclick', "clFunc('confirmPurchase')");
		currentPaymentType = name2;
		$("#confirmDiv").fadeIn().css({display: 'flex'});
		document.getElementById("confirmDivH4").innerHTML=`PURCHASE ${currentPrice}`;
		let currencyText = "dollars";
		if (currency === "£") {
			currencyText = "pounds";
		} else if (currency === "€") {
			currencyText = "euros";
		}
		document.getElementById("confirmSpan").innerHTML=`Are you authorizing payment via ${name2} for the purchase of the ${currentVehLabel} model vehicle for ${currentPrice} ${currencyText}? Please confirm with 'Yes' or 'No'.`;
	} else if (name1 === "cancelPurchase") {
		$("#confirmDiv").fadeOut().css({display: 'flex'});
	} else if (name1 === "confirmPurchase") {
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "confirmPurchase", model: currentVeh, paymentType: currentPaymentType, dealershipId: currentDealershipId}));
	} else if (name1 === "selectSpot") {
		if (selectedSpot) {
			document.getElementById("showroomDivBottomLeftDiv-" + selectedSpot).classList.remove("showroomDivBottomLeftDivActive");
		}
		selectedSpot = name2;
		document.getElementById("showroomDivBottomLeftDiv-" + name2).classList.add("showroomDivBottomLeftDivActive");
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "createSpotCam", dealershipId: currentDealershipId, spotId: selectedSpot}));
	} else if (name1 === "selectSpotVehicle") {
		if (selectedSpotVehicle) {
			if (document.getElementById("showroomDivBottomRightDivBottom-" + selectedSpotVehicle)) {
				document.getElementById("showroomDivBottomRightDivBottom-" + selectedSpotVehicle).classList.remove("showroomDivBottomRightDivBottomActive");
			}
		}
		selectedSpotVehicle = name2;
		document.getElementById("showroomDivBottomRightDivBottom-" + name2).classList.add("showroomDivBottomRightDivBottomActive");
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "updateShowroomVehicle", model: selectedSpotVehicle, dealershipId: currentDealershipId, spotId: Number(selectedSpot)}));
	} else if (name1 === "selectSellVehicle") {
		sellMenuOpen = false;
		document.getElementById("sellVehicleDiv").style.display = "none";
		$("#confirmDiv2").fadeIn().css({display: 'flex'});
		currentSellModel = name2;
		currentSellPrice = Number(name3);
		currentSellType = name4;
		// var xhr = new XMLHttpRequest();
		// xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		// xhr.setRequestHeader('Content-Type', 'application/json');
		// xhr.send(JSON.stringify({action: "createTextsOnPlayers", dealershipId: currentDealershipId, model: name2, price: Number(name3)}));
	} else if (name1 === "openChooseColorMenu") {
		document.getElementById("confirmDiv2").style.display = "none";
		document.getElementById("mainDivSides2").style.display = "flex";
		document.getElementById("MDSCarLabelDiv2").innerHTML=currentSellModel;
	} else if (name1 === "chooseSellVehColor") {
		document.getElementById("mainDivSides2").style.display = "none";
		let color = {};
		color.r = Number(name2);
		color.g = Number(name3);
		color.b = Number(name4);
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "createTextsOnPlayers", dealershipId: currentDealershipId, model: currentSellModel, price: currentSellPrice, color: color, currentSellType: currentSellType}));
	} else if (name1 === "randomColor") {
		document.getElementById("confirmDiv2").style.display = "none";
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "createTextsOnPlayers", dealershipId: currentDealershipId, model: currentSellModel, price: currentSellPrice, color: "random", currentSellType: currentSellType}));
	} else if (name1 === "addStockForAllVehiclesDialog") {
		sellMenuOpen = false;
		document.getElementById("sellVehicleDiv").style.display = "none";
		document.getElementById("inputDiv").style.display = "flex";
		inputOpen = true;
		document.getElementById("CDDDivButton").setAttribute("onclick", "clFunc('openStockConfirm')");
	} else if (name1 === "openStockConfirm") {
		let stockNum = document.getElementById("CDDDivType1RightInput-StockNum");
		if (!Number(stockNum.value)) {
			stockNum.focus();
			return;
		}
		document.getElementById("inputDiv").style.display = "none";
		inputOpen = false;
		$("#confirmDiv").fadeIn().css({display: 'flex'});
		document.getElementById("confirmDivH4").innerHTML=`Do you want to do this?`;
		document.getElementById("confirmSpan").innerHTML=`If you approve this transaction now, ${stockNum.value} units will be added to the stock of all vehicles in this dealer ship.`;
		document.getElementById("confirmDivButton1").setAttribute('onclick', "clFunc('cancelStockTransaction')");
		document.getElementById("confirmDivButton2").setAttribute('onclick', `clFunc('acceptStockTransaction', '${stockNum.value}')`);
	} else if (name1 === "cancelStockTransaction") {
		sellMenuOpen = true;
		document.getElementById("sellVehicleDiv").style.display = "flex";
		document.getElementById("confirmDiv").style.display = "none";
	} else if (name1 === "acceptStockTransaction") {
		sellMenuOpen = false;
		document.getElementById("sellVehicleDiv").style.display = "none";
		document.getElementById("confirmDiv").style.display = "none";
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "addStockForAllVehicles", dealershipId: currentDealershipId, addStockNum: Number(name2)}));
		currentDealershipId = null;
	} else if (name1 === "addStockToVeh") {
		sellMenuOpen = false;
		document.getElementById("sellVehicleDiv").style.display = "none";
		document.getElementById("inputDiv").style.display = "flex";
		inputOpen = true;
		document.getElementById("CDDDivButton").setAttribute("onclick", `clFunc('openStockConfirm2', '${name2}', '${name3}')`);
	} else if (name1 === "openStockConfirm2") {
		let stockNum = document.getElementById("CDDDivType1RightInput-StockNum");
		if (!Number(stockNum.value)) {
			stockNum.focus();
			return;
		}
		document.getElementById("inputDiv").style.display = "none";
		inputOpen = false;
		$("#confirmDiv").fadeIn().css({display: 'flex'});
		document.getElementById("confirmDivH4").innerHTML=`Do you want to do this?`;
		document.getElementById("confirmSpan").innerHTML=`If you approve this transaction now, ${stockNum.value} units will be added to the stock of ${name2} vehicle in this dealer ship.`;
		document.getElementById("confirmDivButton1").setAttribute('onclick', "clFunc('cancelStockTransaction')");
		document.getElementById("confirmDivButton2").setAttribute('onclick', `clFunc('acceptStockTransaction2', '${stockNum.value}', '${name3}')`);
	} else if (name1 === "acceptStockTransaction2") {
		sellMenuOpen = false;
		document.getElementById("sellVehicleDiv").style.display = "none";
		document.getElementById("confirmDiv").style.display = "none";
		var xhr = new XMLHttpRequest();
		xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({action: "addStockForSpecificVehicle", dealershipId: currentDealershipId, model: name3, addStockNum: Number(name2)}));
		currentDealershipId = null;
	} else if (name1 === "showAllVehiclesToAddStock") {
		currentShowroomMenu = "showAllVehiclesToAddStock";
		document.getElementById("showroomDivBottomLeftDiv-AddStock").classList.add("showroomDivBottomLeftDivActive");
		if (document.getElementById("showroomDivBottomLeftDiv-AddStockAll")) {
			document.getElementById("showroomDivBottomLeftDiv-AddStockAll").classList.remove("showroomDivBottomLeftDivActive");
		}
		document.getElementById("showroomDivBottomRight2").style.display = "none";
		document.getElementById("showroomDivBottomRight3").style.display = "flex";
	} else if (name1 === "showAllVehiclesToRequest") {
		currentShowroomMenu = "showAllVehiclesToRequest";
		document.getElementById("showroomDivBottomLeftDiv-AddStock").classList.remove("showroomDivBottomLeftDivActive");
		if (document.getElementById("showroomDivBottomLeftDiv-AddStockAll")) {
			document.getElementById("showroomDivBottomLeftDiv-AddStockAll").classList.add("showroomDivBottomLeftDivActive");
		}
		document.getElementById("showroomDivBottomRight2").style.display = "flex";
		document.getElementById("showroomDivBottomRight3").style.display = "none";
	}
}

document.getElementById("mainDivBottomCenterDiv").addEventListener("wheel", event => {
	var delta = event.deltaY / 2.5;
    var scrollLeft = document.getElementById("mainDivBottomCenterDiv").scrollLeft;
	document.getElementById("mainDivBottomCenterDiv").scrollLeft = scrollLeft + delta;
    event.preventDefault();
});

document.getElementById("MDBSearchInput").addEventListener('input', (e) => {
	const searchData = e.target.value.toLowerCase();
	const filterData = currentCategoryVehs22.filter((vehicle) => {
		return (vehicle.brand.toLocaleLowerCase().includes(searchData) || vehicle.model.toLocaleLowerCase().includes(searchData))
	});
	displayDealershipVehicle(filterData);
});

const displayDealershipVehicle = (vehicles) => {
	document.getElementById("mainDivBottomCenterDiv").innerHTML = vehicles.map((vehicle) => {
		var {spawncode, brand, model, categoryLabel, stock, price, vLabel} = vehicle;
		let divClass = "";
		if (currentVeh === spawncode) {
			divClass = "MDBCDVehicleDivActive";
		}
		let stockText = "In Stock";
		let stockClass = "MDBCDVehicleDivTopRightSide1";
		if (stock === 0 || stock === undefined) {
			stockText = "Out of Stock";
			stockClass = "MDBCDVehicleDivTopRightSide2";
		}
		document.getElementById("mainDivBottomCenterDiv").innerHTML="";
		document.getElementById("mainDivBottomCenterDiv").scrollLeft = 0;
		let existsImg = false;
		checkIfImageExists(`https://docs.fivem.net/vehicles/${model}.webp`, (exists) => {
			existsImg = exists;
		});
		if (existsImg) {
			return (
				`<div class="MDBCDVehicleDiv ${divClass}" id="MDBCDVehicleDiv-${spawncode}" onclick="clFunc('chooseVeh', '${spawncode}', '${categoryLabel}', '${price}', '${vLabel}', '${stock}')">
					<div id="MDBCDVehicleDivTop">
						<div id="MDBCDVehicleDivTopLeftSide">
							<h4>${brand} ${model}</h4>
							<span style="font-family: Gilroy-Regular; color: rgba(255, 255, 255, 0.45); font-size: 0.8vw;">${categoryLabel}</span>
						</div>
						<div class="MDBCDVehicleDivTopRightSide ${stockClass}"><span>${stockText}</span></div>
					</div>
					<img src="https://docs.fivem.net/vehicles/${model}.webp" style="width: 150px; height: 90px;" loading="lazy">
					<div id="MDBCDVehicleDivBottom">
						<div class="MDBCDVehicleDivTopRightSide" style="color: rgba(144, 255, 215, 0.77); text-shadow: 0px 0px 4.8px rgba(144, 255, 215, 0.55);"><span>${currency}${price}</span></div>
					</div>
				</div>`
			)
		} else {
			if (useCustomImg) {
				return (
					`<div class="MDBCDVehicleDiv ${divClass}" id="MDBCDVehicleDiv-${spawncode}" onclick="clFunc('chooseVeh', '${spawncode}', '${categoryLabel}', '${price}', '${vLabel}', '${stock}')">
						<div id="MDBCDVehicleDivTop">
							<div id="MDBCDVehicleDivTopLeftSide">
								<h4>${brand} ${model}</h4>
								<span style="font-family: Gilroy-Regular; color: rgba(255, 255, 255, 0.45); font-size: 0.8vw;">${categoryLabel}</span>
							</div>
							<div class="MDBCDVehicleDivTopRightSide ${stockClass}"><span>${stockText}</span></div>
						</div>
						<img src="customcars/${model}.png" style="width: 150px; height: 90px;" loading="lazy">
						<div id="MDBCDVehicleDivBottom">
							<div class="MDBCDVehicleDivTopRightSide" style="color: rgba(144, 255, 215, 0.77); text-shadow: 0px 0px 4.8px rgba(144, 255, 215, 0.55);"><span>${currency}${price}</span></div>
						</div>
					</div>`
				)
			} else {
				return (
					`<div class="MDBCDVehicleDiv ${divClass}" id="MDBCDVehicleDiv-${spawncode}" onclick="clFunc('chooseVeh', '${spawncode}', '${categoryLabel}', '${price}', '${vLabel}', '${stock}')">
						<div id="MDBCDVehicleDivTop">
							<div id="MDBCDVehicleDivTopLeftSide">
								<h4>${brand} ${model}</h4>
								<span style="font-family: Gilroy-Regular; color: rgba(255, 255, 255, 0.45); font-size: 0.8vw;">${categoryLabel}</span>
							</div>
							<div class="MDBCDVehicleDivTopRightSide ${stockClass}"><span>${stockText}</span></div>
						</div>
						<img src="files/car.png" style="width: 150px; height: 90px;" loading="lazy">
						<div id="MDBCDVehicleDivBottom">
							<div class="MDBCDVehicleDivTopRightSide" style="color: rgba(144, 255, 215, 0.77); text-shadow: 0px 0px 4.8px rgba(144, 255, 215, 0.55);"><span>${currency}${price}</span></div>
						</div>
					</div>`
				)
			}
		}
	}).join('');
}

function appendHtml(el, str) {
	var div = document.createElement('div');
	div.innerHTML = str;
	while (div.children.length > 0) {
		el.appendChild(div.children[0]);
	}
}

document.getElementById("mainDivCenter").addEventListener("wheel", zoom, { passive: false });
function zoom(event) {
	event.preventDefault();
	var xhr = new XMLHttpRequest();
	xhr.open("POST", `https://${GetParentResourceName()}/callback`, true);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.send(JSON.stringify({action: "nuiFocusEvent"}));
}

document.getElementById("showroomDivTopInput").addEventListener('input', (e) => {
	const searchData = e.target.value.toLowerCase();
	const filterData = showroomVehicles.filter((vehicle) => {
		return (vehicle.name.toLocaleLowerCase().includes(searchData))
	});
	displayShowroomVehicle(filterData);
});

const displayShowroomVehicle = (vehicles) => {
	document.getElementById("showroomDivBottomRight").innerHTML = vehicles.map((vehicle) => {
		var {name, model} = vehicle;
		let divClass = "";
		if (selectedSpotVehicle === model) {
			divClass = "showroomDivBottomRightDivBottomActive";
		}
		let existsImg = false;
		checkIfImageExists(`https://docs.fivem.net/vehicles/${model}.webp`, (exists) => {
			existsImg = exists;
		});
		if (existsImg) {
			return (
				`<div id="showroomDivBottomRightDiv">
					<div id="showroomDivBottomRightDivTop">
						<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
						<img src="https://docs.fivem.net/vehicles/${model}.webp" loading="lazy">
					</div>
					<div class="showroomDivBottomRightDivBottom ${divClass}" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('selectSpotVehicle', '${model}')"><span>Display</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
				</div>`
			)
		} else {
			if (useCustomImg) {
				return (
					`<div id="showroomDivBottomRightDiv">
						<div id="showroomDivBottomRightDivTop">
							<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
							<img src="customcars/${model}.png" loading="lazy">
						</div>
						<div class="showroomDivBottomRightDivBottom ${divClass}" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('selectSpotVehicle', '${model}')"><span>Display</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
					</div>`
				)
			} else {
				return (
					`<div id="showroomDivBottomRightDiv">
						<div id="showroomDivBottomRightDivTop">
							<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
							<img src="files/car.png" loading="lazy">
						</div>
						<div class="showroomDivBottomRightDivBottom ${divClass}" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('selectSpotVehicle', '${model}')"><span>Display</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
					</div>`
				)
			}
		}
	}).join('');
}

document.getElementById("showroomDivTopInput2").addEventListener('input', (e) => {
	const searchData = e.target.value.toLowerCase();
	if (currentShowroomMenu === "showAllVehiclesToAddStock") {
		const filterData = addStockVehicles.filter((vehicle) => {
			return (vehicle.name.toLocaleLowerCase().includes(searchData))
		});
		displayShowroomVehicle2(filterData);
	} else {
		const filterData = showroomVehicles.filter((vehicle) => {
			return (vehicle.name.toLocaleLowerCase().includes(searchData))
		});
		displayShowroomVehicle2(filterData);
	}
});

const displayShowroomVehicle2 = (vehicles) => {
	if (currentShowroomMenu === "showAllVehiclesToAddStock") {
		document.getElementById("showroomDivBottomRight3").innerHTML = vehicles.map((vehicle) => {
			var {name, model, price, stock} = vehicle;
			let stockText = `${stock}x Stock`;
			let stockClass = "MDBCDVehicleDivTopRightSide-21";
			if (stock === 0 || stock === undefined) {
				stockText = "Out of Stock";
				stockClass = "MDBCDVehicleDivTopRightSide-22";
			}
			let existsImg = false;
			checkIfImageExists(`https://docs.fivem.net/vehicles/${model}.webp`, (exists) => {
				existsImg = exists;
			});
			if (existsImg) {
				return (`
				<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${name}">
					<div id="showroomDivBottomRightDivTop">
						<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
						<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
						<img src="https://docs.fivem.net/vehicles/${model}.webp" loading="lazy">
					</div>
					<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('addStockToVeh', '${name}', '${model}')" style="gap: 0.2vw;"><span>Add Stock</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
				</div>`)
			} else {
				if (useCustomImg) {
					return (`
					<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${name}">
						<div id="showroomDivBottomRightDivTop">
							<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
							<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
							<img src="customcars/${model}.png" loading="lazy">
						</div>
						<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('addStockToVeh', '${name}', '${model}')" style="gap: 0.2vw;"><span>Add Stock</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
					</div>`)
				} else {
					return (`
					<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${name}">
						<div id="showroomDivBottomRightDivTop">
							<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
							<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
							<img src="files/car.png" loading="lazy">
						</div>
						<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('addStockToVeh', '${name}', '${model}')" style="gap: 0.2vw;"><span>Add Stock</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
					</div>`)
				}
			}
		}).join('');
	} else {
		document.getElementById("showroomDivBottomRight2").innerHTML = vehicles.map((vehicle) => {
			var {name, model, price, stock} = vehicle;
			let stockText = "In Stock";
			let stockClass = "MDBCDVehicleDivTopRightSide-21";
			if (stock === 0 || stock === undefined) {
				stockText = "Out of Stock";
				stockClass = "MDBCDVehicleDivTopRightSide-22";
			} else if (stock === 1) {
				stockText = "1 Stock";
			}
			let existsImg = false;
			checkIfImageExists(`https://docs.fivem.net/vehicles/${model}.webp`, (exists) => {
				existsImg = exists;
			});
			if (existsImg) {
				return (
					`<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${name}">
						<div id="showroomDivBottomRightDivTop">
							<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
							<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
							<img src="https://docs.fivem.net/vehicles/${model}.webp" loading="lazy">
						</div>
						<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('selectSellVehicle', '${model}', '${price}')" oncontextmenu="clFunc('selectSellVehicle', '${model}', '${price}', 'myself')" style="gap: 0.2vw;"><span>Send Request</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
					</div>`
				)
			} else {
				if (useCustomImg) {
					return (
						`<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${name}">
							<div id="showroomDivBottomRightDivTop">
								<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
								<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
								<img src="customcars/${model}.png" loading="lazy">
							</div>
							<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('selectSellVehicle', '${model}', '${price}')" oncontextmenu="clFunc('selectSellVehicle', '${model}', '${price}', 'myself')" style="gap: 0.2vw;"><span>Send Request</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
						</div>`
					)
				} else {
					return (
						`<div class="showroomDivBottomRightDiv" id="showroomDivBottomRightDiv-${name}">
							<div id="showroomDivBottomRightDivTop">
								<div id="showroomDivBottomRightDivTopTextDiv"><span>${name}</span></div>
								<div class="MDBCDVehicleDivTopRightSide-2 ${stockClass}"><span>${stockText}</span></div>
								<img src="files/car.png" loading="lazy">
							</div>
							<div class="showroomDivBottomRightDivBottom" id="showroomDivBottomRightDivBottom-${model}" onclick="clFunc('selectSellVehicle', '${model}', '${price}')" oncontextmenu="clFunc('selectSellVehicle', '${model}', '${price}', 'myself')" style="gap: 0.2vw;"><span>Send Request</span><div id="showroomDivBottomRightDivBottomChevrons"><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i><i class="fal fa-chevron-right"></i></div></div>
						</div>`
					)
				}
			}
		}).join('');
	}
}

function checkIfImageExists(url, callback) {
	const img = new Image();
	img.src = url;
	if (img.complete) {
		callback(true);
	} else {
		img.onload = () => {
			callback(true);
		};
		img.onerror = () => {
			callback(false);
		};
	}
}