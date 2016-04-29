ready = ->
  ##################
  # menu
  ##################
  $(document).on 'click', '.menu-trigger', (e) ->
    e.preventDefault()
    $(this).toggleClass('active')
    $('.menu').toggleClass('hide')

  ##################
  # switch_content
  ##################
  $(document).on 'click', '.switch_content', (e) ->
    if ($(this).hasClass('switch_content_selected'))
      return false

    $('.switch_content').toggleClass('switch_content_selected')

    if ($(this).hasClass('switch_content_first'))
      $('.content_first').show()
      $('.content_second').hide()
    else
      $('.content_first').hide()
      $('.content_second').show()

$(document).ready(ready)
$(document).on('page:load', ready)