function [Corr_DCF, Corr_Confidence] = affinity_term(source, reference)
% This function applies the NRDC algorithim to a pair of images, returning:
%   DCF: a dense correspondence field that indicates, for each pixel in the
%        source image, the corresponding pixel at the reference image;
%   Confidance: a matrix that indicates the level of 'trust' involved in
%               each pixel's mapping in the DCF;

%% Normalize image (source and reference) values:
source = double(source)/255.0;
reference = double(reference)/255.0;

%% Resize image if it is too big for NRDC:
resizeFactor = max(max(size(source))) / 640;
if (resizeFactor > 1)
    disp('Source image is too big. Resize automatically.')
    source = imresize(source, 1.0/resizeFactor);
    reference = imresize(reference, 1.0/resizeFactor);
end

%% Apply NRDC algorithim:
NRDC_Options = [];
tic 
[DCF, Confidence, T, AlignedRef] = nrdc(source, reference, NRDC_Options);
toc % Display the time taken by the NRDC operation;


%% ??
patch_w = 8;
[Corr_DCF, Corr_Confidence] = moveToCenter(DCF, patch_w, Confidence);


%% Returning just the coordinates from teh DCF field 
Corr_DCF = Corr_DCF(:, :, 1:2);

end
    
%% moveToCenter Function
function [Corr, Corr_Confidence] = moveToCenter(DCF, patch_w, DCF_Confidence)
    Corr=zeros([size(DCF,1)+patch_w-1, size(DCF,2)+patch_w-1, 2]);
    Corr(patch_w/2+1:end-patch_w/2+1, patch_w/2+1:end-patch_w/2+1, :) = DCF(:,:,1:2) + patch_w/2;
    
    Corr_Confidence = zeros(size(Corr(:,:,1)));
    if exist('DCF_Confidence', 'var') && ~isempty(DCF_Confidence)
        Corr_Confidence(patch_w/2+1:end-patch_w/2+1, patch_w/2+1:end-patch_w/2+1) = DCF_Confidence(:,:);
    else
        Corr_Confidence(patch_w/2+1:end-patch_w/2+1, patch_w/2+1:end-patch_w/2+1, :) = 1;
    end
end