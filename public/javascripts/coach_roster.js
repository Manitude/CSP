jQuery(document).ready(function() {
	jQuery("#coach-roster-tabs").tabs();
	jQuery('#content-header h2').filter(function(index) { return jQuery(this).text() === "Coach Roster"; }).hide();
	jQuery('#content-header h2').filter(function(index) { return jQuery(this).text() === "Edit Management Team"; }).hide();
	if(jQuery('#coach_list_body tr').length === 0){
		jQuery('#coach_list_body').append("<tr row-data='' height='50px'><td colspan='8'>No Coaches To Display</td></tr>");
		jQuery('#export-coach-csv').hide();
	} else if (jQuery('#mgr_list_body tr').length === 0){
		jQuery('#mgr_list_body').append("<tr row-data='' height='50px'><td colspan='7'>No Data To Display</td></tr>");
		jQuery('#export-mgr-csv').hide();
	}
	fixTableHeaders();
	bindMgrListFilterTextBox();
	bindCoachListFilterTextBox();
	handleFilterFormSubmitAction();
	handleImageClickAction();
	bindEditManagementPageEvents();
});

jQuery(window).load(function() {
	jQuery.each(jQuery('.img-link'), function(index, elem){
		img_url = jQuery(elem).attr('img-url');
		jQuery.image(img_url).done(function (image) {
			if(jQuery(elem).attr('img-or') === 'height'){
				if(image.width > image.height)
					jQuery(image).attr('width','100');
				else
					jQuery(image).attr('height','100');
			}
			else
				jQuery(image).attr('width','100');
			jQuery(elem).hide().html(jQuery(image)).fadeIn('slow');
		});
	});
});

var fixTableHeaders = function() {
    jQuery('#mgr_list_table').fixheadertable({
        height: 484,
        colratio: [112, 160, 160, 110, 110, 220, 80]
    });
    jQuery('#coach_list_table').fixheadertable({
        height: 484,
        colratio: [112, 160, 105, 120, 80, 100, 220, 69]
    });
    jQuery('.ui-widget').css('padding', '0px');
};

var bindMgrListFilterTextBox = function() {
	jQuery('#mgr-filter').bind("keyup", function(e) {
		searchVal = jQuery.trim(jQuery('#mgr-filter').val()).toLowerCase();
		if(searchVal === "") {
			jQuery.each(jQuery('#mgr_list_body tr'), function(index, elem) {
				jQuery(elem).show();
			});
		} else {
			jQuery.each(jQuery('#mgr_list_body tr'), function(index, elem) {
				if(~jQuery(elem).attr('row-data').indexOf(searchVal))
					jQuery(elem).show();
				else
					jQuery(elem).hide();
			});
		}
	});
};

var bindCoachListFilterTextBox = function() {
	jQuery('#coach-filter').bind("keyup", function(e) {
		searchVal = jQuery.trim(jQuery('#coach-filter').val()).toLowerCase();
		if(searchVal === "") {
			jQuery.each(jQuery('#coach_list_body tr'), function(index, elem) {
				jQuery(elem).show();
			});
		} else {
			jQuery.each(jQuery('#coach_list_body tr'), function(index, elem) {
				if(~jQuery(elem).attr('row-data').indexOf(searchVal))
					jQuery(elem).show();
				else
					jQuery(elem).hide();
			});
		}
	});
};

var handleFilterFormSubmitAction = function() {
	jQuery('#coach-roster-submit').live('click', function(e){
		e.preventDefault();
		window.location = "/coach-roster/"+jQuery('#coach-roster-form #language').val()+"/"+jQuery('#coach-roster-form #region').val();
		return false;
	});
};

var handleImageClickAction = function(){
	jQuery('.img-link').live('click', function(e){
		jQuery.facebox(jQuery(e.target).parent().html());
		jQuery('#facebox img').removeAttr('width');
		jQuery('#facebox img').removeAttr('height');
		jQuery('#facebox_header').html(jQuery(e.target).closest('td').next().html());
		if(jQuery('#facebox_header').html() === "") {
			jQuery('#facebox_header').html(jQuery(e.target).parent().parent().siblings('.grp1').find('span.name').text());
		}
		return false;
	});
};

jQuery.image = function (src) {
    return jQuery.Deferred(function (task) {
        var image = new Image();
        image.onload = function () { task.resolve(image); };
        image.onerror = function () { task.reject(); };
        image.src = src;
    }).promise();
};

var bindEditManagementPageEvents = function() {
	jQuery('#add-member').live('click', function(){
		jQuery.ajax({
			url : '/management_team_form',
			success : function(){
				jQuery('#facebox_header').html("Add Member to Management Team");
			}
		});
	});
	jQuery('.edit').live('click', function(e){
		jQuery.ajax({
			url : '/management_team_form' + '?member_id=' + jQuery(e.target).attr('member_id'),
			success : function(){
				member_name = jQuery(e.target).parent().siblings('.grp1').find('span.name').text();
				jQuery('#facebox_header').html("Edit Member - "+member_name);
			}
		});
	});	
	jQuery('.delete').live('click', function(e){
		deleteMember(e);
	});	
	jQuery('.hide').live('change', function(e){
		hideMember(e);
	});
};

var validateEntriesAndSave = function() {
	jQuery('#error_div').hide();
	jQuery('#save').attr('disabled', true);
	errors = "";
    errors += validateTextFieldNotBlank('management_team_member_name', "Member Name");
    if(errors !== "") { errors += "<br/>"; }
    errors += validateEmailField('management_team_member_email',"RS Email" );
    
    if(errors !== ""){
        errors = " Following errors were found : <br/>"+errors;
        jQuery('#error_div').html(errors);
    	jQuery('#error_div').show();
    	jQuery('#save').removeAttr('disabled');
    } else {
    	jQuery('#mgmt-team-member-form').ajaxForm({
    		success: function(message){
    			jQuery('#facebox').fadeOut();
    			alert(message);
    			window.location.href = "/edit_management_team";
    		},
    		error: function(data){ 
    			jQuery('#error_div').html(data.responseText);
    			jQuery('#error_div').show();
    			jQuery('#save').removeAttr('disabled');
    		}
    	}).submit();
    }    
    return false;
};

var deleteMember = function(e){
	member_name = jQuery(e.target).parent().siblings('.grp1').find('span.name').text();
	if(confirm("This will remove the details of "+member_name+" completely. Do you want to proceed?")) {
		jQuery.ajax({
			url : '/delete_member' + '?member_id=' + jQuery(e.target).attr('member_id'),
			type : 'POST',
			success : function(message){
				jQuery(e.target).parent().parent().fadeOut('slow', function(){
					jQuery(e.target).parent().parent().remove();
				});					
			},
			error: function(data){
				alert(data.responseText);
			}
		});
	}
};

var hideMember = function(e){
	jQuery.ajax({
		url : '/hide_member' + '?member_id=' + jQuery(e.target).attr('member_id') + '&hide=' + jQuery(e.target).is(':checked'),
		type : 'POST',
		success: function(){			
			if(jQuery(e.target).is(':checked')) {
				jQuery(e.target).parent().parent().addClass('hidden');
			} else {
				jQuery(e.target).parent().parent().removeClass('hidden');
			}
		},
		error: function(data){
			alert(data.responseText);
		}
	});
};

var saveOrderOfMembers = function() {
	new_order = jQuery("#sortable").sortable("toArray");
	jQuery.ajax({
		url : '/save_order_of_members',
		data : {'new_order' : new_order },
		type : 'POST',
		error: function(data){
			alert("Something went wrong. Order could not be saved. Please try again later.");
		}
	});
};

