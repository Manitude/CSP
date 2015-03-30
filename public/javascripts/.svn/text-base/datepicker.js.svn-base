jQuery(document).ready(function(){
    if(jQuery( ".jquery_datepicker" ).size() > 0){
        jQuery( ".jquery_datepicker" ).datepicker({
            showOn: "button",
            buttonImage: "/images/calendar_date_select/calendar.gif",
            buttonImageOnly: true,
            buttonText: '',
            dateFormat: 'MM d, yy',
            beforeShow: positioningDatepicker

        });
    }
    if(jQuery( ".datetimepicker" ).size() > 0){
        jQuery('.datetimepicker').datetimepicker({
            controlType: 'select',
            showOn: "button",
            timeFormat: 'hh:mm TT',
            buttonImage: "/images/calendar_date_select/calendar.gif",
            buttonImageOnly: true,
            stepMinute : 30,
            showMinute: true,
            dateFormat: 'MM d, yy',
            beforeShow: positioningDatepicker,
            minDateTime : new Date(jQuery('#modification_start_date').val())
        });       
    }
});

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