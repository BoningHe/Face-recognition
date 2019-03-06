function varargout = face(varargin)
% FACE MATLAB code for face.fig
%      FACE, by itself, creates a new FACE or raises the existing
%      singleton*.
%
%      H = FACE returns the handle to a new FACE or the handle to
%      the existing singleton*.
%
%      FACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACE.M with the given input arguments.
%
%      FACE('Property','Value',...) creates a new FACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before face_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to face_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help face

% Last Modified by GUIDE v2.5 07-May-2018 13:30:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @face_OpeningFcn, ...
                   'gui_OutputFcn',  @face_OutputFcn, ...
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


% --- Executes just before face is made visible.
function face_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to face (see VARARGIN)

% Choose default command line output for face
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes face wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = face_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global template_rgb
%% 读取图片
[filename1, pathname1] = uigetfile('*.jpg', 'read image'); %读取视频文件
if isequal(filename1,0)   %判断是否选择
    msgbox('no image');
else
    pathfile=fullfile(pathname1, filename1);  %获得图片路径
    template_rgb=imread(pathfile);
    template_rgb = imresize(template_rgb,0.3);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global template_rgb
%% 读取视频
[filename1, pathname1] = uigetfile('*.mp4', 'read video'); %读取视频文件
if isequal(filename1,0)   %判断是否选择
    msgbox('no video');
else
    pathfile=fullfile(pathname1, filename1);  %获得图片路径
    video_obj=VideoReader(pathfile);
end
frame_number=video_obj.NumberOfFrames;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 读入待检测图像
for i=1:frame_number
    disp(i);
    I=read(video_obj,i);
    src_rgb = imresize(I,0.3);
    %转换为灰度图
    template=rgb2gray(template_rgb);    template = im2double(template);
    src=rgb2gray(src_rgb);  src = im2double(src);
    
    axes(handles.axes1);
    imshow(template_rgb),title('template');
    
    %求的模板与原始图像的大小
    tempSize=size(template);
    tempHeight=tempSize(1); tempWidth=tempSize(2);
    srcSize=size(src);
    srcHeight=srcSize(1); srcWidth=srcSize(2);
    
    %在图片的右侧与下侧补0
    %By default, paddarray adds padding before the first element and after the last element along the specified dimension.
    srcExpand=padarray(src,[tempHeight-1 tempWidth-1],'post');
    
    %初始化一个距离数组 tmp:mj  template:x
    %参见《数字图像处理》 Page561
    distance=zeros(srcSize);
    for height=1:srcHeight
        for width= 1:srcWidth
            tmp=srcExpand(height:(height+tempHeight-1),width:(width+tempWidth-1));
            %diff= template-tmp;
            %distance(height,width)=sum(sum(diff.^2));
            %计算决策函数
            distance(height,width)=sum(sum(template'*tmp-0.5.*(tmp'*tmp)));
        end
    end
    
    %寻找决策函数最大时的索引
    maxDis=max(max(distance));
    [x, y]=find(distance==maxDis);
    
    %绘制匹配结果
    str1 = strcat('Matching results','(','Frame',num2str(i),')');
    axes(handles.axes2);
    imshow(src_rgb);title(str1);
    hold on;
    rectangle('Position',[y x tempWidth tempHeight],'LineWidth',2,'LineStyle','--','EdgeColor','r'),
    pause(0.01);
end