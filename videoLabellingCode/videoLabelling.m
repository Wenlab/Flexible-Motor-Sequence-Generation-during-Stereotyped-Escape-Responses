function varargout = videoLabelling(varargin)
% VIDEOLABELLING MATLAB code for videoLabelling.fig
%      VIDEOLABELLING, by itself, creates a new VIDEOLABELLING or raises the existing
%      singleton*.
%
%      H = VIDEOLABELLING returns the handle to a new VIDEOLABELLING or the handle to
%      the existing singleton*.
%
%      VIDEOLABELLING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEOLABELLING.M with the given input arguments.
%
%      VIDEOLABELLING('Property','Value',...) creates a new VIDEOLABELLING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before videoLabelling_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to videoLabelling_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help videoLabelling

% Last Modified by GUIDE v2.5 26-Sep-2017 12:29:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @videoLabelling_OpeningFcn, ...
                   'gui_OutputFcn',  @videoLabelling_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before videoLabelling is made visible.
function videoLabelling_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to videoLabelling (see VARARGIN)

% Choose default command line output for videoLabelling
handles.output = hObject;
set(handles.axes1,'visible','off');
set(handles.slider1,'visible','off');
set(handles.pushbutton1,'visible','off');
set(handles.pushbutton3,'visible','off');
set(handles.pushbutton4,'visible','off');
set(handles.pushbutton5,'visible','off');
set(handles.uitable1,'visible','off');
set(handles.edit1,'visible','off');
set(handles.text2,'visible','off');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes videoLabelling wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = videoLabelling_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.frameNum = round(get(handles.slider1,'Value'));
DLPidx = handles.DLPidx;
frameIdx = DLPidx(handles.frameNum);
DLPstate = handles.DLPstate;
curSection = find(handles.onIdx <= frameIdx,1,'last');
if isempty(curSection)
    handles.curSection = 1;
else
    handles.curSection = curSection;
end
currentImg = handles.imgStack(:,:,handles.frameNum);
imshow(currentImg,[]);

if DLPstate(frameIdx)
    text(10,10,'DLPon','color','red');
else
    text(10,10,'DLPoff','color','red');
end
text(0.05,0.9,num2str(frameIdx),'color','red','Units','normalized');


handles.frameIdx = frameIdx;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function File_menu_Callback(hObject, eventdata, handles)
% hObject    handle to File_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.avi','Select video file');
fName = strcat(pathname,filename);
vObj = VideoReader(fName);
scaleFac = 0.5;
width =vObj.Width * scaleFac;
height = vObj.Height * scaleFac;
numFrame = floor(vObj.duration*vObj.frameRate);

% Open yaml file
[filename,pathname]  = uigetfile('*.yaml','Select yaml file');
fName = [pathname filename];

fprintf('Loading..., when finished, worm image will show up in the GUI\n');
[timeElapsed, DLPstate] = read_data_from_yaml(fName);
diffState = diff(DLPstate);
onIdx = find(diffState == 1) + 1;
offIdx = find(diffState == -1) ;
state = zeros(size(DLPstate));
numSection = length(onIdx);
dataMat = zeros(numSection,7);
for i = 1:numSection
    dataMat(i,1) = onIdx(i);
    dataMat(i,2) = offIdx(i);
    startIdx = max(1,onIdx(i) - 400);
    endIdx = min(length(DLPstate),offIdx(i) + 400);
    state(startIdx:endIdx) = 1;
end
DLPidx = find(state);
numImg = length(DLPidx);
imgStack = zeros(height,width,numImg);

frameIdx = 1;
for i = 1:numFrame
    I = rgb2gray(readFrame(vObj));
    I = imresize(I,scaleFac);
    if state(i) 
         imgStack(:,:,frameIdx) = I; 
         frameIdx = frameIdx + 1;
    end
end

handles.DLPstate = DLPstate;
handles.timeElapsed = timeElapsed;
handles.imgStack = imgStack;
handles.DLPidx = DLPidx;
handles.numImg = numImg;
handles.numSection = numSection;
handles.onIdx = onIdx;


handles.dataMat = dataMat;
handles.curSection = 1;
minStep = 1/(numImg-1);
maxStep = 5*minStep;
set(handles.slider1,...,
    'Enable','on',...
    'Min',1,...
    'Max',numImg,...
    'Value',1,...
    'SliderStep',[minStep,maxStep]);

set(handles.uitable1,...
    'Data',dataMat,...
    'ColumnEditable',[true,true,true,true,true,true,true], ...
    'ColumnWidth',{'auto',100}, ...
    'ColumnName', {'DLPstart','DLPend','ReversalStart(frame)','ReversalStart(time)','ReversalEnd(frame)','ReversalEnd(time)','IfTurn'}, ...
    'RowName',[], ...
    'visible','on' ...
    );

handles.frameNum = 1;
imshow(imgStack(:,:,1),[]);
%set(handles.axes1,'visible','on');
set(handles.slider1,'visible','on');
set(handles.pushbutton1,'visible','on');
set(handles.pushbutton3,'visible','on');
set(handles.pushbutton4,'visible','on');
set(handles.pushbutton5,'visible','on');
set(handles.uitable1,'visible','on');
set(handles.edit1,'visible','on');
set(handles.text2,'visible','on');
guidata(hObject,handles);


% --------------------------------------------------------------------
function Save_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Save_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataMat = handles.dataMat;
assignin('base','dataMat',dataMat);
guidata(hObject,handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Add DLP on timing
dataMat = handles.dataMat;
frameIdx = handles.frameIdx;
curSection = handles.curSection;
dataMat(curSection,1) = frameIdx;

set(handles.uitable1,'Data',dataMat);
handles.dataMat = dataMat;
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Add DLP off Timing
dataMat = handles.dataMat;
frameIdx = handles.frameIdx;
curSection = handles.curSection;
dataMat(curSection,2) = frameIdx;

set(handles.uitable1,'Data',dataMat);
handles.dataMat = dataMat;
guidata(hObject,handles);



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Add Reversal Start Timing
dataMat = handles.dataMat;
frameIdx = handles.frameIdx;
timeElapsed = handles.timeElapsed;
curSection = handles.curSection;
dataMat(curSection,3) = frameIdx;
dataMat(curSection,4) = timeElapsed(frameIdx);

set(handles.uitable1,'Data',dataMat);
handles.dataMat = dataMat;
guidata(hObject,handles);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Add Reversal End Timing
dataMat = handles.dataMat;
frameIdx = handles.frameIdx;
timeElapsed = handles.timeElapsed;
curSection = handles.curSection;
dataMat(curSection,5) = frameIdx;
dataMat(curSection,6) = timeElapsed(frameIdx);

set(handles.uitable1,'Data',dataMat);
handles.dataMat = dataMat;
guidata(hObject,handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
ifTurn = str2num(get(hObject,'String')); % 0 for no turn, 1 for turn
dataMat = handles.dataMat;
curSection = handles.curSection;
dataMat(curSection,7) = ifTurn;
set(handles.uitable1,'Data',dataMat);
handles.dataMat = dataMat;
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
