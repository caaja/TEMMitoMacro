input = getDirectory("Input directory");
print("Input folder = " +input);
File.makeDirectory(input+File.separator+"Count Masks"+File.separator);

Dialog.create("Indicate Condition");
Dialog.addString("Experimental condition in this folder", "control or treatment?");
Dialog.show();
condition = Dialog.getString();
 
Dialog.create("File type");
Dialog.addString("File suffix: ", ".tif", 5);
Dialog.show();
suffix = Dialog.getString();

processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		//if(File.isDirectory(input + list[i]))
			//processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	open(input+File.separator+file+"");	
	title = getTitle();	
	print(title+ " is being processed.");

	//removes the suffix from the name of the file
	if (endsWith(title, suffix)){
	index2=lastIndexOf(title, suffix);
	image= substring(title, 0, index2);
	}
	
	//Process the images to increase contrast and remove BG
	run("Invert");
	run("Subtract Background...", "rolling=60");
	run("Subtract...", "value=100");
	run("Bandpass Filter...", "filter_large=60 filter_small=8 suppress=Vertical tolerance=5 autoscale saturate");

	//Threshold and make binary mask, fill in gaps in mask
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Dilate");
	run("Fill Holes");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	run("Close-");
	run("Erode");
	run("Erode");
	run("Erode");
	run("Erode");
	run("Open");
	rename("Mask");

	//Open up the corresponding ROIs file for the image.
	//Duplicate out each ROI from the mask as a new image. Analyse those particles.
	roiManager("open", input+"ROIs"+File.separator+"ROIs-"+image+".zip")
	run("Set Measurements...", "area perimeter fit shape feret's add redirect=None decimal=5");
	
	
	//Duplicate out each ROI from the mask as a new image. Analyse those particles. Generate count masks of those particles.
	n = roiManager("Count");
	for (i = 0; i < n; ++i) {
		m=i+1;
		selectWindow("Mask");
		roiManager("Select", i)
		//run("Duplicate...", "title=Mask-"+i"");
		run("Duplicate...", " ");
		selectWindow("Mask-"+m+"");
		//run("Analyze Particles...", "size=500-Infinity circularity=0.40-1.00 show=[Overlay Masks] display exclude");
 		run("Analyze Particles...", "size=600-Infinity show=[Count Masks] display exclude"); //measures particles >600 pixels - excludes remaining background
 		saveAs("Results", ""+input+File.separator+condition+"-Results.csv"); //saves the results table with all the measurements for each particle in each ROI for each file in the folder.
 		
	}
	wait(1000);
	
	//Closes the ROI windows from an image. Saves the new count masks as tiffs
	for (i = 0; i < n; ++i) {
		m=i+1;		
		selectWindow("Mask-"+m+"");
		run("Close"); 	
		selectWindow("Count Masks of Mask-"+m+"");
		run("3-3-2 RGB");
		saveAs("tiff", input+File.separator+"Count Masks"+File.separator+image+"-CountMask-"+m);
	}

	wait(1000);
	
	//clear and close the ROImanager and all open images
	roiManager("deselect");
	roiManager("delete");
	close("*"); 	
}

//This section calculates parameters for mitochondrial morphology measurments, based on the measurements put out in the Results table

awff = ff = ar = sum_a = a2 = len = 0;

for (i = 0; i < nResults; i++) { // for every particle in table
	a = getResult("Area", i); 
	p = getResult("Perim.", i); 
	ar = getResult("Major", i) / getResult("Minor", i); /* aspect ratio = length / width */
	ar_sum+= ar;
	sum_a += a;
	sum_a_sq += a*a; 
	ff = (p*p) / (4 * 3.14159265358979*a); // ff = p^2 / (4 * pi * a)
	//setResult("AspectRatio", i, ar);
	setResult("FormFactor", i, ff);
	ff_sum += ff;
	awff += (p * p) / (4 * 3.14159265358979 );
	}
		
//average and output
nParticles = nResults
sum_a /=nParticles
a2 = sum_a_sq/(sum_a * sum_a); 
awff /= sum_a;
ff_sum /= nParticles;
ar_sum /= nParticles;
	
print(condition+ " average measurements:" + "\t " + "nParticles" + "\t " + "Area" + "\t " + "Area2" + "\t " + "Area-WeightedFormFactor" + "\t " + "FormFactor" + "\t " + "AspectRatio");
print(condition+ " average measurements:" + "\t " + nParticles +"\t " + "\t " + sum_a +"\t " + "\t " + a2 +"\t " + "\t " + awff +"\t " + "\t " + ff_sum + "\t " + "\t " + ar_sum);

saveAs("Results", ""+input+File.separator+condition+"-Results with FF.csv"); //saves the results table with all the measurements for each particle in each ROI for each file in the folder.


//tidy up and confirm finished!
//run("Close"); 	//closes all image windows
close("Results");
close("ROI manager");
Dialog.create("Folder processing finished!");
	Dialog.addMessage("All the images in the folder for <"+condition+"> have been processed and analysed.");
	Dialog.show();


