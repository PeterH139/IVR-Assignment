function [ output_frame ] = subtractMedian( median_frame, input_frame )
%SUBTRACTMEDIAN Subtracts the median frame from the input frame

    output_frame = uint8(median_frame - input_frame);

end