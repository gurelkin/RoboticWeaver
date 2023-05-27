function [line1, line2, line3, line4] = FindQuadFrame3( Piece, showResults )
%FindQuadFrame This function is used to find a tight quadrilateral frame
%around a puzzle piece. Should be roughly square.
%   The function returns 4 lines, for each of the piece's sides. Each line
%   is represented as two points.

% Convert to grayscale and apply edge detector
Pgray = rgb2gray(Piece);
thresh = 0.05; 
% thresh = 0.1; 
bw = edge(Pgray,'prewitt', thresh);
% figure; subplot(1,2,1); imshow(bw);

% Analyze connected components. 
props = regionprops(bw, 'area', 'PixelIdxList', 'BoundingBox');
cleanBW = zeros(size(bw));
l=1;
% figure;
for k=1:size(props,1)
    % Filter CC by area
    if props(k).Area > 10
        % Filter CC by area
        if (props(k).BoundingBox(3) > 2 && props(k).BoundingBox(4) > 2)
            regions(l) = props(k);
            pixList = regions(l).PixelIdxList;
            cleanBW(pixList) = 1;
%             imshow(cleanBW);
            l = l+1;
        end
    end
end

[h,w] = size(cleanBW);

if (sum(sum(cleanBW(1:round(h/2), 1:round(w/2)))) < 10)
    cleanBW(1:round(h/2), 1:round(w/2)) = bw(1:round(h/2), 1:round(w/2));
end
if (sum(cleanBW(round(h/2)+1:end, 1:round(w/2))) < 10)
    cleanBW(round(h/2)+1:end, 1:round(w/2)) = bw(round(h/2)+1:end, 1:round(w/2));
end
if (sum(cleanBW(1:round(h/2), round(w/2)+1:end)) < 10)
    cleanBW(1:round(h/2), round(w/2)+1:end) = bw(1:round(h/2), round(w/2)+1:end);
end
if (sum(cleanBW(round(h/2)+1:end, round(w/2)+1:end)) < 10)
    cleanBW(round(h/2)+1:end, round(w/2)+1:end) = bw(round(h/2)+1:end, round(w/2)+1:end);
end


%% Automatic corner extracion
% Works by finding the pixel closest to image corner in terms of
% the sum of the horizontal and vertical distance

plist = find(cleanBW);

[rowList colList] = ind2sub(size(cleanBW), plist);

% Find Top-Left and Bottom-Right corners
minVal = rowList(1)+colList(1);
maxVal = rowList(end)+colList(end);
TL_r = rowList(1);
TL_c = colList(1);
BR_r = rowList(end);
BR_c = colList(end);
for i=1:size(rowList)
    if rowList(i) + colList(i) < minVal
        minVal = rowList(i)+colList(i);
        TL_r = rowList(i);
        TL_c = colList(i);
    end
    if rowList(i) + colList(i) > maxVal
        maxVal = rowList(i)+colList(i);
        BR_r = rowList(i);
        BR_c = colList(i);
    end
end


% Flip image and repeat to find Top-Right and Bottom-Left corners
bw_flipped = fliplr(cleanBW);
plist = find(bw_flipped);
[rowList colList] = ind2sub(size(bw_flipped), plist);
minVal = rowList(1)+colList(1);
maxVal = rowList(end)+colList(end);
TR_r = rowList(1);
TR_c = colList(1);
BL_r = rowList(end);
BL_c = colList(end);
for i=1:size(rowList)
    if rowList(i) + colList(i) < minVal
        minVal = rowList(i)+colList(i);
        TR_r = rowList(i);
        TR_c = colList(i);
    end
    if rowList(i) + colList(i) > maxVal
        maxVal = rowList(i)+colList(i);
        BL_r = rowList(i);
        BL_c = colList(i);
    end
end

TR_c = w-TR_c+1;
BL_c = w-BL_c+1;

% Plot results to make sure we found the corners
% figure; imshow(bw);
% hold on;
% plot(TL_c, TL_r,'b*')
% hold on; 
% plot(BR_c, BR_r,'r*')
% hold on; 
% plot(TR_c, TR_r,'g*')
% hold on; 
% plot(BL_c, BL_r,'y*')
% hold on; 

% result: list of 4 points
p = [TL_c, TL_r; TR_c, TR_r; BR_c, BR_r; BL_c, BL_r];
line1 = struct('x1',TL_c, 'x2', TR_c, 'y1', TL_r, 'y2', TR_r);
line2 = struct('x1',BL_c, 'x2', BR_c, 'y1', BL_r, 'y2', BR_r);
line3 = struct('x1',TL_c, 'x2', BL_c, 'y1', TL_r, 'y2', BL_r);
line4 = struct('x1',TR_c, 'x2', BR_c, 'y1', TR_r, 'y2', BR_r);
%%
if showResults == 2
    figure;
    subplot(1,2,1); imshow(Piece);
    hold on;
    plot([line1.x1 line1.x2],[line1.y1 line1.y2],'Color','g','LineWidth', 1);
    plot([line2.x1 line2.x2],[line2.y1 line2.y2],'Color','g','LineWidth', 1);
    plot([line3.x1 line3.x2],[line3.y1 line3.y2],'Color','g','LineWidth', 1);
    plot([line4.x1 line4.x2],[line4.y1 line4.y2],'Color','g','LineWidth', 1);
    subplot(1,2,2); imshow(bw);
    hold on;
    plot([line1.x1 line1.x2],[line1.y1 line1.y2],'Color','g','LineWidth', 1);
    plot([line2.x1 line2.x2],[line2.y1 line2.y2],'Color','g','LineWidth', 1);
    plot([line3.x1 line3.x2],[line3.y1 line3.y2],'Color','g','LineWidth', 1);
    plot([line4.x1 line4.x2],[line4.y1 line4.y2],'Color','g','LineWidth', 1);
end

end

