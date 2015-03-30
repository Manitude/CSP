jQuery(document).ready(function(){
  jQuery('#topics_list').live('click', function(ele){
    jQuery(ele.target).toggleClass("edited");
  });

  jQuery('#save_topics_list').live('click', function(){
        var topics_list = [];
        jQuery(".edited").each(function(){
          topics_list.push($(this).attr("id"));
        });
        jQuery.ajax({
                url: '/save_topics',
                data: {
                    topics_list :topics_list
                },
                success: function() {
                    jQuery(".edited").removeClass("edited");
                    alert("Topics have been updated");
                },
                failure: function(error){
                   console.log(error);
                   alert('Something went wrong, Please report this problem.'); 
                },
                error: function(error){
                  console.log(error);
                  alert('Something went wrong, Please report this problem.');
                }              
        });
  });

});

var validateAndSave = function() {
   jQuery('#error_div').hide();
   jQuery('#save').attr('disabled', true);
   errors = "";
    if (jQuery("#topic_title").val() === "" || jQuery("#topic_description").val() === "" ||
     jQuery('#topic_language').val() === "" || jQuery('#topic_cefr_level').val() === "--"){
      errors = "Please select all the required fields.";
    }
    if(errors !== ""){
      jQuery('#error_div').html(errors);
      jQuery('#error_div').show();
      jQuery('#save').removeAttr('disabled');
    } else {
      jQuery('#topics_form').submit(); 
    }    
    return false;
};

function fetch_topics(){
  language = jQuery('#lang_identifier').val();
  cefr_level = jQuery('#cefr_levels').val();
   jQuery.ajax({
                url: '/fetch_topics',
                data: {
                    language :language,
                    cefr_level:cefr_level
                },
                success: function() {
                    applyCSSForTables();
                },
                failure: function(error){
                   console.log(error);
                   alert('Something went wrong, Please report this problem.'); 
                },
                error: function(error){
                  console.log(error);
                  alert('Something went wrong, Please report this problem.');
                }              
            });
}
