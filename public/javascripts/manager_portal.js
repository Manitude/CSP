function getCoach(action){

    if(((jQuery('#coach_id').val()===""||jQuery('#coach_id_initial').val()==="")&&jQuery('#lang_identifier').val()==="")&&action==="GO")
    {
        jQuery('#validation_message').text("Please Select a Language and a Coach");
    }
    else if((jQuery('#coach_id').val()===""||jQuery('#coach_id_initial').val()==="")&&action==="GO")
    {
        jQuery('#validation_message').text("Please Select a Coach");
    }
    else{
        var coach_id;
        if (jQuery('#coach_id'))
            coach_id = jQuery('#coach_id').val();
        else if (lastVisitedCoach !== "")
            coach_id = lastVisitedCoach;
        var lang_id = jQuery('#lang_identifier').val();
        var filter_lang = jQuery('#filter_language').val();
        var date = new Date(jQuery('#start_date').val());
        year = date.getFullYear();
        month = date.getMonth() + 1;
        day = date.getDate();
        if (month < 10) {
            month = "0" + month;
        }
        if (day < 10) {
            day = "0" + day;
        }
        if((lang_id!== "") && (coach_id !== "") && (action === "GO" || action === "Change Language")){
            window.location.href = '/week-view?start_date='+ year + '-' + month + '-' + day +'&coach_id='+coach_id+'&lang_identifier='+lang_id+'&filter_language=all';
        }
        else if((lang_id!== "") && (coach_id !=="") && (typeof filter_lang !== 'undefined') && (filter_lang !== '-1') ){
            window.location.href = '/week-view?start_date='+ year + '-' + month + '-' + day +'&coach_id='+coach_id+'&lang_identifier='+filter_lang+'&filter_language='+filter_lang;
        }
        else if((lang_id!== "")&&(coach_id !== "")){
            window.location.href = '/week-view?start_date='+ year + '-' + month + '-' + day +'&coach_id='+coach_id+'&lang_identifier='+lang_id+'&filter_language=all';
        }
        else if(lang_id==="")
        {
            window.location.href = '/week-view?start_date='+ year + '-' + month + '-' + day;
        }
        else if(coach_id==="")
        {
            window.location.href = '/week-view?start_date='+ year + '-' + month + '-' + day +'&lang_identifier='+lang_id;
        }
        else {
            window.location.href = '/week-view?start_date='+ year + '-' + month + '-' + day +'&lang_identifier='+lang_id;
        }
    }

}

function getTemplate(template){
    window.location.href = '/week-view?template='+template;
}