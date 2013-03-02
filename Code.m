xyloObj = VideoReader('Meu Filme5.avi');

nFrames = xyloObj.NumberOfFrames;
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);

% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(xyloObj, k);
end
imagem1= mov(1).cdata;
imagem2= mov(1).cdata;
figure(1);
imshow(imagem1);
figure(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Segmentação bola
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BW = im2bw(imagem1,graythresh(imagem1));
imshow(BW);

%Elemento estruturante
B = strel('disk',3,0);
%Abertura para diminuir os erros
I = imopen(BW,B);
figure(3);
imshow(I);

%Dilatação para recuperar a bola
O = strel('disk',4,0);
O1 = imdilate(I,O);
figure(4);
imshow(O1);

%Elemento estruturante
B = strel('rectangle',(vidHeight/8:-(vidHeight/8)+1:1));
%Abertura para diminuir os erros
O2 = imopen(O1,B);
figure(3);
imshow(O2);

    for i=1:vidHeight-1
        for j=1:vidWidth-1
            I(i,j)=O1(i,j)-O2(i,j);
        end
    end

%Elemento estruturante
B = strel('disk',3,0);
%Abertura para permanecer somente a bola na imagem
I = imopen(I,B);
figure(3);
imshow(I);    
    
%Descobrir o centro da bola
%Elemento estruturante
B = strel(I);
%Abertura para permanecer somente a bola na imagem
I = imerode(I,B);
figure(3);
imshow(I);    
    


%Mutiplicaçã imagem binaria pela inicial para estração do cookie
for RGB=1:3
    for i=1:vidHeight-1
        for j=1:vidWidth-1
            imagem1(i,j,RGB)= imagem1(i,j)*uint8(I(i,j));
        end
    end
end





%figure(5);
imshow(imagem1);
imwrite(imagem1,'bola_segmentada1.png','png');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Segmentação taco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3);
BW = im2bw(imagem2,0.04);
imshow(BW);

%Dilatação para recuperar a bola para eliminar o cookie imagem
O = strel('disk',4,0);
O = imdilate(I,O);
figure(5);
imshow(O);

%Mutiplicaçã imagem binaria pela inicial para estração do cookie
for RGB=1:3
    for i=1:vidHeight-1
        for j=1:vidWidth-1
            imagem2(i,j,RGB)= imagem2(i,j)*uint8(O(i,j));
        end
    end
end
figure(6);
imshow(imagem2);
%imwrite(imagem,'taco_segmentada1.png','png');

% Size a figure based on the video's width and height.
hf = figure;
set(hf, 'position', [150 150 vidWidth vidHeight])

% Play back the movie once at the video's frame rate.
movie(hf, mov, 1, xyloObj.FrameRate);