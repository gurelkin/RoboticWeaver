function [line1, line2, line3, line4] = FindQuadFrame2( Piece, showResults )
%FindQuadFrame This function is used to find a tight quadrilateral frame
%around a puzzle piece. Should be roughly square.
%   The function returns 4 lines, for each of the piece's sides. Each line
%   is represented as two points.

% Convert to grayscale and apply edge detector
Pgray = rgb2gray(Piece);
thresh = 0.04; 
bw = edge(Pgray,'prewitt', thresh);
% figure; subplot(1,2,1); imshow(bw);

[h,w] = size(bw);
f1 = conv2(bw-0, ones(3,3), 'same') > 2;
f2 = conv2(bw-0, ones(1,3), 'same') > 1;
f3 = conv2(bw-0, ones(3,1), 'same') > 1;
bw = bw.*(f1+f2+f3);
f1 = conv2(bw-0, ones(3,3), 'same') > 2;
f2 = conv2(bw-0, ones(1,3), 'same') > 1;
f3 = conv2(bw-0, ones(3,1), 'same') > 1;
bw = bw.*(f1+f2+f3);
filter = conv2(bw-0, ones(5,5), 'same') > 4;
bw = bw.*filter;
% subplot(1,2,2); imshow(bw);

% Find rows and columns from the edges that contain only black pixels
[LiaR,LocbR] = ismember(bw, zeros(1,size(bw,2) ),'rows') ;
[LiaC,LocbC] = ismember(bw', zeros(1,size(bw,1) ),'rows') ;

minCol = 1;
while (LiaC(minCol) == 1)
    minCol = minCol + 1; end
maxCol = w;
while (LiaC(maxCol) == 1)
    maxCol = maxCol - 1; end
minRow = 1;
while (LiaR(minRow) == 1)
    minRow = minRow + 1; end
maxRow = h;
while (LiaR(maxRow) == 1)
    maxRow = maxRow - 1; end


Temp = zeros(size(bw));
Temp(minRow:maxRow, minCol:maxCol) = ones(maxRow-minRow+1, maxCol-minCol+1);

topCornerCol1 = find(bw(minRow, :), 1, 'first' ) ;
topCornerCol2 = find(bw(minRow, :), 1, 'last' ) ;
if sum(find(bw(minRow+1, :))) >0
    topCornerCol1 = min(topCornerCol1, find(bw(minRow+1, :), 1, 'first' ) );
    topCornerCol2 = max(topCornerCol2, find(bw(minRow+1, :), 1, 'last' ) );
end
if sum(find(bw(minRow+2, :))) >0
    topCornerCol1 = min(topCornerCol1, find(bw(minRow+2, :), 1, 'first' ) );
    topCornerCol2 = max(topCornerCol2, find(bw(minRow+2, :), 1, 'last' ) );
end

topCornerCol = max(topCornerCol1, 1);
if abs(find(bw(minRow, :), 1, 'first' )  - minCol) > abs(find(bw(minRow, :), 1, 'last' ) - maxCol)
    topCornerCol = min(topCornerCol2, w);
end


botCornerCol1 = find(bw(maxRow, :), 1, 'first' ) ;
botCornerCol2 = find(bw(maxRow, :), 1, 'last' ) ;
if sum(find(bw(maxRow-1, :))) >0
    botCornerCol1 = min(botCornerCol1, find(bw(maxRow-1, :), 1, 'first' ) );
    botCornerCol2 = max(botCornerCol2, find(bw(maxRow-1, :), 1, 'last' ) );
end
if sum(find(bw(maxRow-2, :))) >0
    botCornerCol1 = min(botCornerCol1, find(bw(maxRow-2, :), 1, 'first' ) );
    botCornerCol2 = max(botCornerCol2, find(bw(maxRow-2, :), 1, 'last' ) );
end

botCornerCol = max(botCornerCol1, 1);
if abs(topCornerCol - minCol) < abs(topCornerCol - maxCol)
    botCornerCol = min(botCornerCol2, w);
end


leftCornerRow1 = find(bw(:, minCol), 1, 'first' ) ;
leftCornerRow2 = find(bw(:, minCol), 1, 'last' ) ;
if sum(find(bw(:, minCol+1))) >0
    leftCornerRow1 = min(leftCornerRow1, find(bw(:, minCol+1), 1, 'first' ) );
    leftCornerRow2 = max(leftCornerRow2, find(bw(:, minCol+1), 1, 'last' ) );
end
if sum(find(bw(:, minCol+2))) >0
    leftCornerRow1 = min(leftCornerRow1, find(bw(:, minCol+2), 1, 'first' ) );
    leftCornerRow2 = max(leftCornerRow2, find(bw(:, minCol+2), 1, 'last' ) );
end

leftCornerRow = max(leftCornerRow1, 1);
if abs(topCornerCol - minCol) < abs(topCornerCol - maxCol)
    leftCornerRow = min(leftCornerRow2, h);
end

rightCornerRow1 = find(bw(:, maxCol), 1, 'first' ) ;
rightCornerRow2 = find(bw(:, maxCol), 1, 'last' ) ;
if sum(find(bw(:, maxCol-1))) >0
    rightCornerRow1 = min(rightCornerRow1, find(bw(:, maxCol-1), 1, 'first' ) );
    rightCornerRow2 = max(rightCornerRow2, find(bw(:, maxCol-1), 1, 'last' ) );
end
if sum(find(bw(:, maxCol-2))) >0
    rightCornerRow1 = min(rightCornerRow1, find(bw(:, maxCol-2), 1, 'first' ) );
    rightCornerRow2 = max(rightCornerRow2, find(bw(:, maxCol-2), 1, 'last' ) );
end

rightCornerRow = max(rightCornerRow1, 1);
if abs(topCornerCol - minCol) > abs(topCornerCol - maxCol)
    rightCornerRow = min(rightCornerRow2, h);
end

if (topCornerCol > botCornerCol)
    line1 = struct('x1',minCol, 'x2', topCornerCol, 'y1', leftCornerRow, 'y2', minRow);
    line2 = struct('x1', botCornerCol, 'x2', maxCol, 'y1', maxRow, 'y2', rightCornerRow);
    line3 = struct('x1', minCol, 'x2', botCornerCol, 'y1', leftCornerRow, 'y2', maxRow);
    line4 = struct('x1', topCornerCol, 'x2', maxCol, 'y1', minRow, 'y2', rightCornerRow);
else
    line1 = struct('x1',topCornerCol, 'x2', maxCol, 'y1', minRow, 'y2', rightCornerRow);
    line2 = struct('x1', minCol, 'x2', botCornerCol, 'y1', leftCornerRow, 'y2', maxRow);
    line3 = struct('x1',minCol, 'x2', topCornerCol, 'y1', leftCornerRow, 'y2', minRow);
    line4 = struct('x1', botCornerCol, 'x2', maxCol, 'y1', maxRow, 'y2', rightCornerRow);
end

%%
if showResults == 2
    figure;
    subplot(1,3,1); imshow(Piece);
    hold on;
    plot([line1.x1 line1.x2],[line1.y1 line1.y2],'Color','g','LineWidth', 1);
    plot([line2.x1 line2.x2],[line2.y1 line2.y2],'Color','g','LineWidth', 1);
    plot([line3.x1 line3.x2],[line3.y1 line3.y2],'Color','g','LineWidth', 1);
    plot([line4.x1 line4.x2],[line4.y1 line4.y2],'Color','g','LineWidth', 1);
    subplot(1,3,2); imshow(Temp);
    hold on;
    plot([line1.x1 line1.x2],[line1.y1 line1.y2],'Color','g','LineWidth', 1);
    plot([line2.x1 line2.x2],[line2.y1 line2.y2],'Color','g','LineWidth', 1);
    plot([line3.x1 line3.x2],[line3.y1 line3.y2],'Color','g','LineWidth', 1);
    plot([line4.x1 line4.x2],[line4.y1 line4.y2],'Color','g','LineWidth', 1);
    subplot(1,3,3); imshow(bw);
    hold on;
    plot([line1.x1 line1.x2],[line1.y1 line1.y2],'Color','g','LineWidth', 1);
    plot([line2.x1 line2.x2],[line2.y1 line2.y2],'Color','g','LineWidth', 1);
    plot([line3.x1 line3.x2],[line3.y1 line3.y2],'Color','g','LineWidth', 1);
    plot([line4.x1 line4.x2],[line4.y1 line4.y2],'Color','g','LineWidth', 1);
end


end

