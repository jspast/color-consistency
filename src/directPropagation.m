function [ResultImages] = directPropagation(Images, ReferenceImages, Masks, Type)
% For every source image, transfer colors from the reference images
    % Images is an array of cells
    % ReferenceImages is an array with the numbers of the reference images
    % Masks is an adjacency matrix where Masks{i, j} stores a binary mask 
    % of the regions on image i that have correspondence in image j

    % Define a pair of images as a strong match when the sum of the squared
    % correspondences weight is greater than 25% of the source total weight.
    % This value was empiracally determined
    StrongCorr = 0.25;

    ResultImages = cell(length(Images));

    for i = 1:length(Images)
        if isempty(ReferenceImages(ReferenceImages == i))

            % Initialize accumulator variables
            TotalRefMean = 0; TotalRefStd = 0; TotalRefWeights = 0;
            TotalSrcMean = 0; TotalSrcStd = 0; TotalSrcWeights = 0;

            % Process stats from the correspondence with each reference image
            % Weight is squared to emphasize significant matches
            for j = 1:max(size(ReferenceImages))
                [RefMean, RefStd, RefWeight] = computeMeanStdPerChannelWithMask(Images{ReferenceImages(j)}, Masks{ReferenceImages(j), i});
                TotalRefMean = TotalRefMean + RefMean .* RefWeight^2;
                TotalRefStd = TotalRefStd + RefStd .* RefWeight^2;
                TotalRefWeights = TotalRefWeights + RefWeight^2;

                [SrcMean, SrcStd, SrcWeight] = computeMeanStdPerChannelWithMask(Images{i}, Masks{i, ReferenceImages(j)});
                TotalSrcMean = TotalSrcMean + SrcMean .* SrcWeight^2;
                TotalSrcStd = TotalSrcStd + SrcStd .* SrcWeight^2;
                TotalSrcWeights = TotalSrcWeights + SrcWeight^2;
            end

            % Compute the mean of the stats
            RefMean = TotalRefMean ./ TotalRefWeights;
            RefStd = TotalRefStd ./ TotalRefWeights;
            SrcMean = TotalSrcMean ./ TotalSrcWeights;
            SrcStd = TotalSrcStd ./ TotalSrcWeights;

            % Determine the significance of the color transfer
            SrcSize = size(Images{i});
            SrcTotalWeight = SrcSize(1) * SrcSize(2);
            SrcStrongCorrWeight = SrcTotalWeight * StrongCorr;
            if TotalSrcWeights < SrcStrongCorrWeight
                % Do an weighted average with the reference and source stats
                SrcFactor = SrcStrongCorrWeight - TotalSrcWeights;
                RefFactor = TotalSrcWeights;
                RefMean = (RefFactor * RefMean + SrcFactor * SrcMean) / (SrcFactor + RefFactor);
                RefStd = (RefFactor * RefStd + SrcFactor * SrcStd) / (SrcFactor + RefFactor);
            end

            % Apply the color transfer
            ResultImages{i} = meanStdColorTransfer(Images{i}, SrcMean, SrcStd, RefMean, RefStd);
        else
            ResultImages{i} = Images{i};
        end
    end
end

