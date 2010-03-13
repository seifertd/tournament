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
  [2,16],
  [3,8],
  [4,9],
  [6,12],
  [7,4],
  [3,13],
  [7,6],
  [10,11],
  [10,3],
  [7,14],
  [10,7],
  [15,2]
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
  apply_swaps(swaps);
}

function apply_swaps(swaps) {
  for(var region = 0; region < 4; ++region) {
    swaps.forEach(function(swap) {
      var index1 = swap[0] - 1;
      var index2 = swap[1] - 1;
      var node1 = $('region_' + region + '_' + index1);
      var node2 = $('region_' + region + '_' + index2);
      node1.swap(node2);
    });
  }
}
