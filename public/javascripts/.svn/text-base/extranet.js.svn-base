/*
 * Name: extranet.js
 * Description: This file contains all the javascirpt required for Success Extranet. Will be inculded in each file in success Extranet.
 * Libraries Used: prototype.js
 * Author: mshanker@listertechnologies.com
 * Date: 22 June 2010
 */

/*
 * Name : hide_basic_info
 * Description : Hides the basic sections that are present by default on the learner's profile page.
 *               Called when the user clicks on the Session Rating value or Attendance record value in the Studio section.
 * Additional Comment: $('community_profile','studio_info','rworld_info','try_new_search','time_on_languages','recent_course_info').invoke('hide');
 *               This one line statement does not seem to work well when one of the elts is not there in the list
 *               We can look into a better way of doing the same thing.
 */
  function hide_basic_info(){
    if($('general_info')){$('general_info').hide();}
    if($('community_profile')){$('community_profile').hide();}
    if($('studio_info')){$('studio_info').hide();}
    if($('rworld_info')){$('rworld_info').hide();}
    if($('try_new_search')){$('try_new_search').hide();}
    if($('time_on_languages')){$('time_on_languages').hide();}
    if($('recent_course_info')){$('recent_course_info').hide();}
    if($('moderation_details')){$('moderation_details').hide();}
  }

  function clear_learner_search(){
    $('query').clear();
    $('email').clear();
    $('name').clear();
    $('address').clear();
    return false;
  }
  function defaultInputFields(){
    jQuery("#search_by_which_id,#language,#village").find('option:first').attr('selected', 'selected');
    jQuery('#search_options_fname_start_with,#search_options_lname_start_with,#search_options_email_start_with').attr('checked',true);
    jQuery('#village').attr('disabled',false);
    jQuery('#search-results').empty();
    jQuery('#pagination').empty();
    jQuery('#print-button').hide();
    for (var i=0; i < elements.length; i++){
        jQuery("#"+elements[i]).val(default_values[i]);
        jQuery("#"+elements[i]).css('color','#888');
    }
    return false;
}

/*
 * Description : Used on the learner's profile page
 * Arguuments : type =>  can have three values(string): 1.attended 2.skipped 3.next
 */
  function show_attendance_details_for_session(type){
    hide_basic_info();
    $(type+'_session_attendance_details').show();
  }

/*
 * Description : Used on the learner's profile page
 * Arguuments : type =>  can have three values(string): 1.attended 2.skipped 3.next
 */
  function show_rating_details_for_session(type){
    hide_basic_info();
    $(type+'_session_rating_details').show();
  }

/*
 * Description : Used on the learner's profile page
 * Arguuments : type =>  can have three values(string): 1.attended 2.skipped 3.next
 */
  function show_coach_details_for_session(type){
    hide_basic_info();
    $(type+'_session_coach_details').show();
  }

/*
* Required for the drop-downs(Coruse-info and Rworld info) on the learner's profile page to work.
* Adds listeners to the drop-downs.
* Ajax calls are made when you change the value in the drop-downs.
*/
var SuccessExtranet = function() {
  var _config = null;

  return {
    init: function() {
      SuccessExtranet.RworldSocialAppInfo.init();
      SuccessExtranet.TotaleCourseInfo.init();
    },

    setConfig: function(config) {
      _config = config;
    },

    getConfig: function () {
      return _config;
    }
  };
}();


/*
 * Adding listeners to the events for the Learner profile page on page-load
 * Can be optimised, but unlike jQuery throws error if done without checking the existence of the elements.
 * We can look for a better way for the same thing.
 */
$(document).load(function(){
  SuccessExtranet.init();
  if($('#attendance_attended')){
    $('#attendance_attended').click(show_attendance_details_for_session('attended'));
  }
  if($('#attendance_skipped')){
    $('#attendance_skipped').click(show_attendance_details_for_session('skipped'));
  }
  if($('#attendance_next')){
    $('#attendance_next').click(show_attendance_details_for_session('next'));
  }
  if($('#rating_attended')){
    $('rating_attended').click(show_rating_details_for_session('attended'));
  }
  if($('#rating_skipped')){
    $('#rating_skipped').click(show_rating_details_for_session('skipped'));
  }
  if($('#rating_next')){
    $('#rating_next').click(show_rating_details_for_session('next'));
  }
  if($('#coach_attended')){
    $('#coach_attended').click(show_coach_details_for_session('attended'));
  }
  if($('#coach_skipped')){
    $('#coach_skipped').click(show_coach_details_for_session('skipped'));
  }
  if($('#coach_next')){
    $('#coach_next').click(show_coach_details_for_session('next'));
  }
});

jQuery(document).ready(function(){
  jQuery('input.village_list').change(function(){
          
          jQuery.blockUI();
          var status = (this.checked===true)?'enabled':'disabled';
          var hidden_village = this.value;
          
          jQuery.ajax({
                  url: '/save_village_preferences',
                  type : 'post' ,
                  data: {
                      hidden_village :hidden_village,
                      status: status
                  },
                  success: function() {
                      jQuery.unblockUI();
                  },
                  failure: function(error){
                    jQuery.unblockUI();
                    console.log(error);
                     
                  },
                  error: function(error){
                    jQuery.unblockUI();
                    console.log(error);
                    
                  }              
          });
  });

  jQuery("#village_search_box input#search_id").on("keyup", function() {
    var value = $(this).val();
    jQuery("#village_list_table tr").each(function(index) {
        if (index !== 0) {
            $row = $(this);
            var id = $row.find("td:first").text().toLowerCase();
            if (id.indexOf(value.toLowerCase()) == -1) {
                $row.hide();
            }
            else {
                $row.show();
            }
        }
    });
  });

});