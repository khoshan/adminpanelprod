$(document).ready(function(){
		doValidation();
	});

	function doValidation(){

		$("input.phone").mask("(999) 999-9999");
		$("input.zip").mask("99999");

		try{
			$( ".datepicker" ).datepicker({
				dateFormat: 'yy-mm-dd',
				showOn: "button",
					buttonImage: "calendar.gif",
					buttonImageOnly: true,
				onClose: function(){
					this.focus();
				}
			});
		}
		catch(err){
		}
	}


