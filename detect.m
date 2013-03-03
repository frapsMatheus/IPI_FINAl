function detect(traking_prox_x,bola_coluna)
% compute the background image
Imzero = zeros(240,320,3);
for i = 1:10
Im{i} = double(imread(['DATA/',int2str(i),'.png']));
Imzero = Im{i}+Imzero;
end
Imback = Imzero/10;
[MR,MC,Dim] = size(Imback);
% loop over all images
for i = 1 : 39
  % load image
  Im = (imread(['DATA/',int2str(i), '.png']));
  imshow(Im)
  Imwork = double(Im);

  %extract ball
  [cc(i),cr(i),radius,flag] = extractball(Imwork,Imback,i,traking_prox_x,bola_coluna);%,fig1,fig2,fig3,fig15,i);
  if flag==0
    continue
  end
    hold on
    for c = -0.9*radius: radius/20 : 0.9*radius
      r = sqrt(radius^2-c^2);
      plot(cc(i)+c,cr(i)+r,'g.')
      plot(cc(i)+c,cr(i)-r,'g.')
    end
 %Slow motion!
      pause(0.02)
end

figure

  plot(cr,'g*')
  hold on
  plot(cc,'r*')
end