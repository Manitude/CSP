
  jQuery(document).ready(function () {

    jQuery('.box_link_header').bind("click", function(e) {
      jQuery(this).next().slideToggle();
    });

    jQuery('#create_new_box_widget').bind("click", function(e) {
      jQuery.facebox(function (){
        jQuery.ajax({
          url: "/box_links/new",
          type: "get",
          async: true,
          success: function(data){
            jQuery.facebox(data);
          }
        });
      });
    });

    jQuery('.box_delete_link').bind("click", function(e) {
      e.stopPropagation();
      var box_link_id = jQuery(this).attr('data_box_id');
      jQuery.alerts.okButton = ' Yes ';
      jQuery.alerts.cancelButton = ' No ';
      jQuery.alerts.confirm("Are you sure you want to delete this widget?", '', function(result) {
        if(result) {
          jQuery.ajax({
            url: "/box_links/" + box_link_id,
            type: "delete",
            async: true,
            success: function(data){
              if(data =="Success"){
                alert("Widget Removed Successfully");
                window.location.href = "/box_links";
              }else{
                alert("Something went wrong. Please try again.");
              }
            }
          });
        }
      });
    });

    jQuery('.box_edit_link').bind("click", function(e) {
      e.stopPropagation();
      var box_link_id = jQuery(this).attr('data_box_id');
      jQuery.facebox(function (){
        jQuery.ajax({
          url: "/box_links/" + box_link_id + "/edit",
          type: "get",
          async: true,
          success: function(data){
            jQuery.facebox(data);
          }
        });
      });
    });

});


  function validateBoxForm(){
    var title = jQuery('#box_link_title').val();
    var url = jQuery('#box_link_url').val();
    message = [];
    if(title === ""){
      message.push("Title cannot be blank.");
    }
    if(url === ""){
      message.push("Url cannot be blank.");
    }else{
      if(!(url.match(/^(https:\/\/app.box.com\/embed_widget|http:\/\/app.box.com\/embed_widget|https:\/\/rosettastone.app.box.com\/embed_widget|http:\/\/rosettastone.app.box.com\/embed_widget)/))){
        message.push("Url should be a valid box.com widget url.");
      }
    }
    if(message.length === 0){
      return true;
    }else{
      alert(message.join("\n"));
      return false;
    }
  }