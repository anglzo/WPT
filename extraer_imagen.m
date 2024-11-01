function img_secreta_extraida = extraer_imagen(wav_coef_mod, subbandasSeleccionadas, imgSecretaF, imgSecretaC, numBits)
    bitsImagenSecreta = [];  % Donde se almacenarán los bits extraídos
    
    % Recorrer las subbandas seleccionadas
    for i = 1:size(subbandasSeleccionadas, 1)
        subbanda = subbandasSeleccionadas(i, :);
        
        % Extraer los coeficientes de la subbanda seleccionada
        coeficientes = wav_coef_mod{subbanda(1)}{subbanda(2)};
        
        % Convertir coeficientes a vector (asegúrate que sea matriz numérica)
        if iscell(coeficientes)
            coefVector = cell2mat(coeficientes);  % Convierte celda a matriz si es necesario
        else
            coefVector = coeficientes;  % Ya es una matriz
        end
        
        % Guardar el tamaño original para restaurarlo después
        coefSize = size(coefVector);
        
        % Convertir los coeficientes a un vector unidimensional
        coefVector = reshape(coefVector, numel(coefVector), 1);
        
        % Recorrer los coeficientes y extraer los bits LSB
        for j = 1:numel(coefVector)
            % Redondear a enteros y asegurarse de que sean positivos y finitos
            coefEntero = round(coefVector(j));
            
            % Verificar si el valor del coeficiente es válido para extraer
            if ~isfinite(coefEntero) || coefEntero < 0
                coefEntero = 0;  % Si no es válido, asignar un valor neutral
            end
            
            % Calcular el número de bits necesarios para representar el coeficiente
            numBitsCoef = max(ceil(log2(coefEntero + 1)), 1);  % Asegura al menos 1 bit
            
            % Ajustar el número de bits para que no exceda la cantidad de bits de coeficiente
            bitsAExtraer = min(numBits, numBitsCoef);
            
            % Verificar que haya suficientes bits para extraer
            if bitsAExtraer > 0
                % Convertir coeficiente actual a binario usando el número necesario de bits
                coefBin = de2bi(coefEntero, numBitsCoef, 'left-msb');
                
                % Extraer los bits menos significativos
                bitsLSB = coefBin(end - bitsAExtraer + 1:end);
                
                % Almacenar los bits extraídos
                bitsImagenSecreta = [bitsImagenSecreta; bitsLSB(:)];
            end
            
            % Detener si hemos extraído suficientes bits para reconstruir la imagen secreta
            if numel(bitsImagenSecreta) >= imgSecretaF * imgSecretaC * 8
                break;
            end
        end
        
        % Detener si hemos extraído suficientes bits
        if numel(bitsImagenSecreta) >= imgSecretaF * imgSecretaC * 8
            break;
        end
    end
    
    % Asegurarse de que los bits extraídos tengan la longitud correcta
    bitsImagenSecreta = bitsImagenSecreta(1:imgSecretaF * imgSecretaC * 8);
    
    % Reconstruir la imagen secreta desde los bits extraídos
    img_secreta_extraida = reshape(bitsImagenSecreta, 8, [])';  % Organizar de nuevo en bloques de 8 bits
    img_secreta_extraida = uint8(bi2de(img_secreta_extraida, 'left-msb'));  % Convertir a decimal
    img_secreta_extraida = reshape(img_secreta_extraida, imgSecretaF, imgSecretaC);  % Reconstruir la imagen
end
