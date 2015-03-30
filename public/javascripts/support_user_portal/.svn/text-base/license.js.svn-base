jQuery(document).ready(function (){
    jQuery('#update_extension').live('click', function(){
        var license_guid = encodeURIComponent(jQuery(this).attr('license_guid'));
        var language = encodeURIComponent(jQuery(this).attr('language'));
        var license_identifier = encodeURIComponent(jQuery(this).attr('license_identifier'));
        var original_end_date = encodeURIComponent(jQuery(this).attr('original_end_date'));
        var pr_guid = encodeURIComponent(jQuery(this).attr('pr_guid'));
        var version = encodeURIComponent(jQuery(this).attr('version'));
        var group_guid = encodeURIComponent(jQuery(this).attr('group_guid'));
        var url = "/show-extension-form?language=" + language+"&license_guid="+license_guid+"&group_guid="+group_guid+"&license_identifier="+license_identifier+"&original_end_date="+original_end_date+"&pr_guid="+pr_guid+"&version="+version ;
        fixedFacebox(url);
    });
    jQuery('#report_gen').live('click', function(){
      jQuery('#update_prod_report').hide();
     if(validateDates()){
      jQuery('#ajaxLoader').show();
      jQuery('#csv_id').hide();
      var url = jQuery('#report_type').val()+"_report/";
      jQuery.ajax({
                type : 'POST',
                data:{
                    from_date: jQuery('#from_date').val(),
                    to_date: jQuery('#to_date').val(),
                    type: jQuery('#type').val(),
                    form_request: true
                },
                url: url,
                success: function(data) {
                  jQuery('#ajaxLoader').hide();
                  jQuery('#update_prod_report').show();
                  var base_height = jQuery('#prod_report_table').height();
                  if( base_height <= 400){
                      jQuery('.body.ui-widget-content').height(base_height);
                  }
                  jQuery('#update_prod_report').height(jQuery('.body.ui-widget-content').height()+80);
                },
                error: function(error){
                    alert("Something went wrong, please try again later.");
                }
            });
     }
    });
    jQuery('#session_type').live("change",function(){
      var val = jQuery('#session_type').val();
      if(val == '0'){
        var group_expire_date = moment(new Date(jQuery('#group_expire_date').val())).format("L");
        jQuery('#expire-date').html("Expires on "+group_expire_date);
      } else if(val == '1') {
        var solo_expire_date = jQuery('#solo_expire_date').val();
        solo_expire_date = solo_expire_date = (solo_expire_date && (solo_expire_date.length > 4)) ? solo_expire_date : "N/A";
        jQuery('#expire-date').html("Expires on "+solo_expire_date);
      } else {
        jQuery('#expire-date').html("");
      }

    });

    jQuery('#reason').live("change",function(){
      var value = jQuery('#reason').val();
        if(value === 'Other')
          jQuery("#other_reason").show();
        else
          jQuery("#other_reason").hide();
    });

    jQuery('#action_performed').live("change",function(){
      var val = jQuery('#action_performed').val();
        if(val != 'Select')
          jQuery('#number_of_sessions').attr('disabled',false);
        else
          jQuery('#number_of_sessions').attr('disabled',true);
    });
    jQuery('#activate_deactivate').change(function (){
        var elem = jQuery(this);
        var isChecked = elem.is(':checked');
        var no_of_product = jQuery('#no_of_products').val();
        if(no_of_product > 1){
            alert("This license is associated with multiple products, and cannot be placed on hold.");
            elem.attr("checked", !isChecked);
            return;
        }
        var confirmMsg, successMsg;
        if (isChecked) {
            confirmMsg = "You are about to place this license on hold, and the user will not be able to access it. Do you wish to continue?";
            successMsg = "License placed on Hold.";
        } else {
            confirmMsg = "You are about to release the hold on this license, and the customer will be able to access it. Do you wish to continue?";
            successMsg = "License Hold released.";
        }
        jQuery.alerts.okButton = 'Continue';
        jQuery.alerts.cancelButton = 'Cancel';
        jQuery.alerts.confirm(confirmMsg, "Confirm", function (result) {
            if (result) {
                var guid = elem.attr("value");
                elem.attr("disabled", true);
                jQuery.get("/activate_deactivate_license?active=" + isChecked + "&guid=" + guid, function (resposne){
                    if (resposne.isSuccessful){
                        alert(successMsg);
                    }else{
                        alert("There was an error, please try again.");
                        elem.attr("checked", !isChecked);
                    }
                    elem.attr("disabled", false);
                },'json');
            } else {
                elem.attr("checked", !isChecked);
            }
        });
    });
    renderHierarchyTree=function(licenseGuid,familyName){
        url = "/support_user_portal/licenses_hierarchy?license_guid="+licenseGuid+"&family_name="+familyName;
        family = familyName.split("::");
        header = "License Family for "+family[1];
        fixedFaceBoxWithHierarchy(url,header);
    };

    bind_profile_navigation_icon();
    bind_license_navigation_icon();
    bind_close_facebox_event();

});

var bind_close_facebox_event = function() {
    jQuery(document).bind('close.facebox', function(){
        jQuery(".qtip").remove();
    });
};

var bind_profile_navigation_icon = function() {
    jQuery('#profile_navigation_icon').bind('click', function (e) {
        toggleProfileView();
    });
};

var bind_license_navigation_icon = function() {
    jQuery('#license_navigation_icon').bind('click', function (e) {
        toggleLicenseView();
    });
};

var populateLicenseContent = function(){
    if(license_content_div_obj.attr('data_fetched') == "false"){
        license_content_div_obj.load('/view_license_information?license_guid=' + license_guid+"&is_combined_page=true");
        license_content_div_obj.attr('data_fetched', 'true');
    }
};

var populateProfileContent = function(){
    if(profile_content_div_obj.attr('data_fetched') == "false"){
        profile_content_div_obj.load('/learners/' + learner_id + "?is_combined_page=true");
        profile_content_div_obj.attr('data_fetched', 'true');
    }
};

var toggleProfileView = function(){
    if(profile_content_div_obj.attr('data_is_expanded') === 'true') {
        collapseProfile();
    }
    else {
        expandProfile();
    }
    setLicenseAndProfileViewCollapseSetting();
};

var expandProfile = function(){
    populateProfileContent();
    profile_content_div_obj.slideDown('slow');
    jQuery('#profile_navigation_icon').attr('src', '/images/down.png');
    profile_content_div_obj.attr('data_is_expanded', 'true');
};

var collapseProfile = function(){
    profile_content_div_obj.slideUp('slow');
    jQuery('#profile_navigation_icon').attr('src', '/images/next.png');
    profile_content_div_obj.attr('data_is_expanded', 'false');
};

var toggleLicenseView = function(){
    if(license_content_div_obj.attr('data_is_expanded') === 'true'){
        collapseLicense();
    }
    else {
        expandLicense();
    }
    setLicenseAndProfileViewCollapseSetting();
};

var expandLicense = function(){
    populateLicenseContent();
    license_content_div_obj.slideDown('slow');
    jQuery('#license_navigation_icon').attr('src', '/images/down.png');
    license_content_div_obj.attr('data_is_expanded', 'true');
};

var collapseLicense = function(){
    license_content_div_obj.slideUp('slow');
    jQuery('#license_navigation_icon').attr('src', '/images/next.png');
    license_content_div_obj.attr('data_is_expanded', 'false');
};

var setLicenseAndProfileViewCollapseSetting = function(){
    createCookie("coachportal_license_expanded", (license_content_div_obj.attr('data_is_expanded') === 'true')? '1' : '0', 1000 );
    createCookie("coachportal_profile_expanded", (profile_content_div_obj.attr('data_is_expanded') === 'true')? '1' : '0', 1000 );
};

var modifyLanguage = function(path, title, haiving_future_session){
    if(haiving_future_session && !confirm("This customer has one or more sessions scheduled for the currently active language.  Proceeding with this change will cause them to be removed from the session(s). Do you want to proceed?")) return;
    fixedFaceBoxWithHeader(path, title);
};

var validateConsumableFormFields = function() {
    var case_number    = jQuery.trim(jQuery('#case_number').val());
    var type           = (jQuery('#session_type').val() === '-1');
    var reason         = (jQuery('#reason').val() === 'Select' || jQuery('#reason').val() === 'Other');
    var other_reason   = (jQuery.trim(jQuery('#other_reason').val()) === '');
    var msg_text       = "";
    var action         = (jQuery('#action_performed').val() === 'Select');
    var number_of_sessions = jQuery.trim(jQuery('#number_of_sessions').val());

    if(case_number === ""){
      jAlert('Case number cannot be empty.');
      return false;
    } else if (type) {
      jAlert('Please select a consumable type.');
      return false;
    }else if (action) {
      jAlert('Please select an action.');
      return false;
    }else if ( isNaN(jQuery('#number_of_sessions').val()) || number_of_sessions > 100 || number_of_sessions < 1 ) {
      jAlert('Please select a value between 1 to 100 for Number of Sessions.');
      return false;
    }else if (reason && other_reason) {
      jAlert('Reason should not be empty.');
      return false;
    }
    if( (jQuery('#session_type').val() == '1') && (jQuery("#solo_product_right").val().length < 5) ) {
      jQuery.alerts.okButton = 'Yes';
      jQuery.alerts.cancelButton = 'No';
      var msg = 'This Learner does not have active product rights\n for the Session Type you selected. The Product\n Right will automatically be activated if the \nConsumable is added. Do you want to proceed?';
      jConfirm(msg,'', function(result) {
        jQuery.alerts.okButton = 'Ok';
        jQuery.alerts.cancelButton = 'Cancel';
        if(result){
          jQuery("#craccount_type").val(jQuery("#creation_account").val());
          jQuery("#add_multiple_consumables").submit();
        }
        else
          jQuery(document).trigger('close.facebox');
      });
    }
    else
      jQuery("#add_multiple_consumables").submit();
    return true;
};

var uncapLearnerFunction = function(path) {
  jQuery.alerts.okButton = 'Yes';
  jQuery.alerts.cancelButton = 'No';
  var msg = 'This feature is intended for management use only, and is actively monitored for misuse. By proceeding, this customer will be granted unlimited Group Studio sessions.<br/>Do you wish to continue ?';
  jConfirm(msg,'', function(result) {
        jQuery.alerts.okButton = 'Ok';
        jQuery.alerts.cancelButton = 'Cancel';
        if(result){
          fixedFaceBoxWithHeader(path,"Uncap Learner");
        }
        else
          jQuery(document).trigger('close.facebox');
      });
};

var validateUncapFormFields = function() {
  var case_number    = jQuery.trim(jQuery('#case_number').val());
  var reason         = (jQuery('#reason').val() === 'Select');
  if (case_number==="") {
    jAlert('Case number should not be empty.');
    return false;
  }else if (reason) {
    jAlert('Reason should not be empty.');
    return false;
  }
  jQuery.blockUI({ baseZ : 17000} );
  jQuery("#uncap_learner").submit();
  return true;
};

var removeFromSession = function(elem,index) {
    var source = jQuery(elem);
    jQuery.blockUI();
    jQuery.ajax({
        url: source.attr('url'),
        success: function(data){
            alert(data);
            jQuery.unblockUI();
            jQuery('.remove_learner_from_session_'+index).remove();
            window.location.reload();
        },
        failure: function(response){
            console.log(response.responseText);
            jQuery.unblockUI();
            alert(response.responseText);
        },
        error: function(response){
            console.log(response.responseText);
            jQuery.unblockUI();
            alert(response.responseText);
        }
    });
    return false;
};

//Code for the 'Top of page' link. ------------BEGIN------------------------
  //plugin
jQuery.fn.topLink = function(settings) {
  settings = jQuery.extend({
    min: 1,
    fadeSpeed: 200
  }, settings);
  return this.each(function() {
    //listen for scroll
    var el = jQuery(this);
    el.hide(); //in case the user forgot
    jQuery(window).scroll(function() {
      if(jQuery(window).scrollTop() >= settings.min)
      {
        el.fadeIn(settings.fadeSpeed);
      }
      else
      {
        el.fadeOut(settings.fadeSpeed);
      }
    });
  });
};

jQuery(document).ready(function() {
  //set the link
  jQuery('#top-link').topLink({
    min: 400,
    fadeSpeed: 500
  });
  //smoothscroll
  jQuery('#top-link').click(function(e) {
    e.preventDefault();
        jQuery('html,body').animate({
            scrollTop: 0,
            scrollLeft:0
        }, 1000);
  });

});
function validateDates(){
  if(jQuery('#cal_from_date').val() === ""){
    alert("Please select a valid from date");
    return false;
  }
  if(jQuery('#cal_to_date').val() === ""){
    alert("Please select a valid to date");
    return false;
  }
  var from_date = new Date(jQuery('#cal_from_date').val()).getTime();
  var to_date = new Date(jQuery('#cal_to_date').val()).getTime();
  var current_date = new Date().getTime();
  if(to_date < from_date){
    alert("To date should be greater than or equal to from date");
    return false;
  }
  jQuery('#from_date').val(from_date);
  jQuery('#to_date').val(to_date);
  jQuery('#form_request').val(true);
  return true;
}

//Code for the 'Top of page' link. ------------END------------------------
function addConsumables(){
   if(validateFields()){
    add_time = jQuery("#add_time_radio_box_input").is(':checked');
    group_guid = jQuery("#group_guid").val();
    jQuery("#add_time").val(jQuery("#add_time_radio_box_input").is(':checked'));
    jQuery("#add_duration").val(jQuery("#add_time_number").val()+jQuery("#add_time_unit").val());
    jQuery("#remove_duration").val(jQuery("#number_of_cycles").val());
    jQuery("#creation_account").val(jQuery("#creation_account").val());
    jQuery.blockUI({ baseZ : 17000} );
    jQuery("#add_or_remove_extension").submit();
  }
}

function updateReason(obj_id){
    /* Since we are not displaying anywere this. So, I keep the logic simple.*/
    /* Store the data in database and keep it dynamic.*/
    var reasons;
    var disableElements;
    var enableElements;

    jQuery("#other_reason").hide();

    if(obj_id === "add_time_radio_box_input"){
      // first empty the remove projected through
      jQuery("#remove_projected_through").html("");
      //set up variables for reason and enable disable elements
      reasons = ["3 months OLR claimed but not used","My Account not working","Moved OLR to another identifier","OLR expired before claimed-Retailer shelf life","3 months OLR not claimed w/in 6 mos.","Studio Usability Issue- 1 session add only","Grandfathering","Test Session-PS only","Sales set wrong expectations","Service set wrong expectations","Customer Satisfaction- MGMT use only"];
      disableElements = "remove_components";
      enableElements = "add_components";
    }
    else if(jQuery("#expired_license").val() === "true"){
      alert("The license is already expired. The remove operation cannot be performed");
      jQuery("#add_time_radio_box_input").attr("checked","checked");
      return false;
    }
    else{
      //reset the add selection elements
      jQuery("#add_time_unit").val("");
      jQuery("#add_time_number").html("");
      jQuery("#add_projected_through").html("");
      //set up variables for reason and enable disable elements
      reasons = ["Could fix by moving online rights","Error correction","Fraud","Other","Refund"];
      disableElements = "add_components";
      enableElements = "remove_components";
      updateDate();
    }

    //Emptying and disabling the number of days list
    jQuery("#add_time_number").html("");
    jQuery("#add_time_number").attr("disabled",true);

    //populate reasons according to selection and disable/enable the add/remove based on current selection
    var list = $("#reason");
    list.html($("<option />").val("Select").text("Please select one below"));
    $.each(reasons, function() {
        list.append($("<option />").val(this).text(this));
      });
    jQuery("."+disableElements).each(function(){
      jQuery(this).attr("disabled",true);
    });
    jQuery("."+enableElements).each(function(){
      jQuery(this).attr("disabled",false);
    });
    return true;
  }

  function updateList(value){
    var val;
    var elem = jQuery("#add_time_number");
    elem.html("");
    if(value == "d"){
      val = 29;
      jQuery("#group_label").text("Total Group");
    }
    else if(value == "m"){
      val = 36;
      jQuery("#group_label").text("Group per Cycle");
    }
    else{
      elem.attr("disabled",true);
      jQuery("#group_label").text("Group");
      return false;
    }
    elem.attr("disabled",false);
    for (var i = 1; i <= val; i++) {
        elem.append($("<option />").val(i).text(i));
    }
    updateDate();
    return true;
  }

  function updateDate(){
    if(jQuery("#add_time_radio_box_input").is(':checked')){
      jQuery.ajax({
        url: "/support_user_portal/end_date_calculation",
        data: { "original_end_date" : jQuery("#actual_end_date").val(),
          "duration" : jQuery("#add_time_number").val()+jQuery("#add_time_unit").val()
        },
        dataType: 'json',
        success: function(data) {
          jQuery("#add_projected_through").html("New Projected Through : <b>"+data.date+"</b>");
          jQuery.unblockUI();
        }
       });
    }
    else{
      jQuery.blockUI({ baseZ : 17000} );
      jQuery.ajax({
      url: "/support_user_portal/remove_end_date_calculation",
        data: { "original_end_date" : jQuery("#actual_end_date").val(),
          "duration" : jQuery("#number_of_cycles").val(),
          "guid": jQuery("#pr_guid").val()
        },
        dataType: 'json',
        success: function(data) {
          jQuery("#remove_projected_through").html("New Projected Through : <b>"+data.date+"</b>");
          jQuery.unblockUI();
        }
       });
    }

  }

  function validateFields(){
    var response       = true;
    var add_time       = jQuery("#add_time_radio_box_input").is(':checked');
    var remove_rights  = jQuery("#remove_rights_radio_box_input").is(':checked');
    var original_end_date = jQuery("#original_end_date").val();
    var is_group_disabled = jQuery("#group_consumable_count").is(':disabled');
    var group_consumable_count = jQuery("#group_consumable_count").val();
    var solo_consumable_count = jQuery("#solo_consumable_count").val();
    var date_feilds    = [];
    var msg_text       = "";

    /* Validation for Ticket Number start.*/

    var ticket_number  = jQuery("#ticket_number").val();
    if(jQuery.trim(ticket_number) === ""){
      response = false;
      jAlert('Ticket number should not be empty.');
      return response;
    }

    /* Validation for Ticket Number end.*/


  /* Validation for add components start.*/
    var other_reason   = jQuery("#other_reason").val();
    var reason_type    = jQuery("#reason option:selected").val();

    if(add_time && (jQuery("#add_time_unit").val() === "")){
      alert("Please select a unit for adding extension");
      return false;
    }
    if(jQuery("#product_version").val().trim() != "1"){
      if (add_time && !is_group_disabled && (jQuery.trim(group_consumable_count) === "" || group_consumable_count > 99 || group_consumable_count < 0 )){
        alert("Please Enter a valid group consumable count (0-99)");
        return false;
      }
      if(add_time && (jQuery.trim(solo_consumable_count) === "" || solo_consumable_count > 99 || solo_consumable_count < 0 )){
        alert("Please Enter a valid solo consumable count (0-99)");
        return false;
      }
    }

/* Validation for reason start.*/
    if(reason_type == "Select") {
      jAlert('Please select a reason.');
      return false;
    } else if(reason_type == "Other" && (other_reason === "Please enter reason for extension / removal" || jQuery.trim(other_reason) === "")){
      jAlert('Reason should not be empty.');
      return false;
    }

    /* Validation for reason end.*/

    return response;
  }
