$(document).ready(function(){
  $('form.delete').submit(function(e){
    e.preventDefault();
    $.ajax({
      method: 'DELETE', 
      url: $(this).attr('action')
    }).done(function(response){
      alert(response);
    })
  })
})
