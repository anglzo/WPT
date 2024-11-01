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


% Definir los mapas de descomposición
mapa1 = [1 1 1 1];
mapa2 = [1 1 1 1; 1 1 1 1 ;1 1 1 1; 0 0 0 0 ];


%hacer la descomposición para n niveles de resolución
wav_coef = descomponer_imprimir(img,archivos,num_img,lScheme,3,mapa1,mapa2);

%mostrar descomposición
mostrar_imagen(wav_coef);
subbandasSeleccionadas = [1, 3, 1; 1, 2, 2];
%incrustar información
%wav_coef_mod = incrustar_imagen(wav_coef, img_msj, subbandasSeleccionadas, 8);
[wav_coef_mod, imgSecretaF, imgSecretaC, numBits] = incrustar_imagen_v2 (wav_coef, img_msj, subbandasSeleccionadas);
%reeconstrucción de la imagen
img_rec = reconstruir_wavelet(wav_coef_mod, lScheme,3, mapa1, mapa2);

%mostrar imagen reeconstruida
img_rec = uint8(img_rec);  % Convertir a formato de 8 bits si es necesario

% % Mostrar la imagen
figure;
imshow(img_rec);
title("imagen estego")

% Descomponer la imagen stego (img_rec) en los coeficientes wavelet
wav_coef_mod = descomponer_imprimir(img_rec, archivos, num_img, lScheme, 3, mapa1, mapa2);

% Extraer la imagen secreta
img_secreta_extraida = extraer_imagenv2(wav_coef_mod, subbandasSeleccionadas, imgSecretaC, imgSecretaF, numBits);

% figure;
% % Mostrar la imagen secreta
% imshow(uint8(img_secreta_extraida));
% title("imagen secreta extraida")

%comparar imagen original y reconstruida
comparar_imagenes(img,img_rec);
