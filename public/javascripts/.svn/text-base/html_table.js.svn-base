  $(document).ready(function() {
    applyCSSForTables();
  });

  function applyCSSForTables(){
    $('*[class^="old_th"]').each(function(index, obj){
        createOnlyWidth(obj.className, obj.className.substring(6, obj.className.length));
    });
    $('*[class^="th"]').each(function(index, obj){
        createWidth(obj.className, obj.className.substring(2, obj.className.length));
    });
    $('*[class^="tb"]').each(function(pos, obj){
        createMaxWidth(obj.className, obj.className.substring(2, obj.className.length));
    });
    $('*[class^="tb_mod"]').each(function(pos, obj){
        createModWidth(obj.className, obj.className.substring(6, obj.className.length));
    });
  }
  
  function createOnlyWidth(nameOfClass, width){
    $('.'+nameOfClass).css({'width': width});
  }
  function createWidth(nameOfClass, width){
    $('.'+nameOfClass).css({'width': width, 'text-align': 'center'});
  }
  function createMaxWidth(nameOfClass, width){
    $('.'+nameOfClass).css({'width': width, 'max-width': width+'px', 'text-align': 'center'});
  }
  function createModWidth(nameOfClass, width){
    var mod_width = parseInt(width,10) - 1;
    $('.'+nameOfClass).css({'width': width, 'max-width': mod_width+'px'});
  }
  