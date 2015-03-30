var last_div_height;
var from_page;
var refresh_time;
var timeout;
jQuery(document).ready(function(){
    from_page = jQuery("#from_page").val();
    last_div_height     = jQuery('#substitution_alert_div_size').val();
    refresh_time = parseInt(jQuery("#substitution_refresh_time").val(), 10);
    if(!isNaN(refresh_time)) loadSubstitution(false);
    jQuery("#substitution_alert_div").delegate("#see_all_substitutions", "click", function(){
        window.location.href = (from_page === 'cp') ? "/substitutions" : "/substitutions";
    });
    jQuery('.grab_session').live('click', function(){
        grabSubstitution(this);
    });

    jQuery('.substitutions_form').live('change', function(){
        window.location = "/substitutions?coach_id="+jQuery('#coach_id').val()+"&lang_id="+jQuery('#lang_id').val()+"&duration="+jQuery('#duration').val();
    });

    jQuery("#substitution_alert_div").delegate("#close_button", "click", function(){
        jQuery("#substitution_alert").hide();
        loadSubstitution(true);
    });

    jQuery('#assign_substitute_button').live('click', function(){
        assignCoachToSession();
    });

    jQuery('#request_substitute_button').live('click', function(){
        requestCoachForSession();
    });

    jQuery('#cancel_substitute_button_request').live('click', function(){
        jQuery(this).closest('.qtip').remove();
        jQuery(document).trigger('close.facebox');
    });
    
    jQuery('#cancel_substitute_button_assign').live('click', function(){
        jQuery(this).closest('.qtip').remove();
        jQuery(document).trigger('close.facebox');
    });

    jQuery('#cancel_session_button_substitution').live('click', function(){
        var sub_id = jQuery("#sub_id").val();
        var reason_for_sub = jQuery('#reasons option:selected').val();
        jQuery.alerts.okButton = ' OK ';
        if (reason_for_sub === "Select"){
            jAlert("Please select a reason");
            return;
           }
        if (reason_for_sub === "Other") {
            if (jQuery('#other_reasons').val().trim() === ""){
                jAlert("Please provide a reason");
                return;
            }
            else {
                reason_for_sub = "Other - " + jQuery('#other_reasons').val();
            }     
        }
        cancelSubbedSessionConfirmation(sub_id, reason_for_sub);     
    });

    jQuery('#exit_subbed_session_button').live('click', function(){
        jQuery(this).closest('.qtip').remove();
        jQuery(document).trigger('close.facebox');
    });

    jQuery('#coach_list').live('change', function (){
        jQuery('#assign_substitute_button').attr('disabled', jQuery(this).val() === "");
    });

    jQuery('#trigger_sms').live('click', function(){
        jQuery.blockUI();
        jQuery.ajax({
            url: "trigger_sms?lang_id="+jQuery('#lang_id').val(),
            success: function(res){
                alert(res);
                jQuery.unblockUI();
            }
        });
    });

    jQuery('#csv_button_id').live('click', function(){
        jQuery.blockUI();
        jQuery.ajax({
                    url: "/export-to-csv",
                    remote: true,
                    data:{
                            lang_id_hidden: jQuery('#lang_id_hidden').val(),
                            coach_id_hidden: jQuery('#coach_id_hidden').val(),
                            duration_hidden: jQuery('#duration_hidden').val(),
                            grabber_coach_id_hidden: jQuery('#grabber_coach_id_hidden').val(),
                            grabbed_within_hidden: jQuery('#grabbed_within_hidden').val(),
                            start_date_hidden: jQuery('#start_date_hidden').val(),
                            end_date_hidden: jQuery('#end_date_hidden').val()
                        },
                    success: function(data){
                        jQuery.unblockUI();
                        if(data["send"] === "true"){
                            jQuery("#export_csv_file").submit();
                        }
                        else{
                            alert("Your report was emailed to "+data["mail"]);
                        }
                    },
                    error: function(data){
                        jQuery.unblockUI();
                        alert("Something went wrong. Please try again later.");
                    },
                    failure: function(data){
                        jQuery.unblockUI();
                        alert("Something went wrong. Please try again later.");
                    }
                });
    });    

});


var cancelSubbedSessionConfirmation = function(sub_id, reason_for_sub){
    jQuery.alerts.okButton = ' YES ';
    jQuery.alerts.cancelButton = ' NO ';
    jQuery.alerts.confirm('Are you sure?', "Confirm", function(result){
        if(result){
            jQuery.blockUI({ baseZ : 17000} );
            jQuery.ajax({
                url: 'cancel_substitution',
                data: {
                    sub_id: sub_id,
                    reason: reason_for_sub || "",
                    notice: "true"
                },
                success: function(data){
                    alert(data);
                    jQuery("#cancel_subbed_session_"+sub_id).parent().parent().remove();
                    jQuery.unblockUI();
                },
                error: function(data){
                    alert(data.responseText);
                    jQuery.unblockUI();
                }
                });
            jQuery(this).closest('.qtip').remove();
            jQuery(document).trigger('close.facebox');
        }
    });
};

var refreshSubstitutionData = function(){
    if(isNaN(refresh_time)){
        window.location.reload();
    }else{
        loadSubstitution(false);
        jQuery.unblockUI();
    }
};

var assignCoachToSession = function(){
    jQuery.alerts.okButton = ' OK ';
    jQuery.alerts.cancelButton = ' CANCEL ';
    var coach = jQuery('#coach_list option:selected');
    var is_appointment = (jQuery("#is_appointment").val()==="true" || jQuery("#session_type").val() === 'appointment')? true:false;
    if(coach.val() === ""){
        jAlert("Please select a Coach.");
        return;
    }
    var message = "";
    if(coach.attr('status') === 'unavailable')
        message = "You are about to assign " + (jQuery("#session_type").val() === 'appointment' ? 'an appointment' : 'a session') + " for an Unavailable coach";

    if(coach.attr('threshold') === 'true' && is_appointment===false){
        if(message !== "") message = message + " and ";
        message = message + "Coach has reached or exceeded the threshold set for maximum number of sessions per week";
    }
    var reason_for_sub = jQuery('#reasons option:selected').val();
    if (reason_for_sub === "Select"){
        jAlert("Please select a reason");
        return;
    }
    if (reason_for_sub === "Other") {
        if (jQuery('#other_reasons').val().trim() === ""){
            jAlert("Please provide a reason");
            return;
        }
        else {
            reason_for_sub = "Other - " + jQuery('#other_reasons').val();
        }     
    }

    if(message !== "") message = message + ". ";
    message = message + "Do you wish to continue ?";

    jQuery.alerts.okButton = ' YES ';
    jQuery.alerts.cancelButton = ' NO ';
    jQuery.alerts.confirm(message, "Confirm", function(result){
        if(result){
            jQuery.blockUI({ baseZ: 20000 });
            var element;
            size = jQuery("#assign_sub").size();
            if(size>0){
                element = jQuery("#assign_sub").closest(".qtip").data("qtip").options.position.target;
            }else{
                element = jQuery("#"+jQuery("#reassign_sub").val());
            }
            jQuery.ajax({
                data:{
                    assigned_coach:coach.val(),
                    coach_session_id:jQuery('#coach_session_id').val(),
                    reason:reason_for_sub,
                    slot_time: jQuery('#slot_time').val(),
                    from_cs: jQuery('#from_cs').val()
                },
                url: '/assign_substitute_for_coach/',
                success: function(data) {
                    if(size>0){
                        if(data.label[1] == "cs_solid_session_slot"  || data.label[1] == "cs_reassigned_session_slot"){
                            if (jQuery('#is_one_hour_session').val() === "true"){
                              new CalendarEvent(data.start_time+1800).removeEvent();  
                            } 
                            slotEvents(data.start_time, data.label[0], new Date(data.start_time*1000), new Date(data.end_time*1000),data.label[1]);
                        }
                        else{
                            if (jQuery('#is_one_hour_session').val() === "true" && data.half_slot !== "second") {
                             slotEvents(data.start_time+1800, data.label[0], new Date(data.start_time*1000 + 30*60000), new Date(data.end_time*1000),data.label[1]);
                            } 
                            if(data.half_slot !== "first"){
                             slotEvents(data.start_time, data.label[0], new Date(data.start_time*1000), new Date(data.start_time*1000 + 30*60000),data.label[1]);
                            }   
                          jQuery(".qtip").remove();
                        }
                    }else{
                        jQuery.facebox.close();
                        jQuery("#"+jQuery("#reassign_sub").val()).parent().parent().remove();
                    }
                    alert(data.message);
                    jQuery.unblockUI();
                    if (jQuery("#session_type").val() != 'appointment'){
                        increment_session_count('sub_requested_count', $('#sub_requested_count').text());
                        decrement_session_count('scheduled_count', $('#scheduled_count').text());
                        decrement_duration(data.one_hour_session, $('#scheduled_hrs').text());  
                    }    
                },
                error: function(error){
                    jQuery.unblockUI();
                    alert('Something went wrong, Please try again.');
                }
            });
        }
    });
    jQuery.alerts.okButton = ' Ok ';
    jQuery.alerts.cancelButton = ' Cancel ';
};

var requestCoachForSession = function(){
    jQuery.alerts.okButton = ' OK ';
    jQuery.alerts.cancelButton = ' CANCEL ';
    var reason_for_sub = jQuery('#reasons option:selected').val();
    if (reason_for_sub === "Select"){
        jAlert("Please select a reason");
        return;
    }
    if (reason_for_sub === "Other") {
        if (jQuery('#other_reasons').val().trim() === ""){
            jAlert("Please provide a reason");
            return;
        }
        else {
            reason_for_sub = "Other - " + jQuery('#other_reasons').val();
        }     
    }
    jQuery.alerts.okButton = ' YES ';
    jQuery.alerts.cancelButton = ' NO ';
    jQuery.alerts.confirm('Are you sure?', "Confirm", function(result){
        if(result){
            jQuery.blockUI();
            jQuery.ajax({
                data:{
                    time:jQuery('#start_time').val(),
                    current_coach_id:jQuery('#coach').val(),
                    reason:reason_for_sub
                },
                url: '/request_substitute_for_coach/',
                success: function(data){
                    if (jQuery('#is_one_hour_session').val() === "true") {
                        slotEvents(data.start_time+1800, data.label[0], new Date(data.start_time*1000 + 30*60000), new Date(data.end_time*1000),data.label[1]);
                    }
                    slotEvents(data.start_time, data.label[0], new Date(data.start_time*1000), new Date(data.start_time*1000 + 30*60000),data.label[1]);
                    jQuery(".qtip").remove();
                    alert(data.message);
                    jQuery.unblockUI();
                    if (data.is_appointment == false){
                        if (data.cancelled == true){
                            increment_session_count('cancelled_count', $('#cancelled_count').text());
                        }
                        else{
                            increment_session_count('sub_requested_count', $('#sub_requested_count').text());
                        }
                        decrement_session_count('scheduled_count', $('#scheduled_count').text());
                        decrement_duration(data.one_hour_session, $('#scheduled_hrs').text());
                    }
                },
                error: function(error){
                    jQuery.unblockUI();
                    alert('Something went wrong, Please try again.');
                }
            });
        }
    });
    jQuery.alerts.okButton = ' Ok ';
    jQuery.alerts.cancelButton = ' Cancel ';
};

function loadSubstitution(isClosed){
    clearTimeout(timeout);
    jQuery.ajax({
        url : '/substitutions_alert',
        data : {
            closed: isClosed
        },
        method : 'get',
        success : function(response){
            jQuery("#substitution_alert_div").html(response);
            if(jQuery(".wc-header") !== null && jQuery('.wc-header').offset() !== null) {
                if(jQuery('.wc-header').hasClass('fix-header')) {
                    schedulerTableHeaderPosition = parseInt(jQuery('.wc-scrollable-grid').offset().top, 10);
                    if(parseInt(window.pageYOffset, 10) < schedulerTableHeaderPosition) {
                        jQuery('.wc-header').removeClass('fix-header');
                    }
                } else {
                    schedulerTableHeaderPosition = parseInt(jQuery('.wc-header').offset().top, 10);
                }
            }
            timeout = setTimeout(function(){
                loadSubstitution(false);
            }, refresh_time*1000);
        }
    });
}

function grabSubstitution(elem){
    var button = jQuery(elem);
    jQuery.blockUI();
    jQuery.ajax({
        url: '/grab_substitution?sub_id='+button.attr('id'),
        success: function(data) {
            title_ = data.error ? data.error : data.message;
            img_path = data.error ? "/images/failure.png" : "/images/success.png";
            status_line = data.status ? ("<div id = 'approval_status' style = 'display:none'>" + data.status + "</div>") : ""; 
            button.parent('td').html("<div title = '" + title_ + "'><img src = '" + img_path + "'>" + status_line);
            jQuery.unblockUI();
            if (data.is_appointment == false){
                increment_session_count('scheduled_count', $('#scheduled_count').text());
                increment_duration(false, $('#scheduled_hrs').text());
            }
         },
        error: function(data){
            jQuery.unblockUI();
            alert("There is some error, please try again.");
        }
    });
}
