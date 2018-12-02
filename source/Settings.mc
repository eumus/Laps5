class Settings {
	const CURRENT_HR = 0;
	const CURRENT_CADENCE = 10;
	const CURRENT_DISTANCE = 20;
	const LAST_HR = 0;
	const MAX_HR = 10;
	const AVERAGE_HR = 20;
	const MAX_CADENCE = 30;
	const AVERAGE_CADENCE = 40;
	const LAP_DISTANCE = 50;
	
	var column4;
	var bottomField;
	var topBottomFont;
	var rowFont;
	var paddingTop;
	var paddingBottom;

	function initialize() {
        if ( Toybox.Application has :Properties ) {
			column4 = Application.Properties.getValue("column4");
			bottomField = Application.Properties.getValue("bottomField");
			topBottomFont = Application.Properties.getValue("topBottomFont");
			rowFont = Application.Properties.getValue("rowFont");
			paddingTop = Application.Properties.getValue("paddingTop");
			paddingBottom = Application.Properties.getValue("paddingBottom");
		} else {
			column4 = Application.AppBase.getProperty("column4");
			bottomField = Application.AppBase.getProperty("bottomField");
			topBottomFont = Application.AppBase.getProperty("topBottomFont");
			rowFont = Application.AppBase.getProperty("rowFont");
			paddingTop = Application.AppBase.getProperty("paddingTop");
			paddingBottom = Application.AppBase.getProperty("paddingBottom");
		}
    }
}