%-*- mode: octave -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                %
%                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
% This script writes a grid in MOST grid format
%
%
disp("Octave>> Acabo de abrir el archivo"); %% Read about octave's function files and script files. By starting with this command, octave turns this file to a script file. A preferable solution (according to this thread:https://stackoverflow.com/questions/54013267/run-octave-script-file-containing-a-function-definition) is to turn this to a function file, but I preferred this because I didn't quite understand the discussion around Matlab compatibility of Octave scripts, and this one seemed to be the Matlab-compatible solution.

function errString = WriteGrid(lons,lats,bath,filename)


fid=fopen(filename,'w');      % The result will be written to fid
if fid == -1
    fprintf('Cant write to file "%s"', filename);
    return
end

disp(['writing MOST grid file: ' filename])

lats=lats(:); % force a column vector
if (lats(2)>lats(1)) % lats should decrease
    fprintf('Latitude increasing, flipping up/down!\n');
    lats=flipud(lats);
    ## bath=flipud(bath); %lats increase because unique() sorts them. Bath has the right indices 
end

nx=length(lons);
ny=length(lats);

#El original tenia los espacios
#fprintf(fid,'     %d %d\n',nx,ny);
#fprintf(fid,'  %2.6f\n',lons);
#fprintf(fid,'  %2.6f\n',lats);
fprintf(fid,' %d %d\n',nx,ny);
fprintf(fid,'%2.16f\n',lons);
fprintf(fid,'%2.16f\n',lats);



#Cambie esto para prueba. El original es el de size(bath,2)
#fprintf(fid,[repmat(' %0.2f',1,size(bath,2)),'\n'],bath');
fprintf(fid,[repmat(' %0.2f',1,nx),'\n'],-bath');

% dont do this... use matrix form, above
%for j=ny:-1:1
%    for i=1:nx
%        fprintf(fid,' %2.4f',bath(j,i));
%    end
%    fprintf(fid,'\n');
%end

fprintf('Done writing MOST grid.\n');

fclose(fid);

errString = 'none';
endfunction

%disp("Octave>> Empezando");
%Write data to a matrix
file = fopen('limpio_toy_dem_905-895_130-140.csv', 'r'); %This is the input file
A = fscanf(file, '%f %f %f', [3 Inf]);

%Extract rows of that matrix
#El unique() lo tengo para prueba. Creo que el original no lo tenía
lons = unique( A([1],:) );
lats = unique( A([2],:) );
bath = A([3],:);
## disp(lons);
disp("lat(1):");
disp(lats(1));
disp("lat(2):");
disp(lats(2));
disp("bath(3):");
disp(bath(3));

#Execute the function
filename = 'Most_prueba.most';
WriteGrid(lons,lats,bath,filename);
