$(function(){
    $('.shareLink').click(function(){
        var file_id = $(this).attr('file-id'); 
        var file_name = $(this).attr('file-name'); 
        $('#file_id').val(file_id);
        $('#filename').text('Sending "' + file_name +'"');
    })
})
