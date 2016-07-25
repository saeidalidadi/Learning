$(document).ready(function(){
  $('form').submit(function(e){
    e.preventDefault();
    $.ajax({
      method: 'PUT', 
      url: $('form').attr('action'), 
      data:  $('form').serializeArray()
    }).done(function(response){
      alert(response);
    })
  })
})
