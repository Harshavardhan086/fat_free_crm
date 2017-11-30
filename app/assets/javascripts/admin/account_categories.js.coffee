
jQuery ($) ->
  $(document).on("click",".remove_account_category", ->
    ac_id = $(this).attr("id")
    $. get "/remove_account_category",
      id: ac_id
    return
  )