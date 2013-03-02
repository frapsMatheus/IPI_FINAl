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
f=1;
for i=1:vidHeight
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
BW = im2bw(imagem2,0.13);
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
Limiar1  =  200;
Limiar2  =  80;
imshow(BW);
L = bwlabel(BW,8);
min(min(L))
max(max(L))

for i = min(min(L)) : max(max(L))
    [X, Y] = find(L == i);
    [x, y] = size(X);
    if(x > Limiar1 || x<Limiar2)
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

%Elemento estruturante
B = strel('rectangle',(9:-8:1));
%Abertura para diminuir os erros
O2 = imopen(L,B);
figure(3);
imshow(O2);

%Correção de eliminicação de borda
B = strel('square',2);
O2 = imdilate(O2,B);
figure(4);
imshow(O2);
for i=1:vidHeight
    for j=1:vidWidth
        L(i,j)=L(i,j)-O2(i,j);
    end
end
figure(1)
L = uint8(L * 100);
imshow(L);
L = im2bw(L,0);
imshow(L);
%Mutiplicaçã imagem binaria pela inicial para estração do cookie
for RGB=1:3
    for i=1:vidHeight
        for j=1:vidWidth
            imagem2(i,j,RGB)= imagem2(i,j)*uint8(L(i,j));
        end
    end
end

figure(5);
imshow(imagem2);
imwrite(imagem2,'taco_segmentado1.png','png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Criando Vetor chute de Movimento
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Descobrir ponta do taco
%Descobrir o centro da bola
f=1;
for i=1:vidHeight
    for j=1:vidWidth
        if(L(i,j)==1)
            pos_taco1(f)=i;
            pos_taco2(f)=j;
            f=f+1;
        end
    end
end
tam = size(pos_taco1);
DIF2 = 9999;
for i=1:tam(2)
    DIF = [bola_linha,bola_coluna] - [pos_taco1(i),pos_taco2(i)];
    SAD = sum(sum(abs(DIF)));
    if(SAD<DIF2)
        DIF2 = SAD;
        ponta_x=pos_taco2(i);
        ponta_y=pos_taco1(i);
    end    
end    

x = 1:vidWidth;
figure(10);
imshow(mov(1).cdata);
colormap gray
hold on;
if(bola_coluna - ponta_x == 0)
m = (bola_linha - ponta_y)/1;
else
    m = (ponta_y - bola_linha)/(ponta_x - bola_coluna);
end    
y = (m*(x-bola_coluna))+bola_linha;
plot(x,y,'.');
axis([0 vidWidth 0 vidHeight])
hold on;


% Size a figure based on the video's width and height.
hf = figure;
set(hf, 'position', [150 150 vidWidth vidHeight])

% Play back the movie once at the video's frame rate.
movie(hf, mov, 1, vid.FrameRate);