function interpolatedTECMap = interpTECMapTime(TECMap,mapEpochs,userTime)
% Function to linearly interpolate between epochs in the TEC map so that
% bilinear interpolation can then be used on user Lat/Lon

% Get time of next vertex and time of previous vertex
TPlus = min(find(userTime <= mapEpochs));
TMinus = max(find(userTime > mapEpochs));

if isempty(TPlus)
    TPlus = length(mapEpochs);
end
if isempty(TMinus)
    TMinus = 1;
end

% If we are past the bounds of time, set the TEC Map to the first one
if (TPlus == 1) && (TMinus == 1)

    interpolatedTECMap = TECMap(:,:,1);

elseif (TPlus == length(mapEpochs)) && (TMinus == length(mapEpochs))

    interpolatedTECMap = TECMap(:,:,end);

else

    dTVertex = seconds(mapEpochs(TPlus) - mapEpochs(TMinus));
    dT = seconds(userTime - mapEpochs(TMinus));

    % Interpolate map
    interpolatedTECMap = TECMap(:,:,TMinus) + (dT/dTVertex)*(TECMap(:,:,TPlus) - TECMap(:,:,TMinus));

end

end