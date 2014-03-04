
% Initialise
file_dir = 'data/1/'; % put here one of the folder locations with images;
filenames = dir([file_dir '*.jpg']);

median = getMedianFrame(file_dir,1);
frame = imread([file_dir filenames(1).name]);
figure(2); h1 = imshow(frame);
hold on;
prev_pos = plot(0,0);
hold off;
toDelete = 0;
blur = fspecial('gaussian',5);


% This is our main loop over each frame
for k = 250 : size(filenames,1)
    % read the frame
    current_frame = imread([file_dir filenames(k).name]);

    % perform background subtraction
    frame = subtractMedian(median, current_frame);
        
    % performs a gaussian blur over the image to smooth
    output_frame = imfilter(frame,blur,'same');
    
    % make the frame black and white 
    binary_frame = makeBinaryFrame(frame);
    
    %masked_frame = current_frame .* uint8(binary_frame);
    
    % get the region information from the frame.
    % this also performs the 'erode' function to eliminate
    % small parts such as the cloth being hit.
    region_data = getRegionData(binary_frame);
       
    [n m] = size(region_data);
    centroid_list = [];
    
    if (toDelete)
        delete(prev_pos);
        toDelete = 0;
    end
    
    if (n >= 1)
        for i = 1 : n
            centroid_list = [region_data(i).Centroid;centroid_list];
        end
        xs = centroid_list(:,1);
        ys = centroid_list(:,2);
            
        hold on;
        prev_pos = plot(xs,ys,'o');
        hold off;
        toDelete = 1;
    end
    
    set(h1, 'CData', frame);

    drawnow('expose');
    
    disp(['showing frame ' num2str(k)]);
end