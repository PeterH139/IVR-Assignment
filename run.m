% Constants
CONVEXITY_THRESH = 1.05;

MAX_OBJECTS = 2; % max at any one time

FRAME_HEIGHT = 480;
FRAME_WIDTH = 640;


% Initialisation
file_dir = 'data/1/'; % put here one of the folder locations with images;
filenames = dir([file_dir '*.jpg']);

median = getMedianFrame(file_dir,1);
frame = imread([file_dir filenames(1).name]);
figure(2); h1 = imshow(frame);
hold on;
prev_pos = plot(0,0);
kek_plot = plot(0,0);
hold off;
toDelete = 0;

previous_objects = [];
 
% Using motion blur at the moment. Also tried Gaussian.
blur = fspecial('motion');

top_height = zeros(200);
plotted_kek = zeros(2);
centroid_hist = zeros(1000,2,2);
% This is our main loop over each frame
for k = 250 : size(filenames,1)
    % read the frame
    current_frame = imread([file_dir filenames(k).name]);

    % perform background subtraction
    frame = subtractMedian(median, current_frame);
        
    % performs a blur over the image to smooth
    blured_frame = imfilter(frame,blur,'same');
    
    % make the frame black and white 
    binary_frame = makeBinaryFrame(blured_frame);
    
    % get the region information from the frame.
    % this also performs the 'erode' function to eliminate
    % small parts such as the cloth being hit.
    region_data = getRegionData(binary_frame);
       
    
    [n m] = size(region_data);
    centroid_list = [];
    isCircle = [];
    
    % Clear the list of objects detected in the current frame
    current_objects = [];
    
    if (toDelete)
        delete(prev_pos);
        delete(prev_cir);
        toDelete = 0;
    end
    
    if (n >= 1)
        % for each object detected
        for i = 1 : n
            % determine the average colour of the object
            avg_colour = getAverageNormalisedColour(region_data(i).PixelList, current_frame);
            % get the centroid of the object
            centroid = region_data(i).Centroid;
            % determine if it is a ball
            isBall = (region_data(i).ConvexArea/region_data(i).Area) <= CONVEXITY_THRESH;
            % Create a new object struct
            s = struct('Colour',avg_colour,'Position',centroid,'IsBall',isBall);
            % Add it to the objects detected in this frame
            current_objects = [current_objects;s];
            
            % LEGACY CODE
            % add the centroid to the list of centroids for that object
            centroid_list = [region_data(i).Centroid;centroid_list];
            
            % check if the object is a circle
            % can we do more than just convexity?
            convexity = region_data(i).ConvexArea/region_data(i).Area;
            isCircle = [(convexity <= CONVEXITY_THRESH);isCircle];
            
            % add the centroid to the historical list of centroids
            % for that object
            centroid_hist(k,:,i) = centroid;
        end
        
        % Match the current objects with the objects detected previously
        current_objects = matchObjects(current_objects, previous_objects);
        
        xs = centroid_list(:,1);
        ys = centroid_list(:,2);
        cxs = isCircle .* xs;
        cys = isCircle .* ys;
        
        % check for the top position of each object
        for i = 1 : n
            % if the current frame is higher
            if (FRAME_HEIGHT - centroid_hist(k,2,i) > FRAME_HEIGHT - top_height(i))
                % set the current frame to be highest
                top_height(i) = centroid_hist(k,2,1);
                
                % draw the new highest
                delete(kek_plot)
                hold on;
                    if (i <= 2)
                        kek_plot = plot(centroid_hist(k,1,i), centroid_hist(k,2,i), 'x');
                    end
                hold off;
            end
        end
                    
        hold on;
        prev_pos = plot(xs,ys,'o');
        prev_cir = plot(cxs,cys,'o','MarkerSize',50,'MarkerEdgeColor','g','LineWidth',3);
        hold off;
        toDelete = 1;
    else
        % Things specific to when there are no objects on screen go here
    end
    
    set(h1, 'CData', frame);
    drawnow('expose');  
    disp(['showing frame ' num2str(k)]);
    
    % Set the current object list to be the previous object list since we
    % are now finished with it
    previous_objects = current_objects;
end