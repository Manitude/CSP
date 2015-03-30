var reportTemplate;
var optionDatesTemplate;
var spinner;
var createExtraSessionPopUpTemplate;
var createExtraSessionPopUpTemplateForEmptyCoachList;
var currentDate;
var currentDateIndex;

jQuery(document).ready(function () {
    crir.init();
    jQuery("#staffing_report_wrapper").delegate("[id^=create_extra_sessions_button_]","click", function(){
        openCreateExtraSessionPopupForReflex(jQuery(this));
    });
    jQuery("#smr-create-popup-container").css("visibility", "hidden");

    

    jQuery('#content-header').find("h2:contains('Staffing Model Reconciliation Report')").hide();
    currentDate=null;
    currentDateIndex=null;
    spinner = jQuery("<img alt='Please Wait..' src='/images/big_spinner.gif'/>");
    reportTemplate = Hogan.compile(staffingTemplate());
    optionDatesTemplate = Hogan.compile(optionsForDateTemplate());
    createExtraSessionPopUpTemplate = Hogan.compile(extraSessionPopUpTemplate());
    createExtraSessionPopUpTemplateForEmptyCoachList = Hogan.compile(extraSessionPopUpTemplateForEmptyCoachList());
    handleWeekChange();
    handleDateChange();
    fixTableHeaders();
    fixHorizontalScrollingForMac();
    loadDefaultWeek();
});

var loadDefaultWeek = function() {
    if(jQuery('select#staffing_report_week').val() === '-1') {
        jQuery('select#staffing_report_date').prop("selectedIndex", 0);
        jQuery('select#staffing_report_week').prop("selectedIndex", 0);
        jQuery("#staffing_report_date").attr('disabled','disabled');
    } else {
        fetchDataForTheWeek(jQuery('select#staffing_report_week').val());
    }
};

var fixHorizontalScrollingForMac = function() {
    document.addEventListener('DOMMouseScroll', function(e) {
        if (e.axis == e.HORIZONTAL_AXIS) {
            e.stopPropagation();
            e.preventDefault();
            e.cancelBubble = false;
        }
        return false;
    }, false);
};

var fixTableHeaders = function() {
    jQuery('#staffing_report_table').fixheadertable({
        height: 460,
        colratio: [80, 80, 100, 100, 100, 82, 110, 110, 190]
    });
    jQuery('.ui-widget').css('padding', '0px');
    jQuery('.body').css('height','70px');
    jQuery('.body').css('overflow-x','hidden');
};

var handleWeekChange = function() {
    jQuery('select#staffing_report_week').live('change', function (e) {
        currentDateIndex = null;
        currentDate = null;
        var source = jQuery(e.target);
        if (source.val() != '-1') {
            jQuery("#staffing_report_date").attr('disabled','disabled');
            fetchDataForTheWeek(source.val());
        } else {
            jQuery('#staffing_report_table > tbody').html("<tr height='70px'><td colspan='9'>No Data To Show</td></tr>");
            jQuery("#staffing_report_date").html('<option>All</option>');
            jQuery("#staffing_report_date").attr('disabled','disabled');
            jQuery('#export_staffing_data').hide();
            jQuery('.body').css('height','70px');
        }
    });
};

var handleDateChange = function() {
    jQuery('select#staffing_report_date').live('change', function (e) {
        var value = jQuery('select#staffing_report_date').prop("selectedIndex");
        showReportForTheDay(value);
    });
};

var fetchDataForTheWeek = function(WeekId) {
    jQuery('#staffing_report_table > tbody').html("<tr height='70px'><td colspan='9'></td></tr>");
    jQuery('#staffing_report_table').find('td').html(spinner);
    jQuery('.body').css('height','70px');
    jQuery.ajax({
        type : 'GET',
        url: '/get_report_data_for_a_week',
        data: {"week_id":WeekId},
        success: function(reportData){
            if(reportData.report_data.length === 0) {
                alert('The data for this week has been refreshed. Please reload the page and try again.');
                jQuery('#staffing_report_table').find('td').html('No Data To Show');
            } else {
                jQuery('input#week_id').attr('value',WeekId);
                populateReportDataFromTemplate(reportData);
            }
        },
        complete: function(){
            if(currentDateIndex!==null)
                showReportForTheDay(currentDateIndex);
        },
        failure: function(error){
            console.log(error);
            jQuery('#staffing_report_table').find('td').html('No Data To Show');
            alert('Something went wrong, Please report this problem');
        },
        error: function(error){
            console.log(error);
            jQuery('#staffing_report_table').find('td').html('No Data To Show');
            alert('Something went wrong, Please report this problem');
        }
    });
};

var populateReportDataFromTemplate = function(reportData) {
    var day_index = 0;
    var data = {
        'list' : reportData.report_data,
        'dates': reportData.dates,
        'day'  : function() {
            day_index++;
            return Math.ceil(day_index/reportData.no_of_slots);
        }
    };

    jQuery('.body').css('height','500px');
    
    var tableBody = reportTemplate.render(data);
    var options = optionDatesTemplate.render(data);

    var time_zone = reportData.report_data[0]['staffing_data']['time_zone'];
    jQuery('#staffing_report_header > tr > th').first().html(time_zone + ' Date/Time');
    jQuery('#staffing_report_header > tr > th').first().next().next().html('Time Slot (' + time_zone + ')');

    jQuery("#staffing_report_table tbody").html(tableBody);
    jQuery("#staffing_report_date").html(options);
    if(currentDate !== null) {
        jQuery("#staffing_report_date").val(currentDate);
    }
    jQuery("#staffing_report_date").removeAttr('disabled');
    /* jQuery('.staffing-button').attr('disabled','disabled');*/
    jQuery('#export_staffing_data').show();
};

var showReportForTheDay = function(dayToShow){
    if(dayToShow === 0) {
        jQuery('#staffing_report_table').find('tr').show();
    } else {
        for(var day=1; day<=7; day+=1) {
            if( day === dayToShow) {
                jQuery('tr.day_'+day).show();
            } else {
                jQuery('tr.day_'+day).hide();
            }
        }
    }    
};

var staffingTemplate = function(lang_identifier,ext_village_id,session_start_time){
    var reportTableTemplate = "";

    reportTableTemplate += "{{#list}}<tr class='day_{{day}}'>";
    reportTableTemplate += "<td>{{staffing_data.timeslot_est}}</td>";
    reportTableTemplate += "<td>{{staffing_data.timeslot_kst}}</td>";
    reportTableTemplate += "<td style='background-color: {{staffing_data.row_color}}'>{{staffing_data.timeslot}}</td>";
    reportTableTemplate += "<td style='background-color: {{staffing_data.row_color}}'>{{staffing_data.number_of_coaches}}</td>";
    reportTableTemplate += "<td style='background-color: {{staffing_data.row_color}}'>{{staffing_data.actual_scheduled}}</td>";
    reportTableTemplate += "<td style='background-color: {{staffing_data.row_color}}'>{{staffing_data.delta}}</td>";
    reportTableTemplate += "<td style='background-color: {{staffing_data.row_color}}'>{{staffing_data.extra_sessions_scheduled}}</td>";
    reportTableTemplate += "<td style='background-color: {{staffing_data.row_color}}'>{{staffing_data.extra_sessions_grabbed}}</td>";
    reportTableTemplate += "<td> <button id='create_extra_sessions_button_{{staffing_data.timeslot_est}}' {{staffing_data.enable_create_extra_session}}>Create Extra Session</button></td>";// only extra session button
    reportTableTemplate += "<td id='utc_time_slot' style='display:none'>{{staffing_data.utc_time}}</td>";
    reportTableTemplate += "</tr>{{/list}}";    

    return reportTableTemplate;
};

var optionsForDateTemplate = function() {
    var optionsTemplate = "";

    optionsTemplate += "<option>All</option>{{#dates}}";
    optionsTemplate += "<option>{{.}}</option>";
    optionsTemplate += "{{/dates}}";
    
    return optionsTemplate;
};


var extraSessionPopUpTemplate = function() {
    var extraSessionPopUpTemplate = "";
    extraSessionPopUpTemplate += "<div class='smr-popup-top'><div class='close-smr-create-popup'>X</div></div>";
    extraSessionPopUpTemplate += "<div id='smr-create-popup-content'>";
    extraSessionPopUpTemplate += "<div id='head_section'>";
    extraSessionPopUpTemplate += "<div class='title_lotus' style='' id='title'>NEW SHIFT</div>";
    extraSessionPopUpTemplate += "<div id='create_popup_time' value='{{est_start_time}}'>{{session_start_time}}</div>";

    extraSessionPopUpTemplate += "</div>";
    extraSessionPopUpTemplate += "<div style='float: left; position: relative; width: 100%;' id='bottom_part_of_facebox'>";

    extraSessionPopUpTemplate += "<div id='available_coaches_container'>";
    extraSessionPopUpTemplate += "Included Coaches :";
    extraSessionPopUpTemplate += "<div id='excluded_coach_list_container'>";
    extraSessionPopUpTemplate += "<ul id='excluded_coach_list_ul'>";

    extraSessionPopUpTemplate += "{{#coaches}}<li class='excluded_coach_list_li' id='list-{{coach.id}}'>";
    extraSessionPopUpTemplate += "<input type='checkbox' checked='checked' value='{{coach.id}}' name='coach_name' class='excluded_coaches_checkbox' id='checkbox-{{coach.id}}'>";
    extraSessionPopUpTemplate += "<label title='{{coach.full_name}}' class='excluded_coaches_label' for='checkbox-{{coach.id}}'>{{coach.full_name}} </label>";

    extraSessionPopUpTemplate += "</li>{{/coaches}}";


    extraSessionPopUpTemplate += "</ul>";
    extraSessionPopUpTemplate += "</div>";
    extraSessionPopUpTemplate += "</div>";
    extraSessionPopUpTemplate += "<div class='right_container lotus_extra_right'>";
    extraSessionPopUpTemplate += "<div style='padding-bottom: 10px;' id='extra_session_name'>";
    extraSessionPopUpTemplate += "Session Name:";
    extraSessionPopUpTemplate += "<div>";
    extraSessionPopUpTemplate += "<input type='text' name='session_name_txt' id='session_name_txt'>";
    extraSessionPopUpTemplate += "</div>";
    extraSessionPopUpTemplate += "</div>";
    extraSessionPopUpTemplate += "<div id='button_container'>";
    extraSessionPopUpTemplate += "<input type='button' value='CREATE' onclick='this.disabled = true; createExtraSessionReflex({{lang_id}});' class='button'>";
    extraSessionPopUpTemplate += "</div>";
    extraSessionPopUpTemplate += "</div>";

    extraSessionPopUpTemplate += "</div>";
    extraSessionPopUpTemplate += "</div>";
extraSessionPopUpTemplate += "<div class='smr-popup-btm'></div>";
extraSessionPopUpTemplate += "</div>";
 

    return extraSessionPopUpTemplate;
};


var openCreateExtraSessionPopupForReflex = function(obj){
    obj.attr("disabled", "disabled");
    jQuery("#smr-create-popup-container").css("visibility", "visible");
    var lang_identifier = "KLE";
    var session_start_time = jQuery(obj).parent().next().text();
    var path = 'show_create_extra_session_popup_reflex_smr/'+lang_identifier+'/'+session_start_time;
    jQuery('body').addClass('cursor_wait');
    jQuery('#content').addClass('cursor_wait');
    jQuery.ajax({
        type: "get",
        async: true,
        url: path,
        success: function(data){
            //               jQuery("#smr-create-popup-content").html(data);
            populateCreateSessionPopupTemplate(data,obj);
            
        }

    });
jQuery("#smr-create-popup-container").delegate(".close-smr-create-popup","click", function(){
        jQuery("#smr-create-popup-container").hide();
        obj.removeAttr("disabled");
        enableBackground();
    });
    

};

var extraSessionPopUpTemplateForEmptyCoachList = function(){
    var extraSessionForEmptyCoachList="";
    extraSessionForEmptyCoachList += "<div class='smr-popup-top'><div class='close-smr-create-popup'>X</div></div>";
    extraSessionForEmptyCoachList += "<div id='smr-create-popup-content'>";
    extraSessionForEmptyCoachList += "<link type='text/css' rel='stylesheet' media='screen' href='/stylesheets/crir.css?1337590002'>";
    extraSessionForEmptyCoachList += "<div id='create_new_session_smr'>";
    extraSessionForEmptyCoachList += "<div id='head_section'>";
    extraSessionForEmptyCoachList += "<div class='title_lotus' style='' id='title'>NEW SHIFT</div>";
    extraSessionForEmptyCoachList += "<div id='create_popup_time'>{{session_start_time}}</div>";
    extraSessionForEmptyCoachList += "</div>";
    extraSessionForEmptyCoachList += "<div style='float: left; position: relative; width: 100%;' id='bottom_part_of_facebox'>";
    extraSessionForEmptyCoachList += "There are no active coaches qualified to teach this language.";
    extraSessionForEmptyCoachList += "</div>";
    extraSessionForEmptyCoachList += "</div>";
    extraSessionForEmptyCoachList += "</div>";
    extraSessionForEmptyCoachList += "<div class='smr-popup-btm'></div>";
    extraSessionForEmptyCoachList += "</div>";
    return extraSessionForEmptyCoachList;
};



var populateCreateSessionPopupTemplate = function(data, obj){
    var coach_data = {
        'coaches' : data.coaches,
        'lang_id' : data.lang_id,
        'session_start_time' : data.session_start_time,
        'est_start_time' : data.est_start_time
    };
    var popup = '';
    if(data.coaches.length>0){
        popup = createExtraSessionPopUpTemplate.render(coach_data);
    }else{
        popup = createExtraSessionPopUpTemplateForEmptyCoachList.render(coach_data);
    }
    //    jQuery("#smr-create-popup-container").html(popup);
    jQuery("#smr-create-popup-container").html(popup);
    
    var leftcreate = obj.offset().left-jQuery("#content").offset().left-20;
    var topcreate  = obj.offset().top-jQuery("#content").offset().top-jQuery("#smr-create-popup-container").height();//+(jQuery(obj).height()-jQuery("#srm-create-popup-container").height());
    jQuery('html,body').animate({
        scrollTop: topcreate,
        scrollLeft: leftcreate
    }, 1000);
    jQuery("#smr-create-popup-container").css({
        left:leftcreate+"px",
        top: topcreate+"px"
    });
    jQuery('body').removeClass('cursor_wait');
    jQuery('#content').removeClass('cursor_wait');
    jQuery("#smr-create-popup-container").show();
    disableBackground();
};

var createExtraSessionReflex = function(lang_id){
    if(validateSessionNameLength()){
    var path;
    var start_time      = jQuery('#create_popup_time').attr('value');
    var session_name    = jQuery('#session_name_txt').val();
    var coach_ids       = collectSelectedCoachIds();
    path = 'create_extra_session_reflex_smr';
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
        success: function(data){
            currentDate=jQuery('#staffing_report_date').attr('value');
            currentDateIndex = jQuery('select#staffing_report_date').prop("selectedIndex");
            alert(data);
            fetchDataForTheWeek(jQuery('#staffing_report_week').attr('value'));
        },
        complete: function() {
            jQuery("#smr-create-popup-container").hide();
            enableBackground();
        }
    });
    }else{
        jQuery('#button_container input').removeAttr('disabled');
    }

};

var collectSelectedCoachIds = function(){
    var coach_ids = [];
    var coach_list_array = jQuery('#excluded_coach_list_ul').find('li>input:not(:checked)');
    jQuery.each(coach_list_array, function() {
        coach_ids.push(jQuery(this).val());
    });
    return coach_ids;
};

var validateSessionNameLength = function(){
    var max_length_for_session_name = 80;
//    jQuery('#session_name_txt').live('change', function () {
if(jQuery('#session_name_txt').val().length > max_length_for_session_name){
         alert('Session name cannot exceed 80 characters.');
         jQuery('#session_name_txt').val(jQuery('#session_name_txt').val().substring(0,max_length_for_session_name));
        return false;
}else{
    return true;
}
};


var disableBackground = function(){
  jQuery('#staffing_report_week').attr('disabled','disabled');
  jQuery('#staffing_report_date').attr('disabled','disabled');
  jQuery('.body').css('overflow-y','hidden');

};

var enableBackground = function(){
jQuery('#staffing_report_week').removeAttr('disabled');
jQuery('#staffing_report_date').removeAttr('disabled');
jQuery('.body').css('overflow-y','scroll');
};