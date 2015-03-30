jQuery(document).ready(function(){
    registerReflexReportGenerator();
    if(jQuery("#reflexurl").val()=="generate_eng")
    {
        jQuery("#titlereflex").html("All American English");
    }
});

var registerReflexReportGenerator = function(){
    jQuery('#reflex_report_generator').click(function(e){
        e.preventDefault();
        if(validation())
        {
        jQuery("#reflex_data_contents").hide();
        jQuery("#export_to_csv").hide();
        jQuery("#big_spinner").show();
        var form = jQuery('form#reflex_report_form');
        var url = jQuery("#reflexurl").val();
        jQuery.ajax({
            url: url,
            data: form.serialize(),
            success: function(data){
                jQuery("#big_spinner").hide();
                jQuery("#reflex_data_contents").html(data);
                jQuery("#export_to_csv").show();
                jQuery("#reflex_data_contents").show();
                jQuery('#region_hidden').val(jQuery('#region').val());
                jQuery('#start_date_hidden').val(jQuery('#start_date').val());
                jQuery('#end_date_hidden').val(jQuery('#end_date').val());
            },
            error: function(jqXHR, textStatus, errorThrown){
                console.log(errorThrown);
                alert('Something went wrong, Please report this problem');
            }
        });
        }
    });
};
var validation=function(){
    start_date  = jQuery('#start_date').val();
    end_date    = jQuery('#end_date').val();
    if((start_date === '') || (end_date === '')){
        alert('Please select a Timeframe');
        return false;
    }
    var date1 = new Date(start_date);
    var date2 = new Date(end_date);
    if((date2 < date1)) {
      alert("End date must not be less than the start date selected.");
      return false;
    }
    return true;
};

var changeTimeframe = function(timeframe){
    jQuery('#custom_time_select').slideUp("slow");
    var today_start = moment().startOf('day');
    switch(timeframe.value){
      case 'Last month':
        setTimeFields(today_start.clone().subtract('months', 1) , today_start.subtract('minutes', 1));
        break;
      case 'Last week':
        setTimeFields(today_start.clone().subtract('days', 7) , today_start.subtract('minutes', 1));
        break;
      case 'Yesterday':
        setTimeFields(today_start.clone().subtract('days', 1) , today_start.subtract('minutes', 1));
        break;
      case 'Today':
        setTimeFields(today_start.clone() , today_start.add('days', 1).subtract('minutes', 1));
        break;
      case 'Tomorrow':
        setTimeFields(today_start.clone().add('days', 1) , today_start.add('days', 2).subtract('minutes', 1));
        break;
      case 'Next Week':
        setTimeFields(today_start.clone().add('days', 1) , today_start.add('days', 8).subtract('minutes', 1));
        break;
      case 'Next Month':
        setTimeFields(today_start.clone().add('days', 1) , today_start.add('months', 1).add('days', 1).subtract('minutes', 1));
        break;
      case 'Custom':
        setTimeFields(today_start.subtract('months', 1) , moment().endOf('day'));
        jQuery('#custom_time_select').slideDown("slow");
        break;
      case 'Select a Timeframe':
        setTimeFields('','');
        break;
      default:
        break;
    }
};

var setTimeFields = function(start_time, end_time){
    jQuery('#start_date').val(format(start_time));
    jQuery('#end_date').val(format(end_time));
};
var format = function(momentObj){
    if(momentObj === '')
        return '';
    else
        return momentObj.format('MMMM D, YYYY hh:mm A');
};