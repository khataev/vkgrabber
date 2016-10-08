$('#downloadModal').on('show.bs.modal', function (event) {
  var button = $(event.relatedTarget) // Button that triggered the modal
  var groupName = button.data('groupname') // Extract info from data-* attributes
  // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
  // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
  var modal = $(this)
  modal.find('.modal-title').text('Имя группы: ' + groupName)
  modal.find('.group-name').val(groupName)
});

/*
$('#longActionModal').on('shown.bs.modal', function () {

})

jQuery.noConflict();
jQuery(document).ready(function($) {
    $('#longActionModal').modal('show')
});
*/