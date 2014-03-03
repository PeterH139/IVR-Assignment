THRESH = 120;

file_dir = 'data/1/'; % put here one of the folder locations with images;
filenames = dir([file_dir '*.jpg']);



median = getMedianFrame(file_dir,1);
frame = imread([file_dir filenames(1).name]);
figure(1); h1 = imshow(median);
hold on;
prev_pos = plot(0,0);
hold off;

% Read one frame at a time.
for k = 250 : size(filenames,1)
    current_frame = imread([file_dir filenames(k).name]);
    frame = subtractMedian(median, current_frame);
    binary_frame = makeBinaryFrame(frame);
    
    %masked_frame = current_frame .* uint8(binary_frame);
    
    region_data = getRegionData(binary_frame);
       
    [n m] = size(region_data);
    centroid = [];
    if (n >= 1)
        %delete(prev_pos);
        for i = 1 : n
            centroid_list = [region_data(i).Centroid;centroid];
        end
        xs = centroid_list(:,1);
        ys = centroid_list(:,2);
            
        hold on;
        prev_pos = plot(xs,ys,'o');
        hold off;
    end
    
    set(h1, 'CData', frame);
    drawnow('expose');
    
    disp(['showing frame ' num2str(k)]);
end