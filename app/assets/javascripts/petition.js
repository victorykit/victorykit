jQuery(function(){
	var cookie = $.cookie('signed_petitions') || '';	
	var petitionIds = cookie.split("|");
	var currentPetitionId = $('#petitionId').val();
	if ($.inArray(currentPetitionId, petitionIds) > -1) {
        $('#thanks-for-signing-message').show();
        $('#sign-up-form').hide();
    }
    $('#petition_description').wysihtml5();
});
