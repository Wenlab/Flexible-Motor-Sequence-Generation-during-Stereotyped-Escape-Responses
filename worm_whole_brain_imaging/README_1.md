# Worm_whole_brain_imaging

This is the matlab code for whole worm calcium imaging data analysis. It will include automatic neuron identification, matching across different time points and proof reading. 

## Branch single_color

The code is used for the images that only have one kind of color.  

### How to use  

Run 
```MATLAB
img_Stack=import_micromanager_data_and_reshape();
```
The first dialog box needs you to select the target \*.tif file. 
The second dialog box needs you to input the frame index range to process (Start frame&End frame) and the number of frames in one z-scanned volume (number of z sections).  
The third dialog box needs you to input the range of frames you want to process in one volume. For example, you took 10 images in one volume and want to discard the first and the last frames of them, then just input 2 and 9 respectively.  
Now the \*.tif file is import into the workspace which named img_Stack.  

Run
```MATLAB
whole_brain_imaging(img_Stack)
```
Other parameters: 2. neuronal_position 3. neuronal_idx 4. ROIposition can be imported by input them in order following by img_Stack as necessary. 

Left click the mouse to label a neuron. The index is automatically selected.
Shift+left click the labelled neuron to canel the label.  
Right click the mouse to label a neuron, which index is got by a dialog box.
Use the key 'q' or 'w' and the mouse wheel to select different frames.

Use Image-Tracking or Image-Tracking all to automatically label the neuron. If you use Image-tracking all, you will use the neurons in the first volume as reference to label the following volumes. You can also use the FastTracking or FastTracking all funcitions, which process faster than the former one, but with less accuracy.  
You can also use ROI related functions to select a ROI. Similarly, ROI all selection use the ROI region in the first volume as reference to zone the following volumes.  

After the labelling is finished, use Plot-Calculate Signal to get the neuron intensity. It pops up a dialog box asking you to input a number of soma size. It is used as the radius to partite a region, whose mean of the intensity will be used as the neurons intensity.  

Finally, use File-Export to output the data to the workspace. Save it as you wish.
