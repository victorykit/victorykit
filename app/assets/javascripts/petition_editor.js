function applyRichTextEditorTo(item) {
  $(item).wysihtml5({"html": true, parserRules: wysihtml5ParserRules});
}

function initTabIndexes() {
  $('#petition_title').attr('tabIndex', '1');
  $('iframe').attr('tabIndex', '2');
  if ($('#petition_to_send').length) {
    $('#petition_to_send').attr('tabIndex', '3');
    $('#petition_submit').attr('tabIndex', '4');
  }
  else {
    $('#petition_submit').attr('tabIndex', '3');
  }
}

function remove_fields(link) {
  $(link).find("input[type=hidden]").first().val("1");
  $(link).closest(".additional_title").hide();
}

function add_fields(link, association, content, where_selector) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(where_selector).append(content.replace(regexp, new_id));
  var full_id = "#petition_#{association}_attributes_" + new_id + "_title";
  $(full_id).focus();
}

function initEditPetition(root) {
  root = $(root);

  applyRichTextEditorTo('#petition_description');
  initTabIndexes();
  if ($('#email_subject').has('.additional_title').length) {
    $('#email_subject').show();
    $('#email_subject_link').hide();
  }

  $('#email_subject_link').click(function () {
    $('#email_subject').show();
    $('#email_subject input').focus();
    $('#email_subject_link').hide();
  });

  if ($('#facebook_title').has('.additional_title').length) {
    $('#facebook_title').show();
    $('#facebook_title_link').hide();
  }

  $('#facebook_title_link').click(function () {
    $('#facebook_title').show();
    $('#facebook_title_link').hide();
  });

  $('#facebook_description_link').click(function (evt) {
    $('#facebook_description').show();
    $('#facebook_description_link').hide();
    evt.preventDefault();
  });

  if ($('#sharing_image').has('.additional_title').length) {
    $('#sharing_image').show();
    $('#sharing_image_link').hide();
  }

  $('#sharing_image_link').click(function () {
    $('#sharing_image').show();
    $('#sharing_image_link').hide();
  });
}

function send_email_preview(form, url) {
  var valuesToSubmit = form.serialize();
    $.ajax({
        url: url,
        data: valuesToSubmit,
        type: 'POST',
        dataType: "JSON",
        statusCode: {
          200: function() {
            alert("Email sent!");
          }
        },
        error: function(jqXHR, textStatus, errorThrown) {
          alert(textStatus + "...Failed to send email because...\n" + jqXHR.responseText);
        }
    });
}

$(document).ready(function() {
  $(".petition-form").each(function() { 
    initEditPetition(this);
    $("#petition_facebook_description").counter({ goal: 300, count: 'down' });
  });
});