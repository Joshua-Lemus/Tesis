Read TesisTotal.pdf for a reference.

#-------------------------------------------------------------------------------------------------------
# Create altimetry data by mixing bathimetric data and topographic data from a digital elevation model
#-------------------------------------------------------------------------------------------------------
First, you must run grid_data-v2.py using the GEBCO dataset (gebco_965-89_090-155.csv)
Then, you must run again grid_data-v2.py, using the DEM dataset (dem501_wgs84-9226-8900_1360-1550.csv, here uploaded as a compressed file)

Next, run definirCosta.py, which defines the shoreline, you must change the variables "DEM_path", "Bat_path" and "costa_path"  to the path of the output files from previous steps and the output file you want to use for the shoreline definition

Finally, run interpolar-v2.py, canging the inputs to the previous output paths.

After creating the data, you need to cut the data to 3 different regions: a small grid near the shoreline and two bigger grids for simulating the waves dynamics. 
For this, you can use recortar.py, specifying the latitudes and longitudes for your cuts and the fraction by how much you want to coarse-grain the grid (bigger grids will need to be coarse-grained for computational reasons).



#-------------------------------------------------------------------------------------------------------
# Output
#-------------------------------------------------------------------------------------------------------
See 'out.mp4' for an example output
