function [Hzs, stdvs] = calcular_entropias(wav_coef)
    
    %inicializar las vectores que almacenan las variables
    entropias = zeros(1,4);
    maxentropias = zeros(1,4);
    RHs = zeros(1,4);
    stdvs = zeros(1,4);
    SZs = zeros(1,4);
    SZ_RHs = zeros(1,4);
    Hzs = zeros(1,4);
    
    %loop para rellenar los vectores 
    for i = 1:4
        [entropias(i), maxentropias(i), RHs(i), stdvs(i), SZs(i), SZ_RHs(i),Hzs(i)] = calcular_entropia(wav_coef{1,i});
    end
end

% Función para calcular la entropía de una subbanda
function [entropia, maxentropia, RH, stdv, SZ, SZ_RH, Hz] = calcular_entropia(subbanda)

    % Calcular el histograma de la subbanda
    [counts, edges] = histcounts(subbanda(:), 'BinMethod', 'integers');
    
    % Normalizar el histograma para obtener la probabilidad
    prob = counts / sum(counts);
    
    % Eliminar las probabilidades cero para evitar log2(0)
    prob = prob(prob > 0);
    
    % Calcular la entropía de Shannon
    entropia = -sum(prob .* log2(prob));
    
    % Calcular la entropía máxima (asumiendo distribución uniforme)
    M = length(edges) - 1;
    maxentropia = log2(M);
    RH = 1 - (entropia / maxentropia);

    % Calcular la desviación estándar
    stdv = std(subbanda(:));  

    % Calcular size y sz_rh
    SZ = numel(subbanda(:));
    SZ_RH = SZ*RH;

    Hz = RH * (SZ/1048576);


end