    var drawing = false;
    var pauseDrawing = false;
    var x, y;
    var ev
    var initdata = false;
    var line = 0;
    var elesign = new Array();  
    var iphone, ipad, android;

    document.onmousemove = getMouseCoord;

    var minsign, maxsign;

    function printCanvas( elemcanvas, eimg, numsigs, btnsign ) {
        var canvas = document.getElementById(elemcanvas);
        var context = canvas.getContext('2d');
        context.font = "10px sans-serif";
        context.textAlign="left";
        var date = new Date();
    
        var txt = "This document was electronically signed on " + date.toString("MM/dd/yyyy hh:mm:ss a z");
        var sig;
        
        for (i=0; i< numsigs ; i++) {
            sig =  document.getElementById("divusername" + i).children[0].value;

            if (sig) 
                context.fillText(txt, 10, elesign[i] + 28);
        }
        
        var img = canvas.toDataURL("image/png");
        var eImg = document.getElementById(eimg);
        eImg.src = img;
        eImg.style.display = "block";  
        canvas.style.display="none";
        
        var divu;
        for (i=0; i<numsigs; i++ ) {   
            divu = document.getElementById("divusername"+i);
            divu.style.display="none";
        }  
        
        document.getElementById(btnsign).style.visibility="hidden";
    }
    
    function getMouseCoord(event) {
        ev = event || window.event;

    if (((iphone)||(ipad)||(android))&&(ev.touches[0])){ //iPad
        ev._x = ev.touches[0].clientX;
        ev._y = ev.touches[0].clientY;
    }
    else if (ev.layerX || ev.layerX == 0) { // Firefox
        ev._x = ev.layerX;
        ev._y = ev.layerY;
    }
    else if (ev.offsetX || ev.offsetX == 0) { // Opera
        ev._x = ev.offsetX;
        ev._y = ev.offsetY;
    }

	x = ev._x;
	y = ev._y;

    }
    
    function init(canvasElement, eimg) {
        
	canvas = document.getElementById(canvasElement);

	if (!canvas) return;

        iphone = ((window.navigator.userAgent.match('iPhone'))||(window.navigator.userAgent.match('iPod')))?true:false;
        ipad = (window.navigator.userAgent.match('iPad'))?true:false;
	android = (window.navigator.userAgent.match('droid'))?true:false;

        if(iphone||ipad||android){
            canvas.addEventListener('touchstart', function (e) { onTouchStart(e); });
            canvas.addEventListener('touchend', function (e) { onTouchEnd(e); });
            canvas.addEventListener('touchmove', function (e) { onTouchMove(e); });
        }
        else{
            canvas.addEventListener('mousedown', function (e) { onTouchStart(e); });
            canvas.addEventListener('mousemove', function (e) { onTouchMove(e); });
            canvas.addEventListener('mouseup',   function (e) { onTouchEnd(e); });
        }
   

        var totalheight = drawData();
        canvas.height = totalheight;
        
        // setting the height clears the content so we have to call draw data again
        drawData();

        document.getElementById(eimg).style.display="none";
    }

    function onTouchStart(e) {
        startDrawing(e.target.id);
        e.preventDefault();
    }

    function onTouchMove(e) {
	if (iphone||ipad||android)
		draw(e.targetTouches[0].pageX, e.targetTouches[0].pageY);
	else
        	draw(e.pageX, e.pageY);
	
        e.preventDefault();
    }

    function onTouchEnd(e) {
        stopDrawing();
//	e.preventDefault();
    }



    function startDrawing(canvasElement) {
        drawing = true;
        canvas = document.getElementById(canvasElement);
        context = canvas.getContext("2d");
        context.lineWidth = 2;
        context.lineCap = "round";
        context.beginPath();
        context.moveTo(x - canvas.offsetParent.offsetLeft - canvas.offsetParent.offsetParent.offsetLeft, y - canvas.offsetParent.offsetTop - canvas.offsetParent.offsetParent.offsetTop);

    }

    function stopDrawing( canvasElement) {
        drawing = false;
        canvas = document.getElementById(canvasElement);
        context = canvas.getContext("2d");
        context.closePath();
    }

    function draw(x, y, numsigs) {
    
        if (drawing) {


            var inRange = false;
            var newx, newy;
            
            
            inRange = (y - canvas.offsetParent.offsetTop - canvas.offsetParent.offsetParent.offsetTop) > (minsign - 80) 
                   && (y - canvas.offsetParent.offsetTop - canvas.offsetParent.offsetParent.offsetTop) < (maxsign - 2);
            
            if ( inRange )
            {

                newx = canvas.offsetParent.offsetLeft - canvas.offsetParent.offsetParent.offsetLeft;
                newy = canvas.offsetParent.offsetTop - canvas.offsetParent.offsetParent.offsetTop;

                if (pauseDrawing == true) {
                    pauseDrawing = false;
                    context.beginPath();
                    context.moveTo(x - newx , y - newy );
                }
                               
                context.lineTo(x - newx, y - newy);
                context.stroke();
            }

            else {
              
                pauseDrawing = true;
                context.closePath();
                }

        }  // for

       
       
    }

    function drawSignerNames( elemCanvas, numsigs) {

        var canvas = document.getElementById(elemCanvas);
        var width= canvas.width;
        var context = canvas.getContext('2d');
        context.font = "10px sans-serif";
        var date = new Date();
        var fontsize = 15;
        var sig = ""
        var txt = "";
                
        // clear out what's there already
        for (i = 0;i < numsigs; i++) {
            context.clearRect( 10, elesign[i]+8, width, fontsize);
            sig =  document.getElementById("divusername"+i).children[0].value;
            

            if ( sig ) {                       
                txt = "Print Name: " + sig;
                context.fillText(txt, 10, elesign[i]+fontsize);
            }
        }    
               
    }


    function clearCanvas(elemCanvas, eimg, numsigs, btnsign) {
      var canvas = document.getElementById( elemCanvas);
      var context = canvas.getContext('2d');

      context.clearRect(0, 0, context.canvas.width, context.canvas.height);
      
      init(elemCanvas, eimg);
  
      var eImg = document.getElementById(eimg);
      eImg.style.display = "none";
      canvas.style.display="block";
      
      var divu;
      for (i=0; i< numsigs; i++ ) {   
          divu = document.getElementById("divusername"+i);
          divu.style.display="block";
          divu.children[0].value="";
       }  
      
      document.getElementById(btnsign).style.visibility="visible";
      stopDrawing();
  }
  
  
     function wrapText(context, text, x, y, maxWidth, lineHeight) 
        {
            var words = text.split(" ");
            var line = "";
             for (var n = 0; n < words.length; n++) 
             {
                var testLine = line + words[n] + " ";
                var metrics = context.measureText(testLine);
                var testWidth = metrics.width;
                if (testWidth > maxWidth) {
                    context.fillText(line, x, y);
                    line = words[n] + " ";
                    y += lineHeight;
                }
                else {
                    line = testLine;
                }
            }
            context.fillText(line, x, y);
            
            return y;
        }
        
         function formatTime ( d )
        {
            var a_p = "";
            var curr_hour = d.getHours();
    
            if (curr_hour < 12)
               {
               a_p = "AM";
               }
            else
               {
               a_p = "PM";
               }
            if (curr_hour == 0)
               {
               curr_hour = 12;
               }
            if (curr_hour > 12)
               {
               curr_hour = curr_hour - 12;
               }

            var curr_min = d.getMinutes();
            curr_min = curr_min + "";
            
            if (curr_min.length == 1)
               {
               curr_min = "0" + curr_min;
               }
            return (curr_hour + ":" + curr_min + " " + a_p);
            
            
        }
