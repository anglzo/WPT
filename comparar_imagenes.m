function [mse_val, psnr_val, ssim_val] = comparar_imagenes(img1, img2)
    % Convertir imágenes a doble para mayor precisión
     % Si las entradas son celdas, extraer su contenido
    if iscell(img1)
        img1 = img1{1};  % Extraer el contenido si es una celda
    end
    if iscell(img2)
        img2 = img2{1};  % Extraer el contenido si es una celda
    end
    
    img1 = double(img1);
    img2 = double(img2);

    % MSE (Mean Squared Error)
    mse_val = mean((img1(:) - img2(:)).^2);

    % PSNR (Peak Signal-to-Noise Ratio)
    max_pixel_value = 255;  % Para imágenes de 8 bits
    psnr_val = 10 * log10(max_pixel_value^2 / mse_val);

    % SSIM (Structural Similarity Index)
    ssim_val = ssim(uint8(img1), uint8(img2));

    %coeficiente de correlación
    img1_vector = img1(:);
    img2_vector = img2(:);

    % Calcular la correlación
    corr_matrix = corrcoef(img1_vector, img2_vector);
    corr_value = corr_matrix(1, 2);

    % Mostrar resultados
    fprintf('MSE: %0.4f\n', mse_val);
    fprintf('coeficiente de correlación: %0.4f\n', corr_value);
    fprintf('SSIM: %0.4f\n', ssim_val);
end