function [bestBestBuddies] = RunPuzzleSolver2(Im, CameraImageAxes, CapturedImageAxes, JumbledPiecesAxes, SolutionAxes, showWorkAreaDetection, showRoughBlockSeparation, showOnlyBestEstimatedSolution, showEachPiece,Pieces,SIZE,ph,pw)
%RunPuzzleSolver - Acquire puzzle pieces from image, attempt to solve
%puzzle

%clc;
%clear all;
%close all;

% showRoughBlockSeparation = false;
% showWorkAreaDetection = true;
showFinalPiecesBeforeSolving = true;
% showOnlyBestEstimatedSolution = true;
% showEachPiece = 0;  % 0 - no output
                                             % 1 - only piece rotation and cropping
                                             % 2 - also show step identifying each piece closely
PieceCornerMethod = 3;  % choose 1, 2 or 3

% Im = imread('D:\RobotFiles_WithDLL_FromYaron\test.jpg');



%% Detect each piece's area more closely
Pieces = TightCropRotate(Pieces, PieceCornerMethod, showEachPiece);


%% Find minimum piece size, use it to standardize pieces
pSize = SIZE;
for m=1:size(Pieces,1)
    temp = min(size(Pieces{m}.Data, 1), size(Pieces{m}.Data, 1));
    if (temp < pSize)
        pSize = temp;
    end
end





%%
% ============================================================
% Loop: Crop pixels from all sides, run the algorithm. Save best result
% ============================================================

Pieces_Orig = Pieces;
bestBestBuddies = 0;
bestSol = [];
for k=floor(SIZE/400):(2+floor(SIZE/400))
currentBestBuddies = 0;

% Crop a little from each piece and resize to standard piece size
p2c = k-1; % Pixels to crop from every side

for m=1:size(Pieces,1)
    p = Pieces_Orig{m}.Data;
    Pieces{m}.Data = p((1+p2c):(end-p2c), (1+p2c):(end-p2c), :);
    Pieces{m}.Data = imresize(Pieces{m}.Data, [pSize,pSize]);
end


% Combine pieces to a single image
% ph = 3;
% pw = 3;
puzzleInput = combinePieces(Pieces, pw, ph, (1:ph*pw));

imshow(puzzleInput, 'Parent', JumbledPiecesAxes);
if showFinalPiecesBeforeSolving && ~showOnlyBestEstimatedSolution
    figure;
    imshow(puzzleInput);
end

% Save the resulting image, to be used as input for the algorithm 
imwrite(puzzleInput, 'pic2algo.png')

% size(puzzleInput)
% pSize

%%
% Run the algorithm
ImPath = 'pic2algo.png';
OutPath = 'Output\';

firstPartToPlace = -1; % random seed
partSize = pSize; % A square part size, this size should divide with the image
                                          % size or the image is cropped.
compatibilityFunc = 1; % Prediction-based Compatibility (Default)
% compatibilityFunc = 0;
% shiftMode = 1; % Move largest segment across all possible locations and take the best placement
shiftMode = 2; % Growing largest segment using estimationFunc  estimation metric to 
                                % measure convergence (Default)
colorScheme = 0; 
greedyType = 3; % Narrow Best Buddies with average (Default)
% greedyType = 1
estimationFunc = 0; % Best Buddies (Default)
% estimationFunc = 1;
outputMode = 0; % None (only return values)
runTests = 0;
normalMode = 4; % Exponent according to first quartile value (Default)
resPath = OutPath;
debug = 0; % Off

% 10 iterations
% Save best solution so far according to "Best Buddies" estimation metric.
for i=1:20
    [directCompVal, neighborCompVal, estimatedBestBuddiesCorrectness, estimatedAverageOfProbCorrectness, solutionPartsOrder, segmentsAccuracy, numOfIterations] = JigsawSolver(ImPath, firstPartToPlace, partSize, compatibilityFunc, shiftMode, colorScheme, greedyType, estimationFunc, outputMode, runTests, normalMode, OutPath, debug);
    if (estimatedBestBuddiesCorrectness > currentBestBuddies)
        sol = solutionPartsOrder;
        currentBestBuddies = estimatedBestBuddiesCorrectness;
        k_opt = k;
    end
end


if bestBestBuddies < currentBestBuddies
    bestBestBuddies = currentBestBuddies;
    bestSol = sol;
end

if ~showOnlyBestEstimatedSolution
    % Arrange puzzle according to best solution found and display
    puzzleOutput = combinePieces(Pieces, pw, ph, sol);
    figure;
    imshow(puzzleOutput);
    imshow(puzzleOutput, 'Parent', SolutionAxes);
    title(['Best Buddies estimate: ', num2str(currentBestBuddies)]);
end


currentBestBuddies
end

% Arrange puzzle according to best solution found and display
puzzleOutput = combinePieces(Pieces, pw, ph, bestSol);
imshow(puzzleOutput, 'Parent', SolutionAxes);
title(['Best Buddies estimate: ', num2str(bestBestBuddies)]);
imwrite(puzzleInput, 'out.png')


%% shai 1202 - apperantly this promt wasn't in the original code
% Give the user an option to see that the output is good before making the
% robot start
prompt = 'Puzzle solved. Enter 1 to start the robot, 0 to stop: ';
userInput = input(prompt); % requests an integer input
if userInput==0
    return;
end


pSize = pSize+7;
for i=1:ph
    for j=1:pw
        c = round(Pieces{bestSol((i-1)*pw+j)}.Center/2); % c - current position, choose part by order of solution
        target_x = round(50+(ph*pSize)/2*i/ph); % target - piece end position - palce one after the other
        target_y = round(460+50+(pw*pSize)/2*j/pw);
        
        if (c(1) > 0 && c(1) < 420 && c(2) > 0 && c(2) < 460 && ...
                target_x > 0 && target_x < 420 && target_y > 460 && target_y < 920)
            MoveXY(c(1), c(2));
            pause(4)
            MovePiece(target_x, target_y);
        end
    end
end
%MoveHome();
MoveToStart();
end
