var unload_warning = true;
var save_warning   = false;
var edited_locally = false;
var villages_edited = {};
var villages_edited_count = 0;
//var coaches_already_scheduled = {};
/* 1st Popup for Master Scheduler STARTS */

jQuery(document).ready(function(){
    bindExtraSessionCheckBox();
    bindSessionNameLengthValidation();
});

var shift_popup = {};
shift_popup.cell = '';
shift_popup.init = function(){
    jQuery('div.one-hour-cell-for-MS').click(shift_popup.click);
    jQuery('.close-ms-popup').click(shift_popup.close);
};

shift_popup.click = function(){
    if(this.id == "grid_0_2_day-light"){
        this.disabled = true;
    }
    else{
        shift_popup.get(this);
    }
};

shift_popup.get = function(cell) {
    var el = jQuery(cell);
    var utc_time = el.attr('alt');
    var lang_identifier = jQuery('#lang_identifier').val();
    var ext_village_id = jQuery('#ext_village_identifier').val();
    if (lang_identifier == "KLE"){
        ext_village_id = "all";
    }
    var edit_session_ids = "";
    jQuery.each(local_data['edit'], function(index, ele) {
        if(ele['start_time'] === utc_time) {
            edit_session_ids += ele['eschool_session_id'] + ",";
        }
    });
    path = '/get_shift_details/'+lang_identifier+'/'+ext_village_id + '/' + utc_time + '?edit_session_ids=' + edit_session_ids;
    jQuery('#master_schedule, .one-hour-cell-for-MS').addClass('cursor_wait');
    new Ajax.Updater({
        success: 'ms-popup-content'
    }, path,{
        method:'get',
        evalScripts: true,
        onComplete:function(){
            shift_popup.updateActualSessions(el);
            shift_popup.fill_sessions(el,lang_identifier);
            shift_popup.show(cell);
            jQuery('#master_schedule, .one-hour-cell-for-MS').removeClass('cursor_wait');
        }
    });
};

shift_popup.updateActualSessions = function(el){
    for(var i = 0;i < local_data.edit.length; i++){
        if(local_data.edit[i].start_time == el.attr('alt')){
            if (is_lotus === true)
                rebuildActualsRowAfterLotusEdit(local_data.edit[i]);
            else
                rebuildActualsRowAfterEdit(local_data.edit[i]);
        }
    }
    for(i = 0;i < local_data.cancel.length; i++){
        if(local_data.cancel[i].start_time == el.attr('alt')){
            if (is_lotus === true)
                rebuildActualsRow(local_data.cancel[i].coach_session_id,local_data.cancel[i].start_time, local_data.cancel[i].external_village_id, local_data.cancel[i].coach_id);
            else
                rebuildActualsRow(local_data.cancel[i].eschool_session_id,local_data.cancel[i].start_time, local_data.cancel[i].external_village_id, local_data.cancel[i].coach_id);
        }
    }

};

shift_popup.fill_sessions = function(el,lang_identifier){
    var sessions_for_popup = [];
    for(var i = 0;i < local_data.create.length; i++){
        if(local_data.create[i].start_time == el.attr('alt')){
            sessions_for_popup.push(local_data.create[i]);
        }
    }
    try{
        sessions_for_popup.sort(compareSessionByCoachName);
    }catch(e){}
    jQuery.each(sessions_for_popup,function(index, session){
        if (is_lotus === true)
            shift_popup.fill_single_session_for_lotus(session,lang_identifier);
        else
            shift_popup.fill_single_session(session,lang_identifier);
    });
};

function compareSessionByCoachName(a, b) {
    if (a.coach_name.toLowerCase() < b.coach_name.toLowerCase()) {
        return -1;
    }
    if (a.coach_name.toLowerCase() > b.coach_name.toLowerCase()) {
        return 1;
    }
    return 0;
}

shift_popup.fill_single_session = function(s,lang_identifier){//passed lang_identifer all long for edit option
    var html = "<div class='locals_row'>";
    html += "<div class='locals_row_element first' id="+s.coach_id+">"+"<a target='_blank' href='http://coachportal.rosettastone.com/view-coach-profile/"+s.coach_id+"'>"+s.coach_name+"</a></div>";
    if (s.wildcard === 'true')
        html += "<div class='locals_row_element'>Max L"+Math.ceil(s.max_unit/4)+"-U"+(Math.ceil(s.max_unit%4)=== 0?4:Math.ceil(s.max_unit%4));
    else
        html += "<div class='locals_row_element'>L"+s.level+", U"+s.unit;
    if (s.village === '')
        html += "</div>";
    else
        html += " -<br/> "+s.village + "</div>";
    html += "<div class='locals_row_element'>0</div>";
    if(s.recurring)
        html += "<div class='locals_row_element'>Not Active-Recurring</div>";
    else
        html += "<div class='locals_row_element'>Not Active</div>";
    var actualName=s.coach_name;
    var changedName=actualName.replace(/'/g, '#%');
    html += "<div class='locals_row_element'><a onclick='localData.delete(this,"+s.coach_id+");return false;' href='#'>Delete</a> | <a onclick='localData.edit("+s.coach_id+",\""+changedName+"\",\""+s.level+"\",\""+s.unit+"\","+s.number_of_seats+",\""+lang_identifier+"\","+s.recurring+","+s.teacher_confirmed+","+s.max_unit+","+s.external_village_id+",this);return false;' href='#'>Edit</a></div>";
    html += "</div>";
    jQuery('#locals_row_container').append(html);
};

shift_popup.fill_single_session_for_lotus = function(s){//passed lang_identifer all long for edit option
    var html = "<div class='locals_row'>";
    html += "<div class ='locals_row_element first' id="+s.coach_id+"><a target='_blank' href='http://coachportal.rosettastone.com/view-coach-profile/"+s.coach_id+"'>"+s.coach_name+"</a></div>";
    if(s.recurring)
        html += "<div class='locals_row_element'>Not Active-Recurring</div>";
    else
        html += "<div class='locals_row_element'>Not Active</div>";
    html += "<div class='locals_row_element'><a onclick='removeLocalSession(this,"+s.coach_id+");return false;' href='#'>Remove</a>";
    html += "</div>";
    jQuery('#locals_row_container').append(html);
};

shift_popup.show = function(the_cell) {
    shift_popup.close();
    var el = jQuery(the_cell);
    shift_popup.cell = the_cell;
    var pos = el.offset();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#ms-popup-container').height();
    jQuery("#ms-popup-container").css( {
        "left": (pos.left) + "px",
        "top": (pos.top - height + 20) + "px"
    } );
    jQuery("#ms-popup-container").show();
    var target_top  = jQuery("#ms-popup-container").offset().top;
    var target_left = jQuery("#ms-popup-container").offset().left;
    var ms_pop_up_height = jQuery("#ms-popup-container").height();
    var html_page_height = el.offset().top;
    if (ms_pop_up_height > html_page_height){
        jQuery('#header').css('height',(ms_pop_up_height/2)+'px');
    }
    jQuery('html,body').animate({
        scrollTop: target_top - 100,
        scrollLeft: target_left - 20
    }, 1000);
};

shift_popup.close =function(){
    if(shift_popup.cell !== ''){
        closeSessionDetails();
        jQuery('#ms-popup-container').hide();
        jQuery('#header').css('height','1%');
        shift_popup.compareActualsWithHistoricals();
        shift_popup.cell = '';
    }
};

shift_popup.compareActualsWithHistoricals = function(){
    var cell = jQuery(shift_popup.cell);
    var found = false;
    var utc_time = jQuery(shift_popup.cell).attr('alt');
    var local_changes = 0;
    for(var i = 0;!found && i < local_data['create'].length;i++){
        if(local_data['create'][i].start_time === utc_time){
            found = true;
            local_changes ++;
        }
    }
    for(i = 0;!found && i < local_data['cancel'].length;i++){
        if(local_data['cancel'][i].start_time === utc_time){
            found = true;
            local_changes --;
        }
    }
    for(i = 0;!found && i < local_data['edit'].length;i++){
        if(local_data['edit'][i].start_time === utc_time)
            found = true;
    }
    if (found){
        cell.removeClass('pushed_to_eschool');
        cell.addClass('not_pushed_to_eschool');
    }
    var cell_id = shift_popup.cell.id;
    var actuals = jQuery('#'+ cell_id.replace('grid','actual')).text().trim();
    var historical = jQuery("#"+ cell_id.replace('grid','historical')).text();
    cell.removeClass('actuals_less_than_historical');
    if(parseInt(actuals, 10) + local_changes < parseInt(historical, 10))
        cell.addClass('actuals_less_than_historical');
};

/* 1st Popup for Master Scheduler ENDS */
/* local session data manipulation methods */
var localData = {};
localData["delete"] = function(row,coachid){
    var start_time = jQuery(shift_popup.cell).attr('alt');
    var found =false;
    var index = 0;
    for(var i=0;i<local_data.create.length;i++){
        if(local_data.create[i].start_time == start_time && local_data.create[i].coach_id == coachid){
            writeSessionCount(local_data.create[i].recurring);
            var removed_session = local_data.create.splice(i,1)[0];
            deleteCoachIdFromAlreadyScheduledList(removed_session.coach_id,removed_session.start_time,removed_session.coach_availability);
            for(var j = 0;j < local_data['delete'].length;j++){
                if(local_data['delete'][j].coach_id.toString() === removed_session.coach_id && local_data['delete'][j].start_time === start_time){
                    found = true;
                    index = j;
                    break;
                }
            }
            removed_session.changed_now = true;
            if(found)
                local_data['delete'][index] = removed_session;
            else
                local_data['delete'].push(removed_session);

            save_warning   = true;
            enableSaveAsDraftButton();
            jQuery(row).parent().parent().fadeOut('slow');
            jQuery(shift_popup.cell).removeClass('initial_recurring');
            updateSessionCount('delete');
            break;
        }
    }
};
localData["edit"] = function(coachid,coachname,level,unit,no_of_seats,lang_identifier,recurring,teacher_confirmed,max_unit,ext_village_id,ele){
    coachname=coachname.replace(/#%/g, "'");
    save_warning   = true;
    enableSaveAsDraftButton();
    pos=jQuery(ele).offset();
    jQuery('#ms-editlocal-popup-content').empty();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#ms-editlocal-popup-container').height();
    previousposition=jQuery("#ms-editlocal-popup-container").offset();
    var start_time = jQuery(shift_popup.cell).attr('alt');
    jQuery('.close-ms-edit-popup').click(closeSessionDetails);
    jQuery('body').addClass('cursor_wait');
    jQuery('#content, #master_schedule, .one-hour-cell-for-MS').addClass('cursor_wait');
    var local_edit_url ="edit_local_session_ms?lang_identifier="+lang_identifier+"&start_time="+start_time+"&coachid="+coachid+"&coachname="+coachname+"&level="+level+"&unit="+unit+"&no_of_seats="+no_of_seats+"&recurring="+recurring+"&teacher_confirmed="+teacher_confirmed+"&ext_village_id="+ext_village_id;
    jQuery.get(local_edit_url,function(data){
        jQuery("#ms-editlocal-popup-content").html(data);
        jQuery("#ms-editlocal-popup-container").css({
            "position":"absolute",
            "left":pos.left-367+"px",
            "top":(pos.top-height+45)+"px"

        });
        jQuery('body').removeClass('cursor_wait');
        jQuery('#content, #master_schedule, .one-hour-cell-for-MS').removeClass('cursor_wait');
        jQuery("#ms-editlocal-popup-container").show('slow', function() {
            maxlevel(max_unit);
        });
        jQuery('html,body').animate({
            scrollTop: previousposition.top,
            scrollLeft:previousposition.left+100
        }, 1000);
    });
};

/*populating session counts for master scheduler draft*/
function populateCountOnLoadDraft(){
    var localDataCreateLength = local_data['create'].length;
    var localDataCancelLength = local_data['cancel'].length;
    var localDataEditLength = local_data['edit'].length;
    for(var i=0;i<localDataCreateLength;i++){
        var cell =jQuery('#' + id_alt_map[local_data['create'][i].start_time]);
        var localChangesSpan;
        if(local_data['create'][i].recurring===true){
            localChangesSpan = cell.find('span.local_changes');
            updateCellStatus(localChangesSpan, " recurring");
        }
        else{
            localChangesSpan = cell.find('span.local_new_sessions');
            updateCellStatus(localChangesSpan, " new");
        }
    }
    for(var k=0;k<localDataCancelLength;k++){
        cell=jQuery('#' + id_alt_map[local_data['cancel'][k].start_time]);
        localChangesSpan = cell.find('span.local_removed_sessions');
        updateCellStatus(localChangesSpan, " removed");
    }
    for(var j=0;j<localDataEditLength;j++){
        cell=jQuery('#' + id_alt_map[local_data['edit'][j].start_time]);
        cell.removeClass('pushed_to_eschool');
        cell.addClass('not_pushed_to_eschool');
    }
}

function updateCellStatus(localChangesSpan,status){
    var currentSessionCount;
    currentSessionCount = parseInt(localChangesSpan.html().trim(), 10);
    currentSessionCount++;
    localChangesSpan.html(currentSessionCount + status);
    localChangesSpan.removeClass('display_none');
    localChangesSpan.parent().removeClass('display_none');
    localChangesSpan.parent().parent().addClass('not_pushed_to_eschool');
    if(currentSessionCount<=0){
        localChangesSpan.addClass('display_none');
    }
}

/* Function to update session count*/
function updateSessionCount(fromWho){
    var schedule_this_week_remove = parseInt(jQuery('#schedule_this_week_remove').text(),10);
    var schedule_this_week_add =  parseInt(jQuery('#schedule_this_week_add').text(),10);
    var localChangesSpan = jQuery(shift_popup.cell).find('span.local_changes');
    localChangesSpan.removeClass('display_none');
    jQuery(shift_popup.cell).children().removeClass('display_none');
    var currentCellText = localChangesSpan.html().trim();
    var write_now=true;
    var currentSessionCount = currentCellText.length > 0 ? parseInt(currentCellText, 10):0;
    if(currentSessionCount<=0){
        localChangesSpan.addClass('display_none');
    }
    if(fromWho==='delete'){
        if(schedule_this_week_add>0)
        {
            schedule_this_week_add--;
        }
        write_now= false;
    }
    if(fromWho==='cancel'){
        schedule_this_week_remove++;
    }
    if(fromWho==='uncancel'){
        schedule_this_week_remove--;
        write_now= false;
    }
    if(fromWho==='create'){
        currentSessionCount++;
        schedule_this_week_add++;
    }
    if(fromWho==='create_non_recurring'){
        schedule_this_week_add++;
        write_now= false;
    }
    //writing the updated count in the cell
    var session_added_info = "";
    var session_removed_info = "";
    if(currentSessionCount !== 0) {
        if(write_now){
            localChangesSpan.html(currentSessionCount+" recurring");
        }
        session_added_info = schedule_this_week_add + " new ";
        session_removed_info = schedule_this_week_remove + " removed ";
        jQuery('#schedule_this_week_add').text(session_added_info);
        jQuery('#schedule_this_week_remove').text(session_removed_info);
    }else if(currentSessionCount === 0){
        if(write_now){
            localChangesSpan.html("");
        }
        session_added_info = schedule_this_week_add + " new ";
        session_removed_info = schedule_this_week_remove + " removed ";
        jQuery('#schedule_this_week_add').text(session_added_info);
        jQuery('#schedule_this_week_remove').text(session_removed_info);
    }
    if(currentSessionCount>0){
        localChangesSpan.removeClass('display_none');
    }
    if(schedule_this_week_add >0){
        jQuery('#schedule_this_week_add').removeClass("display_none");
    }else{
        jQuery('#schedule_this_week_add').addClass("display_none");
    }
    if(schedule_this_week_remove >0){
        jQuery('#schedule_this_week_remove').removeClass("display_none");
    }else{
        jQuery('#schedule_this_week_remove').addClass("display_none");
    }
}

function writeNewSessionCount(){
    var localChangesSpan = jQuery(shift_popup.cell).find('span.local_new_sessions');
    localChangesSpan.removeClass('display_none');
    var currentSessionCount =parseInt(localChangesSpan.html().trim(), 10);
    currentSessionCount++;
    localChangesSpan.html(currentSessionCount+" new ");
}

/*Function that decides whether 'new' or 'recurring' to be updated and updates*/
function writeSessionCount(recurring){
    var localChangesSpan;
    var currentSessionCount;
    if(!recurring){
        localChangesSpan = jQuery(shift_popup.cell).find('span.local_new_sessions');
        currentSessionCount =parseInt(localChangesSpan.html().trim(), 10);
        currentSessionCount--;
        localChangesSpan.html(currentSessionCount+" new ");
        if(currentSessionCount<=0)
            localChangesSpan.addClass('display_none');
    }
    else{
        localChangesSpan = jQuery(shift_popup.cell).find('span.local_changes');
        currentSessionCount =parseInt(localChangesSpan.html().trim(), 10);
        currentSessionCount--;
        localChangesSpan.html(currentSessionCount+" recurring");
        if(currentSessionCount<=0)
            localChangesSpan.addClass('display_none');
    }
}

function writeRemovedSessionCount(count){
    var localChangesSpan = jQuery(shift_popup.cell).find('span.local_removed_sessions');
    localChangesSpan.removeClass('display_none');
    var currentSessionCount =parseInt(localChangesSpan.html().trim(), 10);
    currentSessionCount+=count;
    localChangesSpan.html(currentSessionCount+" removed ");
    if(currentSessionCount<=0){
        localChangesSpan.addClass('display_none');
    }
}
/*Function that updates session count when an already created session is edited from
 *recurring to non-recurring and vice-versa*/
function rewriteSessionCount(oldval){
    if(oldval){
        changeRecurringSessionCount(-1);
        changeNewSessionCount(1);
    }
    else{
        changeRecurringSessionCount(1);
        changeNewSessionCount(-1);
    }
}

function changeRecurringSessionCount(count){
    var localChangesSpan = jQuery(shift_popup.cell).find('span.local_changes');
    localChangesSpan.removeClass('display_none');
    var currentCellText = localChangesSpan.html().trim();
    var currentSessionCount = currentCellText.length > 0 ? parseInt(currentCellText, 10):0;
    currentSessionCount +=count;
    localChangesSpan.html(currentSessionCount+" recurring");
    if(currentSessionCount<=0){
        localChangesSpan.addClass('display_none');
    }
}

function changeNewSessionCount(count){
    var localChangesSpan = jQuery(shift_popup.cell).find('span.local_new_sessions');
    localChangesSpan.removeClass('display_none');
    var currentSessionCount =parseInt(localChangesSpan.html().trim(), 10);
    currentSessionCount+=count;
    localChangesSpan.html(currentSessionCount+" new ");
    if(currentSessionCount<=0){
        localChangesSpan.addClass('display_none');
    }
}
/* 2nd Popup (create sessions popup) STARTS */
function check_future_conflicting_sessions(fromEdit,is_lotus, lang_id){
    var local_recurring;
    var start_time;
    var path;
    if(is_lotus){
        strcheck='coach_list';
        local_recurring  = jQuery('#recurring').attr('checked');
        if(!local_recurring) {
            createLocalSessions(fromEdit,is_lotus, "false");
        }
        else {
            coaches=document.getElementById(strcheck);
            var selected_coach = 0;
            coach_ids = [];
            for(var i=0; i < (coaches.options.length); i++) {
                if(coaches.options[i].selected){
                    element_id = '#'+coaches.options[i].value;
                    coachId=jQuery(element_id).attr('coach_id');
                    coach_ids.push(coachId);
                    selected_coach =  selected_coach + 1;
                }
            }
            if(selected_coach === 0){
                alert('Please select a coach');
                return;
            }
            start_time      = jQuery(shift_popup.cell).attr('alt');
            path = 'check_future_conflicting_sessions_for_coach_in_start_time';
            jQuery.ajax({
                type: "post",
                async: true,
                data: {
                    coach_id: coach_ids,
                    start_time: start_time,
                    lang_id: lang_id
                },
                url: path,
                success: function(data){
                    createLocalSessions(fromEdit, is_lotus, data);
                }
            });
        }
    }
    else{
        strcheck="#"+jQuery("#coach_list").val();
        local_recurring  = jQuery('#recurring').attr('checked');
        if(!local_recurring) {
            createLocalSessions(fromEdit,is_lotus, "false");
        }
        else {
            var coach_id    = jQuery(strcheck).attr('coach_id');
            start_time      = jQuery(shift_popup.cell).attr('alt');
            if(!jQuery(strcheck).attr('coach_id')){
                alert('Please select a coach');
                return;
            }

            path = 'check_future_conflicting_sessions_for_coach_in_start_time';
            jQuery.ajax({
                type: "post",
                async: true,
                data: {
                    coach_id: coach_id,
                    start_time: start_time,
                    lang_id: lang_id
                },
                url: path,
                success: function(data){
                    createLocalSessions(fromEdit, is_lotus, data);
                }
            });
        }
    }
}

function createLocalSessions(fromEdit,is_lotus, future_conflicting_sessions_available){
    if(future_conflicting_sessions_available == "false") {
        if(is_lotus === true)
            strcheck='coach_list';
        else{
            strcheck="#"+jQuery("#coach_list").val();
            if(!jQuery(strcheck).attr('coach_id')){
                alert('Please select a coach');
                return;
            }
        }

        if(fromEdit){
            save_warning   = true;
            enableSaveAsDraftButton();
            edited_locally=true;
        }
        var start_time = jQuery(shift_popup.cell).attr('alt');
        var local_recurring;
        var recurring  = jQuery('#recurring').attr('checked');
        if(is_lotus === false)
        {

            var coachId         = jQuery(strcheck).attr('coach_id');
            var coachName       = jQuery(strcheck).text().trim();
            var coachUserName   = jQuery(strcheck).attr('user_name').toString();
            var coachMaxUnit    = jQuery(strcheck).attr('max_unit').toString();
            var seats           = jQuery('#number_of_seats').val();
            var teacher_confirmed  = jQuery('#teacher_confirmed').attr('checked');

            var level = jQuery('#level').val();
            var unit = jQuery('#unit').val();
            var village_id = jQuery('#village_id').val();
            village_id = village_id === '' ? null : village_id;
            var village = (village_id === null) ? '' : jQuery("#village_id option:selected").text();
            var wildcard = (level == '--' && unit == '--');
            var illelgalwildcard = ((level == '--' && unit != '--') || (level != '--' && unit == '--') );
            var singleUnit = single_unit_from_level_unit(level,unit);
            var returned_level_values = unit_level_from_max_unit(coachMaxUnit);
            if(!wildcard && illelgalwildcard ){
                alert ('Enter both Level and Unit as wildcard or select values for both');
            }
            else if(wildcard ||coachMaxUnit >=  singleUnit ){
                save_warning   = true;
                local_recurring=jQuery(strcheck).attr('avail_flag').toString();
                if(local_recurring=='false')
                    recurring = false;
                addSessionToJsonObject(coachId, coachName, coachUserName, coachMaxUnit, level, unit, seats, recurring, start_time,village_id,village,local_recurring,teacher_confirmed);
                addCoachIdToAlreadyScheduledList(coachId,start_time,local_recurring);
                jQuery(document).trigger('close.facebox');
                jQuery(shift_popup.cell).removeClass('initial_recurring');
                shift_popup.close();
                span_tag = jQuery(shift_popup.cell).children();
                span_tag.removeClass('display_none');
                enablePushToEschoolButton();
                enableSaveAsDraftButton();
            }
            else
                alert("The Level and Unit Selected  is more than the Maximum Level and  Unit(L"+returned_level_values[0]+"-U"+returned_level_values[1]+") allowed for this coach");
        }
        else
        {

            coaches=document.getElementById(strcheck);
            var selected_coach = 0;
            for(var i=0;i<coaches.options.length;i++)
            {
                if(coaches.options[i].selected){
                    element_id = '#'+coaches.options[i].value;
                    coachId=jQuery(element_id).attr('coach_id');
                    coachName=jQuery(element_id).text().trim();
                    coachUserName=jQuery(element_id).attr('user_name').toString();
                    local_recurring=jQuery(element_id).attr('avail_flag').toString();
                    if(local_recurring=='false')
                        recurring=false;
                    addSessionToJsonObjectforLotus(coachId, coachName, coachUserName,recurring, start_time,local_recurring);
                    addCoachIdToAlreadyScheduledList(coachId,start_time,local_recurring);
                    selected_coach =  selected_coach + 1;
                }
            }
            if(selected_coach === 0){
                alert('Please select a coach');
                return;
            }
            save_warning   = true;
            jQuery(document).trigger('close.facebox');
            jQuery(shift_popup.cell).removeClass('initial_recurring');
            shift_popup.close();
            span_tag = jQuery(shift_popup.cell).children();
            span_tag.removeClass('display_none');
            enablePushToEschoolButton();
            enableSaveAsDraftButton();




        }
    }
    else if(future_conflicting_sessions_available == "Extra Session created successfully."){
        jQuery(shift_popup.cell).addClass('extra_session');
        var current_session_count = parseInt(jQuery(shift_popup.cell).find('span.session_details').first().html(),10);
        jQuery(shift_popup.cell).find('span.session_details').first().html(current_session_count+=1);
        jQuery(shift_popup.cell).find('span').first().removeClass('display_none');
        if(jQuery(shift_popup.cell).find('span.sub_needed_text_in_slot').length === 0)
            jQuery(shift_popup.cell).append('<br/><span class="sub_needed_text_in_slot">SUB NEEDED</span>');
        shift_popup.close();
    }
    else {
        jAlert( future_conflicting_sessions_available );
    }
}

function addCoachIdToAlreadyScheduledList(coachId,start_time,coach_availability){
    if (coach_availability == 'true'){
        var avail_index = coaches_already_scheduled[start_time.toString()]["available_coaches"].indexOf(coachId);
        if(avail_index == -1){// not having an entry already.
            coaches_already_scheduled[start_time.toString()]["available_coaches"].push(coachId);
        }
    }
    else if (coach_availability == 'false') {
        avail_index = coaches_already_scheduled[start_time.toString()]["unavailable_coaches"].indexOf(coachId);
        if(avail_index == -1){// not having an entry already.
            coaches_already_scheduled[start_time.toString()]["unavailable_coaches"].push(coachId);
        }
    }


}

function deleteCoachIdFromAlreadyScheduledList(coachId,start_time,coach_availability){
    if (coach_availability == 'true'){
        var avail_index = coaches_already_scheduled[start_time.toString()]["available_coaches"].indexOf(coachId);
        if(avail_index > -1){// not having an entry already.
            coaches_already_scheduled[start_time.toString()]["available_coaches"].splice(avail_index,1);
        }
    }
    else if (coach_availability == 'false') {
        avail_index = coaches_already_scheduled[start_time.toString()]["unavailable_coaches"].indexOf(coachId);
        if(avail_index > -1){// not having an entry already.
            coaches_already_scheduled[start_time.toString()]["unavailable_coaches"].splice(avail_index,1);
        }
    }


}

function addSessionToJsonObject(coachId, coachName, coachUserName, coachMaxUnit, level, unit, seats, recurring, start_time,village_id,village,local_recurring,teacher_confirmed){
    wildcard = (level == '--' || unit == '--');
    lang_identifier = jQuery('#lang_identifier').val();
    var found = false;
    var index = 0;
    var prev_recurring, cur_recurring;
    for(var i=0; i < local_data['create'].length; i++){
        if(local_data['create'][i].coach_id == coachId && local_data['create'][i].start_time == start_time){
            found = true;
            index = i;
            break;
        }
    }
    if(found){
        prev_recurring=local_data['create'][index].recurring;
        cur_recurring=recurring;
        local_data['create'][index].level = level;
        local_data['create'][index].unit = unit;
        local_data['create'][index].number_of_seats = seats;
        local_data['create'][index].recurring = recurring;
        local_data['create'][index].teacher_confirmed = teacher_confirmed;
        local_data['create'][index].wildcard = wildcard.toString();
        local_data['create'][index].external_village_id = village_id;
        local_data['create'][index].village = village;
        local_data['create'][index].coach_availability = local_recurring;
        local_data['create'][index].from_server = false;
        local_data['create'][index].changed_now = true;

        if(prev_recurring!==cur_recurring){
            rewriteSessionCount(prev_recurring);
        }
    }
    else{
        local_data['create'].push({
            'coach_id': coachId,
            'coach_name': coachName,
            'coach_username' : coachUserName,
            'lang_identifier' : lang_identifier,
            'max_unit' : coachMaxUnit,
            'level': level,
            'unit': unit,
            'duration_in_seconds' : '3600',
            'number_of_seats': seats,
            'recurring': recurring,
            'teacher_confirmed': teacher_confirmed,
            'wildcard': wildcard.toString(),
            'start_time': start_time,
            'external_village_id' : village_id,
            'village' : village,
            'coach_availability' : local_recurring,
            'from_server' : false,
            'changed_now' : true
        });
        if(recurring){
            updateSessionCount('create');
        }
        else{
            writeNewSessionCount();
            updateSessionCount('create_non_recurring');
        }

    }
    enablePushToEschoolButton();
}
////////////////////////////////////////////////////////////////////////////////
//Lotus Function


function addSessionToJsonObjectforLotus(coachId, coachName, coachUserName, recurring, start_time,local_recurring){
    lang_identifier = jQuery('#lang_identifier').val();
    var found = false;
    var index = 0;
    var prev_recurring, cur_recurring;
    for(var i=0; i < local_data['create'].length; i++){
        if(local_data['create'][i].coach_id == coachId && local_data['create'][i].start_time == start_time){
            found = true;
            index = i;
            break;
        }
    }
    if(found){
        prev_recurring=local_data['create'][index].recurring;
        cur_recurring=recurring;
        local_data['create'][index].recurring = recurring;
        local_data['create'][index].coach_availability = local_recurring;
        local_data['create'][index].changed_now = true;

        if(prev_recurring!==cur_recurring){
            rewriteSessionCount(prev_recurring);
        }
    }
    else{
        local_data['create'].push({
            'coach_id': coachId,
            'coach_name': coachName,
            'coach_username' : coachUserName,
            'lang_identifier' : lang_identifier,
            'recurring': recurring,
            'start_time': start_time,
            'coach_availability' : local_recurring,
            'changed_now' : true
        });
        if(recurring){
            updateSessionCount('create');
        }
        else{
            writeNewSessionCount();
            updateSessionCount('create_non_recurring');
        }

    }
    enablePushToEschoolButton();
}




///////////////////////////////////////////////////////////////////////////////////
function unit_level_from_max_unit(coachMaxUnit){
    coachMaxUnit = parseInt(coachMaxUnit,10);
    // level and unit will be both '--' if they are left untouched.
    // this case will be treated as wildcard
    var allowedUnit     = coachMaxUnit > 4 ? (((coachMaxUnit % 4) === 0 ) ? 4 : coachMaxUnit % 4) : coachMaxUnit;
    var allowedLevel    = Math.ceil(parseFloat(coachMaxUnit)/parseFloat(4));
    return [allowedLevel,allowedUnit];
}

function single_unit_from_level_unit(level,unit){
    level     = parseInt(level,10);
    unit      = parseInt(unit,10);
    var singleUnit = ((level-1)*4)+unit;
    return singleUnit;
}

/* 2nd Popup (create sessions popup) ENDS */

/* session Popup for Master Scheduler -View Session details -STARTS */

function viewSessionDetails(cell,eschool_session_id,utc_time) {
    jQuery('#ms-session-popup-content').empty();
    jQuery('.close-ms-session-popup').click(closeSessionDetails);
    path = '/view_session_details/'+eschool_session_id+'/'+utc_time;
    new Ajax.Updater({
        success: 'ms-session-popup-content'
    }, path,{
        method:'get',
        onComplete:function(){
            updateViewIfAlreadyEdited(eschool_session_id);
            showSessionDetails(cell);
        }
    });
}

function showSessionDetails(the_cell) {
    var el = jQuery(the_cell);
    var pos = el.offset();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#ms-session-popup-container').height();
    jQuery("#ms-session-popup-container").css( {
        "left": (pos.left-50) + "px",
        "top": (pos.top - height + 2) + "px"
    } );
    jQuery("#ms-session-popup-container").show();
    var target_top  = jQuery("#ms-session-popup-container").offset().top;
    var target_left = jQuery("#ms-session-popup-container").offset().left;
    jQuery('html,body').animate({
        scrollTop: target_top - 100,
        scrollLeft: target_left - 20
    }, 1000);
}

function closeSessionDetails(){
    jQuery("#ms-create-popup-content").html('');
    jQuery("#ms-session-popup-content").html('');
    jQuery('#ms-edit-popup-content').html('');
    jQuery('#ms-editlocal-popup-content').html('');
    jQuery('#ms-create-popup-container').hide();
    jQuery('#ms-session-popup-container').hide();
    jQuery('#ms-edit-popup-container').hide();
    jQuery('#ms-editlocal-popup-container').hide();
    jQuery('#learner-popup').hide();

}

/* session Popup for Master Scheduler -View Session details -ENDS */

function cancelSession(eschool_session_id,coach_id,start_time,external_village_id ){
    local_data['cancel'].push({
        'eschool_session_id': eschool_session_id,
        'coach_id' : coach_id,
        'start_time':start_time,
        'external_village_id':external_village_id,
        'changed_now':true
    });
    save_warning   = true;
    enableSaveAsDraftButton();
    removeSessionDetailsFromEditData(eschool_session_id);
    rebuildActualsRow(eschool_session_id,start_time, external_village_id,coach_id);
    updateSessionCount('cancel');
    writeRemovedSessionCount(1);
    enablePushToEschoolButton();
}
var sessionStatus={};
function rebuildActualsRow(eschool_session_id,start_time, external_village_id, coach_id){
    window.eschool_session_id=eschool_session_id;
    window.start_time=start_time;
    sessionStatus['i'+eschool_session_id]= jQuery("#actuals_row_status"+eschool_session_id).text();
    jQuery("#actuals_row_status"+eschool_session_id).text('Cancelled');
    start_time_str=jQuery("#actuals_row_link"+eschool_session_id).attr("alt").toString();
    if (is_lotus === true){
        jQuery("#actuals_row_link"+eschool_session_id).html('<a onclick="unRemoveActualSession('+eschool_session_id+',\''+start_time_str+'\''+')" href="#" >UnRemove</a>');
        jQuery("#actuals_row_link2"+eschool_session_id).addClass('display_none');
    }else
        jQuery("#actuals_row_link"+eschool_session_id).html('<a onclick="unCancelSession('+eschool_session_id+',\''+start_time_str+'\',\''+external_village_id+'\',\''+coach_id+'\''+')" href=#>UnCancel</a>');
        jQuery("#"+eschool_session_id).css('background-color','tomato');
}

function unCancelSession(eschool_session_id,start_time, external_village_id, coach_id){
    for(var i=0;i<local_data['cancel'].length;i++){
        if(local_data['cancel'][i].eschool_session_id == eschool_session_id && local_data['cancel'][i].start_time == start_time){
            local_data['cancel'].splice(i,1);
            save_warning   = true;
            enableSaveAsDraftButton();
            break;
        }
    }
    window.eschool_session_id=eschool_session_id;
    window.start_time=start_time;
    start_time_str=jQuery("#actuals_row_link"+eschool_session_id).attr("alt").toString();
    jQuery("#actuals_row_status"+eschool_session_id).text(sessionStatus['i'+eschool_session_id]);
    jQuery("#actuals_row_link"+eschool_session_id).html('<a onclick="cancelSession('+eschool_session_id+',\''+coach_id+'\''+',\''+start_time_str+'\''+',\''+external_village_id+'\''+')" href=#>Cancel</a> | <a href=# onclick=editSessionDetails(window.eschool_session_id,window.start_time,this)>Edit</a>');
    jQuery("#"+eschool_session_id).css('background-color','white');
    updateSessionCount('uncancel');
    writeRemovedSessionCount(-1);
    enablePushToEschoolButton();
}
/* coach_availability list JS */

function get_coach_availability_by_id(selected_coach, selected_language){
    jQuery('#ms-coach-avail-popup').hide();
    if(selected_coach!==''){
        if (!jQuery('#master_schedule').attr('alt')){
            return false;
        }
        var ms_start_date_of_week = jQuery('#master_schedule').attr('alt');
        path = '/get_coach_availability/'+ms_start_date_of_week+'/'+selected_coach+'/'+selected_language;
        jQuery('#content, #master_schedule, .one-hour-cell-for-MS').addClass('cursor_wait');
        new Ajax.Updater({
            success: 'ms-coach-avail-popup'
        }, path,{
            method:'get',
            evalScripts: true,
            onComplete:function(){
                show_coach_availability_popup();
                jQuery('#content, #master_schedule, .one-hour-cell-for-MS').removeClass('cursor_wait');
            }
        });
    }
    return false;
}

function show_coach_availability_popup() {
    var coach_avail_input = '';
    if (jQuery('#coach_avail_input').length){
        coach_avail_input = jQuery('#coach_avail_input');
    } else if (jQuery('#coach_avail_input_lotus').length){
        coach_avail_input = jQuery('#coach_avail_input_lotus');
    }
    var pos = coach_avail_input.offset();
    var container_pos = jQuery('#body-content #content').offset();

    if (jQuery('#coach_avail_input').length || jQuery('#coach_avail_input_lotus').length){
        pos.top = pos.top - container_pos.top + coach_avail_input.height();
        jQuery('#ms-coach-avail-popup').css('right',0);
        jQuery('#ms-coach-avail-popup').css('top',pos.top);
    }
    jQuery('#ms-coach-avail-popup').show();
}

function closeCoachAvailabilityPopup(id){
    jQuery('#'+id).hide();
    if (jQuery('#coach_avail_input').length){
        jQuery('#coach_avail_input option:eq(0)').attr("selected", "selected");
    } else if (jQuery('#coach_avail_input_lotus').length){
        jQuery('#coach_avail_input_lotus option:eq(0)').attr("selected", "selected");
    }
}



function hideCoachAvailabilityPopup() {
    setTimeout(function() {
        jQuery('#ms-coach-avail-popup').hide();
    }, 100);
}

/* coach_availability list JS ends */
function createNewSessions(lang_identifier,ext_village_id,session_start_time){
    jQuery(".button").attr("disabled", "disabled");
    var json_stringified = JSON.stringify(coaches_already_scheduled[session_start_time.toString()]);
    var path = 'create_session_ms/'+lang_identifier+'/'+ext_village_id+'/'+session_start_time;
    jQuery('body').addClass('cursor_wait');
    jQuery('#content, #master_schedule, .one-hour-cell-for-MS').addClass('cursor_wait');
    jQuery.ajax({
        type: "post",
        async: true,
        data: {
            coaches_scheduled: json_stringified
        },
        url: path,
        success: function(data){
            jQuery("#ms-create-popup-content").html(data);
            var leftcreate = jQuery("#ms-popup-container").offset().left-jQuery("#content").offset().left-3;
            var topcreate  = jQuery("#ms-popup-container").offset().top-jQuery("#content").offset().top-3+(jQuery("#ms-popup-container").height()-jQuery("#ms-create-popup-container").height());
            if (topcreate < 0){
                jQuery('#header').css('height', (Math.abs(topcreate) + 10 +'px'));                
                jQuery('html,body').animate({
                    scrollTop: topcreate - 100,
                    scrollLeft: leftcreate - 20
                }, 1000);

            }
            jQuery("#ms-create-popup-container").css({
                left:leftcreate+"px",
                top: topcreate+"px"
            });
            jQuery('body').removeClass('cursor_wait');
            jQuery('#content, #master_schedule, .one-hour-cell-for-MS').removeClass('cursor_wait');
            jQuery("#ms-create-popup-container").show();
            jQuery("#ms-popup-container").hide();
        }

    });
    jQuery(".close-ms-create-popup").click(function(){
        jQuery("#ms-popup-container").show();
        jQuery("#ms-create-popup-container").hide();
        var topcreate  = jQuery("#ms-popup-container").offset().top-jQuery("#content").offset().top-3+(jQuery("#ms-popup-container").height()-jQuery("#ms-create-popup-container").height());
        if (topcreate < 0){
            jQuery('#header').css('height', (Math.abs(topcreate) + 10 +'px'));
        }
        else
        {
            jQuery('#header').css('height','1%');
        }
        jQuery(".button").removeAttr("disabled");
    });

}
/* edit session Popup for Master Scheduler - STARTS */

function editSessionDetails(eschool_session_id,utc_time,ele) {
    pos=jQuery(ele).offset();
    jQuery('#ms-edit-popup-content').empty();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#ms-edit-popup-container').height();
    previousposition=jQuery("#ms-edit-popup-container").offset();
    jQuery('body').addClass('cursor_wait');
    jQuery('#content, #master_schedule, .one-hour-cell-for-MS').addClass('cursor_wait');
    closeSessionDetails();
    jQuery('.close-ms-edit-popup').click(closeSessionDetails);
    for(var i = 0;i < local_data['edit'].length;i++){ // this is included to prevent the removing of the coach name from 2nd po up for the same session's edit'
        if(local_data['edit'][i].eschool_session_id === eschool_session_id){
            if (local_data['edit'][i].coach_availability == "false" && coaches_already_scheduled[utc_time]["unavailable_coaches"].indexOf(local_data['edit'][i].coach_id) !=-1){
                coaches_already_scheduled[utc_time]["unavailable_coaches"].splice(coaches_already_scheduled[utc_time]["unavailable_coaches"].indexOf(local_data['edit'][i].coach_id),1);
            }
            else if (local_data['edit'][i].coach_availability == "true" && coaches_already_scheduled[utc_time]["available_coaches"].indexOf(local_data['edit'][i].coach_id) !=-1)
                coaches_already_scheduled[utc_time]["available_coaches"].splice(coaches_already_scheduled[utc_time]["available_coaches"].indexOf(local_data['edit'][i].coach_id),1);
            break;
        }
    }
    var json_stringified = JSON.stringify(coaches_already_scheduled[utc_time]);
    var ext_village_id = jQuery('ext_village_identifier').val();
    path = '/edit_session_details/'+eschool_session_id+'/'+ext_village_id+'/'+utc_time+'/'+json_stringified;
    jQuery.get(path,function(data){
        jQuery("#ms-edit-popup-content").html(data);
        jQuery("#ms-edit-popup-container").css({
            "position":"absolute",
            "left":pos.left-362+"px",
            "top":pos.top-height+48+"px"

        });
        jQuery('body').removeClass('cursor_wait');
        jQuery('#content, #master_schedule, .one-hour-cell-for-MS').removeClass('cursor_wait');
        jQuery("#ms-edit-popup-container").show('slow', function() {
            updateSessionIfAlreadyEdited(eschool_session_id);
        });
        jQuery('html,body').animate({
            scrollTop: previousposition.top,
            scrollLeft:previousposition.left+100
        }, 1000);
    });

}


function saveSessionChanges(eschool_session_id,start_time){
    strcheck="#"+jQuery("#coach_select_dropdown").val();
    var level           = jQuery('#level').val();
    var unit            = jQuery('#unit').val();
    var wildcard        = jQuery('#wildcard').is(':checked') || (level == '--' && unit == '--');
    var coach_full_name = jQuery(strcheck).text().trim();
    var recurring = jQuery('#recurring').is(':checked');
    var teacher_confirmed = jQuery('#teacher_confirmed').is(':checked');
    var previously_recurring = jQuery('#previously_recurring').val();
    if (coach_full_name == '-need a substitute-')
        coach_full_name = '---';
    //user_name is used as value instead of coach_id -since the eschool session object has only user_name
    var coach_user_name = jQuery(strcheck).attr('user_name').toString();
    var coach_id = jQuery(strcheck).attr('coach_id').toString();
    var coach_availability = jQuery(strcheck).attr('avail_flag').toString();
    var max_unit        = jQuery(strcheck).attr('max_unit').toString();
    var seats           = jQuery('#seats').val();
    var lang_identifier = jQuery('#lang_identifier').val();
    var external_village_id = jQuery('#external_village_id_in_edit').val();
    var external_village_id_actual = jQuery('#external_village_id_actual').val();
    var edited_session  = {
        'eschool_session_id': eschool_session_id,
        'start_time':start_time,
        'coach_username': coach_user_name,
        'coach_name': coach_full_name,
        'coach_id' : coach_id,
        'level': level,
        'unit': unit,
        'max_unit':max_unit,
        'number_of_seats': seats,
        'wildcard': wildcard.toString(),
        'lang_identifier': lang_identifier,
        'coach_availability':coach_availability,
        'external_village_id':external_village_id,
        'village_name': villages[external_village_id],
        'recurring' : recurring,
        'teacher_confirmed' : teacher_confirmed.toString(),
        'previously_recurring' : previously_recurring,
        'changed_now': true
    };
    var illelgalwildcard = ((level == '--' && unit != '--') || (level != '--' && unit == '--') );
    var singleUnit = single_unit_from_level_unit(level,unit);
    var returned_level_values = unit_level_from_max_unit(max_unit);
    if (external_village_id_actual != external_village_id && villages_edited[start_time][eschool_session_id] == 'false'){
        villages_edited_count = villages_edited_count + 1;
        villages_edited[start_time][eschool_session_id] = 'true';
    }
    else if (external_village_id_actual === external_village_id && villages_edited[start_time][eschool_session_id] == 'true'){
        villages_edited_count = villages_edited_count - 1;
        villages_edited[start_time][eschool_session_id] = 'false';
    }
    if(!wildcard && illelgalwildcard ){
        alert ('Enter both Level and Unit as wildcard or select values for both');
    }
    else if(wildcard ||max_unit >=  singleUnit ){
        addSessionToEditList(edited_session);
        if(coach_id != "0"){// "0" corresponds to 'needs a substitute'
            addCoachIdToAlreadyScheduledList(edited_session.coach_id,start_time,edited_session.coach_availability);
        }
        rebuildActualsRowAfterEdit(edited_session);
        jQuery(shift_popup.cell).removeClass('initial_recurring');
        jQuery("#ms-edit-popup-container").hide();
        enablePushToEschoolButton();
    }
    else
        alert("The Level and Unit Selected  is more than the Maximum Level and  Unit(L"+returned_level_values[0]+"-U"+returned_level_values[1]+") allowed for this coach");

}

function saveLotusSessionChanges(coach_session_id,start_time,from){
    var strcheck="#"+jQuery("#coach_list").val();
    var str = "#link" + coach_session_id;
    var link_label = jQuery(str).text();
    var coach_full_name ;
    var coach_user_name ;
    var coach_id ;
    var coach_availability ;
    var recurring ;
    var change_to;
    var previously_recurring;
    if (from == 'edit_page')
    {
        coach_full_name = jQuery(strcheck).text().trim();
        coach_user_name = jQuery(strcheck).attr('user_name').toString();
        coach_id = jQuery(strcheck).attr('coach_id').toString();
        coach_availability =jQuery(strcheck).attr('avail_flag').toString();
        recurring = jQuery('#recurring').is(':checked');

    }
    else if (from == 'shift_page')
    {
        if(link_label == 'Make Recurring')
        {
            previously_recurring = false;
            recurring = true;
            change_to = 'Remove Recurrence' ;
        }
        else if(link_label == 'Remove Recurrence')
        {
            previously_recurring = true;
            recurring = false;
            change_to = 'Make Recurring' ;

        }
    }
    if (coach_full_name == '-need a substitute-')
        coach_full_name = '---';
    var edited_session  = {
        'coach_session_id': coach_session_id,
        'start_time': start_time,
        'coach_username': coach_user_name,
        'coach_name': coach_full_name,
        'coach_id' : coach_id,
        'coach_availability' : coach_availability,
        'recurring'  : recurring,
        'previously_recurring' : previously_recurring,
        'from'       :from,
        'link_label' : link_label,
        'change_to'  : change_to,
        'changed_now': true
    };
    var found = false;
    for(var i = 0;i < local_data['edit'].length;i++)
    {
        if(parseInt(local_data['edit'][i].coach_session_id,10) === parseInt(edited_session['coach_session_id'],10))
        {
            found = true;
            break;
        }
    }
    if(found === false)
    {
        addSessionToEditLotus(edited_session);
        rebuildActualsRowAfterLotusEdit(edited_session,from);
    }
    else
    {
        removeSessionDetailsFromEditData(edited_session['coach_session_id']);
        rebuildActualsRowAfterLotusEditBackToOriginal(edited_session);

    }
    if(coach_id != "0"){// "0" corresponds to 'needs a substitute'
        addCoachIdToAlreadyScheduledList(edited_session.coach_id,start_time,edited_session.coach_availability);
    }
    jQuery(shift_popup.cell).removeClass('initial_recurring');
    jQuery(document).trigger('close.facebox');
}

function maxlevel(coachMaxUnit){
    var allowed_level_unit = unit_level_from_max_unit(coachMaxUnit);
    jQuery('#max_qual_of_the_coach').text("Max Level:"+allowed_level_unit[0]+" Unit:"+allowed_level_unit[1]);
    jQuery('#max_unit').text("Max Level:"+allowed_level_unit[0]+" Unit:"+allowed_level_unit[1]);
}

function addSessionToEditList(edited_session){
    var found = false;
    var index = 0;
    for(var i = 0;i < local_data['edit'].length;i++){
        if(local_data['edit'][i].eschool_session_id === edited_session['eschool_session_id']){
            found = true;
            index = i;
            break;
        }
    }
    if(found){
        local_data['edit'][index] = edited_session;
        save_warning   = true;
    }
    else {
        local_data['edit'].push(edited_session);
        save_warning   = true;
    }
    enableSaveAsDraftButton();
    enablePushToEschoolButton();

}

function addSessionToEditLotus(edited_session){
    local_data['edit'].push(edited_session);
    save_warning   = true;
    enableSaveAsDraftButton();
    enablePushToEschoolButton();

}

function removeSessionDetailsFromEditData(session_id){
    var i = 0;
    if (is_lotus === false){
        for(i = 0;i < local_data['edit'].length;i++){
            if(local_data['edit'][i].eschool_session_id === session_id){
                local_data['edit'].splice(i,1);
                break;
            }
        }
    }else{
        for(i = 0;i < local_data['edit'].length;i++){
            if(parseInt(local_data['edit'][i].coach_session_id,10) === parseInt(session_id,10)){
                local_data['edit'].splice(i,1);
                break;
            }
        }
    }
}

function deleteCoachNameIfAlreadyCreated(){

    var no_of_local_rows = jQuery('.locals_row').length;
    var no_of_actual_rows = jQuery('.actuals_row_element.first').length;
    var no_of_coaches = jQuery('.each_coach_in_list').length;
    var no_of_coaches_unavailable = jQuery('.each_coach_in_list3').length;
    var no_of_coaches_for_actual_edit = jQuery('.each_coach_in_list2').length;
    for(var i = 0; i<no_of_actual_rows;i++){
        var actual_coach_name = jQuery('#'+jQuery('.actuals_row_element.first')[i].id).text().trim();
        for(var j = 0; j < no_of_coaches_for_actual_edit;j++){
            if(jQuery('.each_coach_in_list2')[j] && jQuery('.each_coach_in_list2')[j].id != "0"){
                var coach_in_list = jQuery('#label_checkbox-'+jQuery('.each_coach_in_list2')[j].id).text().trim();
            }
            if(jQuery('.each_coach_in_list2  .radio_checked')[0].innerHTML.trim()!=coach_in_list && coach_in_list === actual_coach_name){
                jQuery('.each_coach_in_list2')[j].remove();
                break;
            }
        }
    }

    for( i=0;i<no_of_local_rows;i++){
        var coach_id = jQuery('.locals_row_element.first')[i].id;
        jQuery('#list-'+coach_id).remove();
    }

    if((no_of_coaches === 0)&&(no_of_coaches_unavailable === 0)){
        jQuery("#bottom_part_of_facebox").text("There are no more coaches available at this timeslot");
    }
    if(no_of_coaches_unavailable === 0){
        jQuery("#li_unavailable_list").hide();
    }

}

function rebuildActualsRowAfterEdit(edited_session){
    jQuery("#actuals_row_status"+edited_session['eschool_session_id']).text('Edited');
    jQuery("#"+edited_session['eschool_session_id']).css('background-color','lightblue');
    jQuery("#actuals_row_coach_name"+edited_session['eschool_session_id']).text(edited_session['coach_name']);
    var level_unit_str = '';
    if (edited_session['wildcard'] === 'true'){
        level_unit_str = "Max L"+Math.ceil(edited_session['max_unit']/ 4) + "-U"+ (Math.ceil((edited_session['max_unit']%4))=== 0?4:Math.ceil((edited_session['max_unit']%4)));
    }
    else
        level_unit_str = 'L'+edited_session['level']+' U'+edited_session['unit'];
    jQuery("#actuals_row_level_unit"+edited_session['eschool_session_id']).text(level_unit_str);
    jQuery("#actuals_row_village_name"+edited_session['eschool_session_id']).html(' -<br/> '+edited_session['village_name']);
}

function rebuildActualsRowAfterLotusEdit(edited_session){
    if(edited_session['from'] == 'shift_page')
    {
        jQuery("#"+edited_session['coach_session_id']).css('background-color','lightblue');
        jQuery("#actuals_row_link3"+edited_session['coach_session_id']).html('<a onclick="saveLotusSessionChanges('+edited_session['coach_session_id']+',\''+edited_session['start_time']+'\''+',\'shift_page\')" id = link'+edited_session['coach_session_id']+' href="#" >' + edited_session['change_to'] + '</a>');
    }
    else if(edited_session['from'] == 'edit_page')
    {
        jQuery("#actuals_row_status"+edited_session['coach_session_id']).text('Assigned Substitute');
        jQuery("#"+edited_session['coach_session_id']).css('background-color','lightblue');
        jQuery("#actuals_row_coach_name"+edited_session['coach_session_id']).text(edited_session['coach_name']);
        jQuery("#actuals_row_link2"+edited_session['coach_session_id']).addClass('display_none');
    }
}

function rebuildActualsRowAfterLotusEditBackToOriginal(edited_session){

        jQuery("#"+edited_session['coach_session_id']).css('background-color','white');
}


function updateViewIfAlreadyEdited(eschool_session_id){
    var found = false;
    var edited_session = {};
    for(var i = 0;i < local_data['edit'].length;i++){
        if(local_data['edit'][i].eschool_session_id === eschool_session_id){
            found = true;
            edited_session = local_data['edit'][i];
            break;
        }
    }
    if(found){
        var level_unit_str = '';
        if (edited_session['wildcard'] === 'true')
            level_unit_str = "Level 1-"+Math.ceil(edited_session['max_unit']/ 4) + ",Unit 1-"+ edited_session['max_unit'];
        else
            level_unit_str = 'Level '+edited_session['level']+',Unit '+edited_session['unit'];
        jQuery(".top_left_element").text(level_unit_str);
        jQuery("#coach_full_name").text(edited_session['coach_name']);
        jQuery('#external_village_id_in_edit').val(edited_session['external_village_id']);//assuming, if no coach,the edited_session['coach_name'] contains "---"
    }

}

//This method is written with assumed UI, may need changes when the edit sessions UI is complete
function updateSessionIfAlreadyEdited(eschool_session_id){
    var found = false;
    var edited_session = {};
    strcheck="#"+jQuery("#coach_select_dropdown").val();
    for(var i = 0;i < local_data['edit'].length;i++){
        if(local_data['edit'][i].eschool_session_id === eschool_session_id){
            found = true;
            edited_session = local_data['edit'][i];
            break;
        }
    }
    var maxunit = jQuery(strcheck).attr('max_unit').toString();
    if(found){
        save_warning   = true;
        enableSaveAsDraftButton();
        jQuery('#level').val(edited_session['level']);
        jQuery('#unit').val(edited_session['unit']);
        jQuery('#seats').val(edited_session['number_of_seats']);
        if( edited_session['recurring'] === false)
        {
            jQuery("#recurring").attr('checked',false);
        }
        else
        {
            jQuery("#recurring").attr('checked',true);
        }
        if( edited_session['wildcard'] === "false"){
            jQuery("#wildcard").attr('checked',false);
            jQuery('#level').attr('disabled',false);
            jQuery('#unit').attr('disabled',false);
        }
        jQuery('#external_village_id_in_edit').val(edited_session['external_village_id']);
        jQuery("#coach_list2 :input" ).removeAttr('Checked');
        jQuery("#checkbox-"+edited_session['coach_username']).attr('Checked','Checked');//assuming, if no coach,the edited_session['coach_name'] contains "---"
        jQuery("#label_checkbox-"+edited_session['coach_username']).removeClass('radio_unchecked').addClass('radio_checked');
        maxunit = jQuery(strcheck).attr('max_unit').toString();
    }
    maxlevel(maxunit);

}
/* Edit session Popup for Master Scheduler - ENDS */

function enablePushToEschoolButton(){
    if(jQuery("#ext_village_id option:selected").val() === "all")
        jQuery('#submit').removeAttr('disabled'); // submit = eschool submit button
    if(jQuery('#submit').attr("value") === "PUSH NO SESSIONS")
        jQuery('#submit').attr("value", "PUSH TO ESCHOOL");
}

function disablePushToEschoolButton(){
    jQuery('#submit').attr('disabled', 'disabled'); // submit = eschool submit button
}

function enableSaveAsDraftButton(){
    jQuery('#draft').removeAttr('disabled');
}
function getScheduleChange(isfirsttimeload){
    if(isfirsttimeload == '1')
        jQuery('#get_schedule_button').css('color','red');
}

function showUnloadWarning(){
    if(unload_warning){
        for(var i = (local_data.create.length - 1);i >= 0;i--){
            if(local_data.create[i].from_server === undefined){
                break;
            }
        }
        if( (i === -1) && (create_from_server_count === local_data.create.length) && (local_data.edit.length + local_data.cancel.length) === 0 && (!edited_locally)) {
            unload_warning = false;
        }
    }
    return unload_warning;
}
/*LOTUS languages related functions*/
function removeActualSession(eschool_session_id,start_time){
    local_data['cancel'].push({
        'coach_session_id': eschool_session_id,
        'start_time':start_time,
        'external_village_id':'none',
        'changed_now': true
    });
    save_warning   = true;
    enableSaveAsDraftButton();
    removeSessionDetailsFromEditData(eschool_session_id);
    rebuildActualsRow(eschool_session_id,start_time, 'none','');
    updateSessionCount('cancel');
    writeRemovedSessionCount(1);
    enablePushToEschoolButton();
}

function removeLocalSession(row,coachid){//lotus lang method
    var start_time = jQuery(shift_popup.cell).attr('alt');
    var found =false;
    var index = 0;
    for(var i=0;i<local_data.create.length;i++){
        if(local_data.create[i].start_time == start_time && local_data.create[i].coach_id == coachid){
            writeSessionCount(local_data.create[i].recurring);
            var removed_session = local_data.create.splice(i,1)[0];
            deleteCoachIdFromAlreadyScheduledList(removed_session.coach_id,removed_session.start_time,removed_session.coach_availability);
            for(var j = 0;j < local_data['delete'].length;j++){
                if(local_data['delete'][j].coach_id.toString() === removed_session.coach_id && local_data['delete'][j].start_time === start_time){
                    found = true;
                    index = j;
                    break;
                }
            }
            removed_session.changed_now = true;
            if(found)
                local_data['delete'][index] = removed_session;
            else
                local_data['delete'].push(removed_session);

            save_warning   = true;
            enableSaveAsDraftButton();
            jQuery(row).parent().parent().fadeOut('slow');
            //updateSessionCount('delete');
            break;
        }
    }
}

function unRemoveActualSession(coach_session_id,start_time){
    for(var i=0;i<local_data['cancel'].length;i++){
        if(local_data['cancel'][i].coach_session_id == coach_session_id ){
            local_data['cancel'].splice(i,1);
            save_warning   = true;
            enableSaveAsDraftButton();
            break;
        }
    }
    window.eschool_session_id = coach_session_id;
    window.start_time = start_time;
    jQuery("#actuals_row_status"+coach_session_id).text(sessionStatus['i'+coach_session_id]);
    start_time_str=jQuery("#actuals_row_link"+coach_session_id).attr("alt").toString();
    jQuery("#actuals_row_link"+coach_session_id).html('<a onclick="removeActualSession('+coach_session_id+',\''+start_time_str+'\''+')" href="#">Remove</a>');
    jQuery("#actuals_row_link2"+coach_session_id).removeClass('display_none');
    jQuery("#"+coach_session_id).css('background-color','white');
    //updateSessionCount('uncancel');
    writeRemovedSessionCount(-1);
    enablePushToEschoolButton();
}
/*LOTUS languages related functions - ends*/

/* Save draft in master sheduler is using this function for updating html in master scheduler page.
 * We call this function only when draft saved successfully */
function updateHtml(){
    document.getElementById('draft').disabled = true;
    var warningMessage = document.getElementById('warning-message-id');
    if (warningMessage) {
        warningMessage.parentNode.removeChild(warningMessage);
    }
}

function seatValidation(learners)
{
    var number_of_seats = jQuery("#seats").val();
    var initial_seats = jQuery("#initial_seats").val();
    if (learners > 0)
    {
        if (learners > number_of_seats)
        {
            alert("You cannot select seats lesser than the learners currently signed up for this session.");
            jQuery("#seats").val(initial_seats);
        }
    }
}

function confirmPushToEschool(alertMessage) {
    if(!confirm(alertMessage)) {
        jQuery.unblockUI();
        return false;
    }
    sendTheJson();
    return true;
}

function showOutOfSequenceMessage(lang_id, last_pushed_week, selected_week) {
    jQuery('#submit').attr('disabled','disabled');
    jQuery('#progress_bar').show();
    jQuery.ajax({
        type : 'GET',
        url: '/check_for_sessions_and_drafts_for_non_pushed_weeks?lang_id='+lang_id+'&last_pushed_week='+last_pushed_week+'&selected_week='+selected_week,
        success: function(message){
            jQuery('#submit').removeAttr('disabled');
            jQuery('#progress_bar').hide();
            jQuery.unblockUI();
            alert(message);
        },
        failure: function(error){
            jQuery('#submit').removeAttr('disabled');
            jQuery('#progress_bar').hide();
            jQuery.unblockUI();
            alert('Something went wrong, Please report this problem');
        },
        error: function(error){
            console.log(error);
            jQuery('#submit').removeAttr('disabled');
            jQuery('#progress_bar').hide();
            jQuery.unblockUI();
            alert('Something went wrong, Please report this problem');
        }
    });
    return false;
}

var bindExtraSessionCheckBox = function() {
    jQuery('#extra_session_chk').live('change', function (e) {
        e.preventDefault();
        if(jQuery('#extra_session_chk').val() === "Extra Session") {
            jQuery('#select_drop_dwon').fadeOut('fast', function(){});
            jQuery('#recurring_container').fadeOut('fast', function(){
                jQuery('#session_name_container').fadeIn('fast', function(){});
                jQuery('#coach_list').attr("disabled", true);
                jQuery('#excluded_coaches_list_div').fadeIn('fast', function(){});
                jQuery('#extra_session_container').animate( { 'margin-top' : '-91px' } ,'fast',function(){});
                jQuery('#note').fadeOut('fast', function(){});
            });
        }
        else{
            jQuery('#session_name_container').fadeOut('fast', function(){
                jQuery('#recurring_container').fadeIn('fast', function(){});
                jQuery('#select_drop_dwon').fadeIn('fast', function(){});
                jQuery('#excluded_coaches_list_div').fadeOut('fast', function(){});
                jQuery('#coach_list').attr("disabled", false);
                jQuery('#extra_session_container').animate( { 'margin-top' : '-43px' } ,'fast',function(){});
                jQuery('#note').fadeIn('fast', function(){});
            });

        }
    });

};

var createCoachSessionFromMS = function(fromEdit,is_lotus, lang_id){
    if(jQuery('#extra_session_chk').val() == 'Extra Session'){
        jQuery.blockUI({
            message : '<img src = "/images/big_spinner.gif">',
            css: {
                border: "none",
                background: "none"
            }
        });
        createExtraSessionTotale(fromEdit,is_lotus, lang_id);
    }
    else {
        check_future_conflicting_sessions(fromEdit,is_lotus, lang_id);
    }
    
};

var createExtraSessionTotale = function(fromEdit,is_lotus, lang_id){
    var path;
    var start_time      = jQuery(shift_popup.cell).attr('alt');
    var seats           = jQuery('#number_of_seats').val();
    var level           = jQuery('#level').val();
    var unit            = jQuery('#unit').val();
    var session_name    = jQuery('#session_name_txt').val();
    var wildcard        = (level == '--' && unit == '--');
    var village_id      = jQuery('#village_id').val();
    var coach_ids       = collectSelectedCoachIds();
    var illelgalwildcard = ((level == '--' && unit != '--') || (level != '--' && unit == '--') );
    if(!wildcard && illelgalwildcard ){
        alert ('Enter both Level and Unit as wildcard or select values for both');
    }else {
        jQuery('input.button_shape').attr("disabled", "disabled");
        path = 'create_extra_session';
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                start_time: start_time,
                lang_id: lang_id,
                number_of_seats: seats,
                level: level,
                unit: unit,
                name: session_name,
                wildcard: wildcard,
                village_id: village_id,
                excluded_coaches: coach_ids.join()
            },
            url: path,
            success: function(data){
                jQuery('input.button_shape').attr("disabled", "");
                alert(data);
                createLocalSessions(fromEdit, is_lotus, data);
            },
            complete: function() {
                jQuery.unblockUI();
            }
        });
    }
};
var cancelExtraSession = function(eschool_session_id, cancel_link){
    if(confirm('Are you sure want to cancel this extra session?')){
        jQuery.blockUI({
            message : '<img src = "/images/big_spinner.gif">',
            css: {
                border: "none",
                background: "none"
            }
        });
    var path = 'cancel-session';
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                session_id: eschool_session_id
            },
            url: path,
            success: function(data){
                jQuery(cancel_link).parent().prev().text('Cancelled');
                var current_session_count = parseInt(jQuery(shift_popup.cell).find('span.session_details').first().html(),10);
                current_session_count--;
                var noOfValidExtraSessions = 0;
                jQuery('div[data_isExtraSession=true]').each(function(){
                    if(jQuery(this).parent().find('div.actuals_row_element:contains("Substitute required")').length > 0){
                        noOfValidExtraSessions = noOfValidExtraSessions + 1;
                    }
                });
                if(noOfValidExtraSessions === 0){
                    jQuery(shift_popup.cell).removeClass('extra_session');
                }
                if(jQuery('div.actuals_row_element:contains("Substitute required")').length === 0){
                    jQuery(shift_popup.cell).find('span.sub_needed_text_in_slot').prev().remove();
                    jQuery(shift_popup.cell).find('span.sub_needed_text_in_slot').remove();
                    if(jQuery('div.actuals_row_element:contains("Active")').length === 0) {
                        jQuery(shift_popup.cell).removeClass('pushed_to_eschool');
                    }
                }
                if(current_session_count === 0 && jQuery('div.locals_row').length === 0){
                    jQuery(shift_popup.cell).find('span').first().addClass('display_none');
                }
                jQuery(shift_popup.cell).find('span.session_details').first().html(current_session_count);
                shift_popup.close();
                alert('Session cancelled successfully.');
            },
            complete: function() {
                jQuery.unblockUI();
            }
        });
    }
};
var cancelExtraSessionReflex = function(coach_session_id, cancel_link){
    if(confirm('Are you sure want to cancel this extra session?')){
        jQuery.blockUI({
            message : '<img src = "/images/big_spinner.gif">',
            css: {
                border: "none",
                background: "none"
            }
        });
    var path = 'cancel_extra_session_reflex';
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                coach_session_id: coach_session_id
            },
            url: path,
            success: function(data){
                jQuery(cancel_link).parent().prev().text('Cancelled');
                var current_session_count = parseInt(jQuery(shift_popup.cell).find('span.session_details').first().html(),10);
                current_session_count--;
                var noOfValidExtraSessions = 0;
                jQuery('div[data_isExtraSession=true]').each(function(){
                    if(jQuery(this).parent().find('div.actuals_row_element:contains("Extra Session")').length > 0){
                        noOfValidExtraSessions = noOfValidExtraSessions + 1;
                    }
                });
                if(noOfValidExtraSessions === 0){
                    jQuery(shift_popup.cell).removeClass('extra_session');
                }
                if(jQuery('div.actuals_row_element:contains("Substitute required")').length === 0 && noOfValidExtraSessions === 0){
                    jQuery(shift_popup.cell).find('span.sub_needed_text_in_slot').prev().remove();
                    jQuery(shift_popup.cell).find('span.sub_needed_text_in_slot').remove();
                    if(jQuery('div.actuals_row_element:contains("Active")').length === 0) {
                        jQuery(shift_popup.cell).removeClass('pushed_to_eschool');
                    }
                }
                if(current_session_count === 0 && jQuery('div.locals_row').length === 0){
                    jQuery(shift_popup.cell).find('span').first().addClass('display_none');
                }
                jQuery(shift_popup.cell).find('span.session_details').first().html(current_session_count);
                shift_popup.close();
                alert(data);
            },
            error: function(data){
                alert(data);
            },
            complete: function() {
                jQuery.unblockUI();
            }
        });
    }
};
var editExtraSession = function(eschool_session_id,utc_time,ele) {
    pos=jQuery(ele).offset();
    jQuery('#ms-edit-popup-content').empty();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#ms-edit-popup-container').height();
    previousposition=jQuery("#ms-edit-popup-container").offset();
    jQuery('body').addClass('cursor_wait');
    jQuery('#content, #master_schedule, .one-hour-cell-for-MS').addClass('cursor_wait');
    closeSessionDetails();
    jQuery('.close-ms-edit-popup').click(closeSessionDetails);
    var ext_village_id = jQuery('ext_village_identifier').val();
    path = '/edit_extra_session/'+eschool_session_id+'/'+ext_village_id+'/'+utc_time;
    jQuery.get(path,function(data){
        jQuery("#ms-edit-popup-content").html(data);
        jQuery("#ms-edit-popup-container").css({
            "position":"absolute",
            "left":pos.left-362+"px",
            "top":pos.top-height+48+"px"

        });
        jQuery('body').removeClass('cursor_wait');
        jQuery('#content, #master_schedule, .one-hour-cell-for-MS').removeClass('cursor_wait');
        jQuery("#ms-edit-popup-container").show('slow', function() {
        });
        jQuery('html,body').animate({
            scrollTop: previousposition.top,
            scrollLeft:previousposition.left+100
        }, 1000);
    });

};

var updateExtraSessions = function(eschool_session_id){
    var path;
    var seats               = jQuery('#number_of_seats').val();
    var start_time      = jQuery(shift_popup.cell).attr('alt');
    var level               = jQuery('#level').val();
    var unit                = jQuery('#unit').val();
    var session_name        = jQuery('#session_name_txt').val();
    var wildcard            = (level == '--' && unit == '--');
    var village_id          = jQuery('#village_id').val();   
    var coach_ids           = collectSelectedCoachIds();
    var illelgalwildcard = ((level == '--' && unit != '--') || (level != '--' && unit == '--') );
    if(!wildcard && illelgalwildcard ){
        alert ('Enter both Level and Unit as wildcard or select values for both');
    }else {

        path = 'update_extra_session';
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                eschool_session_id : eschool_session_id,
                start_time: start_time,
                number_of_seats: seats,
                level: level,
                unit: unit,
                name: session_name,
                wildcard: wildcard,
                village_id: village_id,
                excluded_coaches: coach_ids.join()
            },
            url: path,
            success: function(data){
                alert(data);
                shift_popup.close();
            }
        });
    }
};
var createExtraSessionReflex = function(fromEdit,is_lotus, lang_id){
    var path;
    var start_time      = jQuery(shift_popup.cell).attr('alt');
    var session_name    = jQuery('#session_name_txt').val();
    var coach_ids       = collectSelectedCoachIds();
    jQuery.blockUI({
            message : '<img src = "/images/big_spinner.gif">',
            css: {
                border: "none",
                background: "none"
            }
    });
    path = 'create_extra_session_reflex';
    jQuery.ajax({
        type: "post",
        async: true,
        data: {
            start_time: start_time,
            lang_id: lang_id,
            name: session_name,
            excluded_coaches: coach_ids.join()
        },
        url: path,
        success: function(data){
            alert(data);
            createLocalSessions(fromEdit, is_lotus, data);
        },
        complete: function() {
            jQuery.unblockUI();
        }
    });
};

var editExtraSessionReflex = function(coach_session_id,utc_time,ele) {
    pos=jQuery(ele).offset();
    jQuery('#ms-edit-popup-content').empty();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#ms-edit-popup-container').height();
    previousposition=jQuery("#ms-edit-popup-container").offset();
    jQuery('body').addClass('cursor_wait');
    jQuery('#content, #master_schedule, .one-hour-cell-for-MS').addClass('cursor_wait');
    closeSessionDetails();
    jQuery('.close-ms-edit-popup').click(closeSessionDetails);
    var ext_village_id = jQuery('ext_village_identifier').val();
    path = '/show_edit_extra_session_reflex/'+coach_session_id+'/'+utc_time;
    jQuery.get(path,function(data){
        jQuery("#ms-edit-popup-content").html(data);
        jQuery("#ms-edit-popup-container").css({
            "position":"absolute",
            "left":pos.left-362+"px",
            "top":pos.top-height+48+"px"

        });
        jQuery('body').removeClass('cursor_wait');
        jQuery('#content, #master_schedule, .one-hour-cell-for-MS').removeClass('cursor_wait');
        jQuery("#ms-edit-popup-container").show('slow', function() {
        });
        jQuery('html,body').animate({
            scrollTop: previousposition.top,
            scrollLeft:previousposition.left+100
        }, 1000);
    });

};

var updateExtraSessionReflex = function(coach_session_id){
    var path;
    var session_name        = jQuery('#session_name_txt').val();    
    var coach_ids           = collectSelectedCoachIds();    
        path = 'update_extra_session_reflex';
        jQuery.ajax({
            type: "post",
            async: true,
            data: {
                coach_session_id : coach_session_id,
                name: session_name,
                excluded_coaches: coach_ids.join()
            },
            url: path,
            success: function(data){
                alert(data);
                shift_popup.close();
            }
        });
};

var collectSelectedCoachIds = function(){
    var coach_ids = [];
    var coach_list_array = jQuery('#excluded_coach_list_ul').find('li>input:not(:checked)');
    jQuery.each(coach_list_array, function() {
        coach_ids.push(jQuery(this).val());
    });    
    return coach_ids;
};

var bindSessionNameLengthValidation = function(){
    var max_length_for_session_name = 80;
    jQuery('#session_name_txt').live('change', function () {
        if(jQuery(this).val().length > max_length_for_session_name) {
            alert('Session name cannot exceed 80 characters.');
            jQuery(this).val(jQuery(this).val().substring(0,max_length_for_session_name));
        }
    });
};
