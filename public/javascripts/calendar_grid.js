function cellClickedByCoach(cell){
    cell_coordinates = cell.id.toString().match(/\d+/g);
    row = parseInt(cell_coordinates[0], 10);
    col = parseInt(cell_coordinates[1], 10);
    if (col == 47 ){
        alert("Sorry !!! Last Session Cannot be scheduled");
        return;
    }

    $$('#availabilities_table select').each(function(s){
        if(!s.disabled){
            s.hide();
        }
    });

    //  if( col == 0 || getPreviousCell(cell).disabled == true ||  getPreviousCell(cell).value == "Unavailable" ){}
    span_tag = $(cell.id+'span');
    select_tag = span_tag.childElements()[0];
    span_tag.style.visibility = 'visible';
    select_tag.disabled = false;
    select_tag.show();
    select_tag.setAttribute('who_suggested',"coach");
    changeCellColor(cell);
}


function changeCellColor(cell){
    span_tag = $(cell.id+'span');
    select_tag = span_tag.childElements()[0];
    if(select_tag.getAttribute('who_suggested') == "coach_manager") {
        if(select_tag.value == 'Available') {
            cell.style.background = '#4444FF';
            select_tag.style.background = '#4444FF';
        //changeNextCell(cell,'#4444FF');
        }
        else if(select_tag.value == 'Scheduled') {
            cell.style.background = '#498B66';
            select_tag.style.background = '#498B66';
        //changeNextCell(cell,'#498B66');
        }
        else if(select_tag.value == 'Unavailable') {
            cell.style.background = '#999999';
            select_tag.style.background = '#999999';
        //changeNextCell(cell,'#999999');
        }
    }
    else{
        if (select_tag.value == 'Available'){
            cell.className = 'available';
            cell.style.background = '#BBBBFF';
            select_tag.style.background = '#BBBBFF';
        //changeNextCell(cell,'#BBBBFF');
        }
        else if (select_tag.value == 'Scheduled'){
            cell.className = 'scheduled';
            cell.style.background = '#BBFFBB';
            select_tag.style.background = '#BBFFBB';
        //changeNextCell(cell,'#BBFFBB');
        }
        else if (select_tag.value == 'Unavailable'){
            cell.className = 'unavailable';
            cell.style.background = '#BBBBBB';
            select_tag.style.background = '#BBBBBB';
        //changeNextCell(cell,'#BBBBBB');
        }
    }

}

/*
function changeNextCell(cell,color){
    cell_coordinates = cell.id.toString().match(/\d+/g);
    row = parseInt(cell_coordinates[0]);
    col = parseInt(cell_coordinates[1]) + 1;

    next_cell = $("grid["+row+"]["+col+"]")
    next_select_tag = next_cell.childElements()[0].childElements()[0];
    next_cell.style.background = color;
    next_select_tag.style.background = color;
    next_select_tag.disabled = true;
    col = col + 1;
    
    next_to_next_cell = $("grid["+row+"]["+col+"]");
    changeNextToNextCell(next_to_next_cell);
}

function getPreviousCell(cell){
    cell_coordinates = cell.id.toString().match(/\d+/g);
    row1 = parseInt(cell_coordinates[0]);
    col1 = parseInt(cell_coordinates[1])-1;
    return $("grid["+row1+"]["+col1+"]").childElements()[0].childElements()[0];
}

function changeNextToNextCell(next_to_next_cell){
    next_to_next_select_tag=next_to_next_cell.childElements()[0].childElements()[0];
    if ( col < 48 && next_to_next_select_tag.disabled == true){
        next_to_next_cell.className = 'unavailable';
        next_to_next_cell.style.background ='#BBBBBB';
        next_to_next_select_tag.style.background = '#BBBBBB';
    }
}
 */

function cellClickedByManager(cell){
    $$('#availabilities_table select').each(function(s){
        if(!s.disabled){
            s.hide();
        }
    });
    span_tag = document.getElementById(cell.id+'span');
    select_tag = span_tag.childElements()[0];

    span_tag.style.visibility = 'visible';
    select_tag.disabled = false;
    select_tag.show();
    select_tag.setAttribute('who_suggested',"coach_manager");
    changeCellColor(cell);

}

function cellClickedByManagerToChangeTemplate(cell){
    $$('#availabilities_table select').each(function(s){
        if(!s.disabled){
            s.hide();
        }
    });
    cell_coordinates = cell.id.toString().match(/\d+/g);
    row = parseInt(cell_coordinates[0], 10);
    col = parseInt(cell_coordinates[1], 10);
    grid = $("grid["+row+"]["+col+"]");

    span_tag = document.getElementById(cell.id+'span');
    select_tag = span_tag.childElements()[0];
    // We don't want him to ask the poor coach to come at a time when he's unavailable. So DON'T remove that condition!
    // if(select_tag.getAttribute('who_suggested') != null  && (col == 0 || getPreviousCell(cell).disabled == true)) {
    if(grid.className != 'coach_unavailable') {
        span_tag.style.visibility = 'visible';
        select_tag.disabled = false;
        select_tag.show();
        select_tag.setAttribute('who_suggested',"coach_manager");
        changeCellColor(cell);
    }
}

function clear_selections(){
    closeEditPopup();
}

function changeLabel(option){
    if(option == '1'){
        jQuery('#label_in_popup').val('');
    }else {
        val1 = jQuery('#label_in_popup').val();
        jQuery('#label_in_popup').val(val1);
    }
}
function check_date_and_open_availability_edit_popup(cell){
    var date_text=new Date(jQuery('#last_session_date').val().valueOf().split(" ")[0]).toString();
    var last_session_date=new Date(jQuery('#last_session_date').val().valueOf().split(" ")[0]).toString().substring(4,15);
    if(date_text!=="Invalid Date" && !(new Date(jQuery('#effective_start_date').val().valueOf()) > new Date(jQuery('#last_session_date').val().valueOf().split(" ")[0]))){
        alert('You have confirmed sessions. So the effective start date should be after '+ last_session_date );
        return false;
    }
    else{
        return open_availability_edit_popup(cell);
    }
}
function open_availability_edit_popup(cell){
    var el = jQuery(cell);
    jQuery('#requested_action').val(el.val());
    var pos = el.offset();
    var container_pos = jQuery('#body-content #content').offset();
    pos.left = pos.left-container_pos.left;
    pos.top = pos.top-container_pos.top;
    var height = jQuery('#edit-popup-container').height()+20;
    if(jQuery("#edit-popup-container").css('top') == 'auto'){
        jQuery("#edit-popup-container").css( {
            "left": (pos.left - 225) + "px",
            "top": (pos.top - height - 15) + "px"
        } );
    }
    else{
        jQuery("#edit-popup-container").css( {
            "left": (pos.left - 225) + "px",
            "top": (pos.top - height) + "px"
        } );
    }
    jQuery("#edit-popup-container").show();
    return false;
}

function update_availabilities(){//function used for getting the label in the pop up...
   label_val=jQuery('#label_in_popup').val();
   jQuery('#label').val(label_val);
   label_val1=jQuery('#label').val();
   var available = jQuery(".availability_text_box:contains('Available')").length;
   var error_flag = 0;
   var warn_flag = 0;
   var msg='';
   if(label_val === ''){
        msg += "* Label can't be blank.\n";
        error_flag = 1;
    }
    if(label_val && label_val.length < 3) {
        msg += '* Label is too short (minimum is 3 characters).\n';
        error_flag = 1;
    }
    if(label_val == 'What to call this schedule (required)'){
        msg+= '* Label value is not entered';
        error_flag = 1;
    }
    if(available <= 0  ) {
        msg += 'You have not specified availability for any session. Are you sure you want to proceed ?\n';
        warn_flag = 1;
    }
    var can_save_empty = true;
    if(warn_flag){
        can_save_empty = confirm(msg);
    }
    if(!error_flag){
      if(can_save_empty){
        document.forms['template1'].submit();
        closeEditPopup();
      }
    }
    else{
        alert('The following errors were found:\n\n'+msg+'\n Template cannot be saved or submitted');
    }
    closeEditPopup();
}

function closeEditPopup(){
    jQuery('#edit-popup-container').hide();
}

function toggleAvailability(cell){
    var children = cell.childElements();
    input_box_value =children[0].getAttribute('value');
    if(input_box_value == 'Available'){
        cell.setAttribute("class", "unavailable one-hour-cell-with-pointer");
        children[0].setAttribute('value','Unavailable');
        children[1].innerHTML = '';
        children[1].setAttribute("class", "availability_text_box unavailable");
    }else{
        cell.setAttribute("class", "available one-hour-cell-with-pointer");
        children[0].setAttribute('value','Available');
        children[1].innerHTML = 'Available';
        children[1].setAttribute("class", "availability_text_box available");
    }
}
