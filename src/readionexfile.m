function [ionMap,mapEpochs,mapLatitudes,dLon] = readionexfile(ionfile)
% Borrowed from https://www.researchgate.net/publication/341453294_MATLAB_code_to_read_IONEX_files_of_Global_Ionosphere_Maps
% Adapted by Landon Boyd
% This code assumes that each entry in the TEC map is for all longitudes at
% a single latitude

str = fileread(ionfile);
ca1 = regexp(str, '(?<=START OF TEC MAP).+?(?=END OF TEC MAP)', 'match');
ca1 = ca1(1:end-1);

numEpochs = length(ca1);
ionMap = nan(71,73,numEpochs);
lat2ix  = @(lat) round((lat+87.5)/2.5)+1;
lon2ix  = @(lon) round((lon+180)/5.0)+1;

mapLatitudes = zeros(71,numEpochs);
mapEpochs = NaT(numEpochs,1,"TimeZone","UTC");
dLon = 5;

for ii = 1:numEpochs


    buf = regexp(ca1{ii}, '\n','split','once');
    buf = regexp(buf{2}, '\n', 'split','once');
    ca2 = regexp(buf{2}, 'LAT/LON1/LON2/DLON/H', 'split' );
    pos = ca2{1};

    % Reconstruct map time
    timeCell = split(buf{1});
    mapEpochs(ii) = datetime(str2double(timeCell{2}),...
                             str2double(timeCell{3}),...
                             str2double(timeCell{4}), ...
                             str2double(timeCell{5}),...
                             str2double(timeCell{6}),...
                             str2double(timeCell{7}),...
                             "TimeZone","UTC");



    for jj = 2:length(ca2)

        lat = textscan( pos,'%f%*[^\n]' );
        lat = lat{1};
        num = sscanf( ca2{jj}(1:end-60), '%f' );
        pos =  strtrim( ca2{jj}(end-60+1:end) );
        ionMap(lat2ix(lat),:,ii) = num;
        mapLatitudes(jj,ii) = lat;

    end


end

end