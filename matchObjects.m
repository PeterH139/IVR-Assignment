function [ new_objects ] = matchObjects( current_objects, previous_objects )
%MATCHOBJECTS

% Find the objects in the current object list that match the objects in the
% previous list. Keep the same ordering as the previous list.

% Any new objects found are added at the end of the new list.

DIST_THRESH = 100;
COLOUR_THRESH = 100;
   
% Initialize all the previous objects to not be active;
for i = 1 : size(previous_objects)
    previous_objects(i).IsActive = 0;
end

new_objects = previous_objects;

% If we haven't seent any objects this frame, just ignore and move on.
if(size(current_objects) == 0)
    return;
end

% For each of the currently detected objects in the scene.
for i = 1 : size(current_objects,1)
    cur = current_objects(i);
    match_found = 0;
    
    % Try and find a match from each of the previous objects
    for j = 1 : size(previous_objects,1)
        prev = previous_objects(j);
        position_diff = cur.Position - prev.Position;
        colour_diff = cur.Colour - prev.Colour;
        % if the object is the same then
        if (hypot(position_diff(1),position_diff(2)) < DIST_THRESH && hypot(colour_diff(1),colour_diff(2)) < COLOUR_THRESH)
            % update the position
            new_objects(j) = cur;
            % check the max height
            new_objects(j).MaxHeight(2) = min([cur.Position(2) prev.MaxHeight(2)]);
            if (new_objects(j).MaxHeight(2) == prev.MaxHeight(2))
                new_objects(j).MaxHeight(1) = prev.MaxHeight(1);
            else
                new_objects(j).MaxHeight(1) = cur.Position(1);
            end
            
            % add the position to the history of positions
            new_objects(j).Positions = [prev.Positions ; new_objects(j).Position];
            
            match_found = 1;       
            break;
        end
    end
    
    % If we cant find a match, add at the end of the new objects list
    if (match_found == 0)
        new_objects = [new_objects; cur];
    end;
end

end

