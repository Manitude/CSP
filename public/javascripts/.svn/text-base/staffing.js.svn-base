jQuery(document).ready(function(){
    jQuery("#import_history").tablesorter({
        headers: {
            1: {
                sorter: false
            },
            2: {
                sorter: false
            },
            5: {
                sorter: false
            },
            6:{
                sorter: false
            }
        }
    });
});
  
var check_file = function(){
    str=document.getElementById('staffing_data_file').value.toUpperCase();
    suffix=".CSV";
    suffix2=".csv";
    if(document.getElementById('staffing_data_file').value === ''){
        alert('No file selected to upload');
        return false;
    }
    else if(!(str.indexOf(suffix, str.length - suffix.length) !== -1||
        str.indexOf(suffix2, str.length - suffix2.length) !== -1)){
        alert('File type not allowed,\nAllowed file: *.csv,*.CSV');
        return false;
    }
};

var fileUpload = function(){
    var start_date_value = jQuery("#start_date").val();
    var start_date = new Date(start_date_value);
    if(start_date.getTime() >= begining_of_week){
        var content = ''+
        '<form method="post" id="show_staffing_file_info_path_form" enctype="multipart/form-data" class="show_staffing_file_info_path_form" action="/import_staffing_data">' +
        '<input size="30" type="file" name="staffing_data[file]" id="staffing_data_file">' +
        '<input type="submit" class="upload" value="Upload" onclick="return check_file()" name="commit">' +
        '<input type="hidden" name="date" id="hidden_effective_start_date" value="'+start_date_value+'">' +
        '</form>';
        jQuery.facebox(content);
        document.getElementById('facebox_header').innerHTML = 'File Upload';
    }else{
        alert("File can be uploaded for current and future weeks only.");
    }
};

var redirectPage = function(){};