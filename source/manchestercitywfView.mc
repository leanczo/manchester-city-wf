import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;

class manchestercitywfView extends WatchUi.WatchFace {
	var logo;
	
    function initialize() {
        WatchFace.initialize();
        logo = WatchUi.loadResource(Rez.Drawables.Logo);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
   	function onShow() as Void 
   	{}

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
		var widthScreen = dc.getWidth();
		var heightScreen = dc.getHeight();
  		var widthCenter = widthScreen / 2;
  		
        // Logo
        var positionLogoX = (widthScreen / 2) -70;
        var positionLogoY = (heightScreen / 2) - 70;
        dc.drawBitmap(positionLogoX, positionLogoY, logo);
        
        // Time
       	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(widthCenter, (heightScreen / 12) * 9.5, Graphics.FONT_MEDIUM, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        
        //Date
     	var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
     	var dateString = today.day + " " + today.month;
     
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(widthCenter, (heightScreen / 12 * 1.1), Graphics.FONT_TINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
        
        var center = [dc.getWidth() / 2, dc.getHeight() / 2];
        var radius = dc.getWidth() / 2;
           
        var numLines;
	    var angleIncrement;
	    var hourIncrement;
	    if (!System.getDeviceSettings().is24Hour) {
	        numLines = 48; // 12 horas * 4 líneas por hora (la hora y 3 intervalos)
	        angleIncrement = 7.5;  // 360° / 48
	        hourIncrement = 4; // Cada cuarta línea es una hora en el formato de 12 horas
	    } else {
	        numLines = 24;
	        angleIncrement = 15;  // 360° / 24
	        hourIncrement = 1; // Cada línea es una hora en el formato de 24 horas
	    }
	    
	    var currentHour = System.getDeviceSettings().is24Hour ? hours : (hours % 12 == 0 ? 12 : hours % 12);
		var linesPast = System.getDeviceSettings().is24Hour ? currentHour : (currentHour * hourIncrement);
		
		// Agrega lógica para las líneas de minutos
		if (!System.getDeviceSettings().is24Hour) {
		    var linesPerQuarterHour = 1; // Dado que hay 4 líneas por hora en formato de 12 horas
		    var additionalLines = clockTime.min / 15; // Cada línea representa 15 minutos
		    linesPast += Math.floor(additionalLines) * linesPerQuarterHour;
		}

	    for (var i = 0; i < numLines; i++) {
	        var angle = (i * angleIncrement - 90);
	        var isHourLine = (i % hourIncrement == 0);
	
	        var offset = isHourLine ? 0 : 8; // Las líneas de horas completas serán 5 unidades más largas
	        var x1 = center[0] + (radius - 12 + offset) * Math.cos(angle * (Math.PI / 180));
	        var y1 = center[1] + (radius - 12 + offset) * Math.sin(angle * (Math.PI / 180));
	        var x2 = center[0] + radius * Math.cos(angle * (Math.PI / 180));
	        var y2 = center[1] + radius * Math.sin(angle * (Math.PI / 180));
	
	
	        if (i <= linesPast) {
	            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
	        } else {
	            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	        }
	        
			drawThickLine(dc, x1, y1, x2, y2, 2);  // 4 es el grosor de la línea que quieres
	    }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

	function drawThickLine(dc, x1, y1, x2, y2, thickness) {
	    // Encuentra la dirección de la línea
	    var dx = x2 - x1;
	    var dy = y2 - y1;
	
	    // Normaliza el vector de dirección
	    var mag = Math.sqrt(dx*dx + dy*dy);
	    dx /= mag;
	    dy /= mag;
	
	    // Encuentra el vector perpendicular (normal) a la línea
	    var px = -dy;
	    var py = dx;
	
	    // Calcula los puntos del polígono que representarán la línea gruesa
	    var halfThickness = thickness / 2.0;
	    var p1 = [x1 + px * halfThickness, y1 + py * halfThickness];
	    var p2 = [x1 - px * halfThickness, y1 - py * halfThickness];
	    var p3 = [x2 - px * halfThickness, y2 - py * halfThickness];
	    var p4 = [x2 + px * halfThickness, y2 + py * halfThickness];
	
	    // Llena el polígono
	    dc.fillPolygon([p1, p2, p3, p4]);
	}
}
