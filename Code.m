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
imagem_cinza = rgb2gray(imagem2);
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

    for i=1:vidHeight
        for j=1:vidWidth
            I(i,j)=O1(i,j)-O2(i,j);
        end
    end

%Elemento estruturante
B = strel('disk',4,0);
%Abertura para permanecer somente a bola na imagem
I = imopen(I,B);
figure(3);
imshow(I);    
    
%Descobrir o centro da bola
for i=1:vidHeight
  f=1;
  for j=1:vidWidth
         if(I(i,j)==1)
           pos_bola1(f)=i;
           pos_bola2(f)=j;
           f=f+1;
         end
  end
end      

MAX=max(pos_bola1);
MIN=min(pos_bola1);
bola_linha=MIN+floor((MAX-MIN)/2);
MAX=max(pos_bola2);
MIN=min(pos_bola2);
bola_coluna=MIN+floor((MAX-MIN)/2);

%Mutiplicaçã imagem binaria pela inicial para estração do cookie
for RGB=1:3
    for i=1:vidHeight
        for j=1:vidWidth
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
BW = im2bw(imagem_cinza,0.117);
for i=1:vidHeight
  for j=1:vidWidth
         if(BW(i,j)==1)
                BW(i,j)=0;
         else
             BW(i,j)=1;
         end
  end
end 

%elimina ojetos com quantidade maior de pixels que o limiar
Limiar  =  500;
imshow(BW);
L = bwlabel(BW,8);
min(min(L))
max(max(L))

for i = min(min(L)) : max(max(L))
    [X, Y] = find(L == i);
    [x, y] = size(X);
    if(x > Limiar)
        for j = 1:vidHeight
            for k = 1:vidWidth
                if(L(j, k) == i)
                    L(j, k) = 0;
                end
            end
        end
    end
end
figure(1)
imshow(uint8(L * 100));

%fim da rotina        

%[r,c] = find(L == 2)


% Size a figure based on the video's width and height.
hf = figure;
set(hf, 'position', [150 150 vidWidth vidHeight])

% Play back the movie once at the video's frame rate.
movie(hf, mov, 1, xyloObj.FrameRate);