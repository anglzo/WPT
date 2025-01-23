function [mapa_optimo_nivel1,mapa_optimo_nivel2] = calcularMapa(metrica,modo)
    mapa_optimo_nivel1 = ones(1, 4);  % Mapa óptimo de nivel 1
    mapa_optimo_nivel2 = ones(4, 4);  % Mapa óptimo de nivel 2
    %extraer todos los valores de una celda          
    datos = flattenCell(metrica);
    index =1:84;
    
    %definición de umbrales 
    %método de cuartiles 
    Q1 = prctile(datos, 25); % Primer cuartil (25%)
    Q2 = prctile(datos, 50); % Segundo cuartil o mediana (50%)
    Q3 = prctile(datos, 75); % Tercer cuartil (75%)
    %boxplot(datos,'Notch','on','Whisker',1), set(gcf,'Color','white')
    
    %agrupar valores según el cuartil 
    coefQ1 = index(datos<=Q1);
    coefQ12 = index(datos>Q1 & datos<=Q2);
    coefQ23 = index(datos>Q2 & datos<=Q3);
    coefQ3 = index(datos>Q3);
    if modo == 1
        Matrix_coefsQ = [coefQ1; coefQ12; coefQ23; coefQ3];
    else
        Matrix_coefsQ = [coefQ3; coefQ23; coefQ12; coefQ1];
    end
    
    seed = 1:4;
    coef_indx_nd3 = 16*seed + 5;
    coef_indx_nd2 = 4*seed + 1;
    podar = 0;
    ths = 0; %umbral
    while podar == 0
        ths = ths + 1;
        
        coef_val = Matrix_coefsQ(ths,:);    
        %se recorre cada rama
        for r = 1:4
                nd3 = coef_indx_nd3(r):coef_indx_nd3(r)+15;
                nd2 = coef_indx_nd2(r):coef_indx_nd2(r)+3;
                %comparación con el primer umbral
                flag_nd3 = ismember(nd3,coef_val); %se tienen que separar por ramas
                flag_nd3 = reshape(flag_nd3,4,4); %cada columna representa una rama
                flag_nd3 = sum(double(flag_nd3));
                flag_nd2 = double(ismember(nd2,coef_val));
                flag_nd1 = double(ismember(r,coef_val));
                %dispersión de los datos 
                datos_nd3 = datos(nd3);
                datos_nd3 = reshape(datos_nd3,4,4); %cada columna representa una rama
                disp_nd3 = std(datos_nd3)./abs(max(datos_nd3)-min(datos_nd3)); %desviación estandar comparada con el rango dinámico 
                datos_nd2 = datos(nd2);
                disp_nd2 = std(datos_nd2)./abs(max(datos_nd2)-min(datos_nd2));
                if sum(disp_nd2.*flag_nd2)+sum(disp_nd3.*flag_nd3)+flag_nd1 == 0 %no hay nada en el umbral
                    if ths == 3
                        mapa_optimo_nivel1(r) = 0;
                        podar = 1; %si no encuentra nada en el umbral 3, deja de comparar
                    end
                elseif sum(disp_nd3.*flag_nd3)>0 %se tienen elementos que están dentro del umbral
                    if modo == 1
                        comp = disp_nd3.*flag_nd3<=disp_nd2.*flag_nd2;
                    else
                        comp = disp_nd3.*flag_nd3>=disp_nd2.*flag_nd2;
                    end
                    if sum(comp)>0 %si resulta mejor el nivel dos que el tres
                        mapa_optimo_nivel2(r,comp) = 0; %se poda
                        if sum(disp_nd2.*flag_nd2)>0 
                             if modo == 1
                                comp = mean(disp_nd2.*flag_nd2)<=flag_nd1;
                             else
                                 comp = mean(disp_nd2.*flag_nd2)>=flag_nd1;
                             end

                            if sum(comp)>0 %si resulta mejor el nivel uno que el dos
                                mapa_optimo_nivel1(r) = 0;
                                mapa_optimo_nivel2(r,:) = zeros(1,4);
                                podar = 1;
                            end
                        end
                    else
                        if ths == 3
                            podar = 1; %si no encuentra nada en el umbral 3, deja de comparar
                        end
                    end
                end         
        end
        
        if ths == 4

            [mapa_optimo_nivel1, mapa_optimo_nivel2] = calcular_mapa(metrica);
            podar = 1;

        end

    end

end

function datos = flattenCell(metrica)
    %Función para organizar todos los datos de una celda en un vector 
    %ND1 ND2(1,2,3,4) ND3(1,2,3,4) - 84 elementos
    datos = zeros(1, 84);

    %ND1
    datos(1:4) = metrica{1,1};
    %ND2 y %ND3
    for i =1:4
      datos(i*4+1:(i+1)*4) = metrica{2,i}; 
      datos(i*16+5:i*16+20) = cell2mat(metrica{3,i}); 
    end
end

function [mapa_optimo_nivel1, mapa_optimo_nivel2] = calcular_mapa(metrica)
    % Inicializar mapas óptimos
    mapa_optimo_nivel1 = ones(1, 4);  % Mapa óptimo de nivel 1
    mapa_optimo_nivel2 = ones(4, 4);  % Mapa óptimo de nivel 2
    

    % metodo 1 (promedio energia hijas)

    % Comparación de subbandas de Nivel 1 con subbandas hijas de Nivel 2
    for k = 1:4
        
            % Calcula el parámetro para la subbanda de Nivel 1
            parametro_nivel1 = metrica{1, 1}(k);

            % Suma de parámetros de subbandas hijas en Nivel 2
            parametro_hijas_nivel2 = 0;
            for kk = 1:4
                parametro_hijas_nivel2 = parametro_hijas_nivel2 + metrica{2, k}(kk);
            end
                 
            % Criterio de poda para cada subbanda de Nivel 1 y sus hijas de Nivel 2
            if parametro_hijas_nivel2 >= parametro_nivel1
                mapa_optimo_nivel1(k) = 0;  % Poda en el mapa del nivel 1 para la subbanda k
            end
        
    end

    % Comparación de subbandas de Nivel 2 con subbandas hijas de Nivel 3
    for k = 1:4
        if mapa_optimo_nivel1(k) == 1  % Solo si la subbanda sigue activa en el nivel 1
            for kk = 1:4
                
                    % Calcula el parámetro para la subbanda de Nivel 2
                    parametro_nivel2 = metrica{2, k}(kk);

                    % Suma de parámetros de subbandas hijas en Nivel 3
                    parametro_hijas_nivel3 = 0;
                    for kkk = 1:4
                        parametro_hijas_nivel3 = parametro_hijas_nivel3 + metrica{3, k}{kk}(kkk);
                    end
                    
                    % Criterio de poda para cada subbanda de Nivel 2 y sus hijas de Nivel 3
                    if parametro_hijas_nivel3 >= parametro_nivel2
                        mapa_optimo_nivel2(k, kk) = 0;  % Poda en el mapa del nivel 2 para la subbanda k, kk
                    end
                
            end

        else

        mapa_optimo_nivel2(k,:) = [0 , 0, 0, 0];

        end
    end
end