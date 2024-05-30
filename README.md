Primero, debes correr grid_data-v2, con datos de gebco
Luego, correr nuevamente grid_data-v2, pero con datos de dem

Luego, definirCosta, recordando cambiar los paths según los que se vayan a usar (los outputs de los pasos anteriores).

Por último, correr interpolar-v2, dando como input todos los outputs anteriores.

Posterior a tener el modelo ya armado, usar recortar.py, para sacar los recortes necesarios.
