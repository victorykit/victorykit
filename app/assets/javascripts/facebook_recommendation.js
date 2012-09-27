function diff(array1, array2) {
  var a1 = $.map(array1, function(item) {return item.uid;});
  var a2 = $.map(array2, function(item) {return item.uid;});
  var uids = a1.filter(function(i) {
    return a2.indexOf(i) < 0;
  });
  return array1.filter(function(i) { return uids.indexOf(i.uid) >= 0; });
}

function buildMultiFriendSelector() {
  $(VK.recommended_friends).each(function(index, item) {
    var suggested = item.suggested;
    var checked = item.preselect ? 'checked' : '';
    var li = $('<li><input type="checkbox" '+checked+' value="'+item.uid+'"/>'+item.name+'</li>');
    var id = suggested ? '#suggested' : '#other';
    $('.facebook_friend_widget ' + id + ' ul').append(li);
    $(id).removeClass('hide');
  });
}

function findRecommendedFriends(groups) {
  var tier1 = diff(groups.friends_notifying, groups.friends_involved);
  var friends_not_involved = diff(groups.friends, groups.friends_involved);
  var tier2 = diff(friends_not_involved, tier1);
  var tier3 = diff(groups.friends, tier1.concat(tier2));
  console.log("Tier1: ", tier1);
  console.log("Tier2: ", tier2);
  console.log("Tier3: ", tier3);
  VK.recommended_friends = [];

  $(tier1).each(function(index, friend){
    VK.recommended_friends.push({uid: friend.uid, name: friend.name, type: 'suggested', preselect: true});
  });

  $(tier2).each(function(index, friend){
    VK.recommended_friends.push({uid: friend.uid, name: friend.name, type: 'suggested', preselect: false});
  });

  $(tier3).each(function(index, friend){
    VK.recommended_friends.push({uid: friend.uid, name: friend.name, type: 'other', preselect: false});
  });

  buildMultiFriendSelector();
}

function query_facebook(query, groups) {
  FB.api("/fql?q=" +  encodeURIComponent(JSON.stringify(query)),
    function(response) {
      $(response.data).each(function(index, object) {
        var name = object.name;
        var resultSet = object.fql_result_set;
        $(resultSet).each(function(i, friend) {
          if(!groups[name]) { return; }
          groups[name].push(friend);
        });
      });

      findRecommendedFriends(groups);
    }
  );
}

function getFriendsWithAppInstalled() {
  var groups = {
    friends_notifying: [],
    friends_involved: [],
    friends: []
  };
 
  var query = {
    "friend_ids":"select uid2 from friend where uid1 = me()",
    "friends_notifying":"select name, uid from user where uid "+
      "in (select sender_id from notification where recipient_id = me()) "+
      "order by profile_update_time desc limit 50", 
    "friends_involved":"select name, uid from user where uid in "+
      "(select user_id from url_like where user_id in (select uid2 from #friend_ids) "+
      "and strpos(url, \'watchdog.net\') > 0) order by profile_update_time desc limit 50", 
    "friends":"select name, uid from user where uid in (select uid2 from #friend_ids) "+
      "order by profile_update_time desc limit 50"
  };

  query_facebook(query, groups);
}

function submitAppRequest() {
  $("#thanksModal").modal('toggle');
  FB.login(function (response) {
    if (response.authResponse) {
      getFriendsWithAppInstalled();
      $('#facebookFriendsModal').modal('toggle');
     }
  }, {scope: 'publish_actions, manage_notifications'});
}

function bindFacebookAppRequestButton() {
  $('.fb_request_btn').click(submitAppRequest);  
}
