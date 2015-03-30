var getTimeZone = function(){
    var date = new Date().toString();
    return date.substring(date.indexOf("(")+1, date.indexOf(")"));
};

var configureWeekCalender = function(){
    jQuery('td.wc-time-column-header').text('TIME ('+getTimeZone()+')').css('text-align', 'center');
    jQuery('td.wc-day-column-header').css('border-left', '1px solid #999');
    schedulerTableHeaderPosition = parseInt(jQuery('.wc-header').offset().top, 10);
    bindTableHeaderToFixOnScroll();
};

var bindTableHeaderToFixOnScroll = function() {
    jQuery(window).scroll(function() {
        if(parseInt(window.pageYOffset, 10) > schedulerTableHeaderPosition) {
            jQuery('.wc-header').addClass('fix-header');
        } else {
            jQuery('.wc-header').removeClass('fix-header');
        }
    });
};

var slotEvents = function(id, title, start_time, end_time, slotType){
    var event = new CalendarEvent(id, title, start_time, end_time);
    event.slotType = slotType;
    event.createEvent();
};

//CalendarEvent is an object representing a calendar event
var CalendarEvent = function(id, title, start_time, end_time) {
    this.id          = id;
    this.title       = title;
    this.start       = start_time;
    this.end         = end_time;
    this.createEvent = function(){
        jQuery('#week-calendar').weekCalendar("updateEvent", this);
    };
    this.removeEvent = function(){ 
        jQuery('#week-calendar').weekCalendar('removeEvent',id); 
    }; 
};

var createCalendar = function(calOptions){
    var defaultOptions = {
        timeslotsPerHour: 2,
        timeslotHeight: 50,
        allowCalEventOverlap: true,
        overlapEventsSeparate: true,
        businessHours: {start: 0, end: 0, limitDisplay: false},
        showHeader: false,
        readonly: true,
        // totalEventsWidthPercentInOneColumn : 95,
        height: function($calendar){
            return 2450;
        },
        eventAfterRender: function(calEvent, $event) {
            console.log(calEvent);
        },
        eventNew : function(calEvent, $event) {
            console.log(calEvent);
        },
        eventHeader: function(calEvent, calendar) {
            return '';
        },
        eventClick: function(calEvent, element) {
        }
    };
    jQuery('#week-calendar').weekCalendar(jQuery.extend(defaultOptions, calOptions));
    configureWeekCalender();
};
$.ui.weekCalendar.prototype._adjustForEventCollisions = function($weekDay, $calEvent, newCalEvent, oldCalEvent, maintainEventDuration) {
        var options = this.options;
        if (options.allowCalEventOverlap) {
            return;
        }
        var adjustedStart, adjustedEnd;
        var self = this;
        if (oldCalEvent.end - oldCalEvent.start === 3600000){
            return;
        }
        $weekDay.find('.wc-cal-event').not($calEvent).each(function() {
            var currentCalEvent = $(this).data('calEvent');
            if(jQuery("#is_one_hour_session").val() === "true"){
                return false;
            }
            if(currentCalEvent.id === undefined){
                return false;
            }
            //has been dropped onto existing event overlapping the end time
            if (newCalEvent.start.getTime() < currentCalEvent.end.getTime() &&
                newCalEvent.end.getTime() >= currentCalEvent.end.getTime()) {
                adjustedStart = currentCalEvent.end;
            }
            //has been dropped onto existing event overlapping the start time
            if (newCalEvent.end.getTime() > currentCalEvent.start.getTime() &&
                newCalEvent.start.getTime() <= currentCalEvent.start.getTime()) {
                adjustedEnd = currentCalEvent.start;
            }
            //has been dropped inside existing event with same or larger duration
            if (oldCalEvent.resizable === false ||
                (newCalEvent.end.getTime() <= currentCalEvent.end.getTime() &&
                    newCalEvent.start.getTime() >= currentCalEvent.start.getTime())) {
                adjustedStart = oldCalEvent.start;
                adjustedEnd = oldCalEvent.end;
                return false;
            }
        });
        newCalEvent.start = adjustedStart || newCalEvent.start;    
        if (adjustedStart && maintainEventDuration) {
            newCalEvent.end = new Date(adjustedStart.getTime() + (oldCalEvent.end.getTime() - oldCalEvent.start.getTime()));
            self._adjustForEventCollisions($weekDay, $calEvent, newCalEvent, oldCalEvent);
        } else {
            newCalEvent.end = adjustedEnd || newCalEvent.end;
        }        
        //reset if new cal event has been forced to zero size
        if (newCalEvent.start.getTime() >= newCalEvent.end.getTime()) {
            newCalEvent.start = oldCalEvent.start;
            newCalEvent.end = oldCalEvent.end;
        }    
        $calEvent.data('calEvent', newCalEvent);
};

