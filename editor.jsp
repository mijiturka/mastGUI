<%
String project = request.getParameter("project");
String file = request.getParameter("file");
String ratioStr = request.getParameter("ratio");
if (ratioStr == null || ratioStr.isEmpty()) {
	ratioStr = "50";
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <title>Editor</title>
  
  <script src="js/ace.js" type="text/javascript" charset="utf-8"></script>
  <script>
  function showSliderValue() {
            var ratioInput = document.getElementById("ratio");
            var slider = document.getElementById("slider");
            ratioInput.value = slider.value;
        }
        
        //customised because Firefox has problems with HTML5 oninput
        function waitForSubmit(event) {
        	if(event.keyCode == 13) {
	        	changeRatio();
	        }
        }
        
        function changeRatio() {
        	var newRatio = document.getElementById("ratio").value;
        	if (newRatio < 0) { newRatio = 0; }
        	else if (newRatio > 100) { newRatio = 100; }
        	else if (!(newRatio >= 0 && newRatio <= 100)) { newRatio = 50; }
        	
        	var newURL = window.location.toString();
        	
        	//handle default file shown on request to editor.jsp
	        pageRequested = newURL.substring(newURL.lastIndexOf("/")+1);
        	defaultURL = "android-async-http/sample/src/main/java/com/loopj/android/http/sample/AsyncBackgroundThreadSample.java/"
	        if (pageRequested == "editor.jsp") { newURL = newURL + "/" + defaultURL; }	        
	        if (pageRequested == "editor.jsp/") { newURL = newURL + defaultURL; }
        	
        	//handle current URL ending in .java, .java/, and .java/50
        	else if (newURL.slice(-1) >= '0' && newURL.slice(-1) <= '9') {
	        	newURL = newURL.substring(0, newURL.lastIndexOf("/")+1);
	        }
	        else if (newURL.slice(-1) != '/') {
	        	newURL = newURL + '/';
	        }
	        
	        
	        
        	window.location = newURL + newRatio;
        }
  	window.onload = function() { showSliderValue(); }
  </script>

  <link rel="stylesheet" media="screen" href="css/editor.css" />
  <style type="text/css" media="screen">
    .ace_gutter-cell.ace_info {
    	background-image: url("<%= request.getContextPath() %>/thumbs_up.png");
	    background-position: 2px center;
	}
  </style>
  
</head>

<body>

<div id = "menu">
Compression ratio: 
<form onsubmit="return false;">
<input id="slider" type="range" min="0" max="100" step="1" value="<%= ratioStr %>" oninput="showSliderValue()" onchange="changeRatio()"/>
<input id="ratio" type="text" size="2" onkeypress="waitForSubmit(event)"/>
</form>
</div>


<div id = "browser">
<jsp:include page="browse.jsp" >
  <jsp:param name="ratio" value="${param.ratio}" />
</jsp:include>
</div>


<div id = "code">
<jsp:include page="fold.jsp" >
  <jsp:param name="project" value="${param.project}" />
  <jsp:param name="file" value="${param.file}" />
  <jsp:param name="ratio" value="${param.ratio}" />
</jsp:include>
</div>

</body>
</html>
