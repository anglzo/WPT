function totalSum = suma(inputCell)
    totalSum = 0; % Inicializa la suma
    
    for i = 1:numel(inputCell) % Recorre cada elemento de la celda
        currentElement = inputCell{i};
        
        % Verifica si el elemento es un array `double` y no una celda
        if  ~iscell(currentElement)
            totalSum = totalSum + size(currentElement(:)); % Suma los elementos
        end
    end
end