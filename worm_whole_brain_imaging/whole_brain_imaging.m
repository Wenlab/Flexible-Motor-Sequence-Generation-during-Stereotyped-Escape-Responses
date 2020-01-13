function varargout = whole_brain_imaging(varargin)
%several inputs:
%1. image stack
%2. neuronal_position
%3. neuronal_idx
%4. ROIposition

% whole_brain_imaging MATLAB code for whole_brain_imaging.fig
%      whole_brain_imaging, by itself, creates a new whole_brain_imaging or raises the existing
%      singleton*.
%
%      H = whole_brain_imaging returns the handle to a new whole_brain_imaging or the handle to
%      the existing singleton*.
%
%      whole_brain_imaging('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in whole_brain_imaging.M with the given input arguments.
%
%      whole_brain_imaging('Property','Value,...) creates a new whole_brain_imaging or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before whole_brain_imaging_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to whole_brain_imaging_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help whole_brain_imaging

% Last Modified by GUIDE v2.5 20-May-2017 22:15:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @whole_brain_imaging_OpeningFcn, ...
                   'gui_OutputFcn',  @whole_brain_imaging_OutputFcn, ...
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

% --- Executes just before whole_brain_imaging is made visible.
function whole_brain_imaging_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to whole_brain_imaging (see VARARGIN)

% Choose default command line output for whole_brain_imaging

handles.img_stack=varargin{1};
handles.volumes=length(handles.img_stack);
%img_stack{1,1} is the first volume
[handles.image_height,handles.image_width]=size(handles.img_stack{1,1});

width=800;
height=800;

set(hObject,'Units','pixels');
set(handles.figure1, 'Position', [400 400 width height+80]);
set(handles.slider1, 'Position', [0 0 width 18]);
axes(handles.axes1);
handles.low=0;
handles.high=1500;
handles.tracking_threshold=70;
handles.contrast_enhancement=0;

img=imagesc(handles.img_stack{1,1}(:,:),[handles.low handles.high]);
colormap(gray);
set(handles.axes1, ...
    'Visible', 'off', ...
    'Units', 'pixels', ...
    'Position', [0 30 width height]);

handles.axel_width=width;
handles.axel_height=height;

set(handles.text1, 'Units','pixels');
set(handles.text1, 'Position',[0 44+height+2 width 18]);
set(handles.text1, 'HorizontalAlignment','center');
set(handles.text1, 'String',strcat(num2str(1),'/',num2str(handles.volumes),' volumes; '));

handles.hp=impixelinfo;

set(handles.hp,'Position',[0 44+height+2,300,20]);


set(img,'ButtonDownFcn', 'whole_brain_imaging(''ButtonDown_Callback'',gcbo,[],guidata(gcbo))');

%the maxiumum number of neurons to track is 302
handles.points=cell(302,1);
handles.colorset=varycolor(302);
handles.ROI=cell(handles.volumes,1);

handles.red_green_tform=[];

%initialize neuronal position;
handles.calcium_signals=cell(handles.volumes,1);
switch length(varargin)
    
    case 1
        
        handles.neuronal_position=cell(handles.volumes,1);
        handles.neuronal_idx=cell(handles.volumes,1);
        handles.ROIposition=cell(handles.volumes,1);
        for i=1:handles.volumes
            handles.ROIposition{i,1}(1,1)=1;
            handles.ROIposition{i,1}(1,2)=1;
            handles.ROIposition{i,1}(1,3)=handles.image_width;
            handles.ROIposition{i,1}(1,4)=handles.image_height;
        end
        
    case 2
        
        disp ('Error: where is the neuronal index');
        
    case 3
        
        handles.neuronal_position=varargin{2};
        handles.neuronal_idx=varargin{3};
        N=max(handles.neuronal_idx{1,1});
        handles.colorset=varycolor(N);
        handles.ROIposition=cell(handles.volumes,1);
        for i=1:handles.volumes
            handles.ROIposition{i,1}(1,1)=1;
            handles.ROIposition{i,1}(1,2)=1;
            handles.ROIposition{i,1}(1,3)=handles.image_width;
            handles.ROIposition{i,1}(1,4)=handles.image_height;
        end
        
    case 4
        
        handles.neuronal_position=varargin{2};
        handles.neuronal_idx=varargin{3};
        handles.ROIposition=varargin{4};
        N=max(handles.neuronal_idx{1,1});
        handles.colorset=varycolor(N);
        
    otherwise
        
        disp('Error: exceeds the number of inputs');
        
end

handles.slider1_is_active=1;

handles.signal=[];
handles.normalized_signal=[];
handles.ratio=[];

min_step=1/(handles.volumes-1);
max_step=5*min_step;
set(handles.slider1, ...
    'Enable','on', ...
    'Min',1, ...
    'Max',handles.volumes, ...
    'Value',1, ...
    'SliderStep', [min_step max_step]);

handles.current_volume=1;
handles.reference_volume=1;

handles.fontsize=10;

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes whole_brain_imaging wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = whole_brain_imaging_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.slider1_is_active=1;

handles.current_volume=round(get(hObject,'Value'));
set(handles.text1, 'String',strcat(num2str(handles.current_volume),'/',num2str(handles.volumes),' volumes; '));
axes(handles.axes1);
cla;
if handles.contrast_enhancement
    img=imagesc(contrast_enhancement(handles.img_stack{handles.current_volume,1}(:,:)),[handles.low handles.high]);
else
    img=imagesc(handles.img_stack{handles.current_volume,1}(:,:),[handles.low handles.high]);
end
colormap(gray);
set(handles.axes1, 'Visible', 'off');
set(img,'ButtonDownFcn', 'whole_brain_imaging(''ButtonDown_Callback'',gcbo,[],guidata(gcbo))');

%red channel

if ~isempty(handles.neuronal_position{handles.current_volume,1})
    
    N=size((handles.neuronal_position{handles.current_volume,1}),2);
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    handles.colorset=varycolor(max(neuron_idx));
    for j=1:N
        
        x=handles.neuronal_position{handles.current_volume,1}(1,j);
        y=handles.neuronal_position{handles.current_volume,1}(2,j);
        
        hold on; 
        
        handles.points{j}=text(x,y,num2str(neuron_idx(j)));
        set(handles.points{j}, 'Color', handles.colorset(neuron_idx(j),:));
        set(handles.points{j}, 'HorizontalAlignment','center');
        set(handles.points{j}, 'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownPoint_Callback'',gcbo,[],guidata(gcbo))');
        set(handles.points{j}, 'fontsize',handles.fontsize);
    end
    
end
 
%ROI

if ~isempty(handles.ROIposition{handles.current_volume,1})
    rect=handles.ROIposition{handles.current_volume,1};
    handles.ROI{handles.current_volume,1}=rectangle('Curvature', [0 0],'Position',rect,'EdgeColor','y');
    set(handles.ROI{handles.current_volume,1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownROI_Callback'',gcbo,[],guidata(gcbo))');
    
elseif ~isempty(handles.ROIposition{max(handles.current_volume-1,1),1})
    rect=handles.ROIposition{max(handles.current_volume-1,1),1};
    handles.ROI{handles.current_volume,1}=rectangle('Curvature', [0 0],'Position',rect,'EdgeColor','y');
    handles.ROIposition{handles.current_volume,1}=rect;
    set(handles.ROI{handles.current_volume,1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownROI_Callback'',gcbo,[],guidata(gcbo))');
end

%pixel intensity

handles.hp=impixelinfo;

set(handles.hp,'Position',[0 44+handles.axel_height+2,300,20]);

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


% ----click on the axes to identify neuronal positions and update neuronal
% position in rest of the frames ------------------


function ButtonDown_Callback(hObject, eventdata, handles)

[x,y]=getcurpt(handles.axes1);

if strcmp(get(handles.figure1,'selectionType'),'alt')
    
    centroids=handles.neuronal_position{handles.current_volume,1};
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    N=size(centroids,2);
    missing_idx=find_missing_idx(neuron_idx);
        
    prompt = {'Enter neuron index:'};
    dlg_title = 'Neuronal identification';
    num_lines = 1;
    def = {num2str(missing_idx)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    if ~isempty(answer)
        idx=str2num(answer{1});
        centroids(:,N+1)=[x;y];
        neuron_idx(N+1)=idx;
       F 
        handles.neuronal_position{handles.current_volume,1}=centroids;
        handles.neuronal_idx{handles.current_volume,1}=neuron_idx;
        handles.colorset=varycolor(max(neuron_idx));
   
        axes(handles.axes1);
        hold on;
    
        handles.points{N+1}=text(x,y,num2str(neuron_idx(N+1)));
        set(handles.points{N+1},  'Color', handles.colorset(neuron_idx(N+1),:));
        set(handles.points{N+1}, 'HorizontalAlignment','center');
        set(handles.points{N+1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownPoint_Callback'',gcbo,[],guidata(gcbo))');
        set(handles.points{N+1},'fontsize',handles.fontsize);
        hObject=handles.points{N+1};    
        guidata(hObject,handles);
    
    end
    
end

if strcmp(get(handles.figure1,'selectionType'),'normal')
    
    centroids=handles.neuronal_position{handles.current_volume,1};
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    N=size(centroids,2);
    missing_idx=find_missing_idx(neuron_idx);
        
    def = {num2str(missing_idx)};
    if def{1} ~= 0
        answer = def;
    else
        answer{1} = num2str(1);
    end
    
    if ~isempty(answer)
        idx=str2num(answer{1});
        centroids(:,N+1)=[x;y];
        neuron_idx(N+1)=idx;
        
        handles.neuronal_position{handles.current_volume,1}=centroids;
        handles.neuronal_idx{handles.current_volume,1}=neuron_idx;
        handles.colorset=varycolor(max(neuron_idx));
   
        axes(handles.axes1);
        hold on;
  
        handles.points{N+1}=text(x,y,num2str(neuron_idx(N+1)));
        set(handles.points{N+1},  'Color', handles.colorset(neuron_idx(N+1),:));
        set(handles.points{N+1}, 'HorizontalAlignment','center');
        set(handles.points{N+1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownPoint_Callback'',gcbo,[],guidata(gcbo))');
        set(handles.points{N+1},'fontsize',handles.fontsize);
        hObject=handles.points{N+1};    
        guidata(hObject,handles);
    
    end
        
end


% ----click on the axes to identify neuronal positions and update neuronal
% position in rest of the frames ------------------


function ButtonDownPoint_Callback(hObject, eventdata, handles)

[x,y]=getcurpt(handles.axes1);

if strcmp( get(handles.figure1,'selectionType') , 'extend')
    
    centroids=handles.neuronal_position{handles.current_volume,1};
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    N=size(centroids,2);
    
    distance_square=sum((centroids(1:2,:)'-repmat([x y],N,1)).^2,2);
    distance=sqrt(distance_square);
    [~,k]=min(distance);
    neuron_idx(k)=[];
    centroids(:,k)=[];
    
    handles.neuronal_position{handles.current_volume,1}=centroids;
    handles.neuronal_idx{handles.current_volume,1}=neuron_idx;
    
    delete(hObject);
    
    handles.colorset=varycolor(max(neuron_idx));    
    
    guidata(gcf,handles);

end
    


% --------------------------------------------------------------------
function SaveMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 [filename, pathname] = uiputfile('*.mat', 'Save Workspace as');
if length(filename) > 1
    fnamemat = strcat(pathname,filename);
    save(fnamemat);
end
    

% --------------------------------------------------------------------
function ExportMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ExportMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','neuron_position_data',handles.neuronal_position);
assignin('base','neuron_index_data',handles.neuronal_idx);
assignin('base','ROI_data',handles.ROIposition);
assignin('base','calcium_signal',handles.calcium_signals);


% --------------------------------------------------------------------
function LUTMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LUTMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg({'low','high'}, 'Cancel to clear previous', 1, ...
            {num2str(handles.low),num2str(handles.high)});
handles.low=str2double(answer{1});
handles.high=str2double(answer{2});
axes(handles.axes1);
cla;
img=imagesc(handles.img_stack{handles.current_volume,1}(:,:),[handles.low handles.high]);
colormap(gray);
set(img,'ButtonDownFcn', 'whole_brain_imaging(''ButtonDown_Callback'',gcbo,[],guidata(gcbo))');

guidata(hObject,handles);


% --------------------------------------------------------------------
function TrackingMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to TrackingMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imgStack=handles.img_stack{handles.current_volume,1};

if handles.current_volume>1
    
    answer = inputdlg({'reference volume for registration'}, 'Cancel to clear previous', 1, ...
        {num2str(1)});
    
    ref_volume_number=str2double(answer{1});
    
    imgStack_pre=handles.img_stack{ref_volume_number,1};
    
    if handles.contrast_enhancement
        
        registed_centers = identify_neuronal_position_gf(contrast_enhancement(imgStack),handles.ROIposition(handles.current_volume,1),...
            imgStack_pre,handles.ROIposition(ref_volume_number,1),handles.neuronal_position{ref_volume_number,1});
        
    else
        
        registed_centers = identify_neuronal_position_gf(imgStack,handles.ROIposition(handles.current_volume,1),...
            imgStack_pre,handles.ROIposition(ref_volume_number,1),handles.neuronal_position{ref_volume_number,1});
    end
    
    if ~isempty(registed_centers)
        handles.neuronal_position{handles.current_volume,1}=adjust_abnormal_centroids(registed_centers,handles.image_width,handles.image_height);
        handles.neuronal_idx{handles.current_volume,1}=handles.neuronal_idx{ref_volume_number,1};
        
    end
       
else
    
    disp('please proof read the first volume');
    
end
 
handles.reference_volume=ref_volume_number;

msgbox('Tracking Completed!');
guidata(hObject,handles);


% --------------------------------------------------------------------
function Tracking_thresholdItemMenu_Callback(hObject, eventdata, handles)
% hObject    handle to Tracking_thresholdItemMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg({'tracking threshold'}, 'Cancel to clear previous', 1, ...
            {num2str(handles.tracking_threshold)});
        
handles.tracking_threshold=str2double(answer{1});
guidata(hObject,handles);


function CaculateSignalMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CaculateSignalMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.calcium_signals=cell(handles.volumes,1);
answer = inputdlg({'soma size'},'calcium signal calculation',1,{'2'});

soma_radius = str2double (answer{1});

for j=1:handles.volumes
    
    N=length(handles.neuronal_idx{j,1});
    GC_signal=zeros(N,1);
    
    for k=1:length(handles.neuronal_idx{j,1})%calculating red part
        
        x=handles.neuronal_position{j,1}(1,k);
        y=handles.neuronal_position{j,1}(2,k);
        
        %if (x>=handles.image_width-50)&&(y<=100)
            
            %GC_signal(k)=0;
            %the neurons in the upper right corner are discarded
            
        %else
            
            c_mask=circle_mask_2D(handles.image_width,handles.image_height,x,y,soma_radius);
            
            img=handles.img_stack{j,1}(:,:);
            img0=img(c_mask);
            GC_signal(k)=mean(img0);
         
    end
        
        handles.calcium_signals{j,1}=GC_signal;
        
end
    fprintf('finish analyzing the %d volume \n',j);

%end
guidata(hObject, handles);


function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

if eventdata.VerticalScrollCount>0
    if handles.slider1_is_active &&(handles.current_volume<handles.volumes)
        handles.current_volume=handles.current_volume+1;       
    end    
elseif eventdata.VerticalScrollCount<0
    if handles.slider1_is_active && (handles.current_volume>1)
        handles.current_volume=handles.current_volume-1;
    end
end

set(handles.slider1,'Value',handles.current_volume);

set(handles.text1, 'String',strcat(num2str(handles.current_volume),'/',num2str(handles.volumes),' volumes; '));
axes(handles.axes1);
cla;
if handles.contrast_enhancement
    img=imagesc(contrast_enhancement(handles.img_stack{handles.current_volume,1}(:,:)),[handles.low handles.high]);
else
    img=imagesc(handles.img_stack{handles.current_volume,1}(:,:),[handles.low handles.high]);
end
colormap(gray);
set(handles.axes1, 'Visible', 'off');
set(img,'ButtonDownFcn', 'whole_brain_imaging(''ButtonDown_Callback'',gcbo,[],guidata(gcbo))');

%red channel

if ~isempty(handles.neuronal_position{handles.current_volume,1})

    N=size((handles.neuronal_position{handles.current_volume,1}),2);
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    handles.colorset=varycolor(max(neuron_idx));
    for j=1:N
   
            x=handles.neuronal_position{handles.current_volume,1}(1,j);
            y=handles.neuronal_position{handles.current_volume,1}(2,j);
               
                hold on; 
            
                handles.points{j}=text(x,y,num2str(neuron_idx(j)));
                set(handles.points{j}, 'Color', handles.colorset(neuron_idx(j),:));
                set(handles.points{j}, 'HorizontalAlignment','center');
                set(handles.points{j},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownPoint_Callback'',gcbo,[],guidata(gcbo))');
                set(handles.points{j},'fontsize',handles.fontsize);
    end
    
end

%ROI

if ~isempty(handles.ROIposition{handles.current_volume,1})
    rect=handles.ROIposition{handles.current_volume,1};
    handles.ROI{handles.current_volume,1}=rectangle('Curvature', [0 0],'Position',rect,'EdgeColor','y');
    set(handles.ROI{handles.current_volume,1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownROI_Callback'',gcbo,[],guidata(gcbo))');
    
elseif ~isempty(handles.ROIposition{max(handles.current_volume-1,1),1})
    rect=handles.ROIposition{max(handles.current_volume-1,1),1};
    handles.ROI{handles.current_volume,1}=rectangle('Curvature', [0 0],'Position',rect,'EdgeColor','y');
    handles.ROIposition{handles.current_volume,1}=rect;
    set(handles.ROI{handles.current_volume,1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownROI_Callback'',gcbo,[],guidata(gcbo))');
end

%online pixel intensity calculation
handles.hp=impixelinfo;

set(handles.hp,'Position',[0 44+handles.axel_height+2,300,20]);
guidata(hObject,handles);


% --- Executes on key press with focus on slider1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if eventdata.Key=='w'
    if handles.slider1_is_active &&(handles.current_volume<handles.volumes)
        handles.current_volume=handles.current_volume+1;       
    end    
elseif  eventdata.Key=='q'
    if handles.slider1_is_active && (handles.current_volume>1)
        handles.current_volume=handles.current_volume-1;
    end
end

set(handles.slider1,'Value',handles.current_volume);

set(handles.text1, 'String',strcat(num2str(handles.current_volume),'/',num2str(handles.volumes),' volumes; '));
axes(handles.axes1);
cla;
if handles.contrast_enhancement
    img=imagesc(contrast_enhancement(handles.img_stack{handles.current_volume,1}(:,:)),[handles.low handles.high]);
else
    img=imagesc(handles.img_stack{handles.current_volume,1}(:,:),[handles.low handles.high]);
end
colormap(gray);
set(handles.axes1, 'Visible', 'off');
set(img,'ButtonDownFcn', 'whole_brain_imaging(''ButtonDown_Callback'',gcbo,[],guidata(gcbo))');

%red channel

if ~isempty(handles.neuronal_position{handles.current_volume,1})

    N=size((handles.neuronal_position{handles.current_volume,1}),2);
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    handles.colorset=varycolor(max(neuron_idx)); %a bug fixed by fanchan
    for j=1:N
   
            x=handles.neuronal_position{handles.current_volume,1}(1,j);
            y=handles.neuronal_position{handles.current_volume,1}(2,j);
               
                hold on;
            
                handles.points{j}=text(x,y,num2str(neuron_idx(j)));
                set(handles.points{j}, 'Color', handles.colorset(neuron_idx(j),:));
                set(handles.points{j}, 'HorizontalAlignment','center');
                set(handles.points{j},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownPoint_Callback'',gcbo,[],guidata(gcbo))');
                set(handles.points{j},'fontsize',handles.fontsize); 
    end
    
end

%ROI

if ~isempty(handles.ROIposition{handles.current_volume,1})
    rect=handles.ROIposition{handles.current_volume,1};
    handles.ROI{handles.current_volume,1}=rectangle('Curvature', [0 0],'Position',rect,'EdgeColor','y');
    set(handles.ROI{handles.current_volume,1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownROI_Callback'',gcbo,[],guidata(gcbo))');
    
elseif ~isempty(handles.ROIposition{max(handles.current_volume-1,1),1})
    rect=handles.ROIposition{max(handles.current_volume-1,1),1};
    handles.ROI{handles.current_volume,1}=rectangle('Curvature', [0 0],'Position',rect,'EdgeColor','y');
    handles.ROIposition{handles.current_volume,1}=rect;
    set(handles.ROI{handles.current_volume,1},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownROI_Callback'',gcbo,[],guidata(gcbo))');
end

%online pixel intensity calculation
handles.hp=impixelinfo;

set(handles.hp,'Position',[0 44+handles.axel_height+2,300,20]);
guidata(hObject,handles);

% --------------------------------------------------------------------

function ROIMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ROIMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rect=getrect(gca);

if isempty(handles.ROI{handles.current_volume,1})
    handles.ROI{handles.current_volume,1}=rectangle('Curvature', [0 0],'Position',rect,'EdgeColor','y');
else
    set(handles.ROI{handles.current_volume,1},'Position',rect);
end

handles.ROIposition{handles.current_volume,1}=rect;

guidata(hObject,handles);


% --------------------------------------------------------------------
function ROIAllMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ROIAllMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg({'Start frame', 'End frame'}, '', 1);
istart = str2double(answer{1});
iend = str2double(answer{2});

for i = (istart+1):iend
    handles.ROI{i,1}=rectangle('Curvature', [0 0],'Position',handles.ROIposition{istart,1},'EdgeColor','y');
    set(handles.ROI{i,1},'Position',handles.ROIposition{istart,1});
    handles.ROIposition{i,1}=handles.ROIposition{istart,1};
    fprintf('Finish the %dth volume.\n',i);
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function zoom_Callback(hObject, eventdata, handles)
% hObject    handle to zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

checked=get(hObject,'Checked');
if strcmp(checked,'off')
    set(hObject,'Checked','on');
    zoom on;
    
else
    set(hObject,'Checked','off');
    zoom off;
   
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function Enhance_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to Enhance_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checked=get(hObject,'Checked');
if strcmp(checked,'off')
    set(hObject,'Checked','on');
    handles.contrast_enhancement=1;
else
    set(hObject,'Checked','off');
    handles.contrast_enhancement=0;
end

set(handles.slider1,'Value',handles.current_volume);

set(handles.text1, 'String',strcat(num2str(handles.current_volume),'/',num2str(handles.volumes),' volumes; '));
axes(handles.axes1);
cla;
if handles.contrast_enhancement
    img=imagesc(contrast_enhancement(handles.img_stack{handles.current_volume,1}(:,:)),[handles.low handles.high]);
else
    img=imagesc(handles.img_stack{handles.current_volume,1}(:,:),[handles.low handles.high]);
end
colormap(gray);
set(handles.axes1, 'Visible', 'off');
set(img,'ButtonDownFcn', 'whole_brain_imaging(''ButtonDown_Callback'',gcbo,[],guidata(gcbo))');

if ~isempty(handles.neuronal_position{handles.current_volume,1})

    N=size((handles.neuronal_position{handles.current_volume,1}),2);
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    handles.colorset=varycolor(max(neuron_idx));
    for j=1:N
   
            x=handles.neuronal_position{handles.current_volume,1}(1,j);
            y=handles.neuronal_position{handles.current_volume,1}(2,j);
            
            hold on;  

            handles.points{j}=text(x,y,num2str(neuron_idx(j)));
            set(handles.points{j},  'Color', handles.colorset(neuron_idx(j),:));
            set(handles.points{j}, 'HorizontalAlignment','center');
            set(handles.points{j},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownPoint_Callback'',gcbo,[],guidata(gcbo))');
            set(handles.points{j},'fontsize',handles.fontsize);
   
    end
    
end
handles.hp=impixelinfo;

set(handles.hp,'Position',[0 44+handles.axel_height+2,300,20]);
guidata(hObject,handles);



% --------------------------------------------------------------------
function reset_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to reset_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.ROI{handles.current_volume,1})
    handles.ROIposition{handles.current_volume,1}(1,1)=1;
    handles.ROIposition{handles.current_volume,1}(1,2)=1;
    handles.ROIposition{handles.current_volume,1}(1,3)=handles.image_width;
    handles.ROIposition{handles.current_volume,1}(1,4)=handles.image_height;
    rect=handles.ROIposition{handles.current_volume,1};
    set(handles.ROI{handles.current_volume,1},'Position',rect);
else
    disp('Error: cannot find ROI in the previous volume');
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function Display_reference_Callback(hObject, eventdata, handles)
% hObject    handle to Display_reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'reference volume to be displayed'}, 'Cancel to clear previous', 1, ...
            {num2str(1)});
        
handles.reference_volume=str2double(answer{1});

figure ('Numbertitle','off','Name','Reference Slide Display',...
         'Position', [100 100 handles.axel_width handles.axel_height+30]); 
     
set(gca, ...
    'Visible', 'off', ...
    'Units', 'pixels', ...
    'Position', [0 0 handles.axel_width handles.axel_height]);

cla;

imagesc(handles.img_stack{handles.reference_volume,1}(:,:,1),[handles.low handles.high]);
colormap(gray);
axis equal;
axis off;

text1=uicontrol(gcf,'Style','text');
set(text1, 'Units','pixels');
set(text1, 'Position',[0 0+handles.axel_height-10 handles.axel_width 30]);
set(text1, 'HorizontalAlignment','center');
set(text1, 'String',strcat('The', num2str(handles.reference_volume), 'th Volume '));

N=size((handles.neuronal_position{handles.reference_volume,1}),2);
neuron_idx=handles.neuronal_idx{handles.reference_volume,1};

for j=1:N
    
    x=handles.neuronal_position{handles.reference_volume,1}(1,j);
    y=handles.neuronal_position{handles.reference_volume,1}(2,j);
      
    hold on;  
    h=text(x,y,num2str(neuron_idx(j)));
    set(h, 'HorizontalAlignment','center');
    set(h,  'Color', handles.colorset(neuron_idx(j),:));
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function fontsize_Callback(hObject, eventdata, handles)
% hObject    handle to fontsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dlg_title='font size';
prompt={'font size'};
marks=inputdlg(prompt,dlg_title);
handles.fontsize=str2num(marks{1}(1,:));
set(handles.slider1,'Value',handles.current_volume);

set(handles.text1, 'String',strcat(num2str(handles.current_volume),'/',num2str(handles.volumes),' volumes; '));
axes(handles.axes1);
cla;
if handles.contrast_enhancement
    img=imagesc(contrast_enhancement(handles.img_stack{handles.current_volume,1}(:,:)),[handles.low handles.high]);
else
    img=imagesc(handles.img_stack{handles.current_volume,1}(:,:),[handles.low handles.high]);
end
colormap(gray);
set(handles.axes1, 'Visible', 'off');
set(img,'ButtonDownFcn', 'whole_brain_imaging(''ButtonDown_Callback'',gcbo,[],guidata(gcbo))');

if ~isempty(handles.neuronal_position{handles.current_volume,1})

    N=size((handles.neuronal_position{handles.current_volume,1}),2);
    neuron_idx=handles.neuronal_idx{handles.current_volume,1};
    handles.colorset=varycolor(max(neuron_idx));
    for j=1:N
   
            x=handles.neuronal_position{handles.current_volume,1}(1,j);
            y=handles.neuronal_position{handles.current_volume,1}(2,j);
            
            hold on;  

            handles.points{j}=text(x,y,num2str(neuron_idx(j)));
            set(handles.points{j},  'Color', handles.colorset(neuron_idx(j),:));
            set(handles.points{j}, 'HorizontalAlignment','center');
            set(handles.points{j},'ButtonDownFcn', 'whole_brain_imaging(''ButtonDownPoint_Callback'',gcbo,[],guidata(gcbo))');
            set(handles.points{j},'fontsize',handles.fontsize);
   
    end
    
end
handles.hp=impixelinfo;

set(handles.hp,'Position',[0 44+handles.axel_height+2,300,20]);
guidata(hObject,handles);


% --------------------------------------------------------------------
function Tracking_all_Callback(hObject, eventdata, handles)
% hObject    handle to Tracking_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg({'reference volume for registration'}, 'Cancel to clear previous', 1, ...
    {num2str(1)});

ref_volume_number=str2double(answer{1});

imgStack_pre=handles.img_stack{ref_volume_number,1};

for i=1:handles.volumes
    imgStack=handles.img_stack{i,1};
    if i>1
        
        if handles.contrast_enhancement
            
            registed_centers = identify_neuronal_position_gf(contrast_enhancement(imgStack),handles.ROIposition(i,1),...
                imgStack_pre,handles.ROIposition(ref_volume_number,1),handles.neuronal_position{ref_volume_number,1});
        else
             
            registed_centers = identify_neuronal_position_gf(imgStack,handles.ROIposition(i,1),...
                imgStack_pre,handles.ROIposition(ref_volume_number,1),handles.neuronal_position{ref_volume_number,1});
        end
        
        if ~isempty(registed_centers)
            handles.neuronal_position{i,1}=adjust_abnormal_centroids(registed_centers,handles.image_width,handles.image_height);
            handles.neuronal_idx{i,1}=handles.neuronal_idx{ref_volume_number,1};
        end    
        
    else
               
        disp('Please proof read the first volume.');
        
    end
    
    fprintf('Finish the %dth volume.\n',i);
    imgStack_pre=handles.img_stack{i,1};
    ref_volume_number=i;
end

handles.reference_volume=ref_volume_number;

msgbox('Tracking Completed!');
guidata(hObject,handles);


% --------------------------------------------------------------------
function FastTrackingAll_Callback(hObject, eventdata, handles)
% hObject    handle to FastTrackingAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg({'Start frame', 'End frame'}, '', 1);
istart = str2double(answer{1});
iend = str2double(answer{2});

for i = (istart+1):iend
    
    imgStack=handles.img_stack{i,1};
    ref_volume_number=i-1;
    if handles.contrast_enhancement
        
        registed_centers = identify_neuronal_position_old_method(contrast_enhancement(imgStack),handles.ROIposition{i,1},...
            handles.neuronal_position{ref_volume_number,1},handles.tracking_threshold);
    else
        
        registed_centers = identify_neuronal_position_old_method(imgStack,handles.ROIposition{i,1},...
            handles.neuronal_position{ref_volume_number,1},handles.tracking_threshold);
    end
    
    handles.neuronal_position{i,1}=registed_centers;
    handles.neuronal_idx{i,1}=handles.neuronal_idx{ref_volume_number,1};
    
    fprintf('Finish the %dth volume.\n',i);
end

msgbox('Tracking Completed!');
guidata(hObject,handles);


% --------------------------------------------------------------------
function FastTracking_Callback(hObject, eventdata, handles)
% hObject    handle to FastTracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg({'Ref frame', 'Target frame'}, '', 1);
ref = str2double(answer{1});
tar = str2double(answer{2});

imgStack=handles.img_stack{tar,1};
ref_volume_number=ref;
if handles.contrast_enhancement
    
    registed_centers = identify_neuronal_position_old_method(contrast_enhancement(imgStack),handles.ROIposition{tar,1},...
        handles.neuronal_position{ref_volume_number,1},handles.tracking_threshold);
else
    
    registed_centers = identify_neuronal_position_old_method(imgStack,handles.ROIposition{tar,1},...
        handles.neuronal_position{ref_volume_number,1},handles.tracking_threshold);
end

handles.neuronal_position{tar,1}=registed_centers;
handles.neuronal_idx{tar,1}=handles.neuronal_idx{ref_volume_number,1};

fprintf('Finish the %dth volume.\n',tar);
guidata(hObject,handles);
