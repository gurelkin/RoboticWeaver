function [ Im_res ] = FindWorkAreaCorners(Im, showResults)
%cropWorkArea Identify work area using blue markers and crop image 
%   Im - Original image

showResults = true;

RGB = imread('ImageDB\WorkArea.jpg');

redMask = RGB(:,:,1) < 120;
greenMask = RGB(:,:,2) < 120;
blueMask = RGB(:,:,3) > 100;
grayMask = rgb2gray(RGB) < 150;

if showResults
    figure; imshow(redMask); title('Red Mask');
    figure; imshow(greenMask); title('Green Mask');
    figure; imshow(blueMask); title('Blue Mask');
    figure; imshow(grayMask);title('Gray Mask');
end

BW = (redMask + greenMask + blueMask + grayMask) > 3;
% Perform binary erosion and dilation for noise removal
s = strel('disk', 2, 0);
newBW = imerode(BW, s);
newBW = imdilate(newBW, s);

figure;
imshow(BW)
figure;
imshow(newBW)

CC = bwconncomp(newBW);
numPixels = cellfun(@numel,CC.PixelIdxList);
IdxLists = {};
j=1;
for i=1:CC.NumObjects
    if numPixels(i) > 50
        IdxLists{j} = CC.PixelIdxList{i};
        j = j+1;
    end
end




l=1;
% Analyze connected components. 
props = regionprops(newBW, 'area', 'Centroid', 'PixelIdxList', 'Eccentricity');
cleanBW = zeros(size(newBW));
for k=1:size(props,1)
     props(k).Area
     props(k).Eccentricity

% Filter CC by area
    if props(k).Area > 50 && props(k).Area < 500
        regions(l) = props(k);
        pixList = regions(l).PixelIdxList;
        cleanBW(pixList) = 1;
        l = l+1;
    end
end

TL = regions(1).Centroid
TR = regions(1).Centroid.*[1 -1]
BL = regions(1).Centroid.*[-1 1]
BR = regions(1).Centroid
for i=1:size(regions, 2)
    if sum(regions(i).Centroid) < sum(TL)
        TL = regions(i).Centroid;
    end
    if sum(regions(i).Centroid) > sum(BR)
        BR = regions(i).Centroid;
    end
    if sum(regions(i).Centroid.*[-1 1]) > sum(BL)
        BL = regions(i).Centroid.*[-1 1];
    end
    if sum(regions(i).Centroid.*[1 -1]) > sum(TR)
        TR = regions(i).Centroid.*[1 -1];
    end
end

TL
TR = TR.*[1 -1]
BL = BL.*[-1 1]
BR

% Display final results
if showResults
    figure;
    subplot(1,2,1); imshow(cleanBW);
    subplot(1,2,2); imshow(RGB);
    hold on;
    plot(TL(1), TL(2), '+r');
    plot(TR(1), TR(2), '+r');
    plot(BL(1), BL(2), '+r');
    plot(BR(1), BR(2), '+r');
end

Im_res = PerformHomography( Im, p, p2 );
end

