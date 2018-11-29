using Toybox.WatchUi;
using Toybox.Graphics;

class Laps5View extends WatchUi.DataField {
	private const MAX_LAPS = 5;
	private var mLaps;
	private var mLapCnt;
	private var mLastLapTime;
	private var mZones;

    function initialize() {
        DataField.initialize();
        mLaps = new [MAX_LAPS];
        mLapCnt = 0;
        mLastLapTime = 0;
        mZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
    }
    
    function onTimerLap() {
		var info = Activity.getActivityInfo();
		mLaps[mLapCnt % MAX_LAPS] = [info.timerTime - mLastLapTime, info.currentHeartRate];
		mLastLapTime = info.timerTime;
    	mLapCnt++;
    }
    
    function toMinSec(msValue) {
    	var mins = (msValue / 1000 / 60) % 60;
    	var secs = (msValue / 1000) % 60;    	
	    return Lang.format("$1$:$2$", [mins.format("%02d"), secs.format("%02d")]);
    }
    
    function onLayout(dc) {
    }

    function onUpdate(dc) {
    	var bigFont;
    	var topGap;
    	var bottomGap;
    	if (dc.getHeight() < 240) {
    		bigFont = Graphics.FONT_LARGE;
    		topGap = 4;
    		bottomGap = 8;
    	} else {
    		bigFont = Graphics.FONT_NUMBER_MEDIUM;
    		topGap = 8;
    		bottomGap = 13; 
    	}
		var bigFontHeight = dc.getFontHeight(bigFont);
    	var rowHeight = dc.getFontHeight(Graphics.FONT_SMALL);
    	var width = dc.getWidth();

	    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
	    dc.clear();
	    	    
	    // Draw the current lap time in the top
	    var info = Activity.getActivityInfo();
	    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_WHITE);
	    dc.drawText(width / 2, topGap, bigFont, toMinSec(info.timerTime - mLastLapTime), Graphics.TEXT_JUSTIFY_CENTER); 
	    var y = bigFontHeight + bottomGap;
	    
	    // Draw previous MAX_LAPS laps info
	    var totalTime = 0;
	    for (var i = 1; i <= MAX_LAPS; i++) {
			if (i > mLapCnt) {
				break;
			
			}
			var lap = mLaps[(mLapCnt - i) % MAX_LAPS];
			totalTime += lap[0]; 
			var hr = lap[1];
			if (hr == null) {
				hr = "--";
			}
			var lapNo = (mLapCnt - i + 1).format("%02d");
			var rowText = lapNo + "  " + toMinSec(lap[0]) + "  " + toMinSec(totalTime) + "  " + hr;
			if ((i % 2) == 0) {
				dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);
				dc.fillRectangle(0, y, width, rowHeight);
				dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			}
	    	dc.drawText(width / 2, y, Graphics.FONT_SMALL, rowText, Graphics.TEXT_JUSTIFY_CENTER);
	    	y += rowHeight;
	    }
	   	// Draw the current heart rate in the bottom
	   	var hr = info.currentHeartRate;
	   	var hrBgColor = Graphics.COLOR_LT_GRAY; // Default to Zone 1 and below
		if (hr == null) {
			hr = "--";
		} else if (hr > mZones[1] && hr <= mZones[2]) { // Zone 2
			hrBgColor = Graphics.COLOR_BLUE;
		} else if (hr > mZones[2] && hr <= mZones[3]) { // Zone 3
			hrBgColor = Graphics.COLOR_GREEN;
		} else if (hr > mZones[3] && hr <= mZones[4]) { // Zone 4
			hrBgColor = Graphics.COLOR_YELLOW;
		} else if (hr > mZones[4]){ // Zone 5 and higher
			hrBgColor = Graphics.COLOR_RED;
		}
	    dc.setColor(hrBgColor, hrBgColor);
	    y = dc.getHeight() - bigFontHeight - topGap;
	    dc.fillRectangle(0, y, width, bigFontHeight + bottomGap);
	    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	    dc.drawText(width / 2, y + 2, bigFont, hr, Graphics.TEXT_JUSTIFY_CENTER); 
    }
	
}
