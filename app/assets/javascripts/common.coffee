ready = ->
  $(document).on 'click', '.menu-trigger', (e) ->
    $(this).toggleClass('active');
    $('.menu').toggleClass('hide');

$(document).ready(ready)
$(document).on('page:load', ready)