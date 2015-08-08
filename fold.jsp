<%@ page import="java.io.File" %>
<%@ page import="codesum.lm.*" %>
<%@ page import="codesum.lm.topicsum.GibbsSampler" %>
<%@ page import="codemining.util.serialization.Serializer" %>

<%
final String gitFolderName = "githubprojects";

String project = request.getParameter("project");
if (project == null || project.isEmpty()) {
	project = "android-async-http";
}

String file = request.getParameter("file");
if (file == null || file.isEmpty()) {
	file = "sample/src/main/java/com/loopj/android/http/sample/AsyncBackgroundThreadSample.java";
}

String ratioStr = request.getParameter("ratio");
if (ratioStr == null || ratioStr.isEmpty() || ratioStr == "null") {
	ratioStr = "50";
}
int ratio = Integer.parseInt(ratioStr);

ServletContext context = request.getSession().getServletContext();

String workingDir = context.getRealPath("/tmp") + "/";

String filePath = "/" + gitFolderName + "/" + project + "/" + file;
String filePathReal = context.getRealPath(filePath);
File fileToFold = new File(filePathReal);

String writePath = context.getRealPath("/folds.txt");
File fileToWriteTo = new File(writePath);

//calling MAST tool
java.util.ArrayList<Integer> folds = codesum.lm.tui.FoldSourceFile.foldSourceFile( workingDir, fileToFold, project, ratio, fileToWriteTo);

%>

<!-- Here in order to be inherited and overwrite ace's default style -->
<style type="text/css" media="screen">
.ace_gutter-cell.ace_info {
    	background-image: url("<%= request.getContextPath() %>/thumbs_up.png");
	    background-position: 2px center;
	}
</style>

<link rel="stylesheet" media="screen" href="css/editor.css" />
<script src="js/ace.js" type="text/javascript" charset="utf-8"></script>
<style type="text/css" media="screen">
    .ace_gutter-cell.ace_info {
    	background-image: url("<%= request.getContextPath() %>/thumbs_up.png");
	    background-position: 2px center;
	}
  </style>

<div id="editor"></div>
 
<script>
function populateEditor(url) {
    var xhr = new XMLHttpRequest();
    xhr.onload = function () {
    	//populate editor with code
        document.getElementById('editor').textContent = this.responseText;


		//set up ace   
		var editor = ace.edit("editor");   
   		//editor.setTheme("ace/theme/twilight");
    	editor.setReadOnly(true);
   		editor.getSession().setMode("ace/mode/java");
    
    
    	//set up feedback actions
    	annotations_array = new Array();    	
    	editor.on("guttermousedown", function(e){
    var target = e.domEvent.target;
    if (target.className.indexOf("ace_gutter-cell") == -1)
        return;
    //if (!editor.isFocused())
    //    return;
    if (e.clientX > 25 + target.getBoundingClientRect().left)
        return;

    //var row = e.getDocumentPosition().row;
   	toggleMenu(e.clientY);
    e.stop()
	})  
	
	function toggleMenu(rowPosition) {
		id = "vote-menu";
		
		//set vote menu location
	    var gutterWidth = editor.renderer.$gutterLayer.gutterWidth;
		document.getElementById(id).style.left = gutterWidth + "px";
		document.getElementById(id).style.top = rowPosition + "px";

		//toggle vote menu visibility
        var state = document.getElementById(id).style.display;
            if (state == 'block') {
                document.getElementById(id).style.display = 'none';
            } else {
                document.getElementById(id).style.display = 'block';
            }
        }
    	
    	
    	//fold and set feedback icons
    	window.setTimeout(function() {
    		<%
    		for(int i = 0; i < folds.size(); i+=2) { 
    			Integer start = folds.get(i) - 2;
    			Integer end = folds.get(i+1);
    			if(start+1 < end) {
    			%>		   		
		   			annotations_array.push({row: <%= start %>, column: 0, html:"Click to vote", type:"info"});
		     <% } %>
		   			editor.getSession().foldAll(<%= start %>, <%= end %>, 0);		   		
		<% } %>
		   	

    	editor.getSession().setAnnotations(annotations_array);
    	}, 100);
    	
	};
    xhr.open('GET', url);
    xhr.send();
}
//need full path here for when the request is to a .java
populateEditor('<%= request.getContextPath() + filePath %>');

</script>

<div id="vote-menu">
<a href="#"><img src="<%= request.getContextPath() %>/thumbs_up.png">Vote Up</a> <br />
<a href="#"><img src="<%= request.getContextPath() %>/thumbs_down.png">Vote Down</a>
</div>
