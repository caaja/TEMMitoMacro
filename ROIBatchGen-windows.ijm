/*This macro asks for an input folder (directory), and file format (tif, jpg, etc). 
It opens each of the specified files in the folder, and asks you to selct Regions of interest (ROIs) around the mitochondria (or other areas of interest). 
The selected ROIs are saved as .zip files, to be used by the next macro
*/


input = getDirectory("Input directory"); //asks for folder where your image files are
print("Input folder for ROI generation = " +input);

File.makeDirectory(input+File.separator+"ROIs"+File.separator);
 
Dialog.create("File type");
Dialog.addString("File suffix: ", ".tif", 5);
Dialog.show();
suffix = Dialog.getString();

Dialog.create("Indicate Condition");
Dialog.addString("Experimental condition in this folder", "control or treatment?");
Dialog.show();
condition = Dialog.getString();

processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			//processFile(input, output, list[i]);
			processFile(input, list[i]);
	}
}

//function processFile(input, output, file) {
function processFile(input, file) {
	print("Processing: " + input + file);
	open(input+File.separator+file+"");	
	title = getTitle();

	//removes the suffix from the name of the file
	if (endsWith(title, suffix)){
	index2=lastIndexOf(title, suffix);
	image= substring(title, 0, index2);
	}
	
	//roiManager("delete");
	waitForUser("Select ROIs", "Select ROIs around mitochondria. \n Press t to save each one to the ROI Manager before slecting the next one. \n \n Press OK when you're done."); 
	n=roiManager("count");
	run("Select All");
	roiManager("Save", ""+input+File.separator+"ROIs"+File.separator+"ROIs-"+image+".zip");
	n=roiManager("count");
	print("ROIs selected and saved for "+title+" : "+n+".");
	roiManager("deselect");
	roiManager("delete");
	selectWindow(title);
	run("Close");
}


Dialog.create("Folder processing for ROIs finished!");
Dialog.addMessage("ROIs from all the images in the folder for <"+condition+"> have been generated and saved.");
Dialog.show();