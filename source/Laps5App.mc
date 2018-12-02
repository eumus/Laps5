using Toybox.Application;

class Laps5App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new Laps5View() ];
    }

}