using Toybox.WatchUi;
using Toybox.Graphics;

class Laps5View extends WatchUi.DataField {
	private const MAX_ROWS = 5;
	private var laps;
	private var lapCnt;
	private var lastLapTime;
	private var lastLapDistance;
	private var maxHr;
	private var maxCadence;
	private var avgHr;
	private var avgCadence;
	private var zones;
	private var settings;
	private var avgHrCnt;
	private var avgCadenceCnt;

    function initialize() {
        DataField.initialize();
        zones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        settings = new Settings();
        laps = new [MAX_ROWS];
        lapCnt = 0;
        lastLapTime = 0;
        lastLapDistance = 0;
    	maxHr = 0;
    	maxCadence = 0;
    	avgHr = null;
    	avgHrCnt = 0;
    	avgCadence = null;
    	avgCadenceCnt = 0;
    }
    
    function onTimerLap() {
		var info = Activity.getActivityInfo();
		laps[lapCnt % MAX_ROWS] = [info.timerTime - lastLapTime, getColumn4(info)];
		lastLapTime = info.timerTime;
		lastLapDistance = info.elapsedDistance;
    	lapCnt++;
    	maxHr = 0;
    	maxCadence = 0;
    	avgHr = null;
    	avgHrCnt = 0;
    	avgCadence = null;
    	avgCadenceCnt = 0;
    }
    
    function getColumn4(info) {
    	var column4 = null;
    	switch(settings.column4) {
    		case Settings.LAST_HR:
    			column4 = info.currentHeartRate;
    			break;
    		case Settings.MAX_HR:
    			column4 = maxHr;
    			break;
    		case Settings.AVERAGE_HR:
    			column4 = avgHr;
    			break;
    		case Settings.MAX_CADENCE:
    			column4 = maxCadence;
    			break;
    		case Settings.AVERAGE_CADENCE:
    			column4 = avgCadence;
    			break;
    		case Settings.LAP_DISTANCE:
    			if (info.elapsedDistance != null && lastLapDistance != null) {
    				column4 = info.elapsedDistance - lastLapDistance;
    				column4 = column4.toLong();
    			}
    			break;
    	}
    	return column4;
    }
    
    function onTimerStart() {
    	lastLapDistance = Activity.getActivityInfo().elapsedDistance;
    }
    
    function toMinSec(msValue) {
    	var mins = (msValue / 1000 / 60) % 60;
    	var secs = (msValue / 1000) % 60;    	
	    return Lang.format("$1$:$2$", [mins.format("%02d"), secs.format("%02d")]);
    }
    
    function onSettingsChanged() {
    	settings = new Settings();
    }
    
    function onLayout(dc) {
    }
    
    function compute(info) {
    	var currentHr = info.currentHeartRate;
    	if (currentHr != null) {
    		if (currentHr > maxHr) {
    			maxHr = currentHr;
			}
			if (avgHrCnt == 0) {
				avgHr = currentHr;
			} else {
				avgHr = (avgHr * avgHrCnt + currentHr) / (avgHrCnt + 1);
			}
			avgHrCnt++;
    	}
    	var currentCadence = info.currentCadence;
    	if (currentCadence != null) {
    		if (currentCadence > maxCadence) {
    			maxCadence = currentCadence;
			}
			if (avgCadenceCnt == 0) {
				avgCadence = currentCadence;
			} else {
				avgHr = (avgCadence * avgCadenceCnt + currentHr) / (avgCadenceCnt + 1);
			}
			avgCadenceCnt++;
    	}
    }

    function onUpdate(dc) {
	    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
	    dc.clear();

	    var info = Activity.getActivityInfo();	    	    
		drawTopField(dc, info);
		drawRows(dc, info);	    
	    drawBottomField(dc, info);
    }
    
    function drawTopField(dc, info) {
	    // Draw the current lap time in the top
	    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_WHITE);
	    dc.drawText(dc.getWidth() / 2, settings.paddingTop, settings.topBottomFont, toMinSec(info.timerTime - lastLapTime), Graphics.TEXT_JUSTIFY_CENTER); 
    }
    
    function drawRows(dc, info) {
	    // Draw previous MAX_ROWS laps info
	    var y = dc.getFontHeight(settings.topBottomFont) + settings.paddingBottom;    
    	var rowHeight = dc.getFontHeight(settings.rowFont);
    	var width = dc.getWidth();
	    var totalTime = 0;
	    for (var i = 1; i <= MAX_ROWS; i++) {
			if (i > lapCnt) {
				break;
			
			}
			var lap = laps[(lapCnt - i) % MAX_ROWS];
			totalTime += lap[0]; 
			var column4 = lap[1];
			if (column4 == null || column4 == 0) {
				column4 = "--";
			}
			var lapNo = (lapCnt - i + 1).format("%02d");
			var rowText = lapNo + "  " + toMinSec(lap[0]) + "  " + toMinSec(totalTime) + "  " + column4;
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
    }
    
    function drawBottomField(dc, info) {
    	var val = null;
	    var bottomBgColor = Graphics.COLOR_WHITE;
	    switch (settings.bottomField) {
	    	case Settings.CURRENT_CADENCE:
	    		val = info.currentCadence;
	    		bottomBgColor = getColorByCadence(val);
	    		break;
	    	case Settings.CURRENT_DISTANCE:
	    		val = info.elapsedDistance;
	    		if (val != null) {
	    			if (lastLapDistance != null) {
	    				val -= lastLapDistance;
	    			}
	    			val = val.toLong();
	    		}
	    		break;
	    	default:
	    		val = info.currentHeartRate;
	    		bottomBgColor = getColorByHr(val);
	    		break;
	    }
		if (val == null || val == 0) {
			val = "--";
		}

	    var y = dc.getHeight() - dc.getFontHeight(settings.topBottomFont) - settings.paddingTop;
	    dc.setColor(bottomBgColor, bottomBgColor);
	    dc.fillRectangle(0, y, dc.getWidth(), dc.getHeight() - y);

	    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	    dc.drawText(dc.getWidth() / 2, y + 2, settings.topBottomFont, val, Graphics.TEXT_JUSTIFY_CENTER); 
    }
    
    function getColorByCadence(cadence) {
    	if (cadence == null) {
    		return Graphics.COLOR_LT_GRAY;
    	} else if (cadence >= 180) {
			return Graphics.COLOR_GREEN;
		} else if (cadence >= 170 && cadence < 180) {
			return Graphics.COLOR_BLUE;
		} else if (cadence >= 160 && cadence < 170) {
			return Graphics.COLOR_YELLOW;
		} else if (cadence > 100 && cadence < 160){
			return Graphics.COLOR_RED;
		}
		return Graphics.COLOR_LT_GRAY;
    }	
    
    function getColorByHr(hr) {
    	if (hr == null) {
    		return Graphics.COLOR_LT_GRAY;
    	} else if (hr > zones[1] && hr <= zones[2]) { // Zone 2
			return Graphics.COLOR_BLUE;
		} else if (hr > zones[2] && hr <= zones[3]) { // Zone 3
			return Graphics.COLOR_GREEN;
		} else if (hr > zones[3] && hr <= zones[4]) { // Zone 4
			return Graphics.COLOR_YELLOW;
		} else if (hr > zones[4]){ // Zone 5 and higher
			return Graphics.COLOR_RED;
		}
		return Graphics.COLOR_LT_GRAY; // Default to Zone 1 and below
    }	
}
