function [img_reconstruida] = reconstruir_wavelet(wav_coef, lScheme, nivel, mapa1, mapa2)

    % Nivel 3: Si el nivel es 3, primero reconstruimos las subbandas del tercer nivel
    if nivel >= 3
        for k = 1:4
            wav_coef1 = wav_coef{1,k}; % Subbandas de nivel 2
            if mapa1(k) == 1
                
                for kk = 1:4
                    wav_coef2 = wav_coef1{1,kk}; % Subbandas de nivel 3

                    if mapa2(k,kk) == 1

                       matriz = zeros(128, 128, 'double');

                       img_r_LL =  wav_coef2{1,1};%0.0220
                       img_r_LH{:} = wav_coef2{1,2}; %0.9302       
                       img_r_HL{:} = wav_coef2{1,3}; %0.9354 con SSIM
                       img_r_HH{:} = wav_coef2{1,4}; %0.9387 con SSIM

                       % Reconstruir la subbanda del tercer nivel
                       wav_coef1{1,kk} = ilwt2(img_r_LL, img_r_LH, img_r_HL, img_r_HH, LiftingScheme=lScheme, Int2Int=true);
                    end
                    

                    
                end
                % Si se ha reconstruido alguna subbanda en el tercer nivel, guardamos el resultado
                
                if sum(mapa2(k,:)) ~= 0
                    wav_coef{1,k} = wav_coef1;
                end
            end
        end
    end

    % Nivel 2: Reconstruimos las subbandas del segundo nivel
    if nivel >= 2
        for k = 1:4
            wav_coef3 = wav_coef{1,k};
            if mapa1(k) == 1

                matriz = zeros(256, 256, 'double');
                img_r_LL = wav_coef3{1,1};
                img_r_LH{:} = wav_coef3{1,2};
                
                img_r_HL{:} = wav_coef3{1,3};
                img_r_HH{:} = wav_coef3{1,4};
                
                % Reconstruir la subbanda del segundo nivel
                wav_coef{1,k} = ilwt2(img_r_LL, img_r_LH, img_r_HL, img_r_HH, LiftingScheme=lScheme, Int2Int=true);
            end
        end
    end

    % Nivel 1: Reconstruimos la imagen a partir de las subbandas del primer nivel
    img_r_LL = wav_coef{1,1};
    img_r_LH{:} = wav_coef{1,2};
    img_r_HL{:} = wav_coef{1,3};
    img_r_HH{:} = wav_coef{1,4};
    
    % Reconstruir la imagen
    img_reconstruida = ilwt2(img_r_LL, img_r_LH, img_r_HL, img_r_HH,LiftingScheme=lScheme, Int2Int=true);
end

