function [ResultImage] = meanStdColorTransfer(SourceImage, SourceMean, SourceStd, ReferenceMean, ReferenceStd)
%MEANSTDCOLORTRANSFER Transfer colors between two images based on their per-channel mean and standard deviation

    ImageSize = size(SourceImage);
    ResultImage = zeros(ImageSize);

    for i = 1:ImageSize(3);
        ResultImage(:,:,i) = (double(SourceImage(:,:,i)) - SourceMean(i)) .* (ReferenceStd(i) ./ SourceStd(i)) + ReferenceMean(i);
    end
end

