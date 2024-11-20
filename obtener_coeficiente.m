function coef = obtener_coeficiente(wav_coef, subband_path)
    % Accede a la subbanda especificada en subband_path
    coef = wav_coef;  % Inicia desde la celda completa

    % Recorre cada índice en subband_path para acceder al nivel adecuado
    for i = 1:length(subband_path) 
        % Verifica si el nivel actual es una celda antes de intentar acceder
        if iscell(coef)
            coef = coef{subband_path(i)};
        else
            error('El nivel actual no es una celda. Verifica la estructura de wav_coef.');
        end
    end
end