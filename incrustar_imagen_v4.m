
function [wav_coef_mod,imgSecretaF, imgSecretaC, bitsImagenSecreta, numBits]= incrustar_imagen_v2(wav_coef, imgSecreta, subbandasSeleccionada)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% INCRUSTACIÓN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%esta función tomaría como parámetros de entrada el conjunto de
%coeficientes que se va a modificar, la sección de la imagen secreta que se
%va a incustrar en este conjunto de coeficientes y el número de LSB que se
%van a modificar en el proceso de incustración 

wav_coef_mod = wav_coef;
[imgSecretaF, imgSecretaC] = size(imgSecreta);
imgSecreta = de2bi(imgSecreta(:), 8, 'left-msb');  % Convertir a binario
bitsImagenSecreta = reshape(imgSecreta', [], 1);   % Colapsar en un vector de bits
bitsImagenSecreta = bitsImagenSecreta';

%numero de bits para representar los coeficientes
numBitsCoef = 16;
coef = obtener_coeficiente(wav_coef, subbandasSeleccionada);

%cantidad bits imagen secreta/portada
cantidadBitsImagenPortada =  numel(coef)*numBitsCoef ;
cantidadBitsImagenSecreta = numel(bitsImagenSecreta);

%tamaño original matriz de coeficientes
coefSize = size(coef);

% Convertir los coeficientes a un vector 
coefVector = reshape(coef, numel(coef), 1);
coefVector = coefVector';

numBits = ceil(((numBitsCoef*cantidadBitsImagenSecreta)^2)/(cantidadBitsImagenPortada^2));

%vector con el conjunto de coeficientes wavelet

%vector de bists que representa parte de la información secreta 
cant_infSecre = 20; %tamaño del vector de bits que representa la información secreta
bin_secre_O = randsrc(1,cant_infSecre,[0 1]); 

%número de bits menos significativos que se van a modificar en este grupo
%de coeficientes 
nlsb = 2; 

%% convertir a binario

coef_bin = zeros(length(coefVector),numBitsCoef+1);%una columna adicional para el signo

signo = sign(coefVector); %vector de 1s y-1s
signo_bits = ceil((signo+1)/2); %vector de 1s (positivo) y 0s (negativo)
                                %el ceil es para aproximar hacia arriba,
                                %porque en el caso delvalor cero la función
                                %signo devuelve un 0

bits = int2bit(abs(coefVector),numBitsCoef,true); %devuelve un vector de bits
bits = reshape(bits,numBitsCoef,[])'; %se transforma en una matriz de m filas (# coeficientes) y numbits columnas
%se concatenan los resultados en la matriz 
coef_bin(:,1) = signo_bits;
coef_bin(:,2:end) = bits;

%% proceso de incrustación 

total_info = numBits*length(coefVector); %esta es la información total que se va a modificar en los coeficientes
if total_info >= cantidadBitsImagenSecreta  
    add = total_info - cantidadBitsImagenSecreta; %si son iguales no modifica la longitd porque add es 0
    bin_secre = [bitsImagenSecreta zeros(1,add)];
    bin_secre = reshape(bin_secre,numBits,length(bin_secre)/numBits)'; %se vuelve una matriz para hacer la sustitución completa
else
    disp("tamaños incompatibles")
    beep
    beep
    beep
    return;
    %exit  %%este comando cierra MATLAB
end
coef_bin_stego = coef_bin;
coef_bin_stego(:,end-numBits+1:end) = bin_secre;

%% proceso de recuperación de los coeficientes stego 
signo_est = 2*coef_bin_stego(:,1) - 1;
%bits_est = reshape(values_bin(:,2:end)',numel(values_bin(:,2:end)),1); %verifica que el proceso esté bien
bits_est = reshape(coef_bin_stego(:,2:end)',numel(coef_bin_stego(:,2:end)),1);
coef_est = bit2int(bits_est,numBitsCoef,true);

coef_est = (signo_est.*coef_est)'; %recupera los valores positivos y negativos
wav_coef_mod{subbandasSeleccionada(1)}{subbandasSeleccionada(2)}{subbandasSeleccionada(3)} = reshape(coef_est, coefSize);


% %% proceso de recuperación de los bits de la información secreta
% %desde el receptor 
% values_est = values_est'; 
% bits_recp = int2bit(abs(values_est),numbits,true); %devuelve un vector de bits 
%                                                    %en este punto el signo no interesa
% bits_recp = reshape(bits_recp,numbits,length(bits_recp)/numbits)'; %se transforma en una matriz de m filas (# coeficientes) y numbits columnas
% 
% bin_secre_recp = bits_recp(:,end-nlsb+1:end); % recupero las últimas columnas que se modificaron
% bin_secre_recp = reshape(bin_secre_recp',numel(bin_secre_recp),1)';
% 
% %sin la variable cant_infSecre, no es posible realizar la recuperación 
% %esto asumiendo que siempre se tengan imágenes cuadradas, sino tocaría
% %especificar # de filas y # de columnas 
% bin_secre_recp = bin_secre_recp(1:cant_infSecre); %se eliminan los ceros que se agregaron anteriormente 
% 
% isequal(bin_secre_recp,bin_secre_O) %devuelve un 1 si los dos vectores son iguales 