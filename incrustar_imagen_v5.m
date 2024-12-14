function [wav_coef_mod, bitsincrus] = incrustar_imagen_v5(wav_coef, infSecre, subbandasSeleccionada, nlsb)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% INCRUSTACIÓN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Esta función toma como parámetros de entrada el conjunto de
    % coeficientes que se va a modificar, la sección de la imagen secreta que se
    % va a incrustar en este conjunto de coeficientes y el número de LSB que se
    % van a modificar en el proceso de incrustación 

    wav_coef_mod = wav_coef;
 

    % Número de bits para representar los coeficientes
    numBitsCoef = 16;
    coef = obtener_coeficiente(wav_coef, subbandasSeleccionada);

    % Cantidad de bits imagen secreta/portada
    cantidadBitsImagenPortada = numel(coef) * numBitsCoef;
    cantidadBitsImagenSecreta = numel(infSecre);

    % Tamaño original matriz de coeficientes
    coefSize = size(coef);

    % Convertir los coeficientes a un vector 
    coefVector = reshape(coef, numel(coef), 1);
    coefVector = coefVector';

    %%  Convertir a binario
    coefVector = double(coefVector); % Asegurarse de que coefVector sea numérico
    coef_bin = zeros(length(coefVector), numBitsCoef + 1); % Una columna adicional para el signo
    signo = sign(coefVector); % Vector de 1s y -1s
    signo_bits = ceil((signo + 1) / 2); % Vector de 1s (positivo) y 0s (negativo)
    bits = int2bit(abs(coefVector), numBitsCoef, true); % Devuelve un vector de bits
    bits = reshape(bits, numBitsCoef, [])'; % Se transforma en una matriz de m filas (# coeficientes) y numbits columnas
    coef_bin(:, 1) = signo_bits;
    coef_bin(:, 2:end) = bits;

    %%  Proceso de incrustación
    total_info = nlsb*length(coefVector); % Información total que se va a modificar en los coeficientes
    if nlsb == 4

        bin_secre = [infSecre];
        bin_secre = reshape(bin_secre,nlsb,length(bin_secre)/nlsb)';


    else

        add = total_info - cantidadBitsImagenSecreta; %si son iguales no modifica la longitd porque add es 0
        bin_secre = [infSecre zeros(1,add)];
        bin_secre = reshape(bin_secre,nlsb,length(bin_secre)/nlsb)';

    end
    bitsincrus = bin_secre;
   
    coef_bin_stego = coef_bin;
    coef_bin_stego(:, end - nlsb + 1:end) = bin_secre;

    %% Proceso de recuperación de los coeficientes stego 
    signo_est = 2 * coef_bin_stego(:, 1) - 1;
    bits_est = reshape(coef_bin_stego(:, 2:end)', numel(coef_bin_stego(:, 2:end)), 1);
    coef_est = bit2int(bits_est, numBitsCoef, true);
    coef_est = (signo_est .* coef_est)'; % Recupera los valores positivos y negativos

   if length(subbandasSeleccionada) == 1
    wav_coef_mod{subbandasSeleccionada(1)} = reshape(coef_est, coefSize);
elseif length(subbandasSeleccionada) == 2
    wav_coef_mod{subbandasSeleccionada(1)}{subbandasSeleccionada(2)} = reshape(coef_est, coefSize);
elseif length(subbandasSeleccionada) == 3
    wav_coef_mod{subbandasSeleccionada(1)}{subbandasSeleccionada(2)}{subbandasSeleccionada(3)} = reshape(coef_est, coefSize);
   end
end