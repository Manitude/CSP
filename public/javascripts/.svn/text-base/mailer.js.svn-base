jQuery(document).ready(function () {

    jQuery("#all_languages").live("change",function(){
        populateEmailAddress(jQuery('#all_languages').val());
    });

    jQuery("#cancel_mail_button").live("click",function(){
        jQuery('#facebox').fadeOut();
    });

    jQuery('#send_mail_button').live('click',function(){
        var flag = true;
        var result = jQuery('#to').val().split(",");
        if (jQuery('#to').val() === ""){
            alert ("To address cannot be empty");
            flag = false;
        }else if (jQuery('#body').val() === ""){
            alert ("Message cannot be empty");
            flag = false;
        }else if (jQuery('#subject').val() === ""){
            alert ("Please provide a subject");
            flag = false;
        }else{
            jQuery.each(result, function(i, email){
                if (!validateEmail(email)) {
                    alert('Please check : "' + email + '" is not valid! Provide valid email addresses separated by comma.');
                    flag = false;
                }
            });
        }
        if(flag)jQuery('form#send_mail_to_coaches').submit();
    });

});

function populateEmailAddress(language_id){
    jQuery.ajax({
        url : '/fetch_mail_address/' + language_id,
        success : function(result){
            jQuery("#to").val(result);
        },
        error: function(err){
            alert('Something went wrong. Please try again or report the bug');
        }

    });
}

function validateEmail(field) {
    return (/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,5}$/.test(field));
}



 
