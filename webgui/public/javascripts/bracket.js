  var made_changes = false;
  function submitPicks(form) {
    var picks = '';
    for(var i = 65; i < 128; ++i) {
      var elem = $('' + i)
      var idx = i - 65;
      if ((team = elem.readAttribute('team')) != '') {
        var t2 = $('' + (idx * 2 + 2)).readAttribute('team');
        if (t2 == team) {
          picks += '2';
        } else {
          picks += '1';
        }
      } else {
        picks += '0';
      }
    }
    $('picks').value = '' + picks;
    $('games').value = '' + games;
    return true
  }
  function pick(elem) {
    made_changes = true;
    elem = $(elem)
    var idx = parseInt(elem.id)
    var team = elem.readAttribute('team');
    if (team == '') {
      return;
    }
    var other_team = $('' + other_idx(idx)).readAttribute('team')
    //alert ("idx = " + idx + " next idx = " + next_idx(idx) + " team = " + team);

    var next_elem = $('' + next_idx(idx));
    //alert ("next_elem = " + next_elem)
    if (next_elem) {
      set_team(next_elem, team);
      if (other_team != '') {
        // walk the tree of next games looking for winner
        // that is not the selected winner and set to null
        while (next_elem = $('' + next_idx(next_elem.id))) {
          next_team = next_elem.readAttribute('team');
          //alert ("next_elem = " + next_elem.id + " next team = " + next_team)
          if (next_team != '' && next_team == other_team) {
            next_elem.setAttribute('team', '');
            next_elem.innerHTML = '&nbsp;';
            next_elem.onmouseover = null;
            next_elem.onmouseout = null;
          } else {
            break;
          }
        }
      }
    }
  }
  function set_team(elem, team) {
    elem.setAttribute('team', team);
    elem.innerHTML = team;
    elem.onmouseover = function () {
      this.style.backgroundColor='black';
      this.style.color = 'white';
    }
    elem.onmouseout = function () {
      this.style.backgroundColor='';
      this.style.color = '';
    }
    elem.addClassName('pendingpick');
    elem.removeClassName('missedpick');
  }
  function other_idx(idx) {
    return idx % 2 == 0 ? idx - 1 : idx + 1
  }
  function next_idx(idx) {
    return Math.floor((idx-1)/2) + 65;
  }
