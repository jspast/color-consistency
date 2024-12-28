function [OutputImage] = lab2rgb(InputImage)
% Converts image from L*a*b* to RGB color space
    % InputImage is double
    % OutputImage is uint8

    Converter = vision.ColorSpaceConverter;
    Converter.Conversion = 'L*a*b* to sRGB';
    OutputImage = step(Converter, InputImage);
    OutputImage = uint8(double(OutputImage) .* 255);
end

