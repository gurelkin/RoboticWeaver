function [ Pieces_res ] = SeparatePieces(Im, showResults)
%SeparatePieces Function used to separate image into rough blocks, each
%containing a single puzzle piece
%   Im - Original image

minPieceSize = 50;  % constant used to remove incorrectly identified pieces

I = double(rgb2gray(Im));

% Apply edge detector and remove noise
bw_edges = edge(I, 'canny', [0.2,0.4], 2);
f = conv2(bw_edges-0, ones(3,3), 'same') > 2;
bw_edges = bw_edges.*(f);
if showResults
    figure;
    imshow(bw_edges);
end
CC = bwconncomp(bw_edges);
% Analyze connected components, remove too small / too big
props = regionprops(CC, 'MajorAxisLength', 'PixelIdxList');
bw = zeros(size(bw_edges));

for k=1:size(props,1)
%     props(k).MajorAxisLength

% Filter CC by MajorAxisLength
    if props(k).MajorAxisLength > minPieceSize && props(k).MajorAxisLength < 800
        pixList = props(k).PixelIdxList;
        bw(pixList) = 1;
    end
end
bw_edges = bw;
if showResults
    figure;
    imshow(bw_edges);
end

% Separate image into parts using straight lines across entire image
% width/height
[LiaR,LocbR] = ismember(bw_edges, zeros(1,size(bw_edges,2) ),'rows') ;
[LiaC,LocbC] = ismember(bw_edges', zeros(1,size(bw_edges,1) ),'rows') ;

BW_blocks = ones(size(bw_edges));
for i = 1:size(BW_blocks,1)
    for j = 1:size(BW_blocks,2)
       if(LiaR(i)==0 && LiaC(j)==0)
         BW_blocks(i,j) = 0;  
       end
    end
end


% Examine each connected component and remove those that are too small
CC = bwconncomp(1-BW_blocks);
j = 1;
for i=1:CC.NumObjects
    plist = cell2mat(CC.PixelIdxList(i));
    [row1 col1] = ind2sub(size(Im), min(plist));
    [row2 col2] = ind2sub(size(Im), max(plist));
    if (row2-row1 > minPieceSize) && (col2-col1 > minPieceSize) && (sum(sum(bw_edges(row1:row2, col1:col2))) > 5)
        j = j+1;
    end
end

% Save the proper pieces into a cell array
Pieces = cell(j-1,1);
j = 1;
if showResults
    figure;
    imshow(uint8(I));
end
for i=1:CC.NumObjects
    plist = cell2mat(CC.PixelIdxList(i));
    [row1 col1] = ind2sub(size(Im), min(plist));
    [row2 col2] = ind2sub(size(Im), max(plist));
    if (row2-row1 > minPieceSize) && (col2-col1 > minPieceSize) && (sum(sum(bw_edges(row1:row2, col1:col2))) > 5)
        Pieces{j} = struct('Data', Im((row1-5):(row2+5), (col1-5):(col2+5), :), 'Center', round([(row1+row2)/2, (col1+col2)/2]));
        j = j+1;
        if showResults
            hold on;
            plot([col1-5 col2+5], [(row1-5) (row1-5)],'Color','g','LineWidth', 1);
            plot([col1-5 col2+5],[(row2+5) (row2+5)],'Color','g','LineWidth', 1);
            plot([col1-5 col1-5],[(row1-5) (row2+5)],'Color','g','LineWidth', 1);
            plot([col2+5 col2+5],[(row1-5) (row2+5)],'Color','g','LineWidth', 1);
        end
    end
end

Pieces_res = Pieces;
size(Pieces_res);
if showResults
    figure;
    subplot(1,3,1); imshow(uint8(I)); title('(a)');
    subplot(1,3,2); imshow(bw_edges); title('(b)');
    subplot(1,3,3); imshow(BW_blocks); title('(c)');
end

autoPrintMe = false;
path = 'Output\';
if (autoPrintMe)
    figure; imshow(uint8(I)); print(gcf, '-dpng', [path  'grayscale']);
    figure; imshow(bw_edges); print(gcf, '-dpng', [path  'bw_edges']);
    figure; imshow(BW_blocks); print(gcf, '-dpng', [path  'BW_blocks']);
end

end

