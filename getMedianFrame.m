function [ frame ] = getMedianFrame( file_dir, start_frame)

    filenames = dir([file_dir '*.jpg']);

    frame = imread([file_dir filenames(1).name]);
    [x y z] = size(frame);
    frames = zeros(x,y,z,5);
    
    % Read one frame at a time.
    for k = 1 : 5
        frame = imread([file_dir filenames(k+start_frame-1).name]);
        frames(:,:,:,k) = frame(:,:,:);
    end
   
    frame = uint8(median(frames,4));
        
end

