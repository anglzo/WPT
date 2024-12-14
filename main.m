clc;
clear;
close all;

% Directorio de las imágenes
%directorio = '/Users/juanmanuelordonez/Documents/MATLAB/TESIS/v/imagenes';
directorio = 'C:\Users\ANGEL\OneDrive\Escritorio\tesis\codigos matlab\imagenes';
num_img = 11;

% Obtener la lista de archivos de imagen en la carpeta
archivos = dir(fullfile(directorio, '*.jpg')); % Cambiar *.jpg por el tipo de imagen que desees procesar
archivo_imagen = fullfile(directorio, archivos(num_img).name); % Comentar para varias
archivo_imagen_msj = fullfile(directorio, archivos(13).name);

matriz = zeros(64, 64);

% Dividir la matriz en cuatro cuadrantes y asignar valores
matriz(1:32, 1:32) = 0; % Primer cuadrante (arriba izquierda)
matriz(1:32, 33:64) = 1; % Segundo cuadrante (arriba derecha)
matriz(33:64, 1:32) = 2; % Tercer cuadrante (abajo izquierda)
matriz(33:64, 33:64) = 3; % Cuarto cuadrante (abajo derecha)

prueba = int2bit(matriz(:), 8, true);  % Convertir a binario
prueba = reshape(prueba', [], 1)';   % Colapsar en un vector de bits

% Definir el esquema de lifting wavelet
lScheme = liftingScheme("Wavelet", "haar");

% Asegurarnos de que haya archivos para procesar
if isempty(archivos)
    error('No se encontraron archivos de imagen en el directorio especificado.');
end

imagen = imread(archivo_imagen);
imagen_gris = rgb2gray(imagen);
img = double(imagen_gris);
figure;
imshow(uint8(img));
title("imagen original");

imagen_msj = imread(archivo_imagen_msj);
imagen_gris_msj = rgb2gray(imagen_msj);
img_msj = double(imagen_gris_msj);
figure;
imshow(uint8(img_msj));
title("imagen secreta");

%% Descomposición inicial

% Definir los mapas de descomposición
mapa1 = [1 1 1 1];
mapa2 = [1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1];

% Hacer la descomposición para n niveles de resolución
[hz, std, wav_coef] = descomponer_imprimir(img, archivos, num_img, lScheme, 3, mapa1, mapa2);

% Mostrar descomposición
mostrar_imagen(wav_coef);

%% Poda de acuerdo a los parámetros de entropía z y std

% Mapa óptimo de descomposición
[map_n1, map_n2] = calcular_mapa_optimo(hz, std, mapa1, mapa2);

% Descomposición óptima
[hz_opt, std_opt, wav_optimo] = descomponer_imprimir(img, archivos, num_img, lScheme, 3, map_n1, map_n2);
bp = best_parameter(hz_opt, std_opt);

dimen = length(bp);

%% Incrustación en la mejor descomposición
%vector subbandas
vec_sub = {};
vec_coef = {};

for i = 1:dimen
    isubbanda = bp(2,i);
    subbanda = indices_sub(isubbanda,wav_optimo,map_n1,map_n2);
    vec_sub{i} = subbanda;
    vec_coef{i} = obtener_coeficiente(wav_optimo, vec_sub{i});
end

NLSB = 4; % Número máximo de LSB que se pueden modificar
bits_av = suma(vec_coef)* NLSB; % suma de bits disponibles para incustar
numBitsCoef = 16; %se representan con 16 bits la información de la imagen portada

[imgSecretaF, imgSecretaC] = size(img_msj);
infSecre = de2bi(img_msj(:), 8, 'left-msb');  % Convertir a binario
infSecre = reshape(infSecre', [], 1)';   % Colapsar en un vector de bits
bits_img_msj = infSecre;
residuo = numel(infSecre); % Inicia teniendo pendiente por incrustrar toda la información secreta

% Verificar si hay suficiente espacio en los coeficientes wavelet
if residuo > bits_av
    error('No hay suficiente espacio en la imagen de portada para incrustar toda la información de la imagen secreta.');
end

cont = 0; % Contador
bitsrest = 0;
array_nlsb = zeros(1, dimen); % Vector para almacenar el número de LSB modificados en cada grupo de coeficientes
wav_coef_mod = wav_optimo;
while residuo > 0 
    cont = cont + 1;
    if  ~iscell(vec_coef{cont})
        isubbanda = bp(2, cont);
        subbanda = indices_sub(isubbanda, wav_optimo, map_n1, map_n2);
        nlsb = ceil((residuo)/(numel(vec_coef{cont}))); 
    
        if nlsb <= NLSB
            array_nlsb(cont) = nlsb;
            porIncrus = nlsb*(numel(vec_coef{cont}));
            [wav_coef_mod, bitsincrus] = incrustar_imagen_v5(wav_coef_mod, infSecre, subbanda, nlsb);
                   
            disp("imagen secreta incrustada :)")
            residuo = residuo - porIncrus; %con esto saldría del ciclo while
        else
            array_nlsb(cont) = NLSB;
            porIncrus = NLSB*(numel(vec_coef{cont}));
            incrus = infSecre(1:porIncrus); %porcentaje de la información secreta que se va a incrustar
            [wav_coef_mod, bitsincrus] = incrustar_imagen_v5(wav_coef_mod, incrus, subbanda, NLSB);
    
            infSecre = infSecre(porIncrus+1:end); %se descarta la información que ya se ha ocultado
            residuo = residuo - porIncrus; 
            fprintf('porcentaje incrustado %d',(length(bits_img_msj)/length(infSecre)));
        end
    end


end

% Verificar si toda la información secreta ha sido incrustada
if residuo > 0
    warning('No se pudo incrustar toda la información secreta en la imagen de portada.');
else
    disp('Toda la información secreta ha sido incrustada correctamente.');
end

% Reconstrucción de la imagen con la información incrustada
img_rec = reconstruir_wavelet(wav_coef_mod, lScheme, 3, map_n1, map_n2);

% Mostrar imagen reconstruida
img_rec = uint8(img_rec);  % Convertir a formato de 8 bits si es necesario
figure;
imshow(img_rec);
title("imagen estego")

%% Receptor
% Descomponer la imagen stego (img_rec) en los coeficientes wavelet
wav_coef_rx = descomponer(img_rec, archivos, num_img, lScheme, 3, map_n1, map_n2);

% Extraer la imagen secreta
[img_msj_rx, bits_rx] = extraer_imagen(wav_coef_rx, vec_sub, imgSecretaF, imgSecretaC, bits_img_msj, array_nlsb);
a = isequal(bits_rx,bitsincrus)

figure;
% Mostrar la imagen secreta
imshow(uint8(img_msj_rx));
title("imagen secreta extraida")

% Comparar imagen original y reconstruida
fprintf("similitud imagen portada imagen estego:\n");
comparar_imagenes(img, img_rec);

fprintf("similitud imagen secreta origen y recepción:\n");
comparar_imagenes(img_msj, img_msj_rx);