Read TesisTotal.pdf for a full reference on the files.


# Create altimetry data by mixing bathimetric data and topographic data from a digital elevation model

First, you must run grid_data-v2.py using the GEBCO dataset (gebco_965-89_090-155.csv)
Then, you must run again grid_data-v2.py, using the DEM dataset (dem501_wgs84-9226-8900_1360-1550.csv, here uploaded as a compressed file)

Next, run definirCosta.py, which defines the shoreline, you must change the variables "DEM_path", "Bat_path" and "costa_path"  to the path of the output files from previous steps and the output file you want to use for the shoreline definition

Finally, run interpolar-v2.py, canging the inputs to the previous output paths.

After creating the data, you need to cut the data to 3 different regions: a small grid near the shoreline and two bigger grids for simulating the waves dynamics. 
For this, you can use recortar.py, specifying the latitudes and longitudes for your cuts and the fraction by how much you want to coarse-grain the grid (bigger grids will need to be coarse-grained for computational reasons).



# Write a roadmap grid, where the evacuation will take place

To guide yourself on how the roadmap should look like (to make it as similar as possibl to the actual map), you will need to download some files from https://ideg.segeplan.gob.gt/geoserver/web/wicket/bookmarkable/org.geoserver.web.demo.MapPreviewPage?6 
Useful datasets are: Caminos,	Bosque y Uso de la Tierra, Cuerpos de Agua

You can also guide yourself through google maps.

The file WriteGrid.py writes the roadmap grid. You must edit a matrix where you specify:
- Whether the road is paved or not
- Whether the road is two ways or not
- The direction of the vehicle flow
- Where there are bridges (relevant as these can be blocked after an earthquake)
- Where there is dense or light vegetation
- Where there are beaches



# Run the tsunami evacuation

The main file is "simulacionTesis.nlogo". 
The rest of ".nlogo" files are for setting the rules for loading our roadmap grid (loadWorld-v2.nlogo), types of agents (multipleAgentsets.nlogo), estimating the optimal path to a meeting point (optimalPath.nlogo), etc. 


# Output

The output will be a percentage of survivors and a netlogo visual simulation. See 'out.mp4' for an example recording of the visual simulations
