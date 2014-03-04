function [ avg_colour ] = getAverageNormalisedColour( pixel_list, frame )
%GETAVERAGECOLOUR get the average normalized rgb colour for a region
%defined by pixel_list.

cumulative = [0 0 0];

n = size(pixel_list,1);

for i = 1 : n
    r = double(frame(pixel_list(i,2),pixel_list(i,1),1));
    g = double(frame(pixel_list(i,2),pixel_list(i,1),2));
    b = double(frame(pixel_list(i,2),pixel_list(i,1),3));
    cumulative = cumulative + [r g b];
end

avg_colour = cumulative / n;

avg_colour = avg_colour * 255 / sum(avg_colour);

end

