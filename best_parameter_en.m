function bp = best_parameter_en(ex)
% Inicializar vectores para almacenar datos y etiquetas
en = [];
bp = [];

% Recorrer cada elemento de la celda C
for i = 1:size(ex, 1)
    for j = 1:size(ex, 2)
        energia_actual = ex{i, j};
        
        % Verificar si el contenido es una celda
        if iscell(energia_actual)
            energia_actual = cell2mat(energia_actual(:));
        end

        % Añadir los datos al vector general
        en = [en; energia_actual(:)];
       
    end
end

en = en';

% Ordenar los valores y las etiquetas en conjunto
index = [1:length(en)];

en = [en ; index];
[~, indices] = sort(en(1, :), 'ascend');

% Reordenar ambas filas según los índices obtenidos
bp = en(:, indices);

end