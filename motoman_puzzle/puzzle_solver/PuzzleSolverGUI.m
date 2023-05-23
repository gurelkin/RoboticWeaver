function varargout = PuzzleSolverGUI(varargin)

% Last Modified by GUIDE v2.5 27-May-2018 15:47:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PuzzleSolverGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PuzzleSolverGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PuzzleSolverGUI is made visible.
function PuzzleSolverGUI_OpeningFcn(hObject, eventdata, handles, varargin)
clc;
imaqreset;
tic; % why??

% Choose default command line output for PuzzleSolverGUI
handles.output = hObject;

% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.
handles.video=videoinput('winvideo',1);% shai change 080217
src = getselectedsource(handles.video);
set(src,'WhiteBalanceMode','auto')

% Black BG #2
set(src,'FrameRate', '25') % shai 82
% shai comment out 0802
 %set(src,'Brightness', -10)
 %set(src,'Saturation', 10)
 %set(src, 'Contrast', 9)
 %set(src, 'Gain', 1)
 %set(src, 'Gamma', 1)

 
 
% set(src, 'FocusMode', 'manual')
% set(src, 'ExposureMode', 'manual')
% set(src, 'Focus', 0)
% set(src, 'Exposure', -4)
% set(src, 'Gain', 15)
% set(src, 'Pan', 0)
% set(src, 'Saturation', 128)
% set(src, 'Sharpness', 128)
% set(src, 'WhiteBalanceMode', 'manual')
% set(src, 'WhiteBalance', 3000)

set(handles.video,'TimerPeriod', 0.05, ...
'TimerFcn',['if(~isempty(gco)),'...
'handles=guidata(gcf);'... % Update handles
'image(getsnapshot(handles.video));'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
'set(handles.axes3,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
'else '...
'delete(imaqfind);'... % Clean up - delete any image acquisition objects
'end']);
triggerconfig(handles.video,'manual')
% handles.video.FramesPerTrigger = Inf; % Capture frames until we manually stop it
handles.video.FramesPerTrigger = 1;
set(handles.video,'TriggerRepeat',0)
set(handles.video,'ReturnedColorSpace','rgb')
set(handles.video,'Timeout',2);

set(handles.SolvePuzzleButton,'Enable','off');
set(handles.CaptureImageButton,'Enable','off');
set(handles.axes1,'ytick',[],'xtick',[]); % Remove tickmarks and labels that are inserted when using IMAGE
set(handles.axes2,'ytick',[],'xtick',[]); % Remove tickmarks and labels that are inserted when using IMAGE
set(handles.axes3,'ytick',[],'xtick',[]); % Remove tickmarks and labels that are inserted when using IMAGE
set(handles.axes4,'ytick',[],'xtick',[]); % Remove tickmarks and labels that are inserted when using IMAGE
set(handles.axes1,'box', 'on');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PuzzleSolverGUI wait for user response (see UIRESUME)
uiwait(handles.PuzzleSolverGUI);


% --- Outputs from this function are returned to the command line.
function varargout = PuzzleSolverGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


% --- Executes on button press in startStopCamera.
function startStopCamera_Callback(hObject, eventdata, handles)

% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
    % Camera is off. Change button string and start camera.
    set(handles.startStopCamera,'String','Stop Camera')
    start(handles.video)
    set(handles.SolvePuzzleButton,'Enable','on');
    set(handles.CaptureImageButton,'Enable','on');
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera')
    stop(handles.video)
    set(handles.SolvePuzzleButton,'Enable','off');
    set(handles.CaptureImageButton,'Enable','off');
end

% rectangle('Parent', handles.axes1, 'Position',[50 50 10 10],'Curvature',[1,1],...
%           'FaceColor','r')
% rectangle('Parent', handles.axes2, 'Position',[50 50 10 10],'Curvature',[1,1],...
%           'FaceColor','g')
% rectangle('Parent', handles.axes3, 'Position',[50 50 10 10],'Curvature',[1,1],...
%           'FaceColor','b')
% rectangle('Parent', handles.axes4, 'Position',[50 50 10 10],'Curvature',[1,1],...
%           'FaceColor','y')
      

% --- Executes on button press in CaptureImageButton.
function CaptureImageButton_Callback(hObject, eventdata, handles)

% stop(handles.video);
% src = getselectedsource(handles.video);
% set(src,'Brightness', 120)
% set(src, 'Contrast', 160)
% set(src, 'Exposure', -4)
% set(src, 'FocusMode', 'manual')
% set(src, 'ExposureMode', 'manual')
% set(src, 'Focus', 0)
% set(src, 'Exposure', -4)
% set(src, 'Gain', 15)
% set(src, 'Pan', 0)
% set(src, 'Saturation', 128)
% set(src, 'Sharpness', 128)
% set(src, 'WhiteBalanceMode', 'manual')
% set(src, 'WhiteBalance', 3000)
% start(handles.video);
% pause(0.5);
Im = getsnapshot(handles.video);

cla(handles.axes2);
imshow(Im, 'Parent', handles.axes2);
set(handles.SaveCapturedToFileButton,'Enable','on');

% Update handles structure
handles.Im = Im;
guidata(hObject, handles);


% --- Executes on button press in SolvePuzzleButton.
function SolvePuzzleButton_Callback(hObject, eventdata, handles)

[Pieces,SIZE] = RunPuzzleSolver1(handles.Im, handles.axes3, handles.axes2, handles.axes1, handles.axes4, ...
    get(handles.showWorkAreaDetectionCheckbox, 'Value'), ...
    get(handles.showRoughBlockSeparationCheckbox, 'Value'), ...
    1-get(handles.showMultipleSolutionsCheckbox, 'Value'), ...
    get(handles.piecesMenu,'Value')-1);

% Retrieve selected values for puzzle height and width from GUI
index = get(handles.PuzzleHeight, 'Value');
values = get(handles.PuzzleHeight, 'String');
ph = str2num(values{index});

index = get(handles.PuzzleWidth, 'Value');
values = get(handles.PuzzleWidth, 'String');
pw = str2num(values{index});



handles.bb = RunPuzzleSolver2(handles.Im, handles.axes3, handles.axes2, handles.axes1, handles.axes4, ...
    get(handles.showWorkAreaDetectionCheckbox, 'Value'), ...
    get(handles.showRoughBlockSeparationCheckbox, 'Value'), ...
    1-get(handles.showMultipleSolutionsCheckbox, 'Value'), ...
    get(handles.piecesMenu,'Value')-1,Pieces,SIZE,ph,pw);

guidata(hObject, handles);



function PuzzleSolverGUI_CloseRequestFcn(hObject, eventdata, handles)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);


% --- Executes on button press in showRoughBlockSeparationCheckbox.
function showRoughBlockSeparationCheckbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in showMultipleSolutionsCheckbox.
function showMultipleSolutionsCheckbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in extendedOutputToggle.
function extendedOutputToggle_Callback(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of extendedOutputToggle
val = get(hObject,'Value');
if val == 1
    set(handles.showRoughBlockSeparationCheckbox,'Value',0);
    set(handles.showMultipleSolutionsCheckbox,'Value',0);
    set(handles.piecesMenu,'Value',1);
    set(handles.OutputSettingsPanel,'Visible','on');
else
    set(handles.OutputSettingsPanel,'Visible','off');
end


% --- Executes on selection change in piecesMenu.
function piecesMenu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function piecesMenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveCapturedToFileButton.
function SaveCapturedToFileButton_Callback(hObject, eventdata, handles)
[filename, pathname] = uiputfile('*.jpg','Save Captured Image As');
if isequal(filename,0) || isequal(pathname,0)
   disp('User selected Cancel')
else
   disp(['User selected ',fullfile(pathname,filename)])
   Im = getsnapshot(handles.video);
   imwrite(Im, fullfile(pathname,filename));
end


% --- Executes on button press in LoadImageFromFileButton.
function LoadImageFromFileButton_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'}...
    , 'Select an Image');
if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   Im = imread(fullfile(pathname, filename));
   cla(handles.axes2);
    imshow(Im, 'Parent', handles.axes2);
    set(handles.SaveCapturedToFileButton,'Enable','off');
    set(handles.SolvePuzzleButton,'Enable','on');

    % Update handles structure
    handles.Im = Im;
    guidata(hObject, handles);
end


% --- Executes on button press in showWorkAreaDetectionCheckbox.
function showWorkAreaDetectionCheckbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in MoveToStart.
function MoveToStart_Callback(hObject, eventdata, handles)
% MoveRobot(510,230,320,-87,44,-98,'ROBOT',5); %shai co 82
MoveRobot(605,174,226,178,-2.4,-132.2,'ROBOT',5); %shai  82

% --- Executes on button press in SuctionButton.
function SuctionButton_Callback(hObject, eventdata, handles)
% hObject    handle to SuctionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Suction();


% --- Executes on selection change in PuzzleWidth.
function PuzzleWidth_Callback(hObject, eventdata, handles)
% hObject    handle to PuzzleWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PuzzleWidth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PuzzleWidth


% --- Executes during object creation, after setting all properties.
function PuzzleWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PuzzleWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PuzzleHeight.
function PuzzleHeight_Callback(hObject, eventdata, handles)
% hObject    handle to PuzzleHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns PuzzleHeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PuzzleHeight


% --- Executes during object creation, after setting all properties.
function PuzzleHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PuzzleHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveData.
function SaveData_Callback(hObject, eventdata, handles)
% hObject    handle to SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t = clock;
str = [num2str(t(4)), '.', num2str(t(5)), '.', num2str(floor(t(6)))];
digits(2);
imwrite(getimage(handles.axes2),['output/' str '_captured'  '.png']); 
imwrite(getimage(handles.axes4),['output/' str '_solution_' char(vpa(handles.bb)) '.png']); 
imwrite(getimage(handles.axes1),['output/' str '_pieces' '.png']); 
