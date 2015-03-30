jQuery(document).ready(function() {
    bindFormElements();
    var lang = jQuery('#language').val();
    if (lang !== "") {
        createCalenderInSchedules();
        createSessions();
        bindEvents();
        var lang_filter =jQuery('#language_category').val();
        jQuery('#village').attr('disabled', lang === 'KLE' || lang === 'AUS' || lang === 'AUK' || lang_filter.indexOf("RSA") !== -1 || lang_filter.indexOf("Michelin") !== -1);
        jQuery('#classroom_type').attr('disabled', lang === 'KLE' || lang_filter.indexOf("RSA") !== -1 || lang_filter.indexOf("Michelin") !== -1);
    }
    jQuery('#loaded_language').val(jQuery('#language').val());

    jQuery('#number_of_seats').live('change',function(){
        toggleAebOptions();
    });

    jQuery('#tmm_session_detail').live('keyup',function(){
        text = jQuery("#tmm_session_detail");
        if(text.val().length > 500){
            text.val(text.val().substring(0, 500));
        }
        jQuery("#char_count").html(500 - text.val().length);

    });

    jQuery('#tmm_session_detail').live('keydown',function(e){
        text = jQuery("#tmm_session_detail");
        if(text.val().length >= 500){
            if( e.which != 8){ //accepts only backspace (key code 8) once the  length limit is reached
                return false;
            }
        }
    });

    jQuery('#cefr_level').live('change',function(){
        if($('#cefr_level').val()!="--"){
            jQuery.ajax({
                url: '/get_aeb_topics',
                data: {
                    cefr_level: $('#cefr_level').val(),
                    language: $('#language').val()
                },
                success: function(result) {
                    var topics = result;
                    $('#topic_id').empty();
                    $('#topic_id').append('<option value = "">Select</option>');
                    jQuery.each(topics, function(id,title) {
                        $('#topic_id').append('<option value=' + id + '>' + title + '</option>');
                    });
                    $('#topic_id').attr('disabled', false);
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
}else{
    $('#topic_id').empty();
    $('#topic_id').append('<option>Select</option>');
    $('#topic_id').attr('disabled',true);
}

});

jQuery('#cancel_session_button_schedules').live('click', function() {
    var coach_session_id = jQuery('#coach_session_id').val();
    var eschool_session_id = jQuery('#eschool_session_id').val();
    var element = jQuery('#actuals_row_link'+eschool_session_id).children()[0];
    var reason_for_sub = jQuery('#reasons option:selected').val();
    var is_recurring = jQuery('#recurring_session').val() == "true";
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
    cancelTotaleSession(is_recurring,coach_session_id, element, eschool_session_id, reason_for_sub);
});
});

var createSessions = function() {
    var i = 1;
    _.each(groupedSessions, function(array, key) {
        i = i + 1;
        createSingleSession(i, key, array);
    });
};

var createSingleSession = function(cal_id, session_start_time, coach_sessions) {
    var start_time = new Date(session_start_time * 1000);
    var calendarEvent = new CalendarEvent(cal_id, createTitle(coach_sessions), new Date(start_time), new Date(coach_sessions["end_time"]*1000));
    calendarEvent.createEvent();
};

var validateData = function() {
    if (jQuery('#language').val() === "") alert("Please Select a Language.");
};

var createTitle = function(coach_sessions) {
    if(coach_sessions['switch_to_dst']){
        return "<div class ='switch_to_dst'>Daylight Switch</div>";
    }
    var session_count = coach_sessions.sessions_count + coach_sessions.local_edited_count;
    var title = '<div class="event-title"><div class="session_details">' + session_count + ' Sessions' + '(' + coach_sessions['historical_sessions_count'] + ') </div>';
    if (coach_sessions['type'] === 'RecurringSession' || coach_sessions['recurring_sessions_count'] > 0) {
        title += '<div class="recurring_count">' + coach_sessions['recurring_sessions_count'] + ' recurring</div>';
    }
    if (coach_sessions['type'] === 'LocalSession' || (coach_sessions.hasOwnProperty('local_removed_count') && coach_sessions.local_removed_count > 0)) {
        if(coach_sessions['local_sessions_count'] !== 0)
            title += '<div class="new_count">' + coach_sessions['local_sessions_count'] + ' new</div>';
    }
    if (coach_sessions['type'] === 'LocalCancelled') {
        title += '<div class="removed">' + coach_sessions['local_removed_count'] + ' Removed</div>';
    }
    if (coach_sessions['sub_needed']) {
        title += '<input type="hidden" class="extra_session_count" value="'+coach_sessions['extra_session_count'] +'"/><input type="hidden" class="substitution_count" value="'+coach_sessions['substitution_count'] +'"/><div class="sub_needed_text_in_slot">SUB NEEDED</div>';
    }
    if(coach_sessions['emergency_session_present']) {
        title += '<div class="emergency_session"> Emergency Session</div>';
    }
    title += '</div>';
    return title;
};

var populateSchedulerData = function(from) {
    var language = jQuery('#language').val();
    if (from === "today_button") {
        jQuery('#effective_start_date').val(jQuery('#beginning_of_week').val());
        jQuery('#effective_end_date').val(jQuery('#end_of_week').val());
    } else if (from === "previous_week") {
        changeCalenderDates('subtract');
    }else if (from === "next_week") {
        changeCalenderDates('add');
    } else if (from === "go_button") {
        if (language === "") alert("Please Select a Language.");
    }
    if (language !== "") {
        window.location = '/schedules/' + language + '/' + jQuery('#village').val() + '/' + currentSelectedDateAsString();
        return true;
    }
    return false;
};

var redirectPage = function() {
    var language = jQuery('#language').val();
    if (language !== "") window.location = '/schedules/' + language + '/' + jQuery('#village').val() + '/' + currentSelectedDateAsString()+ '/' + jQuery('#classroom_type').val();
};

var bindEvents = function() {
    bindCreateGroupSessionButton();
    bindQtipForCoachAvailibity();
    bindCreateExtraSessionButton();
    bindCreateGroupSessionLotus();
    bindExtraSessionCheckBox();
    bindPushtoEschoolEvent();
};

var bindQtipForCoachAvailibity = function() {
    jQuery('#coach_avail').live('change', function() {
        var coach = jQuery(this);
        if (coach.val() !== "") {
            var path = '/schedules_coach_availability/' + jQuery('#language').val() + '/' + coach.val() + '/' + currentSelectedDateAsString();
            constructQtipWithoutTip(coach, 'Coach Availability for ' + coach.find('option:selected').text(), path, {
                width: 350,
                event: 'change'
            });
            coach.val("");
        }
    });
};

var bindPushtoEschoolEvent = function() {
    jQuery('#commit_to_schedules').live('click', function(event) {
        jQuery('#language').val(jQuery('#loaded_language').val());
        if(jQuery(event.target).val() === "COMMIT TO SCHEDULES")
            result = confirm("This will commit schedules till this week. Do you wish to continue?");
        else if(jQuery(event.target).val() === "PUSH TO SUPERSAAS")
            result = confirm("This will push sessions to supersaas till this week. Do you wish to continue?");
        else
            result = confirm("This will push sessions to eschool till this week. Do you wish to continue?");
        return result;
    });
};

var slotOnClick = function(calEvent, element){
    if(element.find('.switch_to_dst').length === 0){
        jQuery('#language').val(jQuery('#loaded_language').val());
        jQuery(".qtip").remove();
        var start_time = calEvent.start;
        var milliseconds = start_time.getTime();
        if ((groupedSessions[milliseconds / 1000]) === undefined) recurring_ids = [];
        else recurring_ids = groupedSessions[milliseconds / 1000]["recurring_ids"];
        constructQtipWithTip(element, 'SHIFT DETAIL -- ' + moment(start_time).format('ddd MM/DD/YY hh:mm A'), '/slots/' + jQuery('#language').val() + '/' + jQuery('#village').val() + '/' + (start_time.getTime()), {
            data: {
                recurring_ids: recurring_ids,
                classroom_type: jQuery("#classroom_type").val()
            },
            canRemoveAllQtips: true
        });
    }
};

var bindFormElements = function() {
    if (jQuery("#language").val() === ""){
        jQuery("#language_category").val("");
    }

    jQuery('#language_category').live('change', function(){
        jQuery('#classroom_type').val("");
        jQuery('#village').val("");
        if((jQuery("#language_category").val()).indexOf("RSA") !== -1 || "Michelin".localeCompare(jQuery("#language_category").val()) === 0){
            jQuery('#village').attr('disabled', true);
            jQuery('#village').val("all");
            jQuery('#classroom_type').attr('disabled', true);
            jQuery('#classroom_type').val("all");
        }
        else if("AEB".localeCompare(jQuery("#language_category").val()) === 0){
                jQuery('#village').attr('disabled', true);
                jQuery('#village').val("all");
                jQuery('#classroom_type').attr('disabled', false);
        }
        else{
                jQuery('#village').attr('disabled', false);
                jQuery('#classroom_type').attr('disabled', false);
        }
    });

    jQuery('#language').live('change', function(){
        if("TOTALe/ReFLEX".localeCompare(jQuery("#language_category").val()) === 0){
            if(jQuery(this).val() === 'KLE'){
                jQuery('#village').attr('disabled', true);
                jQuery('#village').val("all");
                jQuery('#classroom_type').attr('disabled', true);
                jQuery('#classroom_type').val("all");
            }
            else{
                jQuery('#village').attr('disabled', false);
                jQuery('#classroom_type').attr('disabled', false);
            }
        }
    });

    jQuery('#village').live('change', function(){
        jQuery("#commit_to_schedules").attr("disabled", jQuery(this).val() !== "all" || jQuery("#classroom_type").val() !=="all");
    });

    jQuery('#go_button').live('click', function() {
        validateData();
        redirectPage();
    });
    jQuery('#classroom_type').live('change', function() {
        validateData();
        redirectPage();
    });

    jQuery('#edit_local_session #coach_list').live('change', function(){
        updateRecurringEndsAtDate();
        maxlevel(jQuery(this).find('option:selected').attr('max_unit'));
    });
    jQuery('#edit_local_session #recurring_container #recurring').live('change', function() {
        updateRecurringEndsAtDate();
        jQuery('.recurring_end_date').toggle();
    });

};

var createCalenderInSchedules = function() {
    createCalendar({
        readonly: false,
        allowCalEventOverlap: false,
        defaultEventLength: 1,
        timeslotsPerHour: (jQuery('#is_aria').val() == "true")? 1 : 2,
        newEventText: '',
        date: moment(jQuery('#start_date').val()).add('days', 1).toDate(),
        height: function($calendar){
            return  (jQuery('#is_aria').val() == "true")? 1248 : 2450;
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
            if (calEvent.end.getTime() < new Date().getTime()) {
                $event.css("backgroundColor", "#aaa");
                $event.find(".time").css({
                    "backgroundColor": "#999",
                    "border": "1px solid #888"
                });
            }
        },
        eventHeader: function(calEvent, calendar) {
            return '';
        },
        eventAfterRender: function(calEvent, element){
            jQuery(element).find('.wc-time').remove();
            if(calEvent.slotType){
                element.removeClass('wc-new-cal-event').addClass(calEvent.slotType);
            } else if (calEvent.title !== ""){
                var session = groupedSessions[calEvent.start.getTime() / 1000];
                if (typeof(session) != 'undefined') {
                    if (jQuery('#classroom_type').val() === 'all' && ((session.sessions_count + session.local_edited_count) < session.historical_sessions_count)) {
                        element.addClass('historic_sessions');
                    }
                    if (session.type === 'ExtraSession') {
                        element.addClass('extra_sessions');
                    }
                    if (session.pushed_to_eschool === true) {
                        element.addClass('pushed_to_eschool');
                    }
                    if (session.type === 'RecurringSession') {
                        element.addClass('recurring_sessions');
                    }
                    if (canBeALocalSession(session)) {
                        element.removeClass('recurring_sessions');
                        element.removeClass('pushed_to_eschool');
                        element.addClass('local_session');
                    }
                }
            }
        },
        beforeEventNew: function($event, ui) {
            return true;
        },
        eventNew: function(calEvent, element, dayFreeBusyManager, calendar, mouseupEvent) {
            createNewEvent(calEvent, element, dayFreeBusyManager, calendar, mouseupEvent);
        }
    });
};

var canBeALocalSession = function(session){
    if (session.type === 'LocalSession' || session.local_sessions_count > 0 || session.local_edited_count > 0 ||
        session.type === 'LocalRecurring' || session.type === 'LocalCancelled')
        return true;
    return false;
};

var createNewEvent = function(calEvent, element, dayFreeBusyManager, calendar, mouseupEvent) {
    var start_time = calEvent.start;
    constructQtipWithTip(element, 'SHIFT DETAIL -- ' + moment(start_time).format('ddd MM/DD/YY hh:mm A'), '/slots/' + jQuery('#language').val() + '/' + jQuery('#village').val() + '/' + (start_time.getTime()),{
        data :{
            classroom_type: jQuery("#classroom_type").val()
        }
    }, {
        width: 450
    });
};
var bindCreateGroupSessionButton = function() {
    jQuery('#create_group_session_btn').live('click', function() {
        var start_time = jQuery('#slot_start_time').val();
        var element = jQuery(this).closest('.qtip').data('qtip').options.position.target;
        constructQtipWithTip(element, "CREATE NEW SESSION -- " + formatDateForPopup(new Date(parseInt(start_time, 10))), '/create_session/' + jQuery('#language').val() + '/' + jQuery('#village').val() + '/' + start_time, {});
    });
};

var bindCreateExtraSessionButton = function() {
    jQuery('#create_group_session_btn_extra_session_lotus').live('click', function() {
        var start_time = parseInt(jQuery("#slot_start_time").val(),10)/1000;
        var element = jQuery(this).closest('.qtip').data('qtip').options.position.target;
        constructQtipWithTip(element, "NEW SHIFT -- " + formatDateForPopup(new Date(parseInt(jQuery("#slot_start_time").val(),10))), '/extra_session_reflex/' + jQuery('#language').val() + '/' + jQuery('#village').val() + '/' + start_time, {});
    });
};
var bindCreateGroupSessionLotus = function() {
    jQuery('#create_group_session_btn_lotus').live('click', function() {
        var start_time = jQuery("#slot_start_time").val();
        var element = jQuery(this).closest('.qtip').data('qtip').options.position.target;
        constructQtipWithTip(element, "NEW SHIFT -- " + formatDateForPopup(new Date(parseInt(start_time, 10))), '/create_session/' + jQuery('#language').val() + '/' + jQuery('#village').val() + '/' + start_time, {});
    });
};

function maxlevel(coachMaxUnit) {
    var allowed_level_unit;
    if (jQuery("#lesson").val() === undefined) {
        allowed_level_unit = unit_level_from_max_unit(coachMaxUnit);
        jQuery('#max_qual_of_the_coach').text("Max Level:" + allowed_level_unit[0] + " Unit:" + allowed_level_unit[1]);
        jQuery('#max_unit').text("Max Level:" + allowed_level_unit[0] + " Unit:" + allowed_level_unit[1]);
    }else{
        allowed_level_unit = unit_level_from_max_unit(coachMaxUnit);
        var lesson = (jQuery("#lesson").val() == "--") ? 4 : jQuery("#lesson").val() ;
        jQuery('#max_qual_of_the_coach').text("Max Level:" + allowed_level_unit[0] + " Unit:" + coachMaxUnit + " Lesson:" + lesson);
        jQuery('#max_unit').text("Max Level:" + allowed_level_unit[0] + " Unit:" + allowed_level_unit[1]);
    }
}

function unit_level_from_max_unit(coachMaxUnit) {
    coachMaxUnit = parseInt(coachMaxUnit, 10);
    // level and unit will be both '--' if they are left untouched.
    // this case will be treated as wildcard
    var allowedUnit = coachMaxUnit > 4 ? (((coachMaxUnit % 4) === 0) ? 4 : coachMaxUnit % 4) : coachMaxUnit;
    var allowedLevel = Math.ceil(parseFloat(coachMaxUnit) / parseFloat(4));
    return [allowedLevel, allowedUnit];
}

function single_unit_from_level_unit(level, unit) {
    if (level == '--' && unit == '--')
        return '';
    level = parseInt(level, 10);
    unit = parseInt(unit, 10);
    var singleUnit = ((level - 1) * 4) + unit;
    return singleUnit;
}

function validate_coach(obj){
    if(obj.value == "--Unavailable Coaches--" || obj.value == "--Available Coaches--"){
        alert("Please select a coach.");
        return false;
    }
    return true;
}

var createCoachSessionFromMS = function(is_lotus, lang_id, start_time) {
    if (jQuery('#extra_session_chk').val() == 'Extra Session') {
        createExtraSessionTotale(lang_id, start_time);
    }
    else {
        coaches = jQuery("#coach_list option:selected");
        if (coaches.attr('value') === "") {
            alert('Please select a coach.');
            return;
        }
        if ($('#number_of_seats').val() === "--") {
            alert('Please select a valid number of seats.');
            return;
        }
        if (($("#language").val()=="AUK" || $("#language").val()=="AUS") && ($("#number_of_seats").val() > 1))
        {
            if($("#cefr_level").val() == "--" )
            {
                alert('Please select a proper CEFR level and topic.');
                return;
            }
            if($("#topic_id").val().length === 0 )
            {
                alert('Please select a proper topic.');
                return;
            }
        }

        var level = jQuery('#level').val();
        var unit = jQuery('#unit').val();
        var lesson = jQuery('#lesson').val();
        if(lesson === undefined){
            if(level === '--' ^ unit === '--'){
                jAlert("Either select both level and unit or none for wildcard.");
                return;
            }else{
                var qual_level_unit = unit_level_from_max_unit(coaches.attr('max_unit'));
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
                if(parseInt(unit, 10) > parseInt(coaches.attr('max_unit'), 10)){
                    jAlert("Coach is not qualified to teach selected unit.");
                    return;
                }
            }
        }
        if(is_lotus && jQuery('#recurring ').is(':checked') && coaches.length !== 0 ) {
            coach_ids = [];
            coaches.each(function(){
                coach = jQuery(this);
                if(coach.attr('value') !== "" && coach.attr('status') === 'available'){
                coach_ids.push(coach.attr('value'));
                }
            });
            if (coach_ids.length === 0) {
            jQuery.alerts.okButton = ' OK ';
            jAlert("Cannot create recurring sessions for unavailable coaches. Please select an available coach");
            return;
            }
        }
        if (coaches.attr('threshold') === 'true') {
            jQuery.alerts.okButton = ' YES, CONTINUE ';
            jQuery.alerts.cancelButton = ' CANCEL ';
            jQuery.alerts.confirm("The Coach has reached or exceeded the threshold set for maximum number of sessions per week.Would you like to continue?", '', function(result) {
                if(result) checkRecurrenceEndDate(is_lotus, lang_id, start_time);
            });
        }
        else {
            checkRecurrenceEndDate(is_lotus, lang_id, start_time);
        }
    }
};

var createExtraSessionTotale = function(lang_id, start_time) {
    var level           = jQuery('#level').val();
    var unit            = jQuery('#unit').val();
    var lesson          = jQuery('#lesson').val();
    var topic_id        = undefined
    var seats = jQuery('#number_of_seats').val()

    if(jQuery('#topic_id').is(':enabled')){
      var topic_id = jQuery('#topic_id').val();
    }
    if(lesson === undefined && (level === "--" ^ unit === "--")){
        alert("Please select a valid level and unit.");
    }else if (lesson === "--" ^ unit === "--"){
        alert("Please select a valid unit and lesson.");
    }else if (topic_id=='Select' || topic_id==''){
        alert("Please select a valid topic.");
    }else if (seats===undefined || seats==="--"){
        alert("Please select a valid number of seats.");
    }else {
        jQuery('input.button_shape').attr("disabled", "disabled");
        jQuery.blockUI();
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                start_time: start_time,
                lang_id: lang_id,
                topic_id: topic_id,
                number_of_seats: seats,
                level: level,
                unit: unit,
                name: jQuery('#session_name_txt').val(),
                wildcard: (unit == '--'),
                village_id: jQuery('#village_id').val(),
                excluded_coaches: collectSelectedCoachIds().join(),
                lesson: lesson,
                details: jQuery('#tmm_session_detail').val()
            },
            url: '/save_extra_session',
            success: function(data) {
                var element = jQuery("#create_session").closest(".qtip").data("qtip").options.position.target;
                updateExtraSession(element);
                checkCount(element);
                var event = new CalendarEvent(jQuery(element).data('calEvent').id, jQuery(element).html(), new Date(data.start_time * 1000), new Date(data.end_time * 1000));
                if (!jQuery(element).is(".local_session")){
                    event.slotType = 'extra_sessions';
                    jQuery(element).removeClass("wc-new-cal-event");
                    jQuery(element).addClass("extra_sessions");
                }
                jQuery(element).remove();
                event.createEvent();
                jQuery(".qtip").remove();
                jQuery.unblockUI();
                alert(data.message);
            }
        });
    }
};

var updateExtraSessions = function(sessionId,type, element) {
    var path;
    var seats = jQuery('#number_of_seats').val();
    var level = jQuery('#level').val();
    var unit = jQuery('#unit').val();
    var lesson = jQuery('#lesson').val();
    var lang_id= jQuery("#language").val();
    var session_name = jQuery('#session_name_txt').val();
    var wildcard = (level == '--' && unit == '--') || (lesson == '--' && unit == '--') || jQuery("#wildcard").is(':checked') ;
    var village_id = jQuery('#village_id').val();
    var coach_ids = collectSelectedCoachIds();
    var illelgalwildcard = lesson ? ((lesson == '--' && unit != '--') || (lesson != '--' && unit == '--')) : ((level == '--' && unit != '--') || (level != '--' && unit == '--'));
    var topic_id = jQuery("#topic_id").val();
    var details = jQuery("#tmm_session_detail").val();
    if (!wildcard && illelgalwildcard) {
        alert('Enter both Level/Lesson and Unit as wildcard or select values for both');
    } else {
        jQuery('input.button_shape').attr("disabled", "disabled");
        path = '/save_edited_session';
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                lang_id: lang_id,
                number_of_seats: seats,
                level: level,
                unit: unit,
                name: session_name,
                wildcard: wildcard,
                village_id: village_id,
                excluded_coaches: coach_ids.join(),
                lesson: lesson,
                session_id: sessionId,
                type: type,
                topic_id: topic_id,
                details: details
            },
            url: path,
            success: function(data) {
                alert(data);
                jQuery(".qtip").remove();
            }
        });
    }
};
var bindExtraSessionCheckBox = function() {
    jQuery('#extra_session_chk').live('change', function(e) {
        e.preventDefault();
        if (jQuery('#extra_session_chk').val() === "Extra Session") {
            jQuery('#select_drop_dwon').fadeOut('fast', function() {});
            jQuery('#recurring_container').fadeOut('fast', function() {
                jQuery('#session_name_container').fadeIn('fast', function() {});
                jQuery('#coach_list').attr("disabled", true);
                jQuery('#excluded_coaches_list_div').fadeIn('fast', function() {});
                jQuery('#aeb #recurring_container').removeClass('standard_session')
                if (jQuery("#is_emergency_slot").val()=='true'){
                    jQuery('#aeb #number_of_seats').val('6')
                    jQuery('#aeb #number_of_seats').trigger("change");
                    jQuery('#aeb #number_of_seats').prop('disabled',true)
                }
                jQuery('#note').fadeOut('fast', function() {});
            });
        } else {
            jQuery('#session_name_container').fadeOut('fast', function() {
                jQuery('#recurring_container').fadeIn('fast', function() {});
                jQuery('#select_drop_dwon').fadeIn('fast', function() {});
                jQuery('#excluded_coaches_list_div').fadeOut('fast', function() {});
                jQuery('#coach_list').attr("disabled", false);
                jQuery('#aeb #recurring_container').addClass('standard_session')
                jQuery('#aeb #number_of_seats').prop('disabled',false)
                jQuery('#note').fadeIn('fast', function() {});
            });
        }
    });
};

var checkRecurrenceEndDate = function(is_lotus, lang_id, start_time) {
    coaches = jQuery("#coach_list option:selected");
    if(!is_lotus && jQuery('#recurring ').is(':checked') && coaches.attr('value') !== "" && coaches.attr('status') === 'available') {
        coach_id = coaches.attr('value');
        jQuery.ajax({
            type : 'get',
            data : {
                start_time : start_time,
                coach_id: coach_id,
                lang_id: lang_id
            },
            url : '/check_recurrence_end_date',
            success : function(endDate) {
                if(endDate != 'false'){
                    jQuery.alerts.okButton = ' YES, CONTINUE ';
                    jQuery.alerts.cancelButton = ' CANCEL ';
                    jQuery.alerts.confirm("Due to conflicts with this Coach's availability template, the last session for this recurrence would take place on "+endDate+". Do you wish to proceed with scheduling this session?", '', function(result) {
                        if(result) check_future_conflicting_sessions_and_save(is_lotus, lang_id, start_time);
                    });
                } else {
                    check_future_conflicting_sessions_and_save(is_lotus, lang_id, start_time);
                }
            },
            error: function() {
                alert('Something went wrong. Please report this problem.');
            }
        });
} else if(is_lotus && jQuery('#recurring ').is(':checked') && coaches.length !== 0) {
    coach_ids = [];
    coaches.each(function(){
        coach = jQuery(this);
        if(coach.attr('value') !== "" && coach.attr('status') === 'available'){
            coach_ids.push(coach.attr('value'));
        }

    });

    if(coach_ids.length !== 0) {
        jQuery.ajax({
            type : 'get',
            data : {
                start_time : start_time,
                coach_id: coach_ids
            },
            url : '/check_recurrence_end_date',
            success : function(endDates) {
                if(endDates.length !== 0){
                    jQuery.alerts.okButton = ' YES, CONTINUE ';
                    jQuery.alerts.cancelButton = ' CANCEL ';
                    message = "Due to conflicts with this coach's availability template, the last session for the following coaches would take place on corresponding dates :<br/>";
                    jQuery.each(endDates, function() {
                        message += " &emsp;&emsp;<b>" + this.coach_name + " - " + this.end_date + "</b><br/>";
                    });
                    message += "Do you wish to proceed with scheduling these sessions?";
                    jQuery.alerts.confirm(message, '', function(result) {
                        if(result) check_future_conflicting_sessions_and_save(is_lotus, lang_id, start_time);
                    });
                } else {
                    check_future_conflicting_sessions_and_save(is_lotus, lang_id, start_time);
                }
            },
            error: function() {
                alert('Something went wrong. Please report this problem.');
            }
        });
}
} else {
    check_future_conflicting_sessions_and_save(is_lotus, lang_id, start_time);
}
};

function check_future_conflicting_sessions_and_save(is_lotus, lang_id, start_time) {
    var local_recurring = jQuery('#recurring').is(':checked');
    if(local_recurring && start_time*1000 < new Date(2012, 9, 14).getTime()){
        jAlert("Sorry, You can't create recurring session for the time before Oct, 14.");
        return;
    }
    var path = '/save_local_session';
    if(is_lotus){
        coach_ids = [];
        var coaches = jQuery('#coach_list option:selected');
        if (coaches.length === 0) {
            alert('Please select a coach.');
            return;
        }
        for (var i = 0; i < coaches.length; i++) {

            var coach = jQuery(coaches[i]);
            if(coach.attr('value') === ""){
                alert("An Invalid coach has been selected : "+coach.text());
                coach.attr('selected', false);
                return;
            }
            coach_ids.push(coach.attr('value'));

        }


        data = {
            coach_id: coach_ids,
            start_time: start_time,
            lang_id: lang_id,
            recurring: local_recurring
        };
        jQuery.blockUI();
        jQuery.ajax({
            type: "post",
            async: true,
            data: data,
            url: path,
            success: function(data) {
                if (data.message !== "false") {
                    jAlert(data.message);
                } else {
                    element = jQuery("#create_session").closest(".qtip").data("qtip").options.position.target;
                    if(parseInt(data.recurring_count,10)>0)
                    {
                        updateDivContents(element, true ,data.recurring_count);
                    }
                    if(parseInt(data.new_count,10)>0)
                        updateDivContents(element, false ,data.new_count);
                    updateEvent(element, data);
                    draft_element = jQuery("#schedule_this_week_add");
                    updateDraftCount(draft_element, coaches.length);
                }
                jQuery.unblockUI();
            }
        });
    }else{
        strcheck = jQuery("#coach_list option:selected");
        var level = jQuery('#level').val();
        var unit = jQuery('#unit').val();
        var lesson = jQuery('#lesson').val();

        if (strcheck.attr('status') === 'unavailable') {
            local_recurring = false;
        }
        var singleUnit = lesson ?  (unit == '--' ? '' : unit) : single_unit_from_level_unit(level, unit);
        var data = {
            coach_id: strcheck.attr('value'),
            start_time: start_time,
            lang_id: lang_id,
            village_id: jQuery('#village_id').val(),
            single_number_unit: singleUnit,
            lesson: (lesson ? (lesson =='--' ? 4 : lesson ) : ''),
            number_of_seats: jQuery('#number_of_seats').val(),
            teacher_confirmed: jQuery('#teacher_confirmed').attr('checked') == "checked",
            recurring: local_recurring,
            topic_id: jQuery("#topic_id").val(),
            details: jQuery('#tmm_session_detail').val()
        };
        if (data.number_of_seats == 1){
            data.topic_id = undefined;
        }

        jQuery.blockUI();
        jQuery.ajax({
            type: "post",
            async: true,
            data: data,
            url: path,
            success: function(data) {
                if (data.message !== "false") {
                    jAlert(data.message);
                }
                element = jQuery("#create_session").closest(".qtip").data("qtip").options.position.target;
                updateDivContents(element, local_recurring,1);
                updateEvent(element, data);
                draftElement = jQuery("#schedule_this_week_add");
                updateDraftCount(draftElement, 1);

                jQuery.unblockUI();
            }
        });
    }
}

var updateEvent = function(element, data){
    var event = new CalendarEvent(jQuery(element).data('calEvent').id, jQuery(element).html(), new Date(data.start_time*1000), new Date(data.end_time*1000));
    jQuery(element).remove();
    event.slotType = 'local_session';
    event.createEvent();
    jQuery(".qtip").remove();
    jQuery("#commit_to_schedules").attr("disabled", jQuery('#village').val() !== "all" || jQuery("#classroom_type").val() !=="all");
};

var createExtraSessionReflex = function(fromEdit, is_lotus, lang_id, start_time) {
    var path;
    var session_name = jQuery('#session_name_txt').val();
    var coach_ids = collectSelectedCoachIds();
    path = '/save_extra_session';
    jQuery.blockUI();
    jQuery.ajax({
        type: "post",
        async: true,
        data: {
            start_time: start_time,
            lang_id: lang_id,
            name: session_name,
            excluded_coaches: coach_ids.join()
        },
        url: path,
        success: function(data) {
            var element = jQuery("#create_session").closest(".qtip").data("qtip").options.position.target;
            updateExtraSession(element);
            checkCount(element);
            var event = new CalendarEvent(jQuery(element).data('calEvent').id, jQuery(element).html(), new Date(data.start_time * 1000), new Date(data.end_time * 1000));
            if (!jQuery(jQuery(element)).is(".local_session") && (!jQuery(jQuery(element)).is(".local_session"))) {
                event.slotType = 'extra_sessions';
                jQuery(element).removeClass("wc-new-cal-event");
                jQuery(element).addClass("extra_sessions");
            }
            jQuery(element).remove();
            event.createEvent();
            jQuery(".qtip").remove();
            jQuery.unblockUI();
            alert(data.message);
        }
    });
};
var checkCount =function(element){
    extra_session_count = jQuery(element).find(".extra_session_count").val();
    if(extra_session_count === undefined){
        jQuery(element).append("<input type='hidden' class='extra_session_count' value='1'/>");
    }
    else{
        jQuery(element).find('.extra_session_count').val(parseInt(jQuery(element).find('.extra_session_count').val(),10)+1);
    }
};
var collectSelectedCoachIds = function() {
    var coach_ids = [];
    var coach_list_array = jQuery('#excluded_coach_list_ul').find('li>input:not(:checked)');
    jQuery.each(coach_list_array, function() {
        coach_ids.push(jQuery(this).val());
    });
    return coach_ids;
};

var updateExtraSession = function(element) {
    actual_element = jQuery(element).find(".session_details");
    if (actual_element.length > 0) {
        textHistorical = actual_element.html().split("Sessions")[1];
        actual_element.html((parseInt(extractNumber(actual_element.html()), 10) + 1) + " Sessions" + textHistorical);

    } else {
        if (jQuery(element).find(".event-title").length > 0) {
            jQuery(element).find(".event-title").append("<div class='session_details'> 1 Sessions(0)</div>");
        } else {
            jQuery(element).find(".wc-title").append("<div class='event-title'><div class='session_details'> 1 Sessions(0)</div></div>");
        }
    }
    if(jQuery(element).find('.sub_needed_text_in_slot').size() === 0)
        jQuery(element).find(".event-title").append("<div class='sub_needed_text_in_slot'>SUB NEEDED</div>");

};

var extractNumber = function(text) {
    var number = text.match(/\d+/g);
    return number[0];
};

var deleteLocalSession = function(type,id,status,element){
    path="/delete_local_session";
    date = parseInt(jQuery("#slot_start_time").val(),10);
    if(type === "LocalSession"){
        jQuery.blockUI();
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                local_session_id:id,
                date: date
            },
            url: path,
            success: function(data) {
                jQuery(element).parent().parent().remove();
                updateLocalSessionDetails(status);
                draftElement = jQuery("#schedule_this_week_add");
                updateDraftCount(draftElement, -1);
                jQuery.unblockUI();
            }
        });
    }else{
        var answer = confirm("Deletes all local recurring sessions before and after the week.");
        if(answer){
            jQuery.blockUI();
            jQuery.ajax({
                type: "post",
                async: true,
                data: {
                    recurring_session_id:id,
                    date:date
                },
                url: path,
                success: function(data) {
                    if(type === "StandardLocalSession"){
                        groupedSessions[date/1000].recurring_ids.splice(groupedSessions[date/1000].recurring_ids.indexOf(parseInt(id,10),1));
                    }
                    jQuery(element).parent().parent().remove();
                    updateLocalSessionDetails(status);
                    draftElement = jQuery("#schedule_this_week_add");
                    updateDraftCount(draftElement, -1);
                    jQuery.unblockUI();
                }
            });
        }
    }
};

var editSession = function(type,coachSessionID,eschoolSessionID, element) {
    closePopups();
    var path = '/edit_session';
    if(type === "ExtraSession"){
        path = '/edit_extra_session';
    }
    var start_time = jQuery("#slot_start_time").val();
    var data = {
        start_time: start_time,
        session_id: eschoolSessionID,
        coach_session_id: coachSessionID,
        type : type,
        ext_village_id: jQuery('#village').val()
    };
    constructQtipWithTip(element, "Edit Session --" + formatDateForPopup(new Date(parseInt(start_time, 10))), path, {
        solo: false,
        remove: false,
        data: data
    });

};

var saveEditedSession = function(type,session_id,element){
    strcheck = jQuery("#coach_list option:selected");
    unavailabel_index = jQuery('#coach_list option:contains("--Unavailable Coaches--")').index();
    selectedcoach_id = jQuery("#coach_list option:selected").index();
    previously_recurring_ms = jQuery("#previously_recurring_ms").val();
    var local_recurring = jQuery('#recurring').is(':checked');
    start_time = parseInt(jQuery("#slot_start_time").val(),10);
    if(local_recurring && start_time < new Date(2012, 9, 14).getTime()){
        jAlert("Sorry, You can't create recurring session for the time before Oct, 14.");
        return;
    }
    if (strcheck.attr('status') === 'unavailable') {
        local_recurring = false;
    }
    var coach = jQuery('#coach_list option:selected');
    if(coach.val() === ""){
        jAlert("Please select a Coach.");
        return;
    }
    if (($("#language").val()=="AUK" || $("#language").val()=="AUS") && ($("#number_of_seats").val() > 1))
    {
        if($("#cefr_level").val() == "--" )
        {
            alert('Please select a proper CEFR level and topic.');
            return;
        }
        if($("#topic_id").val().length === 0 )
        {
            alert('Please select a proper topic.');
            return;
        }
    }
    var tmm_session = $("#language").val().indexOf("TMM") !== -1;
    var detail = jQuery('#tmm_session_detail').val();
    var level = jQuery('#level').val();
    var unit = jQuery('#unit').val();
    var lesson = jQuery('#lesson').val();
    var village_id = jQuery('#village_id').val();
    var coachMaxUnit = jQuery(strcheck).attr('max_unit').toString();
    var wildcard = ((level == '--' && unit == '--') || (unit== '--' && lesson == '--')) || jQuery("#wildcard").is(':checked') ;
    var illelgalwildcard = lesson ? ((lesson == '--' && unit != '--') || (lesson != '--' && unit == '--')) : ((level == '--' && unit != '--') || (level != '--' && unit == '--')) ;
    var singleUnit = wildcard ? '' : (lesson ?  (unit == '--' ? NaN : unit) : single_unit_from_level_unit(level, unit));
    var returned_level_values = unit_level_from_max_unit(coachMaxUnit);
    if (!wildcard && illelgalwildcard) {
        if (jQuery("#lesson").val() === undefined){
            if (level === "--" || unit === "--"){
                alert("Please select a valid level and unit.");
                /*jsl:ignore*/
                return false;
                /*jsl:end*/
            }
        }else{
            if (lesson === "--" || unit === "--"){
                alert("Please select a valid unit and lesson.");
                /*jsl:ignore*/
                return false;
                /*jsl:end*/
            }
        }
    }
    var message = [];
    if(coach.attr('status') === 'unavailable')
        message.push("You are about to assign a session for an Unavailable coach");
    if(coach.attr('threshold') === 'true'){
        message.push("Coach has reached or exceeded the threshold set for maximum number of sessions per week");
    }
    var old_coach_id = jQuery('#old_coach_id').val();
    if((old_coach_id !== selectedcoach_id) && (unit !== "--") && (coach.attr('max_unit') < parseInt(unit, 10))){
        message.push("Session's Level/Unit/Lesson exceeds the selected Coach's qualifications");
    }
    var coach_selected = jQuery("#coach_list option:selected").val();
    if(previously_recurring_ms == "true" && !(tmm_session && local_recurring && old_coach_id == coach_selected)){
        message.push("Do you want to apply these changes to all recurring sessions?");
        jQuery.alerts.okButton = ' SAVE THIS SESSION ONLY ';
        jQuery.alerts.cancelButton = ' SAVE ALL ';
    }
    else {
        message.push("Do you wish to continue?");
        jQuery.alerts.okButton = ' YES ';
        jQuery.alerts.cancelButton = ' NO ';
    }
    jQuery.alerts.confirm(message.join('. '), "Confirm", function(result){
        if ((previously_recurring_ms == "true" && !(tmm_session && local_recurring && old_coach_id == coach_selected)) || result) {
            if((old_coach_id !== selectedcoach_id) && (jQuery('#learner_count').val() === "0") && (coach.attr('max_unit') < parseInt(unit, 10))){
                jQuery('#lesson').val('--');
                jQuery('#unit').val('--');
                jQuery("#wildcard").attr('checked','checked');
                wildcard = true;
                singleUnit = '';
                lesson = '--';
            }

            var data = {
                coach_id: jQuery(strcheck).val(),
                start_time: start_time,
                village_id: village_id,
                single_number_unit: isNaN(singleUnit) ? '' : singleUnit,
                lesson: (lesson ? (lesson =='--' ? 4 : lesson ) : ''),
                number_of_seats: jQuery('#number_of_seats').val(),
                teacher_confirmed: (parseInt(old_coach_id,10) === 0) ? true : (jQuery('#teacher_confirmed').attr('checked') == "checked"),
                recurring: local_recurring,
                session_id: session_id,
                type: type,
                topic_id: jQuery("#topic_id").val(),
                wildcard: wildcard,
                details: detail,
                reassigned: old_coach_id != coach_selected,
                update_one_session: result
            };
            if (data.number_of_seats == 1){
                data.topic_id = undefined;
            }

            path = '/save_edited_session';
            jQuery.ajax({
                type: "post",
                async: true,
                data: data,
                url: path,
                success: function(data) {
                    element = jQuery("#create_group_session_btn").closest(".qtip").data("qtip").options.position.target;
                    if(type === "StandardLocalSession")
                    {
                        groupedSessions[start_time/1000].recurring_ids.splice(groupedSessions[start_time/1000].recurring_ids.indexOf(parseInt(session_id,10),1));
                        jQuery(element).removeClass("recurring_sessions");
                        if(local_recurring === false)
                        {
                            actual_element = jQuery(element).find(".recurring_count");
                            if (parseInt(extractNumber(actual_element.html()), 10) === 1)
                                jQuery(element).find(".recurring_count").remove();
                            else
                                updateDivContents(element,true,-1);
                            updateDivContents(element,false,1);
                        }
                    }
                    jQuery(element).addClass("local_session");
                    jQuery(element).removeClass("extra_sessions");
                    jQuery(".qtip").remove();
                    if(jQuery('#village').val()==="all" && jQuery("#classroom_type").val() ==="all")
                        jQuery("#commit_to_schedules").removeAttr('disabled');
                    else
                        jQuery("#commit_to_schedules").attr("disabled", "disabled");
                }
            });
        }
        // else{
        //     jQuery('.qtip').remove();
        // }
    });
/*jsl:ignore*/
return;
/*jsl:end*/
};

var cancelExtraSession = function(session_id){
    if(confirm('Are you sure want to cancel this extra session?')){
        jQuery.blockUI();
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                session_id: session_id
            },
            url: '/cancel_substitution',
            success: function(data){
                var element = jQuery("#create_group_session_btn,#create_group_session_btn_extra_session_lotus").closest(".qtip").data("qtip").options.position.target;
                updateExtraSessionDiv(element);
                alert(data);
                jQuery(".qtip").remove();
            },
            error: function(data){
                alert(data);
            },
            complete: function() {
                jQuery.unblockUI();
            }
        });
    }
};

var updateExtraSessionDiv = function(element)
{
    extra_session_count = jQuery(element).find(".extra_session_count").val();
    sub_count = jQuery(element).find(".substitution_count").val();
    if(sub_count === undefined)
    {
        sub_count= "0";
    }
    session_count = parseInt(extractNumber(jQuery(element).find(".session_details").text()),0) -1;
    actual_element = jQuery(element).find(".session_details");
    textHistorical = actual_element.html().split("Sessions")[1];
    actual_element.html(session_count + " Sessions" + textHistorical);
    total = parseInt(extra_session_count,10)+ parseInt(sub_count,10) -1;
    recurring_count = jQuery(element).find(".recurring_count");
    local_count = jQuery(element).find(".new_count");
    jQuery(element).find(".extra_session_count").val(parseInt(jQuery(element).find(".extra_session_count").val(),10)-1);
    if(recurring_count.length < 1 && local_count.length <1 && (total < 1))
    {
        if(session_count === 0) {
            jQuery(element).remove();
        }
        else{
            jQuery(element).addClass("pushed_to_eschool");
        }
        jQuery(element).find(".sub_needed_text_in_slot").remove();
        jQuery(element).removeClass("extra_sessions recurring_sessions local_session");
    }
    if(local_count.length > 0 || recurring_count.length > 0)
    {
        jQuery(element).find(".sub_needed_text_in_slot").remove();
        jQuery(element).removeClass("extra_sessions");
        if((total < 1) && local_count.length > 1)
        {
            jQuery(element).addClass("local_session");
        }
        else{
            jQuery(element).addClass("recurring_sessions");
        }
    }
};
var editExtraSessionReflex = function(coach_session_id,element) {
    path = '/edit_extra_session_reflex';
    start_time = jQuery("#slot_start_time").val();
    data = {
        coach_session_id: coach_session_id
    };
    constructQtipWithTip(element, "Edit Session --" + formatDateForPopup(new Date(parseInt(start_time, 10))), path, {
        solo: false,
        remove: false,
        data: data
    });
};
var updateExtraSessionReflex = function(coach_session_id,element){
    var session_name        = jQuery('#session_name_txt').val();
    var coach_ids           = collectSelectedCoachIds();
    path = '/update_extra_session_reflex';
    jQuery.ajax({
        type: "post",
        async: true,
        data: {
            coach_session_id : coach_session_id,
            name: session_name,
            excluded_coaches: coach_ids.join()
        },
        url: path,
        success: function(data){
            alert(data);
            jQuery(".qtip").remove();
        }
    });
};
var assignSusbtitute = function(elem,coach_session_id){
    constructQtipWithTip(elem, 'ASSIGN SUBSTITUTE','/fetch_available_coaches?session_id='+coach_session_id,{solo:false, remove:false});
};

function editActualLotusSession(coach_session_id, element){
    path = '/edit_reflex_session_details';
    start_time = jQuery("#slot_start_time").val();
    data = {
        coach_session_id:coach_session_id
    };
    constructQtipWithTip(element, "Assign SUB --" + formatDateForPopup(new Date(parseInt(start_time, 10))), path, {
        solo: false,
        remove: false,
        data: data
    });

}

function toggleAebOptions() {

    if($('#number_of_seats').val() === "1" || $('#number_of_seats').val() === "--") {
        jQuery('#cefr_level').val('--');
        jQuery('#topic_id').empty();
        jQuery("#topic_id").attr('disabled',true);
        jQuery('#topic_select').hide();
        if( jQuery('#is_emergency_slot').val()=='true' && jQuery('#extra_session_chk').val()=='Extra Session'){
            jQuery("#extra_session_chk").val("standard Session");
        }
        jQuery('#cefr_select').hide();
    } else {
        jQuery('#topic_select').show();
        jQuery('#topic_id').append("<option>Select</option>");
        jQuery('#cefr_select').show();
    }
}

var removeActualSession = function(coach_session_id, element){
    path = '/remove_lotus_session';
    if (jQuery(element).text() === "Remove")
    {
        type =  "LocalSession";
        action = "cancel";
        remove_count = 1;
    }
    else{
        type =  "ConfirmedSession";
        action = "edit_one";
        remove_count = -1;
    }
    data = {
        coach_session_id:  coach_session_id,
        type: type,
        action_type : action
    };
    jQuery.ajax({
        type: "post",
        async: true,
        data: data,
        url: path,
        success: function(data) {
            toggleLinkText(element);
            draft_element = jQuery('#schedule_this_week_remove');
            updateDraftCount(draft_element, remove_count, true);
            if(jQuery('#village').val()==="all" && jQuery("#classroom_type").val() ==="all")
                jQuery("#commit_to_schedules").removeAttr('disabled');
            else
                jQuery("#commit_to_schedules").attr("disabled", "disabled");
        }
    });
};
var saveLotusSessionChanges = function(coach_session_id, element){
    path = '/remove_lotus_session';
    if (jQuery(element).text() === "Remove Recurrence")
        remove_recurrence_for_lotus_session("LocalSession", "cancel_with_recurrence", "true", coach_session_id, element);
    else
        make_recurrence_for_lotus_session("LocalSession", "edit_one", "true", coach_session_id, element);
};

var saveAssignSub = function(coach_session_id, element){
    var message = "";
    if (jQuery("#coach_list :selected").attr('status') === 'unavailable') {
        message += "You are about to assign a session for an Unavailable coach. ";
    }

    if (jQuery("#coach_list :selected").attr('threshold') === 'true') {
        message +="The Coach has reached or exceeded the threshold set for maximum number of sessions per week. Would you like to continue?";
    }
    if (message.length > 0){
        jQuery.alerts.confirm(message, '', function(result) {
            if(result){
                saveReflexAssign(coach_session_id, element);
            }
            else return;
        });
    }
    else
        saveReflexAssign(coach_session_id, element);

};

var saveReflexAssign = function(coach_session_id, element){
    jQuery.blockUI();
    jQuery.ajax({
        type: "post",
        async: true,
        data: {
        start_time : jQuery("#slot_start_time").val(),
        session_id : coach_session_id,
        type : "LocalSession",
        coach_id : jQuery("#coach_list :selected").attr('coach_id'),
        action_type : "edit_one"
        },
        url : '/save_assign_sub',
        success: function(data){
            element = jQuery("#create_group_session_btn_extra_session_lotus").closest(".qtip").data("qtip").options.position.target;
            jQuery(element).addClass("local_session");
            jQuery.unblockUI();
            jQuery(".qtip").remove();
            jQuery("#commit_to_schedules").removeAttr('disabled');
        },
        error: function(data) {
        jQuery.unblockUI();
        alert("Something went wrong. Please report this problem.");
        }
    });
};

var cancelTotaleSession = function(recurring,coach_session_id,element,eschool_session_id, selected_reason){
    var type =  "ConfirmedSession";
    var remove_count = -1;
    var reason = "";
    if (jQuery(element).text() === "Cancel"){
        type =  "LocalSession";
        remove_count = 1;
        reason = selected_reason || "";
    }
    cancel_with_recurrence = "false";
    if (jQuery(element).text() === "Cancel"){
        if(!recurring){
            jQuery.alerts.okButton = ' YES ';
            jQuery.alerts.cancelButton = ' NO ';
            msg = "Do you want to cancel?";
        }
        else{
            jQuery.alerts.okButton = ' CANCEL WITH RECURRENCE ';
            jQuery.alerts.cancelButton = ' CANCEL ';
            msg = "Do you want to cancel this session only, or cancel both this session and all future occurrences?";
        }
    }
    else {
        jQuery.alerts.okButton = ' YES ';
        jQuery.alerts.cancelButton = ' NO ';
        msg = "Do you want to uncancel?";
    }

    jQuery.alerts.confirm(msg, 'CANCEL CONFIRMATION', function(result) {
    if (!(jQuery(element).text() === "UnCancel" && !result) && !(jQuery(element).text() === "Cancel" && !recurring && !result)){
        if (jQuery(element).text() === "Cancel"){
            if (result && recurring) {
                cancel_with_recurrence = "true";
            }
            else {
                cancel_with_recurrence = "false";
            }
        }
    var dataParams = {
        coach_session_id:  coach_session_id,
        type: type,
        action_type: (cancel_with_recurrence == "true" ? "cancel_with_recurrence" : "cancel"),
        eschool_session_id: eschool_session_id,
        cancellation_reason: reason,
        recurring: recurring
    };
    jQuery.ajax({
        type: "post",
        async: true,
        data: dataParams,
        url: '/cancel_totale_session',
        success: function(data){
            toggleLinkTextTotale(element,dataParams,data);
            draftElement = jQuery("#schedule_this_week_remove");
            updateDraftCount(draftElement, remove_count, true);
            if(jQuery('#village').val()==="all" && jQuery("#classroom_type").val() ==="all")
                jQuery("#commit_to_schedules").removeAttr('disabled');
            else
                jQuery("#commit_to_schedules").attr("disabled", "disabled");
        }
    });
    }
    }
    );
};

var toggleLinkText = function(element){
    qtip_element = jQuery(element).closest(".qtip").data("qtip").options.position.target;
    textValue = jQuery(element).text();
    if (textValue === "Remove"){
        jQuery(jQuery(element).parent().siblings()[1]).text("Cancelled");
        jQuery(element).text("UnRemove");
        changeColor(jQuery(element).parent().parent(),"removed_session",false);
        updateRemovedContent(qtip_element,true);
    }
    else if(textValue === "UnRemove"){
        jQuery(jQuery(element).parent().siblings()[1]).text("Active");
        jQuery(element).text("Remove");
        changeColor(jQuery(element).parent().parent(),"removed_session",true);
        updateRemovedContent(qtip_element,false);
    }
    else if(textValue === "Make Recurring")
    {
        jQuery(element).text("Remove Recurrence");
        changeColor(jQuery(element).parent().parent(),"remove_with_recurring",false);
        changeColor(qtip_element,"local_session",false);
    }
    else if(textValue === "Remove Recurrence")
    {
        jQuery(element).text("Make Recurring");
        changeColor(jQuery(element).parent().parent(),"remove_with_recurring",false);
        changeColor(qtip_element,"local_session",false);
    }
};

var toggleLinkTextTotale = function(element,data,response)
{
    qtip_element = jQuery(element).closest(".qtip").data("qtip").options.position.target;
    changeColor(qtip_element,"local_session",false);
    textValue = jQuery(element).text();
    if (textValue === "Cancel"){
        jQuery(element).parent().prev().prev().text("Cancelled");
        changeColor(jQuery(element).parent().parent(),"removed_session",false);
        changeColor(jQuery(element).parent().parent(),"edited_session",true);
        updateRemovedContent(qtip_element,true);
        jQuery(element).parent().html("<a href='#' onclick='cancelTotaleSession("+data["recurring"]+","+data["coach_session_id"]+",this,"+data["eschool_session_id"]+");return false;'>UnCancel</a>");
    }
    else if(textValue === "UnCancel"){
        jQuery(element).parent().prev().prev().text(response);
        changeColor(jQuery(element).parent().parent(),"removed_session",true);
        updateRemovedContent(qtip_element,false);
        if (jQuery("#learner_count_"+data["coach_session_id"]).text() > 0) {
            jQuery(element).parent().html("<a href='#' onclick='constructQtipWithTip(this, \"CANCEL SESSION\", \"/reason_for_cancellation?coach_session_id="+data["coach_session_id"]+"&called_from=schedules\", { solo:false, remove:false });return false;'>Cancel</a> | <a href='#' onclick='editSession(\"ConfirmedSession\","+data["eschool_session_id"]+",this);return false;'>Edit</a>");
        }
        else {
            jQuery(element).parent().html("<a href='#' onclick='cancelTotaleSession("+data["recurring"]+","+data["coach_session_id"]+",this,"+data["eschool_session_id"]+");return false;'>Cancel</a> | <a href='#' onclick='editSession(\"ConfirmedSession\","+data["coach_session_id"]+","+(data["eschool_session_id"] || -1) +",this);return false;'>Edit</a>");
        }
    }
};

var changeColor = function(element,className,flag)
{
    if(!flag)
        jQuery(element).addClass(className);
    else
        jQuery(element).removeClass(className);
};

var updateDivContents = function(element, recurring,length) {
    if (recurring) {
        actual_element = jQuery(element).find(".recurring_count");
        if (actual_element.length > 0) {
            actual_element.html((parseInt(extractNumber(actual_element.html()), 10) + length) + " recurring");
        } else {
            if (jQuery(element).find(".event-title").length > 0) {
                jQuery(element).find(".event-title").append("<div class='recurring_count'>"+ length +"recurring</div>");
            } else {
                jQuery(element).find(".wc-title").append("<div class='event-title'><div class='session_details'>0 Sessions(0)</div><div class='recurring_count'>"+length+" recurring</div></div>");
            }
        }
    } else {
        actual_element = jQuery(element).find(".new_count");
        if (actual_element.length > 0) {
            actual_element.html((parseInt(extractNumber(actual_element.html()), 10) + length) + " new");
        } else {
            if (jQuery(element).find(".event-title").length > 0) {
                jQuery(element).find(".event-title").append("<div class='new_count'>"+ length +" new</div>");
            } else {
                jQuery(element).find(".wc-title").append("<div class='event-title'><div class='session_details'>0 Sessions(0)</div><div class='new_count'> "+length+" new</div></div>");
            }
        }
    }

};

var updateRemovedContent = function(element,removed)
{
    if(removed){
        actual_element = jQuery(element).find(".removed");
        if (actual_element.length > 0) {
            number =parseInt(extractNumber(actual_element.html()),10);
            actual_element.html((number + 1) + " removed");
        } else {
            if (jQuery(element).find(".event-title").length > 0) {
                jQuery(element).find(".event-title").append("<div class='removed'> 1 removed</div>");
            }
        }
        changeColor(element,"local_session",false);
    }
    else{
        actual_element = jQuery(element).find(".removed");
        if (actual_element.length > 0) {
            number =parseInt(extractNumber(actual_element.html()),10);
            if(number >= 2)
            {
                actual_element.html((number - 1) + " removed");
            }
            else{
                jQuery(element).find(".removed").remove();
            }
        }
        actualElementLocalSession = jQuery(element).find(".new_count");
        if(actualElementLocalSession.length < 1)
            changeColor(element,"local_session",true);
    }
};

var updateLocalSessionDetails = function(status)
{
    element = jQuery("#shift_details").closest(".qtip").data("qtip").options.position.target;
    if(status==="Not Active-Recurring")
    {
        actualElement = jQuery(element).find(".recurring_count");
        actualElement.html((parseInt(extractNumber(actualElement.html()), 10) -1 ) + " recurring");
        jQuery(element).removeClass("recurring_session");
        jQuery(element).addClass("local_session");
    }

    else{
        actualElement = jQuery(element).find(".new_count");
        actualElement.html((parseInt(extractNumber(actualElement.html()), 10) -1 ) + " new");
        jQuery(element).removeClass("recurring_session");
        jQuery(element).addClass("local_session");
    }
};

var toggleLevelUnit = function() {
    if(jQuery('#wildcard').is(':checked')) {
        jQuery('#level').attr("disabled", true);
        jQuery('#unit').attr("disabled", true);
        jQuery('#lesson').attr("disabled", true);
    } else {
        jQuery('#level').attr("disabled", false);
        jQuery('#unit').attr("disabled", false);
        jQuery('#lesson').attr("disabled", false);
    }
};
var viewSessionDetails = function(element,eschool_session_id){
    closePopups();
    path = '/view_session_details';
    start_time = jQuery("#slot_start_time").val();
    data = {
        start_time:start_time,
        language_identifier:jQuery("#language").val(),
        village_id:jQuery("#village").val(),
        eschool_session_id:eschool_session_id
    };
    constructQtipWithTip(element,formatDateForPopup(new Date(parseInt(start_time, 10))), path, {
        solo: false,
        remove: false,
        data: data
    });
};
var closePopups = function(){
    jQuery(".top_container").parents('.qtip').remove();
    jQuery("#edit_local_session").parents('.qtip').remove();
};

function showLearner(session_id, learner_id,element){
    path = '/get_learner_info';
    data = {
        id : session_id,
        learner_id: learner_id,
        language_identifier:jQuery("#language").val()
    };
    constructQtipWithTip(element," ", path, {
        solo: false,
        remove: false,
        data: data
    });

}

var updateDraftCount = function(draft_element, count, remove_flag){
    var draft_html_value = (remove_flag ? draft_element.html((parseInt(extractNumber(draft_element.html()), 10) + count) + " remove") : draft_element.html((parseInt(extractNumber(draft_element.html()), 10) + count) + " new"));
};

var updateRecurringEndsAtDate = function() {
    start_time = parseInt(jQuery("#slot_start_time").val(),10);
    strcheck = jQuery("#coach_list option:selected");
    if(jQuery('#recurring ').is(':checked') && strcheck.attr('value') !== "" && strcheck.attr('status') === 'available') {
        coach_id = strcheck.attr('value');
        jQuery.ajax({
            type : 'get',
            data : {
                start_time : start_time/1000,
                coach_id: coach_id
            },
            url : '/check_recurrence_end_date',
            success : function(endDate) {
                if(endDate != 'false'){
                    jQuery('.recurring_end_date').html("Recurring Ends: "+endDate);
                } else {
                    jQuery('.recurring_end_date').html("");
                }
            },
            error: function() {
                alert('Something went wrong. Please report this problem.');
            }
        });
    } else {
        jQuery('.recurring_end_date').html("");
    }
};

var remove_recurrence_for_lotus_session = function(type, action, recurring, coach_session_id, element){
    data = {
        coach_session_id:  coach_session_id,
        type: type,
        action_type: action,
        recurring: recurring
    };
    save_recurrence_info_for_lotus(data, element);
};

var make_recurrence_for_lotus_session = function(type, action, recurring, coach_session_id, element){
    jQuery.blockUI();
    data = {
        coach_session_id:  coach_session_id,
        type: type,
        action_type: action,
        recurring: recurring
    };
    jQuery.ajax(
    {
        type : 'get',
        data : {
            start_time : new Date(element.parentNode.attributes['alt'].value).getTime()/1000,
            coach_id: element.attributes['data_coach_id'].value
        },
        url : '/check_recurrence_end_date',
        success : function(endDate) {
            jQuery.unblockUI();
            if(endDate && (endDate !== "") && (endDate !== "false")){
                jQuery.alerts.okButton = ' YES, CONTINUE ';
                jQuery.alerts.cancelButton = ' CANCEL ';
                message = "Due to conflicts with his availability template, the last session for the coach would take place on corresponding date :<br/>";
                message += " &emsp;&emsp;<b>" + endDate + "</b><br/>";
                message += "Do you wish to proceed with making this recurring?";
                jQuery.alerts.confirm(message, '', function(result) {
                    if(result)
                        save_recurrence_info_for_lotus(data, element);
                });
            } else {
                save_recurrence_info_for_lotus(data, element);
            }
        },
        error: function() {
            jQuery.unblockUI();
            alert('Something went wrong. Please report this problem.');
        }
    });
};

var save_recurrence_info_for_lotus = function(data, element){
 jQuery.ajax({
    type: "post",
    async: false,
    data: data,
    url: path,
    success: function(data) {
        toggleLinkText(element);
        if(jQuery('#village').val()==="all" && jQuery("#classroom_type").val() ==="all")
            jQuery("#commit_to_schedules").removeAttr('disabled');
        else
            jQuery("#commit_to_schedules").attr("disabled", "disabled");
    }
});
};
