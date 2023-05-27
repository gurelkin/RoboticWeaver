function [ Pieces_res ] = SeparatePieces(Im, showResults)
%SeparatePieces Function used to separate image into rough blocks, each
%containing a single puzzle piece
%   Im - Original image

% ----
% original constants
minPieceSize = 70;  % constant used to remove incorrectly identified pieces
maxPieceSize = 800;
minPieceArea = 400;
maxPieceArea = 10000;
% ----
% new constants by Ehud 15000 % Shai 16000
maxPieceArea = 16000; % the previous size was too small
% ----


I = double(rgb2gray(Im));

% Assuming BG is BLACK, we can use simple thresholding:
bw_thresh = I > 65;
bw_edge = edge(I, 'canny', [0.01,0.2], 0.5);
bw_combined = (bw_thresh + bw_edge) > 0;

if showResults
    figure;
    imshow(bw_thresh);
    figure;
    imshow(bw_edge);
    figure;
    imshow(bw_combined);
end
    
% Perform binary erosion and dilation for noise removal
s = strel('disk', 5, 0);
newBW = imdilate(bw_combined, s);
bw_combined = imerode(newBW, s);
    
% Analyze connected components, remove too small / too big
CC = bwconncomp(bw_combined);
props = regionprops(CC, 'MajorAxisLength', 'PixelIdxList', 'BoundingBox', 'Area');
bw = zeros(size(bw_combined));

%Pieces = cell(j-1,1);
j = 1;
bo = 10; % Bounding Box overhead to make sure we include the entire piece

for k=1:size(props,1)
    axlen = props(k).MajorAxisLength;
    bb = props(k).BoundingBox;
    area = props(k).Area;
    
    % Filter CC by MajorAxisLength
    if axlen > minPieceSize && axlen < maxPieceSize
        % Filter CC by Area
        if area > minPieceArea && area < maxPieceArea
            % Filter CC next to the edge
            if ~(bb(1) - bo < 1 || bb(2) - bo < 1 || bb(1)+bb(3)+bo > size(bw_combined, 2) || bb(2)+bb(4)+bo > size(bw_combined, 1))
                pixList = props(k).PixelIdxList;
                bw(pixList) = 1;
                
                Pieces{j} = struct('Data', Im(round((bb(2)-bo)):round((bb(2)+bb(4)+bo)), round((bb(1)-bo)):round((bb(1)+bb(3)+bo)), :), 'Center', round([(bb(2)+bb(4)/2), (bb(1)+bb(3)/2)]));
                
                %             plist = cell2mat(props(k).PixelIdxList);
                %             if (row2-row1 > minPieceSize) && (col2-col1 > minPieceSize) && (sum(sum(bw_thresh(row1:row2, col1:col2))) > 5)
                
                j = j+1;
                if showResults
                    hold on;
                    plot([bb(1)-bo bb(1)+bb(3)+bo], [(bb(2)-bo) (bb(2)-bo)],'Color','g','LineWidth', 1);
                    plot([bb(1)-bo bb(1)+bb(3)+bo],[(bb(2)+bb(4)+bo) (bb(2)+bb(4)+bo)],'Color','g','LineWidth', 1);
                    plot([bb(1)-bo bb(1)-bo],[(bb(2)-bo) (bb(2)+bb(4)+bo)],'Color','g','LineWidth', 1);
                    plot([bb(1)+bb(3)+bo bb(1)+bb(3)+bo],[(bb(2)-bo) (bb(2)+bb(4)+bo)],'Color','g','LineWidth', 1);
                end
            else
                'Bad!'
            end
        else %shai 1202 -check if part is off
            area
            plot([bb(1)-bo bb(1)+bb(3)+bo], [(bb(2)-bo) (bb(2)-bo)],'Color','r','LineWidth', 1);
                    plot([bb(1)-bo bb(1)+bb(3)+bo],[(bb(2)+bb(4)+bo) (bb(2)+bb(4)+bo)],'Color','r','LineWidth', 1);
                    plot([bb(1)-bo bb(1)-bo],[(bb(2)-bo) (bb(2)+bb(4)+bo)],'Color','r','LineWidth', 1);
                    plot([bb(1)+bb(3)+bo bb(1)+bb(3)+bo],[(bb(2)-bo) (bb(2)+bb(4)+bo)],'Color','r','LineWidth', 1);
        end
    else %shai 1202 - check if part is off
        %axlen
    end
end
bw_thresh = bw;
if showResults
    figure;
    imshow(bw_thresh);
end


badIndices = [];
% Search for pieces wrongly split into 2
for i=1 : size(Pieces, 2)
    [h1,w1,t1] = size(Pieces{i}.Data);
    if (h1/w1 > 1.2) || (w1/h1 > 1.2)
        for j=i+1 : size(Pieces, 2)
            [h2,w2,t2] = size(Pieces{j}.Data);
            if (h2/w2 > 1.2) || (w2/h2 > 1.2)
                c1 = Pieces{i}.Center;
                c2 = Pieces{j}.Center;
                if (((abs(c1(1) - c2(1)) < 20) && (abs(c1(2) - c2(2)) < 100)) ...
                        || ((abs(c1(2) - c2(2)) < 20) && (abs(c1(1) - c2(1)) < 100)))
                    TL = round([min(c1(1)-h1/2, c2(1)-h2/2), min(c1(2)-w1/2, c2(2)-w2/2)]);
                    BR = round([max(c1(1)+h1/2, c2(1)+h2/2), max(c1(2)+w1/2, c2(2)+w2/2)]);
                    
                   Pieces{i}.Data = Im(TL(1):BR(1), TL(2):BR(2), :);
                   badIndices = [badIndices, j];
                end
            end
        end
    end
end



Pieces_res = cell(size(Pieces, 2) - size(badIndices, 2), 1);
j=1;
for i=1:size(Pieces,2)
    if sum(badIndices == i) == 0
        Pieces_res{j} = Pieces{i};
        j=j+1;
    end
end


end

