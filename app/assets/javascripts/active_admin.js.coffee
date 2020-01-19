#= require active_admin/base
#= require tinymce

$(document).ready ->
  $('textarea.tinymce').prev('label').css('float', 'none')
  tinyMCE.init
    selector: 'textarea.tinymce'
    plugins: 'link autolink lists paste help wordcount code'
    menubar: false
    toolbar: 'undo redo | styleselect | bold italic | link openlink | bullist outdent indent | removeformat code help'
    relative_urls: false
    convert_urls: false
    remove_script_host: false
    theme: 'modern'
    width: '70%'
    height: '200'
  return
