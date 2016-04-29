# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'submit', 'form[name="signup"]', (e) ->
  offset = new Date().getTimezoneOffset()
  timezone = Math.floor(-(offset / 60))
  $(this).append('<input type="hidden" name="user[timezone]" value="'+timezone+'">')

$(document).on 'click', '.switch_content', (e) ->
  if ($(this).hasClass('switch_content_selected'))
    return false

  $('.switch_content').toggleClass('switch_content_selected')

  if ($(this).hasClass('switch_content_signup'))
    $('form[name="login"]').hide()
    $('form[name="signup"]').show()
  else
    $('form[name="login"]').show()
    $('form[name="signup"]').hide()
