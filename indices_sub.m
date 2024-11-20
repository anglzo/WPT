function subbanda = indices_sub(number, wav_coef, mapa1, mapa2)

    % Inicializar el vector como una celda para poder guardar arreglos de diferente tamaño
    indices_subbandas = cell(1, 84);  
    contador = 1;  % Inicia el índice en 1
    subbanda = [];

    % Nivel 1: Enumerar las subbandas de primer nivel que existen en wav_coef
    for i = 1:numel(wav_coef)
        indices_subbandas{contador} = [i];  % Guardar solo el nivel 1
        contador = contador + 1;
    end

    % Nivel 2: Revisar `mapa1` para determinar las subbandas en el segundo nivel
    for i = 1:numel(wav_coef)
        if mapa1(i) == 1  % Si esta subbanda se descompone en el nivel 2
            for j = 1:numel(wav_coef{i})
                indices_subbandas{contador} = [i, j];  % Guardar como un vector de dos elementos [nivel1 nivel2]
                contador = contador + 1;
            end
        end
    end

    % Nivel 3: Revisar `mapa2` para determinar las subbandas en el tercer nivel
    for i = 1:numel(wav_coef)
        if mapa1(i) == 1  % Solo proceder si el nivel 2 está activo para esta subbanda
            for j = 1:numel(wav_coef{i})
                if mapa2(i, j) == 1  % Si esta subbanda se descompone en el nivel 3
                    for k = 1:numel(wav_coef{i}{j})
                        indices_subbandas{contador} = [i, j, k];  % Guardar como un vector de tres elementos [nivel1 nivel2 nivel3]
                        contador = contador + 1;
                    end
                end
            end
        end
    end

    % Seleccionar la subbanda específica solicitada por 'number'
    if number <= length(indices_subbandas)
        subbanda = indices_subbandas{number};
    else
        error('Número fuera del rango de subbandas generadas.');
    end
end
