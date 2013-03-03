clear all
clc
vid = VideoReader('Pool1.avi');
nFrames = vid.NumberOfFrames;
vidHeight = vid.Height;
vidWidth = vid.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
    'colormap', []);

% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(vid, k);
end


frame1= mov(8).cdata;
frame2= mov(10).cdata;
frame3= mov(11).cdata;
frame4= mov(12).cdata;
frame5= mov(13).cdata;
frame6= mov(14).cdata;
frame7= mov(15).cdata;
frame8= mov(16).cdata;
frame9= mov(17).cdata;
frame10= mov(18).cdata;
frame11= mov(19).cdata;
frame12= mov(20).cdata;
frame13= mov(21).cdata;
frame14= mov(22).cdata;
frame15= mov(23).cdata;
frame16= mov(24).cdata;
imwrite(frame1, 'frame1.png', 'png');
imwrite(frame2, 'frame2.png', 'png');
imwrite(frame3, 'frame3.png', 'png');
imwrite(frame4, 'frame4.png', 'png');
imwrite(frame5, 'frame5.png', 'png');
imwrite(frame6, 'frame6.png', 'png');
imwrite(frame7, 'frame7.png', 'png');
imwrite(frame8, 'frame8.png', 'png');
imwrite(frame9, 'frame9.png', 'png');
imwrite(frame10, 'frame10.png', 'png');
imwrite(frame11, 'frame11.png', 'png');
imwrite(frame12, 'frame12.png', 'png');
imwrite(frame13, 'frame13.png', 'png');
imwrite(frame14, 'frame14.png', 'png');
imwrite(frame15, 'frame15.png', 'png');
imwrite(frame16, 'frame16.png', 'png');