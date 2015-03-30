jQuery(document).ready(function(){
    elem = jQuery('#time_off_link');
    elem.live('click', function(){
        list_timeoff();
    });
    $('#full_day_check').live('click',function(e){
            if(jQuery('#full_day_check').attr('checked')=='checked'){
                //if it is for selecting start date then default the time to 00:00 of the selected day
                jQuery('.ui-timepicker-select').attr('value',0);
                $.datepicker._get($.datepicker._curInst,'timepicker').hour=0;
                $.datepicker._get($.datepicker._curInst,'timepicker').minute=0;
                //if end date then default the time to 00:00 of the next day
                if($.datepicker._curInst.id == 'modification_end_date'){
                    $.datepicker._curInst.selectedDay=parseInt(jQuery('.ui-datepicker-current-day').text(),10) + 1;
                }
                //invoke the onTimeChange function of datepicker to change the display time accordingly 
                $.datepicker._get($.datepicker._curInst,'timepicker')._onTimeChange();
                //modify the label for time if All Day is checked
                if($.datepicker._curInst.id == 'modification_start_date'){
                    jQuery('.ui_tpicker_time_label').text('Begins');
                    jQuery('.ui_tpicker_time').text(jQuery('.ui_tpicker_time').text() + " of selected day");
                    //Default the end time to start date + 1
                    var toDate = new Date($.datepicker._curInst.selectedYear, $.datepicker._curInst.selectedMonth, $.datepicker._curInst.selectedDay);
                    var oneDay = new Date(toDate.getTime()+86400000);//adding 1 day
                    jQuery("#modification_end_date").datepicker("setDate", oneDay);
                }
                else if($.datepicker._curInst.id == 'modification_end_date'){
                    jQuery('.ui_tpicker_time_label').text('Ends');
                    jQuery('.ui_tpicker_time').text(jQuery('.ui_tpicker_time').text() + " of following day");
                }
                jQuery('.ui-timepicker-select').attr('disabled','disabled');
            }
            else{// if unchecked then enable the hour and minute dropdown, bring back the old text for time
                jQuery('.ui-timepicker-select').attr('disabled',false);
                jQuery('.ui_tpicker_time_label').text('Time');
                jQuery('.ui_tpicker_time').text(jQuery('.ui_tpicker_time').text().replace(' of following day',''));
                jQuery('.ui_tpicker_time').text(jQuery('.ui_tpicker_time').text().replace(' of selected day',''));
            }
    });
    jQuery('#new_time_off').live('click', function(){
        constructQtipWithTip(this, 'CREATE TIME OFF', '/create-timeoff', {
            solo:false,
            remove:false
        });
    });

    jQuery('.edit_timeoff').live('click', function(){
        constructQtipWithTip(this, 'EDIT TIME OFF', '/edit-timeoff?mod_id='+jQuery(this).attr('id'), {
            solo:false,
            remove:false
        });
    });

    jQuery(".cancel_timeoff").live('click', function() {
        var timeoff = this.id;
        jQuery.alerts.okButton = ' YES ';
        jQuery.alerts.cancelButton = ' NO ';
        jQuery.alerts.confirm('Are you sure?', "Confirm", function(result){
            if (result) {
                jQuery.blockUI();
                jQuery.ajax({
                url:'/cancel-timeoff',
                data: {
                    timeoff_id: timeoff
                    },
                success: function(data){
                    alert(data);
                    jQuery.unblockUI();
                    location.reload();
                    },
                error: function(data){
                    alert(data.responseText);
                    jQuery.unblockUI();
                    }
                });
            }
        });
    });

    jQuery('#save_timeoff').live('click', function(){
        var error = validateTimeoffData();
        if(error === ""){
            jQuery.blockUI();
            jQuery.ajax({
                url:'/check-policy-violation',
                data: {
                    start_date: jQuery('#modification_start_date').val(),
                    end_date: jQuery('#modification_end_date').val(),
                    timeoff_id: jQuery('#timeoff_id').val()
                },
                success: function(data){
                    if((data.toString() === "false") || confirm('Your requested time off may affect live sessions and scheduled learners. Do you still want to continue?')){
                        saveTimeoff();
                    }else{
                        jQuery.unblockUI();
                    }
                },
                error: function(data){
                    alert(data.responseText);
                    jQuery.unblockUI();
                }
            });
        }else{
            alert(error);
        }
    });
});

var validateTimeoffData = function(){
    var start_date = new Date(jQuery('#modification_start_date').val()).getTime();
    var end_date = new Date(jQuery('#modification_end_date').val()).getTime();
    var comment = jQuery('#comments').val();
    var error = "";
    if(jQuery('#previous_start_date').size() > 0 && new Date(jQuery('#previous_start_date').val()).getTime() === start_date && new Date(jQuery('#previous_end_date').val()).getTime() === end_date)
        error = "No change was made to the start or end date.";
    else if(start_date <= new Date().getTime())
        error = "Start Date must be in future.";
    else if(start_date >= end_date)
        error = "End Date must be after Start Date.";
    else if(comment === "")
        error = "Please enter a valid reason.";
    return error;
};

var saveTimeoff = function(){
    jQuery.ajax({
        url:'/save-timeoff',
        data: {
            start_date:jQuery('#modification_start_date').val(),
            end_date:jQuery('#modification_end_date').val(),
            comments: jQuery('#comments').val(),
            timeoff_id: jQuery('#timeoff_id').val()
        },
        success: function(data){
            alert(data);
            jQuery.unblockUI();
            list_timeoff();
        },
        error: function(data){
            alert(data.responseText);
            jQuery.unblockUI();
        }
    });
};

var list_timeoff = function(){
    constructQtipWithoutTip(elem, 'TIME OFF', '/list-timeoff', {});
};
