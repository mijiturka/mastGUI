<%@ page import="java.io.File" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.io.FileFilter" %>

<%@ page import="java.io.IOException" %>

<%@ page import="java.util.Arrays" %>
<%@ page import="org.apache.commons.io.filefilter.DirectoryFileFilter" %>

<%!

private final String webappName = "dissie";
private final String gitFolderName = "githubprojects";
private final String allowedMimeType = "text/x-java";
private final String extensionOfInterest = ".java";

private String levelIdentation(int level) {
	String identation = "";
	for (int i=0; i<level; i++) {
		identation += "..";
	}
	return identation;
}

private boolean isFirstInProject(File file) {
	String[] siblings = file.getParentFile().list( DirectoryFileFilter.DIRECTORY );
	Arrays.sort(siblings); //needed?
	String firstDir = siblings[0];
	//ignore hidden folders (like .git)
	if (firstDir.startsWith(".")) firstDir = siblings[1];
	
	if (file.getName().equals(firstDir)) return true;
	return false;
}

//Produce html for this directory
private String dirHTML(File file, int level) {
	String html = levelIdentation(level) + "<b>" + file.getName() + "</b>";
	if (level == 0) {
		html =  "</div></div>" + 
				"<h1>" + html + "</h1>" +
				"<div class=\"projectFiles\">";
		//if (file.getParent == 
	}
	else {
	
		//This is the first directory in this project
		if (level == 1 && isFirstInProject(file)) {
				html = 	html +
					"<div class=\"dirFiles\">";
		}
		else {
		html = 	"</div>" + 
				html +
				"<div class=\"dirFiles\">";
		}
	}
	return html;
}

//Produce html for link to this file
private String fileHTML(File file, int level, String ratio) {
	String projectName = file.getPath().split(gitFolderName+"/")[1];
	projectName = projectName.split("/")[0];
	String filePath = file.getPath().split(projectName+"/")[1];
	
	//need full path here for when the request is to a .java
	return levelIdentation(level) + 
			"<a href=\"/" + webappName + "/editor.jsp/" + 
			projectName + 
			"/" + filePath + 
			"/" + ratio + "\">" + 
			file.getName() +
			"</a><br />";	
}

private String listFileTree(File dir, String curTree, int level, String ratio) throws IOException {
    File[] list = dir.listFiles();
    Arrays.sort(list);
    String newTree = "";
    for (File file : list) {
    	if (file.isDirectory()) {
    		if (!file.getName().startsWith(".git")) {
	    		newTree += dirHTML(file, level);
    			newTree += listFileTree(file, curTree, level+1, ratio);
//    			newTree += "</div>";
    		}
    	}
    	else {
    		String mimeType = Files.probeContentType(file.toPath());
        	if (mimeType.equals(allowedMimeType)) {
        		newTree += fileHTML(file, level, ratio);
        	}
    	}
    }
    //add subtree to tree only if it has code in it
    if (newTree.contains(extensionOfInterest)) {
		curTree = curTree + newTree;
	}
    return curTree;
}

%>

<%

String rootPath = "/" + gitFolderName;
String rootPathReal = request.getRealPath(rootPath);
File rootFile = new File(rootPathReal);
String rootTree = "";

String ratioStr = request.getParameter("ratio");
if (ratioStr == null || ratioStr.isEmpty()) {
	ratioStr = "50";
}

try {
		
		out.print("<div class=\"aux\"><div class=\"aux\">");		
		out.print(listFileTree(rootFile, rootTree, 0, ratioStr));
		//out.print("<div class=\"projectFiles\"><div class=\"dirFiles\"></div>What not</div><div class=\"dirFiles\">");
		out.print("</div></div>");
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}

%>

<br />
