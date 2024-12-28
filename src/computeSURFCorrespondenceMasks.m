function [Mask1, Mask2] = computeSURFCorrespondenceMasks(Size1, MatchedPoints1, Size2, MatchedPoints2)
% Computes the correspondence masks for each image based on their SURFPoints

    Mask1 = false(Size1(1:2));
    Mask2 = false(Size2(1:2));

    for i = 1:size(MatchedPoints1)
       Center1 = MatchedPoints1(i).Location;
       Center2 = MatchedPoints2(i).Location;
       Radius1 = MatchedPoints1(i).Scale;
       Radius2 = MatchedPoints2(i).Scale;

       % Create a grid of coordinates
       [X1, Y1] = meshgrid(1:Size1(2), 1:Size1(1));
       [X2, Y2] = meshgrid(1:Size2(2), 1:Size2(1));

       % Calculate the distance of each point from the center
       Dist1 = sqrt((X1 - Center1(1)).^2 + (Y1 - Center1(2)).^2);
       Dist2 = sqrt((X2 - Center2(1)).^2 + (Y2 - Center2(2)).^2);

       % Set pixels within the radius to true (1)
       Mask1(Dist1 <= Radius1) = true;
       Mask2(Dist2 <= Radius2) = true;
    end
end
