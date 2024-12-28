function [Features, Points] = extractSURFFeatures(Image)
% Extract SURF Features from an Image

    GrayImage = rgb2gray(Image);
    
    Points = detectSURFFeatures(GrayImage);
    
    [Features, Points] = extractFeatures(GrayImage, Points);

end

