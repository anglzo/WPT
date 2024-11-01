function [wav_coef_mod,imgSecretaF, imgSecretaC, numBits]= incrustar_imagen_v2(wav_coef, imgSecreta, subbandasSeleccionadas)
    
    % Convertir la imagen secreta a bits
    [imgSecretaF, imgSecretaC] = size(imgSecreta);
    imgSecreta = de2bi(imgSecreta(:), 8, 'left-msb');  % Convertir a binario
    bitsImagenSecreta = reshape(imgSecreta', [], 1);   % Colapsar en un vector de bits
    cantidadBitsImagenSecreta = numel(bitsImagenSecreta);
    numBitsCoef = 16; 
    [numSub,prof] = size(subbandasSeleccionadas);
    cantidadBitsImagenPortada = 0;
    coef = wav_coef;
    for i = 1:numSub
        for j = 1:prof
            coef = coef{1,subbandasSeleccionadas(i,j)};
            p=1;
        end
        cantidadBitsImagenPortada =  cantidadBitsImagenPortada + numel(coef)*numBitsCoef ;
        coef = wav_coef;
    end



    numBits = ceil(((numBitsCoef*cantidadBitsImagenSecreta)^2)/(cantidadBitsImagenPortada^2));
    disp(["cantidad de bits imagen portada :", cantidadBitsImagenPortada]);
    disp(["cantidad de bits imagen secreta:", cantidadBitsImagenSecreta]);
    disp(["número de bits a modificar:", numBits] );
    
    contadorBits = 1;  % Contador para los bits de la imagen secreta
    wav_coef_mod = wav_coef;  % Crear copia de los coeficientes
    
    % Recorrer las subbandas seleccionadas
    for i = 1:size(subbandasSeleccionadas, 1)
        subbanda = subbandasSeleccionadas(i, :);
        
        % Extraer los coeficientes de la subbanda seleccionada
        coeficientes = wav_coef{subbanda(1)}{subbanda(2)}{subbanda(3)};
        
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
        
        % Guardar el tamaño original para restaurarlo después
        coefSize = size(coefVector);
        
        % Convertir los coeficientes a un vector unidimensional
        coefVector = reshape(coefVector, numel(coefVector), 1);
        
        % Recorrer los coeficientes y modificar los bits LSB
        for j = 1:numel(coefVector)
            % Redondear a enteros y asegurarse de que sean positivos y finitos
            coefEntero = round(coefVector(j));
            
            % Verificar si el valor del coeficiente es válido para incrustar
            if ~isfinite(coefEntero) || coefEntero < 0
                coefEntero = 0;  % Si no es válido, asignar un valor neutral
            end
            
            % Calcular el número de bits necesarios para representar el coeficiente
            numBitsCoef = max(ceil(log2(coefEntero + 1)), 1);  % Asegura al menos 1 bit
            
            % Convertir coeficiente actual a binario usando el número necesario de bits
            coefBin = de2bi(coefEntero, numBitsCoef, 'left-msb');
            
            % Reemplazar los bits menos significativos con los bits de la imagen secreta
            for b = 1:min(numBits, length(coefBin))  % Asegúrate de no exceder el tamaño del coeficiente
                if contadorBits <= cantidadBitsImagenSecreta
                    coefBin(end-b+1) = bitsImagenSecreta(contadorBits);  % Cambiar el bit LSB
                    contadorBits = contadorBits + 1;
                else
                    break;
                end
            end
            
            % Convertir de nuevo a decimal
            coefVector(j) = bi2de(coefBin, 'left-msb');
            
            % Detener si ya hemos insertado todos los bits de la imagen secreta
            if contadorBits > cantidadBitsImagenSecreta
                break;
            end
        end
        
        % Restaurar la forma original de los coeficientes usando el tamaño guardado
        wav_coef_mod{subbanda(1)}{subbanda(2)}{subbanda(3)}  = reshape(coefVector, coefSize);
        
        % Detener si ya hemos insertado todos los bits de la imagen secreta
        if contadorBits > cantidadBitsImagenSecreta
            break;
        end
    end
end