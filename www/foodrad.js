
// { カテゴリ: [品名, 品名, ...] }
var categories = {
};
var load_ok = [];

function check_done_loading(sym) {
    load_ok.push(sym);

    if(load_ok.length >= 2) {
	jQuery.mobile.hidePageLoadingMsg();
	jQuery('#submit').removeProp("disabled");
    }
}

function get_area() {
    jQuery.getJSON('prefectures.php?callback=?', function(results){ 
	var sel = jQuery('#select-home_pref');
	sel.empty();
	sel.append(jQuery("<option>").text("すべて").val(""));
	for(var i = 0; i < results.length; i++) {
	    var item = results[i];

	    var opt = jQuery("<option>");
	    var caption = item['home_pref'];
	    if(caption == null) caption = "（不明）"
	    opt.text(caption + " (" + item['count'] + ")").val(item['home_pref']);
	    sel.append(opt);
	}
	sel.trigger("create");
	check_done_loading("home_pref");
    });
}

function get_categories() {
    jQuery.getJSON('categories.php?callback=?', function(result) {
	categories = result;
	var sel = jQuery('#select-category');
	sel.empty();
	sel.append(jQuery("<option>").text("すべて").val(""));
	for(var key in categories) {
	    var item = categories[key];
	    var opt = jQuery("<option>");
	    var caption = key + " (" + item['count'] + ")";
		
	    opt.text(caption).val(key);
	    sel.append(opt);
	}
	sel.trigger("create");
	check_done_loading("category");
    });
}

function onchange_category(cat_name) {
    jQuery('#category').val(cat_name);

    var sel = jQuery('#select-item_name');
    var cat = categories[cat_name]['items'];

    sel.empty();
    sel.append(jQuery("<option>").text("すべて").val(""));
    for(var i = 0; i < cat.length; i++) {
	var opt = jQuery("<option>");
	
	opt.text(cat[i]).val(cat[i]);
	sel.append(opt);
    }
    sel.trigger("create");
}

function rad_label(item, key) {
    if(item[key] == null) {
	return "-";
    }
    if(item[key + "_nd"] != 0) {
	return "< " + item[key];
    }
    return item[key];
}

function on_submit() {
    var ul = jQuery("#result");
    ul.empty();

    jQuery.mobile.showPageLoadingMsg();

    jQuery.getJSON('search.php?callback=?', {
	home_pref: jQuery('#home_pref').val(),
	category: jQuery('#category').val(),
	item_name: jQuery('#item_name').val(),
	cs_total: jQuery('#cs_total').val()
    }, function(result) {
	var ul = jQuery("#result");
	ul.empty();

	if(result == null || result.length == 0) {
	    jQuery("<li>").text("見つかりませんでした").appendTo(ul);
	    jQuery.mobile.changePage(jQuery('#resultPage'));
	    jQuery('ul.dynamic-list').listview('refresh');
	    jQuery.mobile.hidePageLoadingMsg();
	    return;
	}

	for(var i in result) {
	    var item = result[i];
	    var li = jQuery("<li>");
	    var anchor = jQuery("<a>");

	    var title = jQuery("<h3>").text(item['item_name'] + " ").append(jQuery("<small>").text(item['category']));
	    var p1 = jQuery("<p>").text("Cs: " + rad_label(item, 'cs_total') + " Bq/kg"),
	    p2 = jQuery("<p>").text("Cs134: " + rad_label(item, 'cs134') + " Bq/kg, " +
				    "Cs137: " + rad_label(item, 'cs137') + " Bq/kg");

	    anchor.append(title).append(p1).append(p2);

	    jQuery.data(anchor, "item", item);
	    
	    anchor.attr("href", "#detailPage")
	    anchor.click(item, function(event) {
		showDetail(event);
	    });

	    li.append(anchor);
	    ul.append(li);
	}
	jQuery.mobile.changePage(jQuery('#resultPage'));
	jQuery('ul.dynamic-list').listview('refresh');
	jQuery.mobile.hidePageLoadingMsg();
    });
    return false;
}

function showDetail(event) {
    var data = event.data;
    for(var key in data) {
	var td = jQuery("#detail-" + key);
	if(td && td.length > 0) {
	    td.text(data[key]);
	}
    }
}
