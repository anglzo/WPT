clc;
clear;
close all;

% Directorio de las imágenes
directorio = 'C:\Users\ANGEL\OneDrive\Escritorio\tesis\codigos matlab\imagenes';
num_img=4;

% Obtener la lista de archivos de imagen en la carpeta
archivos = dir(fullfile(directorio, '*.jpg')); % Cambiar *.jpg por el tipo de imagen que desees procesar
archivo_imagen = fullfile(directorio, archivos(num_img).name); %comentar para varias
archivo_imagen_msj = fullfile(directorio, archivos(14).name);

% Definir el esquema de lifting wavelet
lScheme = liftingScheme("Wavelet", "db4");

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
mapa2 = [1 1 1 1; 1 1 1 1 ;1 1 1 1; 1 1 1 1];


%hacer la descomposición para n niveles de resolución
[hz,std, wav_coef] = descomponer_imprimir(img,archivos,num_img,lScheme,3,mapa1,mapa2);

%mostrar descomposición
mostrar_imagen(wav_coef);

%% Poda de acuerdo a los parametros de entropia z y std

%Mapa optimo de descomposición
[map_n1, map_n2] = calcular_mapa_optimo(hz, std, mapa1, mapa2);

%Descomposición optima
[hz_opt,std_opt, wav_optimo] = descomponer_imprimir(img,archivos,num_img,lScheme,3,map_n1,map_n2);
bp = best_parameter(hz_opt, std_opt);

dimen = length(bp);

%% Poda de acuerdo a la energia de los coeficientes
[ex, wav_en] = descomponer_energia(img,archivos,num_img,lScheme,3,mapa1,mapa2);
[map_en_1, map_en_2] = calcular_mapa_energia(ex, mapa1, mapa2);

[ex_opt, wav_en_opt] = descomponer_energia(img,archivos,num_img,lScheme,3,map_en_1,map_en_2);
bpn = best_parameter_en(ex_opt);
dimen_en = length(bpn);

%% Incrustación en la mejor descomposición
for i = 1 : dimen
    isubbanda = bp(2,i);
    subbanda = indices_sub(isubbanda,wav_optimo,map_n1,map_n2);
    [wav_coef_mod,imgSecretaF, imgSecretaC, bitsimg, numBits] = incrustar_imagen_v4(wav_optimo, img_msj, subbanda);
    if i == 1
        break
    end
end

% %incrustación energia
% for i = 1 : dimen_en
%     isubbanda = bpn(2,i);
%     subbanda = indices_sub(isubbanda,wav_en_opt,map_en_1,map_en_2);
%     [wav_coef_mod,imgSecretaF, imgSecretaC, bitsimg, numBits] = incrustar_imagen_v4(wav_en_opt, img_msj, subbanda);
%     if i == 1
%         break
%     end
% end


%%
%En este punto ya esta construida la imagen estego

%incrustar información
%wav_coef_mod = incrustar_imagen(wav_coef, img_msj, subbandasSeleccionadas, 8);
%[wav_coef_mod, imgSecretaF, imgSecretaC, numBits] = incrustar_imagen_v2 (wav_coef, img_msj, subbandasSeleccionadas);


%reeconstrucción de la imagen con la información incrustada

img_rec = reconstruir_wavelet(wav_coef_mod, lScheme,3, map_n1, map_n2);

%mostrar imagen reeconstruida
img_rec = uint8(img_rec);  % Convertir a formato de 8 bits si es necesario

% % Mostrar la imagen
figure;
imshow(img_rec);
title("imagen estego")

%% Receptor
% Descomponer la imagen stego (img_rec) en los coeficientes wavelet
wav_coef_rx = descomponer(img_rec, archivos, num_img, lScheme, 3, map_n1, map_n2);

% Extraer la imagen secreta
img_msj_rx = extraer_imagen(wav_coef_rx, subbanda, imgSecretaC, imgSecretaF, bitsimg, numBits);

figure;
%Mostrar la imagen secreta
imshow(uint8(img_msj_rx));
title("imagen secreta extraida")

%comparar imagen original y reconstruida
fprintf("similitud imagen portada imagen estego:\n");
comparar_imagenes(img,img_rec);

fprintf("similitud imagen secreta origen y recepción:\n");
comparar_imagenes(img_msj,img_msj_rx);
