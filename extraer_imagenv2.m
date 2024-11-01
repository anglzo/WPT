function img_secreta_extraida = extraer_imagenv2(wav_coef_mod, subbandasSeleccionadas, imgSecretaF, imgSecretaC, numBitsLSB)
    % Parámetros:
    % wav_coef_mod: los coeficientes con la imagen secreta incrustada.
    % subbandasSeleccionadas: subbandas de los coeficientes donde se incrustó la información.
    % imgSecretaF: número de filas de la imagen secreta.
    % imgSecretaC: número de columnas de la imagen secreta.
    % numBitsLSB: número de bits LSB que se modificaron en cada coeficiente.
    
    % Inicializar un vector para almacenar los bits extraídos
    bitsImagenSecretaExtraidos = [];
    
    % Inicializar el contador de bits extraídos
    contadorBits = 1;
    
    % Recorrer las subbandas seleccionadas
    for i = 1:size(subbandasSeleccionadas, 1)
        subbanda = subbandasSeleccionadas(i, :);
        
        % Extraer los coeficientes de la subbanda seleccionada
        coeficientes = wav_coef_mod{subbanda(1)}{subbanda(2)}{subbanda(3)};
        
        % Convertir coeficientes a vector (asegúrate que sea matriz numérica)
        if iscell(coeficientes)
            coefVector = cell2mat(coeficientes);  % Convierte celda a matriz si es necesario
        else
            coefVector = coeficientes;  % Ya es una matriz
        end
        
        % Verifica que los coeficientes sean valores numéricos válidos
        if ~isnumeric(coefVector)
            error('Los coeficientes de la subbanda seleccionada no son numéricos.');
        end
        
        % Convertir los coeficientes a un vector unidimensional
        coefVector = reshape(coefVector, numel(coefVector), 1);
        signoCoef = sign(coefVector);
        coefVectorAbs = abs(coefVector);
        
        % Recorrer los coeficientes para extraer los bits LSB
        for j = 1:numel(coefVector)
            % Convertir el coeficiente actual a binario (numBitsCoef = 16)
            coefBin = de2bi(coefVectorAbs(j),16, 'left-msb');
            
            % Extraer los bits menos significativos
            lsbBits = coefBin(end-numBitsLSB+1:end);  % Obtener los últimos bits
            
            % Añadir los bits extraídos al vector de bits de la imagen secreta
            bitsImagenSecretaExtraidos = [bitsImagenSecretaExtraidos; lsbBits(:)];
            
            % Detener si ya hemos extraído suficientes bits
            if contadorBits + length(lsbBits) - 1 >= imgSecretaF * imgSecretaC * 8
                bitsImagenSecretaExtraidos = bitsImagenSecretaExtraidos(1:imgSecretaF * imgSecretaC * 8);
                break;
            end
            
            contadorBits = contadorBits + length(lsbBits);
        end
        
        % Detener si ya hemos extraído suficientes bits
        if contadorBits >= imgSecretaF * imgSecretaC * 8
            break;
        end
    end
    
    % Reconstruir la imagen secreta desde los bits extraídos
    % Agrupar los bits en bloques de 8 (porque cada píxel es de 8 bits)
    bitsImagenSecretaExtraidos = reshape(bitsImagenSecretaExtraidos, 8, [])';
    
    % Convertir los bits a valores decimales (valores de píxeles)
    pixelesImagenSecreta = bi2de(bitsImagenSecretaExtraidos, 'left-msb');
    
    % Reconstruir la imagen secreta a partir de los píxeles extraídos
    img_secreta_extraida = reshape(pixelesImagenSecreta, imgSecretaF, imgSecretaC);
    
    % Mostrar la imagen secreta extraída
    figure;
    imshow(uint8(img_secreta_extraida));
    title('Imagen Secreta Extraída');
end
