function [ex, wav_coef] = descomponer_energia(img, archivos, num_img, lScheme, nivel, mapa1, mapa2)
    
    ex = {};
    % Realizar la primera descomposición
    [LL, LH, HL, HH] = lwt2(img, LiftingScheme=lScheme, Level=1, Int2Int=true);
    wav_coef = cell(1,4);
    wav_coef{1,1} = LL;
    wav_coef{1,2} = LH{:,:};
    wav_coef{1,3} = HL{:,:};
    wav_coef{1,4} = HH{:,:};

    
    % Calcular y mostrar entropías para el nivel 1
    [ex1] = calcular_energias(wav_coef);
    ex{1,1} = ex1;

    % Si hay descomposición para el segundo nivel, proceder
    if nivel >= 2
        for k = 1:4
            if mapa1(k) == 1
                img_r = wav_coef{1,k};
                [LL, LH, HL, HH] = lwt2(img_r, LiftingScheme=lScheme, Level=1, Int2Int=true);
                wav_coef1 = cell(1,4);
                wav_coef1{1,1} = LL;
                wav_coef1{1,2} = LH{:,:};
                wav_coef1{1,3} = HL{:,:};
                wav_coef1{1,4} = HH{:,:};
                wav_coef{1,k} = wav_coef1;

                % Calcular y mostrar entropías para el nivel 2
               
                [ex2] = calcular_energias(wav_coef1);
                ex{2,k} = ex2;
            
   
            end
        end
    end

    % Si hay descomposición para el tercer nivel, proceder
    if nivel >= 3
        for k = 1:4
            if mapa1(k) == 1
                wav_coef1 = wav_coef{1,k};
                wav_coef2 = wav_coef1;
                for kk = 1:4
                    if mapa2(k,kk) == 1
                        img_r = wav_coef1{1,kk};
                        [LL, LH, HL, HH] = lwt2(img_r, LiftingScheme=lScheme, Level=1, Int2Int=true);
                        wav_coef3 = cell(1,4);
                        wav_coef3{1,1} = LL;
                        wav_coef3{1,2} = LH{:,:};
                        wav_coef3{1,3} = HL{:,:};
                        wav_coef3{1,4} = HH{:,:};
                        wav_coef2{1,kk} = wav_coef3;

                        % Calcular y mostrar entropías para el nivel 3
                        
                        [ex3] = calcular_energias(wav_coef3);
                        ex{3,k}{kk} = ex3;
                       
                    end
                end
                if sum(mapa2(k,:)) ~= 0
                    wav_coef{1,k} = wav_coef2;
                end
            end
        end
    end

end
