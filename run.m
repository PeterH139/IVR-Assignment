% Constants
CONVEXITY_THRESH = 1.05;
ECCENTRICITY_THRESH = 1;

MAX_OBJECTS = 2; % max at any one time

FRAME_HEIGHT = 480;
FRAME_WIDTH = 640;


% Initialisation
file_dir = 'data/3/'; % put here one of the folder locations with images;
filenames = dir([file_dir '*.jpg']);

median = getMedianFrame(file_dir,1);
frame = imread([file_dir filenames(1).name]);
figure(2); h1 = imshow(frame);
hold on;
prev_pos = plot(0,0);
kek_plot = plot(0,0);
path_plot = plot(0,0);
hold off;
toDelete = 0;


previous_objects = [];
 
% Using motion blur at the moment. Also tried Gaussian.
blur = fspecial('motion');

top_height = zeros(200);
plotted_kek = zeros(2);
centroid_hist = zeros(1000,2,2);
% This is our main loop over each frame
for k = 1 : size(filenames,1)
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
    isCircle = [];
    
    % Clear the list of objects detected in the current frame
    current_objects = [];
    
   
    
    if (n >= 1)
        % for each object detected
        for i = 1 : n
            % determine the average colour of the object
            avg_colour = getAverageNormalisedColour(region_data(i).PixelList, current_frame);
            % get the centroid of the object
            centroid = region_data(i).Centroid;
            % determine if it is a ball
            isBall = ((region_data(i).ConvexArea/region_data(i).Area) <= CONVEXITY_THRESH) & (region_data(i).Eccentricity <= ECCENTRICITY_THRESH);
            % Create a new object struct
            s = struct('Colour',avg_colour,'Position',centroid,'IsBall',isBall,'IsActive',1,'MaxHeight',[0 500],'Positions',centroid);
            % Add it to the objects detected in this frame
            current_objects = [current_objects;s];
            
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
         
        % check for the top position of each object
        if (size(previous_objects,1) > 0)
            to_plot = [];
            has_changed = 0;
            for i = 1 : size(current_objects)
                cur = current_objects(i);
                if (cur.IsActive && cur.IsBall && length(previous_objects) >= i)
                    if (cur.MaxHeight(2) == previous_objects(i).MaxHeight(2))
            
                        to_plot = [to_plot;cur.MaxHeight];
                        has_changed = 1;
                        if(cur.MaxHeight(2) > previous_objects(i).Position(2) - 0.1)
                            %pause(3);
                        end
                    end
                end
            end
            if (has_changed)
                delete(kek_plot);
                hold on;
                kek_plot = plot(to_plot(:,1),to_plot(:,2),'x','MarkerSize',20,'MarkerEdgeColor','r','LineWidth',2);
                hold off;
            end
        end
        
        if (toDelete)
            delete(prev_pos);
            delete(prev_cir);
            delete(path_plot);
            toDelete = 0;
        end
        
        xs = [];
        ys = [];
        cxs = [];
        cys = [];
        xposs = [];
        yposs = [];
        for i = 1 : size(current_objects)
            cur = current_objects(i);
            disp(cur.IsActive);
            if (cur.IsActive == 1)
                % draw the paths
                [row col xpos] = find(cur.Positions(:,1));
                [row col ypos] = find(cur.Positions(:,2));
                
                xposs = [xposs; xpos];
                yposs = [yposs; ypos];
               
                xs = [xs;cur.Position(1)];
                ys = [ys;cur.Position(2)];
                if(cur.IsBall)
                    cxs = [cxs; cur.Position(1)];
                    cys = [cys; cur.Position(2)];
                end
            end
        end
                    
        hold on;
        prev_pos = plot(xs,ys,'o');
        prev_cir = plot(cxs,cys,'o','MarkerSize',50,'MarkerEdgeColor','g','LineWidth',3);
        path_plot = plot(xposs,yposs);
        hold off;
        toDelete = 1;
    else
        % Things specific to when there are no objects on screen go here
    end
    
    set(h1, 'CData', binary_frame);
    drawnow('expose');  
    disp(['showing frame ' num2str(k)]);
    %disp(num2str(current_objects(1).MaxHeight));
    
    % Set the current object list to be the previous object list since we
    % are now finished with it
    previous_objects = current_objects;
end