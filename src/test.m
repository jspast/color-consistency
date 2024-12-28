%% Read images

NumImages = 5;
RefImages = [1];

OriginalImages = cell(NumImages, 1);
OriginalImages{1} = imread('notre_dame1.jpg');
OriginalImages{2} = imread('notre_dame2.jpg');
OriginalImages{3} = imread('notre_dame3.jpg');
OriginalImages{4} = imread('people1.png');
OriginalImages{5} = imread('people2.png');

Images = OriginalImages;

%% Extract images features

% Using SURF algorithm
Features = cell(NumImages, 1);
Points = cell(NumImages, 1);
for i = 1:NumImages
    [Features{i}, Points{i}] = extractSURFFeatures(Images{i});
end

%% Build adjacency matrix

% AdjMat{i, j} stores a binary mask of the regions on image i that have
% correspondence in image j
AdjMat = cell(NumImages, NumImages);

for i = 1:NumImages
    for j = i+1:NumImages
        IndexPairs = matchFeatures(Features{i}, Features{j});
        MatchedPointsi = Points{i}(IndexPairs(:, 1));
        MatchedPointsj = Points{j}(IndexPairs(:, 2));
        
        [Maski, Maskj] = computeSURFCorrespondenceMasks(size(Images{i}), ...
            MatchedPointsi, size(Images{j}), MatchedPointsj);
        AdjMat{i, j} = Maski;
        AdjMat{j, i} = Maskj;
    end
end

%% Color transfer (RGB)

RgbImagesResult = directPropagation(Images, RefImages, AdjMat);

% Cast images to uint8 to display
for i = 1:NumImages
    RgbImagesResult{i} = uint8(RgbImagesResult{i});
end

%% Color transfer (L*a*b*)

% Using the L*a*b* color space for better results
LabImages = cell(NumImages, 1);
for i = 1:NumImages
    LabImages{i} = rgb2lab(Images{i});
end

LabImages = directPropagation(LabImages, RefImages, AdjMat);

% Convert back to RGB color space to display
LabImagesResult = cell(NumImages, 1);
for i = 1:NumImages
    LabImagesResult{i} = lab2rgb(LabImages{i});
end

%% Display result

figure;

for i = 1:NumImages
    subplot(3, NumImages, i);
    imshow(OriginalImages{i});
    if ~isempty(RefImages(RefImages == i))
        title('Reference Image');
    else
        title('Source Image');
    end
    
    subplot(3, NumImages, i + NumImages);
    imshow(RgbImagesResult{i});
    title('Result (RGB)');
    
    subplot(3, NumImages, i + NumImages * 2);
    imshow(LabImagesResult{i});
    title('Result (L*a*b*)');
end
