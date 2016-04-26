# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if 'undefined' == typeof registered_artist_names
    return false

  $(document).on 'click', '.candidates li', (e) ->
    artist_name = $(this).text()
    appendArtistName(artist_name)

  #$(document).on 'blur', ':input[name="artist_name"]', (e) ->
  #  $('.candidates').hide()

  $(document).on 'keyup', ':input[name="artist_name"]', (e) ->
    input_text = $(this).val()
    if input_text.length >= 2
      input_text_lc = input_text.toLowerCase()
      _html = ''
      for registered_artist_name,i in registered_artist_names
        registered_artist_name_lc = registered_artist_name.toLowerCase()
        #TODO ひらがなカタカナ比較
        if registered_artist_name_lc.indexOf(input_text_lc) != 0
          continue
        _html += '<li>'+registered_artist_name+'</li>'

      # registered_artist_names_starting_with_the
      # TODO workaround for names like 'The theives'
      if registered_artist_names_starting_with_the_removed_the_lc.length > 0
        for registered_artist_name_starting_with_the_removed_the_lc,i in registered_artist_names_starting_with_the_removed_the_lc
          if registered_artist_name_starting_with_the_removed_the_lc.indexOf(input_text_lc) != 0
            continue
          _html += '<li>'+registered_artist_names_starting_with_the[i]+'</li>'

      if _html.length > 0
        $('.candidates').html(_html).show()
      else
        $('.candidates').hide()
    else
      $('.candidates').hide()

  $(document).on 'keydown', '#form_artist_name', (e) ->
    code = e.keyCode || e.which
    if code == 13
      e.preventDefault()
      $('.add_artist').trigger('click')

  $(document).on 'click', '.add_artist', (e) ->
    e.preventDefault()
    $input_form = $(':input[name="artist_name"]')
    input_text = $input_form.val()
    if input_text.length == 0
      return false
    appendArtistName(input_text)

  appendArtistName = (artist_name) ->
    $(':input[name="artist_name"]').val('')
    $('.candidates').hide()
    is_already_added = false
    $(':hidden[name="artist_names[]"]').each (index, element) =>
      if $(element).val() == artist_name
        is_already_added = true
        return false
    if(is_already_added)
      return false
    $('.artists').prepend('<li><span class="closeBtn"></span>'+artist_name+'<input type="hidden" name="artist_names[]" value="'+artist_name+'"></li>')

$(document).ready(ready)
$(document).on('page:load', ready)