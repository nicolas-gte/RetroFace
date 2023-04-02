import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Position;

class RetroFaceView extends WatchUi.WatchFace {

    var isAwake = true;
    var digitalFont;
    var timeDrawableSec;
    var timeDrawableNoSec;
    var screenSize;
    var hrValue;
    var globe_grid;

    function initialize() {

        WatchFace.initialize();
        globe_grid = WatchUi.loadResource(Rez.Drawables.globeBitmap);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        digitalFont = WatchUi.loadResource(Rez.Fonts.digitalFont);
        screenSize = dc.getWidth();        
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        //Get current time
        var clockTime = System.getClockTime();
        
        /*var loc = Position.Info.position;
        var utcValue;
        if(loc!=null){
            utcValue = Gregorian.localMoment(loc ,Time.now());
            System.println("UTC "+utcValue.value());
        }*/
        

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();    
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(1); 
        RetroFaceView.drawSlantedSeparator(dc, 0, adaptPx(50), adaptPx(24), adaptPx(90), adaptPx(70), 3);
        RetroFaceView.drawSlantedSeparator(dc, 0, adaptPx(117), adaptPx(20), adaptPx(50), adaptPx(115), 3);
        RetroFaceView.drawTexturedRect(dc, 0, 0, adaptPx(190), adaptPx(74), 0.6, false);
        RetroFaceView.drawTexturedRect(dc, 0, adaptPx(115), adaptPx(190), adaptPx(190), 0.6, false);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillPolygon([[0,adaptPx(54)],
                        [adaptPx(89),adaptPx(54)],
                        [adaptPx(90+23),adaptPx(54+24)],
                        [adaptPx(175),adaptPx(78)],
                        [adaptPx(175),adaptPx(78+58)],
                        [adaptPx(175-103),adaptPx(78+58)],
                        [adaptPx(175-103-20),adaptPx(78+58-20)],
                        [0,adaptPx(78+58-20)]]);
        RetroFaceView.drawParallelsPlanet(dc, adaptPx(144), adaptPx(31), adaptPx(30), false);

        // Day month year textbox
        RetroFaceView.textBox(dc, adaptPx(71), adaptPx(148), adaptPx(84), adaptPx(18), fullCustomDate(), true);

        /*
        var utcOffset = System.ClockTime.timeZoneOffset==null ? 0 : Math.floor(System.ClockTime.timeZoneOffset/3600);        
        RetroFaceView.textBox(dc, adaptPx(5), adaptPx(53), adaptPx(45), adaptPx(18), "UTC "+utcOffset, false);*/

        //Steps information
        var steps = ActivityMonitor.getInfo().steps;
        var stepGoal = ActivityMonitor.getInfo().stepGoal;
        var stepGoalAchieved = steps>=stepGoal;
        var stepAchievePercent = steps.toFloat()/stepGoal.toFloat();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(Math.round(screenSize*0.28), 116, Graphics.FONT_SYSTEM_XTINY, steps.toString(), Graphics.TEXT_JUSTIFY_RIGHT); // Step number displayed
        //Steps graph
        var startX = adaptPx(10);
        var startY = adaptPx(136);
        var height = adaptPx(5);
        var width = adaptPx(50);
        var margin = adaptPx(2);
        var numOfBars = 5.0;
        var fixedX = startX+width;

        for(var i=0;i<numOfBars;i++){            
            if(!stepGoalAchieved && (((numOfBars-i)/numOfBars) > stepAchievePercent)){
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.fillRoundedRectangle(startX, startY, width, height, 1);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(startX, startY, width, height, 1);
            }
            else{
                dc.fillRoundedRectangle(startX, startY, width, height, 1);
            }         
            width -=5;
            startX = fixedX-width;
            startY += height + margin;   
            
        }

        //Display heart rate
        //Draw fill shape and draw outline
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillPolygon([
            [adaptPx(40),adaptPx(5)],
            [adaptPx(110),adaptPx(5)],
            [adaptPx(110),adaptPx(25)],
            [adaptPx(50),adaptPx(25)]]
        );
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawPolygon(dc,[
            [adaptPx(42),adaptPx(6)],
            [adaptPx(108),adaptPx(6)],
            [adaptPx(108),adaptPx(24)],
            [adaptPx(52),adaptPx(24)]]
        );
        computeActivityInfo(Activity.getActivityInfo());
        var hrString = "HR "+hrValue.format("%03d");
        dc.drawText(adaptPx(50), adaptPx(2), Graphics.FONT_SMALL, hrString, Graphics.TEXT_JUSTIFY_LEFT);

        //Battery information
        var batteryLevel = Math.floor(System.getSystemStats().batteryInDays).format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(adaptPx(23),adaptPx(25), Graphics.FONT_SYSTEM_TINY, batteryLevel+"d", Graphics.TEXT_JUSTIFY_LEFT);
        //Battery information field
        var battPolyHeight = adaptPx(10);
        var battPolyInitialWidth = adaptPx(47);
        var polyStartX = adaptPx(54);
        var polyStartY = adaptPx(33);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([ // Background
            [polyStartX, polyStartY],
            [polyStartX+battPolyInitialWidth, polyStartY],
            [polyStartX+battPolyInitialWidth, polyStartY+battPolyHeight],
            [polyStartX+Math.round(battPolyHeight/2), polyStartY+battPolyHeight]
        ]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);
        drawPolygon(dc,[ // Outline
            [polyStartX, polyStartY],
            [polyStartX+battPolyInitialWidth, polyStartY],
            [polyStartX+battPolyInitialWidth, polyStartY+battPolyHeight],
            [polyStartX+Math.round(battPolyHeight/2), polyStartY+battPolyHeight]
        ]);
        var partialFill = Math.round(battPolyInitialWidth*System.getSystemStats().battery/100);
        polyStartX = polyStartX+battPolyInitialWidth-partialFill;
        dc.fillPolygon([ // Fill
            [polyStartX, polyStartY],
            [polyStartX+partialFill, polyStartY],
            [polyStartX+partialFill, polyStartY+battPolyHeight],
            [polyStartX+Math.round(battPolyHeight/2), polyStartY+battPolyHeight]
        ]);
        
        // Show the current time
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        var timeString = null;
        var timePlacement = null;

        if(isAwake) {            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(adaptPx(58), adaptPx(72), digitalFont, clockTime.hour+":", Graphics.TEXT_JUSTIFY_RIGHT);//hours
            dc.drawText(adaptPx(115), adaptPx(72), digitalFont, clockTime.min.format("%02d")+":", Graphics.TEXT_JUSTIFY_RIGHT);//minutes
            dc.drawText(adaptPx(165), adaptPx(72), digitalFont, clockTime.sec.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT);//secondes
        }
        else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(adaptPx(80), adaptPx(72), digitalFont, clockTime.hour+":", Graphics.TEXT_JUSTIFY_RIGHT);//hours
            dc.drawText(adaptPx(130), adaptPx(72), digitalFont, clockTime.min.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT);//minutes
        } 
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isAwake = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isAwake = false;
    }

    function drawSlantedSeparator(dc as Dc, startX as Number, startY as Number, descente as Number, widthPreDecline as Number, widthPostDecline as Number, interLineDist as Number) as Void{
        dc.drawLine(startX, startY, widthPreDecline, startY);
        dc.drawLine(startX, startY+interLineDist, widthPreDecline, startY+interLineDist);        
        dc.drawLine(widthPreDecline, startY,widthPreDecline+descente ,startY+descente);
        dc.drawLine(widthPreDecline, startY+interLineDist+1,widthPreDecline+descente ,startY+descente+interLineDist+1);
        dc.drawLine(widthPreDecline+descente ,startY+descente, widthPreDecline+descente+widthPostDecline ,startY+descente);
        dc.drawLine(widthPreDecline+descente ,startY+descente+interLineDist, widthPreDecline+descente+widthPostDecline ,startY+descente+interLineDist);
    }

    function drawTexturedRect(dc as Dc, x as Number, y as Number, width as Number, height as Number, density as Float, straight as Boolean) as Void{
        /*
        Function that draws a rectangle white with pixels, at a density (best in range from 0.1 to 0.9) of pixels defined in the parameters
        */
        var offset;
        density = Math.round(10*(1-density));
        if(density<2){density=2;}
        for(var i=x;i<x+width;i+=density){
            if(!straight && i.toLong()%2==0){
                offset = Math.round(density/2);                
                }
            else{offset=0;}
            for(var j=y+offset;j<y+height;j+=density){
                dc.drawPoint(i, j);
            }
        }
    }
    
    function drawParallelsPlanet(dc as Dc, centerX as Integer, centerY as Integer, radius as Integer, light as Boolean) as Void{
        var mainColor = Graphics.COLOR_BLACK;
        var secondColor = Graphics.COLOR_WHITE;
        if(light){
            mainColor = Graphics.COLOR_WHITE;
            secondColor = Graphics.COLOR_BLACK; 
        }

        dc.setColor(mainColor, mainColor);
        dc.fillCircle(centerX, centerY, radius); // Planet's background circle
        dc.setColor(secondColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawBitmap(adaptPx(112), adaptPx(0), globe_grid);
    }

    function adaptPx(num as Number) as Integer{
        /*Function that adapts an inputed number to the the watchface's width*/
        return Math.round(screenSize*(num/176.0));
    }
    function textBox(dc as Dc, posX as Integer, posY as Integer, width as Integer, height as Integer, text as String, light as Boolean) as Void{
        var mainColor = Graphics.COLOR_BLACK;
        var secondColor = Graphics.COLOR_WHITE;
        if(light){
            mainColor = Graphics.COLOR_WHITE;
            secondColor = Graphics.COLOR_BLACK; 
        }
        dc.setColor(mainColor, mainColor);
        dc.fillRectangle(posX, posY, width, height);
        dc.setColor(secondColor, secondColor);
        dc.setPenWidth(1); 
        dc.drawRectangle(posX+1, posY+1, width-2, height-2);
        dc.setColor(secondColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(posX+1, posY-3, Graphics.FONT_SYSTEM_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);

    }
    function fullCustomDate() as String{
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        return Lang.format("$1$ $2$.$3$ $4$", [today.month.substring(0,2), today.day_of_week.substring(0,2), today.day, today.year.toString().substring(2,4)]);        
    }

    function drawPolygon(dc as Dc, points as Array<Array<Number>>) as Void{
        var nextIndex;
        for(var i=0; i<points.size(); i++){
            nextIndex = Math.round(((i+1)%points.size())) as Number;
            dc.drawLine(points[i][0],points[i][1],points[nextIndex][0], points[nextIndex][1]);
        }
    }

    function computeActivityInfo(info) {
    if (info has :currentHeartRate) {
        if (info.currentHeartRate != null) {
            hrValue = info.currentHeartRate;
        } else {
            hrValue = 0.0f;
        }
    }
}
}
