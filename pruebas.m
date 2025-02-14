clc;
clear;
close all;

% Directorio de las imágenes
directorio = '/Users/angel/Downloads/imagenes_portada_nuevas';

% Obtener la lista de archivos de imagen en la carpeta
archivos = dir(fullfile(directorio, '*.jpg'));

% Verificar si hay archivos para procesar
if isempty(archivos)
    error('No se encontraron archivos de imagen en el directorio especificado.');
end

num_imgs = 10; % Número total de imágenes disponibles
num_opts = 9; % Número total de opciones en "opt"

% Inicializar matriz para almacenar los SSIM
ssim_results = zeros(num_imgs, num_opts);

families = {'bior6.8', 'rbio1.1', 'bior1.5', 'bior2.2', 'bior2.4', 'bior2.8', 'rbio1.5', 'bior4.4', 'bior2.6','rbio1.3','rbio2.6','rbio2.4', 'bior1.1','db5','haar', 'rbio2.2' };

for fx = 1:length(families)
% Definir el esquema de lifting wavelet
familie = families{fx};
lScheme = liftingScheme("Wavelet", familie);

    % Iterar por cada imagen
for img_idx = 1:num_imgs
    % Leer la imagen de portada
    archivo_imagen = fullfile(directorio, archivos(img_idx).name);
    imagen = imread(archivo_imagen);
    imagen_gris = rgb2gray(imagen);
    img = double(imagen_gris);
    sz_img = numel(img);

    % Leer la imagen secreta (usar siempre la misma, por ejemplo, la imagen 11)
    archivo_imagen_msj = fullfile(directorio, archivos(13).name);
    imagen_msj = imread(archivo_imagen_msj);
    imagen_gris_msj = rgb2gray(imagen_msj);
    img_msj = double(imagen_gris_msj);

    % Mapas iniciales de descomposición
    mapa1 = [1  1 1 1];
    mapa2 = [1  1 1 1; 1  1 1 1; 1  1 1 1; 1  1 1 1];
   
    % Descomposición inicial
    [Ce, C, M, Red, He, Reh, Hz, Ds, HzDs, wav_coef] = descomponer_parametros(img, archivos, img_idx, lScheme, 3, mapa1, mapa2, sz_img);

    % Iterar por cada opción de "opt"
    for opt = 1:num_opts
        % Seleccionar métrica y modo
        switch(opt)
            case 1
                metrica = Ce; modo = 0;
            case 2
                metrica = C; modo = 1;
            case 3
                metrica = M; modo = 1;
            case 4
                metrica = Red; modo = 1;
            case 5
                metrica = He; modo = 0;
            case 6
                metrica = Reh; modo = 1;
            case 7
                metrica = Hz; modo = 0;
            case 8
                metrica = Ds; modo = 0;
            case 9
                metrica = HzDs; modo = 0;
        end

        % Calcular el mapa óptimo
        [mapa_optimo_nivel1, mapa_optimo_nivel2] = calcularMapa(metrica, modo);

        % Descomposición óptima según la métrica seleccionada
        [Ce_opt, C_opt, M_opt, Red_opt, He_opt, Reh_opt, Hz_opt, Ds_opt, HzDs_opt,wav_coef_opt] = descomponer_parametros(img, archivos, img_idx, lScheme, 3, mapa_optimo_nivel1, mapa_optimo_nivel2, sz_img);
        
        metrics = {Ce_opt, C_opt, M_opt, Red_opt, He_opt, Reh_opt, Hz_opt, Ds_opt, HzDs_opt};
        metrica_opt = metrics{opt};

        % Incrustación de la imagen secreta
        wav_coef_mod = wav_coef_opt;
        [imgSecretaF, imgSecretaC] = size(img_msj);
        infSecre = de2bi(img_msj(:), 8, 'left-msb');
        infSecre = reshape(infSecre', [], 1)';
        bits_img_msj = infSecre;
        residuo = numel(infSecre);
        

        % Verificar espacio disponible
        vec_coef = {};
        bp = best_parameter_en(metrica_opt, modo);
        dimen = length(bp);
        for i = 1:dimen
            isubbanda = bp(2, i);
            subbanda = indices_sub(isubbanda, wav_coef_opt, mapa_optimo_nivel1, mapa_optimo_nivel2);
            vec_sub{i} = subbanda;
            vec_coef{i} = obtener_coeficiente(wav_coef_opt, subbanda);
        end

        NLSB = 4; % Número máximo de LSB
        bits_av = suma(vec_coef) * NLSB;
        if residuo > bits_av
            error('No hay suficiente espacio en la imagen de portada para incrustar toda la información de la imagen secreta.');
        end

        % Proceso de incrustación
        cont = 0;
        array_nlsb = zeros(1, dimen);
        while residuo > 0
            cont = cont + 1;
            if ~iscell(vec_coef{cont})
                isubbanda = bp(2, cont);
                subbanda = indices_sub(isubbanda, wav_coef_opt, mapa_optimo_nivel1, mapa_optimo_nivel2);
                nlsb = ceil((residuo) / (numel(vec_coef{cont})));
                if nlsb <= NLSB
                    wav_coef_mod = incrustar_imagen_v5(wav_coef_mod, infSecre, subbanda, nlsb);
                    array_nlsb(cont) = nlsb;
                    porIncrus = nlsb*(numel(vec_coef{cont}));
                    residuo = 0;
                else
                    array_nlsb(cont) = NLSB;
                    porIncrus = NLSB * (numel(vec_coef{cont}));
                    incrus = infSecre(1:porIncrus);
                    wav_coef_mod = incrustar_imagen_v5(wav_coef_mod, incrus, subbanda, NLSB);
                    infSecre = infSecre(porIncrus + 1:end);
                    residuo = residuo - porIncrus;
                end
            end
        end

        % Reconstrucción de la imagen estego
        img_rec = reconstruir_wavelet(wav_coef_mod, lScheme, 3, mapa_optimo_nivel1, mapa_optimo_nivel2);

        % Calcular SSIM entre la imagen original y la estego
        ssim_value = ssim(uint8(img_rec), uint8(img));
        ssim_results(img_idx, opt) = ssim_value;

        
        % Descomponer la imagen stego (img_rec) en los coeficientes wavelet
        wav_coef_rx = descomponer(img_rec, archivos, img_idx, lScheme, 3, mapa_optimo_nivel1, mapa_optimo_nivel2); %aqui
        
        % Extraer la imagen secreta
        [img_msj_rx, bits_rx] = extraer_imagen(wav_coef_rx, vec_sub, imgSecretaF, imgSecretaC, bits_img_msj, array_nlsb);
        
        

            fprintf('%d,%d, %.4f, %s\n ', img_idx,opt, ssim_value, familie);



        
    end
end




end



% Guardar resultados en un archivo
%save('ssim_results.mat', 'ssim_results');

fprintf('Proceso completado. Resultados guardados en "ssim_results.mat".\n');
