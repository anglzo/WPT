function [Ce, C, M, Red, Hen, Reh, Hz, Ds, HzDs, wav_coef] = descomponer_parametros(img, archivos, num_img, lScheme, nivel, mapa1, mapa2,sz_img)

%%  métricas basadas en la energía y la emtropía 
Ce = {};  % índice de concentración de la energía
C = {};   % índice de compacidad
M = {};   % momentos estadísticos
Red = {}; % relación entre la energía y la dispersión
Hen = {};  % entropía energética
Reh = {}; % relación entre la energía y la entropía energética
Hz = {};  % entropía Z
Ds = {};  % desviación estandar
HzDs = {}; %Hz*Ds

%% secciones de la función de descomposición 

% Realizar la primera descomposición
[LL, LH, HL, HH] = lwt2(img, LiftingScheme=lScheme, Level=1, Int2Int=true);
wav_coef = cell(1,4);
wav_coef{1,1} = LL;
wav_coef{1,2} = LH{:,:};
wav_coef{1,3} = HL{:,:};
wav_coef{1,4} = HH{:,:};

% Calcular las métricas para el nivel 1
[Ce1, C1, M1, Red1, He1, Reh1, Hz1, Ds1, HzDs1] = calcular_metricas(wav_coef,sz_img);
Ce{1,1} = Ce1;
C{1,1} = C1;
M{1,1} = M1;
Red{1,1} = Red1;
Hen{1,1} = He1;
Reh{1,1} = Reh1;
Hz{1,1} = Hz1;
Ds{1,1} = Ds1;
HzDs{1,1} = HzDs1;

 % Si hay descomposición para el segundo nivel, proceder
    if nivel >= 2
        for seed = 1:4
            if mapa1(seed) == 1
                img_r = wav_coef{1,seed};
                [LL, LH, HL, HH] = lwt2(img_r, LiftingScheme=lScheme, Level=1, Int2Int=true);
                wav_coef1 = cell(1,4);
                wav_coef1{1,1} = LL;
                wav_coef1{1,2} = LH{:,:};
                wav_coef1{1,3} = HL{:,:};
                wav_coef1{1,4} = HH{:,:};
                wav_coef{1,seed} = wav_coef1;

                %Calcular las métricas para el nivel 2
                [Ce2, C2, M2, Red2, He2, Reh2, Hz2, Ds2, HzDs2] = calcular_metricas(wav_coef1, sz_img);
                Ce{2,seed} = Ce2;
                C{2,seed} = C2;
                M{2,seed} = M2;
                Red{2,seed} = Red2;
                Hen{2,seed} = He2;
                Reh{2,seed} = Reh2;
                Hz{2,seed} = Hz2;
                Ds{2,seed} = Ds2;
                HzDs{2,seed} = HzDs2;
            end
        end
    end

    % Si hay descomposición para el tercer nivel, proceder
    if nivel >= 3
        for seed = 1:4
            if mapa1(seed) == 1
                wav_coef1 = wav_coef{1,seed};
                wav_coef2 = wav_coef1;
                for kk = 1:4
                    if mapa2(seed,kk) == 1
                        img_r = wav_coef1{1,kk};
                        [LL, LH, HL, HH] = lwt2(img_r, LiftingScheme=lScheme, Level=1, Int2Int=true);
                        wav_coef3 = cell(1,4);
                        wav_coef3{1,1} = LL;
                        wav_coef3{1,2} = LH{:,:};
                        wav_coef3{1,3} = HL{:,:};
                        wav_coef3{1,4} = HH{:,:};
                        wav_coef2{1,kk} = wav_coef3;

                        %Calcular las métricas para el nivel 3
                        [Ce3, C3, M3, Red3, He3, Reh3, Hz3, Ds3, HzDs3] = calcular_metricas(wav_coef3, sz_img);
                        Ce{3,seed}{kk} = Ce3;
                        C{3,seed}{kk} = C3;
                        M{3,seed}{kk} = M3;
                        Red{3,seed}{kk} = Red3;
                        Hen{3,seed}{kk} = He3;
                        Reh{3,seed}{kk} = Reh3;
                        Hz{3,seed}{kk} = Hz3;
                        Ds{3,seed}{kk} = Ds3;
                        HzDs{3,seed}{kk} = HzDs3;
                    end
                end
                if sum(mapa2(seed,:)) ~= 0
                    wav_coef{1,seed} = wav_coef2;
                end
            end
        end
    end

    %% funciones de soporte

function [Ce, C, M, Red, He, Reh, Hz, Ds, HzDs] = calcular_metricas(wav_coef,Nimg)
    
    %inicializar las vectores que almacenan las variables
    Ce= zeros(1,4); % índice de concentración de la energía
    C = zeros(1,4); % índice de compacidad
    M = zeros(1,4); % momentos estadísticos
    Red = zeros(1,4); % relación entre la energía y la dispersión
    He = zeros(1,4); % entropía energética
    Reh = zeros(1,4); % relación entre la energía y la entropía energética
    Hz = zeros(1,4); %entropía Z
    Ds = zeros(1,4); %desviación estandar
    HzDs = zeros(1,4); %Hz*Ds
    
    %loop para rellenar los vectores 
    for i = 1:4
        coeficientes = wav_coef{1,i};
        coeficientes = coeficientes(:);
        Ce(i) = IndiceConcentracionEnergia(coeficientes);
        C(i) = IndiceCompacidad(coeficientes);
        M(i) = MomentosEstadisticos(coeficientes);
        Red(i) = RelacionEnergiaDispersion(coeficientes);
        He(i) = EntropiaEnergetica(coeficientes);
        Reh(i) = RelacionEnergiaEntropia(coeficientes);
        [Hz(i), HzDs(i)] = EntropiaZ(coeficientes,Nimg);
        Ds(i) = std(coeficientes);
    end
end

function Ce = IndiceConcentracionEnergia(coeficientes)
    %Función que calula el índice de concentración de la energía de un
    %conjunto de coeficientes wavelet

    
    media = mean(coeficientes); 
    energia = sum(coeficientes.^2);
    Ce = (1/energia)*sum((coeficientes-media).^2);
end

function C = IndiceCompacidad(coeficientes)
    %Función que calula el índice de compacidad de un
    %conjunto de coeficientes wavelet
    
    N = numel(coeficientes); %número de coeficientes
    sd = std(coeficientes); %desviación estandar 
    energia = sum(coeficientes.^2);
    C = energia/(N*sd);
end

function M = MomentosEstadisticos(coeficientes)
    %Función que calula una métrica basada en diferentes momentos estadísticos de un
    %conjunto de coeficientes wavelet

    media = abs(mean(coeficientes)); 
    varianza = var(coeficientes); 
    energia = sum(coeficientes.^2);
    M = energia/(media*varianza);
end

function Red = RelacionEnergiaDispersion(coeficientes)
    %Función que calula la relación entre la energía y la dispersión de un
    %conjunto de coeficientes wavelet

    sd = std(coeficientes); %desviación estandar 
    energia = sum(coeficientes.^2);
    Red = energia/(sd);
end

function He = EntropiaEnergetica(coeficientes)
    %Función que calula una adaptación de la fórmula de la entropía basada en la energía para un
    %conjunto de coeficientes wavelet

    energia = sum(coeficientes.^2);
    Pe = (1/energia)*(coeficientes.^2); %"probabilidades" en función de la energía relativa 
    Pe(Pe==0) = min(nonzeros(Pe))/10; %para evitar el conflicto debido a los ceros
    He = (-1)*sum(Pe.*log(Pe));%podría analizarse la conveniencia de cambiar la base del logaritmo
end

function Reh = RelacionEnergiaEntropia(coeficientes)
    %Función que calula una adaptación de la fórmula de la entropía basada en la energía para un
    %conjunto de coeficientes wavelet

    N = numel(coeficientes);

    a = 0.01; %peso asociado a la energía
    b = 10; %peso asociado a la entropía

    energia = sum(coeficientes.^2);
    Pe = (1/energia)*(coeficientes.^2); %"probabilidades" en función de la energía relativa 
    Pe(Pe==0) = min(nonzeros(Pe))/10; %para evitar el conflicto debido a los ceros
    He = (-1)*sum(Pe.*log(Pe)); %podría analizarse la conveniencia de cambiar la base del logaritmo

    Reh = a*(energia/N) + b*abs(1-(He/log(N)));
end

function [Hz,HzDs] = EntropiaZ(coeficientes,Nimg)
    % Función para calcular la entropía Z de un conjunto de coeficientes
    % wavelet

    % % Calcular el histograma de la subbanda
    % [counts, edges] = histcounts(coeficientes(:), 'BinMethod', 'integers');
    % 
    % % Normalizar el histograma para obtener la probabilidad
    % prob = counts / sum(counts);
    [prob,N] = probabilidades(coeficientes);
    % 
    % Eliminar las probabilidades cero para evitar log2(0)
    prob = prob(prob > 0);
    
    % Calcular la entropía de Shannon
    entropia = -sum(prob.*log2(prob));
    
    % Calcular la entropía máxima (asumiendo distribución uniforme)
    %N = length(edges) - 1;
    maxentropia = log2(N);
    RH = 1 - (entropia / maxentropia);

    Hz = RH*(numel(coeficientes)/Nimg);

    HzDs = Hz.*(std(coeficientes)./abs(max(coeficientes)-min(coeficientes)));
end

function [prob,N] = probabilidades(coeficientes)
    %Función para calcular las probabilidades de ocurrencia relativas para
    %cada conjunto de coeficientes wavelet 

    vunique = unique(coeficientes); %conjunto de valores únicos
    N = numel(vunique);
    count = zeros(1,N);
    for i =1:N
        validation = zeros(size(coeficientes));
        validation(coeficientes==vunique(i)) = 1; %esta aignación permitirá contar el número de coincidencias
        count(i) = sum(validation);
    end
    prob = count/numel(coeficientes);

end

end
