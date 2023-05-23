function [line1, line2, line3, line4] = FindQuadFrame( Piece, showResults )
%FindQuadFrame This function is used to find a tight quadrilateral frame
%around a puzzle piece. Should be roughly square.
%   The function returns 4 lines, for each of the piece's sides. Each line
%   is represented as two points.

% Convert to grayscale and apply edge detector
Pgray = rgb2gray(Piece);
thresh = 0.04; 
bw = edge(Pgray,'prewitt', thresh);

[h,w] = size(bw);

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

ww = maxCol - minCol + 1;
hh = maxRow - minRow + 1;


%% Top side

% Left to right
% Find lowest pixel on the opposite side s.t. when connecting straight line, line is all black
a = max(minRow - 2, 1);
s = 0;
k1 = 0;
while (s == 0)
    k1=k1+1;
    dy = (k1-a)/(ww-1);
    for x=minCol:maxCol
        s = s + bw(a+round((x-minCol)*dy), x);
    end
end

% Right to left - reverse sides and repeat
s = 0;
k2 = 0;
while (s == 0)
    k2=k2+1;
    dy = (k2-a)/(ww-1);
    for x=maxCol:-1:minCol
        s = s + bw(a+round((maxCol-x)*dy), x);
    end
end

line1 = struct('x1', minCol, 'x2', maxCol, 'y1', max(k2, a), 'y2', max(k1,a));

%% Bottom side

% Left to right
% Find lowest pixel on the opposite side s.t. when connecting straight line, line is all black
a = min(maxRow + 2, h);
s = 0;
k1 = h;
while (s == 0)
    k1=k1-1;
    dy = (a-k1)/(ww-1);
    for x=minCol:maxCol
        s = s + bw(a-round((x-minCol)*dy), x);
    end
end

% Right to left - reverse sides and repeat
s = 0;
k2 = h;
while (s == 0)
    k2=k2-1;
    dy = (a-k2)/(ww-1);
    for x=maxCol:-1:minCol
        s = s + bw(a-round((maxCol-x)*dy), x);
    end
end

%line2 = struct('x1', 1, 'x2', w, 'y1', k2, 'y2', k1);
line2 = struct('x1', minCol, 'x2', maxCol, 'y1', min(k2, a), 'y2', min(k1,a));

%% Left side

% Top to bottom
% Find rightmost pixel on the bottom side s.t. when connecting straight line, line is all black
a = max(minCol - 2, 1);

s = 0;
k1 = 0;
while (s == 0)
    k1=k1+1;
    dy = (k1-a)/(hh-1);
    for x=minRow:maxRow
        s = s + bw(x, a+round((x-minRow)*dy));
    end
end

% Bottom to top - reverse sides and repeat
s = 0;
k2 = 0;
while (s == 0)
    k2=k2+1;
    dy = (k2-a)/(hh-1);
    for x=maxRow:-1:minRow
        s = s + bw(x,a+round((maxRow-x)*dy));
    end
end

% line3 = struct('x1', k2, 'x2', k1, 'y1', 1, 'y2', h);
line3 = struct('x1', max(k2,a), 'x2', max(k1,a), 'y1', minRow, 'y2', maxRow);

%% Right side

% Top to bottom
% Find lowest pixel on the opposite side s.t. when connecting straight line, line is all black
a = min(maxCol + 2, w);
s = 0;
k1 = w;
while (s == 0)
    k1=k1-1;
    dy = (a-k1)/(hh-1);
    for x=minRow:maxRow
        s = s + bw(x, a-round((x-minRow)*dy));
    end
end

% Bottom to top - reverse sides and repeat
s = 0;
k2 = w;
while (s == 0)
    k2=k2-1;
    dy = (a-k2)/(hh-1);
    for x=maxRow:-1:minRow
        s = s + bw(x, a-round((maxRow-x)*dy));
    end
end

% line4 = struct('x1', k2, 'x2', k1, 'y1', 1, 'y2', h);
line4 = struct('x1', min(k2,a), 'x2', min(k1,a), 'y1', minRow, 'y2', maxRow);

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

