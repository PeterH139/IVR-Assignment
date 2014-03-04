function [ binary_frame ] = makeBinaryFrame( frame )
%MAKEBINARYFRAME If a pixel value is above a certain threshold, make it
% white, otherwise make it black.

    THRESH = 25;  
    
    binary_frame(:,:,1) = ((frame(:,:,1) + frame(:,:,2) + frame(:,:,3)) / 3.0) > THRESH;
    binary_frame(:,:,2) = binary_frame(:,:,1);
    binary_frame(:,:,3) = binary_frame(:,:,1);
    
end

