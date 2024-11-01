function mostrar_imagen(wav_coef)

   % Mostrar la estructura jerárquica de los coeficientes
    img = concatenar_wavelet_jerarquico(wav_coef);
    
    % Mostrar la imagen resultante
    figure;

    imshow(uint8(img), []);
    title('Descomposición wavelet');
end

function img = concatenar_wavelet_jerarquico(wav_coef)
    % Para el coeficiente LL (si es una celda, sigue descomponiendo)
    if iscell(wav_coef{1})
        LL = concatenar_wavelet_jerarquico(wav_coef{1});
    else
        LL = wav_coef{1};  % Si no es una celda, ya es el coeficiente LL
    end
    
    % Para el coeficiente LH
    if iscell(wav_coef{2})
        LH = concatenar_wavelet_jerarquico(wav_coef{2});
    else
        LH = wav_coef{2};  % Si no es una celda, ya es el coeficiente LH
    end
    
    % Para el coeficiente HL
    if iscell(wav_coef{3})
        HL = concatenar_wavelet_jerarquico(wav_coef{3});
    else
        HL = wav_coef{3};  % Si no es una celda, ya es el coeficiente HL
    end
    
    % Para el coeficiente HH
    if iscell(wav_coef{4})
        HH = concatenar_wavelet_jerarquico(wav_coef{4});
    else
        HH = wav_coef{4};  % Si no es una celda, ya es el coeficiente HH
    end

    % Concatenar los coeficientes en una sola imagen para mostrar
    img = [LL, HL; LH, HH];


end
