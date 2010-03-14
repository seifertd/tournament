// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var swapMethod = {
	swap: function(element, el) {
		element = $(element);
		el = $(el);

		if (element == el) return element;

		var clone = el.cloneNode(false); // no need to clone deep
		Element.replace(element, clone);
		Element.replace(el, element);
		Element.replace(clone, el); // make sure references (like event observers) are kept
		return element;
	}
}
Element.addMethods(swapMethod);

var swaps = [
  [15,2],
  [10,7],
  [7,14],
  [10,3],
  [10,11],
  [7,6],
  [3,13],
  [7,4],
  [6,12],
  [4,9],
  [3,8],
  [2,16]
];
var order = 'seed';

function switch_to_seed_order() {
  if (order == 'seed') {
    return;
  }
  $('matchup_button').enable();
  $('seed_button').disable();
  order = 'seed';
  apply_swaps(swaps.reverse());
}

function switch_to_matchup_order() {
  if (order == 'matchup') {
    return;
  }
  $('matchup_button').disable();
  $('seed_button').enable();
  order = 'matchup';
  apply_swaps(swaps.reverse());
}

function apply_swaps(swaps) {
  for(var region = 0; region < 4; ++region) {
    swaps.forEach(function(s) {
      var index1 = s[0] - 1;
      var index2 = s[1] - 1;
      var node1 = $('region_' + region + '_' + index1);
      var node2 = $('region_' + region + '_' + index2);
      node1.swap(node2);
    });
  }
}
