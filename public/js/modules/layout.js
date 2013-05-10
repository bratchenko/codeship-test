define([], function() {

    return {
        init: function() {
            $(function(){
                $("body").append($("<h2>I'm alive!</h2>"));
            });
        }
    };

});