function [img_secreta_extraida, bits_rx] = extraer_imagen(wav_coef_rx, vec_sub, imgSecretaF, imgSecretaC, bitsimg, numBits)

numBitsCoef = 16;
bits_rx = [];

for i= 1:length(numBits)
    subbanda = vec_sub{i};

    if ~(numBits(i) == 0)
        coef_est = obtener_coeficiente(wav_coef_rx, subbanda);
        coef_est_vector = reshape(coef_est, numel(coef_est), 1);
        coef_est_vector = coef_est_vector';
        bits_recp = int2bit(abs(coef_est_vector),numBitsCoef,true);
        
        bits_recp = reshape(bits_recp,numBitsCoef,[])'; %se transforma en una matriz de m filas (# coeficientes) y numbits columnas
        
        bin_secre_recp = bits_recp(:,end-numBits(i)+1:end); % recupero las últimas columnas que se modificaron
        
        bin_secre_recp = reshape(bin_secre_recp',numel(bin_secre_recp),1)';
       
        bits_rx = [bits_rx bin_secre_recp];
    end



end

% 
% coef_est_vector = reshape(coef_est, numel(coef_est), 1);
% coef_est_vector = coef_est_vector';
% bits_recp = int2bit(abs(coef_est_vector),numBitsCoef,true);
% 
% bits_recp = reshape(bits_recp,numBitsCoef,[])'; %se transforma en una matriz de m filas (# coeficientes) y numbits columnas
% bin_secre_recp = bits_recp(:,end-numBits+1:end); % recupero las últimas columnas que se modificaron
% bin_secre_recp = reshape(bin_secre_recp',numel(bin_secre_recp),1)';

%bin_secre_recp = reshape(bits_rx',numel(bits_rx),1)';
bin_secre_recp = bits_rx(1:(imgSecretaF * imgSecretaC * 8)); %se eliminan los ceros que se agregaron anteriormente 
bin_secre_recp =  reshape(bin_secre_recp, 8, [])';
pixelesImagenSecreta = bi2de(bin_secre_recp,'left-msb' );

% Reconstruir la imagen secreta a partir de los píxeles extraídos
img_secreta_extraida = reshape(pixelesImagenSecreta, imgSecretaF, imgSecretaC);

end
