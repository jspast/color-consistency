%% Settings

% Non-Rigid Dense Correspondence (NRDC) is the superior correspondence algorithm
% If disabled, the much faster Speeded Up Robust Features (SURF) is used
% Disabled by default as it only works on Windows with the nrdc.mexw64 file
UseNRDC = false;

% Use L*a*b* color space for the color transformation
% If disabled, RGB is used
% Enabled by default as it usually delivers better results
UseLab = true;

% The folder to use for the input images
Folder = 'test_images/redencao/';

% The number of images to be used
% Images should be named: "1.---, 2.---, ..., <NumImages>.---"
NumImages = 4;

% The index of the reference images to be used (one or more)
RefImagesIndex = [3];

% Presents a figure at the end of the computation with the results
ShowComparison = true;

% Export the final images on <Folder>/output/ directory
ExportResult = false;


%% Read images

Files = dir(fullfile(pwd, Folder, '*.*'));

OriginalImages = cell(NumImages, 1);

for i = 1:NumImages
    OriginalImages{i} = imread(strcat(Folder, Files(i + 2).name));
end

Images = OriginalImages;

%% Extract images features

if UseNRDC == false
    % Using SURF algorithm
    Features = cell(NumImages, 1);
    Points = cell(NumImages, 1);
    for i = 1:NumImages
        [Features{i}, Points{i}] = extractSURFFeatures(Images{i});
    end
else
    % Using NRDC algorithm
    Mapping = cell(NumImages, NumImages);
    Weights = zeros(NumImages, NumImages);
    for i = 2:NumImages
        for j = 1:i-1
            [mapping, confidence] = affinity_term(Images{i}, Images{j});
            Mapping{i,j} = mapping;
            Weights(i,j) = sum(sum(confidence));
            Weights(j,i) = sum(sum(confidence));
        end
    end
end

%% Build adjacency matrix

% AdjMat{i, j} stores a binary mask of the regions on image i that have
% correspondence in image j
AdjMat = cell(NumImages, NumImages);

if UseNRDC == false
    % Using SURF correspondence
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
else
    % Using NRDC correspondence
    for i = 1:NumImages
        for j = 1:i-1
            if (Weights(i,j) ~= 0)
                mapping = Mapping{i,j};
                maskItoJ = zeros(size(Images{i},1), size(Images{i},2));
                maskJtoI = zeros(size(Images{j},1), size(Images{j},2));
                for x = 1:size(Images{i},1)
                    for y = 1:size(Images{i},2)
                        targetX = round(mapping(x, y, 1));
                        targetY = round(mapping(x, y, 2));
                        if (targetX ~= 0 || targetY ~= 0)
                            maskItoJ(x, y) = 1;
                            maskJtoI(targetX, targetY) = 1;
                        end
                    end  
                end
                AdjMat{i,j} = maskItoJ; 
                AdjMat{j,i} = maskJtoI;
            end
        end
    end
end

%% Color transfer

ResultImages = cell(NumImages, 1);

if UseLab == false
    % Using the RGB color space
    if UseNRDC == false
        ResultImages = directPropagationSURF(Images, RefImagesIndex, AdjMat);
    else
        ResultImages = directPropagationNRDC(Images, RefImagesIndex, AdjMat, Weights);
    end
    
    % Cast images to uint8 to display
    for i = 1:NumImages
        ResultImages{i} = uint8(ResultImages{i});
    end
else
    % Using the L*a*b* color space
    for i = 1:NumImages
        ResultImages{i} = rgb2lab(Images{i});
    end
    
    if UseNRDC == false
        ResultImages = directPropagationSURF(ResultImages, RefImagesIndex, AdjMat);
    else
        ResultImages = directPropagationNRDC(ResultImages, RefImagesIndex, AdjMat, Weights);
    end
    
    % Convert back to RGB color space to display
    for i = 1:NumImages
        ResultImages{i} = lab2rgb(ResultImages{i});
    end
end

%% Display result

if ShowComparison == true
    figure;
    for i = 1:NumImages
        subplot(2, NumImages, i);
        imshow(OriginalImages{i});
        if ~isempty(RefImagesIndex(RefImagesIndex == i))
            title('Reference Image');
        else
            title('Source Image');
        end
        subplot(2, NumImages, i + NumImages);
        imshow(ResultImages{i});
        if UseLab == false
            title('Result (RGB)');
        else
            title('Result (L*a*b*)');
        end
    end
end

%% Export result

if ExportResult == true
    for i = 1:NumImages
        imwrite(ResultImages{i}, strcat(Folder, sprintf('output/%02d.png', i)));
    end
end
