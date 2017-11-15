
jQuery ($) ->
  console.log("you are in the business rules js")
  $(document).on("click",".rule", ->
    console.log("BR ID IS :" + ($(this).attr('id')))
    br_id = $(this).attr('id')
    $. post '/edit_br',
      br_id: br_id
    return
  )

  $('#business_rules').DataTable responsive: true