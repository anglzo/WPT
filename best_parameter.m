function bp = best_parameter(hz,std)
% Inicializar vectores para almacenar datos y etiquetas
z = [];
all_entropy =  [];
all_std = [];
all_data = [];
bp = [];


% Recorrer cada elemento de la celda C
for i = 1:size(hz, 1)
    for j = 1:size(hz, 2)
        entropia_actual = hz{i, j};
        std_actual = std{i,j};

        
        % Verificar si el contenido es una celda
        if iscell(entropia_actual)
            entropia_actual = cell2mat(entropia_actual(:));
        end

          % Verificar si el contenido es una celda
        if iscell(std_actual)
            std_actual = cell2mat(std_actual(:));
        end
        
        % Añadir los datos al vector general
        all_entropy = [all_entropy; entropia_actual(:)];
        all_std = [all_std; std_actual(:)];
       
    end
end

z = all_entropy .* all_std;
z = z';

% Ordenar los valores y las etiquetas en conjunto
index = [1:length(z)];

all_data = [z ; index];
[~, indices] = sort(all_data(1, :), 'ascend');

% Reordenar ambas filas según los índices obtenidos
bp = all_data(:, indices);


end