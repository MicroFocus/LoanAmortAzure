/*
 * Copyright (C) Micro Focus 1984-2018. All rights reserved.
 *     
 * This sample code is supplied for demonstration purposes only
 * on an "as is" basis and is for use at your own risk.
 */
$(document).ready(
		function() {
			$("#formApiEndpointInput").val(
					localStorage.getItem("loanCalculatorApiEndpoint"));

			$("#buttonApiEndpointEdit").on(
					"click",
					function(event) {
						event.preventDefault();
						var isEditing = $(this).find('span:first').hasClass(
								"glyphicon-floppy-disk");
						toggleApiEndpointEditing(isEditing);
					});

			enableDisableFormSubmit(false);

			$("#buttonCalculate").on("click", function(event) {
				event.preventDefault();
				calculate();
			});

			$("#formApiEndpointInput").on('input', function(event) {
				event.preventDefault();
				validateApiEndpoint();
				updateCalculateButtonState();
			});

			$("#formPrincipalInput").on('input', function(event) {
				event.preventDefault();
				validatePrincipal();
				updateCalculateButtonState();
			});

			$("#formLoanTermInput").on('input', function(event) {
				event.preventDefault();
				validateLoanTerm();
				updateCalculateButtonState();
			});

			$("#formLoanRateInput").on('input', function(event) {
				event.preventDefault();
				validateLoanRate();
				updateCalculateButtonState();
			});

			$("#amortizationSchedule").on(
					"hide.bs.collapse",
					function() {
						$("#showHideAmortTableLink").text(
								"Show amortization schedule");
					});
			$("#amortizationSchedule").on(
					"show.bs.collapse",
					function() {
						$("#showHideAmortTableLink").text(
								"Hide amortization schedule");
					});
		});

function calculate() {
	var principal = $("#formPrincipalInput").val();
	var loanTerm = $("#formLoanTermInput").val();
	var loanRate = $("#formLoanRateInput").val();

	const params = {
		p : principal,
		t : loanTerm,
		r : loanRate
	}

	enableDisableFormSubmit(false);
	var calculateButtonText = $("#buttonCalculate").text();
	$("#buttonCalculate").text("Calculating...");

	$.getJSON($("#formApiEndpointInput").val(), params).done(function(data) {
		updatePaymentSummary(data);
		renderTable(data.AmortList);
		enableDisableFormSubmit(true);
		$("#buttonCalculate").text(calculateButtonText);
	}).fail(
			function(jqXhr, textStatus, error) {
				alert("Request Failed :  status code: " + jqXhr.status
						+ ", errorThrown: " + error + ", jqXHR.responseText: "
						+ jqXhr.responseText + ", textStatus: " + textStatus);
				$("#buttonCalculate").text(calculateButtonText);
				enableDisableFormSubmit(true);
			});
}

function validateApiEndpoint() {
	var input = $("#formApiEndpointInput");
	var validationResult = validateUrl(input.val());

	validationFeedback(input, validationResult);
	return validationResult;
}

function validatePrincipal() {
	var input = $("#formPrincipalInput");
	var validationResult = validatePositiveInteger(input.val());

	validationFeedback(input, validationResult);

	return validationResult;
}

function validateLoanTerm() {
	var input = $("#formLoanTermInput");
	var validationResult = validatePositiveInteger(input.val());

	if (validationResult === "success"
			&& (input.val() < 0 || input.val() > 480)) {
		validationResult = "error";
	}

	validationFeedback(input, validationResult);

	return validationResult;
}

function validateLoanRate() {
	var input = $("#formLoanRateInput");
	var validationResult = validatePercentage(input.val());
	if (validationResult === "success"
			&& (input.val() <= 0 || input.val() >= 1000)) {
		validationResult = "error";
	}

	validationFeedback(input, validationResult);

	return validationResult;
}

function validatePositiveInteger(value) {
	if (value === null || value === '') {
		return null;
	}
	if (/^([1-9]\d*)$/.test(value)) {
		return 'success';
	} else {
		return 'error';
	}
}

function validatePercentage(value) {
	if (value === null || value === '') {
		return null;
	}
	if (/^\d*\.?\d{1,2}$/.test(value)) {
		return 'success';
	} else {
		return 'error';
	}
}

function validateUrl(value) {
	if (value === null || value === '') {
		return null;
	}
	if (/^(http|https)?:\/\/[a-zA-Z0-9-\.]+/.test(value)) {
		return 'success';
	} else {
		return 'error';
	}
}

function validationFeedback(input, validationResult) {
	var parentForm = input.parent();
	parentForm.removeClass("has-feedback").addClass("has-feedback");

	if (validationResult === "success") {
		parentForm.removeClass("has-error").addClass("has-success");
	} else if (validationResult === "error") {
		parentForm.removeClass("has-success").addClass("has-error");
	} else {
		parentForm.removeClass("has-success").removeClass("has-error");
	}
}

function updateCalculateButtonState() {
	var isValid = $("#formApiEndpointInput").val()
			&& !($("#formApiEndpointInput").parent().hasClass("has-error"))
			&& $("#formPrincipalInput").val()
			&& !($("#formPrincipalInput").parent().hasClass("has-error"))
			&& $("#formLoanTermInput").val()
			&& !($("#formLoanTermInput").parent().hasClass("has-error"))
			&& $("#formLoanRateInput").val()
			&& !($("#formLoanRateInput").parent().hasClass("has-error"));

	enableDisableFormSubmit(isValid);
}

function enableDisableFormSubmit(doEnable) {
	if (doEnable) {
		$("#buttonCalculate").removeAttr("disabled");
	} else {
		$("#buttonCalculate").attr("disabled", "true");
	}
}

function updatePaymentSummary(data) {
	var currency = "$"
	var payment = data.AmortList[0].Payment.trim();
	if (payment.indexOf(currency) >= 0) {
		payment = payment.substring(1, payment.length);
	}

	$("#currency").text(currency);
	$("#montlyPayment").text(payment);
	$("#totalInterestPaid").text(data.TotalInterest);
	$("#totalPrincipalPaid").text("N/A");
}

function renderTable(tableData) {

	var table = $('<table></table>').addClass(
			"table table-striped table-bordered");
	if (tableData) {
		var th = $('<th></th>');
		var tr = $('<tr></tr>');
		var td = $('<td></td>');

		var header = tr.clone()
		var columnHeaders = Object.keys(tableData[0]);
		columnHeaders.map(function(h) {
			header.append(th.clone().attr("key", h).text(h))
		});
		table.append($('<thead></thead>').append(header));

		var tbody = $('<tbody></tbody>');
		var rowId = 0;
		tableData.map(function(dataRow) {
			var row = tr.clone() // creates a row
			Object.keys(dataRow).map(
					function(dataCol) {
						row.append(td.clone().attr("key", dataCol + rowId)
								.text(dataRow[dataCol]));
					})
			tbody.append(row) // puts row on the tbody
			rowId++;
		});
		table.append(tbody);
	}
	$("#amortizationSchedule").empty().append(table);
}

function toggleApiEndpointEditing(isEditing) {
	var formApiEndpointInput = $("#formApiEndpointInput");
	if (isEditing) {
		localStorage.setItem("loanCalculatorApiEndpoint", formApiEndpointInput
				.val());
		formApiEndpointInput.attr("readonly", true);
	} else {
		formApiEndpointInput.attr("readonly", false);
		formApiEndpointInput.select();
	}
	$("#buttonApiEndpointEditGlyphIcon").toggleClass(
			'glyphicon-pencil glyphicon-floppy-disk');
}
