jQuery(document).ready(function(){

    // if cookie exists, delete it and check if alert is active, if yes then raise alert with lightbox effect
    var cookieValue = getCook('emergency_alert');
    if (cookieValue === 'show_alert') {
        delete_cookie('emergency_alert');
        // check if alert is active
        jQuery.ajax({
                url: '/alert_is_active',
                success: function(result){
                    if (result === 'true'){
                        jQuery.blockUI();
                        $(".blockMsg").css("display", "none");
                        fixedFaceBoxWithHeader("/coach_alert?scenario=after_login","Coach Alert");
                        $("#facebox_header").css({'padding-left':'176px','color': '#FF0000'});
                       $(".close_image").bind( "click", function(event) {
                            jQuery.unblockUI();
                            jQuery(document).trigger('close.facebox');
                            event.stopPropagation();
                        });
                    }
                },
                failure: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                },
                error: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                }
            });
    }

    jQuery('.marker').mouseenter(function(){
        var title=jQuery(this).parent().next().text();
        var guid =jQuery(this).attr('id');
        if(title.length === 0) title = guid;
        constructQtipWithTip(this, title, '/learner_details?license_guid='+guid, {
            width: '1000px'
        });
    });

    jQuery('.reason_popup').live('mouseenter', function(){
      var sub_id = jQuery(this).attr('id');
      constructQtipWithTip(this,"REASON FOR THIS SUBSTITUTION",'/show_reason_in_sub_report?id='+sub_id,{  width: '1000px'});
    });
    jQuery('.reason_popup').live('mouseleave', function(){
         jQuery('.qtip').remove();
    });

    if(jQuery('#next-session-alert').length > 0){
        fetchNextSeesionTime();
    }
   
    
    jQuery('img#next_session_load_image').live('click', function(){
        constructQtipWithTip(this, 'NEXT SESSION/APPOINTMENT DETAILS', '/get-next-session-details', {});
    });

    jQuery('img#print_button').live('click', function(){
        var w = window.open();
        w.document.write($("#"+jQuery(this).attr("print_element_id")).html());
        w.print();
    });

    jQuery('.notification_form').live('change', function(){
        filterNotifications();
    });

    jQuery('.approve_timeoff').live('click', function(){
        approve_timeoff(jQuery(this));
    });
    
    jQuery('a#live_help').live('click', function(){
        initiateChat(this);
    });

    jQuery('a#on_duty_list').live('click', function(){
        fixedFaceBoxWithHeader("/on_duty_list","Studio Team On Duty");
          });
    jQuery('a#coach_manager_alert').live('click', function(){
        fixedFaceBoxWithHeader("/coach_alert","Manage Coach Alert");
        $("#facebox_header").css({'padding-left':'150px','color': '#000000'});
    });

    jQuery('a#coach_alert').live('click', function(){
        fixedFaceBoxWithHeader("/coach_alert","Coach Alert");
        $("#facebox_header").css({'padding-left':'176px','color': '#FF0000'});
    });


    jQuery('.appointment_type_active').live('click', function(){
        updateAppointmentTypeActive(this);
    });

    jQuery('#save_appointment_type').live('click',function(){
        saveAppointmentTypeTitle();
    });
    jQuery('#appointment_type_submit').live('click',function(e){
        saveAppointmentType(e);
    });


    jQuery('#publish_alert').live('click', function(){
        var val = $.trim($("#coach_alert_message").val());
            jQuery.ajax({
                url: '/publish_coach_alert',
                data: {
                    description: val
                },
                success: function(){
                    $("#alert_icon").show();
                    jQuery(document).trigger('close.facebox');
                },
                failure: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                },
                error: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                }
            });
    });

    jQuery('#remove_alert').live('click', function(){
            jQuery.ajax({
                url: '/remove_coach_alert',
                success: function(){
                    $("#alert_icon").fadeOut();
                    $("#coach_alert_message").val('');
                    jQuery(document).trigger('close.facebox');
                },
                failure: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                },
                error: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                }
            });
    });

    jQuery('#read_it_alert').live('click', function(){
        jQuery(document).trigger('close.facebox');
        jQuery.unblockUI();
    });
       jQuery('#language_category').live('change',function(){
        jQuery("#language").attr("disabled",true);
        jQuery.ajax({
                url: '/fetch_languages',
                data: {
                    category: jQuery("#language_category").val()
                },
                success: function(result) {
                    jQuery("#language").html(result);
                    jQuery("#language").attr("disabled",false);
                    if ("Michelin".localeCompare(jQuery("#language_category").val())===0)
                        jQuery("#language").change();
                },
                failure: function(error){
                    console.log(error);
                    alert('Something went wrong, Please report this problem.');
                },
                error: function(error){
                    console.log(error);
                    alert('Something went wrong, Please report this problem.');
                }
            });

    });
    
    jQuery('a#edit_on_duty_list').live('click', function(){
        jQuery('#facebox_header').html("Edit Studio Team On Duty");
        jQuery('#on_duty_list_div').hide();
        jQuery('#edit_on_duty_list_div').show();
         });

    jQuery('a#save_on_duty_message').live('click', function(){
            jQuery.ajax({
                url: '/save_on_duty_message',
                data: {
                    message: jQuery("#on_duty_text_message").val()
                },
                success: function(){
                    jQuery("#confirmation_text").html("Message Saved");
                    setTimeout(function(){ jQuery("#confirmation_text").html("");},4000);
                },
                failure: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                },
                error: function(error){
                    console.log(error);
                    alert("Something went wrong, Please report this problem.");
                }
            });
         });

    jQuery('#save_on_duty_list').live('click', function(){
        var on_duty_ids = [];
        var member_info = new Object();
        var times_info;
        jQuery(".on_duty:checked").each(function() {
            on_duty_ids.push($(this).val());
        });
        for(var i = 0; i < on_duty_ids.length; i++)
        {
            times_info = new Object();
            times_info["start_time"] = jQuery('#'+ on_duty_ids[i] + '_start_time').val() + " " + jQuery('#'+ on_duty_ids[i] + '_sampm').val();
            times_info["end_time"] = jQuery('#'+ on_duty_ids[i] + '_end_time').val() + " " + jQuery('#'+ on_duty_ids[i] + '_eampm').val();
            member_info[on_duty_ids[i]] = times_info;
        }
        jQuery.ajax({
                url: '/save_on_duty_list',
                data: {
                    members: member_info
                },
                success: function() {
                    jQuery('a#on_duty_list').trigger("click");
                },
                failure: function(error){
                    console.log(error);
                    alert('Something went wrong, Please report this problem.');
                },
                error: function(error){
                    console.log(error);
                    alert('Something went wrong, Please report this problem.');
                }              
            });
    });
    
    jQuery('#preference_setting_account_mobile_phone').live('change keyup',function(){
        enableOrDisableSmsCheck();
    });

    jQuery('#preference_setting_account_mobile_country_code').live('change keyup',function(){
        enableOrDisableSmsCheck();
    });
    
    
    jQuery('#sync_sessions').live('click', function(){
        if(confirm("Proceed to synchronise session data between CSP and E-school ?")){
            jQuery.blockUI();
            jQuery.ajax({
                url: '/sync_eschool_csp_data',
                success: function(data) {
                    alert(data["text"]);
                    jQuery.unblockUI();
                },
                failure: function(error){
                    console.log(error);
                    alert('Something went wrong, Please report this problem');
                    jQuery.unblockUI();
                },
                error: function(error){
                    console.log(error);
                    alert('Something went wrong, Please report this problem');
                    jQuery.unblockUI();
                }              
            });
        }    
    });        
});

jQuery(document).keydown(function(e) {
      if(jQuery("#popup_ok").length > 0){
        if(e.keyCode == 27){
          jQuery.alerts._hide();
       }
      } 
   });

function enableOrDisableSmsCheck(){
    var errorMessage = "Mobile Phone must be 10 digits \n » Mobile Country Code can't be blank";
    if((jQuery('#preference_setting_account_mobile_phone').val().match(/^\d{10}$/)) && (jQuery('#preference_setting_account_mobile_country_code').val().match(/\d/))){
        jQuery('#preference_setting_coach_not_present_alert').removeAttr('disabled');
        jQuery('#coach_not_present_mobile_no').html(jQuery('#preference_setting_account_mobile_phone').val());
        jQuery('#preference_setting_receive_reflex_sms_alert').removeAttr('disabled');
        jQuery('#reflex_alert_mobile_no').html(jQuery('#preference_setting_account_mobile_phone').val());
        jQuery('#flash_content_div').html('');
    }else if(jQuery('#preference_setting_account_mobile_phone').val().trim() === ''){
        jQuery('#preference_setting_coach_not_present_alert').attr('disabled','disabled');
        jQuery('#preference_setting_receive_reflex_sms_alert').attr('disabled','disabled');
        jQuery('#coach_not_present_mobile_no').html('Mobile Phone N/A');
        jQuery('#reflex_alert_mobile_no').html('Mobile Phone N/A');
        jQuery('#flash_content_div').html('');
    }else{
        jQuery('#preference_setting_coach_not_present_alert').attr('disabled','disabled');
        jQuery('#preference_setting_receive_reflex_sms_alert').attr('disabled','disabled');
        jQuery('#coach_not_present_mobile_no').html('Mobile Phone N/A');
        jQuery('#reflex_alert_mobile_no').html('Mobile Phone N/A');
        jQuery('#flash_content_div').html('<div class="error">' + errorMessage + '</div>');
    }
}

function confirmHide(elem){
    
}
function initiateChat(elem){
    jQuery.alerts.okButton = ' YES ';
    jQuery.alerts.cancelButton = ' NO ';
    jQuery.alerts.confirm('This will open a new window so that you may talk with a Support representative. Are you sure you want to continue?', "Confirm", function(result){
        if(result){
           window.open(jQuery(elem).attr('url'),'pop up', 'height=705, width=464');
        }
    });
}

var validateReason = function() {
        jQuery.alerts.okButton = ' OK ';
        jQuery.alerts.cancelButton = ' CANCEL ';
        var reason_for_sub = jQuery('select#reasons').find('option:selected').val();
        if (reason_for_sub === "Select"){
            jAlert("Please select a reason");
            return -1;
        }
        if (reason_for_sub === "Other") {
            if (jQuery('#other_reasons').val().trim() === ""){
                jAlert("Please provide a reason");
                return -1;
            }
        else {
            reason_for_sub = "Other - " + jQuery('#other_reasons').val();
        }     
        }
        return reason_for_sub;
};

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

function updateAriaSession(element, session_id){
    jQuery.blockUI();
    jQuery.ajax({
        type: "post",
        data: {
            coach_session_id: session_id
        },
        url: "/update_aria_session_with_slot_id",
        success: function(result) {
            alert(result);
             window.location.reload();
        },
        error:function(result){
            alert(result.responseText);
            jQuery.unblockUI();
        },
        failure:function(result){
            alert(result);
            jQuery.unblockUI();
        }
    });
    return;
}

function launchAriaSession(element, coach_session_id){
    jQuery.blockUI();
    config = "menubar=0,resizable=1,scrollbars=0,toolbar=0,location=0,directories=0,status=0,top=0,left=0";
    jQuery.ajax({
            type: 'post',
            data:{
                coach_session_id: coach_session_id
            },
            url: '/aria_launch_url',
            success: function(result) {
                jQuery.unblockUI();
                child_window = window.open(result, "launch_window", config);
            },
            failure: function(error){
                jQuery.unblockUI();
                console.log(error);
                alert('Something went wrong, Please report this problem');
            },
            error: function(error){
                jQuery.unblockUI();
                console.log(error);
                alert('Something went wrong, Please report this problem');
            }              
    });

}

function add_fields(link, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    $(link).up().insert({
        before: content.replace(regexp, new_id)
    });
}

function add_fields_for_qualification(link, association, content) {

    if(jQuery('.fields').find('a').contents().length === 0){
        jQuery('.fields').find('a').html('remove');
    }

    var new_id = parseInt(jQuery('#index_for_qual').val(),10);
    jQuery('#index_for_qual').val(new_id+1);
    var regexp = new RegExp("new_" + association, "g");
    $(link).up().insert({
        before: content.replace(regexp, new_id)
    });

    var add_val = parseInt(jQuery('#remove_field_link').val(), 10);
    add_val = add_val + 1;
    jQuery('#remove_field_link').val(add_val);
}

function initQualifications(){
    makePreferredNameMandatory();
    updateQualificationIds();
    jQuery('a#add-another').click(function() {
        clone_ele = jQuery('#qualifications-list li:first').clone();
        clone_ele.appendTo('#qualifications-list');
        updateQualificationIds();
        jQuery('select[name$="language_id\\]"]').last().val('');
        jQuery('select[name$="max_unit\\]"]').last().val('');
    });

    jQuery('.remove-qual').live('click', function() {
        if (jQuery('#qualifications-list li').length > 1) {
            jQuery('select[name$="language_id\\]"]').each(function(index){
                jQuery(this).unbind('change');
            });
            jQuery(this).parent().parent().remove();
            makePreferredNameMandatory();
            updateQualificationIds();
        }
        else {
            alert('Coach must have at least one qualification.');
        }
    });
}

function check_mobile_country_code()
{
    var mobile_number = document.getElementById('preference_setting_account_mobile_phone').value;
    if(mobile_number !== '')
    {
        document.getElementById('asterix_id').style.display = 'block';
    }
    else
    {
        document.getElementById('asterix_id').style.display = 'none';

    }
}

function updateQualificationIds() {
    jQuery('select[name$="language_id\\]"]').each(function(index){
        jQuery(this).attr('name', 'qualifications['+index+']'+'[language_id]');
    });
    jQuery('select[name$="max_unit\\]"]').each(function(index){
        jQuery(this).attr('name', 'qualifications['+index+']'+'[max_unit]');
    });
    jQuery('select[name$="dialect_id\\]"]').each(function(index){
        jQuery(this).attr('name', 'qualifications['+index+']'+'[dialect_id]');
    });
    validateEnteredQualification();
}

function removeAdvancedEnglishMaxUnits() {
    jQuery('select[name$="language_id\\]"]').each(function(i, ele) {
        updateUnitQualForAdvancedEnglish(ele);
        toggleQualificationDialect(ele);
    });
}

function updateUnitQualForAdvancedEnglish(ele){
    qualification_id    = jQuery(ele).attr('name').match(/[\d]+/)[0];
    lang_id_select_name = "qualifications["+qualification_id+"][max_unit]";
    max_unit_select     = jQuery('select[name="'+lang_id_select_name+'"]');
    selected_language   = jQuery(ele).find('option:selected').text();
    var aria_tmm_reflex = [
        "Advanced English",
        "AEB US",
        "AEB UK",
        "RSA NED - Tutoring",
        "RSA ENG - Tutoring",
        "RSA FRA - Tutoring",
        "RSA DEU - Tutoring",
        "RSA ITA - Tutoring",
        "RSA ESP - Tutoring",
        "RSA NED - Phone",
        "RSA ENG - Phone",
        "RSA FRA - Phone",
        "RSA DEU - Phone",
        "RSA ITA - Phone",
        "RSA ESP - Phone"
    ];
        if( selected_language === "-Select-" || (aria_tmm_reflex.indexOf(selected_language) !== -1) ){
        max_unit_select.parent().hide();
    }
    else{
        max_unit_select.parent().show();
    }
}

function toggleQualificationDialect(ele){
    qualification_id    = jQuery(ele).attr('name').match(/[\d]+/)[0];
    lang_id_select_name = "qualifications["+qualification_id+"][dialect_id]";
    dialect_id_select   = jQuery('select[name="'+lang_id_select_name+'"]');
    selected_language   = jQuery(ele).find('option:selected').text();
    var tmm_dialect = [
        "RSA ENG - Tutoring",
        "RSA ENG - Phone"
    ];
    if( tmm_dialect.indexOf(selected_language) < 0 ){
        dialect_id_select.parent().hide();
    }
    else{
         current_dialect = dialect_id_select.find('option:selected').val();
            dialect_id_select.empty();
            dialect_id_select.append('<option value = "">-Select-</option>');
            jQuery.ajax({
                type: 'get',
                async: false,
                data:{
                    language_id: jQuery(ele).find('option:selected').val()
                },
                url: '/get_dialects',
                success: function(result) {
                    jQuery.each(result, function(id,dialect) {
                        if(current_dialect == id){
                            dialect_id_select.append('<option selected=selected value=' + id + '>' + dialect + '</option>');
                        }else{
                            dialect_id_select.append('<option value=' + id + '>' + dialect + '</option>');
                        }
                    });
                },
                failure: function(error){
                    console.log(error);
                },
                error: function(error){
                    console.log(error);
                }              
            });
        //}
        dialect_id_select.parent().show();
    }

}

function makePreferredNameMandatory(){
  var langList = jQuery('select[name$="language_id\\]"] > option:selected').map(function(index) { return this.innerHTML; }).get();
  if((langList.indexOf("AEB US") === -1) && (langList.indexOf("AEB UK") === -1)){
    jQuery("#name_label").html("Preferred name");
  }else{
    jQuery("#name_label").html("Preferred name*");
  } 
}


function validateEnteredQualification() {
    jQuery('select[name$="language_id\\]"]').each(function(ele_index, ele) {
        jQuery(ele).change( function() {
            selected_language   = jQuery(this).find('option:selected').text();
            updateUnitQualForAdvancedEnglish(ele);
            toggleQualificationDialect(ele);
            makePreferredNameMandatory();
            checkDuplicateQualifications(ele_index, this);
        });
    });
}

function checkDuplicateQualifications(element_index, element) {
    select_language_elements = jQuery('select[name$="language_id\\]"]');
    jQuery.each(select_language_elements, function(each_index, each_ele) {
        if (jQuery(element).val() !== '' && each_index!= element_index && jQuery(element).val() === jQuery(each_ele).val()) {
            alert("Language already selected");
            jQuery(element).val('');
            return;
        }
    });

    var langList = select_language_elements.find('option:selected').map(function(index) { return this.innerHTML; }).get();
    var current_element = jQuery(element).find('option:selected').text();
    langList.splice(langList.indexOf(current_element),1);
    if(langList.toString().search("AEB")!= -1 && current_element.toString().search("AEB")!= -1){
        alert("An AEB Language has already been selected");
        jQuery(element).val('');
        return;
    }
}


function validateEmailField(id,field_name){
    var mail_text = jQuery('#'+id).val().trim();
    var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if (emailPattern.test(mail_text)){
        return "";
    }else{
        return "* Please enter a valid Email.\n";
    }
}


function validateCoachProfile() {
    errors = "";
    //var test_exp =  /^[a-zA-Z0-9]*$/;
    //if(jQuery("#coach_user_name").val() !== '' && !test_exp.test(jQuery("#coach_user_name").val()))
      //  errors += 'AD name cannot contain special characters or white spaces.';
    if(jQuery("#coach_rs_email").val().length > 0)
        errors += validateEmailField('coach_rs_email',"RS Email" );
    jQuery('select[name$="language_id\\]"]').each(function(i, ele) {
        if(jQuery(ele).val() === "") {
            errors += "* Please select a language.\n";
        }
    });
    var unique_languages = {};
    jQuery('select[name$="language_id\\]"]').each(function(i, ele) {
            if(!unique_languages[jQuery(ele).val()]) {
                unique_languages[jQuery(ele).val()] = true;
            }
            else {
                errors += "* Please remove duplicate language qualification.\n";
            }
    });

    jQuery('select[name$="max_unit\\]"]').each(function(i, ele) {
        if(jQuery(ele).val() === "" && jQuery(ele).is(":visible")) {
            errors += "* Please select a unit qualification.\n";
        }
    });
    jQuery('select[name$="dialect_id\\]"]').each(function(i, ele) {
        if(jQuery(ele).val() === "" && jQuery(ele).is(":visible")) {
            errors += "* Please select a dialect.\n";
        }
    });
    if(errors !== ""){
        errors = "The following problems were encountered :\n\n"+errors;
        alert(errors);
        return false;
    }
    else {
        return true;
    }
}

function validateTextFieldNotBlank(id, name) {
    if (jQuery('#'+id).val().trim() === '') {
        return "* "+name+" cannot be blank.\n";
    } else {
        return "";
    }
}

function launchOnline(launch_string, support_chat_url) {
    config = "menubar=0,resizable=1,scrollbars=0,toolbar=0,location=0,directories=0,status=0,top=0,left=0";
    if(support_chat_url)
        child_window = window.open(launch_string+encodeURIComponent(support_chat_url), "launch_window", config);
    else
        child_window = window.open(launch_string, "launch_window", config);

    // continually refresh the parent window as long as the child window is still open
    // to keep the session alive
    keepAlive = function() {
        if (childIsClosed(child_window)) {
            return;
        } else {
            new Ajax.Request('/session_keep_alive', {
                method: 'get',
                onSuccess: function(){
                    setTimeout('keepAlive();', 60000);
                }
            });
        }
    };

    keepAlive();
}

function childIsClosed(child_window) {
    try {
        if (child_window.closed) {
            // we throw because IE throws an exception when checking closed, so lets be stupid in firefox too
            throw('closed');
        } else {
            return false;
        }
    }
    // we just catch any exception because it seems like child_window.closed raises an exception in IE when the window is closed
    catch(exception) {
        return true;
    }
}

function checkCoachSelected(select_id){
    if(jQuery("#"+select_id).val() === '') {
        alert("Please select a Coach");
        return false;
    }
    return true;
}

function checkLanguageSelected(select_id){
    if(jQuery("#"+select_id).val() === '') {
        alert("Please select a Language");
        return false;
    }
    return true;
}

function checkLanguageAndCoachSelected(language_select_id, coach_select_id){
    return checkLanguageSelected(language_select_id) && checkCoachSelected(coach_select_id);
}

function handleReAssignCoaches() {
    if(jQuery("#"+'manager_id').val() === '') {
        alert("Please select a Coach Manager");
        return false;
    }
    return confirm('Are you sure you want to reassign the Coach?');
}

function enableProgressBar(submit_id, progress_bar_id, hide_submit){
    showProgressBar(submit_id, progress_bar_id, hide_submit);
    showProgressBar($(submit_id).next(), progress_bar_id, hide_submit);
}

function showProgressBar(submit_id, progress_bar_id, hide_submit) {
    jQuery("#"+submit_id).disabled = true;
    if(hide_submit){
        jQuery("#"+submit_id).hide();
    }
    jQuery("#"+progress_bar_id).show();
    return true;
}

function showProgressBarWODisabling(submit_id, progress_bar_id, hide_submit) {
    /*This will not disable the grab caller (esp for 39246)
     *$(submit_id).disabled = true;
     */
    if(hide_submit){
        jQuery.blockUI();
        jQuery("#"+submit_id).hide();
    }
    $("#"+progress_bar_id).show();
    return true;
}

function showWarningAndProgressBar(learners, submit_id, progress_bar_id, hide_submit) {
    var confirmation = true;
    if(learners !== '0'){
        confirmation = confirm(learners+" learners have signed up for this session.\nAre you sure you want to cancel it?");
    }
    if(confirmation){
        return showProgressBar(submit_id, progress_bar_id, hide_submit);
    }
    return false;
}

function markNotificationAsRead(elem, notification_id) {
    if(elem.getAttribute('class') === ''){
        return false;
    }
    elem.setAttribute('class', '');
    curCount = $('unread-notif-count').innerHTML;
    $('unread-notif-count').innerHTML = curCount - 1;
    if(curCount == 1){
        $('unread-notif-count').style.color = 'inherit';
    }
    reqPath = '/mark-notification-as-read/' + notification_id;
    new Ajax.Request(reqPath, {
        method: 'get',
        asynchronous: true,
        evalScripts: true
    });
    return true;
}

function checkForErrors(allowed, who) {
    var available = jQuery(".availability_text_box:contains('Available')").length;
    var error_flag = 0;
    var warn_flag = 0;
    var msg="";
    var label = jQuery('#label').val();
    if(label === ''){
        msg += "* Label can't be blank.\n";
        error_flag = 1;
    }
    if(label && label.length < 3) {
        msg += '* Label is too short (minimum is 3 characters).\n';
        error_flag = 1;
    }
    if(available <= 0  ) {
        msg += 'You have not specified availability for any session. Are you sure you want to proceed ?\n';
        warn_flag = 1;
    }
    if(warn_flag){
        return confirm(msg);
    }
    if(error_flag){
        alert('The following errors were found:\n\n'+msg);
        return false;
    }
    return true;
}
function alertMsg(redirect_from_approved_template , msg){//loads when a template is approved from calendar view template

    if(redirect_from_approved_template=='1'){

        alert("Template - "+msg+" was  approved");
    }

}
/*Method that is called when coach selector popup returns*/
function handleSuccess(){
    jQuery(document).trigger('close.facebox');
    var schedules_this_week = 0;
    for(i=0;i<7;i++){
        var committed_coaches = columnTotals('coaches_committed'+i);
        schedules_this_week += committed_coaches;
        jQuery('#coaches_committed_totals'+i).html(committed_coaches);
        jQuery('#coaches_available_totals'+i).html(columnTotals('coaches_available'+i));
        jQuery('#yellow_totals'+i).html(jQuery('div[id^=yellows'+i+']').length);
        jQuery('#red_totals'+i).html(jQuery('div[id^=reds'+i+']').length);
    }
    jQuery('#schedules_in_present_week').val(schedules_this_week);
    jQuery('#schedules_this_week').html(schedules_this_week);
    validateEschoolButton();
}

function validateEschoolButton(){
    if(parseInt(jQuery('#schedules_this_week').html(), 10) <= parseInt(jQuery('#classes_this_week').html(), 10)){
        jQuery("#submit").attr('disabled','disabled'); // submit = eschool submit button
    }else{
        jQuery("#submit").removeAttr('disabled');
    }
}

function columnTotals(idPrefix) {
    var total = 0;
    jQuery('div[id^="' + idPrefix + '"]').each(function() {
        total += parseInt(jQuery(this).text(), 10);
    });
    return total;
}

// Converts 04:45 to 04:15 and vice versa. For cases where timezone offsets are "x hours and 30 mins"
function toggleMinuteValues(offset) {
    if(Math.abs(parseFloat(offset)) % 1 == 0.5){
        jQuery('td[id^="row"]').each(function(){
            min = parseInt(jQuery(this).text().substr(3,2), 10) + 30;
            min %= 60;
            new_time = jQuery(this).text().substr(0,3) + min;
            jQuery(this).text(new_time);
        });
    }
}

function changeLocation(date,loc) {
    var coach_id = jQuery('#coach_id').val();

    if(coach_id !== ""){
        var lang_id = jQuery('#lang_identifier').val();
        year = date.getFullYear();
        month = date.getMonth() + 1;
        day = date.getDate();
        if (month < 10) {
            month = "0" + month;
        }
        if (day < 10) {
            day = "0" + day;
        }
        location.href = loc + year + '-' + month + '-' + day +'&coach_id='+coach_id+'&lang_identifier='+lang_id;
    }
}

var session_popup = {};
session_popup.clickedcell = '';
session_popup.container_top_position = 0;
var isManagerView;
var isPrintView;
var isMS;
jQuery(document).ready(function(){
    isManagerView = jQuery('#my_schedule').hasClass('manager-view');
    isPrintView = jQuery('#my_schedule').hasClass('print-view');
    isMS = document.getElementById('master_schedule');

    //login  user_name and password blank validation.
    jQuery('form#account_form').live('submit',function(e){
        var user_name_elem = jQuery(':text#coach_user_name');
        if(user_name_elem.val() === ""){
            alert("User name can't be blank.");
            user_name_elem.focus();
            return false;
        }
        var pass_elem = jQuery(':password#coach_password');
        if(pass_elem.val() === ""){
            alert("Password can't be blank.");
            pass_elem.focus();
            return false;
        }
    });
});

function initTimeslotActions(time_slot_with_availability) {
    var slots_with_availability = time_slot_with_availability.split(",");
    for(i=0;i< slots_with_availability.length;i++){
        jQuery("#one_hour_cell_container_"+slots_with_availability[i]+"").slideToggle('slow', function() {});
        jQuery("#x_hour_cell_container_"+slots_with_availability[i]+"").slideToggle('slow', function() {});
        jQuery("#expander_"+slots_with_availability[i]+"").css({
            'background':'#E3781F',
            'color':'#FFFFFF'
        });
        jQuery("#collapser_"+slots_with_availability[i]+"").css({
            'background':'#F5AA6B',
            'color':'#FFFFFF'
        });
    }
    jQuery('.expander').click(function() {
        jQuery(this).parent().slideToggle('slow', function() {});
        jQuery(this).parent().next().slideToggle('slow', function() {});
        if(isMS){
            shift_popup.close();
        }else{
            closePopup();
        }
    });

    jQuery('.collapser').click(function() {
        if(isMS){
            shift_popup.close();
        }else{
            closePopup();
        }
        jQuery(this).parent().slideToggle('slow', function() {});
        jQuery(this).parent().prev().slideToggle('slow', function() {});
    });
    jQuery('.button a').live('mousedown', function(){
        jQuery(this).parent('.button').addClass('clicked');
    });
    jQuery('.clicked').live('mouseup', function(){
        jQuery(this).removeClass('clicked');
    });
    expand_local_session_slot();
}

function expand_local_session_slot(){

    jQuery(".not_pushed_to_eschool").each(function(i){
        slot_val = jQuery(this).parent().attr('id').split("_");
        if(jQuery("#one_hour_cell_container_"+slot_val[3]+"").css('display') == 'none'){
            jQuery("#one_hour_cell_container_"+slot_val[3]+"").slideToggle('slow', function() {});
            jQuery("#x_hour_cell_container_"+slot_val[3]+"").slideToggle('slow', function() {});
            jQuery("#collapser_"+slot_val[3]+"").css({
                'background':'#F5AA6B',
                'color':'#FFFFFF'
            });
        }
    });

}
/* Popup of the week availability calendar */

function closePopup(){
    if(session_popup.clickedcell !== ''){
        jQuery('#popup-container').hide();
        jQuery(session_popup.clickedcell).removeClass('selected_cell');
        session_popup.clickedcell = '';
        jQuery('#learner-popup').hide();
    }
    jQuery('#ext-popup-container').hide();
    jQuery('#header').css('height','1%');
}

function pullThePopupUp(){
    document.getElementById('popup-container').style.top = (parseInt(document.getElementById('popup-container').style.top, 10) - 35).toString() + 'px';
}

function cancelSubAssign(active){
    if(active === "true"){
        jQuery('#session-assign-request-confirmation').slideUp();
    }else{
        jQuery('#assign-request-confirmation').slideUp();
    }
    pullThePopupDown();
}

function pullThePopupDown(){
    document.getElementById('popup-container').style.top = (parseInt(document.getElementById('popup-container').style.top, 10) + 35).toString() + 'px';
}

function clickPopupToCreate(account,cell){
    if(jQuery('#can_create_session').val() === "true") {
        var confirm_needed_slots = ['time_off','cancelled','time_off-cancelled','substitute_requested','substitute_requested-cancelled','substitute_triggered','substitute_triggered-cancelled'];
        var confirmed = true;
        if((jQuery(account).selector === "Coach Manager")){
            if((confirm_needed_slots.indexOf(cell.classList[1]) !== -1 )){
                confirmed = confirm('You are about to create a session on a '+cell.classList[1].replace('_'," ")+' slot. Do you want to proceed?');
            }else if((confirm_needed_slots.indexOf(cell.classList[2]) !== -1 )) {
                confirmed = confirm('You are about to create a session on a '+cell.classList[2].replace('_'," ")+' slot. Do you want to proceed?');
            }
            if(confirmed){
                getCreatePopup(cell);
            }
        }
    } else {
        alert("Please select a language from the 'Filter Schedule by' dropdown in order to schedule a session for this Coach");
    }
}

function getCreatePopup(cell){
    if(cell != session_popup.clickedcell){
        closePopup();
        var language_identifier = jQuery('#lang_identifier').val();
        var utc_time_for_slot = jQuery(cell).attr('alt');
        var coach_id = jQuery('#coach_id').val();
        var external_village_id = jQuery('#external_village_id option:selected').val();
        var cell_type = cell.classList[1];
        var path = '/create_session_from_week_view?external_village_id='+external_village_id+'&coach_id='+coach_id+'&utc_time_for_slot='+utc_time_for_slot+'&language_identifier='+language_identifier+'&cell_type='+cell_type;
        jQuery('#my_schedule, .one-hour-cell').addClass('cursor_wait');
        new Ajax.Updater({
            success: 'popup-content'
        }, path,{
            method:'get',
            onComplete:function(){
                showPopup(cell);
                jQuery('#my_schedule, .one-hour-cell').removeClass('cursor_wait');
            }
        });
    //showPopup(cell);
    }
}

function cancelledCreatePopup(lang_identifier,coach_id,start_time,availability){
    var cell = session_popup.clickedcell;
    var language_identifier = lang_identifier;
    var coach = coach_id;
    var utc_time_for_slot = start_time;
    var coach_availability = availability;
    var path = '/create_session_from_week_view?coach_id='+coach+'&utc_time_for_slot='+utc_time_for_slot+'&language_identifier='+language_identifier+'&cell_type='+coach_availability;
    jQuery('#my_schedule, .one-hour-cell').addClass('cursor_wait');
    new Ajax.Updater({
        success: 'popup-content'
    }, path,{
        method:'get',
        onComplete:function(){
            showPopup(cell);
            jQuery('#my_schedule, .one-hour-cell').removeClass('cursor_wait');
        }
    });
}

function showPopup(the_cell) {
    var el = jQuery(the_cell);
    session_popup.clickedcell = the_cell;
    el.addClass('selected_cell');
    var pos = el.offset();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#popup-container').height();
    jQuery("#popup-container").css( {
        "left": (pos.left) + "px",
        "top": (pos.top - height + 20) + "px"
    } );
    jQuery("#popup-container").show();
    var pop_up_height = jQuery("#popup-container").height();
    var html_page_height = el.offset().top;
    if (pop_up_height > html_page_height){
        jQuery('#header').css('height','160px');
    }
    var target_top  = jQuery("#popup-container").offset().top;
    var target_left = jQuery("#popup-container").offset().left;
    jQuery('html,body').animate({
        scrollTop: target_top - 100,
        scrollLeft: target_left - 20
    }, 1000);
    if (jQuery("#popup-content .btm-section .popup_learner_container .popup_learner_list .learner").length == 1){
        jQuery("#popup-content .btm-section .popup_learner_container .popup_learner_list")[0].style["overflow"] = 'hidden';
    }
    session_popup.container_top_position = parseInt(document.getElementById('popup-container').style.top, 10);
}

function coachShowedUp(id){
    var path = '/coach-showed-up?id='+id;
    new Ajax.Updater({
        }, path,{
            method:'post',
            onComplete:function(){
                return true;
        }});
            }

function fetchNextSeesionTime() {
    jQuery.ajax({
        url: '/next_session_start_time',
        success: function(data){
            jQuery('#next-session-alert').html(data);
            if(jQuery('#next-session-alert').is(':empty'))
            {
                jQuery('#on_duty_link2').hide();
                jQuery('#on_duty_link1').show(); 
            }else{
                jQuery('#on_duty_link1').hide();
                jQuery('#on_duty_link2').show();
            }
            setTimeout(function(){
                fetchNextSeesionTime();
            }, 60000);
        },
        error: function(){
            setTimeout(function(){
                fetchNextSeesionTime();
            }, 60000);
        },
        failure: function(){
            setTimeout(function(){
                fetchNextSeesionTime();
            }, 60000);
        }
    });
}
/* Countdown popup ENDS */

function gotoCalendarView() {
    var lang_id = 'all';
    lang_id = jQuery('#lang_identifier').val();
    var coach_id = jQuery('#coach_id').val();
    if(coach_id === undefined || coach_id === ''){
        var loc = '/week-view';
    }else{
        loc = '/week-view?coach_id='+coach_id+'&lang_identifier='+lang_id;
    }
    location.href = loc;
}

function getTeachersForManagerInLanguage(selected_coach) {
    var lang_identifier = jQuery('#lang_identifier').val();
    if(lang_identifier !== ''){
        new Ajax.Updater('select_coach','/get_teachers_for_manager_in_language/' + $('lang_identifier').value + '?coach_id=' + selected_coach,
        {
            asynchronous:true,
            evalScripts:true,
            method:'get',
            onComplete:function(request){
                jQuery('#change_id').attr('disabled',false);
                $('coach_id').disabled = false;
                if(jQuery('#coach_id').val() === '')
                    jQuery('#link_area_id').hide();
            },
            onSuccess:function(request){}
        });
    }
    return false;

}
//function confirmSubstitutionRequest(){
//    jQuery('#req-sub').live("click",function () {
//        jQuery("#substitution-request-confirmation").slideDown();
//    });
//}

function changeEffectiveStartDateBy7Days(operation, alert_old_date){
    start_date =new Date(jQuery('#effective_start_date').val());
    end_date = new Date(jQuery('#effective_end_date').val());
    if (operation == 'add') {
        start_date.setDate(start_date.getDate()+ 7);
        end_date.setDate(end_date.getDate()+ 7);
    }
    else {
        today = new Date();
        start_date.setDate(start_date.getDate()- 7);
        end_date.setDate(end_date.getDate() - 7);
        if(alert_old_date && (start_date < today)) {
            alert("Please select a date in the future.");
            start_date = today;
            end_date = new Date();
            end_date.setDate(end_date.getDate()+ 6);
        }
    }
    jQuery('#effective_start_date').val(start_date.toFormattedString(false));
    jQuery('#effective_end_date').val(end_date.toFormattedString(false));
}

function changeStartDateBy7Days(operation, alert_old_date){
    start_date =new Date(jQuery('#start_date').val());
    if (operation == 'add') {
        start_date.setDate(start_date.getDate()+ 7);
    }
    else {
        today = new Date();
        start_date.setDate(start_date.getDate()- 7);
        if(alert_old_date && (start_date < today)) {
            alert("Please select a date in the future.");
            start_date = today;
        }
    }
    jQuery('#start_date').val(start_date.toFormattedString(false));
}

function populate_time_off_details(mstart_date,end_date,reason){
    if ($('iamback').checked === true) {
        window.orig_start_date = $('modification_start_date').value;
        window.orig_end_date = $('modification_end_date').value;
        window.time_off_reason = $('modification_comments').value;
        $('modification_start_date').value = mstart_date;
        $('modification_start_date').disabled = true;
        $('modification_end_date').value = end_date;
        $('modification_comments').value = reason;
    }else{
        $('modification_start_date').value = window.orig_start_date;
        $('modification_end_date').value = window.orig_end_date;
        $('modification_comments').value = window.time_off_reason;
        $('modification_start_date').disabled = false;
        $('modification_end_date').disabled = false;
    }
}
function toggleLevelUnit() {
    if($('wildcard').checked === true) {
        jQuery('select#level').val('--');
        jQuery('select#unit').val('--');
        $('level').disabled = true;
        $('unit').disabled = true;
    } else {
        $('level').disabled = false;
        $('unit').disabled = false;
    }
}

function upcomingSessions(coach_id, lang_id){

    path = '/view_my_upcoming_classes?coach_id='+coach_id+'&lang_id='+lang_id;
    new Ajax.Updater({
        success: 'upcoming_classes_for_week'
    }, path,{
        method:'get',
        evalScripts: true,
        onComplete:function(){
            jQuery('#upcoming_classes_for_week').show();
            jQuery('#upcoming_classes_for_week').removeClass('cursor_wait');
        }
    });

}

function closeCoachPopup(id){
    jQuery('#'+id).hide();
}

function getUrlQueryParameter(key) {
    var urlParamsHash = new Hash;
    var urlParams = top.location.href.split("?")[1].split("&");
    for (i=0;i<urlParams.length;i++){
        urlParamsHash[urlParams[i].split("=")[0]] = urlParams[i].split("=")[1];
    }
    return urlParamsHash[key];
}

function confirm_function(a,b,c)
{
    var selected, unavail, selected_threshold;
    for(var i=0;i< jQuery('#'+c+' option').length;i++)
    {
        if(jQuery('#'+c+' option')[i].value === '--UNAVAILABLE:--') {
            unavail = i;
        }
        if(jQuery('#'+c+' option')[i].value === jQuery('#'+c).val()) {
            selected = i;
        }
    }
    selected_threshold = jQuery('#'+c+' option:selected').attr('threshold');
    jQuery('#selected_value').val(jQuery('#'+c).val());
    if(unavail < selected) {
    str1 = "You are about to assign a session for an Unavailable coach,";
    str2 = "Do you wish to continue ?";
    if(selected_threshold === "true")
    {
        str1 += "and this Coach has reached or exceeded the threshold set for maximum number of sessions per week.";
        str1 += str2;
    }
    else
    {
        str1+=str2;
    }
    var p = confirm(str1);
       // var p = confirm("You are about to assign a session for an Unavailable coach. Do you wish to continue ?");
        if(p === true) {
            showProgressBar(a,b,true);
            return true;
        }
        else {
            return false;
        }
    }
    else {
        if(selected_threshold === "true")
        {
            var result = confirm("The Coach has reached or exceeded the threshold set for maximum number of sessions per week.Would you like to continue?");

            if(result === true)
            {
                showProgressBar(a,b,true);
                return true;
            }
            else
            {
                return false;
            }
        }
        else
            {
                showProgressBar(a,b,true);
                return true;
            }

    }
}

function confirm_function_coach_schedule(select_id, submit_id, progress_bar_id){
    var selected, unavail,selected_threshold;
    for(var i=0;i<jQuery('#'+select_id+' option').length;i++){
        if(jQuery('#'+select_id+' option')[i].value === '--UNAVAILABLE:--') {
            unavail = i;
        }
        if(jQuery('#'+select_id+' option')[i].value === jQuery('#'+select_id).val()) {
            selected = i;
        }
    }
    selected_threshold = jQuery('#'+select_id+' option:selected').attr('threshold');
    if(unavail < selected) {
        str1 = "You are about to assign a session for an Unavailable coach, ";
        str2 = "Do you wish to continue ?";
        if(selected_threshold === "true")
        {
            str1 += "and this Coach has reached or exceeded the threshold set for maximum number of sessions per week.";
            str1 += str2;
        }else{
            str1+=str2;
        }
        var p = confirm(str1);
        if(p) {
            enableProgressBar(submit_id, progress_bar_id, true);
            return true;
        }else {
            return false;
        }
    }
    else {
        if(selected_threshold === "true"){
            var result = confirm("The Coach has reached or exceeded the threshold set for maximum number of sessions per week.Would you like to continue?");

            if(result){
                enableProgressBar(submit_id, progress_bar_id, true);
                return true;
            }else{
                 return false;
             }
        }else{
             enableProgressBar(submit_id, progress_bar_id, true);
             return true;
         }
    }
}

function validate_reassign_dropdown(str1,str2)
{
    if((document.getElementById(str1).value=='--UNAVAILABLE:--') || (document.getElementById(str1).value=='--AVAILABLE:--')) {
        document.getElementById(str2).disabled=true;
    }
    else {
        document.getElementById(str2).disabled=false;
    }
}

function validate_assign_coach_dropdown() {
    if(jQuery('#coach_session_assign_drop_down').val() === '--UNAVAILABLE:--') {
        jQuery('#session_assign_coach_submit').attr('disabled',true);
        jQuery('#session_assign_coach_submit').removeClass('button medium_button');
    }else{
        jQuery('#session_assign_coach_submit').attr('disabled',false);
        jQuery('#session_assign_coach_submit').addClass('button medium_button');
    }
}

//For create coaches page under Manager Portal
function validate()
{
    var qualFlag=true;
    for (i=0;i<document.getElementById('index_for_qual').value;i++)
    {
        if(document.getElementById('coach_qualifications_attributes_'+i+'_language_id') !== null)
        {
            qualFlag=false;
            if(document.getElementById('coach_qualifications_attributes_'+i+'_language_id').options[document.getElementById('coach_qualifications_attributes_'+i+'_language_id').selectedIndex].value === "")
            {
                document.getElementById('error_div2').style.display='none';
                document.getElementById('error_div1').style.display='block';
                document.getElementById('error_div3').style.display='none';
                document.getElementById('error_div4').style.display='none';
                document.getElementById('coach_qualifications_attributes_'+i+'_language_id').focus();
                return false;
            }
        }

        if(document.getElementById('coach_qualifications_attributes_'+i+'_language_id') !== null && document.getElementById('coach_qualifications_attributes_'+i+'_language_id').options[document.getElementById('coach_qualifications_attributes_'+i+'_language_id').selectedIndex].value !== "32")
        {
            if(document.getElementById('coach_qualifications_attributes_'+i+'_max_unit')!== null && document.getElementById('coach_qualifications_attributes_'+i+'_max_unit').options[document.getElementById('coach_qualifications_attributes_'+i+'_max_unit').selectedIndex].value === "0")
            {
                //alert('Max Unit should be greater than zero');
                document.getElementById('error_div1').style.display='none';
                document.getElementById('error_div2').style.display='block';
                document.getElementById('error_div3').style.display='none';
                document.getElementById('error_div4').style.display='none';
                document.getElementById('coach_qualifications_attributes_'+i+'_max_unit').focus();
                return false;
            }
        }
    }

    if(qualFlag)
    {
        document.getElementById('error_div1').style.display='none';
        document.getElementById('error_div2').style.display='none';
        document.getElementById('error_div3').style.display='none';
        document.getElementById('error_div4').style.display='block';
        return false;
    }

    if(!checkDuplicates())
        return false;

    return true;
}

//For create coaches page under Manager Portal
function checkDuplicates()
{
    var ids = new Array();
    var index=0;
    for (i=0;i<document.getElementById('index_for_qual').value;i++)
    {
        if(document.getElementById('coach_qualifications_attributes_'+i+'_language_id') !== null && document.getElementById('coach_qualifications_attributes_'+i+'_language_id').options[document.getElementById('coach_qualifications_attributes_'+i+'_language_id').selectedIndex].value !== "")
        {
            ids[index] = document.getElementById('coach_qualifications_attributes_'+i+'_language_id').options[document.getElementById('coach_qualifications_attributes_'+i+'_language_id').selectedIndex].value;
            index = index + 1;
        }
    }

    var sorted_arr = ids.sort();
    for (var i = 0; i < sorted_arr.length - 1; i += 1) {
        if (sorted_arr[i + 1] == sorted_arr[i]) {
            document.getElementById('error_div3').style.display='block';
            document.getElementById('error_div2').style.display='none';
            document.getElementById('error_div1').style.display='none';
            document.getElementById('error_div4').style.display='none';
            //document.getElementById('coach_qualifications_attributes_'+i+'_language_id').focus();
            return false;
        }
    }

    return true;
}

var move_up_pop_up = false;
function lang_change(from_edit){
    var all_languages_and_max_unit_array_json = jQuery.parseJSON(jQuery('#all_languages_max_unit')[0].value);
    var language = jQuery('#language_id').val();
    var reflex_lang = jQuery.parseJSON(jQuery('#lotus_languages')[0].value);
    if((reflex_lang.indexOf(language.toString())) === -1){
        var max_unit = all_languages_and_max_unit_array_json[language];
        maxlevel(max_unit);
        document.getElementById('village_id').disabled = false;
        document.getElementById('number_of_seats').disabled = false;
        document.getElementById('level').disabled = false;
        document.getElementById('unit').disabled = false;
        jQuery('#teacher_confirmed').parent().removeClass("teacher_confirmed");
        if(from_edit){
            jQuery('#cancel_remove_button').val("CANCEL SESSION");
            jQuery('#hidding_data_for_lotus').slideDown("fast");
            if(move_up_pop_up === true){
                document.getElementById('popup-container').style.top = (parseInt(document.getElementById('popup-container').style.top, 10) - 115).toString() + 'px';
                move_up_pop_up = false;
            }
        }
    } else
{
        document.getElementById('level').disabled = true;
        document.getElementById('village_id').disabled = true;
        document.getElementById('unit').disabled = true;
        document.getElementById('number_of_seats').disabled = true;
        jQuery('#teacher_confirmed').parent().addClass("teacher_confirmed");
        jQuery('#max_qual_of_the_coach').text("");
        if(from_edit){
            jQuery('#cancel_remove_button').val("REMOVE");
            jQuery('#hidding_data_for_lotus').slideUp("fast");
            document.getElementById('popup-container').style.top = (parseInt(document.getElementById('popup-container').style.top, 10) + 115).toString() + 'px';
            if(move_up_pop_up === false){
                move_up_pop_up = true;
            }
        }
    }
    if(from_edit){
        if(language === jQuery('#previous_language').val()){
            jQuery('#cancel_remove_button').show();
            jQuery('#village_id').val(jQuery('#previous_village').val());
            jQuery('#level').val(jQuery('#previous_level').val());
            jQuery('#unit').val(jQuery('#previous_unit').val());
            jQuery('#number_of_seats') .val(jQuery('#previous_seats').val());
        }else{
            jQuery('#cancel_remove_button').hide();
            jQuery('#village_id').val("");
            jQuery('#level').val("--");
            jQuery('#unit').val("--");
            jQuery('#number_of_seats') .val("4");
        }
        if(document.getElementById('level').value === "--" && document.getElementById('unit').value === "--"){
            document.getElementById('wildcard').checked = true;
            document.getElementById('level').disabled = true;
            document.getElementById('unit').disabled = true;
        }
        else{
            document.getElementById('wildcard').checked = false;
            document.getElementById('level').disabled = false;
            document.getElementById('unit').disabled = false;
        }
    }
}

function checkRecurringPossible(){
    alert("There is no availablity for you in this time.");
    jQuery('#recurring').attr('disabled', true).attr('checked', false);
}

function checkLevelUnitValidations(){
    var level = jQuery('#level').val();
    var unit = jQuery('#unit').val();
    if((level === '--' && unit !== '--') || (level !== '--' && unit === '--')){
        alert('Enter both Level and Unit as wildcard or select values for both');
        return false;
    }else {
        return true;
    }
}

function checkRecurringLevelUnitValidations(){
    var level = jQuery('#level').val();
    var unit = jQuery('#unit').val();
    if((level === '--' && unit !== '--') || (level !== '--' && unit === '--')){
        jAlert('Enter both Level and Unit as wildcard or select values for both');
    }
    return true;
}

function confirmSessionCreationFromCoachSchedule(threshold_reached){
    if(jQuery("#language_id").val() === "-1") {
        alert("Please select a language to continue");
        return false;
    }
    if(threshold_reached[1] === 'true') {
      if(confirm("The Coach has reached or exceeded the threshold set for maximum number of sessions per week.Would you like to continue?") === true)
        return confirmRecurring();
      else
        return false;
    } else {
      return confirmRecurring();
    }
  }

function confirmRecurring(){
    var recurrence_checked = jQuery('#recurring ').is(':checked');
    var availabilty = jQuery('#availability').val();

    if (recurrence_checked && availabilty === 'unavailable'){
        var name = jQuery('#user_name').val();
        jQuery.alerts.okButton = 'YES, CONTINUE';
        jQuery.alerts.cancelButton = 'NO, DO NOT MAKE RECURRING';
        message = name+' is unavailable at this time. Are you sure you want to create a recurring session?';
        jQuery.alerts.confirm(message, "Confirm", function(result){
            if(result){
                checkRecurringLevelUnitValidations();
                jQuery('#cs_form_submit').click();
                return true;
            }else{
                jQuery('#recurring ').attr('checked', false);
                checkRecurringLevelUnitValidations();
                jQuery('#cs_form_submit').click();
                return true;
            }
        });
    }else{
        checkRecurringLevelUnitValidations();
        jQuery('#cs_form_submit').click();
    }
}

//For create coaches page under Manager Portal
function disableMaxUnit()
{
    for (i=0;i<document.getElementById('index_for_qual').value;i++)
    {
        if(document.getElementById('coach_qualifications_attributes_'+i+'_language_id') !== null && document.getElementById('coach_qualifications_attributes_'+i+'_language_id').options[document.getElementById('coach_qualifications_attributes_'+i+'_language_id').selectedIndex].text === 'Advanced English')
        {
            document.getElementById('coach_qualifications_attributes_'+(i)+'_max_unit').value = '1';
            jQuery('#coach_qualifications_attributes_'+(i)+'_max_unit').hide();
        }else{
            document.getElementById('coach_qualifications_attributes_'+(i)+'_max_unit').value = '0';
            jQuery('#coach_qualifications_attributes_'+(i)+'_max_unit').show();
        }
    }
}

// Preference Settings
function setCheckBoxes() {
    if (jQuery('#preference_setting_substitution_alerts_email').is(':checked')) {
        jQuery('#preference_setting_substitution_alerts_email_type').removeAttr('disabled');
        jQuery('#preference_setting_substitution_alerts_email_sending_schedule').removeAttr('disabled');
    } else {
        jQuery('#preference_setting_substitution_alerts_email_type').attr('disabled', true);
        jQuery('#preference_setting_substitution_alerts_email_sending_schedule').attr('disabled', true);
    }

    if (jQuery('#preference_setting_notifications_email').is(':checked')) {
        jQuery('#preference_setting_notifications_email_type').removeAttr('disabled');
        jQuery('#preference_setting_notifications_email_sending_schedule').removeAttr('disabled');
    } else {
        jQuery('#preference_setting_notifications_email_type').attr('disabled', true);
        jQuery('#preference_setting_notifications_email_sending_schedule').attr('disabled', true);
    }

    if (jQuery('#preference_setting_calendar_notices_email').is(':checked')) {
        jQuery('#preference_setting_calendar_notices_email_type').removeAttr('disabled');
        jQuery('#preference_setting_calendar_notices_email_sending_schedule').removeAttr('disabled');
    } else {
        jQuery('#preference_setting_calendar_notices_email_type').attr('disabled', true);
        jQuery('#preference_setting_calendar_notices_email_sending_schedule').attr('disabled', true);
    }

    if (jQuery('#preference_setting_timeoff_request_email').is(':checked')) {
        jQuery('#preference_setting_timeoff_request_email_type').removeAttr('disabled');
    } else {
        jQuery('#preference_setting_timeoff_request_email_type').attr('disabled', true);
    }

    if (jQuery('#preference_setting_substitution_policy_email').is(':checked')) {
        jQuery('#preference_setting_substitution_policy_email_type').removeAttr('disabled');
        jQuery('#preference_setting_substitution_policy_email_sending_schedule').removeAttr('disabled');
    } else {
        jQuery('#preference_setting_substitution_policy_email_type').attr('disabled', true);
        jQuery('#preference_setting_substitution_policy_email_sending_schedule').attr('disabled', true);
    }
    

    if (jQuery('#preference_setting_substitution_alerts_sms').is(':checked')) {
        jQuery('#substitution_mobile_no').removeClass("disabled_space");
    } else {
        jQuery('#substitution_mobile_no').addClass("disabled_space");
    }

    if (jQuery('#preference_setting_coach_not_present_alert').is(':checked')) {
        jQuery('#coach_not_present_mobile_no').removeClass("disabled_space");
    } else {
        jQuery('#coach_not_present_mobile_no').addClass("disabled_space");
    }

    if (jQuery('#preference_setting_receive_reflex_sms_alert').is(':checked')) {
        jQuery('#reflex_alert_mobile_no').removeClass("disabled_space");
    } else {
        jQuery('#reflex_alert_mobile_no').addClass("disabled_space");
    }

    // Disabling the below field since it is not implemented .
    jQuery('#preference_setting_default_language_for_master_scheduler').attr('disabled', true);

}

function updateCheckBoxes(){
    setCheckBoxes();
    check_box_array = ['#preference_setting_substitution_alerts_email', '#preference_setting_timeoff_request_email' , '#preference_setting_notifications_email', '#preference_setting_calendar_notices_email', '#preference_setting_substitution_alerts_sms', '#preference_setting_substitution_policy_email' ];
    jQuery.each(check_box_array, function(i, element) {
        jQuery(element).click(function(){
            setCheckBoxes();
        });
    });
}

function setCmCheckBoxes() {
    if (jQuery('#preference_setting_orphaned_session_alert_email').is(':checked')) {
        jQuery('#preference_setting_orphaned_session_alert_email_type').removeAttr('disabled');
    } else {
        jQuery('#preference_setting_orphaned_session_alert_email_type').attr('disabled', true);
    }

    if (jQuery('#preference_setting_orphaned_session_alert_sms').is(':checked')) {
        jQuery('#orphaned_session_no').removeClass("disabled_space");
    } else {
        jQuery('#orphaned_session_no').addClass("disabled_space");
    }
}

function updateCmCheckBoxes(){
    setCmCheckBoxes();
    check_box_array = ['#preference_setting_orphaned_session_alert_email'];
    jQuery.each(check_box_array, function(i, element) {
        jQuery(element).click(function(){
            setCmCheckBoxes();
        });
    });
}

function disableNotImplentedTags(){
    check_box_array_to_disable = [ '#preference_setting_notifications_sms_sending_schedule', '#preference_setting_calendar_notices_sms_sending_schedule', '#preference_setting_notifications_sms','#preference_setting_calendar_notices_sms'];

    jQuery.each(check_box_array_to_disable, function(i, element) {
        jQuery(element).attr('disabled', true).attr('checked', false);
    });

    span_tag_array_to_disable = ['#notifications_mobile_no', '#calendar_mobile_no'];
    jQuery.each(span_tag_array_to_disable, function(i, element) {
        jQuery(element).addClass("disabled_space");
    });
}

function enableCheckBoxes(){
    check_box_array_to_enable = ['#preference_setting_substitution_alerts_sms'];
    jQuery.each(check_box_array_to_enable, function(i, element) {
        if(jQuery(element).is(':disabled')){
            jQuery(element).removeAttr('disabled');
        }
    });
}

function approve_timeoff(elem){
    jQuery.blockUI();
    time_off_id = elem.parents('tr').attr('id');
    var path = "approve-modification/" + elem.parents('tr').attr('id') + "/";
    if(elem.text() === "Approve"){
        path += "true";
    }else{
        path += "false";
    }
    jQuery.ajax({
        url: path,
        success: function(data){
            elem.parent().html(data);
            jQuery("#status_"+time_off_id).text(jQuery("#approval_status").text());
            jQuery.unblockUI();
        },
        error: function(){
            jQuery.unblockUI();
            alert("There is some error, please try again.");
        }
    });
}

function filterNotifications() {
    var url = 'manager-notifications?';
    if(!jQuery('#excludeTemplateChanges').is(':checked')) url += 'excludeTemplateChanges=1&';
    if(!jQuery('#excludeTimeOffRequests').is(':checked')) url += 'excludeTimeOffRequests=1&';
    if(jQuery('#coachToShow').val().length !== 0){
        jQuery('#langToShow').val("");
        jQuery('#regionToShow').val("");
    }
    url += 'postedFrom=' + jQuery('#postedFrom').val() + '&';
    url += 'coachToShow=' + jQuery('#coachToShow').val() + '&';
    url += 'langToShow=' + jQuery('#langToShow').val() + '&';
    url += 'regionToShow=' + jQuery('#regionToShow').val() + '&';
    url += 'fromdate=' + jQuery('#start_date').val() + '&';
    url += 'todate=' + jQuery('#end_date').val() + '&'; 
    window.location.href = url;
}

function editCoachSession(time, coach_id, coach_session_id){
    var cell = session_popup.clickedcell;
    var path = 'edit-coach-session?time='+time+'&coach_id='+coach_id+'&coach_session_id='+coach_session_id;
    jQuery('#my_schedule, .one-hour-cell').addClass('cursor_wait');
    new Ajax.Updater({
        success: 'popup-content'
    }, path,{
        method:'get',
        onComplete:function(){
            var target_top = jQuery("#popup-container").offset().top;
            var target_left = jQuery("#popup-container").offset().left;
            jQuery('html,body').animate({
                scrollTop: target_top - 100,
                scrollLeft: target_left - 20
            }, 1000);
            showPopup(cell);
            jQuery('#my_schedule, .one-hour-cell').removeClass('cursor_wait');
            lang_change(true);
            disableAllFields();
        }
    });
}
function confirmationForCancel(action_type,coach_session_id,future_session){

    if(jQuery('#previously_recurring').val() === "false"){
        jQuery.alerts.okButton = ' Yes ';
        jQuery.alerts.cancelButton = ' No ';
        jQuery.alerts.confirm('Are you sure you want to '+action_type.toLowerCase()+' the '+ (jQuery("#is_appointment").val() === 'true' ? 'appointment' : 'session') +'?', action_type+' CONFIRMATION', function(result){
            if(result){
                return confirmationForCoachEdit(action_type,coach_session_id,future_session);
            }else{
                return false;
            }
        });
    }else{
        return confirmationForCoachEdit(action_type,coach_session_id,future_session);
    }
    return true;
}

function confirmationForSave(action_type,coach_session_id,future_session){
  return confirmationForCoachEdit(action_type,coach_session_id,future_session);
}

function confirmationForRecurring(action_type,coach_session_id,future_session){
    var previously_recurring = jQuery('#previously_recurring').val();
    var recurring = jQuery('#recurring').is(':checked');
    if (previously_recurring === "false" && recurring && future_session !== 'NO FUTURE SESSION'){
        jQuery.alerts.okButton = 'Continue';
        jQuery.alerts.cancelButton = 'Cancel';
        jQuery.alerts.confirm(future_session,"Confirm",function(result){
            if(result){
                jQuery('#cancel_future_sessions_without_recurrence').val("true");
                return confirmationForCoachEdit(action_type,coach_session_id,future_session);
            }else{
                jQuery('#cancel_future_sessions_without_recurrence').val("false");
                return false;
            }
        });
    }else{
        return confirmationForCoachEdit(action_type,coach_session_id,future_session);
    }
    return true;
}

function confirmationForCoachEdit(action_type,coach_session_id,future_session){

    var language_id, village_id, level, unit, reflex_lang, no_of_seats, learners_signed_up,teacher_confirmed;
    var previously_recurring = jQuery('#previously_recurring').val();
    var recurring = jQuery('#recurring').is(':checked');
    var wild_card = document.getElementById('wildcard').checked;
    var availability = jQuery('#availability').val();
    if(action_type === "SAVE"){
        language_id = jQuery('#language_id').val();
        reflex_lang = jQuery.parseJSON(jQuery('#lotus_languages')[0].value);
        no_of_seats = jQuery('#number_of_seats').val();
        village_id = jQuery('#village_id').val();
        level = jQuery('#level').val();
        unit = jQuery('#unit').val();
        learners_signed_up = jQuery('#learners_signed_up').val();
        teacher_confirmed = jQuery('#teacher_confirmed').is(':checked');

        if(reflex_lang.indexOf(language_id.toString()) === -1 && !wild_card){
            if(level === "--" || unit === "--"){
                alert("Please select a valid level and unit.");
                return false;
            }
            var all_languages_and_max_unit_array_json = jQuery.parseJSON(jQuery('#all_languages_max_unit')[0].value);
            var max_unit = all_languages_and_max_unit_array_json[language_id];
            var single_unit_number = single_unit_from_level_unit(level,unit);
            var returned_level_values = unit_level_from_max_unit(max_unit);
            if (single_unit_number > max_unit){
                alert("The Level and Unit Selected is more than the Maximum Level and  Unit(L"+returned_level_values[0]+"-U"+returned_level_values[1]+") allowed for this coach");
                return false;
            }
        }

        if (learners_signed_up > 0){
            var learners = jQuery('#learners_signed_up').val();
            if (learners > no_of_seats)
            {
                alert("You cannot select seats lesser than the learners currently signed up for this session.");
                return false;
            }
        }
    }

    if(previously_recurring === "true" || (availability === 'unavailable' && recurring && action_type != 'CANCEL SESSION')){
        jQuery.extend(jQuery.facebox, {
            settings: {
                opacity      : 0.5,
                overlay      : true,
                loadingImage : '/images/facebox/loading.gif',
                closeImage   : '/images/facebox/closelabel.gif',
                imageTypes   : [ 'png', 'jpg', 'jpeg', 'gif' ],
                faceboxHtml  : '\
    <div id="facebox" style="display:none;"> \
      <div class="popup"> \
        <table> \
          <tbody> \
            <tr> \
              <td class="tl"/><td class="b"/><td class="tr"/> \
            </tr> \
            <tr> \
              <td class="b"/> \
              <td class="body" style="width:auto"> \
                 <div style="text-align:right"> \
                  <a href="#" class="close"> \
                    <img src="/images/facebox/closelabel.gif" title="close" class="close_image" /> \
                  </a> \
                </div> \
                <div class="content"> \
                </div> \
              </td> \
              <td class="b"/> \
            </tr> \
            <tr> \
              <td class="bl"/><td class="b"/><td class="br"/> \
            </tr> \
          </tbody> \
        </table> \
      </div> \
    </div>'
            }
        });

        var path = 'confirmation_for_coach_edit';
        jQuery.facebox(function (){
            jQuery.ajax({
                type: "post",
                async: true,
                data: {
                    action_type : action_type,
                    coach_session_id: coach_session_id,
                    language_id: language_id,
                    village_id: village_id,
                    level: level,
                    unit: unit,
                    no_of_seats: no_of_seats,
                    recurring: recurring,
                    learners_signed_up: learners_signed_up,
                    previously_recurring: previously_recurring,
                    wildcard : wild_card,
                    future_session : future_session,
                    availability : availability,
                    teacher_confirmed : teacher_confirmed
                },
                url: path,
                success: function(data){
                    jQuery.facebox(data);
                }
            });
        });
    }else{
        jQuery('#action_type').val(action_type);
        jQuery('#language_id').attr('disabled', false);
        jQuery('#village_id').attr('disabled', false);
        jQuery('#level').attr('disabled', false);
        jQuery('#unit').attr('disabled', false);
        jQuery('#recurring').attr('disabled', false);
        jQuery('#wildcard').attr('disabled', false);
        jQuery('#edit_session_form').submit();
        closePopup();
    }
    return true;
}


function dualFunction(a,b,c)
{
    showProgressBar(a,b,true);
    document.getElementById(c).style.display='none';
    return true;
}


function disableAllFields()
{
    var learners = jQuery('#learners_signed_up').val();
    if (learners > 0){

        var tag_ids_array_to_disable = ['#language_id', '#village_id', '#level', '#unit', '#wildcard'];
        jQuery.each(tag_ids_array_to_disable, function(i, element) {
            jQuery(element).attr('disabled', true);
        });

        var tag_ids_array_to_add_class = ['#ce_sess_level', '#ce_sess_unit', '#ce_sess_wildcard', '#ce_sess_village', '#ce_sess_lang', '#max_qual_of_the_coach'];
        jQuery.each(tag_ids_array_to_add_class, function(i, element) {
            jQuery(element).addClass("disabled_space");
        });

    }
    return true;
}

function viewExtensionDetails(ext_id, pr_guid, license_identifier, license_guid,language,group_guid,version, original_end_date, enable_extension){
    jQuery('.close-popup').click(closePopup);
    var path = '/view_extension_details?pr_guid=' + pr_guid +"&group_guid=" + group_guid + "&license_identifier=" + license_identifier + "&language=" + language + "&version=" + version + "&license_guid=" + license_guid + "&original_end_date=" + original_end_date + "&enable_extension=" + enable_extension;
    jQuery.ajax({
        type : 'GET',
        url: path,
        
        success: function(data){
           jQuery("#ext-popup-content").html(data);
           viewExtensionDetailsShow(ext_id);
        },
        error: function(response){
            
        }
    });

}

function viewExtensionDetailsShow(ext_id) {
    var ext_obj = jQuery('#'+ext_id);
    var pos = ext_obj.offset();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;

    if (jQuery("#view_session_details_popup_table tr").length <= 4){
        jQuery("#view_session_details_popup_table_div").attr('overflow', 'hidden');
        jQuery("#view_session_details_popup_table_div").height('auto');
    }

    var height = jQuery('#ext-popup-container').height();
    jQuery("#ext-popup-container").css( {
        "left": (pos.left - 600) + "px",
        "top": (pos.top - height) + "px"
    } );
    jQuery("#ext-popup-container").show();

    var ext_pop_up_height = jQuery("#ext-popup-container").height();
    var html_page_height = ext_obj.offset().top;
    if (ext_pop_up_height > html_page_height){
        jQuery('#header').css('height','160px');
    }

    var target_top  = jQuery("#ext-popup-container").offset().top;
    var target_left = jQuery("#ext-popup-container").offset().left;
    jQuery('html,body').animate({
        scrollTop: target_top - 100,
        scrollLeft: target_left - 20
    }, 1000);

}

var addStudentToSession = function(submitButton){
    if(submitButton.getAttribute('solo') == "true")
        jQuery('#one_on_one').val(true);
    else
        jQuery('#one_on_one').val(false);
    var form = jQuery(submitButton).parents('form:first');
    jQuery('#add_student_button').attr('disabled','disabled');
    jQuery('#add_student_button').next().show();
    jQuery.ajax({
        type : 'POST',
        url: '/add_student',
        data : jQuery(form).serialize(),
        success: function(data){
            jQuery('#add_student_button').removeAttr('disabled','disabled');
            jQuery('#add_student_button').next().hide();
            jQuery(document).trigger('close.facebox');
            jQuery("tr[class='highlighted'] > td > span[class='learners_level']").html(data.level);
            jQuery("tr[class='highlighted'] > td > span[class='learners_unit']").html(data.unit);
            jQuery("tr[class='highlighted'] > td > span[class='learners_lesson']").html(data.lesson);
            jQuery("tr[class='highlighted'] > td > span[class='learners_wildcard']").html("-");
            var link = jQuery("tr[class='highlighted'] > td > a[class='learners_seats']");
            var text = jQuery(link).html();
            jQuery(link).html(text.replace(text.charAt(0),parseInt(text.charAt(0),10)+1));
            if(jQuery('#one_on_one').val() == "true"){
                jQuery(link).html('1/1');
            }
            alert(data.message);
        },
        error: function(response){
            jQuery('#add_student_button').removeAttr('disabled','disabled');
            jQuery('#add_student_button').next().hide();
            alert(response.responseText);
        }
    });
};

var removeAStudentFromSession = function(e){
    var source = jQuery(e.target);
    jQuery(source).hide();
    jQuery(source).next().show();
    jQuery.ajax({
        type : 'POST',
        url: source.attr('href'),
        success: function(message){
            alert(message);
            var link = jQuery("tr[class='highlighted'] > td > a[class='learners_seats']");
            var text = jQuery(link).html();
            var no_of_seats = jQuery(link).attr('no_of_seats');
            if(no_of_seats == "4" && jQuery(link).html() == "1/1"){
                jQuery(link).html('0/4');
            }
            else{
                jQuery(link).html(text.replace(text.charAt(0),parseInt(text.charAt(0),10)-1));    
            }
            jQuery(document).trigger('close.facebox');
        },
        error: function(error){
            alert(error.responseText);
            jQuery(source).show();
            jQuery(source).next().hide();
        }
    });
};


function confirm_remove(session_start_time,language, index, elem){
    var msg="This leaner will be removed from the "+session_start_time+" "+language+"  session. Do you want to proceed?";
    jQuery.alerts.okButton = 'Yes';
    jQuery.alerts.cancelButton = 'No';
    jConfirm(msg,'', function(result) {
       if(result)
       {
        removeFromSession(elem,index);
       }
    });
}

function toggleEffectiveDate(input_box_value){
    if(input_box_value === 'AS OF'){
        jQuery("#ext_date_feilds").show();
    }else{
        jQuery("#ext_date_feilds").hide();
    }
}

function toggleReason(value){
    if(value === 'Other'){
        jQuery("#other_reason").show();
    }else{
        jQuery("#other_reason").hide();
    }
}
function toggleReasonforSub(value){
    if(value === 'Other'){
        jQuery("#other_reasons").show();
    }else{
        jQuery("#other_reasons").hide();
    }
}
function reasonFocus(i){
    if(i.value === "Please enter reason for extension / removal"){
        i.value="";
        i.style.color="#000";
    }
}

function reasonBlur(i){
    if(i.value === ""){
        i.value="Please enter reason for extension / removal";
        i.style.color="#888";
    }
}
 function confirm_coach_inactive()
  {
    jQuery("#check_box_value").val(jQuery("#inactive_check").is(":checked"));
    bool = jQuery("#inactive_check").is(":checked");
    if (bool)
      msg = 'Are you sure you want to proceed ?';
    else
      msg = 'Making a coach inactive will delete all his/her existing templates and recurring sessions. Do you wish to proceed ?' ;
    var confirm_check = confirm(msg);
    if(confirm_check)
    {
      form = document.getElementById('active_coach');
      document.getElementById('update_after_check').innerHTML = '';
      jQuery('#reassign_ajaxLoader_main').show();
      $.ajax( {
        type: "POST",
        url: jQuery(form).attr('action'),
        data: jQuery(form).serialize(),
        success: function( response ) {
          jQuery('#reassign_ajaxLoader_main').hide();
          jQuery("#update_after_check").html(response);
        }
      } );
    }
    else
    {
      if(bool)
        document.getElementById('inactive_check').checked = false;
      else
        document.getElementById('inactive_check').checked = 'checked';
    }
 }

function get_languages(elem){
    jQuery('.qtip').remove();
    constructQtipWithTip(elem, 'Coach Languages', '/get-coach-language-details?id='+elem.id, {});
}

//A small utility method to take the view to the specified element. Need to pass Id to the method
var scrollToElement = function(elementId){
    var elementOffset = jQuery('#' + elementId).offset();
    jQuery('html,body').animate({
        scrollTop: elementOffset.top,
        scrollLeft:elementOffset.left
    }, 1000);
};

var updateAppointmentTypeActive = function(appt){
    active = appt.checked===true ? 1 : 0;
    jQuery.blockUI();
    jQuery.ajax({
        type : 'PUT',
        url: '/appointment_types/' + appt.id,
        dataType: 'html',
        data: {
            id : appt.id,
            appointment_type : {active : active}
        },
        success: function(data){
            jQuery.unblockUI();
        },
        failure: function(error){
            jQuery.unblockUI();
            console.log(error);
        },
        error: function(error){
            jQuery.unblockUI();
            alert("Update failed. Please try again.");
        }
    });

};

var saveAppointmentTypeTitle = function(){
    title = jQuery("#edit_appointment_type_title").val().trim();
    id = jQuery("#appointment_id").val();
    if (title.length > 0 && title.length < 20)
    {
       jQuery.ajax({
            type : 'PUT',
            url: '/appointment_types/' + id,
            dataType: 'html',
            data: {
                id : id,
                appointment_type : {title : title}
            },
            success: function(data){
                if (data === 'failure') {
                    $('#edit_appointment_type_title').val('');
                    alert('The Appointment type with the same name already exists, Please enter a different name');
                }
                else{
                    jQuery("#tr_"+id).replaceWith(data);
                    jQuery(".close_image").click();
                    jQuery("#tr_"+id).children().each(function(pos, obj){
                        createMaxWidth(obj.className, obj.className.substring(2, obj.className.length));
                    });
                }
            },
            failure: function(error){
                console.log(error);
            },
            error: function(error){
                alert("Update failed. Please try again.");
            }
        });
    return true;
   }else{
    alert("Enter a valid appointment type title.");
    return false;
   }
};

var saveAppointmentType =function(e){
    e.preventDefault();
    title = jQuery("#appointment_type_title").val().trim();
    jQuery("#appointment_type_title").val(title);
    if(title.length > 19 || title.length===0){
        alert("Enter a valid appointment type title.");
    }
        jQuery.ajax({
            type : 'POST',
            url: '/appointment_types',
            dataType: 'html',
            data: {
                appointment_type : {title : title}
            },
            success: function(status){
                if (status == "success")
                    location.reload();
                else{
                   $('#appointment_type_title').val('');
                   alert("The Appointment type with the same name already exists, Please enter a different name");
                }
            },
            failure: function(error){
                console.log(error);
            },
            error: function(error){
                alert("Update failed. Please try again.");
            }
        });
    
};

var handleRemoveProfilePictureEvents = function() {
    jQuery('#remove-pic').live('click', function(e) {
        jQuery('#remove_profile_picture').val(true);
        jQuery('#remove-pic-undo').show();
        jQuery('#remove-pic').removeAttr('href');
        jQuery('#profile-picture').css('opacity','0.4');
    });
    jQuery('#remove-pic-undo').live('click', function(e) {
        e.preventDefault();
        jQuery('#remove_profile_picture').val(false);
        jQuery('#remove-pic').attr('href','#');
        jQuery('#remove-pic-undo').hide();
        jQuery('#profile-picture').css('opacity','1');
    });
    jQuery('#upload-info').qtip({
        content: '* File size should not exceed 100 Kb<br/>* Supported Formats: .jpeg, .png, .gif<br/>* Recommended Resolution: 200x200',
        position: {
           corner: {
              tooltip: 'leftBottom'
           }
        }
    });
};
function getCook(cookiename){
  // Get name followed by anything except a semicolon
  var cookiestring=RegExp(""+cookiename+"[^;]+").exec(document.cookie);
  // Return everything after the equal sign
  return unescape(!!cookiestring ? cookiestring.toString().replace(/^[^=]+./,"") : "");
}
var delete_cookie = function(name) {
    document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
};

jQuery('#coach_alert_message').live('keyup',function(){
        text = jQuery("#coach_alert_message");
        if(text.val().length > 1000){
            text.val(text.val().substring(0, 1000));
        }
        jQuery("#char_count").html(1000 - text.val().length);

        if (text.val().trim() != jQuery("#alert_desc").val().trim() && text.val().trim().length !== 0){
            $("#publish_alert").attr("disabled",false);
        }
        else{
            $("#publish_alert").attr("disabled",true);
        }
    });

    jQuery('#coach_alert_message').live('keydown',function(e){
        text = jQuery("#coach_alert_message");
        if(text.val().length >= 1000){
            if( e.which != 8){ //accepts only backspace (key code 8) once the  length limit is reached
                return false;
            }
        }
    });

function increment_session_count(id, count){
    $('#'+id).text(parseInt(count)+1);
}

function decrement_session_count(id, count){
    $('#'+id).text(parseInt(count)-1);
}

function increment_duration(one_hour_session, count){
    if (one_hour_session == true){                
        $('#scheduled_hrs').text((parseFloat(count)+1).toFixed(1));
    }
    else{
        $('#scheduled_hrs').text((parseFloat(count)+0.5).toFixed(1));
    }
}

function decrement_duration(one_hour_session, count){
    if (one_hour_session == true){                
        $('#scheduled_hrs').text((parseFloat(count)-1).toFixed(1));
    }
    else{
        $('#scheduled_hrs').text((parseFloat(count)-0.5).toFixed(1));
    }
}