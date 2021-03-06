var recommendation = (function() {
  var recommended_friends = [];
  var spinner;
  var socialTracking;

  function diff(array1, array2) {
    var a1 = $.map(array1, function(item) {return item.uid;});
    var a2 = $.map(array2, function(item) {return item.uid;});
    var uids = a1.filter(function(i) {
      return a2.indexOf(i) < 0;
    });
    return array1.filter(function(i) { return uids.indexOf(i.uid) >= 0; });
  }

  function createSpinner() {
    var opts = {
      lines: 13, // The number of lines to draw
      length: 7, // The length of each line
      width: 4, // The line thickness
      radius: 10, // The radius of the inner circle
      corners: 1, // Corner roundness (0..1)
      rotate: 0, // The rotation offset
      color: '#000', // #rgb or #rrggbb
      speed: 1, // Rounds per second
      trail: 60, // Afterglow percentage
      shadow: false, // Whether to render a shadow
      hwaccel: false, // Whether to use hardware acceleration
      className: 'spinner', // The CSS class to assign to the spinner
      zIndex: 2e9, // The z-index (defaults to 2000000000)
      top: 'auto', // Top position relative to parent in px
      left: 'auto' // Left position relative to parent in px
    };
    var target = $('#facebookFriendsModal .modal-body').get(0);
    return new Spinner(opts).spin(target);
  }

  function buildMultiFriendSelector() {
    $(recommended_friends).each(function(index, item) {
      var checked = item.preselect ? 'checked' : '';
      var friend = $(
        '<div class="friend">'+
          '<input type="checkbox" '+checked+' value="'+item.uid+'"/>'+
          '<div class="name">'+item.name+'</div>'+
        '</div>'
      );
      var id = '#' + item.type;
      $('.facebook_friend_widget ' + id + ' .friend_list').append(friend);
      $(id).removeClass('hide');
    });
  }

  function postToMeAndFriends() {
    var domain = location.href.replace(/\?.*/,"");
    var referralCode = (VK.ref_code === '' ? $.cookie('ref_code') : VK.ref_code);
    var url = [domain, '?recommend_ref=', referralCode].join('');
    var message = $('#message-to-friends').val();

    var friends =
      $('.friend_lists input[type="checkbox"]')
        .filter(function() { return $(this).attr('checked'); })
        .map(function() { return $(this).val(); })
        .toArray().concat(['me']);

    (function send(i) {
      if(!(uid = friends[i])) { return; }
      FB.api('/'+uid+'/feed', 'post',
        { link: url, message: message },
        function(res){ send(i+1); }
      );
    })(0);

    $('#facebookFriendsModal').modal('toggle');
    $('#thanksAfterSharingModal').modal('toggle');
  }

  function findRecommendedFriends(groups) {
    var tier1 = diff(groups.interacted, groups.sympathetic);
    var friends_not_involved = diff(groups.friends, groups.sympathetic);
    var tier2 = diff(friends_not_involved, tier1);
    var tier3 = diff(groups.friends, tier1.concat(tier2));
    var suggested = tier1.concat(tier2);
    remaining = suggested.slice(25);
    suggested = suggested.slice(0, 25);
    remaining = remaining.concat(tier3);

    recommended_friends = $.map(suggested, function(friend) {
      return {uid: friend.uid, name: friend.name, type: 'suggested', preselect: true};
    });

    $(remaining).each(function(index, friend){
      recommended_friends.push({uid: friend.uid, name: friend.name, type: 'other', preselect: false});
    });

    buildMultiFriendSelector();
    spinner.stop();
    $('.btn-success').click(postToMeAndFriends);
  }

  function queryFacebook(query, groups) {
    FB.api('/fql?q='+encodeURIComponent(JSON.stringify(query)), function(response) {
      $(response.data).each(function(index, object) {
        var name = object.name;
        var resultSet = object.fql_result_set;
        $(resultSet).each(function(i, friend) {
          if(!groups[name]) { return; }
          groups[name].push(friend);
        });
      });
      findRecommendedFriends(groups);
    });
  }

  function getFriendsWithAppInstalled() {
    spinner = createSpinner();

    var groups = {
      interacted: [],
      sympathetic: [],
      friends: []
    };

    var query = {
      "interacted": (VK.prefer_commenters_to_likers ?
          "select fromid from comment where post_id in " :
          "select user_id from like where post_id in ") +
            "(select post_id from stream where source_id = me() limit 200) limit 25",
      "friend_ids":"select uid2 from friend where uid1 = me()",
      "sympathetic":"select user_id from url_like where user_id in "+
        "(select uid2 from #friend_ids) and strpos(url, \"" + location.host + "\") > 0",
      "friends":"select name, uid from user where uid in (select uid2 from #friend_ids) "+
        "order by profile_update_time desc"
    };

    queryFacebook(query, groups);
  }

  function checkPermissions() {
    function proceedSharing() {
      $('#facebookFriendsModal').modal('toggle');
      if(recommended_friends.length === 0) { getFriendsWithAppInstalled(); }
      socialTracking.trackSharing('recommend');
    }

    function abortSharing() {
      $('#abortSharingModal').modal('toggle');
    }

    FB.api('/me/permissions', function(res) {
      var d = res.data[0];
      return (d.publish_actions && d.read_stream && d.publish_stream) ?
        proceedSharing() : abortSharing();
    });
  }

  function submitAppRequest() {
    closeThanksModal(false);
    FB.login(function (response) {
      if (response.authResponse) {
        checkPermissions();
       }
    }, {scope: 'publish_actions, read_stream, publish_stream'});
  }

  function tryAgain() {
    $('#the-one-in-the-side').trigger('click');
    $('#abortSharingModal').modal('toggle');
  }

  function bind() {
    $('.fb_recommend_btn').click(submitAppRequest);
    $('#try-again').click(tryAgain);
  }

  function init(st) {
    socialTracking = st;
    bind();
  }

  return { init: init };
})();
