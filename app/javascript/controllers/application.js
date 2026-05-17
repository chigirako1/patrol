import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// windowオブジェクトのプロパティにすることで、どこからでも呼び出せるグローバル関数になる
window.myAppUtils = {
    getElemTwt: function(elem_id)
    {
        let elem = document.getElementById(elem_id);
        return elem;
    },

    add_value: function(elem_id, point) {
        const elem = getElemTwt(elem_id);
        elem.value = (Number(elem.value) || 0) + point;
    }
};