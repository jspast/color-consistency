function [Mean, Std, Weight] = computeMeanStdPerChannelWithMask(Image, Mask)
% Calculates the mean and standard deviation for each channel of an Image with a binary Mask
    % The number of pixels used is returned as Weight
    
    ImageSize = size(Image);
    Mean = zeros(ImageSize(3));
    Std = zeros(ImageSize(3));
    
    % Compute stats for each channel
    for i = 1:ImageSize(3);
        Channel = Image(:, :, i);
        
         % Apply the binary mask to extract pixels in the matched region
        Match = Channel(Mask);
        
        % Compute the mean of pixels in the matched region
        Mean(i) = mean(Match);
        
        % Compute the standard deviation of pixels in the matched region
        Std(i) = std(double(Match));
    end

    Weight = max(size(Mask(Mask == 1)));
end
