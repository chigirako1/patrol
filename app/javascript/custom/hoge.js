

function toggle_options_up(elemntId) {
    let sel_box = document.getElementById(elemntId);
    let options = sel_box.options;

    for (let i = 0; i < options.length; i++) {
        if (options[i].selected) {
            if (i == 0) {
                options[options.length - 1].selected = true;
            }
            else {
                options[i - 1].selected = true;
            }
            break;
        }
    }
}

function toggle_options_down(elemntId) {
    let sel_box = document.getElementById(elemntId);
    let options = sel_box.options;

    for (let i = 0; i < options.length; i++) {
        if (options[i].selected) {
            if (i == options.length - 1) {
                options[0].selected = true;
            }
            else {
                options[i + 1].selected = true;
            }
            break;
        }
    }
}

function hoge_u() {
    toggle_options_up("artist_feature");
}

let elem = document.getElementById("artist_feature_up");
if (elem)
{
    elem.onclick = hoge_u;
}
