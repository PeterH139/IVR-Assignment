function [ out ] = getRegionData( frame )
%GETREGIONDATA retrieves the centroid, convex hull and convex area details
% of the object.

    twod_binary_frame = squeeze(frame(:,:,1));
    
    twod_binary_frame = bwmorph(twod_binary_frame,'erode',2);
    twod_binary_frame = bwmorph(twod_binary_frame,'dilate',2);

    I = logical(twod_binary_frame);
    out = regionprops(I,'Centroid','Area','ConvexArea','PixelList','Eccentricity');

end

