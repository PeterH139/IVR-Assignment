% Constants
CONVEXITY_THRESH = 1.05;

% Initialise
file_dir = 'data/4/'; % put here one of the folder locations with images;
filenames = dir([file_dir '*.jpg']);

median = getMedianFrame(file_dir,1);
frame = imread([file_dir filenames(1).name]);
figure(2); h1 = imshow(frame);
hold on;
prev_pos = plot(0,0);
kek_plot = plot(0,0);
hold off;
toDelete = 0;
blur = fspecial('gaussian',5,2);

top_kek = 0;
plotted_kek = zeros(2);
centroid_hist = zeros(1000,2,2);
% This is our main loop over each frame
for k = 250 : size(filenames,1)
    % read the frame
    current_frame = imread([file_dir filenames(k).name]);

    % perform background subtraction
    frame = subtractMedian(median, current_frame);
        
    % performs a gaussian blur over the image to smooth
    blured_frame = imfilter(frame,blur,'same');
    
    % make the frame black and white 
    binary_frame = makeBinaryFrame(blured_frame);
    
    %masked_frame = current_frame .* uint8(binary_frame);
    
    % get the region information from the frame.
    % this also performs the 'erode' function to eliminate
    % small parts such as the cloth being hit.
    region_data = getRegionData(binary_frame);
       
    [n m] = size(region_data);
    centroid_list = [];
    isCircle = [];
    
    if (toDelete)
        delete(prev_pos);
        delete(prev_cir);
        toDelete = 0;
    end
    
    if (n >= 1)
        for i = 1 : n
            centroid = region_data(i).Centroid;
            centroid_list = [region_data(i).Centroid;centroid_list];
            convexity = region_data(i).ConvexArea/region_data(i).Area;
            isCircle = [(convexity <= CONVEXITY_THRESH);isCircle];
            centroid_hist(k,:,i) = centroid;
        end
        
        xs = centroid_list(:,1);
        ys = centroid_list(:,2);
        cxs = isCircle .* xs;
        cys = isCircle .* ys;
        
        % check for the top position of the kek
        if (centroid_hist(k,2,1) < centroid_hist(k-1,2,1))
            top_kek = centroid_hist(k,2,1);
            delete(kek_plot)
            hold on;
            kek_plot = plot(centroid_hist(k,1,1), centroid_hist(k,2,1), 'x');
            hold off;
        end
                    
        hold on;
        prev_pos = plot(xs,ys,'o');
        prev_cir = plot(cxs,cys,'o','MarkerSize',50,'MarkerEdgeColor','g','LineWidth',3);
        hold off;
        toDelete = 1;
    end
    
    set(h1, 'CData', current_frame);
    drawnow('expose');  
    disp(['showing frame ' num2str(k)]);
end