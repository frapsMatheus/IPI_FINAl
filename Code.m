clear all
clc
vid = VideoReader('Pool2.avi');
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
bola= mov(1).cdata;
taco= mov(1).cdata;
borda= mov(1).cdata;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Segmentação bola
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BW = im2bw(bola,graythresh(bola));
imshow(BW);

%Elemento estruturante
B = strel('disk',3,0);
%Abertura para diminuir os erros
I = imopen(BW,B);

%Dilatação para recuperar a bola
O = strel('disk',11,0);
O1 = imdilate(I,O);


%Elemento estruturante
B = strel('rectangle',(vidHeight/8:-(vidHeight/8)+1:1));
%Abertura para diminuir os erros
O2 = imopen(O1,B);


for i=1:vidHeight
    for j=1:vidWidth
        I(i,j)=O1(i,j)-O2(i,j);
    end
end

%Elemento estruturante
B = strel('disk',4,0);
%Abertura para permanecer somente a bola na imagem
I = imopen(I,B);


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
            bola(i,j,RGB)= bola(i,j)*uint8(I(i,j));
        end
    end
end


imwrite(bola,'bola_segmentada1.png','png');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Segmentação taco
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BW = im2bw(taco,0.13);
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


%Elemento estruturante
B = strel('rectangle',(9:-8:1));
%Abertura para diminuir os erros
O2 = imopen(L,B);


%Correção de eliminicação de borda
B = strel('square',2);
O2 = imdilate(O2,B);

for i=1:vidHeight
    for j=1:vidWidth
        L(i,j)=L(i,j)-O2(i,j);
    end
end

L = uint8(L * 100);

L = im2bw(L,0);

%Mutiplicaçã imagem binaria pela inicial para estração do cookie
for RGB=1:3
    for i=1:vidHeight
        for j=1:vidWidth
            taco(i,j,RGB)= taco(i,j)*uint8(L(i,j));
        end
    end
end


imwrite(taco,'taco_segmentado1.png','png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Detectar bordas mesa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:vidHeight
    for j=1:vidWidth
        if(borda(i,j,1)<120||borda(i,j,2)>130||borda(i,j,3)>115)
            for RGB=1:3
                borda(i,j,RGB)= 0;
            end
        else
            for RGB=1:3
                borda(i,j,RGB)= 255;
            end
        end
    end
end

BW = im2bw(borda,graythresh(borda));

%Elemento estruturante
B = strel('rectangle',(2:8:10));
%Abertura para diminuir os erros
O2 = imopen(BW,B);


%Dilatação para recuperar a bola
B = strel('rectangle',(4:2:6));
O2 = imdilate(O2,B);


%elimina ojetos com quantidade maior de pixels que o limiar
Limiar1  =  800;
L_borda = bwlabel(O2,8);
min(min(L_borda))
max(max(L_borda))

for i = min(min(L_borda)) : max(max(L_borda))
    [X, Y] = find(L_borda == i);
    [x, y] = size(X);
    if(x < Limiar1)
        for j = 1:vidHeight
            for k = 1:vidWidth
                if(L_borda(j, k) == i)
                    L_borda(j, k) = 0;
                end
            end
        end
    end
end
borda = im2bw(uint8(L_borda * 100),0.01);


%Elemento estruturante
B = strel('rectangle',(2:4:6));
%Erosão para corresão de bordas
borda = imerode(borda,B);


%elimina ojetos com quantidade maior de pixels que o limiar
Limiar1  =  800;
L_borda = bwlabel(borda,8);
min(min(L_borda))
max(max(L_borda))

for i = min(min(L_borda)) : max(max(L_borda))
    [X, Y] = find(L_borda == i);
    [x, y] = size(X);
    if(x < Limiar1)
        for j = 1:vidHeight
            for k = 1:vidWidth
                if(L_borda(j, k) == i)
                    L_borda(j, k) = 0;
                end
            end
        end
    end
end
borda = im2bw(uint8(L_borda * 100),0.01);


imwrite(borda,'Borda_segmentada.png','png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Criando Vetor chute de Movimento
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Descobrir ponta do taco
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
%Procura ponto mais perto da bola
for i=1:tam(2)
    DIF = [bola_linha,bola_coluna] - [pos_taco1(i),pos_taco2(i)];
    SAD = sum(sum(abs(DIF)));
    if(SAD<DIF2)
        DIF2 = SAD;
        ponta_x=pos_taco2(i);
        ponta_y=pos_taco1(i);
    end
end
%Calculo de equação da reta
colormap gray
hold on;
if(bola_coluna - ponta_x == 0)
    m = (bola_linha - ponta_y)/1;
else
    m = (ponta_y - bola_linha)/(ponta_x - bola_coluna);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Movimento com espelhamento
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xa = bola_coluna;
ya = bola_linha;
traking_count=0;
%Espelhamento
for x = vidWidth:-1:1;
    y2(x) = round((m*(x-xa))+ya);
    if(y2(x)==bola_linha && x==bola_coluna)
       traking_count=1;   
    elseif(traking_count==1)
        traking_prox_x=x;
        traking_count=0;
    end    
    if(y2(x)<1||y2(x)>240)
        y2(x)=0;
    elseif(borda(y2(x),x)==1)
        %Espelho angulo de entrada igual 90-alfa, angulo dentro do triangulo =
        %alfa, angulo externo = 180-alfa;
        m= -m;
        xa = xa-(2*(xa-x));
        
    end
end

%Calculo de equação da reta
x = 1:vidWidth;
figure(11);
imshow(mov(1).cdata);
colormap gray
hold on;
plot(x,y2,'.');
axis([0 vidWidth 0 vidHeight])
hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Traking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
detect(traking_prox_x,bola_coluna);