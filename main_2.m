clc;
clear;
close all;

% Directorio de las imágenes
%directorio = '/Users/juanmanuelordonez/Documents/MATLAB/TESIS/v/imagenes';
%directorio = 'C:\Users\ANGEL\OneDrive\Escritorio\tesis\codigos matlab\imagenes_portada_nuevas';
directorio = '/Users/angel/Downloads/imagenes_portada_nuevas'
num_img =6;

% Obtener la lista de archivos de imagen en la carpeta
archivos = dir(fullfile(directorio, '*.jpg')); % Cambiar *.jpg por el tipo de imagen que desees procesar
archivo_imagen = fullfile(directorio, archivos(num_img).name); % Comentar para varias
archivo_imagen_msj = fullfile(directorio, archivos(12).name);

% Asegurarnos de que haya archivos para procesar
if isempty(archivos)
    error('No se encontraron archivos de imagen en el directorio especificado.');
end
%% imagen portada
imagen = imread(archivo_imagen);
imagen_gris = rgb2gray(imagen);
img = double(imagen_gris);
sz_img = numel(img);
figure;
imshow(uint8(img));
title("imagen original");

%% imagen secreta
imagen_msj = imread(archivo_imagen_msj);
imagen_gris_msj = rgb2gray(imagen_msj);
img_msj = double(imagen_gris_msj);
figure;
imshow(uint8(img_msj));
title("imagen secreta");

%% Definir el esquema de lifting wavelet
lScheme = liftingScheme("Wavelet", "haar");

%% Descomposición inicial

% Definir los mapas de descomposición
mapa1 = [1 1 1 1];
mapa2 = [1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1];

% Hacer la descomposición para n niveles de resolución
[Ce, C, M, Red, He, Reh, Hz, Ds, HzDs, wav_coef] = descomponer_parametros(img, archivos, num_img, lScheme, 3, mapa1, mapa2,sz_img);

%% Busqueda del mapa óptimo de acuerdo a la métrica seleccionada

%seleccionar métrica 
 opt = 8; % Ce índice de concentración de la energía
% opt = 2; % C índice de compacidad
% opt = 3; % M momentos estadísticos
% opt = 4; % Red relación entre la energía y la dispersión
% opt = 5; % He entropía energética
% opt = 6; % Reh relación entre la energía y la entropía energética
% opt = 7; % Hz entropía Z
% opt = 8; % Ds desviación estandar
% opt = 9; % Hz*Ds

switch(opt)
   case 1
        metrica = Ce;
        modo = 0; % 1 valores pequeños convenientes 
                  % 0 valores grandes convenientes 
   case 2
        metrica = C;
        modo = 1;
   case 3
        metrica = M;
        modo = 1;
   case 4
        metrica = Red;
        modo = 1;
   case 5
        metrica = He;
        modo = 0;
   case 6
        metrica = Reh;
        modo = 1;
    case 7 
        metrica = Hz;
        modo = 0;
    case 8
        metrica = Ds;
        modo = 0;
    case 9
        metrica = HzDs;
        modo = 0;
end

% Mapa óptimo de descomposición
[mapa_optimo_nivel1,mapa_optimo_nivel2] = calcularMapa(metrica,modo)

%% Descomposición óptima de aceurdo a la métrica seleccionada

[Ce_opt, C_opt, M_opt, Red_opt, He_opt, Reh_opt, Hz_opt, Ds_opt, HzDs_opt, wav_coef_opt] = descomponer_parametros(img, archivos, num_img, lScheme, 3, mapa_optimo_nivel1, mapa_optimo_nivel2, sz_img); %aqui

metrics = {Ce_opt, C_opt, M_opt, Red_opt, He_opt, Reh_opt, Hz_opt, Ds_opt, HzDs_opt, wav_coef_opt};
metrica_opt = metrics{opt};

% Mostrar descomposición
mostrar_imagen(wav_coef_opt);

bp = best_parameter_en(metrica_opt,modo); %organizar los parámetros de acuerdo al modo

dimen = length(bp);

%% Incrustación en la mejor descomposición
%vector subbandas
vec_sub = {};
vec_coef = {};

for i = 1:dimen
    isubbanda = bp(2,i);
    subbanda = indices_sub(isubbanda,wav_coef_opt,mapa_optimo_nivel1,mapa_optimo_nivel2); %aqui
    vec_sub{i} = subbanda;
    vec_coef{i} = obtener_coeficiente(wav_coef_opt, vec_sub{i});
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
wav_coef_mod = wav_coef_opt;
while residuo > 0 
    cont = cont + 1;
    if  ~iscell(vec_coef{cont})
        isubbanda = bp(2, cont);
        subbanda = indices_sub(isubbanda, wav_coef_opt, mapa_optimo_nivel1, mapa_optimo_nivel2); %aqui
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
img_rec = reconstruir_wavelet(wav_coef_mod, lScheme, 3, mapa_optimo_nivel1, mapa_optimo_nivel2); %aqui

% Mostrar imagen reconstruida
img_rec = uint8(img_rec);  % Convertir a formato de 8 bits si es necesario
figure;
imshow(img_rec);
title("imagen estego")

%% Receptor
% Descomponer la imagen stego (img_rec) en los coeficientes wavelet
wav_coef_rx = descomponer(img_rec, archivos, num_img, lScheme, 3, mapa_optimo_nivel1, mapa_optimo_nivel2); %aqui

% Extraer la imagen secreta
[img_msj_rx, bits_rx] = extraer_imagen(wav_coef_rx, vec_sub, imgSecretaF, imgSecretaC, bits_img_msj, array_nlsb);

figure;
% Mostrar la imagen secreta
imshow(uint8(img_msj_rx));
title("imagen secreta extraida")

% Comparar imagen original y reconstruida
fprintf("similitud imagen portada imagen estego:\n");
comparar_imagenes(img, img_rec);

fprintf("similitud imagen secreta origen y recepción:\n");
comparar_imagenes(img_msj, img_msj_rx);