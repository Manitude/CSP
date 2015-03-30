var ADDITIONAL_SESSION_TIMINGS = new Array('Next Two Weeks', 'Starting in next hour', 'Starting in 3 hours', 'Upcoming sessions in 12 hours', 'Upcoming sessions in 24 hours');
var basicTableCopy;
var tempTdHtml;
var cancelLinkObject;
var canRefreshLiveData = true;                  //Sessiosn should not be refreshed when any other operations are in-progress. So, this is acting like a lock.
var needLiveDataRefreshAfterAssist = false;     //After assisting, the sessions are to be refreshed. This is mark whether assist is clicked.
var liveRefreshTimer;                           // Timer to invoke refresh
var liveRefreshAjaxXhrObj;
var sessionStartTimeFilterOldValue = "Live Now";        //These variables are used in wild cases, when user changes drop-down and doesnt click filter.
var sessionStartTimeFilterCurrentValue = "Live Now";    //In such case, we reload the data with live-now holding values in these two variables.
var has_more_records_to_fetch = false;
var technical_support_requirements = [];

jQuery(document).ready(function () {
    checkCookie();
    basicTableCopy = jQuery('#table_container').html();
    adjustNoticeBarForDojoMatrix();
    handleChangingSessionLanguage();
    bindFilterButton();
    bindNonAssistableSessionsFilterCheckBox();
    bindDisableDashboardRefreshCheckBox();
    bindSessionStartTimeIdSelectBox();
    handleCancelSession();
    handleAssignSubLink();
    handleRequestSubLink();
    handleAssignSubDropdown();
    handleAssignSubButton();
    handleRequestSubButton();
    handleCancelSessionButton();
    handleFullSupportLink();
    loadLearnersSessionData();
    bindCoachFilterTextBox();
    handleFetchAebFirstSeenIcon();
});

var bindCoachFilterTextBox = function() {
    jQuery('#coach_filter').bind("keyup keypress blur change", function(e) {
        var searchVal = jQuery.trim(jQuery('#coach_filter').val()).toLowerCase();
        var rows = jQuery('#session_table_body tr');
        rows.hide();
        rows.filter(function(i){
            return (jQuery(this).attr('row-data').toLowerCase().indexOf(searchVal) >= 0);
        }).show();
    });
};

var adjustNoticeBarForDojoMatrix = function() {
    jQuery('.notice').css('margin-top','1.5em');
    jQuery('.error').css('margin-top','1.5em');
};

var check_non_assistable_sessions = function(sessions){
    var has_non_assistable_sessions= false;
    jQuery.each(sessions, function(session_index, session){
        if(session.class_status != 'already_finished' && session.cancelled == 'false'){
            jQuery.each(session.attendances, function(attendance_index, attendance){
                if(attendance.attendance.audio_input_device && attendance.attendance.audio_input_device.match(/iOS|iPad/) && attendance.attendance.has_technical_problem === "true"){
                    has_non_assistable_sessions = true;
                    return false;
                }
            });
            if(has_non_assistable_sessions)
                return false;
        }
    });
    return has_non_assistable_sessions;
};

var populateDeviceInfoInRow = function(row, value){
    var attendances = value.attendances;
    jQuery.each(attendances, function(index, attendance){
        if(attendance.audio_input_device && attendance.audio_input_device.match(/iOS|iPad/) && attendance.has_technical_problem === "true"){
            row.setAttribute('unAssistable', "true");
            return false;
        }
    });
};

var toogleNonAssistableMode = function(){
    if(sessionStartTimeFilterOldValue == 'Live Now'){
        reloadLiveSessions();
    }
    else{
        window.pageNumber = 0;
        resetTable();
        loadLearnersSessionData();
    }
};

var eventsOnClosingFaceBox = function(){        //This method is invoked in Facebox.js, while closing the pop-up.
    if(needLiveDataRefreshAfterAssist){
        reloadLiveSessions();
        needLiveDataRefreshAfterAssist = false;
    }
};

var sessionStartTimeFilterChange = function(){      // On change of Session start time drop-down.
    sessionStartTimeFilterCurrentValue = jQuery('#session_start_time_id').val();
};
var checkAndResteStartTimeFilter = function(){      // Resetting the filter value if filter-button is not clicked, but the auto refresh is to be triggered.
    if(sessionStartTimeFilterOldValue != sessionStartTimeFilterCurrentValue){
        jQuery('#session_start_time_id').val(sessionStartTimeFilterOldValue);
        sessionStartTimeFilterCurrentValue = sessionStartTimeFilterOldValue;
    }
};

var handleReloadForLiveSessions = function(){
    if(REFRESH_INTERVAL_FOR_LIVE_SESSIONS > 0 && !jQuery('#disable_dashboard_refresh').is(':checked')){
        if(liveRefreshTimer) clearTimeout(liveRefreshTimer);
        liveRefreshTimer = setTimeout("reloadLiveSessions()", REFRESH_INTERVAL_FOR_LIVE_SESSIONS * 1000);
    }
};

var bindDisableDashboardRefreshCheckBox = function() {
    jQuery('#disable_dashboard_refresh').live('click', function (e) {
        var flag = jQuery(this).is(':checked');
        if(flag)
            clearTimeout(liveRefreshTimer);
        else
            handleReloadForLiveSessions();
        createCookie(username,flag.toString(),365);
    });
};

var checkCookie = function(){
    document.getElementById("disable_dashboard_refresh").checked = (readCookie(username) == "true");
};

var reloadLiveSessions = function(){
    if(sessionStartTimeFilterOldValue == 'Live Now' && canRefreshLiveData){
        resetTable();
        loadLearnersSessionData();
        window.pageNumber = 0;
    }
};

var handleFullSupportLink = function () {
    jQuery('a.full_support_link').live('click', function (e) {  
        config = "menubar=0,resizable=1,scrollbars=0,toolbar=0,location=0,directories=0,status=0,top=0,left=0";  
        var source = jQuery(e.target);
        var url = source.attr('href');
        if( url === "javascript:undefined")// URL will be undefined for AEB Sessionos
        {
            canRefreshLiveData = false;
            var tdElement = source.closest('td');
            jQuery.blockUI();
            jQuery.ajax({
                type: 'post',
                data:{
                    eschool_session_id: tdElement.attr('data-session-id'),
                    student_guid: tdElement.attr('learner-guid')
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
                    canRefreshLiveData = true;      // Releasing the lock
                    handleReloadForLiveSessions();  //mannually resetting the timer.
                },
                error: function(error){
                    jQuery.unblockUI();
                    console.log(error);
                    alert(error.responseText);
                    canRefreshLiveData = true;      // Releasing the lock
                    handleReloadForLiveSessions();  //mannually resetting the timer.
                }        
            });
        }
        
    });
};

var handleCancelSession = function () {
    jQuery('a.cancel_link').live('click', function (e) {
        e.preventDefault();
        cancelLinkObject = e;
        var source = jQuery(e.target);
        var tdElement = source.closest('td');
        var sessionDetailsTd = tdElement.siblings('td[id^="session_details"]');
        var learnerDetailTd = tdElement.siblings('td[id^="learner_cell"]');
        var learner_count = learnerDetailTd.text().indexOf(0);
        var yesOrNo = confirm('Are you sure you want to cancel the session - ' + sessionDetailsTd.text());
        if (yesOrNo) {
            time = source.attr('time');
            current_coach_id = source.attr('current_coach_id');
            if(learner_count > 0)
                fetchReasonsDropDown(tdElement,time,current_coach_id, "reason_for_cancellation");
            else
                cancelSession(e,jQuery(e.target));

        }

        return false;
    });
};

var handleFetchAebFirstSeenIcon = function() {
    jQuery('img.first_seen_at_img').live('click', function () {

        var session_id = this.attributes['session_id'].value;
        var coach_id = this.attributes['coach_id'].value;
        var cancelled = this.attributes['cancelled'].value;
        var learner = this.attributes['learner'].value;
        var div_html = jQuery(this).parent().html();
        jQuery("#"+this.attributes['session_id'].value+"_div").html("Loading...");
        jQuery.ajax({
            url: '/fetch_aeb_first_seen_at',
            data: {
                coach_id : coach_id,
                session_id : session_id,
                cancelled : cancelled,
                learner : learner
            },
            success: function(result) {
                jQuery("#"+session_id+"_div").html(result);
            },
            failure: function(error){
                console.log(error);
                alert("Something went wrong. Please try again later.");
                jQuery("#"+session_id+"_div").html(div_html);
            },
            error: function(error){
                console.log(error);
                alert("Something went wrong. Please try again later.");
                jQuery("#"+session_id+"_div").html(div_html);
            }
        });
    });
};

var handleAssignSubLink = function () {
    jQuery('a.assign_sub_link').live('click', function (e) {
        if (jQuery('#assign_substitute_button').length > 0)
        {
            jQuery(jQuery('#assign_substitute_button')).closest('td').html(tempTdHtml);
        }
        e.preventDefault();
        var request_sub_link = jQuery(e.target).closest('td').find("a.request_sub_link");
        if (request_sub_link.size() === 0 || request_sub_link.attr("hidden") === "hidden"){
            var source = jQuery(e.target);
            var tdElement = source.closest('td');
            tempTdHtml = tdElement.html();
            session_id =source.attr('session_id');
            fetchAssignSubstituteDropdown(tdElement,session_id,false);

        }
        else{
            checkSubViolation(e,"assign",true); 
        }
        return false;
    });
};

var handleRequestSubLink = function () {
    jQuery('a.request_sub_link').live('click', function (e) {
        e.preventDefault();
        checkSubViolation(e,"request",false);
        return false;
    });
};

var handleAssignSubDropdown = function () {
    jQuery('#coach_list').live('change', function (){
        jQuery('#assign_substitute_button').attr('disabled', jQuery(this).val() === "");
    });
};

var handleAssignSubButton = function() {
    jQuery('input#assign_substitute_button').live('click', function (){
        jQuery.alerts.okButton = ' OK ';
        jQuery.alerts.cancelButton = ' CANCEL ';
        var selectedCoach = jQuery('select#coach_list').find('option:selected');
        var reason_for_sub = jQuery('select#reasons').find('option:selected').val();
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

        var message = "";
        if(selectedCoach.attr('status') === 'unavailable')
            message = "You are about to assign a session for an Unavailable coach";

        if(selectedCoach.attr('threshold') === 'true'){
            if(message !== "") message = message + " and ";
            message = message + "Coach has reached or exceeded the threshold set for maximum number of sessions per week";
        }

        if(message !== "") message = message + ". ";
        message = message + "Do you wish to continue ?";

        if (confirm(message)) {
            assignSubstitute(jQuery(this), selectedCoach,reason_for_sub);
        }
    });

    jQuery('input#cancel_substitute_button_assign').live('click', function (){
        jQuery(this).closest('td').html(tempTdHtml);
    });
};
var handleRequestSubButton = function() {
    jQuery('input#request_substitute_button').live('click', function (){
        reason_for_sub = validateReason();
        if(reason_for_sub === -1)
            return;
        var message = "";
        if(message !== "") message = message + ". ";
        message = message + "Do you wish to continue ?";

        if (confirm(message)) {
            requestASubstitute(jQuery(this),reason_for_sub);
        }
    });

    jQuery('input#cancel_substitute_button_request').live('click', function (){
        var div = jQuery(this).closest('td');
        jQuery(this).closest('td').html(tempTdHtml);
        div.find('a.request_sub_link').attr("hidden",false);

    });
};

var handleCancelSessionButton = function() {
    jQuery('input#cancel_session_button_dashboard').live('click', function (){
        reason_for_cancel = validateReason();
        if(reason_for_cancel === -1)
            return;
        var message = "";
        if(message !== "") message = message + ". ";
        message = message + "Do you wish to continue ?";

        if (confirm(message)) {
            cancelSession(cancelLinkObject, jQuery(this), reason_for_cancel);
        }
    });

    jQuery('input#back_to_session_button').live('click', function (){
        var div = jQuery(this).closest('td');
        jQuery(this).closest('td').html(tempTdHtml);
        div.find('a.request_sub_link').attr("hidden",false);

    });

};

var handleChangingSessionLanguage = function () {
    jQuery('#session_language_id').bind('change', function (e) {
        var selected_language = jQuery('#session_language_id').val().toLowerCase();
        if (isReflexLanguage(selected_language) && isReflexTimingPresent()) {
            deleteReflexTimings();
        } else if ((!isReflexLanguage(selected_language)) && !isReflexTimingPresent()) {
            jQuery.each(ADDITIONAL_SESSION_TIMINGS, function (index, value) {
                var option = new Option(value, value);
                jQuery('#session_start_time_id').append(option);
            });
        }
        if(["AEB","AUK","AUS"].indexOf(jQuery('#session_language_id').val()) > -1){
            jQuery("#support_language_id").val("None");
            jQuery("#support_language_id").attr("disabled", true);
            jQuery("#non_assistable_sessions_filter").prop("checked", false);
            jQuery("#non_assistable_sessions_filter_div").children().prop("disabled", true);
        }else{
            jQuery("#support_language_id").attr("disabled", false);
            jQuery("#non_assistable_sessions_filter_div").children().prop("disabled", false);
        }

    });
};


var bindFilterButton = function() {
    jQuery('#filter_session_form > #filter').bind('click', function (e) {
        e.preventDefault();
        $('#coach_filter').val('');
        sessionStartTimeFilterOldValue = sessionStartTimeFilterCurrentValue;
        resetTable();
        loadLearnersSessionData();
        return false;
    });
};

var bindNonAssistableSessionsFilterCheckBox = function() {
    jQuery('#non_assistable_sessions_filter').bind('change', function (e) {
        e.preventDefault();
        toogleNonAssistableMode();
        return false;
    });
};

var bindSessionStartTimeIdSelectBox = function() {
    jQuery('#session_start_time_id').bind('change', function (e) {
        e.preventDefault();
        sessionStartTimeFilterChange();
        return false;
    });
};
var checkSubViolation = function(e,type,fetch_reason){
    canRefreshLiveData = false;                 // Locking the refresh
    var source = jQuery(e.target);
    var tdElement = source.closest('td');
    tempTdHtml = tdElement.html();
    jQuery.ajax({
        url: source.attr('href'),
        success: function(data) {
                substitution = true;
                if (data["violation"] === "true")
                {   
                     if(!confirm("This substitution request is in violation of the Studio team's Substitution policy. Substitution(s) were already requested for "+data["text"]+". Would you like to proceed?")){
                        substitution = false;
                     }
                }  
                if(substitution === true){

                    if(type=="assign"){
                        session_id =source.attr('session_id');
                        fetchAssignSubstituteDropdown(tdElement,session_id,fetch_reason);
                    }
                    else{
                        time = source.attr('time');
                        current_coach_id = source.attr('current_coach_id');
                        fetchReasonsDropDown(tdElement,time,current_coach_id,"reason_for_sub_request");
                    }
                }
               
            },
        failure: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            canRefreshLiveData = true;      // Releasing the lock
            handleReloadForLiveSessions();  //mannually resetting the timer.
        },
        error: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            canRefreshLiveData = true;      // Releasing the lock
            handleReloadForLiveSessions();  //mannually resetting the timer.
        },
         async:   false
    });
};

var fetchAssignSubstituteDropdown = function(tdElement,session_id,fetch_reason){
    var tempContainer = jQuery('#temp_container');
    tdElement.html(tempContainer.html());
    canRefreshLiveData = false;                 // Locking the refresh
    jQuery.ajax({
        url: '/fetch_available_coaches?fetch_reason='+fetch_reason+'&session_id=' + session_id,
        success: function(data){
            tdElement.html(data);
        },
        failure: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            canRefreshLiveData = true;      // Releasing the lock
            handleReloadForLiveSessions();  //mannually resetting the timer.
        },
        error: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            canRefreshLiveData = true;      // Releasing the lock
            handleReloadForLiveSessions();  //mannually resetting the timer.
        }
    });
};
var fetchReasonsDropDown = function(tdElement,time,current_coach_id, action){
    tdElement.find('a.request_sub_link').attr("hidden",true);
    tempTdHtml = tdElement.html();
    var tempContainer = jQuery('#temp_container');
    tdElement.html(tempContainer.html());
    canRefreshLiveData = false;                 // Locking the refresh

    jQuery.ajax({
        url: '/'+action+'?current_coach_id='+ current_coach_id + '&time='+ time,
        data : { called_from : "dashboard",
                 from_dashboard: true
                 },
        success: function(data){
            data += "<input id=\"session_details\" coach_id=\""+current_coach_id+"\" time=\""+time+"\" type=\"hidden\">";
            tdElement.html(data);

        },
        failure: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            canRefreshLiveData = true;      // Releasing the lock
            handleReloadForLiveSessions();  //mannually resetting the timer.
        },
        error: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            canRefreshLiveData = true;      // Releasing the lock
            handleReloadForLiveSessions();  //mannually resetting the timer.
        }
    });

};

var requestASubstitute = function(source,reason_for_sub){
    var tdElement = source.closest('td');
    var coachCell = tdElement.siblings('td[id^="coach_cell"]');
    var sessionDetailsTd = tdElement.siblings('td[id^="session_details"]');
    jQuery.ajax({
        type : 'POST',
        data:{    
            current_coach_id : tdElement.find("#session_details").attr("coach_id"),
            time :  new Date(tdElement.find("#session_details").attr("time")).toUTCString(),
            reason : reason_for_sub
         },
        url: '/request_substitute_for_coach/',
        success: function(data){
            if(data.label[0] == "Cancelled"){
                 tdElement.html('');
                 createCancelledDiv(sessionDetailsTd[0], 'CANCELLED');
                 alert('Substitute Requested but Session Cancelled(No learner)');
            }              
            else{
                 coachCell.html('<div class="bolden">Substitute Requested</div>');
                 reInitializeDetails(tdElement, data.message);
            }
           
        },
        failure: function(error){
            console.log(error);
            alert(error);
        },
        error: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
        }
    });
};

var assignSubstitute = function (source, selectedCoach,reason_for_sub) {
    var tdElement = source.closest('td');
    var coach_session_id = tdElement.find('#coach_session_id').val();
    var coachCell = tdElement.siblings('td[id^="coach_cell"]');
    tdElement.html(jQuery('#temp_container').html());
    jQuery.ajax({
         data:{
                    assigned_coach:selectedCoach.val(),
                    coach_session_id:coach_session_id,
                    reason:reason_for_sub

                },
        url:'/assign_substitute_for_coach/',
        success:function (data) {
            coachCell.html('Session reassigned to <div class="bolden">' + selectedCoach.text() + '</div>');
            reInitializeDetails(tdElement, data.message);
        },
        failure:function (error) {
            console.log(error);
            reInitializeDetails(tdElement, 'Something went wrong, please refresh the page');
        },
        error:function (error) {
            console.log(error);
            reInitializeDetails(tdElement, 'Something went wrong, please refresh the page');
        }
    });
};

var reInitializeDetails = function(tdElement, message){
    alert(message);
    tdElement.html(tempTdHtml);
    canRefreshLiveData = true;      // Releasing the lock
    handleReloadForLiveSessions();  //mannually resetting the timer.
};

var cancelSession = function (e, source, reason) {
    var urlSource = jQuery(e.target);
    var tdElement = source.closest('td');
    var coach_cell = tdElement.siblings('td[id^="coach_cell"]');
    var url = urlSource.attr('href');
    var sessionDetailsTd = tdElement.siblings('td[id^="session_details"]');
    
    tdElement.html(jQuery('#temp_container').html());
    jQuery.ajax({
        data : {
                reason : reason
            },
        url:url,
        success:function (data) {
            tdElement.html('');
            createCancelledDiv(sessionDetailsTd[0], 'CANCELLED');
            if(coach_cell.children().html() === "Coach not yet arrived"){
                coach_cell.children().html("Coach did not join session.");
                coach_cell.removeClass("needs_teacher_now");
            }
            alert('Successfully cancelled.');
         },
           failure:function (error) {
              alert('Something went wrong. Please refresh the page');
             console.log(error);
         },
         error:function (error) {
             alert('Something went wrong. Please refresh the page');
             console.log(error);
         }
    });
};


var isReflexLanguage = function (language) {
    return language == 'jle' || language == 'kle' || language == 'ade';
};

var isReflexTimingPresent = function () {
    var timingsAvailable = jQuery('#session_start_time_id').children();
    for (var i = 0; i < timingsAvailable.size(); i++) {
        if (jQuery(timingsAvailable[i]).text() == ADDITIONAL_SESSION_TIMINGS[0].trim()) return true;
    }
    return false;
};

var deleteReflexTimings = function () {
    var timingsAvailable = jQuery('#session_start_time_id').children();
    jQuery.each(timingsAvailable, function (index, value) {
        if (jQuery.inArray(value.text, ADDITIONAL_SESSION_TIMINGS) != -1) {
            jQuery('#session_start_time_id > option[value=\"' + value.text + '\"]').remove();
        }
    });
};

var resetTable = function(){
    window.pageNumber = 0;
    jQuery('#table_container').html('');
    jQuery('#table_container').html(basicTableCopy);
};

var loadLearnersSessionData = function(){
    checkAndResteStartTimeFilter();         // Checking whether drop-down is changed and filter button not clicked.
    var filterButton = jQuery('input#filter');
    filterButton.attr('disabled', 'true');
    var form = jQuery('#filter_session_form');
    var session_table = jQuery('#session_table');
    var session_body = jQuery('#session_table tbody');
    var spinner = jQuery('#big_spinner');
    spinner.show();
    window.pageNumber = (window.pageNumber || 0) + 1;
    window.scrollTo(0, document.documentElement.scrollHeight);
    if(pageNumber <= 1) session_table.hide();
    if(liveRefreshAjaxXhrObj) liveRefreshAjaxXhrObj.abort();
    technical_support_requirements = [];
    liveRefreshAjaxXhrObj = jQuery.ajax({
        url: form.attr('action'),
        data: form.serialize() + '&page_number=' + pageNumber + '&get_non_assistable_sessions=' + jQuery('#non_assistable_sessions_filter').is(":checked"),
        success: function(result) {
            var sessions = result.sessions.session.eschool_sessions;
            var has_non_assistable_sessions = check_non_assistable_sessions(sessions);
            if(has_non_assistable_sessions)
                jQuery('#non_assistable_sessions_alert').show();
            else
                jQuery('#non_assistable_sessions_alert').hide();
            has_more_records_to_fetch = result.can_pull_more;
            jQuery('#coach_filter').removeAttr('disabled');
            if(sessions.length === 0){
                console.log('no records found');
                handleNoRecordsFetched(session_body[0], pageNumber <= 1);
            }
            jQuery.each(sessions, function(index, value){
                createSessionTableRow(session_body[0], countRows(session_body), value.eschool_session);
                populate_technical_support_requirements(value.eschool_session);
            });
            if(jQuery('#session_start_time_id').val() == "Live Now"){
                draw_technical_support_requirements();
                jQuery('#help_requested_by').slideDown();
            }else{
                jQuery('#help_requested_by').slideUp();
            }
            if(pageNumber <= 1) buildFixedHeaderTable();
            handleScroll();
            session_table.show();
            spinner.hide();
            filterButton.removeAttr('disabled');
            console.log('successfully fetched page number ' + window.pageNumber);
            handleReloadForLiveSessions();
        },
        failure: function(failure){
            console.log(failure);
            filterButton.removeAttr('disabled');
            alert('There was a problem in  loading dashboard data, Please report the problem');
            spinner.hide();
            handleReloadForLiveSessions();
        },
        error: function(error){
            /*jsl:ignore*/
            filterButton.removeAttr('disabled');
            if(error.status == 503){
                alert(error.responseText);
            }else if(error.status === 0){
                // Do nothing on incomplete ajax
            }else{ 
                alert('Something went wrong! Please report the problem.');
            }
            console.log(error);
            spinner.hide();
            handleReloadForLiveSessions();
            /*jsl:end*/
        }
    });
};

var populate_technical_support_requirements = function (session) {
    if(session.teacher_has_technical_problem  == "true"){
        technical_support_requirements.push([session.teacher, "Coach", session.label+", ID : "+session.session_id]);
    }
    jQuery.each(session.attendances, function(index, attendance){
        if(attendance.attendance.has_technical_problem == "true"){
            technical_support_requirements.push([attendance.attendance.first_name + " " + attendance.attendance.last_name, "Learner", session.label+", ID : "+session.session_id]);
        }
    });
};

var handleNoRecordsFetched = function(table, isFirstPage){
    var infoText = 'No further records found';
    var row = table.insertRow(0);
    var cell = row.insertCell(0);
    cell.setAttribute('colspan', 6);
    cell.setAttribute('class', 'session_info');
    if(isFirstPage) {
        row.setAttribute('height', '459px');
        infoText = 'No records found, Please refine the search criteria';
        jQuery('#coach_filter').attr('disabled', 'disabled');
    }
    cell.appendChild(document.createTextNode(infoText));
};

var countRows = function(table) {
    return table.children().size();
};

var canFetchMoreData = function (tableBody, element) {
    return has_more_records_to_fetch && (element[0].scrollHeight - element[0].scrollTop - element.height()) < 500;
};
var handleScroll = function(){
    jQuery('div.body').bind('scroll', function(e){
        var tableBody = jQuery('#session_table tbody');
        var element = jQuery(e.target);
        if(canFetchMoreData(tableBody, element) ){
            jQuery('div.body').unbind('scroll');
            loadLearnersSessionData();
        }
    });
};

var buildFixedHeaderTable = function(){
    jQuery('#session_table').fixheadertable({
        height: 460,
        colratio: [210, 150, 99, 99, 190, 200]
    });
};

var createSessionTableRow = function(table, rowCount, value) {
    var row = table.insertRow(rowCount);
    row.setAttribute('class', value.class_status);

    populateSessionCell(row, value, rowCount);
    populateCoachCell(row, value, rowCount);
    populateLearnersCell(row, value, rowCount);
    populateVillageCell(row, value, rowCount);
    populateActions(row, value, rowCount);
    populateAudioDevices(row, value, rowCount);
    populateDeviceInfoInRow(row, value);

};

var populateActions = function(row, value, rowCount){
    var actionCell = row.insertCell(4);
    actionCell.setAttribute('id','action_cell_'+rowCount);
    if(value.class_status != 'already_finished') {
        actionCell.setAttribute('class', 'session_info');
        actionCell.setAttribute('data-session-id', value.session_id);
        var learner_guid = value.attendances.length > 0 ? value.attendances[0].attendance.guid : "None";
        actionCell.setAttribute('learner-guid', learner_guid);
        if(value.cancelled == 'false'){
            var topDiv = document.createElement('div');
            if(value.can_show_support_links == 'true'){
                if(value.aeb !== 'true'){
                    var viewOnlyAnchor = document.createElement('a');
                    var viewLinkValue = document.createTextNode(value.view_link_text);
                    viewOnlyAnchor.setAttribute('class', 'view_only_link');
                    /*jsl:ignore*/
                    viewOnlyAnchor.setAttribute('href', 'javascript:' + value.view_only_url);
                    /*jsl:end*/
                    viewOnlyAnchor.appendChild(viewLinkValue);
                    topDiv.appendChild(viewOnlyAnchor);
                }
                var fullSupportText;
                if(value.can_view_full_support == 'true'){
                    var fullSupportAnchor = document.createElement('a');
                    fullSupportAnchor.setAttribute('class', 'full_support_link');
                    /*jsl:ignore*/
                    fullSupportAnchor.setAttribute('href', 'javascript:' + value.full_support_url);
                    /*jsl:end*/
                    fullSupportText = document.createTextNode(value.full_support_text);
                    fullSupportAnchor.appendChild(fullSupportText);
                    topDiv.appendChild(fullSupportAnchor);
                } else {
                    fullSupportText = document.createTextNode(value.full_support_text);
                    topDiv.appendChild(fullSupportText);
                }
                actionCell.appendChild(topDiv);
            }
            if(value.is_not_present_in_csp === 'false'){
                var middleDiv = document.createElement('div');
                if(value.can_assign_sub == 'true' && value.is_reflex != "true"){
                    var cancelAnchor = document.createElement('a');
                    cancelAnchor.setAttribute('class', 'cancel_link');
                    cancelAnchor.setAttribute('href', '/cancel-session?cancelled_from_led=true&session_id=' + value.session_id);
                    var cancelLinkValue = document.createTextNode(value.cancel_text);
                    cancelAnchor.appendChild(cancelLinkValue);
                    middleDiv.appendChild(cancelAnchor);

                    var assignSubAnchor = document.createElement('a');
                    assignSubAnchor.setAttribute('class', 'assign_sub_link');
                    assignSubAnchor.setAttribute('href', '/check_sub_policy_violation?start_time='+ Date.parse(value.session_time) +'&coach_id='+value.coach_id);
                    assignSubAnchor.setAttribute('session_id',value.session_id);

                    var assignSubstituteValue = document.createTextNode(value.assign_substitute_text);
                    assignSubAnchor.appendChild(assignSubstituteValue);
                    middleDiv.appendChild(assignSubAnchor);
                }

                var bottomDiv = document.createElement('div');
                if(value.can_assign_sub == 'true' && value.is_reflex != "true" && value.teacher != 'Substitute Requested'){
                    var requestSubAnchor = document.createElement('a');
                    requestSubAnchor.setAttribute('class', 'request_sub_link');
                    requestSubAnchor.setAttribute('href', '/check_sub_policy_violation?start_time='+ Date.parse(value.session_time) +'&coach_id='+value.coach_id);
                    requestSubAnchor.setAttribute('current_coach_id',value.coach_id);
                    requestSubAnchor.setAttribute('time',value.session_time);
                    var requestSubstituteValue = document.createTextNode(value.request_substitute_text);
                    requestSubAnchor.appendChild(requestSubstituteValue);
                    bottomDiv.appendChild(requestSubAnchor);
                }
                actionCell.appendChild(middleDiv);
                actionCell.appendChild(bottomDiv);
            }else{
                var eschoolSessionInfoMsgDiv = document.createElement('div');
                var eschoolSessionInfoMsgTxt = document.createTextNode("This session was created in eschool and cannot be modified via the Customer Success Portal");
                eschoolSessionInfoMsgDiv.appendChild(eschoolSessionInfoMsgTxt);
                actionCell.appendChild(eschoolSessionInfoMsgDiv);
            }
        }
    }
};

var populateAudioDevices = function(row, value, rowCount){
    var audioDeviceCell = row.insertCell(5);
    audioDeviceCell.setAttribute('id','audio_device_'+rowCount);
    if(value.cancelled != 'true' && value.class_status != 'already_finished'){
        if(value.show_warning === 'true'){
            var audioDeviceImgDiv = document.createElement('div');
            var audioDeviceImg = document.createElement('img');
            audioDeviceImg.setAttribute("src", "images/warning_red.png");
            audioDeviceImg.setAttribute('alt', value.image_alt );
            audioDeviceImg.setAttribute('title', value.image_title );
            audioDeviceImgDiv.appendChild(audioDeviceImg);
            audioDeviceCell.appendChild(audioDeviceImgDiv);
        }
        var audioDeviceValueDiv = document.createElement('div');
        var audioDeviceValue = document.createTextNode(value.audio);
        audioDeviceValueDiv.appendChild(audioDeviceValue);
        audioDeviceCell.setAttribute('class', ' session_info');
        audioDeviceCell.appendChild(audioDeviceValueDiv);
        var attendances = value.attendances;
        for(var i in attendances){
            if(attendances[i].attendance.has_technical_problem === "true"){
                var learnerDetailDiv = document.createElement("div");
                var learnerDetailLink = document.createElement("a");
                learnerDetailLink.style.color = '#BF0030';
                if(value.aeb !== 'true') learnerDetailLink.setAttribute("href", "/learners/-1?guid=" + attendances[i].attendance.guid);
                var learnerNameText   = document.createTextNode((attendances[i].attendance.first_name? attendances[i].attendance.first_name : '')+ ' ' + (attendances[i].attendance.last_name? attendances[i].attendance.last_name : ''));
                learnerDetailLink.appendChild(learnerNameText);
                learnerDetailDiv.appendChild(learnerDetailLink);
                audioDeviceCell.appendChild(learnerDetailDiv);
            }
        }
    }
};

var populateLearnersCell = function(row, value, rowCount){
    var learnersCell = row.insertCell(2);
    learnersCell.setAttribute('id', 'learner_cell_'+rowCount);
    var numberOfSeats = value.number_of_seats ? value.number_of_seats : 4;
        var learnersAttendanceValue = document.createTextNode(value.attendances_count);
        var learnersInRoomValue = document.createTextNode((value.is_reflex === "true")? "-" : value.students_in_room_count);
        var justASeperatorValue = document.createTextNode('/');

        var learnersAttendanceHasTechnicalProblem = false;
        var learnersInRoomHasTechnicalProblem = false;

        var attendances = value.attendances;
        for(var i in attendances) {
            var attendance = attendances[i].attendance;
            if(attendance.has_technical_problem == "true" && attendance.student_in_room == "true"){
                learnersInRoomHasTechnicalProblem = learnersAttendanceHasTechnicalProblem = true;
                break;
            }
            else if(attendance.has_technical_problem == "true" && attendance.student_in_room == "false"){
                learnersAttendanceHasTechnicalProblem = true;
                break;
            }
        }
        var learnersAttendanceAnchor = document.createElement('a');
        if(value.attendances_count != "0") {
            learnersAttendanceAnchor.appendChild(learnersAttendanceValue);
            /*jsl:ignore*/
            learnersAttendanceAnchor.setAttribute("href", "javascript:fixedFacebox('"+value.attendances_url+"')");
            /*jsl:end*/
            if(learnersAttendanceHasTechnicalProblem)
                learnersAttendanceAnchor.className = 'count_has_technical_problem';
        } else {
            learnersAttendanceAnchor = learnersAttendanceValue;
        }
        var learnersInRoomAnchor = document.createElement('a');
        if(value.students_in_room_count != "0" && value.students_in_room_count != "N/A" && value.is_reflex == "false") {
            learnersInRoomAnchor.appendChild(learnersInRoomValue);
            /*jsl:ignore*/
            learnersInRoomAnchor.setAttribute("href", "javascript:fixedFacebox('"+value.learners_in_room_url+"')");
            /*jsl:end*/
            if(learnersInRoomHasTechnicalProblem)
                learnersInRoomAnchor.className = 'count_has_technical_problem';
        }
        else{
            learnersInRoomAnchor = learnersInRoomValue;
        }

        learnersCell.setAttribute('class', ' session_info');
        learnersCell.appendChild(learnersAttendanceAnchor);
        learnersCell.appendChild(justASeperatorValue);
        learnersCell.appendChild(learnersInRoomAnchor);
        if(numberOfSeats == 1){
            var solo_icon = document.createElement('img');
            solo_icon.setAttribute('src', '/images/solo.png');
            solo_icon.setAttribute('class', 'solo_icon');
            learnersCell.appendChild(solo_icon);
        }

};


var populateVillageCell = function(row, value, rowCount){
        var villageCell = row.insertCell(3);
        villageCell.setAttribute('id', 'village_cell_'+rowCount);
        var villageValue = document.createTextNode(value.village_name);
        villageCell.setAttribute('class', ' session_info');
        villageCell.appendChild(villageValue);
};

var populateSessionCell = function(row, value, rowCount) {
    var sessionCell = row.insertCell(0);
    var sessionValue = document.createTextNode(value.session);
    sessionCell.setAttribute('class', ' session_info');
    sessionCell.setAttribute('id', 'session_details_'+rowCount);
    sessionCell.appendChild(sessionValue);
    if(value.cancelled == 'true'){
       createCancelledDiv(sessionCell, value.cancel_text);
    }
};

var populateCoachCell = function (row, value, rowCount) {
    var coachArrivedTimeValue;
    var coachArrivedAtDiv;
    var coachCell = row.insertCell(1);
    var teacher_learner_names =  value.teacher;
    jQuery.each(value.attendances, function( index, valInsideIndex ) {
        teacher_learner_names =  teacher_learner_names + ' ' + valInsideIndex.attendance.first_name + ' ' +  valInsideIndex.attendance.last_name + ' ' + valInsideIndex.attendance.email;
    });
    row.setAttribute('row-data', teacher_learner_names);
    var coachValue = document.createTextNode(value.teacher);
    coachCell.setAttribute('class', 'session_info');
    coachCell.setAttribute('id', 'coach_cell_'+rowCount);
    coachCell.appendChild(coachValue);
    //adding extra link to fetch first seen at for passed AEB sessions
    if (value.aeb === "true" && value.class_status === "already_finished"){
        img = new Image(15,15); // width, height values are optional params 
        img.src = '/images/clock_icon.jpg';
        img.setAttribute('session_id', value.session_id);
        img.setAttribute('title', "Click to see coach first seen time");
        img.setAttribute('class', "first_seen_at_img");
        img.setAttribute('coach_id', value.coach_id);
        img.setAttribute('cancelled',value.cancelled);
        img.setAttribute('learner',value.attendances.length > 0 ? value.attendances[0].attendance.guid : "");
        first_seen_at_div = document.createElement('div');
        first_seen_at_div.setAttribute('id',value.session_id.toString() + "_div");
        first_seen_at_div.appendChild(img);
        coachCell.appendChild(document.createElement('br'));
        coachCell.appendChild(first_seen_at_div);
    }
    else if(value.teacher_first_seen_at !== '') {
        coachArrivedTimeValue =  document.createTextNode(value.teacher_first_seen_at);
        coachArrivedAtDiv = document.createElement("div");
        coachArrivedAtDiv.appendChild(coachArrivedTimeValue);
        coachCell.appendChild(coachArrivedAtDiv);
    }
    else if(value.teacher_first_seen_at === '' && value.class_status === "already_finished" && value.cancelled == "false"){ //todo: check this condition
        coachArrivedTimeValue =  document.createTextNode("Coach did not join the session");
        coachArrivedAtDiv = document.createElement("div");
        coachArrivedAtDiv.appendChild(coachArrivedTimeValue);
        coachCell.appendChild(coachArrivedAtDiv);
    }

    if(value.needs_teacher_now && value.cancelled !== 'true') {
        var coachNotArrivedText = document.createTextNode('Coach not yet arrived');
        var coachNotArrivedAtDiv = document.createElement("div");
        coachNotArrivedAtDiv.appendChild(coachNotArrivedText);
        coachCell.appendChild(coachNotArrivedAtDiv);
        coachCell.setAttribute('class', 'session_info ' + value.needs_teacher_now );
    }
};

var createCancelledDiv = function(sessionCell, textValue){
    var cancelledDiv = document.createElement('div');
    var cancelValue = document.createTextNode(textValue);
    cancelledDiv.setAttribute('class', 'cancelled_session');
    cancelledDiv.appendChild(cancelValue);
    sessionCell.appendChild(cancelledDiv);
};

var getAssistanceStatus = function(guid, caller){
    if(caller === 'untag'){
        guid += '-assist';
        link = jQuery('a', jQuery('#'+guid))[0];
        link.remove();
        jQuery('img', jQuery('#'+guid))[0].style['display'] = "block";
        if (link.innerHTML.trim() == translations['Assist']){
            return 'ASSISTED';
        } else {
            return 'SUPPORT_COMPLETED';
        }
    }else{
        guid += '-pause';
        link = jQuery('a', jQuery('#'+guid))[0];
        link.remove();
        jQuery('img', jQuery('#'+guid))[0].style['display'] = "block";
        if (link.innerHTML.trim() === translations['Paused']){
            return 'PAUSED';
        } else {
            return 'ASSISTED';
        }
    }
};

var draw_technical_support_requirements = function(){
    var tech_table = jQuery('#help_requested_by_table');
    tech_table.html("");
    if (technical_support_requirements.length === 0) {
        tech_table.html("<tr><td>There are no Coaches and Learners requesting for assistance.</td></tr>");
    }else{
        jQuery.each(technical_support_requirements, function(index, entry){
            tech_table.append("<tr><td class='help_requested_by_name_cell'>"+entry[0]+"</td><td class='help_requested_by_type_cell'>"+entry[1]+"</td><td class='help_requested_by_session_cell'>"+entry[2]+"</td></tr>");
        });
    }
};
