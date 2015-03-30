var id = 10;
var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

jQuery(document).ready(function(){
    if(jQuery('#language').val() !== ""){
        createCalendarForAvailability();
        renderExisitngAvailabilities();
        renderCalendarHeader();
        initializeDatePicker();
        initializeActionEventHandlers();
        selectAppropriateSubNav();
        if(jQuery('#template').val() == '0'){
            jQuery('#delete_template').hide();
        }
    }
});

var createCalendarForAvailability = function() {
    createCalendar(
    {
        timeslotsPerHour: 2,
        readonly: false,
        allowCalEventOverlap: false,
        defaultEventLength: 1,
        timeslotHeight:  40,
        newEventText: 'Available',
        height: function($calendar){
            return 1970;
        },
        eventClick : function(calEvent, element, dayFreeBusyManager,
            calendar, clickEvent) {
            calendar.weekCalendar('removeEvent',calEvent.id);
        },
        eventRender : function(calEvent, $event) {

        },
        eventAfterRender: function(calEvent, $event) {
            
        },
        draggable: function(calEvent, element) {
            return false;
        },
        eventHeader: function(calEvent, calendar) {
            return '';
        },
        eventNew : function(calEvent, element, dayFreeBusyManager,
            calendar, mouseupEvent) {
            calEvent.id = id;
            id++;
            calendar.weekCalendar("updateEvent", calEvent);
        }
    });
    jQuery('#week-calendar').disableSelection();
};

var initializeActionEventHandlers =  function() {
    jQuery('#button_create').click(handleCreateNewTemplateAction);
    jQuery('#template').change(fetchTemplate);
    jQuery('#delete_template').click(function(){
        var template_id = jQuery('#template').val();
        deleteTemplate(template_id);
    });
};

var handleCreateNewTemplateAction = function() {
    jQuery('#disabled_cal').hide();
    jQuery('#template').val(0);
    jQuery('#is_current_template_draft').val("1");
    jQuery('.ui-datepicker-trigger').show();
    jQuery('#template_start_date').val(moment(new Date()).format("MMMM D, YYYY"));
    createCalendarForAvailability();
    renderCalendarHeader();
    jQuery('#week-calendar').disableSelection();
    jQuery('#delete_template').hide();
    jQuery('#sub_title').html('New Template');
};

var initializeDatePicker = function(){
    jQuery('#today_date').find('span').html(moment(new Date()).format("dddd MMM D, YYYY"));
    jQuery("#template_start_date").datepicker({
        showOn: "button",
        buttonImage: "/images/calendar_date_select/calendar.gif",
        buttonImageOnly: true,
        buttonText: '',
        dateFormat: 'MM d, yy',
        beforeShow: positioningDatepicker,
        showOtherMonths: true,
        minDate : 0
    });
    if(jQuery('#is_current_template_draft').val() === "0"){
        jQuery('.ui-datepicker-trigger').hide();
        jQuery('#disabled_cal').show();
        jQuery('#template_status').show();
    }
};

var positioningDatepicker = function(input, inst) {
    var calendar = inst.dpDiv;
    setTimeout(function() {
        calendar.position({
            my: 'right top',
            at: 'right bottom',
            collision: 'none',
            of: input
        });
    }, 1);
};

var renderCalendarHeader = function() {
    jQuery('.wc-day-column-header').each(function(i, elem){
        jQuery(this).html(days[i]);
    });
};

var renderExisitngAvailabilities = function() {
    jQuery.each(availabilities, function(i, array){
        renderAvailability(id, array);
        id = id + 1;
    });
};

var renderAvailability = function(cal_id, availability) {
    var start_time = new Date(availability.start_time * 1000);
    var end_time = new Date(availability.end_time * 1000);
    var calendarEvent = new CalendarEvent(cal_id, 'Available',
        start_time, end_time);
    calendarEvent.createEvent();
};

var fetchAllEvents = function() {
    try {
        var events = jQuery('#week-calendar').weekCalendar("serializeEvents");
        var avlTimes = events.map(getSlotTimes);
        return avlTimes;
    }
    catch(error) {
        alert("Some of the availabilities may not have been marked correctly. Please check and try again.");
        throw new Error('Error fetching calendar events. Process aborted.');
    }
};

var getSlotTimes = function(event) {
    return [event.start.getTime(), event.end.getTime()];
};

var createAvailabilityHash = function(avlTimes) {
    var avlHash = {};
    jQuery.each(avlTimes, function(index, avl){
        avlHash[index+""] = {
            'start' : avl[0],
            'end' : avl[1]
        };
    });
    return avlHash;
};

var fetchTemplate = function() {
    var templateId = jQuery('#template').val();
    if(templateId !== '0') {
        jQuery.blockUI();
        jQuery.ajax({
            type : 'GET',
            url: '/load_template?template_id='+templateId,
            success: function(templateData){
                jQuery.unblockUI();
                jQuery('#template_start_date').val(templateData.template_start_date);
                jQuery('#is_current_template_draft').val(templateData.template_status);
                availabilities = templateData.availabilities;
                createCalendarForAvailability();
                renderExisitngAvailabilities();
                renderCalendarHeader();
                if(templateData.template_status === 0){
                    jQuery('.ui-datepicker-trigger').hide();
                    jQuery('#disabled_cal').show();
                    jQuery('#template_status').show();
                } else {
                    jQuery('.ui-datepicker-trigger').show();
                    jQuery('#disabled_cal').hide();
                    jQuery('#template_status').hide();
                }
                jQuery('#sub_title').html(templateData.template_name);
                if(templateData.show_delete_button === true){
                    jQuery('#delete_template').show();
                }
                else{
                    jQuery('#delete_template').hide();
                }
                jQuery('#removable').val(templateData.removable);
            },
            failure: function(error){
                console.log(error);
                jQuery('#spinner').hide();
                alert('Something went wrong, Please report this problem');
            },
            error: function(error){
                console.log(error);
                jQuery('#spinner').hide();
                alert('Something went wrong, Please report this problem');
            }
        });
    } else {
        handleCreateNewTemplateAction();
    }
};

var handleSaveButtonClick = function(button) {
    var el = jQuery(button);
    jQuery('#requested_action').val(el.val());
    if(jQuery('#is_current_template_draft').val() === "0") {
        var availablities = fetchAllEvents();
        var template_id = jQuery('#template').val();
        saveTemplateData(availablities, '', template_id);
    } else {
        open_availability_edit_popup(button);
    }
    return false;
};

var open_availability_edit_popup  = function(button){
    var el = jQuery(button);
    var pos = el.offset();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#edit-popup-container').height()+20;
    if(jQuery("#edit-popup-container").css('top') == 'auto'){
        jQuery("#edit-popup-container").css( {
            "left": (pos.left - 225) + "px",
            "top": (pos.top - height - 15) + "px"
        } );
    }
    else{
        jQuery("#edit-popup-container").css( {
            "left": (pos.left - 225) + "px",
            "top": (pos.top - height) + "px"
        } );
    }
    jQuery("#edit-popup-container").show();
    return false;
};

var changeLabel = function(option){
    if(option == '1'){
        jQuery('#label_in_popup').val('');
    }else {
        val1 = jQuery('#label_in_popup').val();
        jQuery('#label_in_popup').val(val1);
    }
};

var closeEditPopup = function (){
    jQuery('#edit-popup-container').hide();
};

var saveTemplate = function(){
    var label_val=jQuery('#label_in_popup').val();
    var availablities = fetchAllEvents();
    var template_start_date = jQuery('#template_start_date').val();
    var effective_start_date = moment(template_start_date, "MMM D, YYYY").toDate();
    var error_flag = 0;
    var warn_flag = 0;
    var msg='';
    if(label_val === ''){
        msg += "* Label can't be blank.\n";
        error_flag = 1;
    }
    if(label_val && label_val.length < 3) {
        msg += '* Label is too short (minimum is 3 characters).\n';
        error_flag = 1;
    }
    if(label_val == 'What to call this schedule (required)'){
        msg+= '* Label value is not entered.\n';
        error_flag = 1;
    }
    if(effective_start_date.getTime() <= new Date().getTime()){
        msg+= '* Effective date should be future.\n';
        error_flag = 1;
    }
    if(!error_flag){
        var can_save_empty = true;
        if(availablities.length === 0){
            can_save_empty = confirm('You have not specified availability for any session. Are you sure you want to proceed?\n');
        }
        if(can_save_empty){
            saveTemplateData(availablities, label_val, 0);
            closeEditPopup();
        }
    }
    else{
        jAlert('Template cannot be saved or submitted because of following error(s):\n\n'+msg);
    }
    closeEditPopup();
};

var saveTemplateData = function(availablities, label_val, template_id) {
    var template_start_date = jQuery('#template_start_date').val();
    var avlHash = createAvailabilityHash(availablities);
    var coach_id = jQuery('#coach_id').val();
    var requested_action = jQuery('#requested_action').val();
    var data = {
        'coach_id': coach_id,
        'requested_action' : requested_action,
        'availabilities' : avlHash,
        'template_id' : template_id,
        'label' : label_val,
        'template_start_date' : template_start_date
    };
    jQuery.blockUI();
    jQuery.ajax({
        type : 'POST',
        url: '/save_template',
        data : data,
        async: false,
        success: function(response){
            jQuery.unblockUI();
            if(requested_action === "Save and Submit"){
                if(response.sub_required === "true"){
                    if(confirm("There are some sessions/appointments which will be substitute triggered. Do you want to continue?")){
                        approveTemplate(response.template_id);
                        redirectBackToSchedules();
                    } else {
                        deleteTemplateData(response.template_id, false);
                    }
                }else{
                    if(jQuery('#is_manager').val() === "false"){
                        alert(response.template_label+ " template has been created successfully.");
                    }
                    redirectBackToSchedules();
                }
            } else {
                alert("The template " +response.template_label+ " has been saved successfully as a draft");
                showNewTemplate(response);
            }
        },
        failure: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            jQuery.unblockUI();
        },
        error: function(error){
            console.log(error);
            alert(error.responseText);
            jQuery.unblockUI();
        }
    });
};

var approveTemplate = function(template_id){
    jQuery.blockUI();
    jQuery.ajax({
        type : 'POST',
        data: {'template_id' : template_id},
        url: '/approve_template',
        async: false,
        success: function(template_label){
            jQuery.unblockUI();
            if(jQuery('#is_manager').val() === "false"){
                alert(template_label+ " template has been created successfully.");
            }
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
};

var deleteTemplate = function(template_id){
    if(jQuery('#removable').val() === "true"){
        jQuery.alerts.okButton = ' YES ';
        jQuery.alerts.cancelButton = ' NO ';
        jQuery.alerts.confirm("Are you sure want to delete the template? ", "Confirm", function(result){
            if(result){
                deleteTemplateData(template_id, true);
                redirectBackToSchedules();
            }
        });
    }else{
        alert('You have sessions/appointments based on this template. So this cannot be deleted.');
    }
    return false;
};

var deleteTemplateData = function(template_id, showAlert) {
    var coach_id = jQuery('#coach_id').val();
    jQuery.blockUI();
    jQuery.ajax({
        type : 'POST',
        async : false,
        data: {
            'template_id' : template_id,
            'coach_id'  : coach_id
        },
        url: '/delete_template',
        success: function(template_label){
            jQuery.unblockUI();
            if(showAlert)
                alert("Template " +template_label+ " has been deleted successfully");
        },
        failure: function(error){
            console.log(error);
            alert('Something went wrong, Please report this problem');
            jQuery.unblockUI();
        },
        error: function(error){
            console.log(error);
            alert(error.responseText);
            jQuery.unblockUI();
        }
    });
};

var showNewTemplate = function(response){
    if(jQuery('#is_current_template_draft').val() === "1") {
        jQuery('#template').append("<option value='"+response.template_id+"'>"+response.template_label+"</option>");
        jQuery('#template').val(response.template_id);
        fetchTemplate();
    }
};

var redirectBackToSchedules = function() {
    var url = jQuery('a#schedule_link').attr('href');
    if(url === "/")
        window.location.reload();
    else
        window.location = url;
};

var selectAppropriateSubNav = function() {
  jQuery('a[href="/my_schedule"]').filter(function(){return jQuery(this).text() == "My Schedule";}).parent().attr("class", "active");
  jQuery('a[href="/coach_scheduler"]').parent().toggleClass('main active');
};
