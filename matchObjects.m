function [ new_objects ] = matchObjects( current_objects, previous_objects )
%MATCHOBJECTS

% Find the objects in the current object list that match the objects in the
% previous list. Keep the same ordering as the previous list.

% Any new objects found are added at the end of the new list.

DIST_THRESH = 10;
COLOUR_THRESH = 10;

new_objects = previous_objects;

% For each of the currently detected objects in the scene.
for i = 1 : size(current_objects,1)
    cur = current_objects(i);
    match_found = 0;
    
    % Try and find a match from each of the previous objects
    for j = 1 : size(previous_objects,1)
        prev = previous_objects(j);
        position_diff = cur.Position - prev.Position;
        colour_diff = cur.Colour - prev.Colour;
        if (hypot(position_diff(1),position_diff(2)) < DIST_THRESH && hypot(colour_diff(1),colour_diff(2)) < COLOUR_THRESH)
            new_objects(j) = current_objects(i);
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

