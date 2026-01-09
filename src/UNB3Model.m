function tropoDelay = UNB3Model(dayOfYear,userLLA,emitterEl)
% Implementation of the UNB3 tropospheric delay model in MATLAB.
% https://gssc.esa.int/navipedia/index.php/Tropospheric_Delay#cite_note-4
% INPUTS
%   dayOfYear - scalar of days since January 1
%   userLLA - 1x3 vector of user LLA in degrees, degrees, meters
%   emitterEl - nx1 vector of satellite elevation angles from the user
% OUTPUTS
%   tropoDelay - nx3 vector of tropospheric delays in meters
% Landon Boyd

arguments
    dayOfYear (1,1) double
    userLLA (1,3) double
    emitterEl (:,1) double
end

% Interpolate model parameters from table
[avgParams,deltaParams] = returnTropoParams(abs(userLLA(1)));

% Latitude check
if userLLA(1) >= 0
    DMin = 28;
else
    DMin = 211;
end

% Calculate all parameters
zeta = avgParams + deltaParams.*cos((2*pi*dayOfYear - DMin)/365.25);

% Vertial delays
T0Dry = (10^-6)*77.604*287.054*zeta(1)/9.784;
T0Wet = ((10^-6)*382000*287.054/((zeta(5)+1)*9.784 - zeta(4)*287.054))*(zeta(3)/zeta(2));

% Adjust for height
TDry = ((1 - (zeta(4)*userLLA(3))/zeta(2))^(9.784/(287.054*zeta(4))))*T0Dry;
TWet = ((1 - (zeta(4)*userLLA(3))/zeta(2))^((((zeta(5)+1)*9.784)/(287.054*zeta(4)))-1))*T0Wet;

% Obliquity factors
M = 1.001./sqrt(0.002001 + sind(emitterEl.*sind(emitterEl)));

tropoDelay = (TDry + TWet).*M;

end

function [avgParams,deltaParams] = returnTropoParams(lat)

tableLat = [15 30 45 60 75];

avgTable = [1013.25 299.65 26.31 6.30e-3 2.77;...
            1017.25 294.15 21.79 6.05e-3 3.15;...
            1015.75 283.15 11.66 5.58e-3 2.57;...
            1011.75 272.15 06.78 5.39e-3 1.81;...
            1013.00 263.65 04.11 4.53e-3 1.55];

deltaTable = [0.00 00.00 0.00 0.00e-3 0.00;...
             -3.75 07.00 8.85 0.25e-3 0.33;...
             -2.25 11.00 7.24 0.32e-3 0.46;...
             -1.75 15.00 5.36 0.81e-3 0.74;...
             -0.50 14.50 3.39 0.62e-3 0.30];


avgInterpolant = griddedInterpolant(tableLat,avgTable,"linear","nearest");
deltaInterpolant = griddedInterpolant(tableLat,deltaTable,"linear","nearest");

avgParams = avgInterpolant(lat);
deltaParams = deltaInterpolant(lat);

end