clear
close all
clc

% This script demonstrates use of the ionospheric and tropospheric models
% implemented in this package
% Landon Boyd
% Jan 9, 2026

addpath("src\");
tleData = fullfile("data/gps_05_11_24.tle");
ionexFile = fullfile("data/COD0OPSFIN_20241320000_01D_01H_GIM.INX");

tleStruct = tleread(tleData);

% Propagate satellites for 1 hour
startTime = tleStruct(1).Epoch;
endTime = startTime + hours(1);
timeVec = startTime:seconds(5):endTime;

[satPos,~] = propagateOrbit(timeVec,...
                            tleStruct,...
                            "OutputCoordinateFrame",...
                            "fixed-frame");


% User coordinates
userLLA = [32.606551, -85.481735, 200];
userECEF = lla2ecef(userLLA);

% Stuff for elevation mapping model. Frequency here is set to L1
e = 0.0818191908425;
f = 1575.42e6;
IPPAltitude = 350e3; % This is assumed in IPP location calculations
Re = 6378137 / sqrt(1 - e*e*sind(userLLA(1))*sind(userLLA(1))); % WGS84

% Read Ionospheric Map
% The map contains an ionospheric map at multiple epochs, it must first be
% interpolated to a time with interpTECMapTime() and then must be
% interpolated to a location with interpTECMap()
[ionMap,mapEpochs,mapLatitudes,dLon] = readionexfile(ionexFile);
ionMap = ionMap .* 0.1; % This factor is from TEC to TECU

[ionoError,tropError,inView] = deal(nan(length(timeVec),length(tleStruct)));

for ii = 1:length(timeVec)

    % This function is custom, see README
    satAER = ecef2aer2(squeeze(satPos(:,ii,:))',userLLA);
    E = rad2semicircles(deg2rad(satAER(:,2)));

    % Check in view satellites
    inView(ii,:) = satAER(:,1) >= 0;

    % Interpolate TEC Maps to this time
    currentMap = interpTECMapTime(ionMap,mapEpochs,timeVec(ii));

    % Calculate location of the IPP
    IPPGeocentric = calcIPP(userLLA,satAER,IPPAltitude);

    % VTEC at IPP Location
    VTEC = interpTECMap(currentMap,mapLatitudes,dLon,IPPGeocentric);

    % Satellite Obliquity Factor Calculation
    obliquity = sqrt(1 - ((Re/(Re + IPPAltitude))*cosd(satAER(:,2))).^2);
    STEC = 1e16 * VTEC .* (obliquity.^-1);

    % Satellite Delay Calculation
    ionoError(ii,:) = 40.3 .* STEC ./ (f^2);

    % Tropospheric calculations
    %---------------------------------------------------------------------%
    % I put this in here in case a day-night boundary is ever simulated
    dayOfYear = round(days(timeVec(ii) - dateshift(timeVec(ii),"start","year","current")));
    tropError(ii,:) = UNB3Model(dayOfYear,userLLA,satAER(:,2));
    %---------------------------------------------------------------------%

end

% Mask by elevation
ionoError(~inView) = nan;
tropError(~inView) = nan;

%% Plots
close all

% Jumps occur to do interpolation strategy
figure()
plot(timeVec,ionoError)

figure()
plot(timeVec,tropError)
