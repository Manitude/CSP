jQuery(document).ready(function(){
    jQuery( "#end_date" ).datepicker({
        showOn: "button",
        buttonImage: "/images/calendar_date_select/calendar.gif",
        buttonImageOnly: true,
        buttonText: '',
        dateFormat: 'MM d, yy',
        beforeShow: positioningDatepicker,
        onSelect: onSelectDateFromPicker
    });

    jQuery('#today_button, #previous_week, #next_week').live('click', function(){
        var from = jQuery(this).attr('id');
        if(from === "today_button"){
            var start_date = moment().subtract("days", moment().day());
            setStartEndDates(start_date);
        }else if(from === "previous_week"){
            changeCalenderDates('subtract');
        }else if(from === "next_week"){
            changeCalenderDates('add');
        }
    });
});

var setStartEndDates = function(date){
    jQuery('#start_date').val(formatGivenDate(date));
    jQuery('#end_date').val(formatGivenDate(moment(date).add("days",6)));
    redirectPage(); // define in respective js
};

var formatGivenDate = function(date){
    return moment(date).format("MMMM DD, YYYY");
};

var formatDateForPopup = function(date){
    return '<span style="color: #1090CF;">'+ moment(date).format("ddd MM/DD/YYYY hh:mmA") + '</span>';
};

var currentSelectedDateAsString = function(){
    var date = new Date(jQuery('#start_date').val());
    return moment(date).format("YYYY-MM-DD");
};

var changeCalenderDates = function(operation){
    var start_date = new Date(jQuery('#start_date').val());
    start_date = (operation == 'add')? moment(start_date).add("days", 7) : moment(start_date).subtract("days", 7);
    setStartEndDates(start_date);
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

var onSelectDateFromPicker = function(dateText) {
    var selectedDate = moment(new Date(dateText));
    var start_date = moment(selectedDate).subtract("days",selectedDate.day());
    setStartEndDates(start_date);
};
