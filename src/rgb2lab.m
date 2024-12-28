function [OutputImage] = rgb2lab(InputImage)
% Converts image from RGB to L*a*b* color space
    % InputImage is uint8
    % OutputImage is double

    Converter = vision.ColorSpaceConverter;
    Converter.Conversion = 'sRGB to L*a*b*';
    InputImage = double(InputImage) ./ 255;
    OutputImage = step(Converter, InputImage);

end

