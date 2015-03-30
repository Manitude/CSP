$.noConflict();
jQuery(document).ready(function()
{
  jQuery("#sessions_table").tablesorter({
    headers: {
      2: {
        sorter: false
      },
      3: {
        sorter: false
      },
      4: {
        sorter: false
      },
      7: {
        sorter: false
      }
    }
  });

  jQuery('#sessions_table > tbody > tr').live('click',function(e){
    jQuery("tr[class='highlighted']").removeClass('highlighted');
    jQuery(jQuery(e.target).closest('tr')).addClass('highlighted');
  });
jQuery('#classroom_type').bind('change', function(){
    location = reload_url + "&classroom_type=" + this.value;
  });
});