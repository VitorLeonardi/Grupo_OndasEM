Rl = inputdlg('Entre resist�ncia da carga: ','Sample',[1 5]);
m = inputdlg('Entre tens�o da fonte','Sample',[1 5]);#modo Vs m=1,2
Rl = str2num(Rl{1});#resistencia da carga
m = str2num(m{1});#modo da fonte de tens�o (1 ou 2)

#qualqur valor diferente de 1 ou 2 � considerado 2
if (m != 1 && m != 2)
  m = 2;
endif

#funcao para tensao da fonte
function y = Vs(t,m,uf,Z)
  if (m == 2);
    y = 2;
  elseif (t < Z/(10*uf))
    y = 1;
  else
    y = 0;
  endif
endfunction

Rs = 75; #resist�ncia fonte
Z0 = 50 ; #resist�ncia da linha
c = 3e+8; #velocidade da luz
uf = 0.9*c; #velocidade de propaga��o do sinal
#valores acima na descri��o do projeto 

Z = 10;  # comprimento da linha
T = 10*Z/uf;  #tempo limite, na decri��o do projeto 

L = Z0/uf; #Z0 = L* Uf
C = L/Z0**2; #Z0 = sqrt(L/C)
#L e C s�o derivados de uf e Z0

dz = Z/1e+4;
z = -Z:dz:0;
dt = dz/(1.2*uf); # dt < dz/uf
t = 0:dt:T;
Lz = length(z);
Lt = length(t);
i = v = zeros( 2 , Lz );

k1 = 0.5*(Rs*C*dz/dt - 1);
k2 = 0.5*(Rs*C*dz/dt + 1);

#cria o gr�fico
figure('Name',['Rl = ',num2str(Rl),', m = ', num2str(m)],'NumberTitle','off');
V = v(1,:);
I = i(1,:);
subplot(2,1,1);
plot (z, V,'ydatasource','V');
title('Tens�o');
xlabel("z (m)");
ylabel("v (V)");
axis([-Z 0 -0.6/m 1.1*m]);
subplot(2,1,2);
plot (z, I,'ydatasource','I');
title('Corrente');
xlabel("z (m)");
ylabel("i (A)");
axis([-Z 0 -0.012/m 0.02*m]);
w = waitbar(0,'t = 0s');

tic
M = 80;#1 em cada 100 tempos sao plotados, maior efici�ncia
for n = 2:Lt-1
  #condi��o de fronteira z = -Z (fonte)
  v(2,1) = (k1/k2)*v(1,1) - (Rs*i(1,1) - (Vs((n+1/2)*dt,m,uf,Z) + Vs((n-1/2)*dt,m,uf,Z))/2)/k2;
  
  #equa��o de update tens�o, linha sem perdas
  v(2,2:Lz-1) = v(1,2:Lz-1) - dt*(i(1,2:Lz-1) - i(1,1:Lz-2))/(C*dz);
  
  #condi��o de fronteira z = 0 (carga)
  if (Rl == 0)
    v(2,Lz) = 0;
    i(2,Lz) = i(2,Lz-1);
  elseif (Rl == inf)
    v(2,Lz) = v(2,Lz-1);
    i(2,Lz) = 0;
  else
    v(2,Lz) = (k1/k2)*v(1,Lz) + Rl*i(1,Lz-1)/k2;
    i(2,Lz) = v(2,Lz)/Rl;
  endif  
  
  #equa��o de update corrente, linha sem perdas
  
  i(2,1:Lz-1) = i(1,1:Lz-1) - dt*(v(2,2:Lz)-v(2,1:Lz-1))/(L*dz);
  
  v(1,:) = v(2,:);
  i(1,:) = i(2,:);
  
  #atualiza o gr�fico, 1 em cada M itera��es, grande aumento em performance.
  if ( mod(n,M) == 0) 
    I = i(1,:);
    V = v(1,:);
    if (mod(n,10*M) == 0)
    s = num2str(n*dt);
    waitbar(n/Lt,w,['t = ',s,'s']);
    endif
    refreshdata
    drawnow
  endif
  
endfor
toc
clear