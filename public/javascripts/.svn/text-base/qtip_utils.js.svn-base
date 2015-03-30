var constructQtipWithoutTip = function(element, title, ajaxURL, options){
    constructQtipParamWithoutTip(element, title, ajaxURL, options);
};

var constructQtipWithTip = function(element, title, ajaxURL, options){
    constructQtipParamWithTip(element, title, ajaxURL, options);
};

var constructQtipParamWithoutTip = function(element, title, ajaxURL, options){
    var param = {
        style: {
            classes: 'ui-tooltip-dark ui-tooltip-rounded ui-tooltip-bootstrap'
        },
        position: {
            at: 'center',
            my: 'center',
            viewport: $(window)
        },
        hide: false
    };
    jQuery(element).qtip(jQuery.extend(qtipCommonParams(title, ajaxURL, options), param));
};

var constructQtipParamWithTip = function(element, title, ajaxURL, options){
    var windowsWidth = jQuery(window).width() ;
    var windowsHeight = jQuery(window).height() ;
    var eTop = jQuery(element).offset().top - jQuery(window).scrollTop() ;
    var eleft = jQuery(element).offset().left ;
    var at = 'bottomcenter' ;
    var my = 'topright';
    if((((windowsHeight - eTop)< 400)) && (((windowsWidth-eleft) > 700))){
        at ='topcenter';
        my ='bottomleft';
    }
    else if(((windowsHeight - eTop)< 400)){
        at ='topcenter';
        my ='bottomright';
    }
    else if((((windowsWidth-eleft) > 700))){
        at ='bottomcenter';
        my ='topleft';
    }
    
    var param = {
        style : {
            tip: {
                corner: true,
                width: 20,
                height:15,
                border: 2,
                offset: 20
            },
            classes: 'ui-tooltip-light ui-tooltip-rounded '
        },
        position: {
            at: at,
            my: my,
            effect: false // Disable positioning animation
        },
        hide: true
    };
    jQuery(element).qtip(jQuery.extend(qtipCommonParams(title, ajaxURL, options), param));
};

var qtipCommonParams = function(title, ajaxURL, options){
    jQuery(".qtip:hidden").remove();
    if(!options.hasOwnProperty("remove") || options.remove){
        jQuery(".qtip").remove();
    }
    var param = {
        content: {
            text: 'Loading...',
            title: {
                text: title,
                button: true
            },
            ajax: {
                url: ajaxURL,
                data: (options.data ? options.data : {}),
                success: function(response, status) {
                    this.set('content.text', response);
                }
            }
        },
        events: {
            hide: function(event, api) {
                if(options.canRemoveAllQtips)
                    jQuery(".qtip").remove();
            },
            focus: function(event, api){
                event.preventDefault();
                jQuery('canvas').css('z-index', '-1');
                jQuery('.ui-tooltip').css('z-index', (options.zIndex ? options.zIndex : '1'));
            }
        },
        style: {
            width: (options.width ? options.width : 540)
        },
        show: {
            solo: (options.hasOwnProperty("solo") ? options.solo : true),
            ready: true,
            event: (options.event ? options.event : 'click')
        }
    };
    return param;
};