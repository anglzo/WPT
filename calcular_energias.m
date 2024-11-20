 function [ex] = calcular_energias(wav_coef)
% Calcular la energía de cada grupo de coeficientes
ex = zeros(1,4);

for i = 1:numel(wav_coef)
    coef = wav_coef{i};  % Extraer los coeficientes del grupo i
    ex(i) = sum(coef(:).^2);  % Calcular la energía
end
end