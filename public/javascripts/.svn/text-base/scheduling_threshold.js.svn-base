jQuery(document).ready(function() {
    if(isNaN(jQuery("#language_dropdown_threshold").val())){
        
        disableFields();
    }
    jQuery("#max_assignment").keydown(function(event){allowOnlyNumeric(event);});
    jQuery("#max_grab").keydown(function(event){allowOnlyNumeric(event);});
    jQuery("#hours_prior_to").keydown(function(event){allowOnlyNumeric(event);});

    jQuery("#reset_thresholds").click(function(){
        populateLanguageData(jQuery('option:selected').attr('name'));
    });
    jQuery("#language_dropdown_threshold").change(function(){
       populateLanguageData(jQuery('option:selected').attr('name'));
    });

    jQuery('#threshold_form').submit(function(e){
        if(validateThresholds())
        submitThresholdData(jQuery('option:selected').attr('name'), jQuery(this).serialize());
        e.preventDefault();
    });
});
function allowOnlyNumeric(event) {
        if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 ||
            (event.keyCode >= 35 && event.keyCode <= 39)) {
                 return;
        }
        else {
            if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
                event.preventDefault();
            }
        }
    }
function validateThresholds(){
    errors = "";
    var maxAssignmentValue      = jQuery('#max_assignment').val();
    var maxGrabValue            = jQuery('#max_grab').val();
    var maxHoursPriorToValue    = jQuery('#hours_prior_to').val();
    jQuery('#threshold_error').hide();
    jQuery('#threshold_notice').hide();
    if (jQuery('#max_assignment').val() === '') 
        errors += "* Maximum assignment/week value can't be blank, needs to be a whole number in range of 1 to 50.\n"; 
    else if (isNaN(jQuery('#max_assignment').val()) ||jQuery('#max_assignment').val() < 1 || jQuery('#max_assignment').val() > 50 ||(jQuery('#max_assignment').val()%1) !== 0) 
        errors += "* Maximum assignment/week value needs to be a whole number in range of 1 to 50.\n"; 
    if (jQuery('#max_grab').val() === '') 
        errors += "* Maximum grabbed/week value can't be blank, needs to be a whole number in range of 1 to 30.\n"; 
    else if (isNaN(jQuery('#max_grab').val()) ||jQuery('#max_grab').val() < 1 || jQuery('#max_grab').val() > 30||(jQuery('#max_grab').val()%1)!==0)
        errors += "* Maximum grabbed/week value needs to be a whole number in range of 1 to 30.\n"; 
    if (jQuery('#hours_prior_to').val() === '') 
        errors += "* Hours prior to imminent session override value can't be blank, needs to be a whole number in range of 1 to 12.\n"; 
    else if (isNaN(jQuery('#hours_prior_to').val()) ||jQuery('#hours_prior_to').val() < 1 || jQuery('#hours_prior_to').val() > 12||(jQuery('#hours_prior_to').val()%1)!==0)
        errors += "* Hours prior to imminent session override value needs to be a whole number in range of 1 to 12.\n";
    if (parseInt(maxAssignmentValue,10) < parseInt(maxGrabValue,10))
        errors += "* Maximum assignment/week value cannot be less than Maximum grabbed/week.\n";
    if(errors !== ""){
        errors = "The following problems were encountered :\n\n"+errors;
        alert(errors);
        return false;
    }
    else {
        return true;
    }
}

function submitThresholdData(language_id, data){
    jQuery.ajax({
        url: '/scheduling_thresholds/' + language_id,
        type: 'PUT',
        data:  data,
        success : function(result){
            if(jQuery.isEmptyObject(result)){
                disableFields();
            }else{
                enableFields(result);
                jQuery('#threshold_error').hide();
                jQuery('#threshold_notice').show();
                jQuery('#threshold_notice').html("<li>Threshold values for "+jQuery('option:selected').html()+", updated successfully.</li>");
            }
        },
        error: function(err){
            console.log(err);
            if(err.status === 412){
                error_obj = jQuery.parseJSON(err.responseText).errors;
                error_string = "";
                jQuery.each(error_obj, function() {
                    error_string += '<li>' + this + '</li>';
                });
                jQuery('#threshold_notice').hide();
                jQuery('#threshold_error').show();
                jQuery('#threshold_error').html(error_string);
                

                return;
            }
            alert('Something went wrong. Please try again or report the bug');
        }

    });
    return false;
}

function populateLanguageData(language_id){
    jQuery.ajax({
        url : '/scheduling_thresholds/' + language_id,
        type : 'GET',
        success : function(result){
            if(jQuery.isEmptyObject(result)){
                disableFields();
            }else{
                enableFields(result);
                jQuery('#threshold_notice').hide();
                jQuery('#threshold_error').hide();
            }
        },
        error: function(err){
            alert('Something went wrong. Please try again or report the bug');
        }

    });
}


function enableFields(result){
    jQuery("#submit_threshold").attr('disabled',false);
    jQuery("#reset_thresholds").attr('disabled',false);
    jQuery("#max_assignment").attr('disabled',false);
    jQuery("#max_grab").attr('disabled',false);
    jQuery("#hours_prior_to").attr('disabled',false);
    jQuery("#language_dropdown_threshold").val(result.language_id);
    jQuery("#max_assignment").val(result.max_assignment);
    jQuery("#max_grab").val(result.max_grab);
    jQuery("#hours_prior_to").val(result.hours_prior_to_sesssion_override);
    
}
function disableFields(){
    jQuery("#max_assignment").val('');
    jQuery("#max_grab").val('');
    jQuery("#hours_prior_to").val('');
    jQuery("#submit_threshold").attr('disabled',"disabled");
    jQuery("#reset_thresholds").attr('disabled',"disabled");
    jQuery("#max_assignment").attr('disabled',true);
    jQuery("#max_grab").attr('disabled',true);
    jQuery("#hours_prior_to").attr('disabled',true);
}



