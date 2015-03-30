var captionRowStatus = 'none';
var imageLink = "/images/next.png";
var imageTitle = "Click to Expand";

function displayRow(){
  var images = document.getElementById("img");
  if(jQuery('#caption_row').is(":hidden")){
      jQuery('#caption_row').slideDown("slow");
      if (jQuery('#help_requested_by').is(":hidden")) {
        jQuery('#spacer').slideDown("slow");
    } 
      images.src = "/images/down_arrow.png";
      images.title = "Click to Collapse";
      captionRowStatus = 'block';
      imageLink = "/images/down_arrow.png";
      imageTitle = "Click to Collapse";
      jQuery('#big-info').fadeOut("fast", function(){
          jQuery('#lotus_data_space').slideDown("slow");
      });
  }else{
      jQuery('#caption_row').slideUp("slow");
      jQuery('#spacer').slideUp("slow");
      images.src = "/images/next.png";
      images.title = "Click to Expand";
      captionRowStatus = 'none';
      imageLink = "/images/next.png";
      imageTitle = "Click to Expand";
      jQuery('#lotus_data_space').slideUp("slow",function(){
          jQuery('#big-info').fadeIn();
      });
  }
}

var loadLotusData = function(){
    var lotusElement = jQuery('#lotus_real_time_data');
    if(lotusElement.length > 0){
        jQuery.ajax({
            url: '/lotus_real_time_data?coach_details_viewable=false',
            success: function(data){
                console.log('fetched lotus data successfully');
                lotusElement.html(data);
                scheduleLotusDataFetch();
            },
            failure: function(error){
                console.log(error);
                scheduleLotusDataFetch();
            },
            error: function(error){
                console.log(error);
                scheduleLotusDataFetch();
            }
        });
    }
};

var scheduleLotusDataFetch = function(){
    setTimeout('loadLotusData()', (30 * 1000));
};

var setFaceboxWidth = function(){
    var wid = jQuery('.popup_coach_list').width();
    if (wid !== null)
        jQuery("#facebox").width(wid);
    else
        jQuery("#facebox").width('250px');
};

jQuery(document).ready(function () {
    loadLotusData();
    jQuery('#entry_time').live('click', function(){
         var title = jQuery(this).attr('coachname')+" - Last 5 Logins";
         constructQtipWithTip(this, title,'/last_5_logins',{
                  data: { coach_id: jQuery(this).attr('coachid')
                        
                },
                zIndex: '20000'
            });
    });
});