function [ out ] = getRegionData( frame )
%GETREGIONDATA retrieves the centroid, convex hull and convex area details
% of the object.

    twod_binary_frame = squeeze(frame(:,:,1));
    
    twod_binary_frame = bwmorph(twod_binary_frame,'erode',1);

    I = logical(twod_binary_frame);
    out = regionprops(I,'Centroid','ConvexHull','ConvexArea');

end

