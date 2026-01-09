function geocentricLLA = geodetic2geocentric(geodeticLLA,refEllipsoid)
% Converts a set of geodetic LLA values to geocentric LLA values. Geodetic
% LLA must be in deg, deg, m
% Landon Boyd

arguments
    geodeticLLA (:,3) double
    refEllipsoid (1,1) referenceEllipsoid = wgs84Ellipsoid("meter")
end

e = refEllipsoid.Eccentricity;
f = refEllipsoid.Flattening;
a = refEllipsoid.SemimajorAxis;
e2 = f * (2 - f);

geocentricLLA = zeros(size(geodeticLLA));

for ii = 1:size(geodeticLLA,1)

    N = a / sqrt(1 - e2*sind(geodeticLLA(ii,1)));
    rho = (N + geodeticLLA(ii,3)) * cosd(geodeticLLA(ii,1));
    z = (N*(1 - e2) + geodeticLLA(ii,3))*sind(geodeticLLA(ii,1));

    geocentricLLA(ii,1) = atand(z/rho);
    geocentricLLA(ii,2) = geodeticLLA(ii,2);
    geocentricLLA(ii,3) = N - refEllipsoid.MeanRadius;

end


end