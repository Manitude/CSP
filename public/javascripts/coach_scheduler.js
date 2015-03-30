jQuery(document).ready(function(){
    var cancel_triggering_element;
    populateCoachesForLanguage();
    bindFormElements();
    if (jQuery('select#coach').val() !== "") {
        createCalenderInCoachScehduler();
    }

    jQuery('select#language_id').live('change', function() {
        var elem = jQuery(this);
        language_change(elem.val(), elem.attr("from") == "edit",elem);
    });

    jQuery('select#session_type').live('change', function(){
        session_type_change();
    });

    jQuery('select#number_of_seats_aria').live('change', function() {
        choose_no_of_seats(jQuery(this));
    });

    jQuery('select#cefr').live('change', function() {
        var elem = jQuery(this);
        choose_topics(elem.val());
    });

    jQuery('input#create_session_button').live('click', function() {
        confirmSessionCreationFromCoachSchedule();
    });

    jQuery('input#cancel_session_button_coach_scheduler').live('click', function() {
        reason = validateReason();
        if(reason === -1)
            return;
        confirmationForCoachEdit(window.cancel_triggering_element, reason);
    });

    jQuery('#session_details_text').live('keyup',function(){
        text = jQuery("#session_details_text");
        if(text.val().length > 500){
            text.val(text.val().substring(0, 500));
        }
        jQuery("#char_count").html(500 - text.val().length);

    });

    jQuery('#session_details_text').live('keydown',function(e){
        text = jQuery("#session_details_text");
        if(text.val().length >= 500){
            if( e.which != 8){ //accepts only backspace (key code 8) once the  length limit is reached
                return false;
            }
        }
    });

    jQuery('#session_details_text_edit').live('keyup',function(){
        text = jQuery("#session_details_text_edit");
        if(text.val().length > 500){
            text.val(text.val().substring(0, 500));
        }
        jQuery("#char_count").html(500 - text.val().length);

    });

    jQuery('#session_details_text_edit').live('keydown',function(e){
        text = jQuery("#session_details_text_edit");
        if(text.val().length >= 500){
            if( e.which != 8){ //accepts only backspace (key code 8) once the  length limit is reached
                return false;
            }
        }
    });

    jQuery('span.enable_sub_links').live('click', function(){
        jQuery(".qtip:hidden").remove();
        if (jQuery('#request_sub').attr('id') === 'request_sub'){
            if(jQuery("#is_appointment").val() === 'false') //don't check sub violation policy if appointment
                checkSubViolation(jQuery(this).attr('id'));
            else if (jQuery(this).attr('id') === 'request_sub')
                constructQtipWithTip(jQuery("#request_sub"), 'REQUEST SUBSTITUTE','/reason_for_sub_request?current_coach_id='+jQuery('#coach').val()+'&time='+ Date.parse(jQuery('#start_time').val())+"&is_appointment=true",{solo:false, remove:false});
            else
                constructQtipWithTip(jQuery("#assign_sub"), 'ASSIGN SUBSTITUTE','/fetch_available_coaches?fetch_reason=true&session_id='+jQuery('#coach_session_id').val()+"&is_appointment=true",{solo:false, remove:false});
        }
        else{
            constructQtipWithTip(jQuery("#assign_sub"), 'ASSIGN SUBSTITUTE','/fetch_available_coaches?fetch_reason=false&session_id='+jQuery('#coach_session_id').val(),{solo:false, remove:false});
        }

    });

    jQuery('.quick_details').live('click', function(){
        var elem = this;
        var title = this.attributes['is_appointment'].value==="true" ? "APPOINTMENT DETAILS" : 'SESSION DETAILS';
        constructQtipWithTip(elem, title, '/coach_session_details/' + jQuery(elem).attr('start_time'), {solo:false, remove:false});
    });
});

function launchAriaSession(element, coach_session_id, student_guid){
    config = "menubar=0,resizable=1,scrollbars=0,toolbar=0,location=0,directories=0,status=0,top=0,left=0";
    jQuery.blockUI();
    jQuery.ajax({
            type: 'post',
            data:{
                coach_session_id: coach_session_id,
                student_guid: student_guid
            },
            url: '/aria_launch_url',
            success: function(result) {
                jQuery.unblockUI();
                child_window = window.open(result, "launch_window", config);
            },
            failure: function(error){
                jQuery.unblockUI();
                console.log(error);
                alert(error.responseText);
            },
            error: function(error){
                jQuery.unblockUI();
                console.log(error);
                alert(error.responseText);
            }
    });

}


function checkSubViolation(type){
    jQuery.ajax({
            type: 'get',
            async: false,
            dataType: 'json',
            url: '/check_sub_policy_violation?start_time='+ Date.parse(jQuery('#start_time').val()) +'&coach_id='+jQuery('#coach').val(),
            success: function(data) {
                substitution = true;
                if (data["violation"] === "true")
                   {
                     if(!confirm("This substitution request is in violation of the Studio team's Substitution policy. Substitution(s) were already requested for "+data["text"]+". Would you like to proceed?")){
                        substitution = false;
                     }
                    }
                if ( substitution === true) {
                    if(type === 'request_sub')
                        constructQtipWithTip(jQuery("#request_sub"), 'REQUEST SUBSTITUTE','/reason_for_sub_request?current_coach_id='+jQuery('#coach').val()+'&time='+ Date.parse(jQuery('#start_time').val()),{solo:false, remove:false});
                    else
                        constructQtipWithTip(jQuery("#assign_sub"), 'ASSIGN SUBSTITUTE','/fetch_available_coaches?fetch_reason=true&session_id='+jQuery('#coach_session_id').val(),{solo:false, remove:false});
                }
            },
            failure: function(error){
                console.log(error);
                alert('Something went wrong, Please report this problem');
            },
            error: function(error){
                console.log(error);
                alert('Something went wrong, Please report this problem');
            }
    });
}

var bindFormElements = function() {
    if (jQuery("#language").val() === ""){
        jQuery("#language_category").val("");
    }
    jQuery('select#language_category').live('change',function(){
        jQuery('select#coach').attr('disabled', true);
        jQuery('select#coach').val("");
    });
    jQuery('select#language').live('change', function() {
        populateCoachesForLanguage();
        if (jQuery('#coach').val() !== "") {
            jQuery('select#filter_language').val("all");
            redirectPage();
        }
    });

    jQuery('#go_button').live('click', function() {
        validateData();
        jQuery('select#filter_language').val("all");
        redirectPage();
    });

    jQuery('#filter_language').live('change', function() {
        validateData();
        redirectPage();
    });

    jQuery('#upcoming_classes_btn').live('click', function(event) {
        event.preventDefault();
        upcomingSessions(coach_id_for_upcoming_sessions,'*', this);
    });

    jQuery('#edit_session_form #ce_sess_recurring #recurring').live('change', function() {
        if(jQuery('#ce_sess_recurring_ends'))
            jQuery('#ce_sess_recurring_ends').toggle();
    });
};

var createCalenderInCoachScehduler = function() {
    if (jQuery('#coach').val() !== "") {
        createCalendar({
            date: new Date(jQuery("#start_date").val()),
            readonly: false,
            allowCalEventOverlap: false,
            newEventText: '',
            defaultEventLength: 1,
            timeslotsPerHour: 2,
            timeslotHeight: 50,
            height: function($calendar){
            return 2450;
            },
            deletable: function(calEvent, element) {
                return false;
            },
            draggable: function(calEvent, element) {
                return false;
            },
            resizable: function(calEvent, element) {
                return false;
            },
            eventClick: function(calEvent, element) {
                slotOnClick(calEvent, element);
            },
            eventRender: function(calEvent, $event) {
                if ((calEvent.start.getTime() < new Date().getTime()) || (calEvent.slotType === 'recurring')) {
                    $event.css("cursor", "default");
                }
            },
            eventAfterRender: function(calEvent, element){
                jQuery(element).find('.wc-time').remove();
                element.addClass(   calEvent.slotType);
                jQuery(element).removeClass("wc-new-cal-event");
            },
            beforeEventNew: function($event, ui) {
                return true;
            },
            eventNew: function(calEvent, element, dayFreeBusyManager, calendar, mouseupEvent) {
                createSessionOnAvailableSlot(calEvent, element);
            }
        });
        populateSlots();
    }
};

var validateData = function() {
    if (jQuery('#language').val() === "") {
        alert("Please Select a Language.");
        return false;
    }
    if (jQuery('#coach').val() === "") {
        alert("Please Select a Coach.");
        return false;
    }
    return true;
};

var redirectPage = function() {
    var coach = jQuery('#coach').val();
    if(coach === undefined){
        window.location = '/my_schedule/'+jQuery('#my_schedule_language').val() + '/' + currentSelectedDateAsString();
    }else if(coach !== ""){
        var filter_lang = jQuery('#filter_language').val();
        if(filter_lang === undefined) filter_lang = "all";
        window.location = '/coach_scheduler/' + jQuery('#language').val() + '/' + coach + '/' + filter_lang + '/' + currentSelectedDateAsString();
    }
};

var id = 1;
var populateCoachesForLanguage = function() {
    var language = jQuery('#language').val();
    var coach = jQuery('#coach');
    coach.attr('disabled', true);
    coach.html('<option value="">Select a Coach</option>');
    if (language !== "" && coach.val() !== undefined) {
        jQuery.ajax({
            type: 'get',
            async: false,
            url: '/coaches_for_given_language/' + language,
            success: function(data) {
                if( data.text.length > 0){
                    coach.html(data.text);
                }
                coach.val(jQuery('#selected_coach').val());
                coach.attr('disabled', false);
            }
        });
    }
};

var populateSlots = function() {
    jQuery.each(data, function(i, elem) {
        var event = new CalendarEvent(elem.start_time, elem.label, new Date(elem.start_time*1000), new Date(elem.end_time*1000));
        event.slotType = elem.slot_type;
        event.createEvent();
    });
};

var slotOnClick = function(calEvent, element) {
    if(calEvent.slotType !== 'cs_recurring_slot' && calEvent.slotType !== 'daylight_switch' && calEvent.slotType !== 'cs_appointment_recurring_session_slot'){
        if (['cs_cancelled', 'cs_solid_session_slot', 'cs_appointment_session_slot', 'cs_sub_canl_session_slot', 'cs_sub_needed_solid_session_slot','cs_sub_needed_appointment_session_slot','cs_reassigned_session_slot','cs_reassigned_appointment_session_slot'].indexOf(calEvent.slotType) !== -1) {
            getSelectedSlotDetails(calEvent, element);
        }else{
            createSessionOnAvailableSlot(calEvent, element);
        }
    }
};

var cancelledCreatePopup = function(language, start_time, cell_status, element){
    element = jQuery(element).closest('.qtip').data('qtip').options.position.target ;
    var title_start = (jQuery('#my_coach_id').val()===undefined) ? 'CREATE NEW SESSION/APPOINTMENT at ' : 'CREATE NEW APPOINTMENT at ';
    constructQtipWithTip(element, title_start + formatDateForPopup(new Date(start_time*1000)), '/create_session_form_in_coach_scheduler?coach_id=' + jQuery('#coach').val() + '&start_time=' + start_time + '&cell_type=' + cell_status + '&language=' + language, {});
};


var createSessionOnAvailableSlot = function(calEvent, element){
    var start_time = calEvent.start.getTime();
    var now = Date.now();
    var session_start_time = new Date(start_time);
    var duration = new Date(session_start_time.setMinutes(session_start_time.getMinutes() + parseInt(jQuery('#allow_session_creation_after').val(),10)));
    var coach = jQuery('#coach').val();
    if (jQuery('#my_coach_is_tmm').val()==='true') {
        coach = jQuery('#my_coach_id').val();
    }
    var lang = jQuery('#language').val();
    var aria_only = jQuery('#is_only_aria').val();
    var is_totale = jQuery('#is_totale').val();
    if(coach && (start_time > now || is_totale == 'true' )){
        var createSession = true;
        if (calEvent.slotType == 'cs_time_off_slot'){
            timeoff_message = (jQuery('#my_coach_id').val()===undefined) ? 'a session/appointment' : 'an appointment';
            createSession = confirm('You are about to create ' + timeoff_message + ' on a time off slot. Do you want to proceed?');
        }
        if(createSession){
            if(coach && (start_time > now || (duration > now & aria_only == 'false'))){ // Disallow session creation pop up after start time for aria-only coaches
                var cell_status = (calEvent.title.indexOf('Available') >= 0) ? "available" : "unavailable";
                var title_start = (jQuery('#my_coach_id').val()===undefined) ? 'CREATE NEW SESSION/APPOINTMENT at ' : 'CREATE NEW APPOINTMENT at ';
                constructQtipWithTip(element, title_start + formatDateForPopup(calEvent.start), '/create_session_form_in_coach_scheduler?coach_id=' + coach + '&start_time=' + start_time/1000 + '&cell_type=' + cell_status + '&language=' + jQuery('#filter_language').val(), {});
            }
        }
    }
};

var getSelectedSlotDetails = function(calEvent, element) {
    var start_time = calEvent.start.getTime() / 1000;
    var coach_id = jQuery('#coach').val();
    var path = '/coach_session_details/' + start_time + '/';
    if(coach_id) path = path  + coach_id;
    var header="";
    if ((calEvent.slotType === "cs_solid_session_slot") || (calEvent.slotType === "cs_reassigned_session_slot") || (calEvent.slotType === "cs_sub_needed_solid_session_slot")){
        header = "SESSION DETAILS";
    }else if((calEvent.slotType === "cs_appointment_session_slot") || (calEvent.slotType === "cs_reassigned_appointment_session_slot") || (calEvent.slotType === "cs_sub_needed_appointment_session_slot")){
        header = "APPOINTMENT DETAILS";
    }else{
        header = "SESSION/APPOINTMENT DETAILS";
    }
    constructQtipWithTip(element, header , path, {});
};

var confirmSessionCreationFromCoachSchedule = function(){
    var recurrence_checked = jQuery('#recurring ').is(':checked');
    setAvailableField();
    var header = jQuery("#session_type").val() === 'appointment' ? 'appointment' : 'session';
    var availability = jQuery('#availability').val();
    var no_existing_template = jQuery('#no_existing_template').val();
    if (recurrence_checked && no_existing_template === "true") {
        alert('This coach has no template. So recurring ' + header + ' cannot be created. Please create a template.');
        return;
    }
    if (recurrence_checked && availability === 'unavailable'){
        jQuery.alerts.okButton = 'YES, CONTINUE';
        jQuery.alerts.cancelButton = 'NO, DO NOT MAKE RECURRING';
        var message = 'The coach is unavailable at this time. Are you sure you want to create a recurring ' + header + '?';
        jQuery.alerts.confirm(message, "Confirm", function(result) {
            jQuery('#recurring ').attr('checked', result);
            confirmSessionCreation();
        });
    }else{
       confirmSessionCreation();
    }
};

var setAvailableField = function(){
    var selected_language = jQuery('#language_id').val();
    var splitted_lang = selected_language.toString().split("-");
    if (selected_language === "AUS" || selected_language === "AUK" || (("TMM" == splitted_lang[0]) && ("L" == splitted_lang[splitted_lang.length-1]) && (jQuery('#session_type').val() === "session" || jQuery('#is_appointment').val()==="false")) ){
        jQuery('#availability').val(jQuery('#full_slot_availability').val());
    }
};

var confirmSessionCreation = function(){
    var session_details = jQuery('#session_details_text').val();
    var appointment_type = jQuery('#appointment_type_id').val();
    var selected_language = jQuery('#language_id').val();
    var splitted_lang = selected_language.toString().split("-");
    var path, number_of_seats;
    var topic_id = jQuery('#topic').val();
    var lesson = jQuery('#lesson').val();
    var unit = jQuery('#unit').val();
    var session_type = jQuery('#session_type').val();
    if (selected_language === "AUS" || selected_language === "AUK"){
        number_of_seats = jQuery('#number_of_seats_aria').val();
    }else{
        number_of_seats = jQuery('#number_of_seats').val();
        if ((("TMM" == splitted_lang[0]) && ("P" == splitted_lang[splitted_lang.length-1]) ) || (selected_language === "TMM-MCH-L"))
        {
            number_of_seats = 1;
        }
        topic_id = undefined;
    }
    var teacher_confirmed = jQuery('#teacher_confirmed').is(':checked');
    var selected_lang = jQuery("#language_id").val();
    var start_time = jQuery("#start_time").val();
    var threshold_reached = jQuery.parseJSON(jQuery("#threshold_reached").val());
    var all_languages_max_unit = jQuery('#all_languages_max_unit').val();
    var availability = jQuery('#availability').val();
    var lotus_languages = jQuery('#lotus_languages').val();
    var coach_id = jQuery('#coach_id').val();
    var village_id = jQuery('#village_id').val();
    var recurrence_checked = jQuery('#recurring ').is(':checked');
    var recurring_ends_at = jQuery('#recurring_ends_at').val();
    var aria_recurring_ends_at = jQuery('#aria_recurring_ends_at').val();
    splitted_lang = selected_lang.toString().split("-");

    if (recurrence_checked) {
        header = session_type === "appointment" ? "appointment" : "session";
        if (recurring_ends_at !== "false" && (["AUK","AUS"].toString().search(selected_lang.toString())==-1) && !("TMM" == splitted_lang[0] && "L" == splitted_lang[splitted_lang.length-1])){
            if(!confirm("Due to conflicts with this Coach's availability template, the last " + header + " for this recurrence would take place on "+recurring_ends_at+". Do you wish to proceed with scheduling this " + header + "?")) return;
        }
        if (aria_recurring_ends_at !== "false" && ( ["AUK","AUS"].toString().search(selected_lang.toString())!=-1 || ("TMM" == splitted_lang[0] && "L" == splitted_lang[splitted_lang.length-1]))) {
            if(!confirm("Due to conflicts with this Coach's availability template, the last " + header + " for this recurrence would take place on "+aria_recurring_ends_at+". Do you wish to proceed with scheduling this " + header + "?")) return;
        }
    }
    if(selected_lang === "all"){
        alert("Please select a language to continue.");
        return;
    }
    if(session_type === "appointment" && appointment_type === "all"){
        alert("Please select an appointment type to continue.");
        return;
    }
    if (selected_language === "AUS" || selected_language === "AUK"){
        if (jQuery('#number_of_seats_aria').val() === "--") {
            alert('Please select a valid number of seats.');
            return;
        }
        if (jQuery("#number_of_seats_aria").val() > 1){
            if( jQuery("#cefr").val() == "--" )
                {
                    alert('Please select a proper CEFR level and topic.');
                    return;
                }
            if( jQuery("#topic").val().length  === 0 )
                {
                    alert('Please select a proper topic.');
                    return;
                }
        }

    }
    /*if ("TMM" == selected_lang.toString().split("-")[0]) {
        if (jQuery("#session_details_text").val().length === 0) {
            alert('Please enter valida data in Session details');
            return;
        }
    }*/
    if(jQuery.parseJSON(jQuery('#lotus_languages').val()).indexOf(selected_lang.toString()) === -1 && ("TMM" != selected_lang.toString().split("-")[0])){
        var max_unit = jQuery.parseJSON(jQuery('#all_languages_max_unit').val())[selected_lang];
        var level = jQuery('#level').val();
        lesson = jQuery('#lesson').val();
        unit = jQuery('#unit').val();
        if(lesson === undefined){
            if(level === '--' ^ unit === '--'){
                jAlert("Either select both level and unit or none for wildcard.");
                return;
            }else{
                var qual_level_unit = unit_level_from_max_unit(max_unit);
                if(parseInt(level, 10) > qual_level_unit[0] || parseInt(unit, 10) > qual_level_unit[1]){
                    jAlert("Coach is not qualified to teach selected level and unit.");
                    return;
                }
            }
        }else{
            if(lesson === '--' ^ unit === '--'){
                jAlert("Either select both unit and lesson or none for wildcard.");
                return;
            }else{
                if(parseInt(unit, 10) > parseInt(max_unit, 10)){
                    jAlert("Coach is not qualified to teach selected unit.");
                    return;
                }
            }
        }
    }
    if (threshold_reached[1] === true && session_type === 'session') {
        if (!confirm("The Coach has reached or exceeded the threshold set for maximum number of sessions per week.Would you like to continue?")) return;
    }
    jQuery('input.button_shape').attr("disabled", "disabled");
    jQuery.blockUI();
    jQuery.ajax({
        type: "post",
        async: true,
        data: {
            topic_id: topic_id,
            start_time: start_time,
            lesson: lesson,
            number_of_seats: number_of_seats,
            unit: unit,
            threshold_reached: threshold_reached,
            all_languages_max_unit: all_languages_max_unit,
            availability: availability,
            lotus_languages: lotus_languages,
            teacher_confirmed: teacher_confirmed,
            coach_id: coach_id,
            language_id: selected_lang,
            village_id: village_id,
            recurring: recurrence_checked,
            session_details: session_details,
            session_type: session_type,
            appointment_type_id: appointment_type
        },
        url: "/create_eschool_session_from_coach_scheduler",
        success: function(data) {
            var element = jQuery("#create_session_button").closest(".qtip").data("qtip").options.position.target;
            var event = new CalendarEvent(jQuery(element).data('calEvent').id, data.label, new Date(data.start_time), new Date(data.end_time));
            var second_event = new CalendarEvent(new Date(data.second_slot_start_time).getTime()/1000);
            if(data.aria_session === true){
                jQuery("#is_one_hour_session").val(data.aria_session);
                second_event.removeEvent();
            }
            event.slotType = (session_type=='session') ? "cs_solid_session_slot":"cs_appointment_session_slot";
            event.createEvent();
            jQuery(".qtip").remove();
            alert(data.message);
            jQuery.unblockUI();
            if (session_type == 'session'){
                increment_session_count('scheduled_count', $('#scheduled_count').text());
                increment_duration(data.aria_session, $('#scheduled_hrs').text());
            }
        },
        error:function(data){
            alert(data.responseText);
            jQuery.unblockUI();
            jQuery(".qtip").remove();
        }
    });
    return;
};

var enableDisableElements = function(flag){
        jQuery("#village_div,#level_unit_div,#number_of_seats_div,#teacher_confirmed_div").show();
        jQuery("#cefr_div,#topic_div,#number_of_seats_aria_div").hide();
    if (jQuery("#slot_warning").attr("empty") === "true") jQuery("#slot_warning").html("");
    jQuery('input#teacher_confirmed,#wildcard,#lesson,#village_id,#number_of_seats,#level,#unit').attr('disabled', flag);
};
var enableDisableAriaElements = function(flag){
        jQuery("#village_div,#level_unit_div,#number_of_seats_div,#cefr_div,#topic_div,#teacher_confirmed_div").hide();
        jQuery("#number_of_seats_aria_div").show();
        jQuery('input#number_of_seats_aria,#number_of_seats_aria').prop('selectedIndex',0);
    if (jQuery("#slot_warning").attr("empty") === "true") jQuery("#slot_warning").html("");
    // jQuery('input#teacher_confirmed,#wildcard,#level,#topic,#cefr').attr('disabled', flag);
};

var toggleRecurringAndNote = function(flag){
    if (jQuery("#recurring_not_allowed").val() === "false")
    jQuery("#slot_warning").attr("hidden",flag);
};

var recurringCheckWhileCreation = function(attr_name){
    if (jQuery(attr_name).val() == "false"){
            jQuery('input#recurring').attr('checked',false);
    }
    else{
        jQuery('input#recurring').attr('checked',true);
    }
};

var timeOffAlertForAria = function(){
    var time_off_alert = false;
    if (jQuery('#time_off_in_current_slot').val() !== "true" && jQuery('#time_off_in_other_half_slot').val() === "true"){
        timeoff_message = (jQuery('#my_coach_id').val()===undefined) ? 'a session/appointment' : 'an appointment';
        time_off_alert = confirm('You are about to create ' + timeoff_message + ' on a time off slot. Do you want to proceed?');
        if (time_off_alert === false) {
        jQuery('#create_session_button').closest('.qtip').remove();
        }
    }
};

var handleRecurring = function(from_edit){
    if (jQuery('#availability').val() === "unavailable"){
            jQuery("#slot_warning").html("<b> Note: This coach is unavailable, per their template. </b>");
            jQuery("#slot_warning").attr("hidden",false);
    }
    if(from_edit){
        if (jQuery("#recurring_not_allowed").val() === "true") jQuery('input#recurring').attr('disabled', true);
    }
    else{
        if (jQuery("#recurring_not_allowed").val() === "true"){
            jQuery('input#recurring').attr('checked',false);
            jQuery('input#recurring').attr('disabled', true);
            jQuery("#slot_warning").html("<b> Note: This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time. </b>");
            jQuery("#slot_warning").attr("hidden",false);
        }
        else{
            jQuery('input#recurring').attr('disabled', false);
        }
    }
};

var handleAriaRecurring = function(from_edit){
    if (jQuery('#full_slot_availability').val() === "unavailable"){
            jQuery('input#recurring').attr('checked',false);
            jQuery("#slot_warning").html("<b> Note: This coach is unavailable, per their template. </b>");
            jQuery("#slot_warning").attr("hidden",false);
    }
    if (jQuery('#aria_recurring_not_allowed').val() === "true") {
            jQuery("#slot_warning").html("<b> Note: This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time. </b>");
            jQuery("#slot_warning").attr("hidden",false);
    }
    if(from_edit){
        if (jQuery("#recurring_disabled").val() === "true") jQuery('input#recurring').attr('disabled', true);
    }
    else{
        if (jQuery("#aria_recurring_not_allowed").val() === "true"){

            jQuery('input#recurring').attr('checked',false);
            jQuery('input#recurring').attr('disabled', true);
        }
        else{
            jQuery('input#recurring').attr('disabled', false);
        }
    }
};

var editOperations = function(selected_lang, from_edit){
    if(jQuery('#is_one_hour_session').val() === "false"){
        language_change(selected_lang, from_edit) ; // language change method is used to manipulate elements while create as well as edit
        if (selected_lang === jQuery('#previous_language').val()) {
                jQuery('#cancel_remove_button').show();
                jQuery('#village_id').val(jQuery('#previous_village').val());
                jQuery('#level').val(jQuery('#previous_level').val());
                jQuery('#unit').val(jQuery('#previous_unit').val());
                jQuery('#lesson').val(jQuery('#lesson').val());
                jQuery('#number_of_seats').val(jQuery('#previous_seats').val());
            } else {
                jQuery('#cancel_remove_button').hide();
                jQuery('#village_id').val("");
                jQuery('#level').val("--");
                jQuery('#unit').val("--");
                jQuery('#lesson').val("--");
                jQuery('#number_of_seats').val("4");
            }
            if (((jQuery('#level') && jQuery('#level').val() === "--")||(jQuery('#lesson') && jQuery('#lesson').val() === "--")) && jQuery('#unit').val() === "--") {
                jQuery('#wildcard').attr('checked', true);
                jQuery('#level').attr('disabled', true);
                jQuery('#unit').attr('disabled', true);
                jQuery('#lesson').attr('disabled', true);
            } else {
                jQuery('#wildcard').attr('checked', false);
                jQuery('#level').attr('disabled', false);
                jQuery('#unit').attr('disabled', false);
                jQuery('#lesson').attr('disabled', false);
            }
    }
};

function choose_no_of_seats(elem) {

    jQuery("#cefr").val("--");
    jQuery("#topic").val("");
    if (elem.val() === '6'){
        elem.closest('.qtip').css('margin-top','-40px');
        jQuery("#cefr_div,#topic_div").show();
        jQuery('input#topic,#topic').attr('disabled', true);
        /*if (jQuery('#slot_warning').html().length > 100) {
            elem.closest('.qtip').css('height','200px');
        }
        else {
            elem.closest('.qtip').css('height','180px');
        }*/
    }
    else{
        elem.closest('.qtip').css('margin-top','0px');
        jQuery("#cefr_div,#topic_div").hide();
        /*if (jQuery('#slot_warning').html().length > 100) {
            elem.closest('.qtip').css('height','175px');
        }
        else {
            elem.closest('.qtip').css('height','150px');
        }*/

    }
}

function choose_topics(cefrLevel) {
    var topic = jQuery('#topic');
    if (cefrLevel == '--'){
        topic.attr('disabled', true);
        topic.prop('selectedIndex',0);
    }
    else{
        var language = jQuery('#language_id').val();
        topic.html('<option value="">-Topic-</option>');
        if (language !== "" && topic.val() !== undefined) {
            jQuery.ajax({
                type: 'get',
                async: false,
                dataType: 'json',
                url: '/topic_for_cefr_and_given_language/' + language +'/'+ cefrLevel,
                success: function(data) {
                    jQuery.each(data, function(id, title) {
                        topic.append('<option value=' + id + '>' + title + '</option>');
                    });
                    topic.attr('disabled', false);
                },
                failure: function(error){
                console.log(error);
                alert('Something went wrong, Please report this problem');
                },
                error: function(error){
                    console.log(error);
                    alert('Something went wrong, Please report this problem');
                }
            });
        }
    }
}

var session_type_change = function(){
    var splitted_lang = jQuery("#language_id").val().toString().split("-");
    if (jQuery("#session_type").val() === "appointment") {
        jQuery("#appointment_type_div").show();
        jQuery("#session_details_header").html("<b>Appointment details: </b>");
        jQuery("#aria_note").attr("hidden",true);
        recurringCheckWhileCreation("#non_aria_availability");
        jQuery("#slot_warning").attr("hidden",(jQuery('#non_aria_availability').val()==="true"));
    }else {
        jQuery("#appointment_type_div").hide();
        jQuery("#session_details_header").html("<b>Session details: </b>");
        if (("L".search(splitted_lang[splitted_lang.length-1])) != -1) {
            jQuery("#aria_note").attr("hidden",false);
            recurringCheckWhileCreation("#aria_availability");
            jQuery("#slot_warning").attr("hidden",(jQuery('#aria_availability').val()==="true"));
        }else{
            jQuery("#aria_note").attr("hidden",true);
            recurringCheckWhileCreation("#non_aria_availability");
            jQuery("#slot_warning").attr("hidden",(jQuery('#non_aria_availability').val()==="true"));
        }
    }
};

var language_change = function(selected_lang, from_edit,elem) {
    var my_coach_tmm = jQuery('#my_coach_id').val() && jQuery('#my_coach_is_tmm').val();
    jQuery("#session_details_text_div").hide();
    jQuery("#appointment_type_div").hide();
    jQuery("#session_details_header").html("<b>Session details: </b>");
    jQuery("#session_type_div").hide();
    if (jQuery('#session_type option[value="session"]').length === 0 && my_coach_tmm!=="true") {
        jQuery("#session_type").prepend(new Option("Session", "session"));
        jQuery("#session_type").val("session");
    }
    jQuery("#session_details_text_div_edit").hide();
    jQuery("#language_div").css('width','160px');
    if (selected_lang === 'all') {
        enableDisableElements(true);
        // Next 2 lines to hide note and uncheck and disable recurring whenever select a language is selected.
        jQuery('input#recurring').attr('checked',false);
        jQuery('input#recurring').attr('disabled', true);
        jQuery("#slot_warning").attr("hidden",true);
        jQuery("#aria_note").attr("hidden",true);
        jQuery('#max_qual_of_the_coach').text("");
        jQuery("#number_of_seats_div,#number_of_seats_aria_div,#cefr_div,#topic_div,#level_unit_div,#village_div").hide();
        // to adjust position of qtip that gets affected as we display/hide divisions.
        if(elem !== null){
            var qtip = elem.closest('.qtip');
            if (qtip.css('margin-top') === "-40px"){
                qtip.css('margin-top','0px');
            }
        }
        jQuery("#recurring_confirmed_checkboxes").css('margin-top','0px');
        /*elem.closest('.qtip').css('height','140px');*/
    }
    else if(["AUK","AUS"].toString().search(selected_lang.toString())!=-1){ //If selected language is aria
        if (selected_lang === jQuery('#previous_language').val()) {
            jQuery('#number_of_seats').val(jQuery('#previous_seats').val());
        }else{
            jQuery('#number_of_seats').val(6);
        }
        timeOffAlertForAria(); //Use this for Onehour sessions with second slot having timeoff
        enableDisableAriaElements(true);
        if (!from_edit){
            elem.closest('.qtip').css('margin-top','0px');
            recurringCheckWhileCreation("#aria_availability");
            jQuery("#aria_note").attr("hidden",false);
            /*if (jQuery('#slot_warning').html().length > 100) {
                elem.closest('.qtip').css('height','175px');
            }
            else {
                elem.closest('.qtip').css('height','150px');
            }*/
            jQuery("#language_div").css('width','180px');
        }
        handleAriaRecurring(from_edit); //Handle second slot availability cases for one hour sesion
        jQuery('#max_qual_of_the_coach').text("");
        jQuery("#recurring_confirmed_checkboxes").css('margin-top','0px');

    }
    else if (["AUK","AUS","KLE"].toString().search(selected_lang.toString())==-1 && ("TMM".search(selected_lang.toString().split("-",1))) == -1) {  //If selected language is not aria, not tmm and not reflex
        if (selected_lang === jQuery('#previous_language').val()) {
            jQuery('#number_of_seats').val(jQuery('#previous_seats').val());
        }else{
            jQuery('#number_of_seats').val(4);
        }
        enableDisableElements(false);
        handleRecurring(from_edit);
        var max_unit = jQuery.parseJSON(jQuery('#all_languages_max_unit').val())[selected_lang];
        maxlevel(max_unit);
        if (from_edit) {
            jQuery('#cancel_remove_button').val("CANCEL");
        }else{
            elem.closest('.qtip').css('margin-top','-40px');
            recurringCheckWhileCreation("#non_aria_availability");
            jQuery("#aria_note").attr("hidden",true);
           /* if (jQuery('#slot_warning').html().length > 100) {
                elem.closest('.qtip').css('height','220px');
            }
            else {
                elem.closest('.qtip').css('height','190px');
            }*/
        }
        jQuery("#recurring_confirmed_checkboxes").css('margin-top','0px');
    }
    else if (("TMM".search(selected_lang.toString().split("-",1))) != -1) {
        //jQuery("#recurring_confirmed_checkboxes").css('margin-top','95px');
        jQuery("#session_type_div").show();
        var splitted_lang = selected_lang.toString().split("-");
        enableDisableElements(true);
        if (("L".search(splitted_lang[splitted_lang.length-1])) != -1) {
            if (jQuery("#has_appointment_in_other_half").val()==="true")
            {
                jQuery('#session_type option[value="session"]').remove();
            }
            if (my_coach_tmm !== 'true')
                 timeOffAlertForAria(); //Use this for Onehour sessions with second slot having timeoff
            if(!from_edit){
                if (jQuery('#session_type').val()=='appointment' || jQuery('#is_appointment').val()==='true'){
                    recurringCheckWhileCreation("#non_aria_availability");
                }else{
                    recurringCheckWhileCreation("#aria_availability");
                }
            }
            if (jQuery('#session_type').val()=='appointment' || jQuery('#is_appointment').val()==='true'){
                jQuery("#aria_note").attr("hidden",true);
                handleRecurring(from_edit);
            }else
            {
                jQuery("#aria_note").attr("hidden",false);
                handleAriaRecurring(from_edit);
            }
        }
        else {
            if (jQuery('#session_type option[value="session"]').length === 0 && my_coach_tmm!=="true") {
                jQuery("#session_type").prepend(new Option("Session", "session"));
                jQuery("#session_type").val("session");
            }
            jQuery("#aria_note").attr("hidden",true);
            handleRecurring(from_edit);
             if(!from_edit){
                recurringCheckWhileCreation("#non_aria_availability");
            }
        }
        if (!from_edit) {
            session_type_change();
            elem.closest('.qtip').css('margin-top','0px');
            jQuery("#session_details_text_div").show();
            /*if (jQuery('#slot_warning').html().length > 100) {
               elem.closest('.qtip').css('height','275px');
            }
            else{
                elem.closest('.qtip').css('height','250px');
            }*/
            jQuery("#language_div").css('width','180px');
        }
        else {
            jQuery('#cancel_remove_button').val("CANCEL");
            jQuery("#session_details_text_div_edit").show();
        }
        jQuery("#number_of_seats_div,#number_of_seats_aria_div,#cefr_div,#topic_div,#level_unit_div,#village_div").hide();
    }
    else {
        enableDisableElements(true);
        handleRecurring(from_edit);
        if (selected_lang != jQuery('#previous_language').val()) {
            jQuery('#number_of_seats').val(4);
        }
        jQuery('#max_qual_of_the_coach').text("");
        if (from_edit) {
            jQuery('#cancel_remove_button').val("REMOVE");
            jQuery('#recurring').css('margin-top','10px');
        }else{
            elem.closest('.qtip').css('margin-top','0px');
            recurringCheckWhileCreation("#non_aria_availability");
            jQuery("#aria_note").attr("hidden",true);
            /*if (jQuery('#slot_warning').html().length > 100) {
                elem.closest('.qtip').css('height','155px');
            }
            else {
                elem.closest('.qtip').css('height','130px');
            }*/
        }
        jQuery("#recurring_confirmed_checkboxes").css('margin-top','0px');
        jQuery("#number_of_seats_div,#number_of_seats_aria_div,#cefr_div,#topic_div,#level_unit_div,#village_div").hide();
    }

};

function maxlevel(coachMaxUnit) {
    var allowed_level_unit = unit_level_from_max_unit(coachMaxUnit);
    if (jQuery("#lesson").val() === undefined) {
      jQuery('#max_qual_of_the_coach').text("Max Level:" + allowed_level_unit[0] + " Unit:" + allowed_level_unit[1]);
    }else{
      var lesson = (jQuery("#lesson").val() == "--") ? 4 : jQuery("#lesson").val() ;
      jQuery('#max_qual_of_the_coach').text("Max Level:" + allowed_level_unit[0] + " Unit:" + coachMaxUnit + " Lesson:" + lesson);
    }
    jQuery('#max_unit').text("Max Level:" + allowed_level_unit[0] + " Unit:" + allowed_level_unit[1]);
}

function unit_level_from_max_unit(coachMaxUnit) {
    coachMaxUnit = parseInt(coachMaxUnit, 10);
    // level and unit will be both '--' if they are left untouched.
    // this case will be treated as wildcard
    var allowedUnit = coachMaxUnit > 4 ? (((coachMaxUnit % 4) === 0) ? 4 : coachMaxUnit % 4) : coachMaxUnit;
    var allowedLevel = Math.ceil(parseFloat(coachMaxUnit) / parseFloat(4));
    return [allowedLevel, allowedUnit];
}

function editCoachSession(button, start_time){
    var element = jQuery(button).closest('.qtip').data('qtip').options.position.target ;
    constructQtipWithTip(element, (((element[0].classList.contains("cs_appointment_session_slot")) || (element[0].classList.contains("cs_reassigned_appointment_session_slot"))) ? 'EDIT APPOINTMENT ' : 'EDIT SESSION ')+formatDateForPopup(new Date(start_time)), '/edit_coach_session?&coach_session_id=' + jQuery('#coach_session_id').val(), {solo:false, remove:false});
}

function confirmationForCoachEdit(triggering_element, reason_for_cancel) {
    var action_type = triggering_element.value;
    var reflex_lang, data;
    var recurring = jQuery('#recurring').is(':checked');
    var wild_card = jQuery('#wildcard').is(':checked');
    var header_title = (jQuery("#is_appointment").val() === 'true' ? 'appointment' : 'session');
    reflex_lang = jQuery.parseJSON(jQuery('#lotus_languages').val());
    village_id = jQuery('#village_id').val();
    recurring_ends_at = jQuery('#recurring_ends_at').val();
    end_due_to_template = jQuery('#end_due_to_template').val();
    aria_end_due_to_template = jQuery('#aria_end_due_to_template').val();

    data = {
      previously_recurring: jQuery('#previously_recurring').val(),
      start_time: jQuery('#start_time').val(),
      teacher_confirmed: jQuery('#teacher_confirmed').is(':checked'),
      number_of_seats: jQuery('#number_of_seats').val(),
      lotus_languages: jQuery('#lotus_languages').val(),
      availability: jQuery('#availability').val(),
      coach_session_id: jQuery('#coach_session_id').val(),
      language_id: jQuery('#language_id').val(),
      previous_seats: jQuery('#previous_seats').val(),
      previous_unit: jQuery('#previous_unit').val(),
      previous_village: jQuery('#previous_village').val(),
      wildcard: wild_card,
      recurring: recurring,
      all_languages_max_unit: jQuery('#all_languages_max_unit').val(),
      previous_level: jQuery('#previous_level').val(),
      village_id: jQuery('#village_id').val(),
      learners_signed_up: jQuery('#learners_signed_up').val(),
      previous_language: jQuery('#previous_language').val(),
      level: jQuery('#level').val(),
      unit: jQuery('#unit').val(),
      lesson: jQuery('#lesson').val(),
      cancellation_reason: reason_for_cancel,
      action_type: action_type,
      topic_id: jQuery("#topic").val(),
      session_details: jQuery("#session_details_text_edit").val(),
      is_appointment: jQuery("#is_appointment").val(),
      appointment_type_id: jQuery("#appointment_type_id").val()
   };
   if (data["action_type"] === "SAVE") {
        if (reflex_lang.indexOf(data["language_id"].toString()) === -1 && "TMM" != (data["language_id"].toString().split("-")[0]) && !wild_card) {
            if (jQuery("#lesson").val() === undefined){
                if (data["level"] === "--" || data["unit"] === "--"){
                    alert("Please select a valid level and unit.");
                    return;
                }
            }else{
                if (data["lesson"] === "--" || data["unit"] === "--"){
                    alert("Please select a valid unit and lesson.");
                    return;
                }
            }
            var all_languages_and_max_unit_array_json = jQuery.parseJSON(jQuery('#all_languages_max_unit')[0].value);
            var max_unit = all_languages_and_max_unit_array_json[data["language_id"]];
            var single_unit_number = single_unit_from_level_unit(data["level"], data["unit"]);
            var returned_level_values = unit_level_from_max_unit(max_unit);
            if (single_unit_number > max_unit) {
                alert("The Level and Unit Selected is more than the Maximum Level and  Unit(L" + returned_level_values[0] + "-U" + returned_level_values[1] + ") allowed for this coach");
                return;
            }
        }
        if (parseInt(data["learners_signed_up"], 10) > parseInt(data["number_of_seats"], 10)) {
            alert("You cannot select seats lesser than the learners currently signed up for this session.");
            return;
        }
        //validations for aria
        if((["AUS","AUK"].indexOf(data["language_id"].toString()) != -1) && data["number_of_seats"] != "1"){
            if(jQuery("#topic").val().length === 0){
                alert("Please select a proper topic.");
                return;
            }

        }
        //validations for TMM
        /*if("TMM" == (data["language_id"].toString().split("-")[0])) {
            if(jQuery("#session_details_text_edit").val().length === 0) {
                alert('Please enter valid data in Session details');
                return false;
            }
        }*/

    }
    if (data["previously_recurring"] === "true"){
        if(data["action_type"] === 'CANCEL'){
            jQuery.alerts.okButton = ' CANCEL WITH RECURRENCE ';
            jQuery.alerts.cancelButton = ' CANCEL ';
            jQuery.alerts.confirm("Do you want to cancel this " + header_title +" only, or cancel both this " + header_title + " and all future occurrences?", data["action_type"] + ' CONFIRMATION', function(result) {
                if (result) {
                    data["action_type"] = 'CANCEL ALL';
                    showingProcess('CANCEL ALL', data);
                } else {
                    data["action_type"] = 'CANCEL';
                    showingProcess('CANCEL', data);
                }
            });
        }else if(data["action_type"] === 'REMOVE'){
            jQuery.alerts.okButton = ' REMOVE WITH RECURRENCE ';
            jQuery.alerts.cancelButton = ' REMOVE ';
            jQuery.alerts.confirm("Do you want to apply these changes to all recurring " + header_title + "?", data["action_type"] + ' CONFIRMATION', function(result) {
                if (result) {
                    data["action_type"] = 'CANCEL ALL';
                    showingProcess('CANCEL ALL', data);
                } else {
                    data["action_type"] = 'CANCEL';
                    showingProcess('CANCEL', data);
                }
            });
        }else if(data["action_type"] === "SAVE"){
            //if the recurrence flag is unchecked then the confirmation message has to be asked
            //else if it is TMM with edited session details alone, don't ask for confirmation
            if ("TMM" != data["language_id"].toString().split("-")[0] || !(jQuery('#recurring').is(':checked')))
            {
                jQuery.alerts.okButton = ' SAVE THIS ' + (jQuery("#is_appointment").val() === 'true' ? 'APPOINTMENT' : 'SESSION') + ' ONLY ';
                jQuery.alerts.cancelButton = ' SAVE ALL ';
                jQuery.alerts.confirm("Do you want to apply these changes to all recurring " + header_title +"?", data["action_type"] + ' CONFIRMATION', function(result) {
                    if (result) {
                        jQuery('#recurring').attr('checked', false);
                        data["recurring"] = false;
                        data["action_type"] = 'SAVE';
                        showingProcess('SAVE', data);
                    } else {
                        data["action_type"] = 'SAVE ALL';
                        showingProcess('SAVE ALL', data);
                    }
                });
            }
            else {
                jQuery('#recurring').attr('checked', recurring);
                data["recurring"] = recurring;
                data["action_type"] = 'SAVE';
                showingProcess('SAVE', data);
            }
        }
    }else if(data["action_type"] === "SAVE" && recurring) {
        setAvailableField();
        if((data["availability"] = jQuery('#availability').val()) === 'unavailable') {
            jQuery.alerts.okButton = ' YES, CONTINUE ';
            jQuery.alerts.cancelButton = ' NO, DO NOT MAKE RECURRING ';
            jQuery.alerts.confirm("The coach is unavailable at this time.  Are you sure you want to create a recurring " + header_title + " for them?", data["action_type"] + ' CONFIRMATION', function(result) {
                if(!result){
                    jQuery('#recurring').attr('checked', result);
                    data['recurring']= false;
                    data["action_type"] = 'SAVE';
                    showingProcess("SAVE", data);
                }
                else{
                    if(end_due_to_template !== "false" && ["AUK","AUS"].toString().search(data["language_id"].toString())==-1){
                        if(!confirm("Due to conflicts with this Coach's availability template, the last " + header_title + " for this recurrence would take place on "+end_due_to_template+". Do you wish to proceed with scheduling this " + header_title + "?"))
                            return;
                    }else if(aria_end_due_to_template !== "false" && ["AUK","AUS"].toString().search(data["language_id"].toString())!=-1){
                        if(!confirm("Due to conflicts with this Coach's availability template, the last " + header_title + " for this recurrence would take place on "+aria_end_due_to_template+". Do you wish to proceed with scheduling this " + header_title + "?"))
                            return;
                    }
                    data["action_type"] = 'SAVE';
                    showingProcess("SAVE", data);
                }
            });
        } else {
            if(end_due_to_template !== "false" && ["AUK","AUS"].toString().search(data["language_id"].toString())==-1){
                if(!confirm("Due to conflicts with this Coach's availability template, the last " + header_title + " for this recurrence would take place on "+end_due_to_template+". Do you wish to proceed with scheduling this " + header_title +"?"))
                return;
            }else if(aria_end_due_to_template !== "false" && ["AUK","AUS"].toString().search(data["language_id"].toString())!=-1){
                if(!confirm("Due to conflicts with this Coach's availability template, the last " + header_title + " for this recurrence would take place on "+aria_end_due_to_template+". Do you wish to proceed with scheduling this " + header_title + "?"))
                return;
            }
            data["action_type"] = 'SAVE';
            showingProcess("SAVE", data);
        }
    } else {
        if(data["action_type"] === 'REMOVE')
            data["action_type"] = 'CANCEL';
        jQuery.alerts.okButton = ' Yes ';
        jQuery.alerts.cancelButton = ' No ';
        jQuery.alerts.confirm('Are you sure you want to ' + data["action_type"].toLowerCase() + ' the '+ header_title +'?', data["action_type"] + ' CONFIRMATION', function(result) {
            if (result) showingProcess(data["action_type"], data);
        });

        closePopup();
    }
}

function showingProcess(action_type, data){
    jQuery.blockUI();
    jQuery.ajax({
        type: "post",
        data: data,
        async: true,
        url: "/update_session_from_cs",
        success: function(data) {
            var element = jQuery("#save_edited_session, #cancel_remove_button").closest(".qtip").data("qtip").options.position.target;
            var start_time = new Date(data.start_time).getTime()/1000;
            if ((data.label === "Cancelled") && (jQuery('#is_one_hour_session').val() === "true")){
                var event1 = new CalendarEvent(start_time, data.label, new Date(data.start_time), new Date((start_time*1000)+(30*60000)));
                event1.slotType = "cs_cancelled";
                event1.createEvent();
                var event2 = new CalendarEvent(start_time + 1800, data.label, new Date((start_time*1000)+(30*60000)), new Date(data.end_time));
                event2.slotType = event1.slotType;
                event2.createEvent();
            }
            else{
                var event = new CalendarEvent(start_time, data.label, new Date(data.start_time), new Date(data.end_time));
                //event.slotType = (data.label === "Cancelled") ? "cs_cancelled" : ((data.reassigned) ? "cs_reassigned_session_slot" : "cs_solid_session_slot");
                if(data.label === "Cancelled")
                    event.slotType = "cs_cancelled";
                else if (data.reassigned && data.is_appointment)
                    event.slotType = "cs_reassigned_appointment_session_slot";
                else if (data.reassigned)
                    event.slotType = "cs_reassigned_session_slot";
                else if (data.is_appointment)
                    event.slotType = "cs_appointment_session_slot";
                else
                    event.slotType = "cs_solid_session_slot";
                event.createEvent();
            }
            jQuery(".qtip").remove();
            jQuery.alerts.okButton = '  OK  ';
            jQuery.alerts.alert(data.message);
            jQuery.unblockUI();
            if (data["is_appointment"] == false){
                increment_session_count('cancelled_count', $('#cancelled_count').text());
                decrement_session_count('scheduled_count', $('#scheduled_count').text());
                decrement_duration(data.one_hour_session, $('#scheduled_hrs').text());
            }
        },
        error:function(data){
            alert(data.responseText);
            jQuery.unblockUI();
        }
    });
    return true;
}

function single_unit_from_level_unit(level, unit) {
    level = parseInt(level, 10);
    unit = parseInt(unit, 10);
    var singleUnit = ((level - 1) * 4) + unit;
    return singleUnit;
}
var session_popup = {};
session_popup.clickedcell = '';
session_popup.container_top_position = 0;
jQuery('#session-assign-sub').live("click", function() {
    var coach_name_hidden = jQuery('#coach_name_hidden').val();
    if (coach_name_hidden == '--UNAVAILABLE:--' || coach_name_hidden == '--AVAILABLE:--') {
        jQuery('#session_assign_coach_submit').removeClass('button medium_button');
    } else {
        jQuery('#session_assign_coach_submit').addClass('button medium_button');
    }

    jQuery("#substitution-request-confirmation").slideUp();
    if (session_popup.container_top_position != parseInt(document.getElementById('ui-tooltip-0').style.top, 10)) jQuery("#session-assign-request-confirmation").slideDown('slow');
});

function cancelSubAssign(active) {
    if (active === "true") {
        jQuery('#session-assign-request-confirmation').slideUp();
    } else {
        jQuery('#assign-request-confirmation').slideUp();
    }
}

function confirmationForCancel(triggering_element, learners_signed_up){
    if(typeof(learners_signed_up)==='undefined') learners_signed_up = 0;
    cancel_triggering_element = triggering_element;

    if (parseInt(learners_signed_up.value,10) > 0) {
        fetchReasonForCancellation();
    } else {
        confirmationForCoachEdit(triggering_element);
    }
}

function fetchReasonForCancellation(){
    constructQtipWithTip(jQuery("#cancel_remove_button"), 'CANCEL SESSION','/reason_for_cancellation?called_from=coach_scheduler',{solo:false, remove:false});
}

function confirmSave(future_session, action_type) {
    if ((action_type === 'SAVE ALL' || action_type === 'YES, CONTINUE') && future_session !== 'NO FUTURE SESSION') {
        jQuery.alerts.okButton = ' Continue ';
        jQuery.alerts.cancelButton = ' Cancel ';
        jQuery.alerts.confirm(future_session, "Confirm", function(result) {
            if (result) {
                //document.getElementById('cancel_future_sessions').value = "true";
                return showProcessing(action_type);
            } else {
                document.getElementById('cancel_future_sessions').value = "false";
                return false;
            }
        });
    } else {
        showProcessing(action_type);
    }
    return true;
}

function showProcessing(action_type){
    jQuery.blockUI();
    jQuery('#action_type').val(action_type);
    jQuery('#edit_session_form').submit();
    return true;
}

var toggleLevelUnit = function() {
    if(jQuery('#wildcard').is(':checked')) {
//        jQuery('#level').val('--');
//        jQuery('#unit').val('--');
//        jQuery('#lesson').val('--');
        jQuery('#level').attr("disabled", true);
        jQuery('#unit').attr("disabled", true);
        jQuery('#lesson').attr("disabled", true);
    } else {
        jQuery('#level').attr("disabled", false);
        jQuery('#unit').attr("disabled", false);
        jQuery('#lesson').attr("disabled", false);
    }
};

var upcomingSessions = function(coach_id, lang_id, triggeringElement){
    constructQtipWithTip(triggeringElement, 'MY UPCOMING CLASS SCHEDULE', '/view_my_upcoming_classes?coach_id='+coach_id+'&lang_id='+lang_id, {});
};

var launchOnline = function(launch_string, support_chat_url) {
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
};

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
function showLearner(session_id, learner_id, element){
    closeLearnerPopups();
    constructQtipWithTip(element, 'LEARNER DETAILS','/get_learner_details?id='+session_id+'&learner_id='+learner_id,{solo:false,remove: false});
}
var closeLearnerPopups = function(){
     jQuery(".learner_data").parents('.qtip').remove();
 };
