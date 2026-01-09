function TEC = interpTECMap(TECMap,mapLat,dLon,userPos)
% Function to perform bilinear interpolation on the TEC map. UYser pos is
% in geocentric LLA
% Landon Boyd

lat = mapLat(2:end,1);
lon = -180:dLon:180;

% Interpolate
[X,Y] = meshgrid(lat,lon);
TEC = interp2(X,Y,TECMap',userPos(1),userPos(2),"linear",NaN);

end