
jQuery ($) ->
  console.log("you are in the business rules js")
  $(document).on("click",".rule", ->
    console.log("BR ID IS :" + ($(this).attr('id')))
    br_id = $(this).attr('id')
    $. post '/edit_br',
      br_id: br_id
    return
  )

  $(document).on("click", ".remove_br_attachment",->
    console.log("IN THE REMOVE ATTACHMENT")
    attachment_id = $(this).attr("id")
    console.log("the attachment id is: " + attachment_id)
    $.post '/remove_br_attachment',
      attachment_id: attachment_id
    return
  )

  $(document).on("click", ".remove_additional_field",->
    console.log("IN REMOVE ADDIDIONAL FIELDS")
    additional_field_id = $(this).attr("id")
    $.post "/remove_additional_field",
      field_id: additional_field_id
    return
  )
  $('#business_rules').DataTable responsive: true

