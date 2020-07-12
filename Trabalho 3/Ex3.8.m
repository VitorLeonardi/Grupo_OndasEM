#3.7
m = menu('Ez(0,0) = ','sin(1e8*t)','exp(-(1e8*(t-2e-8))**2)','1')

prompt = {'Condutividaded El�trica = '};

answer = inputdlg(prompt, "Ex3.8" ,[1 10]);
cel = str2num(answer{1})
e0 = 8.8541878128e-12;   #permissividade eletrica do vacuo
u0 = 1.25663706212e-6;   #permeabilidade magnetica do vacuo
c = 1/sqrt(e0*u0); #velocidade da luz
pmg = 0; #perda magnetica

L = 5; #tamanho mesh;  lim Ez = 0
#T = 1; #tempo limite

dx = L/50; #dx = dy
x = -L:dx:L;#preciza conter x = 0
dt = dx/(sqrt(2)*c);

Lx = length(x); #numero de divisoes espaciais em cada coordenada(x,y)

Lt = 400; #numero de passos temporais
#constantes da equacoa de update
Ca = (1 - cel*dt/(2*e0))/(1 + cel*dt/(2*e0)); #3.31a
Cb = (dt/(e0*dx))/(1 + cel*dt/(2*e0)); #3.31b
Da = (1 - pmg*dt/(2*u0))/(1 + pmg*dt/(2*u0));#3.32a
Db = (dt/(u0*dx))/(1 + pmg*dt/(2*u0)); #3.32b

#matrizes para calculos, armazenam apenas os estados atual e anterior
Ez = Hx = Hy = zeros(Lx,Lx,Lt);
#{
Ez(i,j) = Ez < i*dx + 1/2 , j*dy + 1/2 >
Hx(i,j) = Hx < i*dx + 1/2 , j*dy >
Hy(i,j) = Hy < i*dx , j*dy + 1/2 >
#}

#M
#J

function y = inicond(t,m)
  switch m
  case 1
    y = sin(1e8*t);
  case 2
    y = exp(-(1e8*(t-2e-8))**2);
  case 3
    y = 1;
  endswitch
endfunction

z = find(x == 0); #centro da mesh


for n = 1:Lt
  Ez(z,z,n) = inicond(n*dt,m); #condiao inicial no centro 
  
  #equacoes de update
  #Ez = 0 nas fronteiras
  Ez(2:Lx-1,2:Lx-1,n+1) = Ca*Ez(2:Lx-1,2:Lx-1,n) + Cb*(Hy(3:Lx,2:Lx-1,n) - Hy( 2:Lx-1,2:Lx-1,n) + Hx(2:Lx-1,2:Lx-1,n) - Hx(2:Lx-1,3:Lx,n)); # eq 3.41a
  Ez(z,z,n+1) = inicond(n*dt,m);#conserta Ez(0,0)
  
  Hx(1:Lx,2:Lx,n+1) = Da*Hx(1:Lx,2:Lx,n) + Db*( Ez(1:Lx,1:Lx-1,n+1) - Ez(1:Lx,2:Lx,n+1) );# eq 3.41b
  Hy(2:Lx,1:Lx,n+1) = Da*Hy(2:Lx,1:Lx,n) + Db*( Ez(2:Lx,1:Lx,n+1) - Ez(1:Lx-1,1:Lx,n+1) );# eq 3.41c

endfor

#plot

X = meshgrid(x,x);
Z = Ez(1:Lx,1:Lx,1);
Zmin =  min(min(min(Ez)));
Zmax =  max(max(max(Ez)));

h = surf(X, X', Z ,'zdatasource','Z','cdatasource','Z');
axis([-L L -L L Zmin Zmax]);
xlabel('x[ m ]','fontsize',12);
ylabel('y[ m ]','fontsize',12);
zlabel('Ez(x,y) [ V/m ]','fontsize',12);
str = {'Ez(0,0) = sen( 1e8*t ) V/m','Ez(0,0) = exp(-(1e8*(t-2e-8))**2) V/m','Ez(0,0) = 1 V/m'};
title(str(m),'fontsize',15);

colormap(jet(128))
colorbar('fontsize',12);
caxis([0.7*Zmin 0.7*Zmax]);

an = annotation('textbox', [0.05, 0.85, 0, 0], 'String', 't = 0s','edgecolor','none','fontsize',15,'fontweight','bold');

for n = 1:Lt
  Z = Ez(1:Lx,1:Lx,n);
  set(an,'String',["t = " num2str(n*dt) 's'])
  refreshdata
  drawnow
endfor
#saveas(h,"Ex3.7.png","png");
