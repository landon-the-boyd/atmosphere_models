function IPPCoords = calcIPP(userLLA,satAER,IPPAlt)
% This function calculates the location of the ionospheric pierce point 
% (IPP) given satellite elevation angles and user position. This
% formulation is taken from the GPS single frequency ionospheric correction
% algorithm
% INPUTS
%   userLLA - 1x3 vector of LLA in degrees, degrees, meters
%   satAER - nx3 matrix of AER in degrees, degrees, meters
%   IPPAlt - scalar of assumed IPP altitude in meters
% OUTPUTS
%   IPPCoords - nx3 matrix of geocentric IPP coordinates
% Landon Boyd

arguments
    userLLA (1,3) double
    satAER (:,3) double
    IPPAlt (1,1) double
end

% Convert to semicircles
E = rad2semicircles(deg2rad(satAER(:,2)));

% earth-centered angle
psi = (0.0137./(E + 0.11)) - 0.022;

% Lat of IPP - must be within bounds
IPPLat = rad2semicircles(deg2rad(userLLA(1))) + psi.*cosd(satAER(:,1));
lowerFloor = IPPLat < -0.416; % This is a latitude floor of 75 degrees
upperCeil = IPPLat > 0.416;
IPPLat(lowerFloor) = -0.416;
IPPLat(upperCeil) = 0.416;

% Lon of IPP
IPPLon = rad2semicircles(deg2rad(userLLA(2))) + (psi.*sind(satAER(:,1)))./cos(semicircles2rad(IPPLat));
IPPLLA = [IPPLat,IPPLon,IPPAlt.*ones(length(IPPLat),1)];

% Rotate IPP coordinates into geocentric
IPPCoords = geodetic2geocentric(IPPLLA);


end